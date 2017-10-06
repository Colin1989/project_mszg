-module(tcp_mm).
-author('saleyn@gmail.com').

-behaviour(gen_fsm).
-include("packet_def.hrl"). 
-include("enum_def.hrl").
-include("tcp_mm_data.hrl").

-export([start_link/0, start_link/1, set_socket/2, repeat_login_stop/1, stop/1]).

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

-define(KEEPALIVE_TIME, 30 * 1000).

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


set_socket(Pid, Socket) when is_pid(Pid), is_port(Socket) ->
    gen_fsm:send_event(Pid, {socket_ready, Socket}).

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

%%-------------------------------------------------------------------------
%% Func: StateName/2
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% @private
%%-------------------------------------------------------------------------
'WAIT_FOR_SOCKET'({socket_ready, Socket}, State) when is_port(Socket) ->
    % Now we own the socket
    inet:setopts(Socket, [{active, once}, {packet, 4}, binary]),
    case inet:peername(Socket) of
	{ok, {IP, _Port}} ->
	    erlang:start_timer(?KEEPALIVE_TIME, self(), []),
	    io_helper:format("IP:~p~n", [IP]),
	    put(ip, IP),
	    %% {ok, Pid} = player:start_link(self()),
	    %% put(player_pid, Pid),
	    {next_state, 'WAIT_FOR_AUTH', State#tcp_mm_data{socket=Socket, addr=IP}, ?TIMEOUT};
	{error,enotconn} ->
	    {stop, normal, State}
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
    DecodeData = net_helper:get_data(Binary, NPacketCount),
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
    Packet = #notify_repeat_login{},
    {Type, Binary} = protocal:encode(Packet),
    Bin = net_helper:make_net_binary(Type, Binary),  
    gen_tcp:send(Socket, Bin),
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
    Packet = net_helper:get_data(Binary, NPacketCount),
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
    {Type, Binary} = protocal:encode(Packet),
    Bin = net_helper:make_net_binary(Type, Binary),  
    gen_tcp:send(Socket, Bin),
    {stop, normal, State};


'WAIT_FOR_DATA'(Data, State) ->
    io_helper:format("~p Ignoring data: ~p\n", [self(), Data]),
    {next_state, 'WAIT_FOR_DATA', State, ?TIMEOUT}.


'WAIT_FOR_DATA'(repeat_login_stop, From, #tcp_mm_data{socket=Socket}=State) ->
    Packet = #notify_repeat_login{},
    {Type, Binary} = protocal:encode(Packet),
    Bin = net_helper:make_net_binary(Type, Binary),  
    gen_tcp:send(Socket, Bin),
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
handle_info({send2client, Bin}, StateName, #tcp_mm_data{socket=Socket} = StateData) ->
    %%io_helper:format("***Test:~p~n", [Bin]),
    %%io:format("~p~n", [StateName]),
    gen_tcp:send(Socket, Bin),
    case get(player_pid) of
	undefined ->
	    ok;
	Pid ->
	    erlang:garbage_collect(Pid)
    end,
    {next_state, StateName, StateData, ?TIMEOUT};
handle_info({timeout, _TimerRef, _Msg}, StateName, #tcp_mm_data{socket=Socket} = StateData) ->
    {Type, Binary} = protocal:encode(#notify_heartbeat{}),
    Bin = net_helper:make_net_binary(Type, Binary), 
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

handle_info({tcp_closed, _Socket}, _StateName, StateData) ->
	%%io:format("tcp close~n",[]),
    {stop, normal, StateData};
handle_info({tcp_error, _Socket, _Error}, _StateName, StateData) ->
    %%io:format(error, "tcp_error:" ++ Error),
    {stop, normal, StateData};
handle_info({'EXIT', _Pid, {shutdown, reselect_role}}, _StateName, StateData) ->
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
	    account_pid_mapping:unmapping(PlayerID);
	_ ->
	    ok
    end,
    Bin = net_helper:make_net_binary(protocal:encode(#notify_socket_close{})),
    gen_tcp:send(Socket, Bin),
    gen_tcp:close(Socket),
    {stop, Reason}.

%%-------------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% @private
%%-------------------------------------------------------------------------
code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}. 



    
