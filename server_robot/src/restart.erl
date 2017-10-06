-module(restart).

-export([start/1]).

start([Address]) ->
    rpc:call(Address, init, restart, []).
