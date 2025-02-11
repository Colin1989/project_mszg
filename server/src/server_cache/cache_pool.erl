-module(cache_pool).
-export([call/2, call/3]).

call(Pool, Msg) ->
    Worker = poolboy:checkout(Pool),
    Reply = gen_server:call(Worker, Msg),
    ok = gen_server:call(Worker, gc_worker),
    poolboy:checkin(Pool, Worker),
    Reply.

call(Pool, Msg, Timeout) ->
    Worker = poolboy:checkout(Pool),
    Reply = gen_server:call(Worker, Msg, Timeout),
    ok = gen_server:call(Worker, gc_worker),
    poolboy:checkin(Pool, Worker),
    Reply.
