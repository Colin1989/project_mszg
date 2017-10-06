
-module(challenge).
-include("tplt_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").
-include("event_def.hrl").

-export([start/0, restore_challenge_info/0, get_max_award_ranking/0]).

-export([get_challenge_award/2,get_ranking_award/1,get_ranking_copy/1,get_ranking_map_info/2,get_player_rank/1,get_be_challenge_amount/0]).

-export([proc_req_challenge_other_player/1,proc_req_challenge_settle/1,proc_req_get_challenge_rank/1,proc_req_get_be_challenged_info/1,
         proc_req_get_can_challenge_role/1,proc_req_buy_challenge_times/1,proc_req_get_challenge_times_info/1,proc_req_get_challenge_rank_award/1]).


-compile(export_all).
start()->
    packet:register(?msg_req_challenge_other_player,{?MODULE,proc_req_challenge_other_player}),
    packet:register(?msg_req_challenge_settle,{?MODULE,proc_req_challenge_settle}),
    packet:register(?msg_req_get_be_challenged_info,{?MODULE,proc_req_get_be_challenged_info}),
    packet:register(?msg_req_get_challenge_rank,{?MODULE,proc_req_get_challenge_rank}),
    packet:register(?msg_req_get_can_challenge_role,{?MODULE,proc_req_get_can_challenge_role}),
    packet:register(?msg_req_buy_challenge_times,{?MODULE,proc_req_buy_challenge_times}),
    packet:register(?msg_req_get_challenge_times_info,{?MODULE,proc_req_get_challenge_times_info}),
    packet:register(?msg_req_get_challenge_rank_award, {?MODULE, proc_req_get_challenge_rank_award}),
    ok.

restore_challenge_info()->
    %%io:format("restore_rank_info~n"),
    %%MaxRanking = get_max_award_ranking(),

    ok.

proc_req_get_challenge_rank_award(#req_get_challenge_rank_award{}=Pack)->
    io_helper:format("~p~n", [Pack]),
    TimeLeft = get_rank_award_timeleft(),
    MyRank = get_role_challenge_rank(player:get_role_id()),
    case TimeLeft of
	0 ->
	    case check_if_i_can_get_rank_award(MyRank) of
		true ->
		    do_get_ranking_award(MyRank),
		    packet:send(#notify_get_challenge_rank_award_result{result = ?common_success});
		false ->
		    sys_msg:send_to_self(?sg_challenge_rank_award_not_in_rank, []),
		    packet:send(#notify_get_challenge_rank_award_result{result = ?common_error})
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_challenge_rank_award_in_cd, []),
	    packet:send(#notify_get_challenge_rank_award_result{result = ?common_error})
    end.

check_if_i_can_get_rank_award(Rank)->
    Rank =< config:get(ranking_awared_rank_limit).

do_get_ranking_award(MyRank)->
    {RewardIDs, RewardAmounts} = get_ranking_award(MyRank),
    reward:give(RewardIDs, RewardAmounts, ?st_get_rank_award),
    cache:set(rank_award_get_time, player:get_role_id(), erlang:localtime()).



get_role_challenge_rank(RoleId)->
    redis_extend:get_hrank(challenge_rank, RoleId).


get_rank_award_timeleft()->
    TimeLeft = case cache:get(rank_award_get_time, player:get_role_id()) of
		   [] ->
		       0;
		   [{_, Time}] ->
		       Now = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
		       LastGet = datetime:datetime_to_gregorian_seconds(Time),
		       Cd = config:get(ranking_award_cd),
		       Left = Cd - (Now - LastGet),
		       case Left < 0 of
			   true ->
			       0;
			   false ->
			       Left
		       end
	       end,
    TimeLeft.


proc_req_challenge_other_player(#req_challenge_other_player{role_id=RoleId}=Pack)->
    io_helper:format("~p~n",[Pack]),
    MyId = player:get_role_id(),
    RankInfo = get_rank_info(),
    NeedPassCopyID = game_copy:get_func_unlock_need_copy_id(24),
    case game_copy:check_copy_has_passed(NeedPassCopyID) of
	true ->
	    case lists:filter(fun(X)-> X#rank_info.role_id=:=RoleId end,RankInfo) of
		[] ->
		    packet:send(#notify_challenge_other_player_result{result=?common_error}),
		    sys_msg:send_to_self(?sg_challenge_enemy_noexist,[]),
		    error;
		[ChallengeObj] ->
		    case lists:filter(fun(X)-> X#rank_info.role_id=:= MyId end,RankInfo) of
			[] ->
			    packet:send(#notify_challenge_other_player_result{result=?common_error}),
			    sys_msg:send_to_self(?sg_challenge_noreq_list,[]),
			    error;
			[MyInfo] ->
			    case check_times_exceeded() of
				true ->
				    packet:send(#notify_challenge_other_player_result{result=?common_failed}),
				    sys_msg:send_to_self(?sg_challenge_times_use_up,[]);
				false ->
				    case RoleId=:=MyId of
					true ->
					    packet:send(#notify_challenge_other_player_result{result=?common_failed}),
					    sys_msg:send_to_self(?sg_challenge_self,[]);
                                        false->
                                            try
                                                Copy = get_ranking_copy(MyInfo#rank_info.level),
                                                Map = get_ranking_map_info(Copy, RoleId),
                                                GameId = uuid:gen(),
                                                set_cur_challenge_info({GameId,RoleId,ChallengeObj#rank_info.rank,MyId,MyInfo#rank_info.rank}, Map),
                                                packet:send(#notify_challenge_other_player_result{map=[Map],result=?common_success,game_id=GameId}),
                                                increase_challenge_times()
                                            catch
                                                _:_ ->
                                                    packet:send(#notify_challenge_other_player_result{result=?common_failed}),
                                                    sys_msg:send_to_self(?sg_challenge_level_err,[])
                                            end
                                    end
                            end


                    end
            end;
        false ->
            packet:send(#notify_challenge_other_player_result{result=?common_failed}),
            sys_msg:send_to_self(?sg_game_copy_not_pass,[])
    end,
    ok.

proc_req_challenge_settle(#req_challenge_settle{game_id=GameId, result=Result}=Pack)->
    io_helper:format("~p~n",[Pack]),
    event_router:send_event_msg(#event_challenge{result = Result}),
    case check_if_legal(GameId,Result) of
	{true,{{_,EnemyId,EnemyRank,MyId,MyRank}, MapInfo}} ->
	    {Points, Coins} = settle_challenge(GameId,Result,EnemyId,EnemyRank,MyId,MyRank,MapInfo),
            activeness_task:update_activeness_task_status(challenge),
	    packet:send(#notify_challenge_settle{result=Result, point=Points, coins=Coins}),
	    clear_cur_challenge_info(),
	    ok;
	Result1 ->
	    packet:send(#notify_challenge_settle{result=Result1})
    end,
    ok.


proc_req_get_be_challenged_info(#req_get_be_challenged_info{}=Pack)->
    io_helper:format("~p~n",[Pack]),
    Infos = get_be_challenge_msg(),
    case Infos of
	[] ->
	    ok;
	_ ->
	    packet:send(#notify_challenge_info_list{infos=Infos})
    end,
    ok.

proc_req_get_challenge_rank(#req_get_challenge_rank{}=Pack)->
    io_helper:format("~p~n",[Pack]),
    ok.

proc_req_get_can_challenge_role(#req_get_can_challenge_role{}=Pack)->
    io_helper:format("~p~n",[Pack]),
    AboveList = redis_extend:get_hrank_info_above(challenge_rank, role_info_detail, player:get_role_id(), 6),
    NewList = lists:map(fun(X) -> 
				make_rank_info(X)
			end,AboveList),
    FinalList = lists:filter(fun(X) -> X=/=undefined end,NewList),
    set_rank_info(FinalList),
    packet:send(#notify_can_challenge_lists{infos=FinalList}),
    ok.

make_rank_info(RoleBattleInfo)->
    {Rank,{Id,Data}}=RoleBattleInfo,
    case roleinfo_manager:upgrade_data(Id, Data) of
	undefined ->
	    undefined;
	Info ->
	    #rank_info{role_id=Id,name=Info#role_info_detail.nickname,type=Info#role_info_detail.type,rank=Rank,
                       level=Info#role_info_detail.level,power=Info#role_info_detail.battle_prop#role_attr_detail.battle_power,
                       potence_level = Info#role_info_detail.potence_level, advanced_level = Info#role_info_detail.advanced_level}
    end.


%% case Data of 
%% 	DD when (not is_record(DD,friend_data) orelse (not is_record(DD#friend_data.battle_prop,battle_info))) ->
%% 			       Info=friend:make_friend_data(Id),
%% 			       case Info of
%% 				   undefined ->
%% 				       undefined;
%% 				   _ ->
%% 				       #rank_info{role_id=Id,name=Info#friend_data.nickname,type=Info#friend_data.head,rank=Rank,
%% 						  level=Info#friend_data.level,power=Info#friend_data.battle_prop#battle_info.power}
%% 			       end;
%% 	_ ->
%% 	    #rank_info{role_id=Id,name=Data#friend_data.nickname,type=Data#friend_data.head,rank=Rank,
%% 			       level=Data#friend_data.level,power=Data#friend_data.battle_prop#battle_info.power}
%% end.
proc_req_buy_challenge_times(#req_buy_challenge_times{}=Pack)->
    io_helper:format("~p~n",[Pack]),
    BuyTimes = get_buy_times(),
    case check_buy_challenge_times_enable(BuyTimes) of
	true ->
	    Cost = get_buy_challenge_times_need_emoney(BuyTimes),%%trunc(math:pow(2,(BuyTimes+1))),
	    case player_role:check_emoney_enough(Cost) of
		true ->
		    player_role:reduce_emoney(?st_buy_challenge_times,Cost),
		    increase_buy_times(),
		    packet:send(#notify_buy_challenge_times_result{result=?common_success});
		false ->
		    sys_msg:send_to_self(?sg_challenge_buy_times_not_enough_emoney, []),
		    packet:send(#notify_buy_challenge_times_result{result=?common_failed})
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_challenge_buy_times_exceeded, []),
	    packet:send(#notify_buy_challenge_times_result{result=?common_failed})
    end.



proc_req_get_challenge_times_info(#req_get_challenge_times_info{}=Pack)->
    io_helper:format("~p~n",[Pack]),
    BuyTimes = get_buy_times(),
    PlayTimes = get_challenge_times(),
    OrgTimes = config:get(max_challenge_times) + vip:get_privilege_count(4),
    packet:send(#notify_challenge_times_info{buy_times = BuyTimes, org_times = OrgTimes, play_times = PlayTimes, 
					     award_timeleft = get_rank_award_timeleft()}).


notify_enemy_be_challenge(Result,EnemyId,NewRank)->
    %% RankInfo = get_rank_info(),
    %% [MyInfo] = lists:filter(fun(X)-> X#rank_info.role_id=:= player:get_role_id() end,RankInfo),
    %% Name = MyInfo#rank_info.name,
    RoleInfo = player_role:get_db_role(player:get_role_id()),
    NewTimes = add_be_challenge_msg(EnemyId,Result,RoleInfo:nickname(),NewRank),
    case role_pid_mapping:get_pid(EnemyId) of
	undefined -> 
	    ok;
	Pid ->
	    packet:send(Pid,#notify_be_challenged_times{times=NewTimes})
    end.

%%--------------------------------------------------------------------
%% 排位相关处理
%%--------------------------------------------------------------------

get_player_rank(RoleId)->
    case redis:hget(challenge_rank_byobj, RoleId) of
	undefined ->
	    0;
	Rank ->
	    Rank
    end.
%%cache:get(challenge_rank,RoleId).

%%--------------------------------------------------------------------
%% 模板相关
%%--------------------------------------------------------------------



%%--------------------------------------------------------------------
%% @doc
%% @根据排位情况获得挑战的奖励
%% @end
%%--------------------------------------------------------------------
get_challenge_award(_Rank,Result)->
    %% Awards = tplt:get_all_data(challenge_award_tplt),
    %% [Award] = lists:filter(fun(X) ->
    %% 			 [Min,Max] = X#challenge_award_tplt.ranking_range,
    %% 			 (Rank >= Min) and (Rank =< Max)
    %% 		 end,Awards),
    case Result of
	?game_win ->
	    {config:get(challenge_success_points), config:get(challenge_success_coin)};
        %%{Award#challenge_award_tplt.success_points,Award#challenge_award_tplt.success_honours};
	?game_lost ->
	    {config:get(challenge_failed_points), config:get(challenge_failed_coin)}
	    %%{Award#challenge_award_tplt.failed_points,Award#challenge_award_tplt.failed_honours}
    end.


%%--------------------------------------------------------------------
%% @doc
%% @根据排位情况获得排位的奖励
%% @end
%%--------------------------------------------------------------------
get_ranking_award(Rank)->
    RewardID = get_reward_id(101, Rank),
    RewardInfo = get_tplt(RewardID),
    {RewardInfo#challenge_reward_tplt.ids, RewardInfo#challenge_reward_tplt.amounts}.


get_reward_id(CurID, Rank) ->
    RewardInfo = get_tplt(CurID),
    MinReqRank = lists:nth(2, RewardInfo#challenge_reward_tplt.rank_range),
    case Rank > MinReqRank of
        true ->
            get_reward_id(CurID + 1, Rank);
        false ->
            CurID
    end.

%% get_ranking_award(Rank)->
%%     Role = player_role:get_role_info_by_roleid(player:get_role_id()),
%%     Level = Role:level(),
%%     Point = get_ranking_award(Rank, Level),
%%     Point.
%%
%% get_ranking_award(Rank, Level)->
%%      Fun = (tplt:get_data(expression_tplt, 13))#expression_tplt.expression,
%%      Fun([{'Rank', Rank}, {'Level', Level}]).
%%   BasePoint = config:get(ranking_award_basepoing),
%%     Base = config:get(ranking_award_base),
%%     Point = (Level + BasePoint div (Rank + Base)),
%%     Point.
%%     %% Awards = tplt:get_all_data(ranking_award_tplt),
%%     %% [Award] = lists:filter(fun(X) ->
%%     %% 			 [Min,Max] = X#ranking_award_tplt.ranking_range,
%%     %% 			 (Rank >= Min) and (Rank =< Max)
%%     %% 		 end,Awards),
%%     %% Award
%% %%	.


%% get_sale_sculpture_price(Lev, Quality)->
%%     Fun = (tplt:get_data(expression_tplt, 4))#expression_tplt.expression,
%%     Fun([{'Lev', Lev}, {'Quality', Quality}]).





get_max_award_ranking()->
    Awards = tplt:get_all_data(ranking_award_tplt),
    MaxRanking = lists:foldl(fun(X, In) -> 
				     [_, Max] = X#ranking_award_tplt.ranking_range,
				     case Max > In of
					 true ->
					     Max;
					 false ->
					     In
				     end
			     end, 0, Awards),
    MaxRanking.


%%--------------------------------------------------------------------
%% @doc
%% @根据等级情况获取挑战的副本信息
%% @end
%%--------------------------------------------------------------------
get_ranking_copy(Lev)->
    Copys = tplt:get_all_data(ranking_copy_tplt),
    [Copy] = lists:filter(fun(X) ->
                                  [Min,Max] = X#ranking_copy_tplt.lev_range,
                                  (Lev >= Min) and (Lev =< Max)
                          end,Copys),
    Copy.

%%--------------------------------------------------------------------
%% @doc
%% @获取副本内容
%% @end
%%--------------------------------------------------------------------
get_ranking_map_info(CopyInfo, EnemyId)->
    EnemyBattleInfo = roleinfo_manager:get_roleinfo(EnemyId),
    Mostters = get_monsters(CopyInfo),
    [Scene] = rand:rand_members_from_list(CopyInfo#ranking_copy_tplt.scene,1),
    %%Scene = lists:nth(rand:uniform(length(Map#push_tower_map.scene)),Map#push_tower_map.scene),
    Traps = get_traps(CopyInfo),
    Friends = get_friends(CopyInfo),
    Awards = get_awards(CopyInfo),
    game_copy:create_ranking_copy(Mostters,Traps,Friends,Awards,Scene,CopyInfo#ranking_copy_tplt.barrier_amount,
				  [#senemy{type=EnemyBattleInfo#role_info_detail.type,
                                           name = EnemyBattleInfo#role_info_detail.nickname,
                                           level = EnemyBattleInfo#role_info_detail.level,
					  battle_prop=friend:make_battle_info(EnemyBattleInfo#role_info_detail.battle_prop),
					  potence_level = EnemyBattleInfo#role_info_detail.potence_level, 
					  advanced_level = EnemyBattleInfo#role_info_detail.advanced_level,
                                          talent_list  = talent:get_talent_record_list_by_role_id(EnemyId),
                                  team_tag = 1, mitigation = EnemyBattleInfo#role_info_detail.mitigation}]).





%%--------------------------------------------------------------------
%% @doc
%% @获取怪物列表
%% @end
%%--------------------------------------------------------------------
get_monsters(Map)->
    Min = Map#ranking_copy_tplt.monster_min,
    Max = Map#ranking_copy_tplt.monster_max,
    MonsterIds = Map#ranking_copy_tplt.monsters,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(MonsterIds, Count).
%%--------------------------------------------------------------------
%% @doc
%% @获取陷阱列表
%% @end
%%--------------------------------------------------------------------
get_traps(Map)->
    Min = Map#ranking_copy_tplt.trap_min,
    Max = Map#ranking_copy_tplt.trap_max,
    TrapIds = Map#ranking_copy_tplt.traps,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(TrapIds, Count).
%%--------------------------------------------------------------------
%% @doc
%% @获取好友ID列表
%% @end
%%--------------------------------------------------------------------
get_friends(Map)->
    Min = Map#ranking_copy_tplt.friend_min,
    Max = Map#ranking_copy_tplt.friend_max,
    FriendIds = Map#ranking_copy_tplt.friends,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(FriendIds, Count).

%%--------------------------------------------------------------------
%% @doc
%% @获取奖励事件列表
%% @end
%%--------------------------------------------------------------------
get_awards(Map)->
    Min = Map#ranking_copy_tplt.trap_min,
    Max = Map#ranking_copy_tplt.trap_max,
    AwardIds = Map#ranking_copy_tplt.traps,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(AwardIds, Count).


set_rank_info(Info)->
    put(rank_info,Info).

get_rank_info()->
    get(rank_info).



%%--------------------------------------------------------------------
%% @doc
%% @保存获取清空比赛信息
%% @end
%%--------------------------------------------------------------------
set_cur_challenge_info(ExtraInfo, Info)->
    cache:set(map_information,player:get_role_id(),{ExtraInfo, Info}).

get_cur_challenge_info()->
    case cache:get(map_information,player:get_role_id()) of
	[Result] ->
	    element(2,Result);
	Other ->
	    Other  
    end.

clear_cur_challenge_info()->
    cache:delete(map_information,player:get_role_id()).


%%--------------------------------------------------------------------
%% @doc
%% @比赛相关
%% @end
%%--------------------------------------------------------------------


settle_challenge(GameId,Result,EnemyId,EnemyRank,MyId,MyRank,_MapInfo)->
    NewEnemyRank = case Result of
                       ?game_win when EnemyRank < MyRank ->
                           redis_extend:exchange_hrank(challenge_rank, EnemyId, EnemyRank, MyId, MyRank),
                           MyRank;
                       %% Best = get_best_rank(),
                       %% case Best =< EnemyRank of
                       %% 	true ->
                       %% 	    ok;
                       %% 	false ->
                       %% 	    set_best_rank(EnemyRank)
                       %% end;
                       _ ->
                           redis_extend:get_hrank(challenge_rank, EnemyId)
                   end,
    {Points,Coins} = get_challenge_award(MyRank,Result),
    player_role:add_point(?st_challenge_settle, Points),
    %military_rank:add_honour(?st_challenge_settle, Honours),
    reward:give([config:get(challenge_coin_id)], [Coins], ?st_challenge_settle),
    notify_enemy_be_challenge(Result,EnemyId,NewEnemyRank),
    log:create(challenge_log, [GameId, MyId, EnemyId, EnemyRank, MyRank, Result, Points, Coins, datetime:local_time()]),
    {Points, Coins}.


check_if_legal(GameId,_Result)->
    case get_cur_challenge_info() of
	[] ->
	    sys_msg:send_to_self(?sg_challenge_settle_not_info,[]),
	    ?game_error;
	{{GameId,EnemyId,EnemyRank,MyId,MyRank}, Info} ->
	    {true,{{GameId,EnemyId,EnemyRank,MyId,MyRank}, Info}};
	_ ->
	    sys_msg:send_to_self(?sg_challenge_settle_info_err,[]),
	    clear_cur_challenge_info(),
	    ?game_error
    end.




check_times_exceeded()->
    get_my_max_challengetimes() =< get_challenge_times().

get_my_max_challengetimes()->
    OrgMax = config:get(max_challenge_times) + vip:get_privilege_count(4),
    BuyTimes = get_buy_times(),
    OrgMax + BuyTimes.

get_buy_times()->
    Times=case cache_with_expire:get(buy_challenge_times,player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

get_challenge_times()->
    Times=case cache_with_expire:get(challenge_times,player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

increase_buy_times()->
    cache_with_expire:increase(buy_challenge_times,player:get_role_id(),day).

increase_challenge_times()->
    cache_with_expire:increase(challenge_times,player:get_role_id(),day).

add_be_challenge_msg(EnemyId,Result,Name,Rank)->
    redis_extend:insert_msg_and_return_amount(lists:concat(['be_challenge:',EnemyId]),#challenge_info{name=Name,result=Result,new_rank=Rank},10).


get_be_challenge_msg()->
    RoleId = player:get_role_id(),
    redis_extend:get_msg_and_delete(lists:concat(['be_challenge:',RoleId])).

get_be_challenge_amount()->
    RoleId = player:get_role_id(),
    redis:llen(lists:concat(['be_challenge:',RoleId])).

get_buy_challenge_times_need_emoney(Times) ->
    Fun = (tplt:get_data(expression_tplt, 19))#expression_tplt.expression,
    Fun([{'Times', Times}]).

check_buy_challenge_times_enable(Times) ->
    Times < config:get(challenge_max_buy_times).

%% get_best_rank()->
%%     RoleId = player:get_role_id(),
%%     case cache:get(challenge_max_rank,RoleId) of
%% 	[] ->
%% 	    NewRank = get_player_rank(RoleId),
%% 	    cache:set(challenge_max_rank,RoleId,NewRank);
%% 	[{_,Rank}] ->
%% 	    Rank
%%     end.

%% set_best_rank(Rank)->
%%     RoleId = player:get_role_id(),
%%     cache:set(challenge_max_rank,RoleId,Rank).

%% get_role_military_rank()->
%%     Role = player_role:get_role_info_by_roleid(player:get_role_id()),
%%     NewHonour = update_honour(Role:honour()),
%%     get_military_rank_by_honour(NewHonour).

%%update_honour(CurHonour)->
%%     CurLev = get_military_rank_by_honour(CurHonour),
%%     Data = tplt:get_data(military_rank_tplt, CurLev),
%%     Deducted = Data#military_rank_tplt.deducted_honour,
%%     case Deducted =:= 0 of
%% 	true ->
%% 	    CurHonour;
%% 	false ->
%% 	    case get_deduct_time() of
%% 		0 ->
%% 		    set_deduct_time({erlang:date(),{0,0,0}}),
%% 		    CurHonour;
%% 		LastTime ->
%% 		    case (datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(LastTime)) < 86400 of
%% 			true ->
%% 			    CurHonour;
%% 			false ->
%% 			    TotalDays = (datetime:datetime_to_gregorian_seconds(LastTime) - datetime:datetime_to_gregorian_seconds(LastTime)) div  86400,
%% 			    NewRole = military_rank:reduce_honour(?st_honour_deduct,get_deduct_value(CurHonour,TotalDays)),
%% 			    set_deduct_time({erlang:date(),{0,0,0}}),
%% 			    NewRole:honour()
%% 		    end
%% 	    end
%%     end.
%%ok.

%% get_deduct_value(_CurHonour,0)->
%%     0;
%% get_deduct_value(CurHonour,Days)->
%%     CurLev = get_military_rank_by_honour(CurHonour),
%%     %%io:format("~p~n",[CurLev]),
%%     Data = tplt:get_data(military_rank_tplt, CurLev),
%%     Deducted = Data#military_rank_tplt.deducted_honour,
%%     Deducted + get_deduct_value(CurHonour - Deducted, Days - 1).
%%
%%
%%
%%
%%
%%
%%
%% get_deduct_time()->
%%     Time=case cache:get(honour_deduct_time,player:get_role_id()) of
%% 	      [] -> 0;
%% 	      [Timeds] ->element(2,Timeds)
%% 	  end,
%%     Time.
%%
%% set_deduct_time(Time)->
%%     cache:set(honour_deduct_time,player:get_role_id(),Time).
%%
%%
%% get_military_rank_by_honour(Honour) ->
%%     get_military_rank_by_honour(Honour, 1).
%%
%%
%% get_military_rank_by_honour(Honour, Lev)->
%%     try
%% 	Data = tplt:get_data(military_rank_tplt, Lev),
%% 	case Data#military_rank_tplt.max_honour > Honour of
%% 	    true ->
%% 		Lev;
%% 	    false ->
%% 		get_military_rank_by_honour(Honour, Lev + 1)
%% 	end
%%     catch
%% 	_:_ ->
%% 	    Lev - 1
%%     end.
%%--------------------------------------------------------------------
%% @doc
%% @ 模版相关
%% @end
%%--------------------------------------------------------------------

get_tplt(ID) ->
    tplt:get_data(challenge_reward_tplt, ID).




