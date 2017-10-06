-module(push_tower).

-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-export([is_push_tower_enable/2,get_can_play_copy/1,to_first_map/1,to_next_map/5]).

-export([clear_cur_map_info/0,get_push_tower_pass_award/1,buy_push_tower_round/0,buy_push_tower_playtimes/0,
	 get_push_max_tower_times/1,get_play_times_today/0,get_max_floor/0]).
-compile(export_all).


%%--------------------------------------------------------------------
%% @doc
%% @�жϽ�������Ƿ�������
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
%% @��ȡ���ͨ��
%% @end
%%--------------------------------------------------------------------
get_max_floor()->
    PushTower = get_role_push_tower_info(),
    PushTower:max_floor().

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�����������
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
%% @��ȡÿ��������
%% @end
%%--------------------------------------------------------------------
get_push_max_tower_times(_RoleId)->
    Org=config:get(push_tower_times),
    Org + get_push_tower_buy_times().
%%--------------------------------------------------------------------
%% @doc
%% @�ж��Ƿ�ɽ���
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
%% @�ײ�
%% @end
%%--------------------------------------------------------------------
to_first_map(CopyId)->
    GameId = uuid:gen(),
    Copy = tplt:get_data(push_tower_copy, CopyId),
    MapId = Copy#push_tower_copy.first_map_id,
    put(cur_copy_id, CopyId),
    %%set_cur_map_info(MapId, 1),
    Info = get_push_tower_map_info(1,MapId),
    set_cur_map_info({GameId, MapId, 1, 300, [], 0, 0}, Info),
    {GameId,Info}.



buy_push_tower_round()->
    case get_cur_map_info() of
	{{GameId, CurMap, Times, RoundLeft, OrgItems, TotalFloors, BuyRoundTimes}, PreMap} ->
	    case BuyRoundTimes of
		0 ->
		    Cost = config:get(push_tower_emoney_buy_round),
		    Round = config:get(push_tower_buy_round_amount),
		    case player_role:check_emoney_enough(Cost) of
			true ->
			    player_role:reduce_emoney(?st_push_tower_buy_round,Cost),
			    set_cur_map_info({GameId, CurMap, Times, RoundLeft+Round , OrgItems, TotalFloors, 1}, PreMap),
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
    Cost = get_buy_push_tower_need_emoney(BuyTimes),%%trunc(3*math:pow(2,(BuyTimes+1))),
    case player_role:check_emoney_enough(Cost) of
	true ->
	    increase_push_tower_buy_times(),
	    player_role:reduce_emoney(?st_push_tower_buy_playtimes,Cost),
	    ?common_success;
	false ->
	    ?common_failed
    end.

%%--------------------------------------------------------------------
%% @doc
%% @ÿ��Ĺ���ĳ��Դ���
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
%% @��һ��
%% @end
%%--------------------------------------------------------------------
to_next_map(CGameId, CostRound, Items, Life, Result) ->
    case get_cur_map_info() of
	{{GameId, CurMap, Times, RoundLeft, OrgItems, TotalFloors, BuyTimes}, PreMap} ->
	    case is_req_legal(CGameId,CostRound,Items,{GameId, PreMap, Times, RoundLeft}, Result) of
		true ->
		    case is_push_tower_over(RoundLeft, CostRound, Life, Result) of
			{true, RRRR} ->
			    activeness_task:update_activeness_task_status(push_tower),
			    process_push_tower_settle({GameId, CurMap, Times, RoundLeft, OrgItems++Items, TotalFloors, Life}),
			    cache_with_expire:increase(push_tower_play_times,player:get_role_id(),day),
			    clear_cur_map_info(),
			    {RRRR, [#game_map{}],[]};
			false ->
			    Map = tplt:get_data(push_tower_map, CurMap),
			    case Map#push_tower_map.repeat_times > Times of
				true ->
				    {GemList,BaseGold,BaseExp} = get_awards_of_push_tower_per_map(CurMap),
				    Info = get_push_tower_map_info(PreMap#game_map.key,CurMap),
				    set_cur_map_info({GameId, CurMap, Times+1, RoundLeft-CostRound, Items++OrgItems++GemList, 
						      TotalFloors+1, BuyTimes}, Info),
				    {?map_settle_next_map,[Info],make_award_list(GemList),BaseGold,BaseExp};
				false ->
				    case Map#push_tower_map.next_map of
					0 ->
					    {?map_settle_error, [#game_map{}],[]};
					NewMap ->
					    {GemList,BaseGold,BaseExp} = get_awards_of_push_tower_per_map(CurMap),
					    ExtraGold = get_push_tower_pass_gold(CurMap),
					    NInfo = get_push_tower_map_info(PreMap#game_map.key,NewMap),
					    Award = get_push_tower_pass_award(CurMap),
					    set_cur_map_info({GameId, NewMap, 1, RoundLeft-CostRound, Award ++ Items ++ OrgItems,
							      TotalFloors+1, BuyTimes}, NInfo),
					    {?map_settle_next_map, [NInfo], make_award_list(Award++GemList),BaseGold + ExtraGold, BaseExp}
				    end
			    end
		    end;
		false ->
		    clear_cur_map_info(),
		    
		    {?map_settle_error, [#game_map{}],[]}
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_push_tower_settle_gameinfo_not_exist,[]),
	    {?map_settle_error, [#game_map{}],[]}
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
get_awards_of_push_tower_per_map(CurMap)->
    {BaseGemAmount,RandList} = get_pass_gem_award_amount(CurMap),
    BaseGemList = rand:rand_members_from_list(RandList, BaseGemAmount),
    %%CopyInfo = tplt:get_data(push_tower_copy,CurMap div 100),
    CopyInfo = tplt:get_data(push_tower_copy, get_copyid()),
    BaseGold = CopyInfo#push_tower_copy.base_gold,
    BaseExp = CopyInfo#push_tower_copy.base_exp,
    {BaseGemList,BaseGold,BaseExp}.
%%--------------------------------------------------------------------
%% @doc
%% @��������
%% @end
%%--------------------------------------------------------------------
process_push_tower_settle(GameInfo)->
    {GameId, CurMap, _Times, _RoundLeft, AllItems, TotalFloors, Life} = GameInfo,
    {PassTimes,DieTimes,Result} = case Life > 0 of
			       true ->
				   {1,0,1};
			       false ->
				   {0,1,2}
			   end,
    PushTowerInfo = get_role_push_tower_info(),
    MaxFloor = case TotalFloors > PushTowerInfo:max_floor() of
		   true ->
		       TotalFloors;
		   false ->
		       PushTowerInfo:max_floor()
	       end,
    NewInfo = PushTowerInfo:set([{pass_times,PushTowerInfo:pass_times()+PassTimes},{die_times,PushTowerInfo:die_times()+DieTimes},
				{try_times,PushTowerInfo:try_times()+1},{max_floor,MaxFloor},{last_try_time,datetime:local_time()}]),
    %%{BaseGemAmount,RandList} = get_pass_gem_award_amount(CurMap),
    %%BaseGemList = rand:rand_members_from_list(RandList, BaseGemAmount*TotalFloors),
    giveout_items(AllItems),%% ++ BaseGemList),
    RoleId = player:get_role_id(),
    Gold = update_gold_and_exp(CurMap, TotalFloors, RoleId),
    NewInfo:save(),
    %%Result 1��ʾ�غ����꣬2��ʾ����
    game_log:write_only_game_info(Result,?push_tower,GameId,get_copyid(),player:get_role_id(),TotalFloors,AllItems,Gold),%% ++ BaseGemList,Gold),
    Gold.


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
    get(cur_copy_id).


get_role_push_tower_info()->
    case db:find(db_push_tower,[{role_id, 'equals', player:get_role_id()}]) of
	[] ->
	    db_push_tower:new(id,player:get_role_id(),0,0,0,0,datetime:local_time(),datetime:local_time());
	[Info] ->
	    Info
    end.
%%--------------------------------------------------------------------
%% @doc
%% @��ȡ������ʯ����������
%% @end
%%--------------------------------------------------------------------
get_pass_gem_award_amount(_CurMap)->
    CopyInfo = tplt:get_data(push_tower_copy,get_copyid()),
    {CopyInfo#push_tower_copy.base_gem_count,CopyInfo#push_tower_copy.gem_list}.
%%--------------------------------------------------------------------
%% @doc
%% @���½�Һ;���
%% @end
%%--------------------------------------------------------------------
update_gold_and_exp(_CurMap, TotalFloors, RoleId)->
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    CopyInfo = tplt:get_data(push_tower_copy, get_copyid()),
    %%CopyInfo = tplt:get_data(push_tower_copy,CurMap div 100),
    BaseGold = CopyInfo#push_tower_copy.base_gold,
    BaseExp = CopyInfo#push_tower_copy.base_exp,
    TotalGold = BaseGold * TotalFloors + get_extra_gold(TotalFloors),
    TotalExp = BaseExp * TotalFloors,
    {ok,NewRole} = player_role:add_exp(Role, TotalExp),
    %% NewExp=TotalExp+Role:exp(),                           %%���¾���͵ȼ�
    %% NewLevel=player_role:get_level_by_exp(Role:level(),NewExp),
    %% NewRole=Role:set([{level,NewLevel},{exp,NewExp}]),
    %% NewRole:save(),
    player_role:add_gold(?st_push_tower_settle,TotalGold),       %%�ӽ��
    Gold=TotalGold+Role:gold(),
    CurRole=NewRole:set(gold,Gold),
    player_role:notify_role_info(CurRole),
    TotalGold.
%%--------------------------------------------------------------------
%% @doc
%% @�ַ���Ʒ
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
%% @�����Ƿ����
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
    %% case CostRound >= RoundLeft of
    %% 	true ->
    %% 	    true;
    %% 	_ ->
    %% 	    case Life > 0 of
    %% 		true ->
    %% 		    false;
    %% 		false ->
    %% 		    true
    %% 	    end
    %% end.
%%--------------------------------------------------------------------
%% @doc
%% @�ж������Ƿ�Ϸ�
%% @end
%%--------------------------------------------------------------------
is_req_legal(CGameId, CostRound, Items, GameInfo, Result)->
    {GameId, CurMap, _Times, RoundLeft } = GameInfo,
    case CGameId of
	GameId ->
	    DropOut = lists:map(fun(X)->
					X#smonster.dropout
				end,CurMap#game_map.monster),
	    case  length(DropOut--Items)+length(Items) =:= length(DropOut) of
		false ->
		    sys_msg:send_to_self(?sg_push_tower_settle_items_not_right,[]),
		    false;
		true ->
		    case Result == ?map_settle_finish of
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
		    end
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_push_tower_settle_gameid_not_match,[]),
	    false
    end.
%%--------------------------------------------------------------------
%% @doc
%% @·������
%% @end
%%--------------------------------------------------------------------
get_way_length(Pos1,StartPos1)->
    Pos = Pos1 - 1,
    StartPos = StartPos1 - 1,
    abs((Pos div 5)-(StartPos div 5)) + abs((Pos rem 5)-(StartPos rem 5)).
    %% Distance=case Pos-StartPos of
    %% 		 Dis when Dis < 0 ->
    %% 		     StartPos-Pos;
    %% 		 Disu  ->Disu
    %% 	     end,
    %% (Distance div 5) + (Distance rem 5).

get_push_tower_map_info(_StartPos,MapId)->
    Map = tplt:get_data(push_tower_map,MapId),
    Mostters = get_monsters(Map),
    [Scene] = rand:rand_members_from_list(Map#push_tower_map.scene,1),
    %%Scene = lists:nth(rand:uniform(length(Map#push_tower_map.scene)),Map#push_tower_map.scene),
    Traps = get_traps(Map),
    Friends = get_friends(Map),
    Awards = get_awards(Map),
    create_push_tower_map(Map#push_tower_map.key_monster,Mostters,Traps,Friends,Awards,Scene,Map#push_tower_map.barrier_amount).

create_push_tower_map(KeyMonster,Mostters,Traps,Friends,Awards,Scene,Barriers)->
    game_copy:create_push_tower(KeyMonster,Mostters,Traps,Friends,Awards,Scene,Barriers).
%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�����б�
%% @end
%%--------------------------------------------------------------------
get_monsters(Map)->
    Min = Map#push_tower_map.monster_min,
    Max = Map#push_tower_map.monster_max,
    MonsterIds = Map#push_tower_map.monsters,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(MonsterIds, Count).
    %%rand_monsters(MonsterIds,Count).

%% rand_monsters(MonsterIds, Count)->
%%     case Count of
%% 	0 ->
%% 	    [];
%% 	_ ->
%% 	    Monster = lists:nth(rand:uniform(length(MonsterIds)),MonsterIds),
%% 	    [Monster|rand_monsters(MonsterIds--[Monster], Count-1)]
%%     end.
%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�����б�
%% @end
%%--------------------------------------------------------------------
get_traps(Map)->
    Min = Map#push_tower_map.trap_min,
    Max = Map#push_tower_map.trap_max,
    TrapIds = Map#push_tower_map.traps,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(TrapIds, Count).
    %%rand_traps(TrapIds,Count).

%% rand_traps(TrapIds, Count)->
%%     case Count of
%% 	0 ->
%% 	    [];
%% 	_ ->
%% 	    Trap = lists:nth(rand:uniform(length(TrapIds)),TrapIds),
%% 	    [Trap|rand_traps(TrapIds--[Trap], Count-1)]
%%     end.
%%--------------------------------------------------------------------
%% @doc
%% @��ȡ����ID�б�
%% @end
%%--------------------------------------------------------------------
get_friends(Map)->
    Min = Map#push_tower_map.friend_min,
    Max = Map#push_tower_map.friend_max,
    FriendIds = Map#push_tower_map.friends,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(FriendIds, Count).
    %%rand_friends(FriendIds,Count).

%% rand_friends(FriendIds, Count)->
%%     case Count of
%% 	0 ->
%% 	    []; 
%% 	_ ->
%% 	    Friend = lists:nth(rand:uniform(length(FriendIds)),FriendIds),
%% 	    [Friend|rand_friends(FriendIds--[Friend], Count-1)]
%%     end.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�����¼��б�
%% @end
%%--------------------------------------------------------------------
get_awards(Map)->
    Min = Map#push_tower_map.trap_min,
    Max = Map#push_tower_map.trap_max,
    AwardIds = Map#push_tower_map.traps,
    Count = Min + rand:uniform(Max-Min+1) - 1,
    rand:rand_members_from_list(AwardIds, Count).
    %%rand_awards(AwardIds,Count).

%% rand_awards(AwardIds, Count)->
%%     case Count of
%% 	0 ->
%% 	    [];
%% 	_ ->
%% 	    Award = lists:nth(rand:uniform(length(AwardIds)),AwardIds),
%% 	    [Award|rand_awards(AwardIds--[Award], Count-1)]
%%     end.


%%--------------------------------------------------------------------
%% @doc
%% @�����ȡ��ձ�����Ϣ
%% @end
%%--------------------------------------------------------------------
set_cur_map_info(ExtraInfo, Info)->
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
%% @��ȡ���㽱��
%% @end
%%--------------------------------------------------------------------
get_push_tower_pass_award(MapId)->
    MapInfo = tplt:get_data(push_tower_map, MapId),
    case MapInfo#push_tower_map.award of
	0 ->
	    [];
	AwardId ->
	    NRand = rand:uniform(10000),
	    AwardInfo = tplt:get_data(push_tower_award,AwardId),
	    Award = get_gem_award(NRand, AwardInfo, 1),
	    [Award]
    end.

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



%% get_pre_map_info()->
%%     cache:get(map_information,player:get_role_id()).


%% set_pre_map_info(Info)->
%%     cache:set(map_information,player:get_role_id(),Info).

%% clear_pre_map_info()->
%%     cache:delete(map_information,player:get_role_id()).


