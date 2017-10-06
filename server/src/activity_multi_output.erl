%%%-------------------------------------------------------------------
%%% @author wanghl
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%    多倍产出活动
%%% @end
%%% Created : 15. 一月 2015 10:53
%%%-------------------------------------------------------------------
-module(activity_multi_output).
-author("wanghl").

%% API
-export([get_exp_multi_num/0,
         start/0,
         init_notify/0]).

start() ->
    ok.

init_notify() ->
    ok.


get_exp_multi_num() ->
    case activities:is_open(activities:module_to_index(activity_multi_output)) of
        true ->
            config:get(act_exp_multi);
        false ->
            1
    end.