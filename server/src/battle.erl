-module(battle).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").
-include("event_def.hrl").

-export([start/0, 
         get_gameinfo/1,
         get_mapinfo/0,
         clear_mapinfo/0]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
start()->
    packet:register(?msg_req_enter_game, {?MODULE,proc_req_enter_game}),
    packet:register(?msg_req_last_copy, {?MODULE,proc_req_last_copy}),
    packet:register(?msg_req_game_settle,{?MODULE,proc_req_game_settle}),
    packet:register(?msg_req_push_tower_map_settle,{?MODULE,proc_req_push_tower_map_settle}),
    packet:register(?msg_req_reborn,{?MODULE, proc_req_reborn}),
    packet:register(?msg_req_push_tower_buy_round,{?MODULE, proc_req_push_tower_buy_round}),
    packet:register(?msg_req_push_tower_buy_playtimes,{?MODULE, proc_req_push_tower_buy_playtimes}),
    packet:register(?msg_req_push_tower_info,{?MODULE, proc_req_push_tower_info}),
    packet:register(?msg_req_game_lottery,{?MODULE, proc_req_lottery}),
    packet:register(?msg_req_clean_up_copy, {?MODULE, proc_req_clean_up_copy}),
    packet:register(?msg_req_auto_fight, {?MODULE, proc_req_auto_fight}),
    %%ets:new(map_information,[ordered_set, public, named_table]),
    %%ets:new(role_battle_info,[ordered_set,public,named_table]),
    ok.

proc_req_push_tower_info(#req_push_tower_info{}=Packet)->
    MaxFloors = push_tower:get_max_floor(),
    PlayTimes = push_tower:get_play_times_today(),
    MaxTimes = push_tower:get_push_max_tower_times(player:get_role_id()),
    packet:send(#notify_push_tower_info{play_times=PlayTimes,max_times=MaxTimes,max_floor=MaxFloors}),
    io_helper:format("~p~n",[Packet]),
    ok.  
proc_req_reborn(#req_reborn{type = Type} = Packet)->
    io_helper:format("~p~n",[Packet]),
    Times = case cache:get(list_to_atom(lists:concat(['reborn_times:', Type])), player:get_role_id()) of
		[] ->
		    0;
		[{_, TheTimes}] ->
		    TheTimes
	    end,
    case Type of
	_ ->
	    NeedEmoney = get_reborn_need(Times),%%20 * trunc(math:pow(2,Times)),
	    case player_role:check_emoney_enough(NeedEmoney) of
		true ->
		    player_role:reduce_emoney(?st_reborn_base + Type, NeedEmoney),
		    cache:set(list_to_atom(lists:concat(['reborn_times:', Type])), player:get_role_id(), Times + 1),
		    packet:send(#notify_reborn_result{result = ?common_success}),
		    ok;
		false ->
		    packet:send(#notify_reborn_result{result = ?common_failed}),
		    sys_msg:send_to_self(?sg_reborn_emoney_not_enough, [])
	    end
    end.



proc_req_push_tower_buy_round(Packet)->
    io_helper:format("~p~n",[Packet]),
    Result = push_tower:buy_push_tower_round(),
    packet:send(#notify_push_tower_buy_round{result=Result}),
    ok.

proc_req_push_tower_buy_playtimes(Packet)->
    io_helper:format("~p~n", [Packet]),
    Result = push_tower:buy_push_tower_playtimes(),
    packet:send(#notify_push_tower_buy_playtimes{result=Result}),
    ok.



proc_req_push_tower_map_settle(#req_push_tower_map_settle{game_id=GameId, cost_round=CostRound, life=Life, pickup_items=_Items,
                                                          drop_gold = DropGold, result =Result}=Packet) when DropGold =< 0 ->
    io_helper:format("~p~n",[Packet]),
    case push_tower:to_next_map(GameId, CostRound, Life, Result, DropGold) of
	{_Result,Info,Award} ->
	    packet:send(#notify_push_tower_map_settle{result=_Result,gamemap=Info,awards=Award});
	{_Result,Info,Award,Gold,Exp} ->
	    packet:send(#notify_push_tower_map_settle{result=_Result,gamemap=Info,awards=Award,gold=Gold,exp=Exp})
	    
    end.
    
    %% case Life =< 0 of
    %% 	true ->
    %% 	    packet:send(#notify_push_tower_map_settle{result=?map_settle_finish});
    %% 	false ->
    %% 	    {Result,Info,Award} = push_tower:to_next_map(GameId, CostRound, Items, Life),
    %% 	    packet:send(#notify_push_tower_map_settle{result=Result,gamemap=Info,awards=Award})
    %% end.
%%--------------------------------------------------------------------
%% @doc
%% @结算时再次请求抽卡
%% @end
%%--------------------------------------------------------------------
proc_req_lottery(#req_game_lottery{}) ->
    RoleID = player:get_role_id(),
    [{_, LotteryInfo}] = cache:get(copy_lottery_info, RoleID),
    AwardID = element(4, LotteryInfo),
    AwardInfo = tplt:get_data(game_award, AwardID),
    NeedEmoney = AwardInfo#game_award.need_emoney,
    LotterItem = element(2, LotteryInfo),
    %%io:format("lottery_NeedEmoney:~p~n", [NeedEmoney]),
    case NeedEmoney > player_role:get_emoney() of
	true ->
	    sys_msg:send_to_self(?sg_game_emoney_not_enough, []),
	    packet:send(#notify_game_lottery{second_item = LotterItem, result = ?common_failed});
	false ->
	    %% 扣代币
	    player_role:reduce_emoney(?st_game_settle, NeedEmoney),
	    %% 发奖励
	    giveout_lottery_item(LotterItem),
	    packet:send(#notify_game_lottery{second_item = LotterItem, result = ?common_success})
    end.
%%--------------------------------------------------------------------
%% @doc
%% @进行推塔游戏
%% @end
%%--------------------------------------------------------------------
play_push_tower()->
    RoleId=player:get_role_id(),
    case push_tower:get_can_play_copy(RoleId) of
	undefined ->
	    sys_msg:send_to_self(?sg_push_tower_enter_level_nomatch,[]),
	    packet:send(#notify_enter_game{result=?enter_game_failed});
	Copy ->
	    case push_tower:is_push_tower_enable(RoleId,Copy) of
		true ->
		    {GameId,GameMap} = push_tower:to_first_map(Copy#push_tower_copy.id),
		    player_role:init_role_battle_info(),
		    %%增加推塔已玩次数
		    cache_with_expire:increase(push_tower_play_times,player:get_role_id(),day),
		    packet:send(#notify_enter_game{result=?enter_game_success,game_id=GameId,gamemaps=[GameMap]});
		false ->
		    PackTypeFailed=#notify_enter_game{result=?enter_game_failed},
		    packet:send(PackTypeFailed)
	    end
    end.

proc_req_clean_up_copy(#req_clean_up_copy{copy_id = CopyId, count = Count}) when Count =< 5 ->
    case check_clean_up_copy_leagal(CopyId, Count) of
	true ->
	    {TraphyList, TotalTrophy} = circle_clean_up(CopyId, Count, [], {0, 0, []}),
            game_copy:update_pass_copy(CopyId, {?game_win, 3}, Count),
	    send_clean_up_trophy(TotalTrophy, CopyId, Count),
            {Ids, Amounts} = game_copy:get_clean_up_rewards(CopyId),
            reward:give(Ids, [Amount*Count||Amount <- Amounts], ?st_game_settle),
            player_pack:delete_items(?st_game_settle, [{config:get(clean_up_card_id), Count}]),
%%             event_router:send_event_msg(#event_clean_up{times = Count}),
            event_router:send_event_msg(#event_game_copy{copy_id = CopyId, score = 3, count = Count}),
            packet:send(#notify_clean_up_copy_result{result = ?common_success, trophy_list = TraphyList});
	{false, Msg} ->
	    sys_msg:send_to_self(Msg, []),
	    packet:send(#notify_clean_up_copy_result{result = ?common_failed})
    end.

check_clean_up_copy_leagal(CopyId, Count) ->
    CopyInfo = game_copy:get_copy_info(CopyId),
    case CopyInfo#copy_tplt.type of
	Type when Type =:= 1 orelse Type =:= 2 ->
            case game_copy:check_func_unlock(40) of
                true ->
                    case power_hp:get_power_hp() < (CopyInfo#copy_tplt.need_power + CopyInfo#copy_tplt.win_need_power) * Count of
                        true ->
                            {false, ?sg_clean_up_copy_ph_not_enough};
                        false ->
                            case game_copy:is_copy_max_score(CopyId) of
                                false ->
                                    {false, ?sg_clean_up_copy_not_max_score};
                                true ->
                                    [{_,Amount}]  = player_pack:get_items_count([config:get(clean_up_card_id)]),
                                    case Amount >= Count of
                                        true ->
                                            true;
                                        false ->
                                            {false, ?sg_clean_up_copy_clean_up_card_not_enough}
                                    end
                            end
                    end;
                false ->
                    {false, ?sg_clean_up_copy_pass_copy_not_enough}
            end;
	_ ->
	    {false, ?sg_clean_up_copy_not_base_copy}
    end.

send_clean_up_trophy(TotalTrophy, CopyId, Count) ->
    RoleId = player:get_role_id(),
    {NG, NE, NI} = TotalTrophy,
    game_log:write_game_info(?game_win,?copy_clean_up, 0, CopyId, player:get_role_id(), 3,NI, NG, Count),
    {_NewPower, CurRole} = update_clean_up_gold_power_exp(RoleId, CopyId, NG, NE, Count),
    player_role:notify_role_info(CurRole),
    giveout_items(NI),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @ 请求自动战斗
%% @end
%%--------------------------------------------------------------------
proc_req_auto_fight(#req_auto_fight{}) ->
    Gold = player_role:get_gold(),
    Level = player_role:get_level(),
    %%case Level >= config:get(auto_fight_min_level) of
    case game_copy:check_func_unlock(18) of
	true ->
	    NeedGold = get_auto_fight_need_gold(Level),
	    case Gold >= NeedGold of
		true ->
		    player_role:reduce_gold(?st_auto_fight, NeedGold),
		    packet:send(#notify_auto_fight_result{result = ?common_success});
		false ->
		    packet:send(#notify_auto_fight_result{result = ?common_failed})
	    end;
	false ->
	    packet:send(#notify_auto_fight_result{result = ?common_failed})
    end.

get_auto_fight_need_gold(Level) ->
	Fun = (tplt:get_data(expression_tplt, 22))#expression_tplt.expression,
	Fun([{'Lev', Level}]).
%% game_settle(Result,CopyId,GameId,Life,MaxLife,MonsterAmount,PickUpItems,Operations,Gold,KillMonsters)->
%%     RoleId = player:get_role_id(),
%%     Score = 3,
%%     event_router:send_event_msg(#event_game_copy{copy_id = CopyId, score = Score, monsterids = KillMonsters}),
%%     {_NewPower,CurRole}=update_gold_power_exp(RoleId,CopyId,Gold),
%%     %%lists:foreach(fun(ItemId)->player_pack:add_item(notify, ?st_game_settle, ItemId) end,PickUpItems),
%%     {FinalItem, RatioList} = deal_final_item(Score, CopyId, RoleId),
%%     %%[FinalItemInfo|PickUpItemInfos]=case FinalItem of
%%     %%					0->[0|giveout_items(PickUpItems)];
%%     %%					_->giveout_items([FinalItem|PickUpItems])
%%     %%				    end,
%%     giveout_items(PickUpItems),
%%     player_role:notify_role_info(CurRole),
%%     game_log:write_game_log(Result,?common,RoleId,GameId,Life,MaxLife,MonsterAmount,PickUpItems,Score,FinalItem,Operations,get_mapinfo(),Gold),
%%     packet:send(#notify_game_settle{result=?game_win, score=Score,final_item=FinalItem,ratio_items=RatioList}),
%%     clear_mapinfo(),
%%     Score.
proc_req_game_settle(#req_game_settle{
			result=Result,game_id=Gameid,life=Life,maxlife=MaxLife,killmonsters= KillMonsters,
			user_operations=Operations, pickup_items=PickUpItems,gold=Gold, cost_round = CostRound}=_Packet)->
    %%io_helper:format("~p~n",[Packet]),

    case get_mapinfo() of
	{GameId,CopyId,_AllMap}->
	    case game_validation:game_validate(Operations,Result,Gold,PickUpItems,_AllMap) of
		true ->
		    case GameId of
			Gameid->
			    assistance:assistance_settle(Result,?st_game_settle),
			    case Result of
				?game_lost->
				    game_log:write_game_log(Result,?common,player:get_role_id(),Gameid,Life,MaxLife,CostRound,PickUpItems,0,0,
							    Operations,{GameId,CopyId,_AllMap},Gold),
				    packet:send(#notify_game_settle{result=?game_lost}),
				    event_router:send_event_msg(#event_game_copy{copy_id = CopyId, score = 0, monsterids = KillMonsters, count = 1});
				    %%game_copy:update_pass_copy(CopyId, {Result, 0});
				?game_win ->
				    Score=game_settle(Result,CopyId,GameId,Life,MaxLife, CostRound, PickUpItems,Operations,Gold, KillMonsters),
				    game_copy:update_pass_copy(CopyId,{Result,Score})
				    %%game_copy:update_lastcopy(player:get_role_id(),CopyId)
			    end;
			_->
			    sys_msg:send_to_self(?sg_game_settle_error,[]),
			    packet:send(#notify_game_settle{result=?game_error})  
		    end;
		false ->
		    packet:send(#notify_game_settle{result=?game_lost})	
	    end;
	_->
	    sys_msg:send_to_self(?sg_game_settle_error,[]),
	    packet:send(#notify_game_settle{result=?game_error})

    end,
    clear_mapinfo().
    

proc_req_last_copy(#req_last_copy{roleid=RoleId}=Packet)->
    io_helper:format("~p~n",[Packet]),
    %%LastCopy=game_copy:get_lastcopy(RoleId),
    CopyInfoList=game_copy:query_all_pass_copy_information(RoleId),
    %%LastCopyId=case has_pass_last_copy(LastCopy,CopyInfoList) of
    %%		 true->game_copy:update_lastcopy(RoleId,LastCopy);
    %%		 false->LastCopy
    %%	       end,
    LastCopyId=1001,
    Pack=#notify_last_copy{last_copy_id=LastCopyId,copyinfos=CopyInfoList},
    packet:send(Pack).

%%has_pass_last_copy(CopyId,[#copy_info{copy_id=CopyId,max_score=MaxScore}|_ListLeft])->
%%    case MaxScore of
%%	0->false;
%%	_ ->true
%%    end;
%%has_pass_last_copy(_CopyId,[])->
%%    false;
%%has_pass_last_copy(CopyId,[_|ListLeft])->
%%    has_pass_last_copy(CopyId,ListLeft).

    
proc_req_enter_game(#req_enter_game{id=RoleId,gametype=GameType,copy_id=CopyId}=Packet)->
    io_helper:format("~p~p~n",[RoleId,Packet]),
    game_init(GameType,CopyId).


%%--------------------------------------------------------------------
%% @doc
%% @获取关卡信息并生成关卡地图
%% get_gameinfo(GameId::int)->GameInfo::#notify_enter_game{}
%% GameId:关卡ID
%% @end
%%--------------------------------------------------------------------
get_gameinfo(CopyId)->
    {GameId,AllMap}=game_copy:get_gameinfo(CopyId),
    set_mapinfo(GameId,CopyId,AllMap),
    #notify_enter_game{result=?enter_game_success,gamemaps=AllMap,game_id=GameId}.

    
%%--------------------------------------------------------------------
%% @doc
%% @保存地图信息用于后期校验
%% get_mapinfo()->AllMap::List(#game_map{}).
%% AllMap:地图信息
%% @end
%%--------------------------------------------------------------------
get_mapinfo()->
    RoleId=player:get_role_id(),
    case cache:get(map_information,RoleId) of
    %%case ets:lookup(map_information,RoleId) of
	[{_Key,Value}]->
	    Value;
	_ ->undefined
    end.

clear_mapinfo()->
    RoleId=player:get_role_id(),
    cache:delete(map_information,RoleId).
    %%ets:delete(map_information,RoleId).
%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @关卡校验,返回是否可以进行游戏
%% get_whether_can_play(GameId::int)->true|false
%% @end
%%-------------------------------------------------------------------- 
get_whether_can_play(GameId) ->
  %%RoleId=player:get_role_id(),

  %%LastCopy=game_copy:get_lastcopy(RoleId),
  case game_copy:is_copy_unlock(GameId) of
      true ->
          GetNeedPower = game_copy:get_need_power(GameId),
	  NeedPower = GetNeedPower + game_copy:get_win_need_power(GameId),
	  MyPower = power_hp:get_power_hp(),
	  case MyPower < NeedPower of
	      true ->
		  sys_msg:send_to_self(?sg_game_not_enough_power, []),
		  false;
	      false ->
		  NeedStone = game_copy:get_need_stone(GameId),
		  case player_role:check_summon_stone_enough(NeedStone) of
		      false ->
			  sys_msg:send_to_self(?sg_game_not_enough_summon_stone, []),
			  false;
		      true ->
			  case player_role:get_level() >= game_copy:get_need_level(GameId) of
			      true ->
				  player_role:reduce_summon_stone(?st_boss_copy, NeedStone),
				  NewHp = power_hp:cost_hp(cost, player:get_role_id(), GetNeedPower),%%扣体力
				  packet:send(#notify_role_info_change{type = "power_hp", new_value = NewHp}),
				  true;
			      false ->
				  sys_msg:send_to_self(?sg_game_level_not_enough, []),
				  false
			  end

		  end
	  end;
      false ->
	  sys_msg:send_to_self(?sg_game_copy_lock, []),
      false
  end.

%%--------------------------------------------------------------------
%% @doc
%% @保存地图信息用于后期校验
%% set_mapinfo(GameId,AllMap::List(#game_map{}))->ok.
%% AllMap:地图信息
%% @end
%%--------------------------------------------------------------------
set_mapinfo(GameId,CopyId,AllMap)->
    RoleId=player:get_role_id(),
    cache:set(map_information,RoleId,{GameId,CopyId,AllMap}).
    %%ets:insert(map_information,{RoleId,{GameId,CopyId,AllMap}}).


game_init(GameType,GameId)->
    PlayerID=player:get_player_id(),
    case player:get_player_id() of
	undefined->
	    PackUnLogin=#notify_enter_game{result=?enter_game_unlogin},
	    packet:send(PackUnLogin);
	PlayerID->
	    case GameType of
		?common->
		    cache:set(list_to_atom(lists:concat(['reborn_times:', ?common])), player:get_role_id(), 0),
		    play_common_game(GameId);
		?push_tower->
		    NeedPassCopyID = game_copy:get_func_unlock_need_copy_id(17),
		    case game_copy:check_copy_has_passed(NeedPassCopyID) of
			true ->
			    cache:set(list_to_atom(lists:concat(['reborn_times:', ?push_tower])), player:get_role_id(), 0),
			    play_push_tower();
			false ->
			    packet:send(#notify_enter_game{result=?enter_game_failed}),
			    sys_msg:send_to_self(?sg_game_copy_not_pass,[])
		    end;

		_ ->
		    PackTypeError=#notify_enter_game{result=?enter_game_failed},
		    packet:send(PackTypeError)
	    end
    end.
%%--------------------------------------------------------------------
%% @doc
%% @进行主线副本
%% @end
%%--------------------------------------------------------------------
play_common_game(GameId)->
    case get_whether_can_play(GameId) of
	true->
	    PackSuccess=get_gameinfo(GameId),
	    player_role:init_role_battle_info(),
	    game_copy:update_try_copy(GameId),
	    packet:send(PackSuccess);
	false->
	    PackTypeFailed=#notify_enter_game{result=?enter_game_failed},
	    packet:send(PackTypeFailed)
    end.





%%--------------------------------------------------------------------
%% @doc
%% @通关副本后进行战斗结算
%% game_settle(GameId::int)
%% @end
%%--------------------------------------------------------------------
game_settle(Result,CopyId,GameId,Life,MaxLife,CostRound,PickUpItems,Operations,Gold,KillMonsters)->
    RoleId = player:get_role_id(),
    Score=get_game_score(CopyId,CostRound,Life,MaxLife),
    event_router:send_event_msg(#event_game_copy{copy_id = CopyId, score = Score, monsterids = KillMonsters, count = 1}),
    {_NewPower, CurRole} = update_gold_power_exp(RoleId, CopyId, Gold),

    %%lists:foreach(fun(ItemId)->player_pack:add_item(notify, ?st_game_settle, ItemId) end,PickUpItems),

    %%[FinalItemInfo|PickUpItemInfos]=case FinalItem of
    %%					0->[0|giveout_items(PickUpItems)];
    %%					_->giveout_items([FinalItem|PickUpItems])
    %%				    end,

    player_role:notify_role_info(CurRole),
	{FinalItem, RatioList} = deal_final_item(Score, CopyId, RoleId),
	io_helper:format("PickUpItems:~p~n", [PickUpItems]),
	giveout_items(PickUpItems),
    game_log:write_game_log(Result,?common,RoleId,GameId,Life,MaxLife,CostRound,PickUpItems,Score,FinalItem,Operations,get_mapinfo(),Gold),
    packet:send(#notify_game_settle{result=?game_win, score=Score,final_item=FinalItem,ratio_items=RatioList}),
    %%clear_mapinfo(),
    Score.
%%--------------------------------------------------------------------
%% @doc
%% @通关副本后进行战斗结算:更新金币，体力，经验
%% update_gold_power_exp(RoleId::int64,CopyId::int)
%% @end
%%--------------------------------------------------------------------
update_gold_exp(RoleId, CopyId, ExtraGold) ->
    %%[Role | _] = db:find(db_role, [{role_id, 'equals', RoleId}]),
    Role = player_role:get_db_role(RoleId),
    CopyInfo = game_copy:get_copy_info(CopyId),
    {ok, NewRole} = player_role:add_exp(Role, CopyInfo#copy_tplt.exp),
    player_role:add_gold(?st_game_settle, CopyInfo#copy_tplt.gold + ExtraGold),       %%加金币
    Gold = CopyInfo#copy_tplt.gold + Role:gold() + ExtraGold,
    CurRole = NewRole:set(gold, Gold),
    CurRole.

update_gold_power_exp(RoleId,CopyId,ExtraGold)->
    Role=player_role:get_db_role(RoleId),%%db:find(db_role,[{role_id,'equals',RoleId}]),
    CopyInfo=game_copy:get_copy_info(CopyId),
    NewPower=power_hp:cost_hp(cost,RoleId,CopyInfo#copy_tplt.win_need_power),%%扣体力
    %%NewExp=CopyInfo#copy_tplt.exp+Role:exp(),                           %%更新经验和等级
    %%NewLevel=player_role:get_level_by_exp(Role:level(),NewExp),
    io_helper:format("activity_multi_output:~p~n", [activity_multi_output:get_exp_multi_num()]),
    {ok, NewRole} = player_role:add_exp(Role, trunc(CopyInfo#copy_tplt.exp * activity_multi_output:get_exp_multi_num())),
    %%NewRole=Role:set([{level,NewLevel},{exp,NewExp}]),
    %%NewRole:save(),
    player_role:add_gold(?st_game_settle,CopyInfo#copy_tplt.gold+ExtraGold),       %%加金币
    Gold=CopyInfo#copy_tplt.gold+Role:gold()+ExtraGold,
    CurRole=NewRole:set(gold,Gold),
    {NewPower,CurRole}.

update_gold_power_exp(RoleId,CopyId,ExtraGold,ExtraExp)->
    Role=player_role:get_db_role(RoleId),%%db:find(db_role,[{role_id,'equals',RoleId}]),
    CopyInfo=game_copy:get_copy_info(CopyId),
    NewPower=power_hp:cost_hp(cost,RoleId,CopyInfo#copy_tplt.need_power),%%扣体力
    %%NewExp=CopyInfo#copy_tplt.exp+Role:exp(),                           %%更新经验和等级
    %%NewLevel=player_role:get_level_by_exp(Role:level(),NewExp),
    {ok, NewRole} = player_role:add_exp(Role, CopyInfo#copy_tplt.exp + ExtraExp),
    %%NewRole=Role:set([{level,NewLevel},{exp,NewExp}]),
    %%NewRole:save(),
    player_role:add_gold(?st_game_settle,CopyInfo#copy_tplt.gold+ExtraGold),       %%加金币
    Gold=CopyInfo#copy_tplt.gold+Role:gold()+ExtraGold,
    CurRole=NewRole:set(gold,Gold),
    {NewPower,CurRole}.

update_clean_up_gold_power_exp(RoleID, CopyID, Gold, Exp, Count) ->
    Role = player_role:get_db_role(RoleID),
    CopyInfo = game_copy:get_copy_info(CopyID),
    NewPower = power_hp:cost_hp(cost, RoleID, (CopyInfo#copy_tplt.need_power + CopyInfo#copy_tplt.win_need_power) * Count),%%扣体力
    {ok, NewRole} = player_role:add_exp(Role, Exp),
    player_role:add_gold(?st_game_settle, Gold),       %%加金币
    FinalGold = Role:gold() + Gold,
    CurRole = NewRole:set(gold, FinalGold),
    {NewPower, CurRole}.
%%--------------------------------------------------------------------
%% @doc
%% @通关副本后进行战斗结算:获取通关分数
%% update_gold_power_exp(RoleId::int64,CopyId::int)
%% @end
%%--------------------------------------------------------------------
get_game_score(CopyId, CostRound, Life, MaxLife)->
    #copy_tplt{min_life_percent = MinLife, min_cost_round = MinRound} = game_copy:get_copy_info(CopyId),
    
    LifeSocre=case Life*100 >= MaxLife*MinLife of
		 true->
		     1;
		 _ ->
		     0
	     end,
    Score=case CostRound =< MinRound of
	      true->
		  2 + LifeSocre;
	      false ->
		  1 + LifeSocre
	  end,
    
    Score.
%%--------------------------------------------------------------------
%% @doc
%% @通关副本后进行战斗结算:生成对应的奖励
%% update_gold_power_exp(RoleId::int64,CopyId::int)
%% @end
%%--------------------------------------------------------------------
deal_final_item(Score, CopyId, RoleID) ->
  if
    Score =:= 3 ->
      {FinalItem, FinalItem2, RatioList} = game_copy:get_copy_award(CopyId),
      AwardID = game_copy:get_copy_award_id(CopyId),
      cache:set(copy_lottery_info, RoleID, {FinalItem, FinalItem2, RatioList, AwardID}),
      giveout_lottery_item(FinalItem),
      {FinalItem, RatioList};
    true ->
      {#lottery_item{}, []}
  end.

%%--------------------------------------------------------------------
%% @doc
%% @通关副本后进行战斗结算:发放物品
%% update_gold_power_exp(RoleId::int64,CopyId::int)
%% @end
%%--------------------------------------------------------------------
giveout_lottery_item(Item) ->
    #lottery_item{reward_id= RewardID, amount= Amount} = Item,
    SourceType = ?st_game_settle,
	reward:give([RewardID], [Amount], SourceType),
    ok.

giveout_items(GrandItems, Type) ->
    IDs = lists:map(
	    fun(X) ->
		    X#mons_item.id
	    end, GrandItems),
    Amounts = lists:map(
		fun(X) ->
			X#mons_item.amount
		end, GrandItems),
    reward:merge2give(IDs, Amounts, Type).

giveout_items(GrandItems) ->
    giveout_items(GrandItems, ?st_game_settle).

%%giveout_items(GrantItems)->
%%    {ItemList,EquipmentList}=lists:foldl(fun giveout_item/2,{[],[]},GrantItems),
%%    equipment:append_equipment_infos(EquipmentList),
%%    lists:reverse(ItemList).

%%giveout_item(ItemId,{ItemList,EquipmentList})->
%%    Item=player_pack:add_item(notify, ?st_game_settle, ItemId),
%%    NewList=case item:get_type(ItemId)of
%%		?equipment->
%%		    Equipment=equipment:create_equipment_and_save(ItemId,Item:inst_id()),
%%		    EquipmentInfo=#equipmentinfo{equipment_id=Equipment:equipment_id(),strengthen_level=Equipment:level(),
%%						 gem_extra=Equipment:addition_gem(),attr_ids=Equipment:attach_info()},
%%		    {[#equip_extra_info{temp_id=ItemId,level=0,addition_gem=Equipment:addition_gem(),attach_info=Equipment:attach_info()}|ItemList],
%%		     [EquipmentInfo|EquipmentList]};
%%		_ ->{[ItemId|ItemList],EquipmentList}
%%	    end,
%%    NewList.


process_clean_up_copy(CopyId)->
    %%RoleId = player:get_role_id(),
    #copy_tplt{gold= G, exp = E} = game_copy:get_copy_info(CopyId),
    {_GameId,AllMap}=game_copy:get_clean_up_game_info(CopyId),
    {PickUpItems,Gold} = game_validation:get_items_and_gold(AllMap),
    KillMonsters = get_all_monsters(AllMap),
    {FinalItem, _, _} = game_copy:get_copy_award(CopyId),
    {NG, NE, NI} = update_gain_by_finalitem(Gold + G, E, PickUpItems, FinalItem),
    event_router:send_event_msg(#event_game_copy{copy_id = CopyId, monsterids = KillMonsters}),
%%     {_NewPower,CurRole}=update_gold_power_exp(RoleId, CopyId, NG - G, NE - E),
%%     giveout_items(NI),
%%    game_copy:update_pass_copy(CopyId,{?game_win,Score}),
%%    game_log:write_game_info(?game_win,?copy_clean_up, GameId, CopyId, RoleId, Score,NI, NG, 0),
%%     player_role:notify_role_info(CurRole),
    %%activeness_task:update_activeness_task_status(clean_up),
    {NG, NE, NI}.


update_gain_by_finalitem(Gold, Exp, Items, FinalItem)->
    #lottery_item{reward_id= RewardID, amount= Amount} = FinalItem,
	{Gold, Exp, [#mons_item{id = RewardID, amount = Amount} | Items]}.
get_all_monsters(Maps) ->
    case Maps of
	[] ->
	    [];
	[#game_map{monster=Monsters, boss = BossMonsters}|Left] ->
	    [Id||#smonster{monsterid = Id} <- (Monsters ++ BossMonsters)] ++ get_all_monsters(Left)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @循环多次扫荡
%% @end
%%--------------------------------------------------------------------
circle_clean_up(_CopyId, 0, TrophyContainer, TotalTrophy) ->
    {TrophyContainer, TotalTrophy};
circle_clean_up(CopyId, Count, TrophyContainer, {TotalGold, TotalExp, TrophyItems}) ->
                    {Gold, Exp, Items} = process_clean_up_copy(CopyId),
                    circle_clean_up(CopyId, Count - 1, [#clean_up_trophy{item = Items, gold = Gold, exp = Exp} | TrophyContainer],
                                    {TotalGold + Gold, TotalExp + Exp, TrophyItems ++ Items}).



    
%%获取复活需要的代币数量
get_reborn_need(Times) ->
    Fun = (tplt:get_data(expression_tplt, 14))#expression_tplt.expression,
    Fun([{'Times', Times}]).
	      
    


    

    
    
    




