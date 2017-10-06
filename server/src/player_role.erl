%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%% 玩家角色
%%% @end
%%% Created : 27 Dec 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(player_role).
-include("record_def.hrl").
-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("event_def.hrl").
-include("common_def.hrl").
-include("thrift/rpc_types.hrl").

-define(add_coin, 1).
-define(dec_coin, 2).

-define(add_emoney, 1).
-define(dec_emoney, 2).
-define(update_emoney, 3).

-define(add_summon_stone, 1).
-define(dec_summon_stone, 2).

-define(add_point, 1).
-define(dec_point, 2).


-define(add_honour, 1).
-define(dec_honour, 2).


-define(add_exp, 1).

-define(add_battle_soul, 1).
-define(dec_battle_soul, 2).

%% API
-export([create/8,
         level_check/1,
         %%get_equipment/0,
         %%get_equipment/1,
         %%get_equipment_prop/0,
         check_gold_enough/1,
         check_emoney_enough/1,
         check_point_enough/1,
         reduce_gold/2,
         add_gold/2,
         get_gold/0,
         reduce_emoney/2,
         add_emoney/2,
         get_emoney/0,
         update_emoney/2,
         update_emoney/4,
         update_vip_level/2,
         update_vip_level/3,
         reduce_point/2,
         add_point/2,
         get_friend_point/0,
         get_level_by_exp/2,
         get_level/0,
         get_role_info/3,
         get_role_info/1,
         get_role_info_by_roleid/1,
         notify_role_info/3,
         notify_role_info/1,
         get_role_battle_info/0,
         init_role_battle_info/0,
         clear_role_battle_info/0,
         get_role_by_nickname/1,
         add_exp/2,
         %%battle_prop_info_addition/2,
         %%get_role_battle_prop/0,
         %%get_role_battle_prop/1,
         get_default_sculpture_by_role_type/1,
         role_online/0,
         role_offline/0,
         check_summon_stone_enough/1,
         add_summon_stone/2,
         reduce_summon_stone/2,
         get_summon_stone/0,
         get_role_type/0,
         get_db_role/1,
         reget_role_info/1,
         save_my_db_role/1,
         get_battle_soul/0,
         reduce_battle_soul/2,
         add_battle_soul/2,
         check_battle_soul/1,
         get_potence_level/0,
         increase_potence_level/0,
         get_advanced_level/0,
         increase_advanced_level/0,
         get_user/1,
         set_user/1,
         get_online_role_amount/0,
         %%kick_role_by_roleid/2,
         get_role_level_condition/0,
         check_role_in_status/1,
         check_role_in_status/2,
         modify_rolestatus_by_roleid/3,
         get_role_detail_by_roleid/1,
         update_emoney_with_log/3,
         is_role_exist/1,
         add_vip_exp/2,
         add_vip_exp/3,
         add_vip_exp/4
]).

%%%===================================================================
%%% API
%%%===================================================================
get_role_detail_by_roleid(RoleId) ->
    case roleinfo_manager:get_roleinfo_from_cache(RoleId) of
        undefined ->
            #notify_role_detail_info_result{role_id = 0};
        RoleInfo ->
            ChallengeRank = challenge:get_player_rank(RoleId),
            MilitaryRank = military_rank:get_level(RoleId),
            #notify_role_detail_info_result{role_id = RoleId,
                                            nickname = RoleInfo#role_info_detail.nickname,
                                            status = RoleInfo#role_info_detail.status,
                                            level = RoleInfo#role_info_detail.level,
                                            type = RoleInfo#role_info_detail.type,
                                            public = RoleInfo#role_info_detail.public,
                                            potence_level = RoleInfo#role_info_detail.potence_level,
                                            advanced_level = RoleInfo#role_info_detail.advanced_level,
                                            sculptures = RoleInfo#role_info_detail.battle_prop#role_attr_detail.sculptures,
                                            %%equipments = RoleInfo#role_info_detail.battle_prop#role_attr_detail.equipments,
                                            battle_power = RoleInfo#role_info_detail.battle_prop#role_attr_detail.battle_power,
                                            challenge_rank = ChallengeRank, military_lev = MilitaryRank}
    end.


get_role_level_condition() ->
    io:format("~p~n", [[{X, redis:scard(lists:concat(["train_match:role_lev_bucket:bucket:", X]))} || X <- lists:seq(1, 120)]]).


%%获取在线用户数量
get_online_role_amount() ->
    redis:scard(online_roleid_set).

check_role_in_status(Index) ->
    Role = get_db_role(player:get_role_id()),
    check_role_in_status(Role, Index).

check_role_in_status(Role, Index) ->
    Status = Role:role_status(),
    Head = Index - 1,
    Tail = 32 - Index,
    <<_:Tail/integer, Res:1/integer, _:Head/integer>> = <<Status:32/integer>>,
    Res =:= 1.


get_role_in_statusx(Role, Index) ->
    Status = Role:role_status(),
    Head = Index - 1,
    Tail = 32 - Index,
    <<_:Tail/integer, Res:1/integer, _:Head/integer>> = <<Status:32/integer>>,
    Res.

get_new_role_status(Status, Index, Case) ->
    Head = Index - 1,
    Tail = 32 - Index,
    <<H:Tail/integer, _:1/integer, T:Head/integer>> = <<Status:32/integer>>,
    <<NewStatus:32/integer>> = <<H:Tail/integer, Case:1/integer, T:Head/integer>>,
    NewStatus.


modify_rolestatus_by_roleid(RoleId, StatusType, OptType) ->
    case get_db_role(RoleId) of
        undefined ->
            ?rpc_ModifyRoleStatusResult_NOEXIST;
        Role ->
            case get_role_in_statusx(Role, StatusType) of
                OptType ->
                    ?rpc_ModifyRoleStatusResult_STATUS_ERR;
                _ ->
                    try
                        NewRole = Role:set([{role_status, get_new_role_status(Role:role_status(), StatusType, OptType)}]),
                        NewRole:save(),
                        do_notify_client_role_status_change(RoleId, StatusType, OptType),
                        ?rpc_ModifyRoleStatusResult_SUCCESS
                    catch
                        _:_ ->
                            ?rpc_ModifyRoleStatusResult_SUCCESS
                    end
            end
    end.

do_notify_client_role_status_change(RoleId, StatusType, OptType) ->

    case role_pid_mapping:get_player_pid(RoleId) of
        undefined ->
            ok;
        PlayerPid ->
            case StatusType of
                ?rpc_RoleStatus_KICK when OptType =:= ?rpc_ModifyType_MARK ->
                    Pid = role_pid_mapping:get_pid(RoleId),
                    Pid ! {be_kick};
                _ ->
                    gen_server:call(PlayerPid, {reget, roleinfo})
            end
    end.
%% case role_pid_mapping:get_pid(RoleId) of
%% 	undefined ->
%% 	    ok;
%% 	Pid ->
%% 	    case StatusType of
%% 		?rpc_RoleStatus_KICK when OptType =:= ?rpc_ModifyType_MARK->
%% 		    Pid ! {be_kick};
%% 		_ ->
%% 		    case role_pid_mapping:get_pid(RoleId) of

%% 		    end
%% 		    Pid ! {role_status_change}
%% 	    end
%% end.


%% mute_role_by_roleid(RoleId, OptType) ->
%%     case get_db_role(RoleId) of
%% 	undefined ->
%% 	    ?rpc_MuteRoleResult_NOEXIST;
%% 	Role ->
%% 	    case OptType of
%% 		?rpc_MuteOptType_MUTE ->
%% 		    case check_role_in_status(Role, ?rpc_RoleStatus_MUTE) of
%% 			true ->
%% 			    ?rpc_MuteRoleResult_STATUS_ERR;
%% 			false ->
%% 			    case role_pid_mapping:get_pid(RoleId) of
%% 				undefined ->
%% 				    ok;
%% 				Pid ->
%% 				    Pid ! {be_kick}
%% 			    end,
%% 			    NewRole = Role:set([{role_status, get_new_role_status(Role:role_status(), ?rpc_RoleStatus_MUTE, 1)}]),
%% 			    NewRole:save(),
%% 			    ?rpc_MuteRoleResult_SUCCESS
%% 		    end;
%% 		?rpc_MuteOptType_UNMUTE ->
%% 		    case check_role_in_status(Role, ?rpc_RoleStatus_MUTE) of
%% 			false ->
%% 			    ?rpc_MuteRoleResult_STATUS_ERR;
%% 			true ->
%% 			    NewRole = Role:set([{role_status, get_new_role_status(Role:role_status(), ?rpc_RoleStatus_MUTE, 0)}]),
%% 			    NewRole:save(),
%% 			    ?rpc_MuteRoleResult_SUCCESS
%% 		    end
%% 	    end
%%     end.


%% kick_role_by_roleid(RoleId, OptType) ->
%%     case get_db_role(RoleId) of
%% 	undefined ->
%% 	    ?rpc_KickRoleResult_NOEXIST;
%% 	Role ->
%% 	    case OptType of
%% 		?rpc_KickOptType_KICK ->
%% 		    case check_role_in_status(Role, ?rpc_RoleStatus_KICK) of
%% 			true ->
%% 			    ?rpc_KickRoleResult_STATUS_ERR;
%% 			false ->
%% 			    case role_pid_mapping:get_pid(RoleId) of
%% 				undefined ->
%% 				    ok;
%% 				Pid ->
%% 				    Pid ! {be_kick}
%% 			    end,
%% 			    NewRole = Role:set([{role_status, get_new_role_status(Role:role_status(), ?rpc_RoleStatus_KICK, 1)}]),
%% 			    NewRole:save(),
%% 			    ?rpc_KickRoleResult_SUCCESS
%% 		    end;
%% 		?rpc_KickOptType_UNKICK ->
%% 		    case check_role_in_status(Role, ?rpc_RoleStatus_KICK) of
%% 			false ->
%% 			    ?rpc_KickRoleResult_STATUS_ERR;
%% 			true ->
%% 			    NewRole = Role:set([{role_status, get_new_role_status(Role:role_status(), ?rpc_RoleStatus_KICK, 0)}]),
%% 			    NewRole:save(),
%% 			    ?rpc_KickRoleResult_SUCCESS
%% 		    end
%% 	    end
%%     end.

is_role_exist(RoleID) ->
    case get_db_role(RoleID) of
        undefined ->
            false;
        _ ->
            true
    end.

%%取我的角色表信息
get_db_role(RoleId) ->
    case player:get_role_id() of
        RoleId ->
            case get(my_db_role) of
                undefined ->
                    [Role] = db:find(db_role, [{role_id, 'equals', RoleId}]),
                    put(my_db_role, Role),
                    Role;
                DbRole ->
                    DbRole
            end;
        _ ->
            case db:find(db_role, [{role_id, 'equals', RoleId}]) of
                [] ->
                    undefined;
                [Role] ->
                    Role
            end
    end.

reget_role_info(RoleId) ->
    case player:get_role_id() of
        RoleId ->
            [Role] = db:find(db_role, [{role_id, 'equals', RoleId}]),
            put(my_db_role, Role),
            notify_role_info(Role),
            Role;
        _ ->
            case db:find(db_role, [{role_id, 'equals', RoleId}]) of
                [] ->
                    undefined;
                [Role] ->
                    Role
            end
    end.


%%保存我的角色信息
save_my_db_role(DbRole) ->
    MyId = player:get_role_id(),
    {ok, DbRole} = DbRole:save(),
    case DbRole:role_id() of
        MyId ->
            put(my_db_role, DbRole);
        _ ->
            ok
    end,
    DbRole.


role_online() ->
    %%Ip = get(ip),
    put(login_time, erlang:localtime()),

    {Year, Month, Day} = erlang:date(),
    event_router:send_event_msg(#event_login{year = Year, month = Month, day = Day}),
    activity_lottery:proc_moon_card_user(),
    cache:set(role_online_tbl, player:get_role_id(), datetime:local_time()),
    redis:sadd(online_roleid_set, [player:get_role_id()]).
%%login_logout_log:create(player:get_player_id(), player:get_role_id(), Ip, 1).

role_offline() ->
    Ip = get(ip),
    online_award:update_online_time(),
    %%cache:delete(role_online_tbl, player:get_role_id()),
    notice:del_send_notice_detail_list(),
    redis:srem(online_roleid_set, [player:get_role_id()]),
    log:create(login_logout_log, [player:get_player_id(), player:get_role_id(), Ip, get(login_time), erlang:localtime()]).

get_role_info_by_roleid(RoleId) ->
    get_db_role(RoleId).
%% case db:find(db_role,[{role_id,'equals',RoleId}]) of
%% 	[] ->
%% 	    undefined;
%% 	[Role]->
%% 	    Role
%% end.

add_exp(Type, Exp) when is_integer(Type) ->
    Role = get_role_info_by_roleid(player:get_role_id()),
    NewExp = Exp + Role:exp(),
    {NewLevel, FinalExp} = get_level_by_exp(Role:level(), NewExp),
    case FinalExp =:= Role:exp() of
        true ->
            ok;
        false ->
            NewRole = Role:set([{level, NewLevel}, {exp, FinalExp}]),
            save_my_db_role(NewRole),
            packet:send(#notify_role_info_change{type = "exp", new_value = FinalExp}),
            player_log:create(player:get_role_id(), ?exp, Type, ?add_exp, 0, 0, Exp, Role:exp()),
            case NewLevel =:= Role:level() of
                false ->
                  UgradeTplt = get_exp_tplt(NewLevel),
                  reward:give(UgradeTplt#role_exp_tplt.ids, UgradeTplt#role_exp_tplt.amounts, Type),
                  packet:send(#notify_role_info_change{type = "level", new_value = NewLevel}),
                  %%PH = power_hp:recover_all_pwoer_hp(),
                  %%packet:send(#notify_role_info_change{type = "power_hp", new_value = PH:power_hp()});
                  friend:set_myinfo_update();
                true ->
                    ok
            end
    end;

add_exp(Role, TotalExp) ->
    NewExp = TotalExp + Role:exp(),                           %%更新经验和等级
    {NewLevel, FinalExp} = get_level_by_exp(Role:level(), NewExp),
    case FinalExp =:= Role:exp() of
        true ->
            {ok, Role};
        false ->
            NewRole = Role:set([{level, NewLevel}, {exp, FinalExp}]),
            NR = save_my_db_role(NewRole),
            case NewLevel =:= Role:level() of
                true ->
                    ok;
                false ->
                    UgradeTplt = get_exp_tplt(NewLevel),
                    reward:give(UgradeTplt#role_exp_tplt.ids, UgradeTplt#role_exp_tplt.amounts, ?st_role_upgrade),
                    friend:set_myinfo_update()
            %%power_hp:recover_all_pwoer_hp()
            end,
            {ok, NR}
    end.

add_vip_exp(Type, Exp) ->
    add_vip_exp(Type, Exp, player:get_player_id()).
add_vip_exp(Type, Exp, UserID) ->
    Role = get_role_info_by_roleid(player:get_role_id()),
    NewVipExp = Exp + Role:vip_exp(),
    NewRole = Role:set([{vip_exp, NewVipExp}]),
    save_my_db_role(NewRole),
    packet:send(#notify_role_info_change{type = "vip_exp", new_value = NewVipExp}),
    player_log:create(player:get_role_id(), ?vip_exp, Type, ?add_exp, 0, 0, NewVipExp, Role:vip_exp()),

    CurLevel = vip:get_level(),
    NewLevel = vip:get_new_level(UserID, NewVipExp),
    case CurLevel =:= NewLevel of
        true ->
            ok;
        false ->
            player_role:update_vip_level(player_role:get_user(UserID), NewLevel)
    end.

add_vip_exp(Type, Exp, UserID, no_notify) ->
    Role = get_role_info_by_userid(UserID),
    %%Role = get_role_info_by_roleid(player:get_role_id()),
    NewVipExp = Exp + Role:vip_exp(),
    NewRole = Role:set([{vip_exp, NewVipExp}]),
    save_my_db_role(NewRole),
    player_log:create(Role:role_id(), ?vip_exp, Type, ?add_exp, 0, 0, NewVipExp, Role:vip_exp()),

    CurLevel = vip:get_level(UserID),
    NewLevel = vip:get_new_level(UserID, NewVipExp),
    case CurLevel =:= NewLevel of
        true ->
            ok;
        false ->
            player_role:update_vip_level(player_role:get_user(UserID), NewLevel, no_notify)
    end.

get_role_info_by_userid(UserID) ->
    case db:find(db_role,[{user_id,'equals',UserID}]) of
	[] ->
	    undefined;
	[Role]->
	    Role
end.

%%--------------------------------------------------------------------
%% @doc
%% @通过角色昵称获取角色信息
%% @end
%%--------------------------------------------------------------------
get_role_by_nickname(NickName) ->
    db:find(db_role, [{nickname, 'equals', NickName}]).
%%--------------------------------------------------------------------
%% @doc
%% @创建用户角色
%% @end
%%--------------------------------------------------------------------
create(RoleID, NickName, PlayerID, RoleType, ArmorInstId, WeaponInstId, Skill1, Skill2) ->
    %%UserKey = db:generate_key("db_user", PlayerID),

    Role = db_role:new(id, RoleID, NickName, PlayerID, 1, 0, RoleType, ArmorInstId, WeaponInstId, 0, 0, 0, 0,
                       Skill1, Skill2, 1, 0, config:get(init_gold), config:get(init_summon_stone),
                       0, config:get(init_point), 100, 1,
                       config:get(pack_space_init), 0, datetime:local_time()),
    {ok, NewRole} = Role:save(),
    NewRole.

%%--------------------------------------------------------------------
%% @doc
%% @进入游戏前初始化角色基本战斗数据用于以后校验
%% @end
%%--------------------------------------------------------------------
init_role_battle_info() ->
    RoleId = player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = get_db_role(RoleId),
    #skill_group_item{id1 = ID1, id2 = ID2, id3 = ID3, id4 = ID4} = sculpture:get_cur_skill_group_info(),
    RoleInfo = #role_battle_info{armor = get_Temp_Info(Role:armor()),
                                 weapon = get_Temp_Info(Role:weapon()),
                                 medal = get_Temp_Info(Role:medal()),
                                 jewelry = get_Temp_Info(Role:jewelry()),
                                 sculpture1 = ID1,
                                 sculpture2 = ID2,
                                 sculpture3 = ID3,
                                 sculpture4 = ID4,
                                 level = Role:level()},
    set_role_battle_info(RoleInfo).
set_role_battle_info(RoleInfo) ->
    RoleId = player:get_role_id(),
    cache:set(role_battle_info, RoleId, RoleInfo).
%%ets:insert(role_battle_info,{RoleId,RoleInfo}).

%%--------------------------------------------------------------------
%% @doc
%% @游戏结束后获取进游戏前角色的属性进行写库
%% @end
%%--------------------------------------------------------------------
get_role_battle_info() ->
    RoleId = player:get_role_id(),
    case cache:get(role_battle_info, RoleId) of
        [{_Key, Value}] ->
            Value;
        _ -> undefined
    end.

clear_role_battle_info() ->
    RoleId = player:get_role_id(),
    cache:delete(role_battle_info, RoleId).


%%--------------------------------------------------------------------
%% @doc
%% @把角色属性转换为#notify_roleinfo_msg结构
%% @end
%%--------------------------------------------------------------------
get_role_info(Role, Power, TimeLeft) ->
    %%RoleId=db:get_IntegerKey(Role:id()),
    RoleId = Role:role_id(),
    #notify_roleinfo_msg{id = RoleId,
                         nickname = Role:nickname(),
                         roletype = Role:role_type(),
                         role_status = Role:role_status(),
                         armor = Role:armor(),
                         weapon = Role:weapon(),
                         medal = Role:medal(),
                         jewelry = Role:jewelry(),
                         ring = Role:ring(),
                         necklace = Role:necklace(),
                         skill1 = Role:skill1(),
                         skill2 = Role:skill2(),
                         level = Role:level(),
                         exp = Role:exp(),
                         skill_group_index = sculpture:get_activate_group(),
                         gold = Role:gold(),
                         emoney = get_emoney(),
                         summon_stone = Role:summon_stone(),
                         friend_point = assistance:get_point(),
                         point = Role:point(),
                         honour = military_rank:get_honour(),
                         recover_time_left = TimeLeft,
                         power_hp = Power,
                         power_hp_buy_times = player_power_hp:get_buy_times(),
                         pack_space = Role:pack_space(),
                         battle_power = friend:get_battle_power(),
                         alchemy_exp = alchemy:get_exp(),
                         battle_soul = Role:battle_soul(),
                         potence_level = Role:potence_level(),
                         advanced_level = Role:advanced_level(),
                         vip_level = vip:get_level(),
                         vip_exp = Role:vip_exp()}.

notify_role_info(Role, Power, TimeLeft) ->
    Packet = get_role_info(Role, Power, TimeLeft),
    packet:send(Packet).
%%--------------------------------------------------------------------
%% @doc
%% @把角色属性转换为#notify_roleinfo_msg结构
%% @end
%%--------------------------------------------------------------------
get_role_info(Role) ->
    RoleId = Role:role_id(),
    Power = power_hp:get_power_hp(RoleId),
    TimeLeft = power_hp:get_power_hp_time_left(RoleId),
    get_role_info(Role, Power, TimeLeft).

notify_role_info(Role) ->
    Packet = get_role_info(Role),
    packet:send(Packet).


%%--------------------------------------------------------------------
%% @doc
%% @获取玩家战斗属性
%% @end
%%--------------------------------------------------------------------

%% get_role_battle_prop()->
%%     get_role_battle_prop(player:get_role_id()).

%% get_role_battle_prop(RoleId) when is_integer(RoleId)->
%%     [Role] = db:find(db_role,[{role_id,'equals',RoleId}]),
%%     get_role_battle_prop(Role);

%% get_role_battle_prop(RoleInfo) ->
%%     EuqipmentProp = get_equipment_prop(RoleInfo),
%%     BaseProp = get_role_base_battle_prop(RoleInfo:role_type(),RoleInfo:level()),
%%     battle_power:battle_prop_info_addition(EuqipmentProp,BaseProp).


%% get_role_base_battle_prop(RoleType,Level)->
%%     Id = RoleType*1000 + Level,
%%     Info = tplt:get_data(role_upgrad_tplt,Id),
%%     #battle_prop{life = Info#role_upgrad_tplt.life,
%% 		atk = Info#role_upgrad_tplt.atk,
%% 		speed = Info#role_upgrad_tplt.speed,
%% 		hit_ratio = Info#role_upgrad_tplt.hit_ratio,
%% 		critical_ratio = Info#role_upgrad_tplt.critical_ratio,
%% 		miss_ratio = Info#role_upgrad_tplt.miss_ratio,
%% 		tenacity = Info#role_upgrad_tplt.tenacity,
%% 		power = Info#role_upgrad_tplt.combat_effectiveness}.

%%--------------------------------------------------------------------
%% @doc
%% @获取玩家装备的属性
%% @end
%%--------------------------------------------------------------------

%% get_equipment_prop()->
%%     EquipmentInsts=get_equipment(),
%%     count_equip_prop(EquipmentInsts,#battle_prop{}).


%% get_equipment_prop(RoleInfo)->
%%     EquipmentInsts=get_equipment(RoleInfo),
%%     count_equip_prop(EquipmentInsts,#battle_prop{}).
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @计算玩家的装备属性
%% %% @end
%% %%--------------------------------------------------------------------
%% count_equip_prop([],Prop)->
%%     Prop;
%% count_equip_prop([EquipmentInst|EquipmentInsts],Prop)->
%%     %%Item=equipment:get_equipment_info(EquipmentInst),%%player_pack:get_item(EquipmentInst),
%%     %%Equipment=equipment:get_equipment_prop(item:get_sub_id(Item:temp_id())),
%%     count_equip_prop(EquipmentInsts,equip_prop_accumulation(EquipmentInst, Prop)).
%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @玩家装备属性累加
%% %% equip_prop_accumulation(Equipment::#equipment_tplt{},Prop::#equip_prop{})->NewProp=#equip_prop{}
%% %% Equipment:装备,Prop:当前累计属性,NewProp:新累计属性,NewProp=Equipment+Prop
%% %% @end
%% %%--------------------------------------------------------------------
%% equip_prop_accumulation(EquipmentInst, Prop)->
%%     case EquipmentInst of
%% 	0 ->
%% 	    Prop;
%% 	_ ->
%% 	    EquipmentProp = equipment:get_equipment_battle_info(EquipmentInst),
%% 	    battle_power:battle_prop_info_addition(EquipmentProp, Prop)
%%     end.


%%--------------------------------------------------------------------
%% @doc
%% @spec判断金币是否足够
%% @end
%%--------------------------------------------------------------------
check_gold_enough(Gold) ->
    RoleId = player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = get_db_role(RoleId),
    MyGold = Role:gold(),
    (Gold =< MyGold) andalso (Gold >= 0).

%%--------------------------------------------------------------------
%% @doc
%% @spec判断代币是否足够
%% @end
%%--------------------------------------------------------------------
check_emoney_enough(Emoney) ->
    UserId = player:get_player_id(),
    %%[User]=db:find(db_user,[{user_id,'equals',UserId}]),
    User = get_user(UserId),
    MyEmoney = User:emoney(),
    (Emoney =< MyEmoney) andalso (Emoney >= 0).


level_check(Level) ->
    RoleId = player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = get_db_role(RoleId),
    MyLevel = Role:level(),
    Level =< MyLevel.

%%--------------------------------------------------------------------
%% @doc
%% @spec判断积分是否足够
%% @end
%%--------------------------------------------------------------------
check_point_enough(Point) ->
    RoleId = player:get_role_id(),
    Role = get_db_role(RoleId),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleId}]),
    MyPoint = Role:point(),
    (Point =< MyPoint) andalso (Point >= 0).

%%--------------------------------------------------------------------
%% @doc
%% @spec减少金币
%% @end
%%--------------------------------------------------------------------
reduce_gold(Type, Gold) when Gold >= 0 ->
    RoleID = player:get_role_id(),
    Role = get_db_role(RoleID),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    update_gold(Role, -Gold),
    player_log:create(RoleID, ?coin, Type, ?dec_coin, 0, 0, Gold, Role:gold()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加金币
%% @end
%%--------------------------------------------------------------------
add_gold(Type, Gold) when Gold >= 0 ->
    RoleID = player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_gold(Role, Gold),
    player_log:create(RoleID, ?coin, Type, ?add_coin, 0, 0, Gold, Role:gold()).


%%--------------------------------------------------------------------
%% @doc
%% @spec减少代币
%% @end
%%--------------------------------------------------------------------
reduce_emoney(Type, Emoney) when Emoney >= 0 ->
    UserID = player:get_player_id(),
    %%[User]=db:find(db_user,[{user_id,'equals',UserID}]),
    User = get_user(UserID),
    update_emoney(User, -Emoney),
    player_log:create(player:get_player_id(), ?emoney, Type, ?dec_emoney, 0, 0, Emoney, User:emoney()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加代币
%% @end
%%--------------------------------------------------------------------
add_emoney(Type, Emoney) when Emoney >= 0 ->
    UserID = player:get_player_id(),
    %%[User]=db:find(db_user,[{user_id,'equals',UserID}]),
    User = get_user(UserID),
    update_emoney(User, Emoney),
    player_log:create(player:get_player_id(), ?emoney, Type, ?add_emoney, 0, 0, Emoney, User:emoney()).


get_role_type() ->
    case get(role_type) of
        undefined ->
            RoleId = player:get_role_id(),
            %%[Role|_] = db:find(db_role,[{role_id, 'equals', RoleId}]),
            Role = get_db_role(RoleId),
            RoleType = Role:role_type(),
            put(role_type, RoleType),
            RoleType;
        Type ->
            Type

    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec减少积分
%% @end
%%--------------------------------------------------------------------
reduce_point(Type, Point) when Point >= 0 ->
    RoleID = player:get_role_id(),
    Role = get_db_role(RoleID),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    update_point(Role, -Point),
    player_log:create(RoleID, ?point, Type, ?dec_point, 0, 0, Point, Role:point()).

%%--------------------------------------------------------------------
%% @doc
%% @spec增加积分
%% @end
%%--------------------------------------------------------------------
add_point(Type, Point) when Point >= 0 ->
    RoleID = player:get_role_id(),
    %%[Role|_]=db:find(db_role,[{role_id,'equals',RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_point(Role, Point),
    player_log:create(RoleID, ?point, Type, ?add_point, 0, 0, Point, Role:point()).

%%--------------------------------------------------------------------
%% @doc
%% @spec更新积分
%% @end
%%--------------------------------------------------------------------
update_point(Role, Point) ->
    case Point =:= 0 of
        false ->
            MyPoint = Role:point() + Point,
            NewRole = Role:set([{point, MyPoint}]),
            save_my_db_role(NewRole),
            packet:send(#notify_role_info_change{type = "point", new_value = MyPoint}),
            NewRole;
        true ->
            ok
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 战魂值相关
%% @end
%%--------------------------------------------------------------------
check_battle_soul(Souls) ->
  RoleId = player:get_role_id(),
  Role = get_db_role(RoleId),
  MySouls = Role:battle_soul(),
  (Souls =< MySouls) andalso (Souls >= 0).

get_battle_soul() ->
    RoleId = player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:battle_soul().

reduce_battle_soul(Type, Point) when Point >= 0 ->
    RoleID = player:get_role_id(),
    Role = get_db_role(RoleID),
    update_battle_soul(Role, -Point),
    player_log:create(RoleID, ?battle_soul, Type, ?dec_battle_soul, 0, 0, Point, Role:battle_soul()).

add_battle_soul(Type, Point) when Point >= 0 ->
    RoleID = player:get_role_id(),
    Role = player_role:get_db_role(RoleID),
    update_battle_soul(Role, Point),
    player_log:create(RoleID, ?battle_soul, Type, ?add_battle_soul, 0, 0, Point, Role:battle_soul()).

update_battle_soul(Role, Point) ->
    case Point =:= 0 of
        false ->
            MyPoint = Role:battle_soul() + Point,
            NewRole = Role:set([{battle_soul, MyPoint}]),
            save_my_db_role(NewRole),
            packet:send(#notify_role_info_change{type = "battle_soul", new_value = MyPoint}),
            NewRole;
        true ->
            ok
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 潜力值相关
%% @end
%%--------------------------------------------------------------------
get_potence_level() ->
    RoleId = player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:potence_level().

increase_potence_level() ->
    RoleID = player:get_role_id(),
    Role = player_role:get_db_role(RoleID),
    NewLevel = Role:potence_level() + 1,
    NewRole = Role:set([{potence_level, NewLevel}]),
    save_my_db_role(NewRole),
    packet:send(#notify_role_info_change{type = "potence_level", new_value = NewLevel}),
    NewRole.

%%--------------------------------------------------------------------
%% @doc
%% @spec 进阶等级相关
%% @end
%%--------------------------------------------------------------------
get_advanced_level() ->
    RoleId = player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:advanced_level().

increase_advanced_level() ->
    RoleID = player:get_role_id(),
    Role = player_role:get_db_role(RoleID),
    NewLevel = Role:advanced_level() + 1,
    NewRole = Role:set([{advanced_level, NewLevel}]),
    save_my_db_role(NewRole),
    packet:send(#notify_role_info_change{type = "advanced_level", new_value = NewLevel}),
    talent:unlock(NewLevel),
    NewRole.

%%--------------------------------------------------------------------
%% @doc
%% @spec获取金币
%% @end
%%--------------------------------------------------------------------
get_gold() ->
    RoleId = player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:gold().
%% case db:find(db_role,[{role_id,'equals',RoleId}]) of
%% 	[Role|_]->
%% 	    Role:gold()
%% end.

%%--------------------------------------------------------------------
%% @doc
%% @spec获取代币币
%% @end
%%--------------------------------------------------------------------
get_emoney() ->
    UserId = player:get_player_id(),
    %% case db:find(db_user,[{user_id,'equals',UserId}]) of
    %% 	[User]->
    %% 	    User:emoney()
    %% end.
    User = get_user(UserId),
    User:emoney().


%%--------------------------------------------------------------------
%% @doc
%% @spec获取代币币
%% @end
%%--------------------------------------------------------------------
get_friend_point() ->
    RoleId = player:get_role_id(),
    Role = player_role:get_db_role(RoleId),
    Role:friend_point().
%% case db:find(db_role,[{role_id,'equals',RoleId}]) of
%% 	[Role|_]->
%% 	    Role:friend_point()
%% end.

%%--------------------------------------------------------------------
%% @doc
%% @get_level_by_exp(Level::int,Exp::int)获取当前等级
%% @end
%%--------------------------------------------------------------------
get_level_by_exp(Level, Exp) ->
    try
        ExpLevel = tplt:get_data(role_exp_tplt, Level),
        ExpInt = ExpLevel#role_exp_tplt.exp,
        case ExpInt =< Exp of
            true ->
                get_level_by_exp(Level + 1, Exp);
            false ->
                {Level, Exp}
        end
    catch
        _:_ ->
            ExpInfo = tplt:get_data(role_exp_tplt, Level - 1),
            {Level - 1, ExpInfo#role_exp_tplt.exp}
    end.

%%--------------------------------------------------------------------
%% @doc
%% @ 获取角色等级
%% @end
%%--------------------------------------------------------------------
get_level() ->
    RoleID = player:get_role_id(),
    Role = get_db_role(RoleID),
    Role:level().

%%--------------------------------------------------------------------
%% @doc
%% @ 召唤石相关
%% @end
%%--------------------------------------------------------------------
get_summon_stone() ->
    RoleID = player:get_role_id(),
    Role = player_role:get_db_role(RoleID),
    Role:summon_stone().
%% case db:find(db_role, [{role_id, 'equals', RoleID}]) of
%% 	[Role] ->
%% 	    Role:summon_stone()
%% end.

check_summon_stone_enough(Amount) ->
    (get_summon_stone() >= Amount) andalso (Amount >= 0).

reduce_summon_stone(Type, Amount) when Amount >= 0 ->
    RoleID = player:get_role_id(),
    %%[Role] = db:find(db_role, [{role_id, 'equals', RoleID}]),
    Role = player_role:get_db_role(RoleID),
    update_summon_stone(Role, -Amount),
    case Amount =/= 0 of
        true ->
            Count = cache_with_expire:increase('boss_copy_fight_time', RoleID, day),
            packet:send(#notify_boss_copy_fight_count{count = Count}),
            player_log:create(player:get_role_id(), ?summon_stone, Type, ?dec_summon_stone, 0, 0, Amount, Role:summon_stone());
        _ ->
            ok
    end.

add_summon_stone(Type, Amount) when Amount >= 0 ->
    RoleID = player:get_role_id(),
    %%[Role] = db:find(db_role, [{role_id, 'equals', RoleID}]),
    Role = Role = player_role:get_db_role(RoleID),
    update_summon_stone(Role, Amount),
    case Amount =/= 0 of
        true ->
            player_log:create(player:get_role_id(), ?summon_stone, Type, ?add_summon_stone, 0, 0, Amount, Role:summon_stone());
        _ ->
            ok
    end.

update_summon_stone(Role, Amount) ->
    case Amount =:= 0 of
        false ->
            NewAmount = Role:summon_stone() + Amount,
            NewUser = Role:set([{summon_stone, NewAmount}]),
            save_my_db_role(NewUser),
            packet:send(#notify_role_info_change{type = "summon_stone", new_value = NewAmount}),
            NewUser;
        true ->
            ok
    end.
%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec更新金币
%% @end
%%--------------------------------------------------------------------
update_gold(Role, Gold) ->
    case Gold =:= 0 of
        true ->
            ok;
        false ->
            MyGold = Role:gold() + Gold,
            NewRole = Role:set([{gold, MyGold}]),
            save_my_db_role(NewRole),
            packet:send(#notify_gold_update{gold = MyGold}),
            NewRole
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec更新代币
%% @end
%%--------------------------------------------------------------------
update_emoney(User, Emoney) ->
    case Emoney =:= 0 of
        false ->
            MyEmoney = User:emoney() + Emoney,
            NewUser = User:set([{emoney, MyEmoney}]),
            {ok, New} = NewUser:save(),
            set_user(New),
            packet:send(#notify_emoney_update{emoney = MyEmoney}),
            NewUser;
        true ->
            ok
    end.

update_emoney(User, Emoney, Type, no_notify) ->
    case Emoney =:= 0 of
        false ->
            MyEmoney = User:emoney() + Emoney,
            NewUser = User:set([{emoney, MyEmoney}]),
            {ok, _New} = NewUser:save(),
            player_log:create(User:user_id(), ?emoney, Type, ?add_emoney, 0, 0, Emoney, User:emoney()),
            NewUser;
        true ->
            ok
    end.

update_emoney_with_log(User, Emoney, Type) ->
    case Emoney =:= 0 of
        false ->
            MyEmoney = User:emoney() + Emoney,
            NewUser = User:set([{emoney, MyEmoney}]),
            {ok, _New} = NewUser:save(),
            player_log:create(User:user_id(), ?emoney, Type, ?update_emoney, 0, 0, Emoney, User:emoney()),
            NewUser;
        true ->
            ok
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec更新vip等级
%% @end
%%--------------------------------------------------------------------
update_vip_level(User, Level) ->
    case Level =:= 0 of
        false ->
            NewUser = User:set([{vip_level, Level}]),
            {ok, New} = NewUser:save(),
            set_user(New),
            packet:send(#notify_role_info_change{type = "vip_level", new_value = Level}),
            NewUser;
        true ->
            ok
    end.

update_vip_level(User, Level, no_notify) ->
    case Level =:= 0 of
        false ->
            NewUser = User:set([{vip_level, Level}]),
            {ok, _New} = NewUser:save(),
            NewUser;
        true ->
            ok
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取物品的模板ID
%% @end
%%--------------------------------------------------------------------
%% get_TempId(0)->
%%     0;
%% get_TempId(InstID) ->
%%     Item=player_pack:get_item(InstID),
%%     Item:item_id().

%%--------------------------------------------------------------------
%% @doc
%% @获取装备信息
%% @end
%%--------------------------------------------------------------------
get_Temp_Info(0) ->
    #equip_extra_info{};
get_Temp_Info(InstID) ->
    Equipment = equipment:get_equipment_extra_info(InstID),
    Equipment.
%%Item=player_pack:get_item(InstID),
%%Equipment#equip_extra_info{temp_id=Item:item_id()}.



get_default_sculpture_by_role_type(Type) ->
    Data = tplt:get_data(role_tplt, Type),
    #sculpture_data{temp_id = Data#role_tplt.default_sculpture, level = 0}.


%%获取帐号信息
get_user(UserId) ->
    MyID = player:get_player_id(),
    case MyID of
        UserId ->
            case get(my_user_info) of
                undefined ->
                    %%io:format("**********************************~n***********************************"),
                    [User] = db:find(db_user, [{user_id, 'equals', UserId}]),
                    put(my_user_info, User),
                    User;
                User ->
                    User
            end;
        _ ->
            [User] = db:find(db_user, [{user_id, 'equals', UserId}]),
            User
    end.
%%设置帐号信息
set_user(User) ->
    MyID = player:get_player_id(),
    case User:user_id() of
        MyID ->
            put(my_user_info, User);
        _ ->
            ok
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取装备信息
%% @end
%%--------------------------------------------------------------------
get_exp_tplt(ID) ->
    tplt:get_data(role_exp_tplt, ID).
