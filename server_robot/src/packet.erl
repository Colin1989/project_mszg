%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  ���������, ·��ģ��
%%% @end
%%% Created :  8 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(packet).

-export([start/0, router/1, register/2, send/1, send/2, broadcast/2]).
-compile(export_all).

start() ->
    Module = get_module(),
    Module:start().


%% �Ѱ�·�ɵ�ָ���Ĵ���������
router(Packet) ->
    Module = get_module(),
    Module:router(Packet).

%% ����ϢЭ�����ͺͺ���
register(PacketType, Fun) ->
    Module = get_module(),
    Module:register(PacketType, Fun).

%% ������������ͻ���

send(Packet) ->
    io_helper:format("***send Packet:~p~n", [Packet]),
    Pid = get(tcpid),%%���tcpid����playerģ����ʹ��put�����
    case Pid of
	undefined ->

	    ok;
	_ ->
	    send(Pid, Packet)
    end.

send(Pid,repeat_login_stop)->
	Pid ! {repeat_login_stop};
send(Pid, Packet) when is_pid(Pid) ->
    Binary = net_helper:make_net_binary(protocal:encode(Packet)),
    %%io_helper:format("length:~p~n", [length(binary_to_list(Binary))]),
    Pid ! {send2client, Binary};
send(Account, Packet) ->
    io_helper:format("***send Account:~p, Packet:~p~n", [Account, Packet]),
    TcpPid = account_pid_mapping:get_pid(Account), %% �����pid��tcp_mm���̵�pid
    send(TcpPid, Packet).

broadcast(Players, Packet) ->
    [send(P, Packet) || P <- Players],
    ok.


%% ����mock_packet_router�ķ�����, 
%% 1. ʹ��debugģʽ���� make debug 
%% 2. ��game.app�е�env��������  {env, [{packet_router, mock_packet_router}]}
-ifdef(release).
get_module() ->
    packet_router.
-else.
get_module() ->
    packet_router.
-endif.


