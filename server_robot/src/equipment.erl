-module(equipment).

-define(modify_equip, 5).

-include("sys_msg.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").
-include("record_def.hrl").
-include("event_def.hrl").
-export([start/0,init/1,get_equipment_prop/1,get_equipment_info/1,get_mounted_gems/1,get_attach_info/1,
	 get_equipment_infos/0,create_equipment/1,create_equipment_and_save/2,
	 get_equipment_extra_info/1,proc_equipment_infos/1,append_equipment_infos/1,
	 create_equipment_and_save/3,check_gem_type_exist/2,get_equipment_extra_value_by_level/2,get_equipment_extra_value_by_attrs/1,
	 get_equipment_extra_value_by_gems/1,modify_battle_power/1]).

-export([get_equipment/0, get_equipment/1]).

-compile(export_all).

start()->
    packet:register(?msg_req_equipment_strengthen, {?MODULE,proc_equipment_strengthen}),
    packet:register(?msg_req_equipment_infos, {?MODULE,proc_equipment_infos}),
    packet:register(?msg_req_equipment_mountgem, {?MODULE,proc_equipment_mountgem}),
    packet:register(?msg_req_equipment_puton, {?MODULE, proc_equipment_puton}),
    packet:register(?msg_req_equipment_takeoff,{?MODULE,proc_equipment_takeoff}),


    packet:register(?msg_req_equipment_advance, {?MODULE, proc_equipment_advance}),%%进阶
    packet:register(?msg_req_equipment_resolve, {?MODULE, proc_equipment_resolve}),%%分解
    packet:register(?msg_req_equipment_recast, {?MODULE, proc_equipment_recast}),%%重铸
    packet:register(?msg_req_save_recast_info, {?MODULE, proc_req_save_recast_info}),
    ok.

init(Role)->
    io_helper:format("~p~n",[Role]),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% @获取玩家装备get_equipment->List[InstID::uuid]
%% 返回玩家装备的实例ID列表
%% @end
%%--------------------------------------------------------------------
get_equipment()->
    RoleId=player:get_role_id(),
    Role=player_role:get_db_role(RoleId),%%db:find(db_role,[{role_id,'equals',RoleId}]),
    get_equipment(Role).

get_equipment(RoleId) when is_integer(RoleId)->
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    get_equipment(Role);

get_equipment(Role)->
    [Role:armor(),Role:weapon(),Role:jewelry(),Role:medal(),Role:ring(),Role:necklace()].




proc_equipment_advance(#req_equipment_advance{inst_id = InstId} = Packet) ->
    io_helper:format("~p~n", [Packet]),
    EquipmentInfoExt=get_equipment_info(InstId),
    EquipmentInfo=tplt:get_data(equipment_tplt,item:get_sub_id(EquipmentInfoExt:temp_id())),
    StrengthenId = EquipmentInfo#equipment_tplt.strengthen_id,
    %%case EquipmentInfoExt:level() of
    case get_equip_advance_need(StrengthenId,EquipmentInfoExt:level()) of
	undefined ->
	    case EquipmentInfo#equipment_tplt.advance_id of
		0 ->
		    sys_msg:send_to_self(?sg_equipment_advance_can_not_advance, []),
		    packet:send(#notify_equipment_advance_result{result=?common_error});
		AdvanceId ->
		    AdvanceInfo = tplt:get_data(equipment_advance_tplt, AdvanceId),
		    case advance_legal_check(AdvanceInfo) of
			true ->
			    player_role:reduce_gold(?st_equipment_advance, AdvanceInfo#equipment_advance_tplt.need_gold),
			    player_pack:delete_items(?st_equipment_advance, AdvanceInfo#equipment_advance_tplt.need_material),
			    NewInfo = EquipmentInfoExt:set([{level, 0}, {temp_id, AdvanceInfo#equipment_advance_tplt.advance_id}]),
			    %%{ok, Info} = NewInfo:save(),
			    Info = equipment_modify(NewInfo),
			    player_pack:set_item(?st_equipment_advance, InstId, AdvanceInfo#equipment_advance_tplt.advance_id),
			    player_log:create(NewInfo:role_id(), ?equipment_info, ?st_equipment_advance, ?modify_equip, 
					      NewInfo:equipment_id(), NewInfo:temp_id(), 1, integer_to_list(EquipmentInfoExt:temp_id())),
			    notify_equipment_info_change([trans_db_info(Info)]),
			    packet:send(#notify_equipment_advance_result{result=?common_success}),
			    modify_battle_power(NewInfo:equipment_id()),
			    ok;
			{false, gold_err} ->
			    sys_msg:send_to_self(?sg_equipment_advance_gold_not_enough, []),
			    packet:send(#notify_equipment_strengthen_result{strengthen_result=?common_error});
			{false, item_err} ->
			    sys_msg:send_to_self(?sg_equipment_advance_item_not_enough, []),
			    packet:send(#notify_equipment_advance_result{result=?common_error})
		    end
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_equipment_advance_level_not_enough, []),
	    packet:send(#notify_equipment_advance_result{result=?common_error})
    end.

notify_equipment_info_change(NewInfos) ->
    packet:send(#notify_equipment_infos{type = ?modify, equipment_infos = NewInfos}).


proc_equipment_resolve(#req_equipment_resolve{inst_id = InstIds} = Packet) ->
    io_helper:format("~p~n", [Packet]),
    {Items, ErrId, Ids, Materials} = process_resovle_equipments(InstIds),
    player_pack:delete_items_by_insts_and_amount(?st_equipment_resolve, [{X, 1} || X <- Ids]),
    player_pack:add_items(?st_equipment_resolve, Items),
    case ErrId of
	0 ->
      event_router:send_event_msg(#event_task_finish_times_update{amount = 1, sub_type = 6}),
	    packet:send(#notify_equipment_resolve_result{result = ?common_success, infos = Materials});
	_ ->
	    packet:send(#notify_equipment_resolve_result{result = ?common_failed, infos = Materials, errid = ErrId})
    end,
    %% EquipmentInfoExt=get_equipment_info(InstId),
    %% %%EquipmentInfo=tplt:get_data(equipment_tplt,item:get_sub_id(EquipmentInfoExt:temp_id())),
    %% try 
    %% 	case check_equipment_on_body(InstId) of
    %% 	    false ->
    %% 		Info = tplt:get_data(equipment_resolve_tplt, item:get_sub_id(EquipmentInfoExt:temp_id())),
    %% 		{Id, Amount} = rand_resolve_material(Info#equipment_resolve_tplt.material_resolved, rand:uniform(100)),
    %% 		EquipmentGems = game_log:termstr_to_term(EquipmentInfoExt:gems()),
    %% 		player_pack:add_items(?st_equipment_resolve, [{Id, Amount}]++[{GemId, 1}|| GemId <- EquipmentGems]),
    %% 		player_pack:delete_items_by_insts_and_amount(?st_equipment_resolve, [{InstId, 1}]),
    %% 		packet:send(#notify_equipment_resolve_result{result = ?common_success, material_id = Id, amount = Amount});
    %% 	    true ->
    %% 		sys_msg:send_to_self(?sg_equipment_resolve_on_body, []),
    %% 		packet:send(#notify_equipment_resolve_result{result = ?common_error})
    %% 	end
    %% catch
    %% 	_:Other ->
    %% 	    io:format("SubId:~p,Reason:~p~n", [item:get_sub_id(EquipmentInfoExt:temp_id()),Other]),
    %% 	    sys_msg:send_to_self(?sg_equipment_resolve_disable, []),
    %% 	    packet:send(#notify_equipment_resolve_result{result = ?common_error})
    %% end,
    ok.

process_resovle_equipments([])->
    {[], 0, [], []};
process_resovle_equipments([InstId|InstIds]) -> 
    case get_equipment_info(InstId) of
	undefined ->
	    sys_msg:send_to_self(?sg_equipment_resolve_not_exist,[]),
	    %%io:format("err1"),
	    {[], InstId, [], []};
	Inst ->
	    try
		case check_equipment_on_body(InstId) of
		    true ->
			sys_msg:send_to_self(?sg_equipment_resolve_on_body, []),
			%%io:format("err2"),
			{[],InstId, [], []};
		    false ->
			Info = tplt:get_data(equipment_resolve_tplt, item:get_sub_id(Inst:temp_id())),
			{Id, Amount} = rand_resolve_material(Info#equipment_resolve_tplt.material_resolved, rand:uniform(100)),
			EquipmentGems = game_log:termstr_to_term(Inst:gems()),
			{Items, ErrId, InstIds, Materials} = process_resovle_equipments(InstIds),
			NewMaterials = case lists:keyfind(Id, #material_info.material_id, Materials) of
					   false ->
					       [#material_info{material_id = Id, amount = Amount}|Materials];
					   #material_info{amount = OldAmount} ->
					       lists:keyreplace(Id, #material_info.material_id,
								Materials, #material_info{material_id = Id, amount = OldAmount + 1})
				       end,
			{lists:concat([Items, [{Id, Amount}|[{GemId, 1}|| GemId <- EquipmentGems]]]),
			 ErrId, [InstId|InstIds], NewMaterials}
			%% player_pack:add_items(?st_equipment_resolve, [{Id, Amount}]++[{GemId, 1}|| GemId <- EquipmentGems]),
			%% player_pack:delete_items_by_insts_and_amount(?st_equipment_resolve, [{InstId, 1}]),
			%% packet:send(#notify_equipment_resolve_result{result = ?common_success, material_id = Id, amount = Amount})
		end
	    catch
		_:_ ->
		    %%io:format("err3:TempId:~p~n~p~n", [Inst:temp_id(), ErrResult]),
		    sys_msg:send_to_self(?sg_equipment_resolve_disable, []),
		    {[], InstId, [], []}
	    end
    end.

rand_resolve_material([{Id, Amount, Radio}|Materials], Rand)->
    case Radio >= Rand of
	true ->
	    {Id, Amount};
	false ->
	    rand_resolve_material(Materials, Rand - Radio)
    end.

proc_equipment_recast(#req_equipment_recast{inst_id = InstId} = Packet) ->
    io_helper:format("~p~n", [Packet]),
    EquipmentInfoExt=get_equipment_info(InstId),
    EquipmentInfo=tplt:get_data(equipment_tplt,item:get_sub_id(EquipmentInfoExt:temp_id())),
    case EquipmentInfo#equipment_tplt.recast_id of
	0 ->
	    sys_msg:send_to_self(?sg_equipment_recast_can_not_recast, []),
	    packet:send(#notify_equipment_advance_result{result=?common_error});
	RecastId ->
	    RecastInfo = tplt:get_data(equipment_recast_tplt, RecastId),
	    case recast_legal_check(RecastInfo) of
		true ->
		    player_role:reduce_gold(?st_equipment_recast, RecastInfo#equipment_recast_tplt.need_gold),
		    player_pack:delete_items(?st_equipment_recast, RecastInfo#equipment_recast_tplt.need_material),
		    RuleId = RecastInfo#equipment_recast_tplt.mf_rule_id,
		    CreateRule=tplt:get_data(equipment_mf_rule_tplt,RuleId),
		    Count=rand:uniform(CreateRule#equipment_mf_rule_tplt.addtional_attr_max-CreateRule#equipment_mf_rule_tplt.addtional_attr_min+1)-1+
			CreateRule#equipment_mf_rule_tplt.addtional_attr_min,
		    RandAttrsAddtion=rand_equipment_attr(Count,CreateRule#equipment_mf_rule_tplt.addtional_attr_ids),
		    CountSpecial=rand:uniform(CreateRule#equipment_mf_rule_tplt.special_attr_max-CreateRule#equipment_mf_rule_tplt.special_attr_min+1)-1+
			CreateRule#equipment_mf_rule_tplt.special_attr_min,
		    RandAttrsSpecial=rand_equipment_attr(CountSpecial,CreateRule#equipment_mf_rule_tplt.special_attr_ids),
		    NewInfo = EquipmentInfoExt:set([{attach_info, get_list_int_str(RandAttrsAddtion++RandAttrsSpecial)}]),
		    set_recast_info(NewInfo),
		    %%NewDbInfo = NewInfo:set([{attach_info, get_list_int_str(RandAttrsAddtion++RandAttrsSpecial)}]),
		    packet:send(#notify_equipment_recast_result{result=?common_success, new_info = trans_db_info(NewInfo)}),
		    ok;
		{false, gold_err} ->
		    sys_msg:send_to_self(?sg_equipment_recast_gold_not_enough, []),
		    packet:send(#notify_equipment_recast_result{result=?common_error});
		{false, item_err} ->
		    sys_msg:send_to_self(?sg_equipment_recast_item_not_enough, []),
		    packet:send(#notify_equipment_recast_result{result=?common_error})
	    end
    end.

proc_req_save_recast_info(#req_save_recast_info{equipment_id = InstId}) ->
    case get_recast_info() of
	undefined ->
	    sys_msg:send_to_self(?sg_equipment_save_recast_iderr, []),
	    packet:send(#notify_save_recast_info_result{result=?common_failed}),
	    error;
	EquipmentInfo ->
	    case EquipmentInfo:equipment_id() of
		InstId ->
		    %%{ok, Info} = EquipmentInfo:save(),
		    Info = equipment_modify(EquipmentInfo),
		    player_log:create(Info:role_id(), ?equipment_info, ?st_equipment_recast, ?modify_equip, 
				      Info:equipment_id(), Info:temp_id(), 1, integer_to_list(Info:temp_id())),
		    %%NewDbInfo = Info:set([{attach_info, get_list_int_str(RandAttrsAddtion++RandAttrsSpecial)}]),
		    notify_equipment_info_change([trans_db_info(Info)]),
		    modify_battle_power(InstId),
		    packet:send(#notify_save_recast_info_result{result=?common_success}),
		    ok;
		_ ->
		    sys_msg:send_to_self(?sg_equipment_save_recast_iderr, []),
		    packet:send(#notify_save_recast_info_result{result=?common_failed}),
		    error
	    end
    end,
    ok.


set_recast_info(EquipmentInfo) ->
    redis:hset(cur_recast_info, player:get_role_id(), EquipmentInfo).

get_recast_info() ->
    redis:hget(cur_recast_info, player:get_role_id()).

clear_recast_info()->
    redis:hdel(cur_recast_info, player:get_role_id()).



%%--------------------------------------------------------------------
%% @doc
%% @脱下装备
%% @end
%%--------------------------------------------------------------------
proc_equipment_takeoff(#req_equipment_takeoff{position=Position}=Pack)->
    io_helper:format("~p~n",[Pack]),
    RoleId=player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    {NewRole,Result, Org}=case Position of
			 ?weapon ->{Role:set([{weapon,0}]),success, Role:weapon()};
			 ?armor ->{Role:set([{armor,0}]),success ,Role:armor()};
			 ?ring ->{Role:set([{ring,0}]),success, Role:ring()};
			 ?necklace ->{Role:set([{necklace,0}]),success, Role:necklace()};
			 ?jewelry ->{Role:set([{jewelry,0}]),success, Role:jewelry()};
			 ?medal ->{Role:set([{medal,0}]),success, Role:jewelry()};
			 _ ->{Role,error, 0}
		     end,
    case Result of
	success ->
	    case player_pack:is_space_exceeded() of
		false ->
		    resave_pack_item(Org, ?st_equip_takeoff),
		    update_equipments_on_body(Org, 0),
		    player_role:save_my_db_role(NewRole),
		    packet:send(#notify_equipment_takeoff_result{takeoff_result=?common_success}),
		    friend:set_myinfo_update();
		true ->
		   packet:send(#notify_equipment_takeoff_result{takeoff_result=?common_error}),
		   sys_msg:send_to_self(?sg_equipment_takeoff_pack_full,[]) 
	    end;
	    
	error ->
	    packet:send(#notify_equipment_takeoff_result{takeoff_result=?common_error}),
	    sys_msg:send_to_self(?sg_equipment_takeoff_type_error,[])
    end.
%%--------------------------------------------------------------------
%% @doc
%% @穿上装备
%% @end
%%--------------------------------------------------------------------
proc_equipment_puton(#req_equipment_puton{equipment_id=InstId}=Pack)->
    io_helper:format("~p~n",[Pack]),
    RoleId=player:get_role_id(),
    %%Equipment=player_pack:get_item(InstId),
    case player_pack:get_item(InstId) of
	undefined ->
	    packet:send(#notify_equipment_puton_result{puton_result=?common_error}),
	    sys_msg:send_to_self(?sg_equipment_puton_noexist,[]) ;
	Equipment ->
	    case Equipment:item_type() of
		?equipment ->
		    case Equipment:role_id() of
			RoleId->
			    EquipmentInfo=tplt:get_data(equipment_tplt,item:get_sub_id(Equipment:item_id())),
			    EquipmentType=EquipmentInfo#equipment_tplt.type,
			    Position=EquipmentType div 10,
			    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
			    Role = player_role:get_db_role(RoleId),
			    RoleType=Role:role_type(),
			    case EquipmentType rem 10 of
				T  when T =:= 0 orelse RoleType =:= T ->
				    case EquipmentInfo#equipment_tplt.equip_use_level=<Role:level() of
					true ->
					    REquipment = get_equipment_by_instid(InstId),
					    %%[REquipment] = db:find(db_equipment, [{equipment_id, 'equals', InstId}]),
					    case REquipment:bind_type() of
						?bind_puton ->
						    case REquipment:bind_status() of
							?bind ->
							    ok;
							?not_bind ->
							    NewEquipment = REquipment:set([{bind_status, ?bind}]),
							    %%NewEquipment:save()
							    equipment_add(NewEquipment)
						    end;
						_ ->
						    ok
					    end,
					    change_role_info(Role,Position,InstId);
					false ->
					    packet:send(#notify_equipment_puton_result{puton_result=?common_error}),
					    sys_msg:send_to_self(?sg_equipment_puton_levelerr,[])
				    end;
				_ -> 
				    packet:send(#notify_equipment_puton_result{puton_result=?common_error}),
				    sys_msg:send_to_self(?sg_equipment_puton_roletypeerr,[]) 
			    end;
			_ ->
			    packet:send(#notify_equipment_puton_result{puton_result=?common_error}),
			    sys_msg:send_to_self(?sg_equipment_puton_notowner,[])
		    end;
		_ ->
		    packet:send(#notify_equipment_puton_result{puton_result=?common_error}),
		    sys_msg:send_to_self(?sg_equipment_puton_itemtypeerr,[])
	    end
    end.
    



proc_equipment_infos(_Pack)->
    %%io_helper:format("~p~n",[Pack]),
    packet:send(#notify_equipment_infos{type=?init,equipment_infos=get_equipment_infos()}).

append_equipment_infos(AdditionList)->
    case AdditionList of
	[] ->
	    ok;
	_ ->
	    packet:send(#notify_equipment_infos{type=?append,equipment_infos=AdditionList})
    end.
    
proc_equipment_strengthen(#req_equipment_strengthen{equipment_id=EquipmentInstId}=Pack)->
    io_helper:format("~p~n",[Pack]),
    advance_equipment(EquipmentInstId),
    ok.


proc_equipment_mountgem(#req_equipment_mountgem{gem_id=GemId, equipment_id=EquipmentId}=Pack)->
    io_helper:format("~p~n",[Pack]),
    %%case db:find(db_equipment,[{equipment_id,'equals',EquipmentId}]) of
    case get_equipment_by_instid(EquipmentId) of
	not_exist ->
	    packet:send(#notify_equipment_mountgem_result{mountgem_result=?common_error});
	Equipment ->
	    case player_pack:get_item(GemId) of
		undefined ->
		    packet:send(#notify_equipment_mountgem_result{mountgem_result=?common_error});
		Gem ->
		    EquipmentGems = game_log:termstr_to_term(Equipment:gems()),
		    case check_gem_trough_enough(Equipment,length(EquipmentGems)) of
			true ->
			    GTempId = item:get_sub_id(Gem:item_id()),
			    GemType = gem:get_gem_type(GTempId),
			    case check_gem_type_exist(EquipmentGems, GemType) of
				true ->
				    packet:send(#notify_equipment_mountgem_result{mountgem_result=?common_failed}),
				    sys_msg:send_to_self(?sg_gem_mount_typeexist,[]);
				false ->
				    NewList = EquipmentGems ++ [Gem:item_id()],
				    %%NewEquipment = Equipment:set([{gems,io_lib:format("~w~n",[NewList])}]),
				    NewEquipment = Equipment:set([{gems, get_list_int_str(NewList)}]),
				    %%NewEquipment:save(),
				    equipment_add(NewEquipment),
				    modify_battle_power(NewEquipment:equipment_id()),
				    player_pack:delete_item(GemId,1,?st_equip_mounted),
				    packet:send(#notify_equipment_mountgem_result{mountgem_result=?common_success})
			    end;
			false ->
			    packet:send(#notify_equipment_mountgem_result{mountgem_result=?common_failed}),
			    sys_msg:send_to_self(?sg_gem_mount_not_trough,[])
		    end
	    end
    end.

check_gem_trough_enough(Equipment,CurAmount) ->
    TempId = Equipment:temp_id(),
    EquipProp = get_equipment_prop(TempId),
    OrgTrough = EquipProp#equipment_tplt.gem_trough,
    AddTrough = Equipment:addition_gem(),
    (OrgTrough + AddTrough) > CurAmount.

check_gem_type_exist(EquipmentGems, GemType)->
    case lists:filter(fun(X) ->
			      gem:get_gem_type(X) =:= GemType
		      end, EquipmentGems) of

	[] ->
	    false;
	_ ->
	    true
    end.
    
    




%%--------------------------------------------------------------------
%% @doc
%% @升级装备
%% @end
%%--------------------------------------------------------------------
advance_equipment(EquipInst)->
    %%Item=player_pack:get_item(EquipInst),
    
    EquipmentInfoExt=get_equipment_info(EquipInst),
	EquipmentInfo=tplt:get_data(equipment_tplt,item:get_sub_id(EquipmentInfoExt:temp_id())),
    case get_equip_advance_need(EquipmentInfo#equipment_tplt.strengthen_id,EquipmentInfoExt:level()) of
	undefined->
	    sys_msg:send_to_self(?sg_equipment_streng_cannot_streng,[]),
	    packet:send(#notify_equipment_strengthen_result{strengthen_result=?common_error});
	EquipmentAdvance->
	    case strengthen_legal_check(EquipmentAdvance) of
		true->
		    SuccessRate = EquipmentAdvance#equip_strengthen_tplt.strengthen_rate,
		    RandRes = rand:uniform(100),
		    case RandRes =< SuccessRate of
			true ->
          event_router:send_event_msg(#event_task_finish_times_update{amount = 1, sub_type = 5}),
			    delete_need_items(EquipmentAdvance),
			    NewInfo=EquipmentInfoExt:set([{level,EquipmentInfoExt:level()+1}]),
			    %%NewInfo:save(),
			    equipment_add(NewInfo),
			    modify_battle_power(NewInfo:equipment_id()),
			    packet:send(#notify_equipment_strengthen_result{strengthen_result=?common_success});
			false ->
			    delete_need_items(EquipmentAdvance),
			    packet:send(#notify_equipment_strengthen_result{strengthen_result=?common_failed}),
			    sys_msg:send_to_self(?sg_equipment_streng_streng_failed, [])
			end;
		false ->
		    packet:send(#notify_equipment_strengthen_result{strengthen_result=?common_error})
	    end
    end.
%%--------------------------------------------------------------------
%% @doc
%% @删除合成物品
%% @end
%%--------------------------------------------------------------------
delete_need_items(EquipmentAdvance)->
    Gold=EquipmentAdvance#equip_strengthen_tplt.need_gold,
%%    NeedItem=EquipmentAdvance#equip_strengthen_tplt.need_item,
%%    NeedItemAmount=EquipmentAdvance#equip_strengthen_tplt.need_item_amount,
    player_role:reduce_gold(?st_equip_strengthen,Gold).
%%    ItemList=make_item_tuple_list(NeedItem,NeedItemAmount,[]),
%%    player_pack:delete_items(?st_equip_strengthen,ItemList).

%%--------------------------------------------------------------------
%% @doc
%% @校验是否满足升级或强化条件
%% @end
%%--------------------------------------------------------------------
strengthen_legal_check(EquipmentAdvance)->
    Gold=EquipmentAdvance#equip_strengthen_tplt.need_gold,
%%    NeedItem=EquipmentAdvance#equip_strengthen_tplt.need_item,
%%    NeedItemAmount=EquipmentAdvance#equip_strengthen_tplt.need_item_amount,
    case player_role:check_gold_enough(Gold) of
	false->
	    sys_msg:send_to_self(?sg_equipment_streng_gold_not_enough,[]),
	    false;
	true ->
	    true
	    %%MyItems=player_pack:get_items_count(NeedItem),
	    %%check_item_enough(NeedItem,NeedItemAmount,MyItems)
    end.


advance_legal_check(EquipmentAdvance)->
    Gold=EquipmentAdvance#equipment_advance_tplt.need_gold,
    NeedItem=EquipmentAdvance#equipment_advance_tplt.need_material,
    case player_role:check_gold_enough(Gold) of
	false->
	    %%sys_msg:send_to_self(?sg_equipment_advance_gold_not_enough,[]),
	    {false, gold_err};
	true ->
	    MyItems=player_pack:get_items_count([ Id ||{Id, _} <- NeedItem]),
	    case check_item_enough(NeedItem,MyItems) of
		true ->
		    true;
		false ->
		    {false, item_err}
	    end
    end.


recast_legal_check(EquipmentRecast)->
    Gold=EquipmentRecast#equipment_recast_tplt.need_gold,
    NeedItem=EquipmentRecast#equipment_recast_tplt.need_material,
    case player_role:check_gold_enough(Gold) of
	false->
	    %%sys_msg:send_to_self(?sg_equipment_advance_gold_not_enough,[]),
	    {false, gold_err};
	true ->
	    MyItems=player_pack:get_items_count([ Id ||{Id, _} <- NeedItem]),
	    case check_item_enough(NeedItem,MyItems) of
		true ->
		    true;
		false ->
		    {false, item_err}
	    end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @生成物品和物品数量组成的元组列表
%% @end
%%--------------------------------------------------------------------
make_item_tuple_list([],[],TupleList)->
    TupleList;
make_item_tuple_list([Item|ItemList],[ItemAmount|ItemAmounts],TupleList) ->
    make_item_tuple_list(ItemList,ItemAmounts,[{Item,ItemAmount}|TupleList]).
%%--------------------------------------------------------------------
%% @doc
%% @判断物品数量是否满足升级
%% @end
%%--------------------------------------------------------------------
check_item_enough([],_)->
    true;
check_item_enough([{_, NeedItemAmount}|NeedItems],[MyItem|MyItems])->
    case NeedItemAmount>element(2,MyItem) of
	true ->
	    %%sys_msg:send_to_self(?sg_equipment_streng_item_not_enough,[]),
	    false;
	false ->
	    check_item_enough(NeedItems,MyItems)
    end.
	
    

%%--------------------------------------------------------------------
%% @doc
%% @获取升级装备所需
%% @end
%%--------------------------------------------------------------------
get_equip_advance_need(StrengthenId,Level)->
    RuleId=StrengthenId*100+Level+1,
    try tplt:get_data(equip_strengthen_tplt,RuleId)
    catch
	_:_->undefined
    end.
%%--------------------------------------------------------------------
%% @doc
%% @获取装备属性
%% @end
%%--------------------------------------------------------------------
get_equipment_prop(EquipmentTempId)->
    tplt:get_data(equipment_tplt,item:get_sub_id(EquipmentTempId)).

%%--------------------------------------------------------------------
%% @doc
%% @获取装备属性
%% @end
%%--------------------------------------------------------------------
get_equipment_info(EquipmentInstId)->
    %%case db:find(db_equipment,[{equipment_id,'equals',EquipmentInstId}]) of
    case get_equipment_by_instid(EquipmentInstId) of
	not_exist ->
	    undefined;
	Equipment ->
	    Equipment
    end.

get_equipment_extra_info(EquipmentInstId)->
    Equipment=get_equipment_info(EquipmentInstId),
    #equip_extra_info{level=Equipment:level(),temp_id=Equipment:temp_id(),addition_gem=Equipment:addition_gem(),
		      attach_info=game_log:termstr_to_term(Equipment:attach_info())}.


%%--------------------------------------------------------------------
%% @doc
%% @获取装备属性
%% @end
%%--------------------------------------------------------------------
get_equipment_battle_info(EquipmentInstId)->
    Inst = get_equipment_info(EquipmentInstId),
    battle_power:get_equipment_battle_power(Inst).


get_equipment_battle_info(RoleId, EquipmentInstId)->
    case player:get_role_id() of
	RoleId ->
	    Inst = get_equipment_info(EquipmentInstId),
	    battle_power:get_equipment_battle_power(Inst);
	_ ->
	    Equipment = find_db_equipment_by_inst(EquipmentInstId),
	    battle_power:get_equipment_battle_power(Equipment)
    end.


find_db_equipment_by_inst(InstId) ->
    [Equipment] = db:find(db_equipment, [{equipment_id, 'equals', InstId}]),
    Equipment.

    
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @获取装备基础战斗属性
%% %% @end
%% %%--------------------------------------------------------------------
%% get_equipment_base_battle_info(Equipment)->
%%     BaseInfo = get_equipment_prop(Equipment:temp_id()),
%%     #battle_prop{life = BaseInfo#equipment_tplt.life,
%% 		 atk = BaseInfo#equipment_tplt.atk,
%% 		 speed = BaseInfo#equipment_tplt.speed,
%% 		 hit_ratio = BaseInfo#equipment_tplt.hit_ratio,
%% 		 miss_ratio = BaseInfo#equipment_tplt.miss_ratio,
%% 		 critical_ratio = BaseInfo#equipment_tplt.critical_ratio,
%% 		 tenacity = BaseInfo#equipment_tplt.tenacity,
%% 		 power = BaseInfo#equipment_tplt.combat_effectiveness}.
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @附加装备强化额外战斗属性
%% %% @end
%% %%--------------------------------------------------------------------
%% add_equipment_level_battle_prop(Level, StrendId, Prop)->
%%     NProp = case Level of
%% 		0 ->
%% 		    Prop;
%% 		_ ->
%% 		    Info = tplt:get_data(equipment_lev_price, Level),
%% 		    Percent = Info#equipment_lev_price.combat_effectiveness,
%% 		    LevProp = get_equipment_level_battle_prop(StrendId, Level),
%% 		    player_role:battle_prop_info_addition(LevProp, Prop#battle_prop{power = (Prop#battle_prop.power * (100+Percent)) div 100})
%% 	    end,

%%     NProp.

%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @附加装备镶嵌宝石的战斗属性
%% %% @end
%% %%--------------------------------------------------------------------
%% add_gem_battle_prop(Equipment,Prop)->
%%     Gems = get_mounted_gems(Equipment),
%%     lists:foldl(fun(X, CurProp)-> 
%% 			XProp = gem:get_gem_attr_info(X),
%% 			player_role:battle_prop_info_addition(CurProp, XProp)
%% 		end,Prop,Gems).
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @附加装备随机属性的战斗属性值
%% %% @end
%% %%--------------------------------------------------------------------
%% add_attr_battle_prop(Equipment, Prop)->
%%     Attrs = get_attach_info(Equipment),
%%     lists:foldl(fun(X, CurProp)-> 
%% 			XProp = get_equipment_extra_attr_battle_prop(X),
%% 			player_role:battle_prop_info_addition(CurProp, XProp)
%% 		end, Prop, Attrs).
    

%%--------------------------------------------------------------------
%% @doc
%% @获取玩家的装备信息
%% @end
%%--------------------------------------------------------------------
get_equipment_infos()->
    RoleId=player:get_role_id(),
    get_equipment_infos(RoleId).
get_equipment_infos(RoleId)->
    Infos = case player:get_role_id() of
	RoleId ->
	    get_all_equipment();
	_ ->
	    db:find(db_equipment,[{role_id,'equals',RoleId}])
    end,
    %%Infos=db:find(db_equipment,[{role_id,'equals',RoleId}]),
    EquipInfos=lists:map(fun trans_db_info/1,Infos),
    EquipInfos.

trans_db_info(Info)->
    NewInfo=#equipmentinfo{equipment_id=Info:equipment_id(),temp_id=Info:temp_id(),strengthen_level=Info:level(),gem_extra=Info:addition_gem(),
			   gems=game_log:termstr_to_term(Info:gems()),attr_ids=game_log:termstr_to_term(Info:attach_info()),
			   bindtype = Info:bind_type(),bindstatus = Info:bind_status()},
    NewInfo.

get_mounted_gems(Equipment)->
    game_log:termstr_to_term(Equipment:gems()).

get_attach_info(Equipment)->
    game_log:termstr_to_term(Equipment:attach_info()).

%%--------------------------------------------------------------------
%% @doc
%% @随机物品属性
%% @end
%%--------------------------------------------------------------------

%%-record(attr_create_rule,{min=0,max=0,attrids,attrrates}).
create_equipment_and_save(EquipmentId,InstanceId,RoleId)->
    {RandGemTrough,RandAttrs}=create_equipment(EquipmentId),
    BindType = item:get_bind_type(EquipmentId),
    BindStatus = case BindType of
		     %%拾到直接绑定
		     ?bind_default ->
			 1;
		     _ ->
			 0
		 end,
    %%Equipment=db_equipment:new(id,InstanceId,RoleId,EquipmentId,0,RandGemTrough,io_lib:format("~w~n",[[]]),
    %%			       io_lib:format("~w~n",[RandAttrs]),BindStatus, BindType, datetime:local_time()),
    Equipment=db_equipment:new(id,InstanceId,RoleId,EquipmentId,0,RandGemTrough,get_list_int_str([]),%%io_lib:format("~w~n",[[]]),
			       get_list_int_str(RandAttrs),%%io_lib:format("~w~n",[RandAttrs]),
			       BindStatus, BindType, datetime:local_time()),
    %%NewEquipment = Equipment:set([{gems, get_list_int_str(NewList)}]),
    %%Equipment:save(),
    equipment_add(Equipment),
    Equipment:set([{attach_info,RandAttrs}]).
create_equipment_and_save(EquipmentId,InstanceId)->
    {RandGemTrough,RandAttrs}=create_equipment(EquipmentId),
    BindType = item:get_bind_type(EquipmentId),
    BindStatus = case BindType of
		     %%拾到直接绑定
		     ?bind_default ->
			 1;
		     _ ->
			 0
		 end,
    %% Equipment=db_equipment:new(id,InstanceId,player:get_role_id(),EquipmentId,0,RandGemTrough,io_lib:format("~w~n",[[]]),
    %% 			       io_lib:format("~w~n",[RandAttrs]),BindStatus, BindType,datetime:local_time()),

    Equipment=db_equipment:new(id,InstanceId,player:get_role_id(),EquipmentId,0,RandGemTrough,get_list_int_str([]),
			       get_list_int_str(RandAttrs),BindStatus, BindType,datetime:local_time()),
    %%{ok, _E} = Equipment:save(),
    equipment_add(Equipment),
    Equipment:set([{attach_info,RandAttrs}]).
    

%% create_equipment(TempId)->
%%     Equipment=tplt:get_data(equipment_tplt,item:get_sub_id(TempId)),
%%     RuleId=Equipment#equipment_tplt.mf_rule,
%%     %%InstanceId=uuid:gen(),
%%     case RuleId of
%% 	0 ->
%% 	 {0,Equipment#equipment_tplt.attr_ids};
%% 	_ ->
%% 	    CreateRule=tplt:get_data(equipment_mf_rule_tplt,RuleId),
%% 	    %%CreateRule=#attr_create_rule{min=2,max=3,attrids=[101,123,345],attrrates=[100,100,99]},
%% 	    Count=rand:uniform(CreateRule#equipment_mf_rule_tplt.addtional_attr_max-CreateRule#equipment_mf_rule_tplt.addtional_attr_min+1)-1+
%% 		CreateRule#equipment_mf_rule_tplt.addtional_attr_min,
%% 	    RandAttrsAddtion=rand_equipment_attr(Count,CreateRule#equipment_mf_rule_tplt.addtional_attr_ids,
%% 					     CreateRule#equipment_mf_rule_tplt.addtional_attr_rates,
%% 					 lists:foldl(fun(X, Sum) -> X + Sum end, 0 , CreateRule#equipment_mf_rule_tplt.addtional_attr_rates)),
%% 	    CountSpecial=rand:uniform(CreateRule#equipment_mf_rule_tplt.special_attr_max-CreateRule#equipment_mf_rule_tplt.special_attr_min+1)-1+
%% 		CreateRule#equipment_mf_rule_tplt.special_attr_min,
%% 	    RandAttrsSpecial=rand_equipment_attr(CountSpecial,CreateRule#equipment_mf_rule_tplt.special_attr_ids,
%% 					 CreateRule#equipment_mf_rule_tplt.special_attr_rates,
%% 					 lists:foldl(fun(X, Sum) -> X + Sum end, 0 , CreateRule#equipment_mf_rule_tplt.special_attr_rates)),
%% 	    RandGemTrough=rand:uniform(CreateRule#equipment_mf_rule_tplt.gem_trough+1)-1,
%% 	    {RandGemTrough,RandAttrsAddtion++RandAttrsSpecial}
%%    end.
create_equipment(TempId)->
    Equipment=tplt:get_data(equipment_tplt,item:get_sub_id(TempId)),
    RuleId=Equipment#equipment_tplt.mf_rule,
    %%InstanceId=uuid:gen(),
    case RuleId of
	0 ->
	 {0,Equipment#equipment_tplt.attr_ids};
	_ ->
	    CreateRule=tplt:get_data(equipment_mf_rule_tplt,RuleId),
	    %%CreateRule=#attr_create_rule{min=2,max=3,attrids=[101,123,345],attrrates=[100,100,99]},
	    Count=rand:uniform(CreateRule#equipment_mf_rule_tplt.addtional_attr_max-CreateRule#equipment_mf_rule_tplt.addtional_attr_min+1)-1+
		CreateRule#equipment_mf_rule_tplt.addtional_attr_min,
	    RandAttrsAddtion=rand_equipment_attr(Count,CreateRule#equipment_mf_rule_tplt.addtional_attr_ids),
	    CountSpecial=rand:uniform(CreateRule#equipment_mf_rule_tplt.special_attr_max-CreateRule#equipment_mf_rule_tplt.special_attr_min+1)-1+
		CreateRule#equipment_mf_rule_tplt.special_attr_min,
	    RandAttrsSpecial=rand_equipment_attr(CountSpecial,CreateRule#equipment_mf_rule_tplt.special_attr_ids),
	    RandGemTrough=rand:uniform(CreateRule#equipment_mf_rule_tplt.gem_trough+1)-1,
	    {RandGemTrough,RandAttrsAddtion++RandAttrsSpecial}
   end.

rand_equipment_attr(0,_AttrIds)->
    [];

rand_equipment_attr(Count,AttrIds)->
    AttrTuples = rand:rand_members_from_list(AttrIds, Count),
    [ create_attr_id(Min, Max)||{Min,Max} <- AttrTuples].
    %% AttrId = lists:nth(rand:uniform(length(AttrIds)),AttrIds),
    %% [AttrId|rand_equipment_attr(Count-1,AttrIds--[AttrId])].

create_attr_id(Min, Max)->
    Min + rand:uniform(Max - Min + 1) - 1.    

%% rand_equipment_attr(0,_AttrIds,_AttrRates,_Total)->
%%     [];

%% rand_equipment_attr(Count,AttrIds,AttrRates,Total)->
%%     Rr=rand:uniform(Total),
%%     {AttrId,AttrRate,NewRates}=get_rand_result(Rr,AttrIds,AttrRates,[]),
%%     [AttrId|rand_equipment_attr(Count-1,AttrIds--[AttrId],NewRates,Total-AttrRate)].


%% get_rand_result(RandInteger,[AttrId|AttrIds],[AttrRate|AttrRates],NewRates)->
%%     case RandInteger =< AttrRate of
%% 	true->
%% 	    {AttrId,AttrRate,lists:reverse(NewRates)++AttrRates};
%% 	false ->
%% 	    get_rand_result(RandInteger-AttrRate,AttrIds,AttrRates,[AttrRate|NewRates])
%%     end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @更换装备
%% @end
%%--------------------------------------------------------------------
change_role_info(Role,Position,InstId)->
    {NewRole,Result,Org,_Pos}=case Position of
			     ?weapon ->{Role:set([{weapon,InstId}]),success,Role:weapon(),"weapon"};
			     ?armor ->{Role:set([{armor,InstId}]),success,Role:armor(),"armor"};
			     ?ring ->{Role:set([{ring,InstId}]),success,Role:ring(),"ring"};
			     ?necklace ->{Role:set([{necklace,InstId}]),success,Role:necklace(),"necklace"};
			     ?jewelry ->{Role:set([{jewelry,InstId}]),success, Role:jewelry(),"jewelry"};
			     ?medal ->{Role:set([{medal,InstId}]),success, Role:medal(),"medal"}
			 end,
    case Result of
	success ->
	    %%packet:send(#notify_role_info_change{type = Pos, value = })
	    packet:send(#notify_equipment_puton_result{puton_result=?common_success}),
	    case Org of
		0 ->
		    player_pack:delete_item_notify(InstId,?st_equip_puton);
		_ ->
		    player_pack:delete_item(InstId,?st_equip_puton)
	    end,
	    update_equipments_on_body(Org, InstId),
	    player_role:save_my_db_role(NewRole),
	    %%player_pack:delete_item(InstId,?st_equip_puton),
	    resave_pack_item(Org, ?st_equip_puton),
	    friend:set_myinfo_update()
    end.


resave_pack_item(InstId, SourceType)->
    case InstId of
	0 ->
	    ok;
	_ ->
	    case db:find(db_equipment,[{equipment_id,'equals',InstId}]) of
		[] ->
		    ok;
		[Equipment] ->
		    NewItem=db_pack:new(id, Equipment:role_id(), InstId, Equipment:temp_id(), ?equipment , 1, Equipment:create_time()),
		    player_pack:add_item(whole,NewItem,SourceType)
	    end
    end.



get_equipment_extra_value_by_level(TempId, Level)->
    case Level of
	0 ->
	    0;
	_ ->
	    BasePrice = item:get_sell_price(TempId),
	    Info = tplt:get_data(equipment_lev_price, Level),
	    Percent = Info#equipment_lev_price.percent,
	    (BasePrice * Percent) div 100
    end.

get_equipment_extra_value_by_attrs(Attrs)->
    TotalValue = lists:foldl(fun(X, In)->
				     AttrInfo = tplt:get_data(equipment_attr_tplt, X),
				     AttrInfo#equipment_attr_tplt.value + In
			     end,0,Attrs),
    TotalValue.

get_equipment_extra_value_by_gems(Gems)->
    GemsPrice = lists:foldl(fun(X, In)->
				    item:get_sell_price(X) + In
			    end,0,Gems),
    GemsPrice.



    
%%--------------------------------------------------------------------
%% @doc
%% @装备额外属性的提取
%% @end
%%--------------------------------------------------------------------    
get_equipment_extra_attr_battle_prop(AttrId)->    
    Attr = tplt:get_data(equipment_attr_tplt, AttrId),
    case binary_to_list(Attr#equipment_attr_tplt.attr_type) of
	"life" ->
	    #battle_prop{life = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	"atk" ->
	    #battle_prop{atk = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	"speed" ->
	    #battle_prop{speed = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	"hit_ratio" ->
	    #battle_prop{hit_ratio = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	"miss_ratio" ->
	    #battle_prop{miss_ratio = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	"critical_ratio" ->
	    #battle_prop{critical_ratio = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	"tenacity" ->
	    #battle_prop{tenacity = Attr#equipment_attr_tplt.attr_values, power = Attr#equipment_attr_tplt.combat_effectiveness};
	_ ->
	    #battle_prop{power = Attr#equipment_attr_tplt.combat_effectiveness}
    end.

%%--------------------------------------------------------------------
%% @doc
%% @装备强化等级提供的额外属性提取
%% @end
%%--------------------------------------------------------------------  
get_equipment_level_battle_prop(StrendId, Level)->
    case Level of
	0 ->
	    #battle_prop{};
	_ ->
	    StrengInfo = tplt:get_data(equip_strengthen_tplt, StrendId*100 + Level),
	    {Prop,_} = lists:foldl(fun(X, {CurProp, [Value|Left]})-> 
					   NewProp = case binary_to_list(X) of
							 "life" ->
							     CurProp#battle_prop{life = Value};
							 "atk" ->
							     CurProp#battle_prop{atk = Value};
							 "speed" ->
							     CurProp#battle_prop{speed = Value};
							 "hit_ratio" ->
							     CurProp#battle_prop{hit_ratio = Value};
							 "miss_ratio" ->
							     CurProp#battle_prop{miss_ratio = Value};
							 "critical_ratio" ->
							     CurProp#battle_prop{critical_ratio = Value};
							 "tenacity" ->
							     CurProp#battle_prop{tenacity = Value};
							 "_" ->
							     CurProp
						     end,
					   {NewProp,Left}
				   end, 
				   {#battle_prop{}, StrengInfo#equip_strengthen_tplt.attr_values}, StrengInfo#equip_strengthen_tplt.attr_types),
	    Prop
    end.


get_equipments_on_body()->
    case get(equipment_puton) of
	undefined ->
	    Equipments = lists:filter(fun(X) -> X=/=0 end, get_equipment()),
	    put(equipment_puton, Equipments),
	    Equipments;
        Results ->
	    Results
    end.

update_equipments_on_body(Org, Cur)->
    put(equipment_puton, (get_equipments_on_body() -- [Org]) ++ [Cur]).


check_equipment_on_body(InstId) ->
    AllInBody = get_equipments_on_body(),
    %%io:format("~p~p~n", [AllInBody, InstId]),
    length(AllInBody) =/= length(AllInBody -- [InstId]).


modify_battle_power(InstId)->
    case lists:filter(fun(X) -> X =:= InstId end, get_equipments_on_body()) of
	[] ->
	    ok;
	_ ->
	    friend:set_myinfo_update()
	    %%notify
    end.

%%把list_int转化成字符串
get_list_int_str(List) ->
    {_, Res} = lists:foldl(fun(X, {Flag, In}) ->
			      case Flag of
				  true ->
				      {true, lists:concat([In, ",", integer_to_list(X)])};  
				  false ->
				      {true, lists:concat([In, integer_to_list(X)])}
			      end
		      end, {false, ""}, List),
    lists:concat(["[", Res, "]\n"]).







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   equipment data manager
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_all_equipment() ->
    case get(all_equipment) of
	undefined ->
	    Infos = db:find(db_equipment,[{role_id,'equals',player:get_role_id()}]),
	    put(all_equipment, Infos),
	    Infos;
	Info ->
	    Info
    end.


get_equipment_by_instid(InstId) ->
    Equipments = get_all_equipment(),
    case lists:keyfind(InstId, db_equipment:index(equipment_id), Equipments) of
	false ->
	    not_exist;
	Equipment ->
	    Equipment
    end.

equipment_delete(InstId) ->
    Equipments = get_all_equipment(),
    Equipment = get_equipment_by_instid(InstId),
    NewList = lists:keydelete(InstId, db_equipment:index(equipment_id), Equipments),
    ok = db:delete(Equipment:id()),
    put(all_equipment, NewList).


equipment_add(Inst) ->
    Equipments = get_all_equipment(),
    List = lists:keydelete(Inst:equipment_id(), db_equipment:index(equipment_id), Equipments),
    {ok, NewInst} = Inst:save(),
    NewList = [NewInst|List],
    put(all_equipment, NewList).

equipment_modify(Inst) ->
    Equipments = get_all_equipment(),
    {ok, NewInst} = Inst:save(),
    NewList = lists:keyreplace(Inst:equipment_id(), db_equipment:index(equipment_id), Equipments, NewInst),
    put(all_equipment, NewList),
    NewInst.
    
    









    
    





