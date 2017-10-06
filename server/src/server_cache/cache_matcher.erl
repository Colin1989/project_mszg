%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2015, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 12 Feb 2015 by shenlk <>
%%%-------------------------------------------------------------------
-module(cache_matcher).

-behaviour(gen_server).

%% API
-export([start_link/1]).

-export([
	 new/0,
	 delete/1
	]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
	  server_queue = [],
	  new_queue = []
	 }).

%%%===================================================================
%%% API
%%%===================================================================
new() ->
    gen_server:call(?SERVER, new).

delete(ServerName) ->
    gen_server:call(?SERVER, {delete, ServerName}).
%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(Amount) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Amount], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([Amount]) ->
    ServerQueue = [{list_to_atom(lists:concat([cache_server_, Index])), 0} || Index <- lists:seq(1,Amount)],
    {ok, #state{server_queue = ServerQueue}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(new, _From, #state{server_queue = [{Name, Amount}|Left], new_queue = NewQueue}) ->
    NewState = case Left of
		   [] ->
		       #state{server_queue = [{Name, Amount+1}|NewQueue], new_queue = []};
		   _ ->
		       case NewQueue of
			   [] ->
			       [{_, M}|_] = Left,
			       case M < Amount + 1 of 
				   true ->
				       #state{server_queue = Left, new_queue = [{Name, Amount+1}|NewQueue]};
				   false ->
				       #state{server_queue = [{Name, Amount+1}|Left], new_queue = NewQueue}
			       end;
			   [{_, M}|_] ->
			       case M > Amount + 1 of 
				   false ->
				       #state{server_queue = Left, new_queue = [{Name, Amount+1}|NewQueue]};
				   true ->
				       #state{server_queue = [{Name, Amount+1}|Left], new_queue = NewQueue}
			       end
		       end
	       end,
    {reply, Name, NewState};

handle_call({delete, Name}, _From, #state{server_queue = ServerQueue, new_queue = NewQueue}) ->
    NewState = case lists:keyfind(Name, 1, ServerQueue) of
		   false ->
		       [{_, Amount}|_] = NewQueue,
		       #state{server_queue = insert_element(ServerQueue, {Name, Amount-1}), new_queue = lists:keydelete(Name, 1, NewQueue)};
		   {N, M} ->
		       #state{server_queue = insert_element(lists:keydelete(Name, 1, ServerQueue), {N, M - 1}), new_queue = NewQueue}
	       end,
    {reply, ok, NewState};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.



insert_element(List, {Name, Amount}) ->
    insert_element(List, {Name, Amount}, []).



insert_element([], undefined, List) ->
    lists:reverse(List);
insert_element([], E, List) ->
    lists:reverse([E|List]);
insert_element([L|List1], undefined, List) ->
    insert_element(List1, undefined, [L|List]);


insert_element([Element = {_, A}|List], {Name, Amount}, New) ->
    case Amount =< A of
       true ->
	    insert_element(List, undefined, [Element, {Name,Amount}|New]);
       false ->
	    insert_element(List, {Name, Amount}, [Element|New])
    end.



%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
