%%%-------------------------------------------------------------------
%%% @author linyijie <>
%%% @copyright (C) 2013, linyijie
%%% @doc
%%%
%%% @end
%%% Created : 11 Nov 2013 by linyijie <>
%%%-------------------------------------------------------------------
-module(test_helper).
-export([start/0, start/1, stop/0, get_packet/0, send_mock/0]).

start() ->
    start("test").

start(DB) ->
    {ok, BossDBPid} = boss_db:start([{adapter, mysql},
				     {db_host, "127.0.0.1"},
				     {db_port, 3306},
				     {db_database, DB},
				     {db_username, "root"},
				     {db_password, ""}
				    ]),
    put(boss_db_pid, BossDBPid),
    {ok, BossNewsPid} = boss_news:start(),
    put(boss_news_pid, BossNewsPid),
    timer:sleep(30),
    db_update:start(),
    %%MockPid = global:whereis_name(boss_db_mock_sup),
    %%put(mock_pid, MockPid),
    send_mock(),
    ok.

stop() ->
    meck:unload(),
    exit(get(mock_pid), normal),
    exit(get(boss_news_pid), normal),
    exit(get(boss_db_pid), normal),
    ok.
    
get_packet() ->
    receive
	{packet, Account, Packet} ->
	    {ok, Account, Packet}
    after 0 -> 
	    {error, timeout}
    end.

send_mock() ->
    meck:new(packet, [no_link]),
    meck:expect(packet, send, 1, fun(Packet) -> self() ! {packet, this, Packet} end),
    meck:expect(packet, send, 2, fun(Account,Packet) -> self() ! {packet, Account, Packet} end),
    ok.
