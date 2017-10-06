%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 20 May 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(training_match).

-include("tplt_def.hrl").
-include("packet_def.hrl").
-include("common_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("record_def.hrl").
-include("business_log_def.hrl").
-include("event_def.hrl").

-compile(export_all).

%% API
-export([start/0, update_rank/3, rand_role_by_lev/2]).

-export([proc_req_train_match_list/1, 
	 proc_req_start_train_match/1, 
	 proc_req_train_match_settle/1, 
	 proc_req_get_train_match_times_info/1, 
	 proc_req_buy_train_match_times/1, 
	 proc_req_get_train_award/1]).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec 注册相关事件
%% @end
%%--------------------------------------------------------------------
start() ->
    packet:register(?msg_req_train_match_list, {?MODULE, proc_req_train_match_list}),
    packet:register(?msg_req_start_train_match, {?MODULE, proc_req_start_train_match}),
    packet:register(?msg_req_train_match_settle, {?MODULE, proc_req_train_match_settle}),
    packet:register(?msg_req_get_train_match_times_info, {?MODULE, proc_req_get_train_match_times_info}),
    packet:register(?msg_req_buy_train_match_times, {?MODULE, proc_req_buy_train_match_times}),
    packet:register(?msg_req_get_train_award, {?MODULE, proc_req_get_train_award}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec获取训练赛对象
%% @end
%%--------------------------------------------------------------------
proc_req_train_match_list(Packet = #req_train_match_list{list_type = Type}) ->
  io_helper:format("Packet:~p~nType:~p~n", [Packet, Type]),
  RoleID = player:get_role_id(),
  List = case Type of
           1 ->
             get_train_list();
           2 ->
             case cache_with_expire:get('train_match:refreshTimes', RoleID) of
               [] ->
                 cache_with_expire:set('train_match:refreshTimes', RoleID, 1, day),
                 rand_train_list();
               [{_, RefreshTimes}] ->
                 NeedEmoney = get_buy_refresh_train_list_need_emoney(RefreshTimes),%%config:get(refresh_train_list_need_emoney),
                 case player_role:check_emoney_enough(NeedEmoney) of
                   true ->
                     cache_with_expire:set('train_match:refreshTimes', RoleID, RefreshTimes + 1, day),
                     player_role:reduce_emoney(?st_train_refresh_list, NeedEmoney),
                     rand_train_list();
                   false ->
                     sys_msg:send_to_self(?sg_train_match_refresh_not_enough_emoney, []),
                     get_train_list()
                 end
             end
         end,
  packet:send(#notify_train_match_list{match_list = [X || {X, _} <- List]}),
  ok.











%%--------------------------------------------------------------------
%% @doc
%% @spec开始训练赛
%% @end
%%--------------------------------------------------------------------
proc_req_start_train_match(Packet = #req_start_train_match{role_id = RoleId})->
    io_helper:format("Packet:~p~n", [Packet]),
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    case check_train_illegal(RoleId) of
	false ->
	    packet:send(#notify_start_train_match_result{result = ?common_failed});
	TrainInfo ->
	    try 
		Copy = challenge:get_ranking_copy(Role:level()),
		Map = get_ranking_map_info(Copy, TrainInfo),
		{_, IsRobot} = TrainInfo,
		GameId = uuid:gen(),
		set_cur_train_info({GameId,RoleId, IsRobot}, Map),
		packet:send(#notify_start_train_match_result{map=[Map],result=?common_success,game_id=GameId}),
		increase_train_times()
	    catch
		_:_ ->
		    packet:send(#notify_start_train_match_result{result=?common_failed}),
		    sys_msg:send_to_self(?sg_train_match_against_leverr, [])
	    end
    end.
	   

    


%%--------------------------------------------------------------------
%% @doc
%% @spec训练赛结算
%% @end
%%--------------------------------------------------------------------
proc_req_train_match_settle(Packet = #req_train_match_settle{game_id = GameId, result = Result})->
    io_helper:format("Packet:~p~n", [Packet]),
    event_router:send_event_msg(#event_train_match{result = Result}),
    case check_if_legal(GameId,Result) of
	{true,{{_, EnemyId, IsRobot}, MapInfo}} ->
	    {Points, Honours} = settle_train(GameId, Result, EnemyId, IsRobot, MapInfo),
	    packet:send(#notify_train_match_settle{result=Result, point=Points, honour=Honours}),
	    clear_cur_train_info(),
	    log:create(business_log, [player:get_role_id(), 0, ?bs_training_match, ?PVP, erlang:localtime(), erlang:localtime(), 0]),
	    activeness_task:update_activeness_task_status(train_match),
	    ok;
	Result1 ->
	    packet:send(#notify_train_match_settle{result=Result1})
    end,
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec获取训练赛相关信息
%% @end
%%--------------------------------------------------------------------
proc_req_get_train_match_times_info(Packet)->
    io_helper:format("Packet:~p~n", [Packet]),
    BuyTimes = get_buy_times(),
    PlayTimes = get_train_times(),
    OrgTimes = config:get(max_train_times) + vip:get_privilege_count(2),
    SuccessTimes = get_train_success_times(),
    FreshTimes = get_fresh_times(),
    packet:send(#notify_train_match_times_info{buy_times = BuyTimes, org_times = OrgTimes, play_times = PlayTimes, 
					       success_times = SuccessTimes, award_status = make_status_int(get_award_info()), refresh_times = FreshTimes}).

%%--------------------------------------------------------------------
%% @doc
%% @spec购买训练赛挑战次数
%% @end
%%--------------------------------------------------------------------
proc_req_buy_train_match_times(Packet)->
    io_helper:format("Packet:~p~n", [Packet]),
    BuyTimes = get_buy_times(),
    case check_buy_train_times_enable(BuyTimes) of
	true ->
	    Cost = get_buy_train_times_need_emoney(BuyTimes),%%trunc(math:pow(2,(BuyTimes+1))),
	    case player_role:check_emoney_enough(Cost) of
		true ->
		    player_role:reduce_emoney(?st_buy_train_times,Cost),
		    increase_buy_times(),
		    packet:send(#notify_buy_train_match_times_result{result=?common_success});
		false ->
		    sys_msg:send_to_self(?sg_train_match_buy_times_not_enough_emoney, []),
		    packet:send(#notify_buy_train_match_times_result{result=?common_failed})
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_train_match_buy_times_exceeded, []),
	    packet:send(#notify_buy_train_match_times_result{result=?common_failed})
    end.




    

%%--------------------------------------------------------------------
%% @doc
%% @spec获取训练赛奖励
%% @end
%%--------------------------------------------------------------------
proc_req_get_train_award(Packet = #req_get_train_award{type = Type})->
    io_helper:format("Packet:~p~n", [Packet]),
    NeedSuccess = case Type of
		      1 ->
			  1;
		      2 ->
			  2;
		      3 ->
			  4;
		      4 ->
			  6
		  end,
    SuccessTimes = get_train_success_times(),
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    case NeedSuccess =< SuccessTimes of
	true ->
	    Status = get_award_info(),
	    case lists:nth(Type, Status) of
		0 ->
		    AwardId = get_award_by_lev_and_type(Role:level(), Type),
		    {AwardItemId, Amount} = rand_award_by_award_id(AwardId),
		    NewStatus = lists:reverse(element(1,lists:foldl(fun(X, {New, Index}) -> 
						    case Index =:= Type of
							true ->
							    {[1|New], Index + 1};
							false ->
							    {[X|New], Index + 1}
						    end
					    end, {[], 1}, Status))),
		    update_award_info(NewStatus),
		 
		    reward:give([AwardItemId], [Amount], ?st_train_match_award),
		    packet:send(#notify_get_train_award_type{result = ?common_success, award_id = AwardItemId, amount = Amount, 
							     new_status = make_status_int(NewStatus)});
		1 ->
		    packet:send(#notify_get_train_award_type{result = ?common_failed}),
		    sys_msg:send_to_self(?sg_train_match_award_has_get, [])
	    end;
	false ->
	    packet:send(#notify_get_train_award_type{result = ?common_failed}),
	    sys_msg:send_to_self(?sg_train_match_award_times_not_enough, [])
    end,
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec更新排名
%% @end
%%--------------------------------------------------------------------

update_rank(RankType, RoleId, Value)->
    case RankType of
	battle_power_rank ->
	    redis_extend:update_rank_by_bucket('train_match:role_battle_power_bucket', RoleId, Value div 100);
	    %%update_battle_power_rank(RankType, RoleId, Value);
	role_lev_rank ->
	    redis_extend:update_rank_by_bucket('train_match:role_lev_bucket', RoleId, Value)
	    %%update_lev_rank(RankType, RoleId, Value)
    end.





%%%===================================================================
%%% Internal functions
%%%===================================================================


%%训练结算
settle_train(_GameId, Result, EnemyId, IsRobot, _MapInfo)->
    {Points,Honours} = get_train_award(Result),
    case Result of
	?game_win ->
	    TrainInfos = get_train_list(),
	    NewTrainInfos = lists:reverse(lists:foldl(fun(X, In) ->
							    {#train_info{role_id = RoleId}=Enemy, _} = X,
							      case RoleId of
								  EnemyId ->
								      [{Enemy#train_info{status = 1}, IsRobot}|In];
								  _ ->
								      [X|In]
							      end
						      end, [], TrainInfos)),
	    case lists:filter(fun({#train_info{status = Status}, _}) ->
				      Status =:= 0
			      end, NewTrainInfos) of
		[] ->
		    FinalInfos = rand_train_list(NewTrainInfos),
		    packet:send(#notify_train_match_list{match_list = [X || {X, _} <-FinalInfos]});
		_ ->
		    set_train_list_info(NewTrainInfos)  
	    end,
	    increase_train_success_times(),
	    ok;
	_ ->
	    ok
    end,
    player_role:add_point(?st_train_match_settle, Points),
    %%military_rank:add_honour(?st_train_match_settle, Honours),
    %%log:create(challenge_log, [GameId, player:get_role_id(), EnemyId, IsRobot, 0, Result, Points,Honours]),
    {Points, Honours}.

%%根据比赛结果获取奖励
get_train_award(Result)->
    case Result of
	?game_win ->
	    {config:get(train_success_points), 0};
	    %%{Award#challenge_award_tplt.success_points,Award#challenge_award_tplt.success_honours};
	?game_lost ->
	    {config:get(train_failed_points), 0}
	    %%{Award#challenge_award_tplt.failed_points,Award#challenge_award_tplt.failed_honours}
    end.

%%判断是否合法
check_if_legal(GameId,_Result)->
    case get_cur_train_info() of
	[] ->
	    sys_msg:send_to_self(?sg_train_match_settle_not_info,[]),
	    ?game_error;
	{{GameId,EnemyId,IsRobot}, Info} ->
	    {true,{{GameId,EnemyId,IsRobot}, Info}};
	_ ->
	    sys_msg:send_to_self(?sg_train_match_settle_info_error,[]),
	    clear_cur_train_info(),
	    ?game_error
    end.

%%生成地图信息
get_ranking_map_info(CopyInfo, TrainInfo)->	
    {#train_info{role_id = RoleId, level = Lev, type = Type, name = Name}, IsRobot} = TrainInfo,
    Mostters = challenge:get_monsters(CopyInfo),
    [Scene] = rand:rand_members_from_list(CopyInfo#ranking_copy_tplt.scene,1),
    Traps = challenge:get_traps(CopyInfo),
    Friends = challenge:get_friends(CopyInfo),
    Awards = challenge:get_awards(CopyInfo),
    case IsRobot of
	0 ->
	    EnemyBattleInfo = roleinfo_manager:get_roleinfo(RoleId),
	    game_copy:create_ranking_copy(Mostters,Traps,Friends,Awards,Scene,CopyInfo#ranking_copy_tplt.barrier_amount,
					  [#senemy{type=EnemyBattleInfo#role_info_detail.type,
                                                    name = EnemyBattleInfo#role_info_detail.nickname,
						  level = EnemyBattleInfo#role_info_detail.level,
						  battle_prop=friend:make_battle_info(EnemyBattleInfo#role_info_detail.battle_prop),
                                                  potence_level = EnemyBattleInfo#role_info_detail.potence_level, 
                                                  advanced_level = EnemyBattleInfo#role_info_detail.advanced_level,
                                                  talent_list  = talent:get_talent_record_list_by_role_id(RoleId),
                                                  team_tag = 1,
							mitigation = EnemyBattleInfo#role_info_detail.mitigation}]);
	1 ->
	    game_copy:create_ranking_copy(Mostters,Traps,Friends,Awards,Scene,CopyInfo#ranking_copy_tplt.barrier_amount,
					  [#senemy{type=Type,
                                                   name = Name,
						  level = Lev,
						  battle_prop=gen_robot_attr(Lev, Type),
						  potence_level = 100, advanced_level = 1,
                                          team_tag = 1}])
    end.


    

%%判断训练是否合法
check_train_illegal(RoleId) ->
    NeedPassCopyID = game_copy:get_func_unlock_need_copy_id(19),
    case game_copy:check_copy_has_passed(NeedPassCopyID) of
	true ->
	    TrainList = get_train_list(),
	    case lists:filter(fun({#train_info{role_id = Id}, _}) ->
		Id =:= RoleId
			      end, TrainList) of
		[] ->
		    sys_msg:send_to_self(?sg_train_match_against_enemy_not_exist, []),
		    false;
		[RoleInfo] ->
		    {#train_info{status = Status}, _} = RoleInfo,
		    case Status =:= 0 of
			true ->
			    case check_times_exceeded() of
				true ->
				    sys_msg:send_to_self(?sg_train_match_times_exceeded, []),
				    false;
				_ ->
				    RoleInfo
			    end;
			false ->
			    sys_msg:send_to_self(?sg_train_match_has_train, []),
			    false
		    end
	    end;
	false ->
	    sys_msg:send_to_self(?sg_game_copy_not_pass, []),
	    false
    end.

%%判断次数是否用完
check_times_exceeded()->
    get_my_max_traintimes() =< get_train_times().

%%--------------------------------------------------------------------
%% @doc
%% @保存获取清空比赛信息
%% @end
%%--------------------------------------------------------------------
set_cur_train_info(ExtraInfo, Info)->
    cache:set('train_match:map_information',player:get_role_id(),{ExtraInfo, Info}).

get_cur_train_info()->
    case cache:get('train_match:map_information',player:get_role_id()) of
	[Result] ->
	    element(2,Result);
	Other ->
	    Other  
    end.

clear_cur_train_info()->
    cache:delete('train_match:map_information',player:get_role_id()).


%%--------------------------------------------------------------------
%% @doc
%% @保存获取更新奖励领取情况
%% @end
%%--------------------------------------------------------------------
update_award_info(NewStatus)->
    cache_with_expire:set('train_match:award_status', player:get_role_id(), NewStatus, day).

get_award_info()->
    case cache:get('train_match:award_status',player:get_role_id()) of
	[Result] ->
	    element(2,Result);
	_ ->
	    [0,0,0,0]  
    end.

make_status_int(Status)->
    List = [integer_to_list(X) || X <- [1|Status]],
    list_to_integer(lists:concat(List)).

%%--------------------------------------------------------------------
%% @doc
%% @spec通过等级随机角色
%% @end
%%--------------------------------------------------------------------


rand_role_by_lev(Lev, Amount)->
    Levels = get_enable_lev_list(Lev),
    Amounts = redis_extend:mget_bucket_card('train_match:role_lev_bucket', Levels),
    RandTuple = make_rand_tuple(Levels, Amounts),
    %%io:format("~p~n", [RandTuple]),
    MaxNumber = lists:foldl(fun(X, In) -> X + In end, 0, Amounts),
    RandList = lists:foldl(fun(X, In) ->
				   case lists:keyfind(X, 1, In) of
				       false ->
					   [{X, 1}|In];
				       Tuple ->
					   lists:keyreplace(X, 1, In, {X, element(2, Tuple) + 1})
				   end
			   end, [], get_rand_result(Amount, RandTuple, MaxNumber)),
    %%io:format("~p~n",[RandList]),
    redis_extend:mrand_bucket_member('train_match:role_lev_bucket', RandList).


%%--------------------------------------------------------------------
%% @doc
%% @spec通过战斗力随机角色
%% @end
%%--------------------------------------------------------------------
rand_role_by_battle_power(Power, Amount)->
    Ranges = get_enable_battle_power_range_list(Power),
    Amounts = redis_extend:mget_bucket_card('train_match:role_battle_power_bucket', Ranges),
    RandTuple = make_rand_tuple(Ranges, Amounts),
    %%io:format("~p~n", [RandTuple]),
    MaxNumber = lists:foldl(fun(X, In) -> X + In end, 0, Amounts),
    RandList = lists:foldl(fun(X, In) ->
				   case lists:keyfind(X, 1, In) of
				       false ->
					   [{X, 1}|In];
				       Tuple ->
					   lists:keyreplace(X, 1, In, {X, element(2, Tuple) + 1})
				   end
			   end, [], get_rand_result(Amount, RandTuple, MaxNumber)),
    %%io:format("~p~n",[RandList]),
    redis_extend:mrand_bucket_member('train_match:role_battle_power_bucket', RandList).
%%生成随机的元组列表
make_rand_tuple([], []) ->
    [];
make_rand_tuple([Lev|Levs], [Amount|Amounts]) ->
    case Amount of
	0 ->
	    make_rand_tuple(Levs, Amounts);
	_ ->
	    [{Lev, Amount}|make_rand_tuple(Levs, Amounts)]
    end.





get_enable_lev_list(Lev) ->
	lists:filter(
		fun(E) ->
			E =< config:get(player_max_lev)
		end,
		[Lev - 3, Lev - 2, Lev - 1, Lev, Lev + 1, Lev + 2, Lev + 3]).

get_enable_battle_power_range_list(BattlePower)->
    Length = 100,
    Base = trunc(BattlePower / Length),
    [{(Base-1)*Length, Base*Length},{Base*Length, (Base+1)*Length},{(Base+1)*Length, (Base+2)*Length}].


get_rand_result(Amountd, RandTuple, MaxNumber)->
    case Amountd of
	0 ->
	    [];
	_ ->
	    case MaxNumber of
	        0 ->
		    [];
		_ ->
		    RandRes = rand:uniform(MaxNumber),
		    {{TLeft, Result}, _} = lists:foldl(fun({Value, Amount}, {{TuplesLeft,Res}, Left}) ->
							       case Left =<0 of
								   true ->
								       {{[{Value, Amount}|TuplesLeft], Res}, Left};
								   false ->
								       case Amount >=Left of
									   true ->
									       case Amount > 1 of
										   true ->
										       {{[{Value, Amount -1}|TuplesLeft], Value}, Left - Amount};
										   false ->
										       {{TuplesLeft, Value}, Left - Amount}
									       end;
									   false ->
									       {{[{Value, Amount}|TuplesLeft], Res}, Left - Amount}
								       end
							       end
						       end, {{[],0}, RandRes}, RandTuple),
		    [Result|get_rand_result(Amountd - 1, TLeft, MaxNumber - 1)]
	    end
    end.


%%把提取的数据转换成rank_info
make_train_info(RoleBattleInfo)->
    {Id ,Data}=RoleBattleInfo,
    %%io:format("Id:~p~n", [Id]),
    case roleinfo_manager:upgrade_data(Id, Data) of
	undefined ->
	    undefined;
	DD ->
	    #train_info{role_id=Id,name=DD#role_info_detail.nickname,type=DD#role_info_detail.type,status = 0,
		       level=DD#role_info_detail.level,power=DD#role_info_detail.battle_prop#role_attr_detail.battle_power,
			   potence_level = DD#role_info_detail.potence_level, advanced_level = DD#role_info_detail.advanced_level}
    end.

%%今天的最高次数
get_my_max_traintimes()->
    OrgMax = config:get(max_train_times) + vip:get_privilege_count(2),
    BuyTimes = get_buy_times(),
    OrgMax + BuyTimes.


%%获得今天已购买次数
get_buy_times()->
    Times=case cache_with_expire:get('train_match:buy_times',player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.


%%获得今天挑战次数
get_train_times()->
    Times=case cache_with_expire:get('train_match:train_times',player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

%%获得今天刷新次数
get_fresh_times() ->
  case cache_with_expire:get('train_match:refreshTimes', player:get_role_id()) of
    [] ->
      0;
    [{_, RefreshTimes}] ->
      RefreshTimes
  end.

%%获得今天成功次数
get_train_success_times() ->
    Times=case cache_with_expire:get('train_match:train_success_times',player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

%%递增已购买次数
increase_buy_times()->
    cache_with_expire:increase('train_match:buy_times',player:get_role_id(),day).


%%递增今天的训练次数    
increase_train_times()->
    cache_with_expire:increase('train_match:train_times',player:get_role_id(),day).

%%递增今天的训练成功次数    
increase_train_success_times()->
    cache_with_expire:increase('train_match:train_success_times',player:get_role_id(),day).


%%获取训练赛名单
get_train_list()->
    Tlist = case redis:hget('train_match:my_train_list', player:get_role_id()) of
		undefined ->
		    rand_train_list(undefined);
		List ->
		    List
	    end,
    Tlist.
    %%[X || {X, _} <- Tlist].


%%保存训练赛名单
set_train_list_info(List) ->
  cache_with_expire:set('train_match:my_train_list',player:get_role_id(), List, day).
%%redis:hset('train_match:my_train_list', player:get_role_id(), List).


%%随机训练赛名单
rand_train_list() ->
    rand_train_list(redis:hget('train_match:my_train_list', player:get_role_id())).

rand_train_list(OrgData)->
    OrgIds = case OrgData of
		 undefined ->
		     [];
		 _ ->
		     [RoleId||{#train_info{role_id = RoleId}, _} <- OrgData]
	     end,
    LevAmount = config:get(train_match_by_lev_amount),
    PowerAmount = config:get(train_match_by_battle_power),
    Role = player_role:get_role_info_by_roleid(player:get_role_id()),
    LevIds = lists:filter(fun(X) ->
				  X > 0
			  end, rand_role_by_lev(Role:level(), LevAmount)),
    PowerIds = rand_role_by_battle_power(friend:get_battle_power(), PowerAmount),
    RoleIds = ((LevIds -- PowerIds) ++ PowerIds) -- [player:get_role_id()|OrgIds],
    RoleInfos  = case length(RoleIds) of
		0 ->
		    [];
		_ ->
		    redis:hmget(role_info_detail, RoleIds)
	    end,
    NewList = lists:filter(fun(X) -> X=/=undefined end, 
			   lists:map(fun(X) -> 
					     make_train_info(X)
				     end,RoleInfos)),
    FinalList = add_robot([{X, 0} || X<-NewList], lists:filter(fun(X)-> X >0 end, get_enable_lev_list(Role:level()))),
    set_train_list_info(FinalList),
    FinalList.

%%加入机器人
add_robot(NewList, LevIds)->
    %%io:format("LevIds:~p~n", [LevIds]),
    case length(NewList)<6 of
	true ->
	    NewList ++ gen_robot_infos(6 - length(NewList), LevIds);
	false ->
	    NewList
    end.



%%根据机器人的等级和类型生成属性，战斗时使用
gen_robot_attr(Lev, Type)->
    #battle_info{life = gen_robot_life(Lev), 
		 speed = gen_robot_speed(Lev),
		 atk = gen_robot_atk(Lev),
		 hit_ratio = gen_robot_hit(Lev),
		 miss_ratio = gen_robot_miss(Lev),
		 critical_ratio = gen_robot_critical(Lev),
		 tenacity = gen_robot_tenacity(Lev),
		 sculpture = gen_robot_skill(Lev, Type),
    power = get_robot_battle_power(Lev)}.

gen_robot_life(Lev)->
    Fun = (tplt:get_data(expression_tplt, 6))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_speed(Lev)->
    Fun = (tplt:get_data(expression_tplt, 7))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_atk(Lev)->
    Fun = (tplt:get_data(expression_tplt, 8))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_hit(Lev)->
    Fun = (tplt:get_data(expression_tplt, 9))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_miss(Lev)->
    Fun = (tplt:get_data(expression_tplt, 10))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_critical(Lev)->
    Fun = (tplt:get_data(expression_tplt, 11))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_tenacity(Lev)->
    Fun = (tplt:get_data(expression_tplt, 12))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).
gen_robot_skill(Lev, Type) ->
    #role_exp_tplt{group_id = GroupId} = tplt:get_data(role_exp_tplt, Lev),
    Id = Type * 1000 + GroupId,
    #robot_skill_tplt{skills = SkillTuples} = tplt:get_data(robot_skill_tplt, Id),
    [#sculpture_data{temp_id = SkillId, level = SkillLevel}|| {SkillId, SkillLevel} <- SkillTuples].
    %% case Type of
    %% 	1 ->
    %% 	    [#sculpture_data{temp_id = 44100, level = Lev rem 10},#sculpture_data{temp_id = 45100, level = Lev rem 10}];
    %% 	2 ->
    %% 	    [#sculpture_data{temp_id = 78100, level = Lev rem 10},#sculpture_data{temp_id = 79100, level = Lev rem 10}];
    %% 	3 ->
    %% 	    [#sculpture_data{temp_id = 61100, level = Lev rem 10},#sculpture_data{temp_id = 62100, level = Lev rem 10}];
    %% 	4 ->
    %% 	    [#sculpture_data{temp_id = 37100, level = Lev rem 10},#sculpture_data{temp_id = 22100, level = Lev rem 10}]
    %% end.

%%生成机器人填充没有玩家的地方
gen_robot_infos(0, _)->
    [];
gen_robot_infos(Amount, LevIds) ->
    [Lev] = rand:rand_members_from_list(LevIds, 1),
    [gen_robot_info(Lev)|gen_robot_infos(Amount - 1, LevIds)].

gen_robot_info(Lev) ->
	NickName = rand_nickname:rand_nickname(),
	{#train_info{role_id = uuid:gen(), level = Lev, power = get_robot_battle_power(Lev), type = rand:uniform(4), name = NickName,
				 potence_level = 100, advanced_level = 1, status = 0}, 1}.

get_robot_battle_power(Lev) ->
    Fun = (tplt:get_data(expression_tplt, 30))#expression_tplt.expression,
    Fun([{'Lev', Lev}]).

%%模板表相关操作

rand_award_by_award_id(AwardId) ->
    Award = tplt:get_data(train_match_award, AwardId),
    Total = lists:sum(Award#train_match_award.radios),
    Res = rand:uniform(Total),
    get_award_item(Award#train_match_award.awards, Award#train_match_award.radios, Award#train_match_award.amounts, Res).

get_award_item([Award|Awards], [Radio|Radios], [Amount|Amounts], Left)->
    case Radio >= Left of
	true ->
	    {Award, Amount};
	false ->
	    get_award_item(Awards, Radios, Amounts, Left - Radio)
    end.

get_award_by_lev_and_type(Lev, Type) ->
    AwardGroup = get_award_group_by_lev(Lev),
    case Type of
	1 ->
	    AwardGroup#train_match_award_group.blue_award;
	2 ->
	    AwardGroup#train_match_award_group.purple_award;
	3 ->
	    AwardGroup#train_match_award_group.orange_award;
	4 ->
	    AwardGroup#train_match_award_group.red_award
    end.


get_award_group_by_lev(Lev)->
    AllGroup = tplt:get_all_data(train_match_award_group),
    [Group] = lists:filter(fun(X) -> 
			 (X#train_match_award_group.min_lev =< Lev) and (X#train_match_award_group.max_lev >= Lev)
		 end, AllGroup),
    Group.


get_buy_train_times_need_emoney(Times) ->
    Fun = (tplt:get_data(expression_tplt, 17))#expression_tplt.expression,
    Fun([{'Times', Times}]).

check_buy_train_times_enable(Times) ->
    Times < config:get(train_max_buy_times).

get_buy_refresh_train_list_need_emoney(Times) ->
    Fun = (tplt:get_data(expression_tplt, 18))#expression_tplt.expression,
    Fun([{'Times', Times}]).








%% update_lev_rank(RankType, RoleId, NewLev) ->
%%     OrgBucket = get_my_lev_rank_bucket(RoleId),
%%     NewBucket = get_new_lev_bucket(NewLev),
%%     case OrgBucket =:= NewBucket  of
%% 	true ->
%% 	    ok;
%% 	_ ->
%% 	    ok%%set_my_lev_rank_bucket(NewBucket)
	    
%%     end,
%%     ok.


%% update_battle_power_rank(RankType, RoleId, NewBattlePower) ->
%%     ok.




%% get_new_lev_bucket(CurLev) ->
%%     CurLev.

%% get_my_lev_rank_bucket(RoleId) ->
%%     case redis:hget('training_match:lev_bucket', RoleId) of
%% 	undefined ->
%% 	    0;
%% 	Bucket ->
%% 	    Bucket
%%     end.

%% set_my_lev_rank_bucket(RoleId, NewValue) ->
%%     redis:hset('training_match:lev_bucket', RoleId, NewValue).



%%[battle_power_rank, role_lev_rank]
