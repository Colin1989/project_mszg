%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created : 11 Sep 2014 by whl <>
%%%-------------------------------------------------------------------
-module(invitation_code).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").

%% API
-export([start/0,
         get_comrade_list/1,
         disengage_by_del_role/1]).

-compile(export_all).

-record(prentice_item, {role_id = 0, rewarded_list = []}).
-record(master_item, {role_id = 0, my_rewarded_list = []}).
-record(help_item, {role_id = 0, help_status = ?help_none}).
%%%===================================================================
%%% API
%%%===================================================================

start() ->
    packet:register(?msg_req_input_invite_code, {?MODULE, proc_req_input_invite_code}),
    packet:register(?msg_req_disengage, {?MODULE, proc_req_disengage}),
    packet:register(?msg_req_master_level_reward, {?MODULE, proc_req_master_level_reward}),
    packet:register(?msg_req_prentice_level_reward, {?MODULE, proc_req_prentice_level_reward}),
    packet:register(?msg_req_master_help, {?MODULE, proc_req_help}),
    packet:register(?msg_req_give_help, {?MODULE, proc_req_give_help}),
    packet:register(?msg_req_get_help_reward, {?MODULE, proc_req_get_help_reward}),
    packet:register(?msg_req_disengage_check, {?MODULE, proc_req_disengage_check}),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% @spec 邀请码功能信息通知
%% @end
%%--------------------------------------------------------------------
notify_invite_code_info() ->
    {RewardedList, MasterInfo} = get_master_info(),
    PrenticeList = get_prentice_info_list(),
    IsNewPrenticeGot = get_master_new_prentice_add_tag(),
    Code = get_code(),
    packet:send(#notify_invite_code_info{master = MasterInfo, prentice_list = PrenticeList, code = Code,
                                         is_new_prentice_got = IsNewPrenticeGot, rewarded_list = RewardedList}).

get_master_info() ->
    case get_my_master() of
        undefined ->
            {[],#master_info{}};
        MasterItem ->
            HelpStatus = get_help_status(MasterItem#master_item.role_id, player:get_role_id()),
            Master = roleinfo_manager:get_roleinfo(MasterItem#master_item.role_id),
            MasterInfo = #master_info{role_id = MasterItem#master_item.role_id,
                                      name = Master#role_info_detail.nickname,
                                      type = Master#role_info_detail.type,
                                      advanced_level = Master#role_info_detail.advanced_level,
                                      battle_power = Master#role_info_detail.battle_prop#role_attr_detail.battle_power,
                                      level = Master#role_info_detail.level,
                                      status = HelpStatus},
            RewardedList = MasterItem#master_item.my_rewarded_list,
            {RewardedList, MasterInfo}
    end.

get_prentice_info_list() ->
    RoleID = player:get_role_id(),
    case get_prentice_list(RoleID) of
        [] ->
            [];
        PrenticeList ->
            HelpList = case get_help_list(RoleID) of
                           undefined ->
                               [];
                           List ->
                               List
                       end,
            PrenticeInfoList = lists:map(
                     fun(E) ->
                         HelpStatus = case get_help_item(HelpList, E#prentice_item.role_id) of
                                          false ->
                                              ?help_none;
                                          HelpItem ->
                                              HelpItem#help_item.help_status
                                      end,
                    Prentice = roleinfo_manager:get_roleinfo(E#prentice_item.role_id),
                    #prentice_info{role_id = E#prentice_item.role_id,
                                   name = Prentice#role_info_detail.nickname,
                                   type = Prentice#role_info_detail.type,
                                   advanced_level = Prentice#role_info_detail.advanced_level,
                                   level = Prentice#role_info_detail.level,
                                   rewarded_list = E#prentice_item.rewarded_list,
                                   status = HelpStatus}
                end, PrenticeList),
            PrenticeInfoList
    end.

get_master_new_prentice_add_tag() ->
    case redis:hget("invite_code:new_prentice_tag", player:get_role_id()) of
        undefined ->
           0;
        Tag ->
            %% send_master_bind_reward(Tag), 去掉师傅的邀请礼包
            redis:hdel("invite_code:new_prentice_tag", player:get_role_id()),
            Tag
    end.

get_code() ->
    get_player_code().

disengage_by_del_role(DelRoleID) ->
    case get_master_item(DelRoleID) of %% 从师傅列表中清除自己
        #master_item{role_id = MasterID} ->
            del_master_Prentice(MasterID, DelRoleID),
            notify_lost_prentice(MasterID, DelRoleID);
        undefined ->
            ok
    end,
    case get_prentice_list(DelRoleID) of %% 断绝所有徒弟
        undefined ->
            ok;
        [] ->
            ok;
        PrenticeList ->
            lists:foreach(
                fun(E) ->
                    del_master_Prentice(DelRoleID, E#prentice_item.role_id),
                    notify_lost_master(E#prentice_item.role_id, DelRoleID)
                end, PrenticeList)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 徒弟：输入邀请码，拜师
%% @end
%%--------------------------------------------------------------------
proc_req_input_invite_code(#req_input_invite_code{code = Code}) ->
    case check_bind_legal() of
        true -> %%验码
            case verify_code(Code) of
                {true, MasterID} ->
                    Master = roleinfo_manager:get_roleinfo(MasterID),
                    MasterLevel = Master#role_info_detail.level,
                    case check_is_same_user(MasterID) of
                        true ->
                            sys_msg:send_to_self(?sg_invitation_code_can_not_use_at_same_account, []),
                            packet:send(#notify_input_invite_code_result{result = ?common_failed});
                        false ->
                            case is_seat_enough(MasterID, MasterLevel) of
                                true ->
                                    MasterItem = #master_item{role_id = MasterID},
                                    init_my_master(MasterItem),
                                    send_bind_reward(MasterID),
                                    set_master_new_prentice_add_tag(MasterID),
                                    add_to_comrade_list(player:get_role_id(), MasterID),
                                    add_to_comrade_list(MasterID, player:get_role_id()),
                                    packet:send(#notify_input_invite_code_result{result = ?common_success,
                                                                                 master = #master_info{role_id = MasterID,
                                                                                                       name = Master#role_info_detail.nickname,
                                                                                                       type = Master#role_info_detail.type,
                                                                                                       advanced_level = Master#role_info_detail.advanced_level,
                                                                                                       battle_power = Master#role_info_detail.battle_prop#role_attr_detail.battle_power,
                                                                                                       level = MasterLevel,
                                                                                                       status = ?help_none}});
                                false ->
                                    sys_msg:send_to_self(?sg_invitation_code_invite_num_is_full, []),
                                    packet:send(#notify_input_invite_code_result{result = ?common_failed})
                            end
                    end;
                false ->
                    sys_msg:send_to_self(?sg_invitation_code_code_err, []),
                    packet:send(#notify_input_invite_code_result{result = ?common_failed})
            end;
        false ->
            packet:send(#notify_input_invite_code_result{result = ?common_failed})
    end.

check_bind_legal() -> %% 1已经拜师 2等级小于20
    case get_my_master() of
        undefined ->
            check_can_be_prentice();
        _ ->
            false
    end.

check_can_be_prentice() ->
    player_role:get_level() < config:get(invite_req_min_lev).

check_is_same_user(RoleID) ->
    MasterUserID = player:get_player_id(RoleID),
    MyUserID = player:get_player_id(),
    MasterUserID =:= MyUserID.

is_seat_enough(MasterID, Level) ->
    length(get_prentice_list(MasterID)) < get_prentice_seat_num(Level).

get_prentice_seat_num(_Level) ->
    4.
%%     LevelList = [20,30,40,50],
%%     cal_seat_num(Level, LevelList, 0).

cal_seat_num(_Level, [], CurNum) ->
    CurNum;
cal_seat_num(Level, [CheckLevel | LevelList], CurNum) ->
    case CheckLevel > Level of
        true ->
            CurNum;
        false ->
            cal_seat_num(Level, LevelList, CurNum + 1)
    end.

init_my_master(MasterItem) ->
    redis:hset("invite_code:master", player:get_role_id(), MasterItem),
    add_me_to_prentice_list(MasterItem#master_item.role_id).

add_me_to_prentice_list(MasterID) ->
    OldList = get_prentice_list(MasterID),
    PrenticeItem = #prentice_item{role_id = player:get_role_id()},
    redis:hset("invite_code:prentice_list", MasterID, [PrenticeItem | OldList]).

send_bind_reward(_MasterID) ->
    send_my_bind_reward().

send_my_bind_reward() ->
    ItemID = config:get(invite_bind_pretince_gift_bag_id),
    player_pack:add_item(notify, ?st_invitation_bind, ItemID).


send_master_bind_reward(Num) ->
    ItemID = config:get(invite_bind_pretince_gift_bag_id),
    player_pack:add_item(notify, ?st_invitation_bind, ItemID, Num).

set_master_new_prentice_add_tag(MasterID) ->
    redis:hincrby("invite_code:new_prentice_tag", MasterID, 1).


add_to_comrade_list(RoleID, ComradeID) -> %% 增加战友列表记录 做标记用
    ComradeList = get_comrade_list(RoleID),
    case lists:any(fun(E) -> E =:= ComradeID end, ComradeList) of
        true ->
            ok;
        false ->
            redis:hset("invite_code:comrade_list", RoleID, [ComradeID | ComradeList])
    end.

get_comrade_list(RoleID) ->
    case redis:hget("invite_code:comrade_list", RoleID) of
        undefined ->
            [];
        Other ->
            Other
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 师傅：请求邀请码
%% @end
%%--------------------------------------------------------------------

get_player_code() ->
    data_trans:integer_to_string_format(player:get_role_id()).

verify_code(Code) ->
    MasterID =  data_trans:get_integer_from_string(Code),
    case player_role:is_role_exist(MasterID) of
        true ->
            {true, MasterID};
        false ->
            false
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 断绝关系
%% @end
%%--------------------------------------------------------------------
proc_req_disengage_check(#req_disengage_check{type = Type, role_id = RoleID}) ->
    case Type of
        1 ->
            case check_can_disengage_master() of
                true ->
                    packet:send(#notify_disengage_check_result{result = ?common_success, role_id = RoleID, type = Type});
                false ->
                    sys_msg:send_to_self(?sg_invitation_code_disengage_err, []),
                    packet:send(#notify_disengage_check_result{result = ?common_failed})
            end;
        2 ->
            case check_can_disengage_prentice(RoleID) of
                true ->
                    packet:send(#notify_disengage_check_result{result = ?common_success, role_id = RoleID, type = Type});
                false ->
                    sys_msg:send_to_self(?sg_invitation_code_disengage_err, []),
                    packet:send(#notify_disengage_check_result{result = ?common_failed})
            end
    end.

proc_req_disengage(#req_disengage{type = Type, role_id = RoleID}) ->
    case Type of
        1 ->
            process_disengage_master(RoleID, Type);
        2 ->
            process_disengate_prentice(RoleID, Type)
    end.

process_disengage_master(RoleID, Type) ->  %% 徒弟主动断绝关系
    case check_can_disengage_master() of
        true ->
            del_master_Prentice(RoleID, player:get_role_id()),
            notify_lost_prentice(RoleID),
            packet:send(#notify_disengage_result{result = ?common_success, role_id = RoleID, type = Type});
        false ->
            sys_msg:send_to_self(?sg_invitation_code_disengage_err, []),
            packet:send(#notify_disengage_result{result = ?common_failed})
    end.

notify_lost_prentice(MasterID) ->
    case role_pid_mapping:get_pid(MasterID) of
        undefined ->
            ok;
        Pid ->
            packet:send(Pid, #notify_lost_prentice{role_id = player:get_role_id()})
    end.

notify_lost_prentice(MasterID, PrenticeID) ->
    case role_pid_mapping:get_pid(MasterID) of
        undefined ->
            ok;
        Pid ->
            packet:send(Pid, #notify_lost_prentice{role_id = PrenticeID})
    end.

check_can_disengage_master() -> %% 未登录满10天 等级达到
    case check_my_master_exists() of
        {true, MasterID} ->
            LoginResult = check_is_ten_day_unlogin(MasterID),
            DisengageLev = config:get(invite_bind_can_disengage_level),
            DisengateLevResult = player_role:get_level() >= DisengageLev,
            LoginResult orelse DisengateLevResult;
        false ->
            false
    end.

check_my_master_exists() ->
    case get_my_master() of
        undefined ->
            false;
        MasterItem ->
            {true, MasterItem#master_item.role_id}
    end.

process_disengate_prentice(RoleID, Type) -> %% 师傅主动断绝关系
    case check_can_disengage_prentice(RoleID) of
        true ->
            del_master_Prentice(player:get_role_id(), RoleID),
            notify_lost_master(RoleID),
            packet:send(#notify_disengage_result{result = ?common_success, role_id = RoleID, type = Type});
        false ->
            sys_msg:send_to_self(?sg_invitation_code_disengage_err, []),
            packet:send(#notify_disengage_result{result = ?common_failed})
    end.

notify_lost_master(PrenticeID) ->
    notify_lost_master(PrenticeID, player:get_role_id()).

notify_lost_master(PrenticeID, MasterID) ->
    case role_pid_mapping:get_pid(PrenticeID) of
        undefined ->
            ok;
        Pid ->
            packet:send(Pid, #notify_lost_master{role_id = MasterID})
    end.

check_can_disengage_prentice(RoleID) -> %% 未登录满10天
    case check_my_prentice_exists(RoleID) of
        true ->
            LoginResult = check_is_ten_day_unlogin(RoleID),
            DisengageLev = config:get(invite_bind_can_disengage_level),
            PrenticeInfo = roleinfo_manager:get_roleinfo(RoleID),
            PrenticeLev = PrenticeInfo#role_info_detail.level,
            DisengateLevResult = PrenticeLev >= DisengageLev,
            LoginResult orelse DisengateLevResult;
        false ->
            false
    end.

check_my_prentice_exists(RoleID) ->
    case get_prentice_list(player:get_role_id()) of
        undefined ->
            false;
        [] ->
            false;
        PrenticeList ->
            lists:any(fun(E) -> RoleID =:= E#prentice_item.role_id end, PrenticeList)
    end.

check_is_ten_day_unlogin(RoleID) ->
    [{RoleID, LastLoginTime}] = cache:get(role_online_tbl, RoleID),
    CheckTime = datetime:datetime_to_gregorian_seconds(LastLoginTime) + 86400 * config:get(invite_bind_can_disengage_day),
    CheckTime < datetime:datetime_to_gregorian_seconds(erlang:localtime()).

del_master_Prentice(MasterID, PrenticeID) ->
    del_master(PrenticeID),
    del_prentice(MasterID, PrenticeID).

del_master(PrenticeID) ->
    redis:hdel("invite_code:master", PrenticeID).

del_prentice(MasterID, PrenticeID) ->
    OrgPrenticeList = get_prentice_list(MasterID),
    FixList = lists:filter(fun(E) -> E#prentice_item.role_id =/= PrenticeID  end,OrgPrenticeList),
    set_prentice_list(MasterID, FixList).
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求获取带人等级礼包
%% @end
%%--------------------------------------------------------------------
proc_req_master_level_reward(#req_master_level_reward{prentice_id = PrenticeID, level = Level}) ->
    RoleID = player:get_role_id(),
    PrenticeList = get_prentice_list(RoleID),
    case check_can_get_master_lev_reward(PrenticeList, PrenticeID, Level) of
        {true, OldPrenticeItem} ->
            NewPrenticeItem = OldPrenticeItem#prentice_item{rewarded_list = [Level | OldPrenticeItem#prentice_item.rewarded_list]},
            update_prentice_list(OldPrenticeItem, NewPrenticeItem, PrenticeList),
            give_level_reward(2, Level),
            packet:send(#notify_master_level_reward_result{result = ?common_success, prentice_id = PrenticeID, level = Level});
        false ->
            packet:send(#notify_master_level_reward_result{result = ?common_failed})
    end.

check_can_get_master_lev_reward(PrenticeList, PrenticeID, Level) -> %%1等级 2已领
    case get_prentice_item(PrenticeList, PrenticeID) of
        false ->
            false;
        PrenticeItem ->
            case lists:any(fun(E) -> Level =:= E end, PrenticeItem#prentice_item.rewarded_list) of
                true ->
                    false;
                false ->
                    PrenticeInfo = roleinfo_manager:get_roleinfo(PrenticeID),
                    PrenticeLev = PrenticeInfo#role_info_detail.level,
                    case PrenticeLev >= Level of
                        true ->
                            {true, PrenticeItem};
                        false ->
                            false
                    end
            end
    end.

get_prentice_item(PrenticeList, PrenticeID) ->
    lists:keyfind(PrenticeID, 2, PrenticeList).

give_level_reward(Type, Level) ->
    TpltInfo = get_level_reward_tplt(Level),
    {IDs, Amounts} = case Type of
                         1 ->
                             {TpltInfo#invite_code_reward_tplt.pretince_ids, TpltInfo#invite_code_reward_tplt.prentince_amounts};
                         2 ->
                             {TpltInfo#invite_code_reward_tplt.master_ids, TpltInfo#invite_code_reward_tplt.master_amounts}
                     end,
    reward:give(IDs, Amounts, ?st_invitation_level).
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求获取新人等级礼包
%% @end
%%--------------------------------------------------------------------
proc_req_prentice_level_reward(#req_prentice_level_reward{level = Level}) ->
    case check_can_get_prentice_lev_reward(Level) of
        {true, MasterItem} ->
            NewMasterItem = MasterItem#master_item{my_rewarded_list = [Level | MasterItem#master_item.my_rewarded_list]},
            update_my_master(NewMasterItem),
            give_level_reward(1, Level),
            packet:send(#notify_prentice_level_reward_result{result = ?common_success, level = Level});
        false ->
            packet:send(#notify_prentice_level_reward_result{result = ?common_failed})
    end.

check_can_get_prentice_lev_reward(Level) ->
    case get_my_master() of
        undefined ->
            false;
        MasterItem ->
            case lists:any(fun(E) -> Level =:= E end, MasterItem#master_item.my_rewarded_list) of
                true ->
                    false;
                false ->
                    PlayerLevel = player_role:get_level(),
                    case PlayerLevel >= Level of
                        true ->
                            {true, MasterItem};
                        false ->
                            false
                    end
            end
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求帮助
%% @end
%%--------------------------------------------------------------------
proc_req_help(#req_master_help{}) ->
    MasterID = get_my_master_id(),
    case check_can_req_help(MasterID) of
        {true, OldHelpItem, OldHelpList} ->
            NewHelpItem = OldHelpItem#help_item{help_status = ?help_req},
            update_help_list(MasterID, OldHelpItem, NewHelpItem, OldHelpList),
            notify_req_help_from_prentice(MasterID, player:get_role_id()),
            packet:send(#notify_master_help_result{result = ?common_success});
        false ->
            packet:send(#notify_master_help_result{result = ?common_failed})
    end.

notify_req_help_from_prentice(MasterID, PrenticeID) ->
    case role_pid_mapping:get_pid(MasterID) of
        undefined ->
            ok;
        Pid ->
            packet:send(Pid, #notify_req_help_from_prentice{prentice_id = PrenticeID})
    end.

check_can_req_help(MasterID) -> %% 已帮助 1天一次
    case get_help_list(MasterID) of
        undefined ->
            {true, #help_item{role_id = player:get_role_id()}, []};
        HelpList ->
            case get_help_item(HelpList, player:get_role_id()) of
                false ->
                    {true, #help_item{role_id = player:get_role_id()}, HelpList};
                HelpItem ->
                    case HelpItem#help_item.help_status of
                        Status when Status =:= ?help_none ->
                            {true, HelpItem, HelpList};
                        _ ->
                            false
                    end
            end
    end.

get_help_list(MasterID) ->
    redis:hget("invite_code:helplist", MasterID).

get_help_item(HelpList, PrenticeID) ->
    lists:keyfind(PrenticeID, 2, HelpList).

get_help_status(MasterID, PrenticeID) ->
    case get_help_list(MasterID) of
        undefined ->
            ?help_none;
        List ->
            case get_help_item(List, PrenticeID) of
                false ->
                    ?help_none;
                HelpItem ->
                    HelpItem#help_item.help_status
            end
    end.

update_help_list(MasterID, OldItem, NewItem, OldList) ->
    FixList = lists:filter(fun(E) -> OldItem =/= E end, OldList),
    set_help_list(MasterID, [NewItem | FixList]).

set_help_list(MasterID, HelpList) ->
    cache_with_expire:set("invite_code:helplist", MasterID, HelpList, day).
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求给与帮助
%% @end
%%--------------------------------------------------------------------
proc_req_give_help(#req_give_help{prentice_id = PrenticeID}) ->
    case check_can_give_help(PrenticeID) of
        {true, OldHelpItem, OldHelpList} ->
            NewHelpItem = OldHelpItem#help_item{help_status = ?help_doing},
            update_help_list(player:get_role_id(), OldHelpItem, NewHelpItem, OldHelpList),
            notify_give_help_from_master(PrenticeID),
            packet:send(#notify_give_help_result{result = ?common_success});
        false ->
            packet:send(#notify_give_help_result{result = ?common_failed})
    end.

notify_give_help_from_master(PrenticeID) ->
    case role_pid_mapping:get_pid(PrenticeID) of
        undefined ->
            ok;
        Pid ->
            packet:send(Pid, #notify_give_help_from_master{master_id = player:get_role_id()})
    end.

check_can_give_help(PrenticeID) -> %% 已帮助 1天一次
    case get_help_list(player:get_role_id()) of
        undefined ->
            {true, #help_item{role_id = PrenticeID}, []};
        HelpList ->
            case get_help_item(HelpList, PrenticeID) of
                false ->
                    {true, #help_item{role_id = PrenticeID}, HelpList};
                HelpItem ->
                    case HelpItem#help_item.help_status of
                        Status when Status =:= ?help_none orelse Status =:= ?help_req ->
                            {true, HelpItem, HelpList};
                        _ ->
                            false
                    end
            end
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 请求领取帮助奖励
%% @end
%%--------------------------------------------------------------------
proc_req_get_help_reward(#req_get_help_reward{level = RewardLevel}) ->
    MasterID = get_my_master_id(),
    case check_can_get_help_reward(MasterID) of
        {true, OldHelpItem, OldHelpList} ->
            TpltInfo = get_help_reward_tplt(RewardLevel),
            NeedLevel = TpltInfo#invite_help_reward_tplt.need_level,
            RoleLelve = player_role:get_level(),
            case RoleLelve >= NeedLevel andalso RoleLelve < config:get(invite_help_max_level) of
                true ->
                    give_help_reward(TpltInfo),
                    NewHelpItem = OldHelpItem#help_item{help_status = ?help_got},
                    update_help_list(MasterID, OldHelpItem, NewHelpItem, OldHelpList),
                    packet:send(#notify_get_help_reward_result{result = ?common_success, level = RewardLevel});
                false -> %% 客户端传值有误
                    packet:send(#notify_get_help_reward_result{result = ?common_failed, level = RewardLevel})
            end;
        false ->
            packet:send(#notify_get_help_reward_result{result = ?common_failed})
    end.

check_can_get_help_reward(MasterID) ->
    case get_help_list(MasterID) of
        undefined ->
            false;
        HelpList ->
            case get_help_item(HelpList, player:get_role_id()) of
                false ->
                    false;
                HelpItem ->
                    case HelpItem#help_item.help_status of
                        Status when Status =:= ?help_doing ->
                            {true, HelpItem, HelpList};
                        _ ->
                            false
                    end
            end
    end.

give_help_reward(TpltInfo) ->
    IDs = TpltInfo#invite_help_reward_tplt.ids,
    Amounts = TpltInfo#invite_help_reward_tplt.amounts,
    reward:give(IDs, Amounts, ?st_invitation_help).

%% get_help_reward(Level, []) ->
%%     {Level, [],[]};
%% get_help_reward(Level, [TpltInfo | TpltList]) ->
%%     case TpltInfo#invite_help_reward_tplt.id =< Level of
%%         true ->
%%             {Level, TpltInfo#invite_help_reward_tplt.ids, TpltInfo#invite_help_reward_tplt.amounts};
%%         false ->
%%             get_help_reward(Level, TpltList)
%%     end.

%%%===================================================================
%%% Internal functions
%%%===================================================================


get_my_master() ->
    get_master_item(player:get_role_id()).

get_my_master_id() ->
    MasterItem = get_my_master(),
    MasterItem#master_item.role_id.

get_master_item(RoleID) ->
    redis:hget("invite_code:master", RoleID).

update_my_master(MasterItem) ->
    update_master_item(player:get_role_id(), MasterItem).

update_master_item(PrenticeID, MasterItem) ->
    redis:hset("invite_code:master", PrenticeID, MasterItem).

unbind_my_master() ->
    redis:hdel("invite_code:master", player:get_role_id()).

get_prentice_list(MasterID) ->
    case redis:hget("invite_code:prentice_list", MasterID) of
        undefined ->
            [];
        List ->
            List
    end.

update_prentice_list(OldPrenticeItem, NewPrenticeItem, OldList) ->
    FixList = lists:filter(fun(E) -> OldPrenticeItem =/= E end, OldList),
    redis:hset("invite_code:prentice_list", player:get_role_id(), [NewPrenticeItem | FixList]),
    ok.

add_prentice(MasterID, PrenticeID) ->
    PrenticeList = get_prentice_list(MasterID),
    PrenticeItem = #prentice_item{role_id = PrenticeID},
    set_prentice_list(MasterID, [PrenticeItem | PrenticeList]).

get_prentice_ids(MasterID) ->
    PrenticeList = get_prentice_list(MasterID),
    [ RoleID || #prentice_item{role_id = RoleID} <- PrenticeList].

set_prentice_list(MasterID, List) ->
    redis:hset("invite_code:prentice_list", MasterID, List).

check_can_give_help() -> %% 已帮助 1天一次
    true.

%%--------------------------------------------------------------------
%% @doc
%% @spec 帮助相关
%% @end
%%--------------------------------------------------------------------
get_help_reward() ->
    ok.

get_req_help_info() -> %% 请求帮助
    case redis:hget("invite_code:req_help_list", player:get_role_id()) of
        undefined ->
            0;
        Info ->
            Info
    end.

set_req_help_info() ->
    cache_with_expire:set("invite_code:req_help_list", player:get_role_id(), 1, day).

get_give_help_info() ->
    case redis:hget("invite_code:give_help_list", player:get_role_id()) of
        undefined ->
            0;
        Info ->
            Info
    end.

set_give_help_info() -> %% 给与帮助
    cache_with_expire:set("invite_code:give_help_list", player:get_role_id(), 1, day).

get_helped_info(RoleID) ->
    case redis:hget("invite_code:helped_list", RoleID) of
        undefined ->
            0;
        Info ->
            Info
    end.

set_helped_info() ->
    cache_with_expire:set("invite_code:helped_list", player:get_role_id(), 1, day).


%%--------------------------------------------------------------------
%% @doc
%% @spec 奖励相关
%% @end
%%--------------------------------------------------------------------
get_prientice_rewared_list() -> %% 徒弟的等级奖励
    ok.

is_prientice_rewarded() ->
    ok.

set_prientice_rewarded_list() ->
    ok.

get_master_rewared_list() -> %% 师傅的等级奖励
    ok.

is_master_rewarded() ->
    ok.

set_master_rewarded_list() ->
    ok.

get_prientice_reward() -> %% 徒弟绑定奖励
    ok.

get_master_reward() -> %% 师傅绑定奖励
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------

get_level_reward_tplt(ID) ->
    tplt:get_data(invite_code_reward_tplt, ID).

get_help_reward_tplt(ID) ->
    tplt:get_data(invite_help_reward_tplt, ID).
