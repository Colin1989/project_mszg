%%%-------------------------------------------------------------------
%%% @author wanghl
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 一月 2015 10:59
%%%-------------------------------------------------------------------
-module(activities).
-author("wanghl").

-include("tplt_def.hrl").
-include("packet_def.hrl").

%% API
-export([
    init_notify/0,
    get_act_remain_second/1,
    module_to_index/1]).

-compile(export_all).

start() ->
    activity_recharge:start(),
    activity_lottery:start(),
    ok.

init_notify() ->
    List = get_cur_acts(),
    packet:send(#notify_activity_list{list = List}),
    init_activities(List).

init_activities(List) ->
    lists:map(
        fun(ActItem) ->
            Module = index_to_module(ActItem#activity_item.id),
           %% Module:start(),
            Module:init_notify()
        end,
        List).

index_to_module(Index) ->
    ModuleList = get_module_list(),
    {_Tag, ModuleName} = lists:keyfind(Index, 1, ModuleList),
    ModuleName.

module_to_index(ModuleName) ->
    ModuleList = get_module_list(),
    {Index, _Name} = lists:keyfind(ModuleName, 2, ModuleList),
    Index.

get_module_list() ->
    [{1, activity_lottery},{2, activity_recharge}, {3, activity_multi_output}].


%% get_cur_activities() ->
%%     F = fun({_Key, Value}, AccIn)-> [Value | AccIn] end,
%%     lists:reverse(ets:foldl(F, [], cur_activities)).



%%--------------------------------------------------------------------
%% @doc
%% @spec 模板重新加载时，更新缓存里的活动
%% @end
%%--------------------------------------------------------------------
%% update_activities() ->
%%     CurActTplts = get_cur_acts(),
%%     lists:foreach(
%%         fun(X) ->
%%             RemainSecond = get_act_remain_second_by_id(X#activity_tplt.id),
%%             cache:set('activities', X#activity_tplt.id, X#activity_tplt.end_time_array, RemainSecond)
%%         end,
%%         CurActTplts).


get_cur_acts() ->
    Alltplt = tplt:get_all_data(activity_tplt),
    lists:foldl(
        fun(X, CurList) ->
            case is_open_by_tplt(X) of
                true ->
                    RemainSecond = get_act_remain_second_by_id(X#activity_tplt.id),
                    ActItem = #activity_item{id = X#activity_tplt.id, remain_seconds = RemainSecond},
                    [ActItem | CurList];
                false ->
                    CurList
            end
        end,
        [], Alltplt).

get_act_remain_second(ActName) ->
    ID = module_to_index(ActName),
    get_act_remain_second_by_id(ID).

get_act_remain_second_by_id(ID) ->
    CurSeconds = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
    [EndDate, EndTime] = get_tplt_end_time(ID),
    case datetime:datetime_to_gregorian_seconds({EndDate, EndTime}) - CurSeconds of
        RemainSeconds when RemainSeconds > 0 ->
            RemainSeconds;
        _ ->
            0
    end.

is_open(ID) ->
    TpltInfo = get_tplt(ID),
    is_open_by_tplt(TpltInfo).

is_open_by_tplt(TpltInfo) ->
    CurSeconds = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
    [Date, Time] = TpltInfo#activity_tplt.begin_time_array,
    [Date2, Time2] = TpltInfo#activity_tplt.end_time_array,
    CurSeconds >= datetime:datetime_to_gregorian_seconds({Date, Time}) andalso
    CurSeconds =< datetime:datetime_to_gregorian_seconds({Date2, Time2}).


get_tplt_end_time(ID) ->
    Info = get_tplt(ID),
    Info#activity_tplt.end_time_array.

get_tplt(ID) ->
    tplt:get_data(activity_tplt, ID).

