%%%-------------------------------------------------------------------
%%% @author linyijie <>
%%% @copyright (C) 2013, linyijie
%%% @doc
%%%
%%% @end
%%% Created : 11 Nov 2013 by linyijie <>
%%%-------------------------------------------------------------------
-module(tplt_mock_SUITE).

%% Note: This directive should only be used in test suites.
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-include("test_helper.hrl").
-include("packet_def.hrl").

%%--------------------------------------------------------------------
%% COMMON TEST CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

suite() ->
    [{timetrap,{minutes,10}}].

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

all() ->
    [ {exports, Functions} | _ ] = ?MODULE:module_info(),
    [ FName || {FName, _} <- lists:filter(
                               fun ({module_info,_}) -> false;
                                   ({all,_}) -> false;
                                   ({init_per_suite,1}) -> false;
                                   ({end_per_suite,1}) -> false;
                                   ({_,1}) -> true;
                                   ({_,_}) -> false
                               end, Functions)].


%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------
test_tplt_mock(_Config) ->
    Data1 = {item, 1, "item-1"},
    tplt_mock:find_mock(Data1),
    Data1 = tplt:find(item, 1),
    tplt_mock:stop(),

    Data2 = {a, 1, "a"},
    Data3 = {b, 2, "b"},
    tplt_mock:find_mock([Data2, Data3]),
    Data2 = tplt:find(a, 1),
    Data3 = tplt:find(b, 2),
    ?assertException(error, {not_found_data, a, 3}, tplt:find(a, 3)),
    tplt_mock:stop(),

    Data4 = [{a, 1}, {a, 2}, {a, 3}, {a, 4}, {a, 5}],
    tplt_mock:get_all_mock(Data4),
    Data4 = tplt:get_all(a),
    ?assertException(error, {not_found_data, b}, tplt:get_all(b)),
    ok.
