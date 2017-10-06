-module (cache_adapter_ets).
-author('shen_likun@163.com').
-behaviour(gen_server).
-behaviour(cache_adapter).
-define(SERVER,cache_ets_server).
-export([initConn/1, start/0, start/1, stop/1, terminate/1]).
-export([get/3, set/4, delete/2, delete/3,hello/0,set/5]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).
-spec start() -> 'ok'.
%%-spec start(_) -> 'ok'.
-spec stop(_) -> 'ok'.
-spec initConn(_) -> {'ok','undefined'}.
-spec terminate(_) -> 'ok'.
-spec get(_,atom() | string() | number(),_) -> any().
-spec set(_,atom() | string() | number(),_,_) -> 'ok'.
-spec delete(_,atom() | string() | number(),_) -> 'ok'.

start() ->
    %%cache_server:start_link(),
    %%check_server:start_link(),
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
start(_Options)->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
%%start(Options) ->
    %%cache_server:start_link(Options),
    %%check_server:start_link(Options),
%%    ok.

stop(_Conn) ->
    %%cache_server:stop(),
    %%check_server:stop(),
    ok.

initConn(_Options) ->
    {ok, ?SERVER}.

terminate(_Conn) ->
    ok.

get(_Conn,Key, Field) ->
    gen_server:call(_Conn,{get,Key,Field}).

    

set(_Conn,Key, Field, Val) ->
    gen_server:call(_Conn,{set,Key,Field,Val}).
set(_Conn,Key, Field, Val,_Expire) ->
    gen_server:call(_Conn,{set,Key,Field,Val}).

delete(_Conn,Key, Field) ->
    gen_server:call(_Conn,{delete,Key,Field}).

delete(_Conn, Key) ->
    gen_server:call(_Conn,{delete,Key}).

hello()->
    ok.
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
init(_Args)->
    {ok,{}}.
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
handle_call({set,Key,Field,Val}, _From, State) ->
    case ets:info(Key) of
	undefined->
	    ets:new(Key,[ordered_set, private, named_table]);
	_->ok
    end,
    Reply=ets:insert(Key,{Field,Val}),
    {reply, Reply, State};
handle_call({get,Key,Field}, _From, State) ->
    case ets:info(Key) of
	undefined->
	    {reply, [], State};
	_->
	    Reply=ets:lookup(Key,Field),
	    {reply, Reply, State}
    end;
handle_call({delete,Key,Field}, _From, State) ->
    case ets:info(Key) of
	undefined->
	    {reply,true, State};
	_->
	    Reply=ets:delete(Key,Field),
	    {reply, Reply, State}
    end;

handle_call({delete,Key}, _From, State) ->
    case ets:info(Key) of
	undefined->
	   {reply, ok, State};
	_->
	    Reply=ets:delete(Key),
	    {reply, Reply, State}
    end;
   
handle_call(_Request, _From, State) ->
    {noreply, State}.

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
handle_cast(_Msg,State) ->
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
handle_info(_Info,State) ->
   {noreply, State}.
   %% {noreply, State}.

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


