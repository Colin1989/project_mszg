%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2013, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 20 Dec 2013 by shenlk <>
%%%-------------------------------------------------------------------
-module(robot1).

-behaviour(gen_server).

%% API
-export([start_link/1,senddata/1,newconnect/0,breakconnect/0,breakconnect/1,newrobot/0,senddata/2]).
-include("net_type.hrl").
-include("packet_def.hrl").  
-include("enum_def.hrl").

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {socket}).

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
start_link([Ip, Port]) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Ip,Port], []).

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
init([Ip,Port]) ->
    Socket = connect(Ip, list_to_integer(Port)),
    {ok, #state{socket=Socket}}.

senddata(Data)->
    gen_server:cast(?SERVER,Data).
senddata(Pid,Data)->
    gen_server:cast(Pid,Data).

breakconnect()->
    gen_server:cast(?SERVER,breakconnect).
breakconnect(Pid)->
    gen_server:cast(Pid,breakconnect).


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
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

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
handle_cast(breakconnect,State)->
    {stop,normal,State};
handle_cast(Msg,#state{socket=Socket}=State) ->
    send_data(Socket,Msg),
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
handle_info(Info,#state{socket=Socket}= State) ->
    case Info of
	{tcp, Socket, Bin} ->
	    Binary = list_to_binary(Bin),
	    {MsgType, MsgData}= net_helper:get_data(Binary),
	    printf("receive msg:{MsgType:~p, MsgData:~p}~n", [MsgType, MsgData]),
	   %% process(Socket, MsgType, MsgData),
	    {noreply,State};
	{tcp_closed, Socket} ->
	    printf("tcp close~n"),
	    {stop,"tcp close~n",State}
    end.
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

%%%===================================================================
%%% Internal functions
%%%===================================================================
connect(Ip, Port) -> 
    {ok, Socket} = gen_tcp:connect(Ip, Port, [{packet, 4}]),
    Socket.

printf(_Str) ->
    io_helper:format(_Str),
    ok. 

printf(_Str, _Params) ->
    case _Params of
	[?msg_notify_heartbeat|_]->ok;
	_->io_helper:format(_Str, _Params)
    end.

send_data(Socket, Data) ->
    {Type, Binary} = protocal:encode(Data),
    Msg = net_helper:make_net_binary(Type, Binary),
    gen_tcp:send(Socket, Msg),
    ok.

newconnect()->
    start_link(["127.0.0.1","8001"]).

newrobot()->
    case gen_server:start_link(?MODULE, ["127.0.0.1","8001"], []) of
	{ok,Pid}->
	    Pid;
	_ ->
	    failed
    end.
