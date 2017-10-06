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
    [Amount] = player_pack:get_items_count([TempId]),
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
    case Result > CompoundInfo#gem_compound.success_rate of
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
	    player_role:reduce_gold(?st_gem_compound, CompoundInfo#gem_compound.gold),
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



    

    
