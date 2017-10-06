%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2015, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 12 Feb 2015 by shenlk <>
%%%-------------------------------------------------------------------
-module(cache_server_sup).

-behaviour(supervisor).

%% API
-export([start_link/2]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(Options, Adapter) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, [Options, Adapter]).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([Options, Adapter]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    %%Restart = permanent,
    %%Shutdown = 2000,
    %%Type = worker,

    %%AChild = {'AName', {'AModule', start_link, []},
    %%	      Restart, Shutdown, Type, ['AModule']},
    Childs = [{list_to_atom(lists:concat([cache_server_, Index])), 
	       {Adapter, start, [Options, Index]}, 
	       permanent, 2000, worker, [Adapter]}||Index <- lists:seq(1,get_amount(Options))],
    

    {ok, {SupFlags, Childs}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_amount(Options) ->
    proplists:get_value(amount, Options, 1).
