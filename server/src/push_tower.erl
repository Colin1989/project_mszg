-module(push_tower).

-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("event_def.hrl").

-export([is_push_tower_enable/2,get_can_play_copy/1,to_first_map/1,to_next_map/5]).

-export([clear_cur_map_info/0,buy_push_tower_round/0,buy_push_tower_playtimes/0,
	 get_push_max_tower_times/1,get_play_times_today/0,get_max_floor/0]).
-compile(export_all).


%%--------------------------------------------------------------------
%% @doc
%% @判断今天次数是否已用完
%% @end
%%--------------------------------------------------------------------
is_push_tower_enable(RoleId,_Copy)->
    Times=case cache_with_expire:get(push_tower_play_times,RoleId) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    case get_push_max_tower_times(RoleId) > Times of
	true ->
	    true;
	false ->
	    sys_msg:send_to_self(?sg_push_tower_times_exceeded,[]),
	    false
    end.
%%--------------------------------------------------------------------
%% @doc
%% @获取最高通关
%% @end
%%--------------------------------------------------------------------
get_max_floor()->
    PushTower = get_role_push_tower_info(),
    PushTower:max_floor().

%%--------------------------------------------------------------------
%% @doc
%% @获取今天已玩次数
%% @end
%%--------------------------------------------------------------------
get_play_times_today()->
    Times=case cache_with_expire:get(push_tower_play_times,player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

%%--------------------------------------------------------------------
%% @doc
%% @获取每天可玩次数
%% @end
%%--------------------------------------------------------------------
get_push_max_tower_times(_RoleId)->
    Org=config:get(push_tower_times) + vip:get_privilege_count(5),
    Org + get_push_tower_buy_times().
%%--------------------------------------------------------------------
%% @doc
%% @判断是否可进入
%% @end
%%--------------------------------------------------------------------
get_can_play_copy(RoleId)->
    %%[Role] = db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    Level = Role:level(),
    Copys=tplt:get_all_data(push_tower_copy),
    case lists:filter(fun(X) -> 
			      (Level >= X#push_tower_copy.min_level)  and  (Level =< X#push_tower_copy.max_level)
		      end, Copys) of
	[] ->
	    undefined;
	[Copy] ->
	    Copy
    end.
%%--------------------------------------------------------------------
%% @doc
%% @首层
%% @end
%%--------------------------------------------------------------------
to_first_map(CopyId)->
    GameId = uuid:gen(),
    Copy = tplt:get_data(push_tower_copy, CopyId),
    MapId = Copy#push_tower_copy.first_map_id,
    put(cur_copy_id, CopyId),
    Info = get_push_tower_map_info(1,MapId),
    set_cur_map_info({GameId, MapId, 1, config:get(push_tower_max_round), 0, 0,0}, Info),
    activeness_task:update_activeness_task_status(push_tower),
    {GameId,Info}.



buy_push_tower_round()->
    case get_cur_map_info() of
	{{GameId, CurMap, Times, RoundLeft, TotalFloors, BuyRoundTimes, TotalDropGold}, PreMap} ->
	    case BuyRoundTimes of
		0 ->
		    Cost = config:get(push_tower_emoney_buy_round),
		    Round = config:get(push_tower_buy_round_amount),
		    case player_role:check_emoney_enough(Cost) of
			true ->
			    player_role:reduce_emoney(?st_push_tower_buy_round,Cost),
			    set_cur_map_info({GameId, CurMap, Times, RoundLeft+Round, TotalFloors, 1, TotalDropGold}, PreMap),
			    ?common_success;
			false ->
			    ?common_failed
		    end;
		_ ->
		    ?common_failed
	    end;
	_ ->
	    ?common_error
    end.

buy_push_tower_playtimes()->
    BuyTimes = get_push_tower_buy_times(),
    case check_buy_push_tower_times_enable(BuyTimes) of
	true ->
	    Cost = get_buy_push_tower_need_emoney(BuyTimes),%%trunc(3*math:pow(2,(BuyTimes+1))),
	    case player_role:check_emoney_enough(Cost) of
		true ->
		    increase_push_tower_buy_times(),
		    player_role:reduce_emoney(?st_push_tower_buy_playtimes,Cost),
		    ?common_success;
		false ->
		    sys_msg:send_to_self(?sg_push_tower_buy_emoney_not_enough, []),
		    ?common_failed
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_push_tower_buy_times_exceeded, []),
	    ?common_failed
    end.

%%--------------------------------------------------------------------
%% @doc
%% @每天的购买的尝试次数
%% @end
%%--------------------------------------------------------------------
get_push_tower_buy_times()->
    Times=case cache_with_expire:get(push_tower_buy_play_times,player:get_role_id()) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

increase_push_tower_buy_times()->
    cache_with_expire:increase(push_tower_buy_play_times,player:get_role_id(),day).
    
%%--------------------------------------------------------------------
%% @doc
%% @下一层
%% @end
%%--------------------------------------------------------------------
to_next_map(CGameId, CostRound, Life, Result, DropGold) ->
    case get_cur_map_info() of
	{{GameId, MapId, Times, RoundLeft, TotalFloors, BuyTimes, TotalDropGold}, MapInfo} ->
	    case is_req_legal(CGameId, CostRound , {GameId, MapInfo, Times, RoundLeft}, Result) of
		true ->
		    case is_push_tower_over(RoundLeft, CostRound, Life, Result) of
			{true, Reason} ->
			    make_push_tower_settle(Reason, GameId, MapId, TotalFloors, Life, TotalDropGold + DropGold);
			false ->
			    do_to_next_map(MapId, Times, MapInfo, CostRound, RoundLeft, GameId, TotalFloors, BuyTimes, TotalDropGold + DropGold)
		    end;
		false ->
		    clear_cur_map_info(),
		    {?map_settle_error, [#game_map{}],[]}
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_push_tower_settle_gameinfo_not_exist,[]),
	    {?map_settle_error, [#game_map{}],[]}
    end.


%%推塔结束进行结算
make_push_tower_settle(Reason, GameId, CurMap, TotalFloors, Life, NewTotalDropGold) ->
    event_router:send_event_msg(#event_push_tower{result = ?game_win}),
    process_push_tower_settle({GameId, CurMap, TotalFloors, Life, NewTotalDropGold}),
    clear_cur_map_info(),
    {Reason, [#game_map{}],[]}.


%%回合数未用完且生命不为零，则进入下层地图
do_to_next_map(MapId, Times, PreMap, CostRound, RoundLeft, GameId, TotalFloors, BuyTimes, NewTotalDropGold) ->
    Map = tplt:get_data(push_tower_map, MapId),
    {Reply, MapInfo} = case Map#push_tower_map.repeat_times > Times of
			   true ->
			       Info = get_push_tower_map_info(PreMap#game_map.key, MapId),
			       NewMapInfo = {GameId, MapId, Times+1, RoundLeft-CostRound, TotalFloors+1, BuyTimes, NewTotalDropGold},
			       set_cur_map_info(NewMapInfo, Info),
			       {{?map_settle_next_map, [Info], [], 0, 0}, NewMapInfo};
			   false ->
			       case Map#push_tower_map.next_map of
				   0 ->
				       {?map_settle_error, [#game_map{}],[]};
				   NewMapId ->
				       ExtraGold = get_push_tower_pass_gold(MapId),
				       NInfo = get_push_tower_map_info(PreMap#game_map.key, NewMapId),
				       NewMapInfo = {GameId, NewMapId, 1, RoundLeft-CostRound,
						     TotalFloors+1, BuyTimes, NewTotalDropGold},
				       set_cur_map_info(NewMapInfo, NInfo),
				       {{?map_settle_next_map, [NInfo], [], ExtraGold, 0}, NewMapInfo}
			       end
		       end,
    settle_push_tower(Reply, MapInfo).



%%推塔结算并检测是否已经爬到最高层
settle_push_tower(Reply, MapInfo) ->
    {GameId, MapId, _Times, _RoundLeft, TotalFloors, _BuyTimes, TotalDropGold} = MapInfo,
    ExtraGold = get_push_tower_pass_gold(MapId),
    player_role:add_gold(?st_push_tower_settle, ExtraGold), 
    case TotalFloors >= config:get(max_push_tower_floor) of
	true ->
	    %%activeness_task:update_activeness_task_status(push_tower),
	    process_push_tower_settle({GameId, MapId, TotalFloors, 100, TotalDropGold}),
	    %%cache_with_expire:increase(push_tower_play_times, player:get_role_id(), day),
	    clear_cur_map_info(),
	    {?map_settle_finish, [#game_map{}],[], element(4, Reply), element(5, Reply)};
	false ->
	    Reply
    end.


make_award_list(List)->
    case List of
	[] ->
	    [];
	[TempId|ListLeft] ->
	    CurList = make_award_list(ListLeft),
	    case lists:filter(fun(X)-> 
				      X#award_item.temp_id == TempId
			      end,CurList) of
		[] ->
		    [#award_item{temp_id=TempId,amount=1}|CurList];
		[Item] ->
		    NewItem = #award_item{temp_id = TempId, amount = Item#award_item.amount + 1},
		    [NewItem|(CurList -- [Item])]
	    end
    end.



%%--------------------------------------------------------------------
%% @doc
%% @推塔结算
%% @end
%%--------------------------------------------------------------------
process_push_tower_settle(GameInfo)->
    {GameId, CurMap, TotalFloors, Life, NewTotalDropGold} = GameInfo,
    {PassTimes,DieTimes,Result} = case Life > 0 of
			       true ->
				   {1,0,1};
			       false ->
				   {0,1,2}
			   end,
    player_role:reduce_gold(?push_tower, abs(NewTotalDropGold)),
    PushTowerInfo = get_role_push_tower_info(),
    MaxFloor = case TotalFloors > PushTowerInfo:max_floor() of
		   true ->
		       TotalFloors;
		   false ->
		       PushTowerInfo:max_floor()
	       end,
    NewInfo = PushTowerInfo:set([{pass_times,PushTowerInfo:pass_times()+PassTimes},{die_times,PushTowerInfo:die_times()+DieTimes},
				{try_times,PushTowerInfo:try_times()+1},{max_floor,MaxFloor},{last_try_time,datetime:local_time()}]),
    RoleId = player:get_role_id(),
    Gold = update_gold_and_exp(CurMap, TotalFloors, RoleId, NewTotalDropGold),
    NewInfo:save(),
    %%Result 1表示回合用完，2表示死亡
    game_log:write_only_game_info(Result, ?push_tower, GameId, 0, player:get_role_id(), TotalFloors, [], Gold).


get_extra_gold(TotalFloors)->
    CopyId = get_copyid(),
    CopyInfo = tplt:get_data(push_tower_copy,CopyId),
    accumulate_gold(TotalFloors, CopyInfo#push_tower_copy.first_map_id, 0).


accumulate_gold(Left, CurMap, CurGold)->
    MapInfo = tplt:get_data(push_tower_map, CurMap),
    case MapInfo#push_tower_map.repeat_times > Left of
	true ->
	    CurGold;
	false ->
	    case MapInfo#push_tower_map.next_map of
		0 ->
		    CurGold + MapInfo#push_tower_map.gold;
		_ ->
		    accumulate_gold(Left - MapInfo#push_tower_map.repeat_times, MapInfo#push_tower_map.next_map, CurGold + MapInfo#push_tower_map.gold)
	    end
	    
    end.

get_copyid() ->
    case get(cur_copy_id) of
	undefined ->
	    Copy = push_tower:get_can_play_copy(player:get_role_id()),
	    CopyId = Copy#push_tower_copy.id,
	    put(cur_copy_id, CopyId),
	    CopyId;
	CopyId ->
	    CopyId
    end.


get_role_push_tower_info()->
    case db:find(db_push_tower,[{role_id, 'equals', player:get_role_id()}]) of
	[] ->
	    db_push_tower:new(id,player:get_role_id(),0,0,0,0,datetime:local_time(),datetime:local_time());
	[Info] ->
	    Info
    end.



%%--------------------------------------------------------------------
%% @doc
%% @更新金币和经验
%% @end
%%--------------------------------------------------------------------
update_gold_and_exp(_CurMap, TotalFloors, _RoleId, NewTotalDropGold)->
    %%Role = player_role:get_db_role(RoleId),
    TotalGold = get_extra_gold(TotalFloors),
    %% player_role:add_gold(?st_push_tower_settle,TotalGold),       %%加金币
    %% Gold = TotalGold + Role:gold(),
    %% CurRole=Role:set(gold,Gold),
    %% player_role:notify_role_info(CurRole),
    TotalGold + NewTotalDropGold.


%%--------------------------------------------------------------------
%% @doc
%% @分发物品
%% @end
%%--------------------------------------------------------------------    
giveout_items(GrandItems)->
    player_pack:add_items(?st_game_settle,make_item_tuples(GrandItems)).
make_item_tuples(GrandItems)->
    ItemTuples=lists:map(fun(X) ->
				 {X,1}
			 end,GrandItems),
    ItemTuples.


%%--------------------------------------------------------------------
%% @doc
%% @比赛是否结束
%% @end
%%--------------------------------------------------------------------
is_push_tower_over(RoundLeft, CostRound, Life, Result)->
    case Life > 0 of
	true ->
	    case (Result =:= ?map_settle_finish) or (Result =:= ?map_settle_died) of
		true ->
		    {true, Result};
		false ->
		    case CostRound > RoundLeft of
			true ->
			    {true, ?map_settle_finish};
			false ->
			    false
		    end
	    end;
	false ->
	    {true,?map_settle_died}
    end.



%%--------------------------------------------------------------------
%% @doc
%% @判断请求是否合法
%% @end
%%--------------------------------------------------------------------
is_req_legal(CGameId, CostRound, GameInfo, Result)->
    {GameId, CurMap, _Times, RoundLeft } = GameInfo,
    case CGameId of
	GameId ->
	    case (Result =:= ?map_settle_finish) or (Result =:=?map_settle_died) of
		true ->
		    true;
		false ->
		    case CostRound >= get_way_length(CurMap#game_map.key,CurMap#game_map.start) of
			true ->
			    case CostRound =< RoundLeft of
				true ->
				    true;
				_ ->
				    sys_msg:send_to_self(?sg_push_tower_settle_round_not_enouth,[]),
				    false
			    end;
			false ->
			    sys_msg:send_to_self(?sg_push_tower_settle_cost_round_illegel,[]),
			    false
		    end
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_push_tower_settle_gameid_not_match,[]),
	    false
    end.
%%--------------------------------------------------------------------
%% @doc
%% @路径长度
%% @end
%%--------------------------------------------------------------------
get_way_length(_Pos1, _StartPos1)->
    0.
    %% Pos = Pos1 - 1,
    %% StartPos = StartPos1 - 1,
    %% abs((Pos div 5)-(StartPos div 5)) + abs((Pos rem 5)-(StartPos rem 5)).

get_push_tower_map_info(_StartPos,MapId)->
    Map = tplt:get_data(push_tower_map,MapId),
    Mostters = get_monsters(Map),
    [Scene] = rand:rand_members_from_list(Map#push_tower_map.scene,1),
    Traps = get_traps(Map),
    Friends = get_friends(Map),
    Awards = get_awards(Map),
    create_push_tower_map(Map#push_tower_map.key_monster,Mostters,Traps,Friends,Awards,Scene,Map#push_tower_map.barrier_amount).

create_push_tower_map(KeyMonster,Mostters,Traps,Friends,Awards,Scene,Barriers)->
    game_copy:create_push_tower(KeyMonster,Mostters,Traps,Friends,Awards,Scene,Barriers).
%%--------------------------------------------------------------------
%% @doc
%% @获取怪物列表
%% @end
%%--------------------------------------------------------------------
get_monsters(Map)->
    Min = Map#push_tower_map.monster_min,
    Max = Map#push_tower_map.monster_max,
    MonsterIds = Map#push_tower_map.monsters,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(MonsterIds, Count).


%%--------------------------------------------------------------------
%% @doc
%% @获取陷阱列表
%% @end
%%--------------------------------------------------------------------
get_traps(Map)->
    Min = Map#push_tower_map.trap_min,
    Max = Map#push_tower_map.trap_max,
    TrapIds = Map#push_tower_map.traps,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(TrapIds, Count).


%%--------------------------------------------------------------------
%% @doc
%% @获取好友ID列表
%% @end
%%--------------------------------------------------------------------
get_friends(Map)->
    Min = Map#push_tower_map.friend_min,
    Max = Map#push_tower_map.friend_max,
    FriendIds = Map#push_tower_map.friends,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(FriendIds, Count).

%%--------------------------------------------------------------------
%% @doc
%% @获取奖励事件列表
%% @end
%%--------------------------------------------------------------------
get_awards(Map)->
    Min = Map#push_tower_map.award_min,
    Max = Map#push_tower_map.award_max,
    AwardIds = Map#push_tower_map.awards,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(AwardIds, Count).


%%--------------------------------------------------------------------
%% @doc
%% @保存获取清空比赛信息
%% @end
%%--------------------------------------------------------------------
set_cur_map_info(ExtraInfo, Info)->
    io_helper:format("{ExtraInfo:~p, Info:~p~n}", [ExtraInfo, Info]),
    cache:set(map_information,player:get_role_id(),{ExtraInfo, Info}).

get_cur_map_info()->
    case cache:get(map_information,player:get_role_id()) of
	[Result] ->
	    element(2,Result);
	Other ->
	    Other  
    end.

clear_cur_map_info()->
    cache:delete(map_information,player:get_role_id()).


%%--------------------------------------------------------------------
%% @doc
%% @获取整层奖励
%% @end
%%--------------------------------------------------------------------

get_push_tower_pass_gold(MapId) ->
    MapInfo = tplt:get_data(push_tower_map, MapId),
    MapInfo#push_tower_map.gold.


get_gem_award(Left,Award,GemLev)->
    {GemList, Ridio} = get_gemlist_and_radio(Award, GemLev),
    CurRadio = Ridio * 100,
    case CurRadio >= Left of
	true -> 
	    [Gem] = rand:rand_members_from_list(GemList,1),
	    Gem;
	false ->
	    get_gem_award(Left - CurRadio, Award, GemLev+1)
    end.


get_gemlist_and_radio(Award, Lev)->
    case Lev of
	1 ->
	    {Award#push_tower_award.gem_lev1,Award#push_tower_award.lev1_radio};
	2 ->
	    {Award#push_tower_award.gem_lev2,Award#push_tower_award.lev2_radio};
	3 ->
	    {Award#push_tower_award.gem_lev3,Award#push_tower_award.lev3_radio};
	4 ->
	    {Award#push_tower_award.gem_lev4,Award#push_tower_award.lev4_radio}
    end.



get_buy_push_tower_need_emoney(Times) ->
    Fun = (tplt:get_data(expression_tplt, 16))#expression_tplt.expression,
    Fun([{'Times', Times}]).    

check_buy_push_tower_times_enable(Times) ->
    Times < config:get(push_tower_max_buy_times).



%% get_pre_map_info()->
%%     cache:get(map_information,player:get_role_id()).


%% set_pre_map_info(Info)->
%%     cache:set(map_information,player:get_role_id(),Info).

%% clear_pre_map_info()->
%%     cache:delete(map_information,player:get_role_id()).
