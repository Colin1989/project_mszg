%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created :  7 Jul 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(recharge).
-include("common_def.hrl").
-include("tplt_def.hrl").
-include("thrift/rpc_types.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
%% API

-export([start/0,
         recharge/4,
         get_user_money/0,
         get_user_recharge_times/0
]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================

start() ->
    packet:register(?msg_req_recharge, {?MODULE, proc_req_recharge}).


proc_req_recharge({server, #req_recharge{user_id = UserID, emoney = AddEmoney, vip_exp = VipExp, org_emoney = OrgEmoney}}) ->
    %%packet:send(#notify_role_info_change{type = "vip_exp", new_value = VipExp}),
    player_role:add_emoney(?st_recharge, AddEmoney),
    player_role:add_vip_exp(?st_recharge, VipExp, UserID),
    activity_recharge:update_recharge_amount(UserID, OrgEmoney), %% 活动充值时的奖励计算
    case first_charge_reward:get_reward_status() of %% 是首冲时，通知可领取首冲奖励
        ?charget_not_rewarded ->
            packet:send(#notify_first_charge_info{status = ?charget_not_rewarded});
        _ ->
            ok
    end,
    ?rpc_RechargeResult_SUCCESS.

recharge_check() ->
    true.


recharge(UserID, OrderID, Money, RechargeID) ->
    case db:find(db_recharge, [{order_id, 'equals', OrderID}, {remark, "1"}]) of
        [] ->
            case db:find(db_user, [{user_id, 'equals', UserID}]) of
                [] ->
                    ?rpc_RechargeResult_USERIDERR;
                [User] ->
                    case get_tplt(RechargeID) of
                        {true, #recharge_tplt{money = TpltMoney, recharge_emoney = RechargeEmoney,
                                              reward_emoney = RewardEmoney, type = Type, channel_id = ChannelID,
                                              reward_vip_exp = AddVipExp }} ->
                            case TpltMoney =:= Money of
                                false ->
                                    ?rpc_RechargeResult_MONEYMISMATCH;
                                true ->
                                    CacheChannelID = redis:hget("channel_id", UserID),
                                    io_helper:format("CacheChaneelID:~p~nChannelID:~p~n", [CacheChannelID, ChannelID]),
                                    case CacheChannelID =:= ChannelID of
                                        true ->
                                            Order = db_recharge:new(id, OrderID, UserID, Money, RechargeID, datetime:local_time(), "1"),
                                            try
                                                case Type of
                                                    1 ->
                                                        process_mooncard(User, RechargeID, RewardEmoney),
                                                        ?rpc_RechargeResult_SUCCESS;
                                                    2 ->
                                                        FinalAddEmoney = process_recharge(User, RechargeEmoney, RewardEmoney, Money),
                                                        process_notify_to_client(User, FinalAddEmoney, RechargeEmoney, AddVipExp, OrderID)
                                                end,
                                                {ok, _Data} = Order:save()
                                                catch
                                                _ : _ ->
                                                    UnfinishedOrder = Order:set([{remark, "0"}]),
                                                    UnfinishedOrder:save(),
                                                    redis:hset("recharge:error", OrderID, erlang:get_stacktrace()),
                                                    ?rpc_RechargeResult_RECHARGEFAILED
                                            end;
                                        false ->
                                            ?rpc_RechargeResult_CHANNELIDERR
                                    end
                            end;
                        false ->
                            ?rpc_RechargeResult_PRODUCTIDERR
                    end
            end;
        _ ->
            ?rpc_RechargeResult_ORDERIDERR
    end.

process_mooncard(User, RechargeID, RewardEmoney) ->
    case account_pid_mapping:get_player_pid(User:user_id()) of
        undefined -> %% 玩家不在线
            mooncard:increase_remain_days(User:user_id(), RechargeID, RewardEmoney);
        _Pid -> %% 玩家在线
            gen_server:call(_Pid, {from_service, #req_buy_mooncard{type = RechargeID, reward_emoney = RewardEmoney}})
    %%mooncard:increase_remain_days(RechargeID)
    end.

get_tplt(RechargeID) ->
    try
        TpltInfo = tplt:get_data(recharge_tplt, RechargeID),
        {true, TpltInfo}
    catch
        _ : _ ->
            false
    end.

process_recharge(User, Emoney, RewardEmoney, Money) ->
    UserID = User:user_id(),
    AddEmoney = case redis:hget("recharge:total_times", UserID) of %% 首冲双倍奖励
                    undefined ->
                        Emoney * 2;
                    _Other ->
                        Emoney
                end,

    CurMoney = get_user_money(UserID),
    NewMoney = CurMoney + Money,
    %%VipLevel = vip:get_new_level(UserID, NewMoney),

    redis:hset("recharge:total_use_money", UserID, NewMoney),
    redis:hincrby("recharge:total_times", UserID, 1),
    write_recharge_log(Money),
    AddEmoney + RewardEmoney.


process_notify_to_client(User, AddEmoney, OrgEmoney, AddVipExp, OrderID) ->
    case account_pid_mapping:get_pid(User:user_id()) of
        undefined -> %% 玩家不在线
            NewUser = player_role:update_emoney(User, AddEmoney, ?st_recharge, no_notify),
            player_role:add_vip_exp(?st_recharge, AddVipExp, NewUser:user_id(), no_notify),
            activity_recharge:update_recharge_amount(NewUser:user_id(), OrgEmoney, no_notify), %% 活动充值时的奖励计算
            %%player_role:update_vip_level(NewUser, VipLevel, no_notify),
            ?rpc_RechargeResult_SUCCESS;
        _Pid -> %% 玩家在线
            PlayerPid = account_pid_mapping:get_player_pid(User:user_id()),
            try
                case gen_server:call(PlayerPid, {from_service, #req_recharge{user_id = User:user_id(),
                                                                             emoney = AddEmoney,
                                                                             org_emoney = OrgEmoney,
                                                                             vip_exp = AddVipExp}})
                of
                    Result when is_integer(Result) ->
                        Result;
                    _ ->
                        ?rpc_RechargeResult_SUCCESS
                end
            catch
                _:_ ->
                    redis:hset("recharge:error", OrderID, [{user_id, User:user_id()}, {pid, PlayerPid}, erlang:get_stacktrace()]),
                    ?rpc_RechargeResult_RECHARGEFAILED
            end
    end.

get_user_money() ->
    UserID = player:get_player_id(),
    get_user_money(UserID).
get_user_money(UserID) ->
    case redis:hget("recharge:total_use_money", UserID) of
        undefined ->
            0;
        Other ->
            Other
    end.

get_user_recharge_times() ->
    UserID = player:get_player_id(),
    get_user_recharge_times(UserID).
get_user_recharge_times(UserID) ->
    case redis:hget("recharge:total_times", UserID) of
        undefined ->
            0;
        Other ->
            Other
    end.

write_recharge_log(_Type) ->
    ok.


