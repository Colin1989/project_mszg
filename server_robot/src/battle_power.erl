-module(battle_power).


-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("record_def.hrl").

-export([get_equipment_battle_power/1,
	 battle_prop_info_addition/2,
	 get_role_battle_prop/0,
	 get_role_battle_prop/1]).



get_role_battle_prop()->
    get_role_battle_prop(player:get_role_id()).

get_role_battle_prop(RoleId) when is_integer(RoleId)->
    Role = player_role:get_db_role(RoleId),
    get_role_battle_prop(Role);

get_role_battle_prop(RoleInfo) ->
    EuqipmentProp = get_equipment_prop(RoleInfo),
    BaseProp = get_role_base_battle_prop(RoleInfo:role_type(),RoleInfo:level()),
    battle_power:battle_prop_info_addition(EuqipmentProp,BaseProp).
    

get_role_base_battle_prop(RoleType,Level)->
    Id = RoleType*1000 + Level,
    Info = tplt:get_data(role_upgrad_tplt,Id),
    #battle_prop{life = Info#role_upgrad_tplt.life,
		atk = Info#role_upgrad_tplt.atk,
		speed = Info#role_upgrad_tplt.speed,
		hit_ratio = Info#role_upgrad_tplt.hit_ratio,
		critical_ratio = Info#role_upgrad_tplt.critical_ratio,
		miss_ratio = Info#role_upgrad_tplt.miss_ratio,
		tenacity = Info#role_upgrad_tplt.tenacity,
		power = Info#role_upgrad_tplt.combat_effectiveness}.




get_equipment_prop(RoleInfo)->
    EquipmentInsts = equipment:get_equipment(RoleInfo),
    count_equip_prop(RoleInfo:role_id(), EquipmentInsts,#battle_prop{}).
%%--------------------------------------------------------------------
%% @doc
%% @计算玩家的装备属性
%% @end
%%--------------------------------------------------------------------
count_equip_prop(_, [],Prop)->
    Prop;
count_equip_prop(RoleId, [EquipmentInst|EquipmentInsts],Prop)->
    %%Item=equipment:get_equipment_info(EquipmentInst),%%player_pack:get_item(EquipmentInst),
    %%Equipment=equipment:get_equipment_prop(item:get_sub_id(Item:temp_id())),
    count_equip_prop(RoleId, EquipmentInsts,equip_prop_accumulation(RoleId, EquipmentInst, Prop)).
%%--------------------------------------------------------------------
%% @doc
%% @玩家装备属性累加
%% equip_prop_accumulation(Equipment::#equipment_tplt{},Prop::#equip_prop{})->NewProp=#equip_prop{}
%% Equipment:装备,Prop:当前累计属性,NewProp:新累计属性,NewProp=Equipment+Prop
%% @end
%%--------------------------------------------------------------------
equip_prop_accumulation(RoleId, EquipmentInst, Prop)->
    case EquipmentInst of
	0 ->
	    Prop;
	_ ->
	    EquipmentProp = equipment:get_equipment_battle_info(RoleId, EquipmentInst),
	    battle_power:battle_prop_info_addition(EquipmentProp, Prop)
    end.

%%装备战斗力相关
get_equipment_battle_power(Equipment) when is_record(Equipment, equipmentinfo)->
    get_equipment_battle_info(Equipment);
get_equipment_battle_power(Equipment) when element(1, Equipment) =:= db_equipment->
    get_equipment_battle_power(db_equipment_to_equipmentinfo(Equipment)).


db_equipment_to_equipmentinfo(DbEquipment)->
    NewInfo=#equipmentinfo{equipment_id=DbEquipment:equipment_id(),temp_id=DbEquipment:temp_id(),
			   strengthen_level=DbEquipment:level(),gem_extra=DbEquipment:addition_gem(),
			   gems=game_log:termstr_to_term(DbEquipment:gems()),attr_ids=game_log:termstr_to_term(DbEquipment:attach_info()),
			   bindtype = DbEquipment:bind_type(),bindstatus = DbEquipment:bind_status()},
    NewInfo.

%%--------------------------------------------------------------------
%% @doc
%% @获取装备属性
%% @end
%%--------------------------------------------------------------------
get_equipment_battle_info(Equipment)->
    BaseProp = get_equipment_base_battle_info(Equipment),
    BaseInfo = equipment:get_equipment_prop(Equipment#equipmentinfo.temp_id),
    
    NProp = add_equipment_level_battle_prop(Equipment#equipmentinfo.strengthen_level, BaseInfo#equipment_tplt.strengthen_id, BaseProp),
    NProp1 = add_gem_battle_prop(Equipment, NProp),
    NProp2 = add_attr_battle_prop(Equipment, NProp1),
    NProp2.
%%--------------------------------------------------------------------
%% @doc
%% @获取装备基础战斗属性
%% @end
%%--------------------------------------------------------------------
get_equipment_base_battle_info(Equipment)->
    BaseInfo = equipment:get_equipment_prop(Equipment#equipmentinfo.temp_id),
    #battle_prop{life = BaseInfo#equipment_tplt.life,
		 atk = BaseInfo#equipment_tplt.atk,
		 speed = BaseInfo#equipment_tplt.speed,
		 hit_ratio = BaseInfo#equipment_tplt.hit_ratio,
		 miss_ratio = BaseInfo#equipment_tplt.miss_ratio,
		 critical_ratio = BaseInfo#equipment_tplt.critical_ratio,
		 tenacity = BaseInfo#equipment_tplt.tenacity,
		 power = BaseInfo#equipment_tplt.combat_effectiveness}.
%%--------------------------------------------------------------------
%% @doc
%% @附加装备强化额外战斗属性
%% @end
%%--------------------------------------------------------------------
add_equipment_level_battle_prop(Level, StrendId, Prop)->
    NProp = case Level of
		0 ->
		    Prop;
		_ ->
		    Info = tplt:get_data(equipment_lev_price, Level),
		    Percent = Info#equipment_lev_price.combat_effectiveness,
		    LevProp = equipment:get_equipment_level_battle_prop(StrendId, Level),
		    battle_prop_info_addition(LevProp, Prop#battle_prop{power = (Prop#battle_prop.power * (100+Percent)) div 100})
	    end,

    NProp.

%%--------------------------------------------------------------------
%% @doc
%% @附加装备镶嵌宝石的战斗属性
%% @end
%%--------------------------------------------------------------------
add_gem_battle_prop(Equipment,Prop)->
    Gems = Equipment#equipmentinfo.gems,
    lists:foldl(fun(X, CurProp)-> 
			XProp = gem:get_gem_attr_info(X),
			battle_prop_info_addition(CurProp, XProp)
		end,Prop,Gems).
%%--------------------------------------------------------------------
%% @doc
%% @附加装备随机属性的战斗属性值
%% @end
%%--------------------------------------------------------------------
add_attr_battle_prop(Equipment, Prop)->
    Attrs = Equipment#equipmentinfo.attr_ids,
    lists:foldl(fun(X, CurProp)-> 
			XProp = equipment:get_equipment_extra_attr_battle_prop(X),
			battle_prop_info_addition(CurProp, XProp)
		end, Prop, Attrs).


battle_prop_info_addition(Prop1,Prop2)->
    #battle_prop{life = Prop1#battle_prop.life + Prop2#battle_prop.life,
		 atk = Prop1#battle_prop.atk + Prop2#battle_prop.atk,
		 speed = Prop1#battle_prop.speed + Prop2#battle_prop.speed,
		 hit_ratio = Prop1#battle_prop.hit_ratio + Prop2#battle_prop.hit_ratio,
		 miss_ratio = Prop1#battle_prop.miss_ratio + Prop2#battle_prop.miss_ratio,
		 critical_ratio = Prop1#battle_prop.critical_ratio + Prop2#battle_prop.critical_ratio,
		 tenacity = Prop1#battle_prop.tenacity + Prop2#battle_prop.tenacity,
		 power = Prop1#battle_prop.power + Prop2#battle_prop.power}.



    

%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @获取玩家的装备信息
%% %% @end
%% %%--------------------------------------------------------------------
%% get_equipment_infos()->
%%     RoleId=player:get_role_id(),
%%     get_equipment_infos(RoleId).
%% get_equipment_infos(RoleId)->
%%     Infos=db:find(db_equipment,[{role_id,'equals',RoleId}]),
%%     EquipInfos=lists:map(fun trans_db_info/1,Infos),
%%     EquipInfos.

%% trans_db_info(Info)->
%%     NewInfo=#equipmentinfo{equipment_id=Info:equipment_id(),temp_id=Info:temp_id(),strengthen_level=Info:level(),gem_extra=Info:addition_gem(),
%% 			   gems=game_log:termstr_to_term(Info:gems()),attr_ids=game_log:termstr_to_term(Info:attach_info()),
%% 			   bindtype = Info:bind_type(),bindstatus = Info:bind_status()},
%%     NewInfo.

