%%%-------------------------------------------------------------------
%%% @author linyijie <>
%%% @copyright (C) 2013, linyijie
%%% @doc
%%%
%%% @end
%%% Created : 11 Nov 2013 by linyijie <>
%%%-------------------------------------------------------------------
-module(test_helper_SUITE).

%% Note: This directive should only be used in test suites.
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include("packet_def.hrl").

%%--------------------------------------------------------------------
%% COMMON TEST CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

suite() ->
    [{timetrap,{minutes,10}}].

init_per_testcase(_TestCase, Config) ->
    test_helper:start(),
    Config.

end_per_testcase(_TestCase, _Config) ->
    test_helper:stop(),
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
test_packet(_Config) ->
    Packet = #req_login{version=1, account="a", password="b"},
    packet:send(Packet),
    {ok, this, Packet} = test_helper:get_packet(),

    Account = "test",
    packet:send(Account, Packet),
    {ok, Account, Packet} = test_helper:get_packet(),
    ok.

test_db(_Config) -> 
    undefined = db:find("item-1"),
    ok.
