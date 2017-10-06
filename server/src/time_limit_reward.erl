%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created : 11 Nov 2014 by whl <>
%%%-------------------------------------------------------------------
-module(time_limit_reward).

%% API
-export([start/0,
         proc_req_time_limit_reward/1,
         notify_rewarded_list/0]).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").
-include("event_def.hrl").

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_time_limit_reward, {?MODULE, proc_req_time_limit_reward}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 通知已奖励列表
%% @end
%%--------------------------------------------------------------------
notify_rewarded_list() ->
    List = get_rewarded_list(),
    packet:send(#notify_time_limit_rewarded_list{list = List}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求获取奖励
%% @end
%%--------------------------------------------------------------------
proc_req_time_limit_reward(#req_time_limit_reward{id = ID}) ->
    case can_get_reward(ID) of
        {true, RewardedCount, IDs, Amount} ->
            set_rewarded_count(ID, RewardedCount + 1),
            reward:give(IDs, Amount, ?st_time_limit_reward),
            notify_rewarded_list(),
            packet:send(#notify_time_limit_reward{result = ?common_success});
        false ->
            packet:send(#notify_time_limit_reward{result = ?common_failed})
    end,
    ok.

can_get_reward(ID) ->
    TpltInfo = get_tplt(ID),
    CurTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
    StartTime = datetime:datetime_to_gregorian_seconds({erlang:date(), lists:nth(1, TpltInfo#time_limit_reward_tplt.start_time)}),
    EndTime = datetime:datetime_to_gregorian_seconds({erlang:date(), lists:nth(1, TpltInfo#time_limit_reward_tplt.end_time)}),
    case CurTime >= StartTime andalso CurTime =< EndTime of
        true ->
            Item = get_rewarded_item(ID),
            #stime{year=Year, month=Month, day=Day, hour=Hour, minute=Minute, second=Second} = Item#time_limit_rewarded_item.rewarded_time,
            PassTime = CurTime - datetime:datetime_to_gregorian_seconds({{Year, Month, Day}, {Hour, Minute, Second}}),
            case Item#time_limit_rewarded_item.count < TpltInfo#time_limit_reward_tplt.count andalso
                 PassTime >= TpltInfo#time_limit_reward_tplt.cd_time of
                true ->
                    {true, Item#time_limit_rewarded_item.count, TpltInfo#time_limit_reward_tplt.ids, TpltInfo#time_limit_reward_tplt.amounts};
                false ->
                    false
            end;
        false ->
            false
    end.

get_rewarded_item(ID) ->
    List = get_rewarded_list(),
    case lists:keyfind(ID, #time_limit_rewarded_item.id, List) of
        false ->
            #time_limit_rewarded_item{id = ID, rewarded_time = #stime{year=1970, month=1, day=1, hour=0, minute=0, second=0}};
        Info ->
            Info
    end.

set_rewarded_count(ID, NewCount) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = erlang:localtime(),
    RewardedTime = #stime{year=Year, month=Month, day=Day, hour=Hour, minute=Minute, second=Second},
    set_rewarded_list(#time_limit_rewarded_item{id = ID, count = NewCount,
                                                rewarded_time = RewardedTime}).


get_rewarded_list() ->
    {_Year, _Month, Day} = erlang:date(),
    case get(time_limit_rewarded_list) of
        undefined ->
            reset_rewarded_list_in_dict(Day);
        {Info, RecordDay} ->
            case RecordDay =:= Day of
                true ->
                    Info;
                false ->
                    reset_rewarded_list_in_dict(Day)
            end
    end.

reset_rewarded_list_in_dict(Day) ->
    CacheInfo = get_rewarded_list_in_cache(),
    put(time_limit_rewarded_list, {CacheInfo, Day}),
    CacheInfo.

set_rewarded_list(NewItem) ->
    set_rewarded_list(player:get_role_id(), NewItem).

set_rewarded_list(RoleID, NewItem) ->
    io_helper:format("NewItem:~p~n", [NewItem]),
    OldList = get_rewarded_list(),
    NewList = case NewItem#time_limit_rewarded_item.count > 1 of
                  true ->
                      lists:keyreplace(NewItem#time_limit_rewarded_item.id, #time_limit_rewarded_item.id, OldList, NewItem);
                  false ->
                      [NewItem | OldList]
              end,
    io_helper:format("NewList:~p~n", [NewList]),
    {_, _, Day} = erlang:date(),
    put(time_limit_rewarded_list, {NewList, Day}),
    cache_with_expire:set("time_limit_reward:rewarded_list", RoleID, NewList, day).

get_rewarded_list_in_cache() ->
    case redis:hget("time_limit_reward:rewarded_list", player:get_role_id()) of
        undefined ->
           [];
        Info ->
            Info
    end.
%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec 获取模板奖励
%% @end
%%--------------------------------------------------------------------
get_tplt(ID) ->
    tplt:get_data(time_limit_reward_tplt, ID).
