%%%-------------------------------------------------------------------
%%% @author wanghl
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%     充值活动
%%% @end
%%% Created : 15. 一月 2015 10:52
%%%-------------------------------------------------------------------
-module(activity_recharge).
-author("wanghl").

-include("event_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").

%% API
-export([start/0,
         init_notify/0,
         update_recharge_amount/2]).

-compile(export_all).

start() ->
    packet:register(?msg_req_act_recharge_reward, {?MODULE, proc_req_act_recharge_reward}).

init_notify() ->
    UserID = player:get_player_id(),
    packet:send(get_reward_info(UserID)).

%%--------------------------------------------------------------------
%% @doc
%% @spec 缓存存储相关信息
%% @end
%%--------------------------------------------------------------------
get_reward_info(UserID) ->
    case cache_with_expire:get('activity_recharge:info', UserID) of
        [] ->
            #notify_act_recharge_info{};
        [{_, Value}] ->
            Value
    end.

set_reward_info(UserID, NewInfo) ->
    cache:set('activity_recharge:info', UserID, NewInfo, activities:get_act_remain_second(activity_recharge)).

proc_req_act_recharge_reward(#req_act_recharge_reward{id = ID}) ->
    case check_can_get_reward(ID) of
        false ->
            packet:send(#notify_act_recharge_reward_result{result =?common_failed});
        {true, Info} ->
            TpltInfo = get_tplt(ID),
            NewInfo = Info#notify_act_recharge_info{rewarded_list = [ID | Info#notify_act_recharge_info.rewarded_list]},
            set_reward_info(player:get_player_id(), NewInfo),
            reward:give(TpltInfo#act_recharge_tplt.reward_ids,TpltInfo#act_recharge_tplt.reward_amounts, ?st_act_recharge_reward),
            packet:send(#notify_act_recharge_reward_result{result =?common_success, id = ID})
    end.

check_can_get_reward(ID) ->
    Info = #notify_act_recharge_info{rewarded_list = RewardedList, cur_recharge_count = Count} = get_reward_info(player:get_player_id()),
    TpltInfo = get_tplt(ID),
    case check_id_is_in_list(ID, RewardedList) or (Count < TpltInfo#act_recharge_tplt.need_emoney) of
        true ->
            false;
        false ->
            {true, Info}
    end.

check_id_is_in_list(ID, List) ->
    lists:any(fun(E) -> ID =:= E end,List).

update_recharge_amount(UserID, Addmount) ->
    io_helper:format("add_recharge_amount:~p~n", [Addmount]),

    case activities:is_open(activities:module_to_index(activity_recharge)) of
        true ->
            Info = get_reward_info(UserID),
            NewInfo =Info#notify_act_recharge_info{cur_recharge_count = Info#notify_act_recharge_info.cur_recharge_count + Addmount},
            set_reward_info(UserID, NewInfo),
            packet:send(NewInfo);
        false ->
            ok
    end.

update_recharge_amount(UserID, Addmount, no_notify) ->
    io_helper:format("add_recharge_amount:~p~n", [Addmount]),

    case activities:is_open(activities:module_to_index(activity_recharge)) of
        true ->
            Info = get_reward_info(UserID),
            NewInfo =Info#notify_act_recharge_info{cur_recharge_count = Info#notify_act_recharge_info.cur_recharge_count + Addmount},
            set_reward_info(UserID, NewInfo);
        false ->
            ok
    end.

get_tplt(ID) ->
    tplt:get_data(act_recharge_tplt, ID).