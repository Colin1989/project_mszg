-module(cache_sup).
-author('shen_likun@163.com').

-behaviour(supervisor).

-export([start_link/0, start_link/1]).

-export([init/1]).

start_link() ->
    start_link([]).

start_link(StartArgs) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, StartArgs).

init(StartArgs) ->
    Args = [{name, {local, server_cache_pool}},
	    {worker_module, cache_controler},
	    {size, 5}, {max_overflow, 40}|StartArgs],
    PoolSpec = 
	{cache_controller, 
	 {poolboy, start_link, [Args]}, 
	 permanent, 2000, worker, [poolboy]},
    {ok, {{one_for_one, 10, 10}, [PoolSpec]}}.
