-module(tcp_mm).
-author('saleyn@gmail.com').

-behaviour(gen_fsm).
-include("packet_def.hrl"). 
-include("enum_def.hrl").
-include("tcp_mm_data.hrl").
-include("sys_msg.hrl").

-export([start_link/0, start_link/1, set_socket/3, repeat_login_stop/1, stop/1, get_queue_from_cache/0, resend_packet/1, get_resend_packets/2]).

%% gen_fsm callbacks
-export([init/1, handle_event/3,
         handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

%% FSM States
-export([
	 'WAIT_FOR_SOCKET'/2,
	 'WAIT_FOR_DATA'/2,
	 'WAIT_FOR_AUTH'/2,
	 'WAIT_FOR_DATA'/3,
	 'WAIT_FOR_AUTH'/3
]).

%% -record(state, {
%%                 socket,    	% client socket
%%                 addr,       % client address
%% 				account
%%                }).

-define(TIMEOUT, infinity).

-define(KEEPALIVE_TIME, 300 * 1000).

%%%------------------------------------------------------------------------
%%% API
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% @spec (Socket) -> {ok,Pid} | ignore | {error,Error}
%% @doc To be called by the supervisor in order to start the server.
%%      If init/1 fails with Reason, the function returns {error,Reason}.
%%      If init/1 returns {stop,Reason} or ignore, the process is
%%      terminated and the function returns {error,Reason} or ignore,
%%      respectively.
%% @end
%%-------------------------------------------------------------------------
start_link() ->
    gen_fsm:start_link(?MODULE, [], []).
start_link([]) ->
    start_link().

stop(Pid) ->
    gen_fsm:send_event(Pid, stop).

%% 因重复登陆停止
repeat_login_stop(Pid) ->
    gen_fsm:send_event(Pid, repeat_login_stop).


set_socket(Pid, Socket, Status) when is_pid(Pid), is_port(Socket) ->
    gen_fsm:send_event(Pid, {socket_ready, Socket, Status}).

%%%------------------------------------------------------------------------
%%% Callback functions from gen_server
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok, StateName, StateData}          |
%%          {ok, StateName, StateData, Timeout} |
%%          ignore                              |
%%          {stop, StopReason}
%% @private
%%-------------------------------------------------------------------------
init([]) ->
    process_flag(trap_exit, true),
    io_helper:start(),
    {ok, 'WAIT_FOR_SOCKET', #tcp_mm_data{}}.


notify_refuse_becauseof_busy(Socket) ->
    {Type, Binary} = protocal:encode(#notify_sys_msg{code = ?sg_service_is_busy_now, params = []}),
    Bin = net_helper:make_net_binary(Type, Binary, 1, 0),
    gen_tcp:send(Socket, Bin).


%%-------------------------------------------------------------------------
%% Func: StateName/2
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% @private
%%-------------------------------------------------------------------------
'WAIT_FOR_SOCKET'({socket_ready, Socket, Status}, State) when is_port(Socket) ->
						% Now we own the socket
    inet:setopts(Socket, [{active, once}, {packet, 4}, binary]),
    case Status of
	1 ->
	    case inet:peername(Socket) of
		{ok, {IP, _Port}} ->
		    erlang:start_timer(?KEEPALIVE_TIME, self(), []),
		    io_helper:format("IP:~p~n", [IP]),
		    put_socket(Socket),
		    put(ip, IP),
		    %% {ok, Pid} = player:start_link(self()),
		    %% put(player_pid, Pid),
		    {next_state, 'WAIT_FOR_AUTH', State#tcp_mm_data{socket=Socket, addr=IP}, ?TIMEOUT};
		{error,enotconn} ->
		    {stop, normal, State};
		{error, _} ->
		    io:format("Port:~p, PortInfo:~p~n", [Socket, erlang:port_info(Socket)]),
		    {stop, normal, State}
	    end;
	2 ->
	    put_socket(Socket),
	    notify_refuse_becauseof_busy(Socket),
	    {stop, normal, State#tcp_mm_data{socket=Socket}}	
    end;
'WAIT_FOR_SOCKET'(Other, State) ->
    io_helper:format("Other:~p~n", [Other]),
    error_logger:error_msg("State: 'WAIT_FOR_SOCKET'. Unexpected message: ~p\n", [Other]),
    %% Allow to receive async messages
    {next_state, 'WAIT_FOR_SOCKET', State}.

'WAIT_FOR_AUTH'({data, Binary}, #tcp_mm_data{socket=_Socket, packet_count=PacketCount}=State) ->
    NPacketCount = 
	case PacketCount >= 255 of
	    true -> 1;
	    _ -> PacketCount + 1
	end,
    {DecodeData, ClientLastRecv} = net_helper:get_data(Binary, NPacketCount),
    clear_queue_by_step(ClientLastRecv),
    set_last_recv_stepnum(NPacketCount),
    io_helper:format("~p~n", [DecodeData]),
    case player_auth:call(DecodeData) of
	{next_state, wait_for_auth} ->
	    {next_state, 'WAIT_FOR_AUTH', State#tcp_mm_data{packet_count=NPacketCount}};
	{next_state, wait_for_data} ->
	    {next_state, 'WAIT_FOR_DATA', State#tcp_mm_data{packet_count=NPacketCount}}
    end;
'WAIT_FOR_AUTH'(timeout, State) ->
    error_logger:error_msg("~p Client connection timeout - closing.\n", [self()]),
    {stop, normal, State};
'WAIT_FOR_AUTH'(Data, State) ->
    io_helper:format("~p Ignoring data: ~p\n", [self(), Data]),
    {next_state, 'WAIT_FOR_DATA', State, ?TIMEOUT}.


'WAIT_FOR_AUTH'(repeat_login_stop, From, #tcp_mm_data{socket=Socket}=State) ->
    write_queue_to_cache(),
    Packet = #notify_repeat_login{},
    %% {Type, Binary} = protocal:encode(Packet),
    %% Bin = net_helper:make_net_binary(Type, Binary),  
    %% gen_tcp:send(Socket, Bin),
    proc_packet_send(Socket, Packet),
    
    %%Pid = get(player_pid),
    %%gen_server:call(Pid, {tcp_closed}),
    put(is_repeat,true),
    gen_fsm:reply(From, ok),
    {stop, normal, State}.


%% Notification event coming from client
'WAIT_FOR_DATA'({data, Binary}, #tcp_mm_data{socket=_Socket, packet_count=PacketCount}=State) ->
    NPacketCount = 
	case PacketCount >= 255 of
	    true -> 1;
	    _ -> PacketCount + 1
	end,
    {Packet, ClientLastRecv} = net_helper:get_data(Binary, NPacketCount),
    clear_queue_by_step(ClientLastRecv),
    set_last_recv_stepnum(NPacketCount),
    %% Packet = net_helper:get_data(Binary, NPacketCount),
    %% clear_queue_by_step(NPacketCount),
    %% set_last_recv_stepnum(NPacketCount),
    io_helper:format("Data:~p~n", [Packet]),
    Pid = get(player_pid),
    gen_server:cast(Pid, {packet, Packet}),
    {next_state, 'WAIT_FOR_DATA', State#tcp_mm_data{packet_count=NPacketCount}, ?TIMEOUT};

'WAIT_FOR_DATA'(timeout, #tcp_mm_data{account=Account}=State) ->
    error_logger:error_msg("Account:~p Client connection timeout - closing.\n", [Account]),
    {stop, normal, State};

'WAIT_FOR_DATA'(stop, State) ->
    {stop, normal, State};

'WAIT_FOR_DATA'(repeat_login_stop, #tcp_mm_data{socket=Socket}=State) ->
    Packet = #notify_repeat_login{},
    %% {Type, Binary} = protocal:encode(Packet),
    %% Bin = net_helper:make_net_binary(Type, Binary),  
    %% gen_tcp:send(Socket, Bin),
    proc_packet_send(Socket, Packet),
    {stop, normal, State};


'WAIT_FOR_DATA'(Data, State) ->
    io_helper:format("~p Ignoring data: ~p\n", [self(), Data]),
    {next_state, 'WAIT_FOR_DATA', State, ?TIMEOUT}.


'WAIT_FOR_DATA'(repeat_login_stop, From, #tcp_mm_data{socket=Socket}=State) ->
    Packet = #notify_repeat_login{},
    %% {Type, Binary} = protocal:encode(Packet),
    %% Bin = net_helper:make_net_binary(Type, Binary),  
    %% gen_tcp:send(Socket, Bin),
    write_queue_to_cache(),
    proc_packet_send(Socket, Packet),


    %%Pid = get(player_pid),
    %%gen_server:call(Pid, {tcp_closed}),
    put(is_repeat,true),
    gen_fsm:reply(From, ok),
    {stop, normal, State}.






%%-------------------------------------------------------------------------
%% Func: handle_event/3
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% @private
%%-------------------------------------------------------------------------
handle_event(_Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

%%-------------------------------------------------------------------------
%% Func: handle_sync_event/4
%% Returns: {next_state, NextStateName, NextStateData}            |
%%          {next_state, NextStateName, NextStateData, Timeout}   |
%%          {reply, Reply, NextStateName, NextStateData}          |
%%          {reply, Reply, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}                          |
%%          {stop, Reason, Reply, NewStateData}
%% @private
%%-------------------------------------------------------------------------
%% handle_sync_event(repeat_login_stop, _From, StateName, StateData)->
%%     io:format("############################repeat_login:~p##################",[StateName]),
%%     ?MODULE:StateName(repeat_login_stop,StateData);

handle_sync_event(Event, _From, StateName, StateData) ->
    {stop, {StateName, undefined_event, Event}, StateData}.



%%-------------------------------------------------------------------------
%% Func: handle_info/3
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% @private
%%-------------------------------------------------------------------------
handle_info({send2client, Packet}, StateName, #tcp_mm_data{socket=Socket} = StateData) ->
    %%io_helper:format("***Test:~p~n", [Bin]),
    %%io:format("~p~n", [StateName]),

    
    %%gen_tcp:send(Socket, Bin),
    special_process(Packet),
    proc_packet_send(Socket, Packet),
    case get(player_pid) of
	undefined ->
	    ok;
	Pid ->
	    erlang:garbage_collect(Pid)
    end,
    {next_state, StateName, StateData, ?TIMEOUT};
handle_info({recv_from_gm, Packet}, StateName, StateData) ->
    Pid = get(player_pid),
    gen_server:cast(Pid, {packet, Packet}),
    {next_state, StateName, StateData, ?TIMEOUT};
handle_info({timeout, _TimerRef, _Msg}, StateName, #tcp_mm_data{socket=Socket} = StateData) ->
    %%{Type, Binary} = protocal:encode(#notify_heartbeat{}),
    %%Bin = net_helper:make_net_binary(Type, Binary), 
    %%case gen_tcp:send(Socket, Bin) of
    Packet = #notify_heartbeat{version = ?proto_ver},
    {Type, Binary} = protocal:encode(Packet),
    MyStep = gen_new_step(),
    RecvStep = get_last_recv_stepnum(),
    Bin = net_helper:make_net_binary(Type, Binary, MyStep, RecvStep),
    add_to_queue({MyStep, Packet}),


    %%gen_tcp:send(Socket, Bin),
    %%case proc_packet_send(Socket, #notify_heartbeat{}) of
    case gen_tcp:send(Socket, Bin) of
	ok ->
	    erlang:start_timer(?KEEPALIVE_TIME, self(), []),
	    {next_state, StateName, StateData, ?TIMEOUT};
	{error, Reason} ->
	    error_logger:error_msg("socket send data error, Reason: ~p\n", [Reason]),
	    {stop, normal, StateData}
    end;
handle_info({tcp, Socket, Bin}, StateName, #tcp_mm_data{socket=Socket} = StateData) ->
    % Flow control: enable forwarding of next TCP message
    io_helper:format("recv data:~p~n", [Bin]),
    inet:setopts(Socket, [{active, once}]),
    ?MODULE:StateName({data, Bin}, StateData);
handle_info({repeat_login_stop},StateName,StateData)->
	?MODULE:StateName(repeat_login_stop,StateData);

handle_info({be_kick}, _StateName, #tcp_mm_data{socket=Socket} = StateData) ->
    Packet = #notify_sys_msg{code = ?sg_service_be_kick, params = []},
    %% {Type, Binary} = protocal:encode(Packet),
    %% Bin = net_helper:make_net_binary(Type, Binary),  
    %% gen_tcp:send(Socket, Bin),
    proc_packet_send(Socket, Packet),
    {stop, normal, StateData};

    

handle_info({tcp_closed, _Socket}, _StateName, StateData) ->
	%%io:format("tcp close~n",[]),
    {stop, normal, StateData};
handle_info({tcp_error, _Socket, _Error}, _StateName, StateData) ->
    %%io:format(error, "tcp_error:" ++ Error),
    {stop, normal, StateData};
handle_info({'EXIT', _Pid, {shutdown, {reselect_role, User}}}, _StateName, StateData) ->
 	player_auth:init_player_info(User),
    {next_state, 'WAIT_FOR_AUTH', StateData, ?TIMEOUT};
handle_info({'EXIT', _Pid, Reason}, _StateName, StateData) ->
    {stop, Reason, StateData};

handle_info(Info, StateName, StateData) ->
    io_helper:format("tcp_mm unhandle info: ~p~n", [Info]),
    get(player_pid)! ok,
    {next_state, StateName, StateData}.



%%-------------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% @private
%%-------------------------------------------------------------------------
terminate(Reason, _StateName, #tcp_mm_data{socket=Socket}) ->
    case get(is_repeat) of
	undefined ->
	    PlayerID = player:get_player_id(),
	    write_queue_to_cache(),
	    account_pid_mapping:unmapping(PlayerID);
	_ ->
	    
	    ok
    end,
    %%Bin = net_helper:make_net_binary(protocal:encode(#notify_socket_close{})),
    %%gen_tcp:send(Socket, Bin),
    %%write_queue_to_cache(),
    case Socket of
	undefined ->
	    ok;
	_ ->
	    proc_packet_send(Socket, #notify_socket_close{}),
	    gen_tcp:close(Socket)
    end,
    gen_server:cast(tcp_listener, {client_destroy}),
    {stop, Reason}.

%%-------------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% @private
%%-------------------------------------------------------------------------
code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}. 





%%-------------------------------------------------------------------------
%%
%%     Message Queue
%%
%%
%%-------------------------------------------------------------------------

%%process send packet to client
proc_packet_send(Socket, Packet) ->
    {Type, Binary} = protocal:encode(Packet),
    MyStep = gen_new_step(),
    RecvStep = get_last_recv_stepnum(),
    %%io:format("MyStep:~p,RecvStep:~p~n", [MyStep, RecvStep]),
    Bin = net_helper:make_net_binary(Type, Binary, MyStep, RecvStep),  
    add_to_queue({MyStep, Packet}),
    gen_tcp:send(Socket, Bin).



%%generate a new step num
gen_new_step() ->
    NewStep = case get(my_step_num) of
		  undefined ->
		      1;
		  Num ->
		      case Num >= 255 of
			  true ->
			      1;
			  false ->
			      Num + 1
		      end
	      end,
    put(my_step_num, NewStep),
    NewStep.


%%get packets which need to be resent
get_resend_packets(PacketQueue, LastBeRecv) ->
    clear_queue(PacketQueue, LastBeRecv).




%%do resend packet to client
resend_packet({[], []}) ->
    ok;
resend_packet(Queue) ->
    {{value, {_StepNum, Binary}}, NewQueue} = queue:out(Queue),
    proc_packet_send(get_socket(), Binary),
    resend_packet(NewQueue).

get_socket() ->
    get(the_socket).

put_socket(Socket) ->
    put(the_socket, Socket).
    



%%get last recv stepnum 
get_last_recv_stepnum() ->
    case get(last_recv_stepnum) of
	undefined ->
	    1;
	StepNum ->
	    StepNum
    end.


%%set last recv stepnum
set_last_recv_stepnum(StepNum) ->
    put(last_recv_stepnum, StepNum).



%%get the queue contains msgs those may need to be resend
get_message_queue() ->
    case get(msg_queue) of
	undefined ->
	    queue:new();
	Queue ->
	    Queue
    end.

%%set msg queue
set_message_queue(NewQueue) ->
    %%io:format("NewQueue:~p~n", [NewQueue]),
    put(msg_queue, NewQueue).


%%to add a new msg to the msg queue
add_to_queue({StepNum, BinaryPacket}) ->
    CurQueue = get_message_queue(),
    set_message_queue(queue:in({StepNum, BinaryPacket}, CurQueue)).



%%get queue msg from redis for reconnect
get_queue_from_cache() ->
    case redis:hget("tcp_msg_queue", player:get_player_id()) of
	undefined ->
	    {1, {[],[]}};
	Res ->
	    Res
    end.

%%save queue msg to cache, maybe for reconnect
write_queue_to_cache() ->
    case player:get_player_id() of
	undefined ->
	    ok;
	_ ->
	    redis:hset("tcp_msg_queue", player:get_player_id(), {get_last_recv_stepnum(), get_message_queue()})
    end.


%%update the queue by a newest stepnum when recv a packet from client
clear_queue_by_step(Step) ->
    CurQueue = get_message_queue(),
    %%io:format("CurQueue:~p~n", [CurQueue]),
    NewQueue = clear_queue(CurQueue, Step),
    %%io:format("NewQueue1:~p~n", [NewQueue]),
    set_message_queue(NewQueue).



%%update msg queue by delete those item that is out of date .every time remove one item
clear_queue({[], []}, _)->
    {[], []};

clear_queue(CurQueue, Step) ->
    %%io:format("queue:~p~n", [CurQueue]),
    {StepHead, _Head} = queue:head(CurQueue),
    {StepLast, _Last} = queue:last(CurQueue),
    case StepHead =< StepLast of
	true ->
	    case (StepHead =< Step) and (Step =< StepLast) of
		true ->
		    clear_queue(element(2, queue:out(CurQueue)), Step);
		false ->
		    CurQueue
	    end;
	false ->
	    case (StepLast >= Step)  or (Step >= StepHead) of
		true ->
		    clear_queue(element(2, queue:out(CurQueue)), Step);
		false ->
		    CurQueue
	    end
    end.


special_process(#notify_email_add{new_email = NewEmail}) ->
    Pid = get(player_pid),
    gen_server:cast(Pid, {packet, {?msg_notify_email_add, #notify_email_add{new_email = NewEmail}}});

special_process(_)->
    ok.





    
