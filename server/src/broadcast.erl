-module(broadcast).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").

-define(max_priority, 10).

-export([broadcast/2, broadcast/3, broadcast_serveice_msg/0, broadcast_service_msg/1, broadcast_service_msg/3]).


broadcast_service_msg(Msg, RepeatTimes, Priority) ->
    AllPids=redis_extend:get_members_info(online_roleid_set,role_pid_mapping),
    Packet = #notify_sys_msg{code = ?sg_service_broadcast, params = [Msg, integer_to_list(RepeatTimes), integer_to_list(Priority)]},
    broadcast_server:broadcast_packet([X || {_, X} <- lists:filter(fun({_, X})-> X =/= undefined end, AllPids)], Packet, ?max_priority - Priority),
    ok.


broadcast_serveice_msg() ->
    Msg = config:get_broadcast_msg(),
    broadcast_service_msg(Msg).
broadcast_service_msg(Msg) ->
    AllPids=redis_extend:get_members_info(online_roleid_set,role_pid_mapping),
    Packet = #notify_sys_msg{code = ?sg_service_broadcast, params = [Msg]},
    broadcast_server:broadcast_packet([X || {_, X} <- lists:filter(fun({_, X})-> X =/= undefined end, AllPids)], Packet, 4),
    ok.


broadcast(MsgType, Params, Priority)->
    AllPids=redis_extend:get_members_info(online_roleid_set,role_pid_mapping),
    Packet = #notify_sys_msg{code = MsgType, params = Params},
    broadcast_server:broadcast_packet([X || {_, X} <- lists:filter(fun({_, X})-> X =/= undefined end, AllPids)], Packet, ?max_priority - Priority),
    ok.
broadcast(MsgType, Params)->
    AllPids=redis_extend:get_members_info(online_roleid_set,role_pid_mapping),
    Packet = #notify_sys_msg{code = MsgType, params = Params},
    broadcast_server:broadcast_packet([X || {_, X} <- lists:filter(fun({_, X})-> X =/= undefined end, AllPids)], Packet, ?max_priority - 1),
    ok.

%% lists:foreach(fun({_, Pid}) ->
    %% 			  case Pid of
    %% 			    undefined ->
    %% 				  ok;
    %% 			    Pid when is_pid(Pid) -> 
    %% 				  sys_msg:send(Pid,MstType,Params)
    %% 				%%packet:send(Pid,#notify_friend_list{type=?modify,friends=[MyInfo]})
    %% 			end
    %% 		  end, AllPids),













