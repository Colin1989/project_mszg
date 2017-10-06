-module(cache_controler).

-behaviour(gen_server).

-export([start_link/0, start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
        adapter,
        connection
    }).

start_link() ->
    start_link([]).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Options) ->
    AdapterName = proplists:get_value(adapter, Options, ets),
    Adapter	= list_to_atom(lists:concat(["cache_adapter_", AdapterName])),
    {ok, Conn}	= Adapter:initConn(Options),
    {ok, #state{ adapter = Adapter, connection = Conn }}.

%%redis&&ets
handle_call({get, Key, Field}, 
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:get(Conn, Key, Field), State};

handle_call(gc_worker, _From, State) ->
    erlang:garbage_collect(self()),
    {reply, ok, State};

handle_call({set, Key, Field, Value},
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:set(Conn, Key, Field, Value), State};
handle_call({delete, Key, Field}, 
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:delete(Conn, Key, Field), State};
handle_call({delete, Key}, 
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:delete(Conn, Key), State};

%%redis
handle_call({set, Key, Field, Value,Expire},
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:set(Conn, Key, Field, Value,Expire), State};

handle_call({increase, Key, Field, Expire},
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:increase(Conn, Key, Field ,Expire), State};

handle_call({get_int, Key, Field},
	    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:get_int(Conn, Key, Field), State};
handle_call({insert, Key, Val},
           _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:insert(Conn, Key, Val), State};

handle_call({is_member, Key, Val},
           _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:is_member(Conn, Key, Val), State};
handle_call({get_member_amount, Key},
           _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:get_member_amount(Conn, Key), State};
handle_call({remove, Key, Val},
           _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:remove(Conn, Key, Val), State};
handle_call({get_all_info, Key, Tab},
           _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:get_all_info(Conn, Key, Tab), State};

handle_call({getall, Key},
           _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:get_rank(Conn, Key), State};

handle_call({get_table_len, Key},
	   _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:get_table_len(Conn, Key), State};
%%end redis

%%rank Eval
handle_call({execute_cmd, Cmds},
    _From, State = #state{adapter=Adapter, connection = Conn}) ->
    {reply, Adapter:execute_cmd(Conn, Cmds), State}.
%%

handle_cast(_Request, State) ->
    {noreply, State}.

terminate(_Reason, _State = #state{adapter=Adapter, connection = Conn}) ->
    Adapter:terminate(Conn).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_info(_Info, State) ->
    {noreply, State}.
