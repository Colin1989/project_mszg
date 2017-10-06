-module(game_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start() ->
    start([], []).

start(_StartType, StartArgs) ->
    game_sup:start_link(StartArgs).

stop(_State) ->
    ok.
