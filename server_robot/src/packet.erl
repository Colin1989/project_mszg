%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  网络包发送, 路由模块
%%% @end
%%% Created :  8 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(packet).

-export([start/0, router/1, register/2, send/1, send/2, broadcast/2]).
-compile(export_all).

start() ->
    Module = get_module(),
    Module:start().


%% 把包路由到指定的处理函数处理
router(Packet) ->
    Module = get_module(),
    Module:router(Packet).

%% 绑定消息协议类型和函数
register(PacketType, Fun) ->
    Module = get_module(),
    Module:register(PacketType, Fun).

%% 发送网络包到客户端

send(Packet) ->
    io_helper:format("***send Packet:~p~n", [Packet]),
    Pid = get(tcpid),%%这个tcpid是在player模块里使用put保存的
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
    TcpPid = account_pid_mapping:get_pid(Account), %% 这里的pid是tcp_mm进程的pid
    send(TcpPid, Packet).

broadcast(Players, Packet) ->
    [send(P, Packet) || P <- Players],
    ok.


%% 开启mock_packet_router的方法是, 
%% 1. 使用debug模式编译 make debug 
%% 2. 在game.app中的env里做设置  {env, [{packet_router, mock_packet_router}]}
-ifdef(release).
get_module() ->
    packet_router.
-else.
get_module() ->
    packet_router.
-endif.


