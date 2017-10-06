%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  唯一id
%%% @end
%%% Created : 27 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(uuid).

-behaviour(gen_server).

%% API
-export([start/0, stop/0, start_link/0, gen/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
%% 每间隔多少, 存一次数据到硬盘, 防止因每次生成一次id都需要对硬盘进行操作, 提高效率
-define(INDEX_INTERVAL, 1000).  

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start() ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
    gen_server:cast(?SERVER, stop).

gen() ->
    gen_server:call(?SERVER, generate).


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
init([]) ->
    put(uuid, true),
    Node = atom_to_list(node()),
    [ID, _] = string:tokens(Node, "@"),
    ServerID = list_to_integer(ID),
    put(server_id, ServerID),
    StartIndex = get_start_index(),
    CurrID = make_id(ServerID, StartIndex),
    put(curr_id, CurrID),
    {ok, #state{}}.

make_id(ServerID, Index) ->
    <<CurrID:64>> = <<ServerID:8, Index:56>>,
    CurrID.

get_index(UUID) ->
    <<_ServerID:8, Index:56>> = <<UUID:64>>,
    Index.


get_start_index() ->
    ServerID = get(server_id),
    case db:find(uuid_index,[{server_id,'equals',ServerID}]) of
	[] ->
	    Index = 0,
	    UIndex = uuid_index:new(id,ServerID, Index),
	    {ok, Result} = UIndex:save(),
	    set_uuid_index(Result),
	    Index;
	[UIndex|_] ->
	    NextIndex = get_next_start_index(UIndex:idx()),
	    UIndex1 = UIndex:set(idx, NextIndex),
	    {ok, Result} = UIndex1:save(),
	    set_uuid_index(Result),
	    NextIndex
    end.

get_next_start_index(CurrIndex)->
    Rem = CurrIndex rem ?INDEX_INTERVAL,
    Rest = (CurrIndex - Rem) div ?INDEX_INTERVAL, 
    (Rest + 1) * ?INDEX_INTERVAL.

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
handle_call(generate, _From, State) ->
    CurrID = get(curr_id),
    CurrID1 = CurrID + 1,
    put(curr_id, CurrID1),
    Index = get_index(CurrID1),
    %% 每间隔?INDEX_INTERVAL之后再写硬盘
    Rem = Index rem ?INDEX_INTERVAL,
    io_helper:format("Rem:~p, Index:~p~n", [Rem, Index]),
    case Rem == 0 of
	true -> 
	    
	    %%[UIndex] = db:find(uuid_index,[{server_id,'equals',ServerID}]),
	    %%UIndex = db:find("uuid_index-1"),
	    UIndex = get_uuid_index(),
	    NUIndex = UIndex:set(idx, Index),
	    {ok, _} = NUIndex:save(),
	    set_uuid_index(NUIndex),
	    CurrID1;
	false -> ok
    end,    
    {reply, CurrID, State}.

get_uuid_index() ->
    get(db_uuid).
    %% case get(db_uuid) of
    %% 	undefined ->
    %% 	    ServerID = get(server_id),
    %% 	    [UIndex] = db:find(uuid_index,[{server_id,'equals',ServerID}]),
    %% 	    put(db_uuid, UIndex),
    %% 	    UIndex;
    %% 	UIndex1 ->
    %% 	    UIndex1
    %% end.

set_uuid_index(NUIndex) ->
    put(db_uuid, NUIndex).


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
handle_cast(stop, State) ->
    {stop, normal, State};
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
