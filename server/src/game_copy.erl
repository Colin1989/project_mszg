
-module(game_copy).
-include("tplt_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").

-export([update_pass_copy/2,update_pass_copy/3,update_try_copy/1,query_all_pass_copy/0,query_all_pass_copy/1,
	get_gameinfo/1,get_need_power/1,get_copy_info/1,get_copy_monster_amount/1,get_copy_award/1,get_copy_award_id/1,
	query_all_pass_copy_information/0,query_all_pass_copy_information/1,is_copy_unlock/1,is_copy_unlock/2,is_copy_max_score/1,
  get_need_stone/1, get_type/1,get_need_level/1, get_func_unlock_need_copy_id/1,check_copy_has_passed/1,check_func_unlock/1,
  get_clean_up_rewards/1]).

-export([create_push_tower/7,create_ranking_copy/7,get_disable_pos/1,get_next_key/1,get_activity_copy_game_info/1]).

-compile(export_all).


%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ��ǰ����������Ʒ
%% get_copy_info(GameId::int)->CopyInfo#copy_tplt{}.
%% @end
%%--------------------------------------------------------------------


get_copy_award(GameId)->
    GameCopy=tplt:get_data(copy_tplt,GameId),
    get_award(GameCopy#copy_tplt.award).

get_award(AwardId)->
    AwardInfo=tplt:get_data(game_award,AwardId),

    IdList1 = AwardInfo#game_award.id_list1,
    AmountList1 = AwardInfo#game_award.amount_list1,
    Item1 = gen_award(IdList1, AmountList1),
    Ratio1 = AwardInfo#game_award.list1_ratio,

    IdList2 = AwardInfo#game_award.id_list2,
    AmountList2 = AwardInfo#game_award.amount_list2,
    Item2 = gen_award(IdList2, AmountList2),
    Ratio2 = AwardInfo#game_award.list2_ratio,

    IdList3 = AwardInfo#game_award.id_list3,
    AmountList3 = AwardInfo#game_award.amount_list3,
    Item3 = gen_award(IdList3, AmountList3),
    Ratio3 = AwardInfo#game_award.list3_ratio,

    RatioList = [Ratio1, Ratio2, Ratio3],
    ItemList = [Item1, Item2, Item3],
    {FinalItem1, Ratio} = get_final_item(rand:uniform(100), RatioList, ItemList),
    ReamainRate = 100 - Ratio,
    RemainRatioList = RatioList -- [Ratio],
    ReaminItemList = ItemList -- [FinalItem1],
    {FinalItem2, _} = get_final_item(rand:uniform(ReamainRate), RemainRatioList, ReaminItemList),
    {FinalItem1, FinalItem2, [Item1, Item2, Item3]}.

%% gen_award(ItemList, GoldList, ExpList) ->
%%   Type = rand:uniform(3),
%%   case Type of
%%     ?lottery_item ->
%%       Item = lists:nth(rand:uniform(length(ItemList)), ItemList),
%%       #lottery_item{type = ?lottery_item, item_info = Item};
%%     ?lottery_gold ->
%%       Gold = lists:nth(rand:uniform(length(GoldList)), GoldList),
%%       #lottery_item{type = ?lottery_gold, item_info = Gold};
%%     ?lottery_exp ->
%%       Exp = lists:nth(rand:uniform(length(ExpList)), ExpList),
%%       #lottery_item{type = ?lottery_exp, item_info = Exp}
%%   end.

gen_award(IdList, AmountList) ->
    Index = rand:uniform(length(IdList)),
    RewardID = lists:nth(Index, IdList),
    Amount = lists:nth(Index, AmountList),
	#lottery_item{reward_id = RewardID, amount = Amount}.

%% transform_to_lottery_item(RewardID, Amount) ->
%%     RewardType = reward:get_item_tplt_type(RewardID),
%%     Type = reward_type_to_lottery_type(RewardType),
%%     case Type of
%% 	?lottery_item ->
%% 	    TempID = reward:get_item_tplt_temp_id(RewardID),
%% 	    #lottery_item{type = ?lottery_item, item_info = TempID};
%% 	?lottery_gold ->
%% 	    #lottery_item{type = ?lottery_gold, item_info = Amount};
%% 	?lottery_exp ->
%% 	    #lottery_item{type = ?lottery_exp, item_info = Amount}
%%     end.

%% reward_type_to_lottery_type(RewardType) ->
%%     case RewardType of
%% 	1 ->
%% 	    ?lottery_gold;
%% 	2 ->
%% 	    ?lottery_exp;
%% 	7 ->
%% 	    ?lottery_item
%%     end.

get_final_item(RandResult, [Ratio | RatioList], [Item | ItemList])->
    case RandResult =< Ratio of
	true->
	    {Item, Ratio};
	false ->
	    get_final_item(RandResult-Ratio,RatioList,ItemList)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec�жϸ����Ƿ����
%% @end
%%--------------------------------------------------------------------
is_copy_unlock(CopyId)->
    RoleId=player:get_role_id(),
    is_copy_unlock(CopyId,RoleId).

is_copy_unlock(CopyId, _RoleId) ->
    CopyInfo = get_copy_info(CopyId),
    check_copys_pass(CopyInfo#copy_tplt.pre_copy).
    %% case CopyInfo#copy_tplt.pre_copy of
    %% 	[] -> true;
    %% 	PreCopy -> %% ��������ǰ�ø���δ����
    %% 	    PassList = db:find(db_copy, [{role_id, 'equals', RoleId}, {copy_id, 'in', PreCopy}, {pass_times, 'gt', 0}]),
    %% 	    length(PassList) =:= length(PreCopy)
    %% end.

is_copy_max_score(CopyId)->
    case get_copy_by_copyid(CopyId) of
	undefined ->
	    false;
	CopyInfo ->
	    CopyInfo:max_score() =:= 3
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ���븱�������ٻ�ʯ
%% @end
%%--------------------------------------------------------------------
get_need_stone(CopyID) ->
  CopyInfo = get_copy_info(CopyID),
  CopyInfo#copy_tplt.need_stone.

%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ���븱�������ٻ�ʯ
%% @end
%%--------------------------------------------------------------------
get_type(CopyID) ->
  CopyInfo = get_copy_info(CopyID),
  CopyInfo#copy_tplt.type.

%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ���븱������ȼ�
%% @end
%%--------------------------------------------------------------------
get_need_level(CopyID) ->
	CopyInfo = get_copy_info(CopyID),
	CopyInfo#copy_tplt.need_level.

%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ��ǰ������Ϣ
%% get_copy_info(GameId::int)->CopyInfo#copy_tplt{}.
%% @end
%%--------------------------------------------------------------------
get_copy_info(GameId)->
    tplt:get_data(copy_tplt,GameId).

get_copy_award_id(GameId)->
    CopyInfo = get_copy_info(GameId),
    CopyInfo#copy_tplt.award.


%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡʤ������������
%% @end
%%--------------------------------------------------------------------
get_win_need_power(CopyID) ->
    CopyInfo = get_copy_info(CopyID),
    CopyInfo#copy_tplt.win_need_power.

%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡɨ������
%% @end
%%--------------------------------------------------------------------
get_clean_up_rewards(CopyID) ->
    CopyInfo = get_copy_info(CopyID),
    IDs = CopyInfo#copy_tplt.clean_up_reward_ids,
    Amounts = CopyInfo#copy_tplt.clean_up_reward_amounts,
    {IDs, Amounts}.

%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ��ǰ������������
%% get_copy_info(GameId::int)->CopyInfo#copy_tplt{}.
%% @end
%%--------------------------------------------------------------------
get_copy_monster_amount(GameId)->
    GameCopy=tplt:get_data(copy_tplt,GameId),
    MapId=GameCopy#copy_tplt.first_map_id,
    get_map_monster_amount(MapId,0).

get_map_monster_amount(0,Count)->
    Count;
get_map_monster_amount(MapId,Count)->
    Map=tplt:get_data(game_map_tplt,MapId),
    NextMap=Map#game_map_tplt.next_map,
    MapMonsters=length(Map#game_map_tplt.monster),
    RuleId = Map#game_map_tplt.map_rule_id,
    NAmount = case RuleId of
		  0 ->
		      MapMonsters;
		  _ ->
		      Rule = tplt:get_data(game_map_rule_tplt, RuleId),
		      length(Rule#game_map_rule_tplt.monster)+MapMonsters
	      end,
    get_map_monster_amount(NextMap,Count+NAmount+1).


	
%%--------------------------------------------------------------------
%% @doc
%% @spec������ҽ��и�������Ϣ
%% update_pass_copy(RoleId::uint64,CopyId::int,{Result::atom,Score::int})
%% RoleId:���Id,CopyId:����ID,Result:ͨ�ؽ��,Score:����
%% @end
%%--------------------------------------------------------------------
update_try_copy(CopyId) ->
    CopyInfo=  case get_copy_by_copyid(CopyId) of
		   undefined->
		       db_copy:new(id,player:get_role_id(),CopyId,0,1,0,datetime:local_time(),datetime:local_time());

		   OrgCopyInfo ->
		       OrgCopyInfo:set([{try_times, OrgCopyInfo:try_times() + 1}])
	       end,
    copy_modify(CopyInfo).



update_pass_copy(CopyId,{Result,Score})->
    RoleId=player:get_role_id(),
    update_pass_copy(RoleId,CopyId,{Result,Score}).
update_pass_copy(CopyId, {Result, Score}, Times) ->
    CopyInfo=  case get_copy_by_copyid(CopyId) of%%case db:find(db_copy,[{role_id,'equals',RoleId},{copy_id,'equals',CopyId}]) of
		   undefined->
		       db_copy:new(id,player:get_role_id(),CopyId,0,0,0,datetime:local_time(),datetime:local_time());
                   OrgCopyInfo ->
		       OrgCopyInfo
		       %%db_copy:new(db:get_IntegerKey(CopyInfo:id()),CopyInfo:role_id(),CopyId,PassTimes,
		       %%TryTimes,MaxScore,CopyInfo:create_time(),datetime:local_time())
	       end,
    PassTimesOrg=CopyInfo:pass_times(),
    TryTimes=CopyInfo:try_times()+Times,
    PassTimes=case Result of
		  1->
		      PassTimesOrg + Times;
		  _ ->
		      PassTimesOrg
	      end,
    ScoreOrg=CopyInfo:max_score(),
    MaxScore=case ScoreOrg<Score of
		 true->
		     Score;
		 _ ->
		     ScoreOrg
	     end,
    NewCopyInfo=CopyInfo:set([{pass_times,PassTimes},{try_times,TryTimes},
		  {max_score,MaxScore},{last_past_time,datetime:local_time()}]),
    %%talent:unlock(CopyId,(CopyInfo:max_score() =:= 0) and (MaxScore =/= 0)), %%�츳����
    copy_modify(NewCopyInfo);
update_pass_copy(RoleId,CopyId,{Result,Score})->
    CopyInfo=  case get_copy_by_copyid(CopyId) of%%case db:find(db_copy,[{role_id,'equals',RoleId},{copy_id,'equals',CopyId}]) of
		   undefined->
		       db_copy:new(id,RoleId,CopyId,0,0,0,datetime:local_time(),datetime:local_time());

		   OrgCopyInfo ->
		       OrgCopyInfo
		       %%db_copy:new(db:get_IntegerKey(CopyInfo:id()),CopyInfo:role_id(),CopyId,PassTimes,
		       %%TryTimes,MaxScore,CopyInfo:create_time(),datetime:local_time())
	       end,
    PassTimesOrg=CopyInfo:pass_times(),
    %%TryTimes=CopyInfo:try_times()+1,
    PassTimes=case Result of
		  1->
		      PassTimesOrg+1;
		  _ ->
		      PassTimesOrg
	      end,
    ScoreOrg=CopyInfo:max_score(),
    MaxScore=case ScoreOrg<Score of
		 true->
		     Score;
		 _ ->
		     ScoreOrg
	     end,
    NewCopyInfo=CopyInfo:set([{pass_times,PassTimes},%%{try_times,TryTimes},
		  {max_score,MaxScore},{last_past_time,datetime:local_time()}]),
    %%io:format("~p~n",[NewCopyInfo]),
    %%NewCopyInfo:save().
    %%talent:unlock(CopyId,(CopyInfo:max_score() =:= 0) and (MaxScore =/= 0)), %%�츳����
    copy_modify(NewCopyInfo).
%%--------------------------------------------------------------------
%% @doc
%% @spec��ȡ������ͨ�ظ���Id
%% query_all_pass_copy(RoleId::uint64)->CopyIdList::List(int)
%% CopyIdList:������ͨ�ظ���Id
%% @end
%%--------------------------------------------------------------------
query_all_pass_copy()->
    RoleId=player:get_role_id(),
    query_all_pass_copy(RoleId).

query_all_pass_copy(_RoleId)->
    %%RoleIdStr=db:generate_key(db_role,RoleId),
    %%CopyList=db:find(db_copy,[{role_id,'equals',RoleId},{pass_times,'gt',0}]),
    CopyList = get_all_pass(),
    CopyIdList=lists:map(fun(A)->A:copy_id() end,CopyList),
    CopyIdList.

query_all_pass_copy_information()->
    RoleId=player:get_role_id(),
    query_all_pass_copy_information(RoleId).
query_all_pass_copy_information(_RoleId)->
    %%CopyList=db:find(db_copy,[{role_id,'equals',RoleId},{pass_times,'gt',0}]),
    CopyList = get_all_pass(),
    %%CopyIdList = lists:map(fun(X)-> X:copy_id() end, CopyList),
    PassTimes = [],%%cache_with_expire:get(cream_copy_, CopyIdList, RoleId),
    CopyInfoList=lists:map(fun(A)->#copy_info{copy_id=A:copy_id(),max_score=A:max_score(),pass_times=proplists:get_value(A:copy_id(), PassTimes, 0)} end,
			   CopyList),
    CopyInfoList.

%%--------------------------------------------------------------------
%% @doc
%% @ ���ؿ��Ѿ�ͨ��
%% @end
%%--------------------------------------------------------------------
check_copy_has_passed(CopyID) ->
    PassCopyList = query_all_pass_copy(),
    lists:any(fun(E) -> CopyID =:= E end, PassCopyList).


%%--------------------------------------------------------------------
%% @doc
%% @����
%% @end
%%--------------------------------------------------------------------
create_push_tower(KeyMonsters ,Mostters,Trap,Friend,Award,Scene,BarriesAmount)->
    DoorPos = rand:uniform(30),
    RandArray=initRandArray(30,[])--[DoorPos],
    KeyPos = lists:nth(rand:uniform(29),RandArray),
    KeyMonster = get_key_monster(KeyMonsters, KeyPos),
    NewRandArray=RandArray--[KeyPos],
    {Monsters,CurArray1}=create_monster(Mostters,KeyMonster,NewRandArray,[]),
    {Buffs,CurArray3}=create_award(Award,[],NewRandArray--CurArray1,CurArray1),
    {Traps,CurArray4}=create_trap(Trap,[],NewRandArray--CurArray3,CurArray3),
    {Friends,CurArray5}=create_friend_role(Friend,[],NewRandArray--CurArray4,CurArray4),
    BarriesAmount=case BarriesAmount>length(NewRandArray--CurArray5) of
		      true->
			  length(NewRandArray--CurArray5);
		      false ->
			  BarriesAmount
		  end,
    {Barriers,_CurArray2}=create_barriers(BarriesAmount,[],NewRandArray--CurArray5,CurArray5,[],DoorPos),
    CurMap=#game_map{monster=Monsters,start=DoorPos,key=KeyPos,barrier=Barriers,award=Buffs,trap=Traps,friend=Friends,scene=Scene},
    CurMap.

create_ranking_copy(Mostters,Trap,Friend,Award,Scene,BarriesAmount,Enemies)->
    StartPos = rand:uniform(30),
    RandArray=initRandArray(30,[])--[StartPos],
    {SelectedPosList, FixEnemies} = lists:foldl(
        fun(Enemy, {SelectedPos, CurList}) ->
            Pos = create_door(StartPos, 0, RandArray -- SelectedPos),
            NewEnemy = Enemy#senemy{pos = Pos},
            {[Pos | SelectedPos], [NewEnemy | CurList]}
        end,
        {[], []},
        Enemies),
    %%AgainstPlayer = create_door(StartPos,0,RandArray),
    %%AgainstPlayer = lists:nth(rand:uniform(29),RandArray),
    NewRandArray = RandArray--SelectedPosList,
    {Monsters,CurArray1}=create_monster(Mostters,[],NewRandArray,[]),
    {Buffs,CurArray3}=create_award(Award,[],NewRandArray--CurArray1,CurArray1),
    {Traps,CurArray4}=create_trap(Trap,[],NewRandArray--CurArray3,CurArray3),
    {Friends,CurArray5}=create_friend_role(Friend,[],NewRandArray--CurArray4,CurArray4),
    BarriesAmount=case BarriesAmount>length(NewRandArray--CurArray5) of
		      true->
			  length(NewRandArray--CurArray5);
		      false ->
			  BarriesAmount
		  end,
    {Barriers,_CurArray2}=create_barriers(BarriesAmount,[],NewRandArray--CurArray5,CurArray5,[],StartPos),
    CurMap=#game_map{monster=Monsters,start=StartPos,key=0,barrier=Barriers,award=Buffs,trap=Traps,friend=Friends,scene=Scene,
		     enemy = FixEnemies},
    CurMap.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�ؿ���Ϣ�����ɹؿ���ͼ
%% get_need_power(CopyId::int)->NeedPower::int
%% CopyId:����ID
%% @end
%%--------------------------------------------------------------------
get_need_power(CopyId)->
    GameCopy=tplt:get_data(copy_tplt,CopyId),
    GameCopy#copy_tplt.need_power.


%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�ؿ���Ϣ�����ɹؿ���ͼ
%% get_gameinfo(GameId::int)->GameInfo::#notify_enter_game{}
%% GameId:�ؿ�ID
%% @end
%%--------------------------------------------------------------------
get_activity_copy_game_info(CopyId) ->
    CopyInfo = tplt:get_data(activity_copy_tplt, CopyId),
    MapId = CopyInfo#activity_copy_tplt.first_map_id,
    AllMap = get_allmap(MapId, 1, []),
    {uuid:gen(), AllMap}.

get_gameinfo(GameId)->
    GameCopy=tplt:get_data(copy_tplt,GameId),
    MapId=GameCopy#copy_tplt.first_map_id,
    AllMap=get_allmap(MapId,1,[]),
    {uuid:gen(),AllMap}.

get_clean_up_game_info(CopyID) -> %% ��ȡ����ɨ����Ϣ
  GameCopy = tplt:get_data(copy_tplt, CopyID),
  MapId = GameCopy#copy_tplt.first_map_id,
  AllMap = get_clean_up_allmap(MapId, []),
  {uuid:gen(), AllMap}.

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�ؿ���ͼ
%% get_AllMap(MapId::int,StartPos::int,Maps::List(Map::#game_map{}))->Maps::List(Map::#game_map{})
%% MapId:��ͼID,StartPos:��ʼλ��,Maps:��ͼ�б�
%% @end
%%--------------------------------------------------------------------   
get_allmap(0,_StartPos,Maps)->
    NewMaps=lists:reverse(Maps),
    NewMaps;
get_allmap(MapId,_StartPos,Maps)->
    %%KeyPos = rand:uniform(30),
    MapInfo=tplt:get_data(game_map_tplt,MapId),
    NextMap=MapInfo#game_map_tplt.next_map,
    RandArray=initRandArray(30,[]),
    {Mons, Door, Bars, Awards, Arr, BossMonsters, BossRule}=get_pos_by_rule(MapInfo#game_map_tplt.map_rule_id),
    RA = RandArray -- Arr,
    DoorPos = case Door of
		  0 ->
		      lists:nth(rand:uniform(length(RA)), RA);
		  _ -> 
		      Door
	      end,
    NewRandArray = RA -- [DoorPos],
    {Monsters,CurArray1} = create_monster(MapInfo#game_map_tplt.monster, Mons, NewRandArray, []),
    
    {Buffs,CurArray3}=create_award(MapInfo#game_map_tplt.buff, Awards, NewRandArray--CurArray1,CurArray1),
    {Traps,CurArray4}=create_trap(MapInfo#game_map_tplt.trap,[],NewRandArray--CurArray3,CurArray3),
    {Friends,CurArray5}=create_friend_role(MapInfo#game_map_tplt.friend_role,[],NewRandArray--CurArray4,CurArray4),
    BarriesAmount=case MapInfo#game_map_tplt.barries_amount>length(NewRandArray--CurArray5) of
		      true->
			  length(NewRandArray--CurArray5);
		      false ->
			  MapInfo#game_map_tplt.barries_amount
		  end,
    {Barriers,_CurArray2}=create_barriers(BarriesAmount,Bars,NewRandArray--CurArray5,CurArray5,[],DoorPos),
    CurMap=#game_map{monster=Monsters, start=DoorPos, 
		     key=1,
		     barrier=Barriers,
		     award=Buffs,
		     trap=Traps,
		     friend=Friends,
		     scene = MapInfo#game_map_tplt.room,
		     boss = BossMonsters,
		     boss_rule = BossRule},

    get_allmap(NextMap, DoorPos, [CurMap|Maps]).


get_clean_up_allmap(0, Maps) ->
    NewMaps = lists:reverse(Maps),
    NewMaps;
get_clean_up_allmap(MapId, Maps) ->
    MapInfo = tplt:get_data(game_map_tplt, MapId),
    NextMap = MapInfo#game_map_tplt.next_map,

    %%���ɹ���
    KeyMonsterID = get_key_monster_id(MapInfo#game_map_tplt.key_monster),
    %%lists:nth(rand:uniform(length(MapInfo#game_map_tplt.key_monster)), MapInfo#game_map_tplt.key_monster),
    {RuleMonsterIDs, {Bosses, _}} = case MapInfo#game_map_tplt.map_rule_id of
			 0 ->
			     {[], {[], ok}};
			 _ ->
			     RuleInfo = tplt:get_data(game_map_rule_tplt, MapInfo#game_map_tplt.map_rule_id),
			     {RuleInfo#game_map_rule_tplt.monster, 
			      gen_boss_monsters(RuleInfo#game_map_rule_tplt.boss, RuleInfo#game_map_rule_tplt.boss_amount)}
		     end,
    RandMonsterIDs = MapInfo#game_map_tplt.monster,
    AllMonsterIDs = KeyMonsterID++RuleMonsterIDs++RandMonsterIDs,
    
    Monsters = lists:map(fun(X) -> monster:genetare_monster(X, 0) end, AllMonsterIDs),
    %%���ɽ�����Ʒ
    Buffs = lists:map(fun(X) -> #saward{pos = 0, awardid = X} end, MapInfo#game_map_tplt.buff),

    CurMap = #game_map{monster = Monsters, award = Buffs, boss = Bosses},

    get_clean_up_allmap(NextMap, [CurMap | Maps]).


get_key_monster_id([]) ->
    [];
get_key_monster_id(Ids) ->
    [lists:nth(rand:uniform(length(Ids)), Ids)].


get_key_monster([], _Pos)->
    [];
get_key_monster(RankList, Pos)->
    MonsterId = lists:nth(rand:uniform(length(RankList)), RankList),
    [monster:genetare_monster(MonsterId,Pos)].

%%--------------------------------------------------------------------
%% @doc
%% @��ȡ�Ų���ѡλ��
%% @end
%%--------------------------------------------------------------------  
get_disable_pos(NextMap)->
    case NextMap of
	0 ->
	    [];
	_ ->
	    MapInfo=tplt:get_data(game_map_tplt,NextMap),
	    get_all_select_pos(MapInfo#game_map_tplt.map_rule_id)
    end.



get_all_select_pos(Rule)->
    case Rule of
	0 -> 
	    [];
	_ ->
	    RuleInfo=tplt:get_data(game_map_rule_tplt,Rule),
	    RuleInfo#game_map_rule_tplt.monster_pos++RuleInfo#game_map_rule_tplt.barries_pos++[RuleInfo#game_map_rule_tplt.door]--[0]
    end.
%%--------------------------------------------------------------------
%% @doc
%% @��ȡ��һ��ͼDOOR
%% @end
%%--------------------------------------------------------------------  
get_next_key(NextMap)->
    case NextMap of
	0 ->
	    0;
	_ ->
	    MapInfo=tplt:get_data(game_map_tplt,NextMap),
	    get_key_pos(MapInfo#game_map_tplt.map_rule_id)
    end.

get_key_pos(Rule)->
    case Rule of
	0 -> 
	    0;
	_ ->
	    RuleInfo=tplt:get_data(game_map_rule_tplt,Rule),
	    RuleInfo#game_map_rule_tplt.door
    end.

%%--------------------------------------------------------------------
%% @doc
%% @ͨ�����õĹ������ɵ�ͼ��Ϣ
%% @end
%%-------------------------------------------------------------------- 
get_pos_by_rule(Rule) ->
    case Rule of
	0 ->
	    {[], 0, [], [],[], [], 0};
	_ ->
	    RuleInfo = tplt:get_data(game_map_rule_tplt, Rule),
	    {BossMonster, UsePos} = gen_boss_monsters(RuleInfo#game_map_rule_tplt.boss, RuleInfo#game_map_rule_tplt.boss_amount),
	    {[], Monsters} = lists:foldl(fun(X, {[Pos | PosList], MonsterList}) ->
						 {PosList, [monster:genetare_monster(X, Pos) | MonsterList]} end,
					 {RuleInfo#game_map_rule_tplt.monster_pos, []},
					 RuleInfo#game_map_rule_tplt.monster),
	    Awards = [#saward{pos=AwardPos,awardid=AwardId} || {AwardPos, AwardId} <- RuleInfo#game_map_rule_tplt.awards],
	    AwardPoss = [AwardPos || {AwardPos, _} <- RuleInfo#game_map_rule_tplt.awards],
	    Door = RuleInfo#game_map_rule_tplt.door,
	    {Monsters, Door, RuleInfo#game_map_rule_tplt.barries_pos, Awards,
	     RuleInfo#game_map_rule_tplt.monster_pos ++ RuleInfo#game_map_rule_tplt.barries_pos ++ AwardPoss ++ UsePos, 
	     BossMonster, gen_boss_rule(RuleInfo#game_map_rule_tplt.boss_rule)}
    end.

gen_boss_rule(Rules) ->
    case Rules of
	[] ->
	    0;
	_ ->
	   lists:nth(rand:uniform(length(Rules)), Rules)
    end.

gen_boss_monsters(Info, Amount) ->
    case rand:rand_members_from_list_not_repeat(Info, Amount) of
	[] ->
	    {[], []};
	Monsters ->
	    lists:foldl(fun gen_boss_monster/2, {[], []}, Monsters)
	    %% FirstLine = case (Pos + 4) div 5 of
	    %% 		    1 ->
	    %% 			1;
	    %% 		    6 ->
	    %% 			4;
	    %% 		    Line ->
	    %% 			Line - 1
	    %% 		end,
	    %% NewCols = case Pos rem 5 of
	    %% 		  1 ->
	    %% 		      2;
	    %% 		  5 ->
	    %% 		      4;
	    %% 		  Cols ->
	    %% 		      Cols
	    %% 	      end,
	    %% NewPos = FirstLine * 5 + NewCols,
	    %% {[monster:genetare_monster(BossId, NewPos)], lists:seq(FirstLine * 5 - 4, FirstLine * 5 + 10)}
    end.

gen_boss_monster({BossId, Pos}, {Monster, Dis}) ->
    DisablePos = lists:seq(Pos-7, Pos+7),%%[Pos, Pos + 1, Pos - 1, Pos - 5, Pos + 5, Pos - 4, Pos - 6, Pos + 4, Pos + 6],
    {[monster:genetare_monster(BossId, Pos)|Monster], DisablePos ++ Dis}.


%%--------------------------------------------------------------------
%% @doc
%% @��ʼ���������1~����������Ŀǰ��30
%% initRandArray(Count::int,Array::List(int))->NewArray::List(int)
%% Count:������,NewArray:Ŀ������
%% @end
%%--------------------------------------------------------------------   
initRandArray(0,Array)->
    Array;

initRandArray(Count,Array)->
    initRandArray(Count-1,[Count|Array]).

    
%%--------------------------------------------------------------------
%% @doc
%% @������
%% create_door(RandArray::List(int))->{Pos::int,NewRandArray::List(int)}
%% RandArray:�������������
%% @end
%%--------------------------------------------------------------------  
create_door(StartPos,0,RandArray)->
    List=lists:sort(fun(A, B) -> get_way_length(A,StartPos) >= get_way_length(B,StartPos) end, RandArray),
    NewList=lists:sublist(List,get_select_part_length(length(List))),
    Pos=lists:nth(rand:uniform(length(NewList)),NewList),
    Pos;
create_door(StartPos,NextDoor,RandArray)->
    List=lists:sort(fun(A, B) -> get_way_length(A,StartPos) >= get_way_length(B,StartPos) end, RandArray),
    NewList=lists:sublist(List,get_select_part_length(length(List))),
    List1=lists:sort(fun(A, B) -> get_way_length(A,NextDoor) >= get_way_length(B,NextDoor) end, NewList),
    NewList1=lists:sublist(List1,get_select_part_length(length(List1))),
    Pos=lists:nth(rand:uniform(length(NewList1)),NewList1),
    Pos.

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

get_select_part_length(Length)->
    case Length =< 3 of
	true -> Length;
	false  ->Length div 3
    end.	

%%--------------------------------------------------------------------
%% @doc
%% @���ɹ���
%% create_monster(MonsterIdArray,Monsters,RandArray::List(int),CurArray::list(int))->{NewMonsters::List(T::#smonster{}),NewRandArray::List(int)}
%% RandArray:�������������,MonsterIdArray:����Id�б�,Monsters:�����ɵĹ����б�,NewMonsters:��ͼ���й����б�,CurArray:�������λ��
%% @end
%%--------------------------------------------------------------------  
create_monster([],Monsters,_RandArray,CurArray)->
    {Monsters,CurArray};
create_monster([MosterId|MonsterIdArray],Monsters,RandArray,CurArray)->
    Pos=lists:nth(rand:uniform(length(RandArray)),RandArray),
    Monster=monster:genetare_monster(MosterId,Pos),
    create_monster(MonsterIdArray,[Monster|Monsters],RandArray--[Pos],[Pos|CurArray]).

%%--------------------------------------------------------------------
%% @doc
%% @�����ϰ�
%% create_barriers(Count::int,Array::List(int),RandArray::List(int),CurArray::list(int))->{NewArray::List(int),NewRandArray::List(int)}
%% RandArray:�������������,Count:�������ϰ���,Array:�������ϰ��б�,NewArray:��ͼ�ϰ��б�,CurArray:�������λ��
%% @end
%%--------------------------------------------------------------------
create_barriers(_,Array,[],CurArray,_Barriers,_StratPos)->
    %%PosBit=make_bit_of_pos(Barriers),
    %%{true,Side}=test_open_way(PosBit,0,StratPos),
    {Array,CurArray};
  
create_barriers(0,Array,_RandArray,CurArray,_Barriers,_StratPos)->
    %%PosBit=make_bit_of_pos(Barriers),
    %%{true,Side}=test_open_way(PosBit,0,StratPos),
    {Array,CurArray};

create_barriers(Count,Array,RandArray,CurArray,Barriers,StratPos) when Count>0 ->
    Pos=lists:nth(rand:uniform(length(RandArray)),RandArray),
    PosBit=make_bit_of_pos(Barriers),
    case test_open_way(PosBit,Pos,StratPos) of
	{true,_Side}->
	    create_barriers(Count-1,[Pos|Array],RandArray--[Pos],[Pos|CurArray],[Pos|Barriers],StratPos);
	false ->
	    create_barriers(Count,Array,RandArray--[Pos],CurArray,Barriers,StratPos)
    end.

%%--------------------------------------------------------------------
%% @doc
%% ���Ե�ͼ�Ƿ���ͨ
%% @end
%%--------------------------------------------------------------------  
test_open_way(PosBit,0,Door)->
    
    find_open_path(PosBit,[Door],bnot_process_integer( (1 bsl 31) bor (1 bor (1 bsl Door))));

test_open_way(PosBit,Pos,Door)->
    
    find_open_path(PosBit bor (1 bsl Pos),[Door],bnot_process_integer( (1 bsl 31) bor (1 bor (1 bsl Door)))).

    %test_open_way(PosBit,Pos),

%%--------------------------------------------------------------------
%% @doc
%% find_open_path(_PosBit,Sides,LeftPos)
%% PosBit:�ϰ���λ�õĶ����Ʊ���,Sides:�������Ľڵ��б�,ʣ��δ����ǵĽڵ��λ�õĶ����Ʊ���
%% @end
%%--------------------------------------------------------------------  
find_open_path(_PosBit,[Side|_Sides],0)->
    {true,Side};
find_open_path(_PosBit,[],_)->
    false;
find_open_path(PosBit,[Side|Sides],LeftPos)->
    %%�жϵ�ǰ�ڵ��Ƿ�Ϊ�ϰ��ڵ㣬�ǵĻ���������չ��0��ʾ����
    case PosBit band (1 bsl Side) of
	0 ->
	    %%��չ��ǰ�ڵ㣬����չ�õ��Ľڵ�ŵ��������ڵ��б���������
	    NewList=get_new_side(LeftPos,Side),
	    NewLeftPos=lists:foldl(fun(X,Left)-> Left band bnot_process_integer(1 bsl X) end,LeftPos,NewList),
	    find_open_path(PosBit,Sides++NewList,NewLeftPos);
	_ ->
	    %%�ýڵ�Ϊ�ϰ��ڵ㲻������չ��ȥ��һ���ڵ��������
	    find_open_path(PosBit,Sides,LeftPos)
    end.


%%��ȡPos�Ŀ���չ�ڵ㲢���أ������ؿ���չ�б�
get_new_side(LeftPos,Pos)->
    Row=Pos div 5,
    Column=Pos rem 5,
    Top=case Row of 
	    0->
		0;
	    _ ->
		Pos-5
    end,
    Bottom=case Row of 
	    5->
		0;
	    _ ->
		Pos+5
    end,
    Left=case Column of 
	    1->
		0;
	    _ ->
		Pos-1
    end,
    Right=case Column of 
	    0->
		0;
	    _ ->
		Pos+1
    end,
    {NewList,_}=lists:foldl(fun(_X,{New,LeftTPos})->
				    T=lists:nth(rand:uniform(length(LeftTPos)),LeftTPos),
				    {[T|New],LeftTPos--[T]}
			    end,
			    {[],[Top,Bottom,Left,Right]},[Top,Bottom,Left,Right]),
    SideList=lists:filter(fun(X)->
				  (X=/=0) andalso ((LeftPos band (1 bsl X))=/=0) 
			  end,NewList),
    SideList.
%%����ת��
%%trans_to_int32(X)->
%%    Bn= << X:32 >>,
%%    << Br:32 >>=Bn,
%%    Br.

%%��λȡ��
bnot_process_integer(X)->
    Bn= << (bnot(X)):32 >>,
    << Br:32 >>=Bn,
    Br.
%%������������λ�õĶ����Ʊ���
make_bit_of_pos(CurArray)->
    PosBit=lists:foldl(fun(X,Sit) -> ( 1 bsl X ) bor  Sit end,0,CurArray),
    PosBit.

%%--------------------------------------------------------------------
%% @doc
%% @����Buff
%% create_buff(BuffIdArray::list(int),Buffs::list(#sbuff{}��,RandArray::list(int),CurArray::list(int))->
%%                            {NewBuffs::List(T::#sbuff{}),NewRandArray::List(int)}
%% RandArray:�������������,Buffs:������Buff�б�,BuffIdArray:�����ɵ�BuffID�б�,NewBuffs:��ͼBuff�б�,CurArray:�������λ��
%% @end
%%--------------------------------------------------------------------  
create_award([],Awards,_RandArray,CurArray)->
    {Awards,CurArray};

create_award([AwardId|AwardIdArray],Awards,RandArray,CurArray)->
    Pos=lists:nth(rand:uniform(length(RandArray)),RandArray),
    create_award(AwardIdArray,[#saward{pos=Pos,awardid=AwardId}|Awards],RandArray--[Pos],[Pos|CurArray]).
%%--------------------------------------------------------------------
%% @doc
%% @��������
%% create_trap(TrapIdArray::list(int),Traps::list(#strap{}),RandArray::List(int),CurArray::list(int))->{NewTraps::List(T::#strap{}),NewRandArray::List(int)}
%% RandArray:�������������,Traps:�����������б�,TrapIdArray:�����ɵ������б�,NewTraps::��ͼ�����б�,CurArray:�������λ��
%% @end
%%--------------------------------------------------------------------  
create_trap([],Traps,_RandArray,CurArray)->
    {Traps,CurArray};

create_trap([TrapId|TrapIdArray],Traps,RandArray,CurArray)->
    Pos=lists:nth(rand:uniform(length(RandArray)),RandArray),
    create_trap(TrapIdArray,[#strap{pos=Pos,trapid=TrapId}|Traps],RandArray--[Pos],[Pos|CurArray]).

%%--------------------------------------------------------------------
%% @doc
%% @�����ѷ���Ӫ
%% @end
%%--------------------------------------------------------------------  
create_friend_role([],Friends,_RandArray,CurArray)->
    {Friends,CurArray};

create_friend_role([FriendRoleId|FriendIdArray],Friends,RandArray,CurArray)->
    Pos=lists:nth(rand:uniform(length(RandArray)),RandArray),
    create_friend_role(FriendIdArray,[#strap{pos=Pos,trapid=FriendRoleId}|Friends],RandArray--[Pos],[Pos|CurArray]).






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%       copy data manager
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_all_copy() ->
    case get(all_play_copy) of
	undefined ->
	    Copys = db:find(db_copy, [{role_id, 'equals', player:get_role_id()}]),
	    put(all_play_copy, Copys),
	    Copys;
	Copys ->
	    Copys
    end.


get_copy_by_copyid(CopyId) ->
    Copys = get_all_copy(),
    case lists:keyfind(CopyId, db_copy:index(copy_id), Copys) of
	false ->
	    undefined ;
	CopyInfo ->
	    CopyInfo
    end.

get_all_pass() ->
    Copys = get_all_copy(),  
    lists:filter(fun(X) ->
			 X:pass_times() > 0
		 end, Copys).

check_copys_pass(Ids) ->
    case Ids of
	[] ->
	    true;
	[Id|Left] ->
	    case get_copy_by_copyid(Id) of
		undefined ->
		    false;
		CopyInfo ->
		    case CopyInfo:pass_times() > 0 of
			true ->
			    check_copys_pass(Left);
			false ->
			    false
		    end
	    end
    end.

%% copy_delete(CopyId) ->
%%     Copys = get_all_copy(),
%%     Copy = get_copy_by_copyid(CopyId),
%%     NewList = lists:keydelete(CopyId, db_copy:index(copy_id), Copys),
%%     ok = db:delete(Copy:id()),
%%     put(all_play_copy, NewList).


copy_add(Inst) ->
    Copys = get_all_copy(),
    List = lists:keydelete(Inst:copy_id(), db_copy:index(copy_id), Copys),
    {ok, NewInst} = Inst:save(),
    NewList = [NewInst|List],
    put(all_play_copy, NewList).

copy_modify(Inst) ->
    Copys = get_all_copy(),
    {ok, NewInst} = Inst:save(),
    NewList =case get_copy_by_copyid(Inst:copy_id()) of
		 Copy when Copy =/= undefined ->
		     lists:keyreplace(Inst:copy_id(), db_copy:index(copy_id), Copys, NewInst);
		 _ ->
		     [NewInst|Copys]
	     end,
    put(all_play_copy, NewList),
    NewInst.


%%--------------------------------------------------------------------
%% @doc
%% @ ��ȡ���ܽ������踱��ͨ��
%% @end
%%--------------------------------------------------------------------
get_func_unlock_need_copy_id(ID) ->
    TpltInfo = tplt:get_data(function_unlock_tplt, ID),
    TpltInfo#function_unlock_tplt.copy_id.


check_func_unlock(ID) ->
    try 
	NeedPassCopyId = get_func_unlock_need_copy_id(ID),
	check_copy_has_passed(NeedPassCopyId)
    catch
	_:_ ->
	    true
    end.


    
    
    
    


    
