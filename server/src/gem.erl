-module(gem).


-include("tplt_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").

-export([start/0,get_gem_type/1,get_gem_attr_info/1]).

-compile(export_all).

start()->
    packet:register(?msg_req_gem_compound, {?MODULE, proc_gem_compound}),
    packet:register(?msg_req_one_touch_gem_compound, {?MODULE, proc_one_touch_compound}),
    packet:register(?msg_req_gem_unmounted,{?MODULE, proc_gem_unmounted}),
    ok.

get_gem_type(TempId)->
    Gem = tplt:get_data(gem_attributes,item:get_sub_id(TempId)),
    Gem#gem_attributes.type.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%宝石融合
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_gem_compound(#req_gem_compound{temp_id = TempId, is_protect=Protect}=_Pack)->
    [{_, Amount}] = player_pack:get_items_count([TempId]),
    case Amount >= 5 of
	true ->
	    GemId = item:get_sub_id(TempId),
	    CompoundInfo = get_compound_Info(GemId),
	    case CompoundInfo#gem_compound.related_id of
		0 ->
		    packet:send(#notify_gem_compound_result{result=?common_error}),
		    sys_msg:send_to_self(?sg_gem_compound_not_related,[]);
		_RelatedId ->
		    case player_role:check_gold_enough(CompoundInfo#gem_compound.gold) of
			true ->
			    [{_,ProtectAmount}] = player_pack:get_items_count([config:get(gem_protected_id)]),
			    case Protect =< ProtectAmount of
				true ->
				    case player_pack:is_space_exceeded() of
					true ->
					    packet:send(#notify_gem_compound_result{result=?common_error}),
					    sys_msg:send_to_self(?sg_gem_compound_pack_full,[]);
					false ->
					    compound_gem(CompoundInfo, Protect) 
				    end;
				false ->
				    packet:send(#notify_gem_compound_result{result=?common_error}),
				    sys_msg:send_to_self(?sg_gem_compound_not_protect,[])
			    end;
			false ->
			    packet:send(#notify_gem_compound_result{result=?common_error}),
			    sys_msg:send_to_self(?sg_gem_compound_not_enough_gold,[])
		    end
	    end;
	false ->
	    packet:send(#notify_gem_compound_result{result=?common_error}),
	    sys_msg:send_to_self(?sg_gem_compound_gem_not_enough,[])
    end.

compound_gem(CompoundInfo, Protect)->
    Result = rand:uniform(100),
    player_role:reduce_gold(?st_gem_compound, CompoundInfo#gem_compound.gold),
    case Result > CompoundInfo#gem_compound.success_rate andalso Protect =:= 0 of
	true ->
	    MissResult = rand:uniform(100),
	    case Protect of
		1 ->
		    player_pack:delete_items(?st_gem_compound_failed, [{config:get(gem_protected_id),1}]),
		    packet:send(#notify_gem_compound_result{result=?common_failed,lost_gem_amount=0});
		0 ->
		    LostGem = get_lost_amount(CompoundInfo#gem_compound.miss_rate, MissResult, 1),
		    player_pack:delete_items(?st_gem_compound_failed, [{CompoundInfo#gem_compound.id,LostGem}]),
		    packet:send(#notify_gem_compound_result{result=?common_failed,lost_gem_amount=LostGem})
	    end;
	false ->
	    DelItems = case Protect of
			   1 ->
			       [{config:get(gem_protected_id),1}, {CompoundInfo#gem_compound.id,5}];
			   0 ->
			       [{CompoundInfo#gem_compound.id,5}]
		       end,
	    player_pack:delete_items(?st_gem_compound, DelItems),
	    player_pack:add_item(notify, ?st_gem_compound, CompoundInfo#gem_compound.related_id),
	    packet:send(#notify_gem_compound_result{result=?common_success,lost_gem_amount=5})
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 一键宝石融合
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_one_touch_compound(#req_one_touch_gem_compound{temp_id = TempID, is_protect = Protect} = _Pack) ->
    [{_, GemAmount}] = player_pack:get_items_count([TempID]),
    GemId = item:get_sub_id(TempID),
    CompoundInfo = get_compound_Info(GemId),
    PlayerGold = player_role:get_gold(),
    case check_one_touch_compound(CompoundInfo, GemAmount, PlayerGold, Protect) of
	true ->
	    one_touch_compound_gem(CompoundInfo, GemAmount, PlayerGold, Protect);
	MsgError ->
	    sys_msg:send_to_self(MsgError, []),
	    packet:send(#notify_one_touch_gem_compound_result{ result_list = []})
    end.

check_one_touch_compound(CompoundInfo, MaxAmount, PlayerGold, Protect) ->
    case MaxAmount >= 5 of
	true ->
	    case CompoundInfo#gem_compound.related_id of
		0 ->
		    ?sg_gem_compound_not_related;
		_RelatedId ->
		    case PlayerGold >= CompoundInfo#gem_compound.gold of
			true ->
			    case player_pack:is_space_exceeded() of
				true ->
				    ?sg_gem_compound_pack_full;
				false ->
				    check_enough_procet_count(Protect)
			    end;
			false ->
			    ?sg_gem_compound_not_enough_gold
		    end
	    end;
	false ->
	    ?sg_gem_compound_gem_not_enough
    end.

check_enough_procet_count(Protect) ->
    case Protect of
	1 ->
	    [{_, ProtectAmount}] = player_pack:get_items_count([config:get(gem_protected_id)]),
	    case ProtectAmount > 0 of
		true ->
		    true;
		false ->
		    ?sg_gem_compound_not_protect
	    end;
	0 ->
	    true
    end.

one_touch_compound_gem(CompoundInfo, MaxAmount, PlayerGold, Protect) ->
%%     {CanCompoundCount, LackMsg} = cal_can_compound_count(MaxAmount, CompoundInfo#gem_compound.gold, Protect),
	ProtectCount = case Protect of
									 1 ->
										 [{_, ProtectAmount}] = player_pack:get_items_count([config:get(gem_protected_id)]),
										 ProtectAmount;
									 0 ->
										 0
								 end,
      {TotalCostGem, TotalAddGem, ResultList, TotalCostGold, TotalCostProtect, Msg} = process_one_touch_compund(Protect, CompoundInfo, ProtectCount, MaxAmount, PlayerGold,
				{0,0,0,0,0}, []),
    player_role:reduce_gold(?st_gem_compound, TotalCostGold),
    player_pack:delete_items(?st_gem_compound, [{CompoundInfo#gem_compound.id, TotalCostGem}, {config:get(gem_protected_id), TotalCostProtect}]),
    case TotalAddGem > 0 of
        true ->
            player_pack:add_items(?st_gem_compound, [{CompoundInfo#gem_compound.related_id, TotalAddGem}]);
        false ->
            ok
    end,
     sys_msg:send_to_self(Msg, []),
    packet:send(#notify_one_touch_gem_compound_result{ result_list = ResultList}).

cal_can_compound_count(MaxAmount, EachTimeGold, Protect) ->
    HasGold = player_role:get_gold(),
    MaxMoneyCount = HasGold div EachTimeGold,
    MaxGemCount = MaxAmount div 5,
    MaxProtectCount = case Protect of
			  1 ->
			      [{_, ProtectAmount}] = player_pack:get_items_count([config:get(gem_protected_id)]),
			      ProtectAmount;
			  0 ->
			      999999
		      end,
    case MaxMoneyCount > MaxGemCount of
	true ->
	    case MaxGemCount > MaxProtectCount of
		true ->
		    {MaxProtectCount, ?sg_gem_compound_not_protect};
		false ->
				io:format("MaxGemCount:~p~n", [MaxGemCount]),
		    {MaxGemCount, ?sg_gem_compound_gem_not_enough}
	    end;
	false ->
	    case MaxMoneyCount > MaxProtectCount of
		true ->
		    {MaxProtectCount, ?sg_gem_compound_not_protect};
		false ->
		    {MaxMoneyCount, ?sg_gem_compound_not_enough_gold}
	    end
    end.

%% 保护符用完
process_one_touch_compund(1, _CompoundInfo, 0, _MaxAmount, _PlayerGold,
		{TotalCostGem, TotalAddGem, TotalCostGold, TotalCostProtect, _Msg},
		ResultList) ->
	{TotalCostGem, TotalAddGem, ResultList, TotalCostGold, TotalCostProtect, ?sg_gem_compound_not_protect};
%% 合成宝石不足
process_one_touch_compund(_Protect, _CompoundInfo, _ProtectCount, MaxAmount, _PlayerGold,
		{TotalCostGem, TotalAddGem, TotalCostGold, TotalCostProtect, _Msg},
		ResultList) when TotalCostGem + 5 >  MaxAmount ->
	{TotalCostGem, TotalAddGem, ResultList, TotalCostGold, TotalCostProtect, ?sg_gem_compound_gem_not_enough};
%% 金币不足
process_one_touch_compund(_Protect, CompoundInfo, _ProtectCount, _MaxAmount, PlayerGold,
		{TotalCostGem, TotalAddGem, TotalCostGold, TotalCostProtect, _Msg},
		ResultList) when PlayerGold < CompoundInfo#gem_compound.gold + TotalCostGold ->
	{TotalCostGem, TotalAddGem, ResultList, TotalCostGold, TotalCostProtect, ?sg_gem_compound_not_enough_gold};
%% 有保护符合成
process_one_touch_compund(1, CompoundInfo, ProtectCount, MaxAmount, PlayerGold,
		{TotalCostGem, TotalAddGem, TotalCostGold, TotalCostProtect, Msg},
		ResultList) ->
	RandomNUmber = rand:uniform(100),
	{CostGem, AddGem, Result} = case RandomNUmber > CompoundInfo#gem_compound.success_rate orelse true of
																true ->
																	{5, 1, #notify_gem_compound_result{result = ?common_success, lost_gem_amount = 0}};
																	%%MissResult = rand:uniform(100),
																	%%LostGem = get_lost_amount(CompoundInfo#gem_compound.miss_rate, MissResult, 1),
%% 																	case ProtectCount > 0 of
%% 																		true ->
%% 																			{0, 1, #notify_gem_compound_result{result = ?common_failed, lost_gem_amount = 0}};
%% 																		false ->
%% 																			{LostGem, 0, #notify_gem_compound_result{result = ?common_failed, lost_gem_amount = LostGem}}
%% 																	end;
																false ->
																	{5, 1, #notify_gem_compound_result{result = ?common_success, lost_gem_amount = 5}}
															end,
	process_one_touch_compund(1, CompoundInfo, ProtectCount - 1, MaxAmount, PlayerGold,
		{TotalCostGem + CostGem,
			TotalAddGem + AddGem,
			TotalCostGold + CompoundInfo#gem_compound.gold,
			TotalCostProtect + 1, Msg},
		[Result | ResultList]);
%% 无保护符合成
process_one_touch_compund(0, CompoundInfo, ProtectCount, MaxAmount, PlayerGold,
		{TotalCostGem, TotalAddGem, TotalCostGold, _TotalCostProtect, Msg},
		ResultList) ->
	RandomNUmber = rand:uniform(100),
	{CostGem, AddGem, Result} = case RandomNUmber > CompoundInfo#gem_compound.success_rate of
																true ->
																	MissResult = rand:uniform(100),
																	LostGem = get_lost_amount(CompoundInfo#gem_compound.miss_rate, MissResult, 1),
																	{LostGem, 0, #notify_gem_compound_result{result = ?common_failed, lost_gem_amount = LostGem}};
																false ->
																	{5, 1, #notify_gem_compound_result{result = ?common_success, lost_gem_amount = 5}}
															end,
	process_one_touch_compund(0, CompoundInfo, ProtectCount - 1, MaxAmount, PlayerGold,
		{TotalCostGem + CostGem,
			TotalAddGem + AddGem,
			TotalCostGold + CompoundInfo#gem_compound.gold,
			0, Msg},
		[Result | ResultList]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%获取丢失的宝石数
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_lost_amount([],_Rand,_Pos)->
    0;
get_lost_amount([Rate|List],Rand,Pos)->
    case Rate >= Rand of
	true ->
	    Pos; 
	false ->
	    get_lost_amount(List,Rand-Rate,Pos+1)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%宝石卸下
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_gem_unmounted(#req_gem_unmounted{equipment_id = EuqipmentId, gem_temp_id = GemTempId}=_Pack)->
    case equipment:get_equipment_info(EuqipmentId) of
	undefined ->
	    packet:send(#notify_gem_unmounted_result{result=?common_error}),
	    sys_msg:send_to_self(?sg_gem_unmounted_equip_notexist,[]);
	Equipment ->
	    EquipmentGems = game_log:termstr_to_term(Equipment:gems()),
	    case check_gem_exist(EquipmentGems,GemTempId) of
		true ->
		    case player_pack:is_space_exceeded() of
			true ->
			    packet:send(#notify_gem_unmounted_result{result=?common_failed}),
			    sys_msg:send_to_self(?sg_gem_unmounted_pack_full,[]);
			false ->
			    Price = get_gem_unmounted_price(GemTempId),
			    case player_role:check_emoney_enough(Price) of
				true ->
				    player_role:reduce_emoney(?st_gem_unmounted,Price),
				    %%NewEquip = Equipment:set([{gems,io_lib:format("~w~n",[EquipmentGems--[GemTempId]])}]),
				    NewEquip = Equipment:set([{gems, equipment:get_list_int_str(EquipmentGems--[GemTempId])}]),
				    player_pack:add_item(notify,?st_gem_unmounted,GemTempId),
				    %%NewEquip:save(),
				    equipment:equipment_modify(NewEquip),
				    equipment:modify_battle_power(NewEquip:equipment_id()),
				    packet:send(#notify_gem_unmounted_result{result=?common_success});
				false ->
				    packet:send(#notify_gem_unmounted_result{result=?common_failed}),
				    sys_msg:send_to_self(?sg_gem_unmounted_emoney_not_enough,[])
			    end
		    end;
		false ->
		    packet:send(#notify_gem_unmounted_result{result=?common_error}),
		    sys_msg:send_to_self(?sg_gem_unmounted_notexist,[])
	    end
    end.

get_gem_unmounted_price(TempId)->
    Gem = tplt:get_data(gem_attributes,item:get_sub_id(TempId)),
    Gem#gem_attributes.unmounted_price.

check_gem_exist(EquipmentGems,TempId)->
    length(EquipmentGems) =/= length(EquipmentGems -- [TempId]).




get_gem_attr_info(TempId)->
    GemId = item:get_sub_id(TempId),
    GemInfo = tplt:get_data(gem_attributes,GemId),
    #battle_prop{life=GemInfo#gem_attributes.life,atk=GemInfo#gem_attributes.atk,
		speed=GemInfo#gem_attributes.speed,hit_ratio=GemInfo#gem_attributes.hit_ratio,
		miss_ratio=GemInfo#gem_attributes.miss_ratio,critical_ratio=GemInfo#gem_attributes.critical_ratio,
		tenacity=GemInfo#gem_attributes.tenacity,power=GemInfo#gem_attributes.combat_effectiveness}.
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%内部
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_compound_Info(GemId)->
    GemCompoundInfo = tplt:get_data(gem_compound,GemId),
    GemCompoundInfo.



    

    
