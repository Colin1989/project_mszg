%%%-------------------------------------------------------------------
%%% @author linyibin
%%% @copyright (C) 2010, linyibin
%%% @doc
%%%  ÓÎÏ··þÎñÆ÷
%%% @end
%%% Created : 17 Aug 2010 by linyibin
%%%-------------------------------------------------------------------
-module(gamesvr).

-export([start/0, stop/0, stop/1]).


start()->
    %ok = application:start(crypto),
    ok = application:start(asn1),
    ok = application:start(public_key),
    ok = application:start(ssl),

    io:format("start game server...~n"),
    ok = application:start(mongodb),


    %% ok =  application:start(tcp_server),
    ok = application:start(server).

stop() ->
    stop(server).

stop(AppFile) ->
    application:stop(AppFile).


