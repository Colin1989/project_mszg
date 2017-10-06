-module(gate).
-export([start/0, start/1, stop/0, stop/1]).


start()->
    start([tcp_server]).

start([AppFile]) when is_list(AppFile) ->

    io_helper:format("start gate server...~n"),

    %%application:start(exmpp),
    Ret = application:start(AppFile),
    io_helper:format("start gate server success...~n"),
    Ret.

stop() ->
    stop(tcp_server).

stop(AppFile) ->
    application:stop(AppFile).


