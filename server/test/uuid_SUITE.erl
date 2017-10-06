%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%
%%% @end
%%% Created : 11 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(uuid_SUITE).

%% Note: This directive should only be used in test suites.
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include("packet_def.hrl").

%%--------------------------------------------------------------------
%% COMMON TEST CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

suite() ->
    [{timetrap,{minutes,10}}].

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
test_gen(_Config) ->
    test_helper:start("test"),
    db:delete_all("uuid_indices"),
    uuid:start(),
    72057594037927936 = uuid:gen(),
    72057594037927937 = uuid:gen(),
    72057594037927938 = uuid:gen(),
    uuid:stop(),
    timer:sleep(1000),
    uuid:start(),
    72057594037928936 = uuid:gen(),
    UIndex = db:find("uuid_index-1"),
    1000 = UIndex:idx(),
    ok.
