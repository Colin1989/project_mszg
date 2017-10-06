%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 23 Jul 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(broadcast_server).

-behaviour(gen_server).

%% API
-export([start_link/0]).

-export([broadcast_packet/3]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {traffic_limit, msg_queue}).
-record(msg_data, {length, data, send_list}).

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
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).



broadcast_packet(Pids, Packet, Priority) ->
    PacketLength = get_packet_length(Packet),
    gen_server:cast(?MODULE, {Pids, Packet, Priority, PacketLength}).


    




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
    start_broadcast(),
    {ok, #state{traffic_limit = config:get_server_config(broadcast_limit), msg_queue =[]}}.



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
handle_cast({Pids, Packet, Priority, PacketLength}, #state{msg_queue = MsgQueue} = State) ->
    %%io:format("111111~n"),
    case lists:keyfind(Priority, 1, MsgQueue) of
	false ->
	    {noreply, State#state{msg_queue = [{Priority, [#msg_data{length = PacketLength, data = Packet, send_list = Pids}]}|MsgQueue]}};
	{_, Lists} ->
	    NewList = lists:reverse([#msg_data{length = PacketLength, data = Packet, send_list = Pids}|lists:reverse(Lists)]),
	    {noreply, State#state{msg_queue = lists:keyreplace(Priority, 1, MsgQueue, {Priority, NewList})}}
    end;
handle_cast(do_broadcast, State) ->
    %%io:format("111112~n"),
    NewState = proc_broadcast(State),
    {noreply, NewState};
handle_cast(_Msg, State) ->
    %%io:format("111113~n"),
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
proc_broadcast(#state{msg_queue = MsgQueue, traffic_limit = TrafficLimit} = State) ->
    case MsgQueue of
	[] ->
	    start_broadcast(),
	    State;
	_ ->
	    NQueue = lists:keysort(1, MsgQueue),
	    {NewMsgQueue, Msgs} = get_msg_to_send(NQueue, TrafficLimit, []),
	    %%io:format("Msgs:~p,NewMsgQueue:~p~n", [Msgs, NewMsgQueue]),
	    start_broadcast(),
	    spawn(?MODULE, process_broadcast, [lists:reverse(Msgs)]),
	    State#state{msg_queue = NewMsgQueue}
   end.



%%process broadcast
process_broadcast([]) ->
    ok;
process_broadcast([{Data, SendList}|Msgs]) ->
    lists:foreach(fun(Pid)-> spawn(?MODULE, send_msg, [Pid, Data]) end, SendList),
    process_broadcast(Msgs).


%%process send msg to the pid
send_msg(Pid, Data) ->
    timer:sleep(rand:uniform(1000)),
    packet:send(Pid, Data).





%%get the msg to send
get_msg_to_send([], _, CurQueue) ->
    {[], CurQueue};

get_msg_to_send(MsgQueues, 0, CurQueue) ->
    {MsgQueues, CurQueue};



get_msg_to_send([{Priority, MsgQueue}|MsgQueues], TrafficLimit, CurQueue) ->
    [#msg_data{length = Length, send_list = SendList, data = Data}|Msgs] = MsgQueue,
    MaxAmount = TrafficLimit div Length,
    SendListLength = length(SendList),
    case MaxAmount >= SendListLength of
	true ->
	    case Msgs of
		[] ->
		    get_msg_to_send(MsgQueues, TrafficLimit - Length * SendListLength, [{Data, SendList}|CurQueue]);
		_ ->
		    get_msg_to_send([{Priority, Msgs}|MsgQueues], TrafficLimit - Length * SendListLength, [{Data, SendList}|CurQueue])
	    end;
	false ->
	    case MaxAmount of
		0 ->
		    {[{Priority, MsgQueue}|MsgQueues], CurQueue} ;
		_ ->
		    lists:sublist(SendList, MaxAmount),
		    {[{Priority, [#msg_data{length = Length, data = Data, 
					    send_list = lists:sublist(SendList, MaxAmount + 1, SendListLength - MaxAmount)}|Msgs]}|MsgQueues], 
		     [{Data, lists:sublist(SendList, MaxAmount)}|CurQueue]}
	    end
    end.
    
    
    


%%get the length of the packet to send
get_packet_length(Packet) ->
    {Type, Binary} = protocal:encode(Packet),
    MyStep = 1,
    RecvStep = 2,
    Bin = net_helper:make_net_binary(Type, Binary, MyStep, RecvStep),
    length(binary_to_list(Bin)).


%%start a new broadcast
start_broadcast() ->
    spawn(?MODULE, do_broadcast, [self()]).



do_broadcast(Pid) ->
    %%io:format("%%%%%%%%%%%%%%%%%%ddddd~n"),
    timer:sleep(1000),
    gen_server:cast(Pid, do_broadcast).


