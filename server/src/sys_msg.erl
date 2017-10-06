%%%-------------------------------------------------------------------
%%% @author  linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%%  系统消息的提示模块
%%% @end
%%% Created : 25 Mar 2010 by  <>
%%%-------------------------------------------------------------------
-module(sys_msg).

-include("packet_def.hrl").
-include("sys_msg.hrl").

%% API
-export([send/2, send/3,send_to_self/2,
	notify_error_msg/1]).

%%%===================================================================
%%% API
%%%===================================================================
%% 发送系统消息给客户端
%% Player: 玩家帐号
%% SysType: 系统类型, 参见common_def.hrl定义
%% MsgCode: 消息代码, 参见sys_msg.hrl定义
notify_error_msg(Info) ->
    send_to_self(?sg_service_error, [Info]).
send(Player, MsgCode)->
    send(Player, MsgCode, []).

%% Params: [Param | ...]
%% Param: int, float, atom, string
send_to_self(MsgCode,NParams)->
    packet:send(#notify_sys_msg{code=MsgCode, params=NParams}).
send(_Player, 0, _Params)->
    %% 为0时不处理
    ok;
send(Pid,MsgCode,Params)when is_pid(Pid)->
    NParams = [translate(P) || P <- Params],
    packet:send(Pid, #notify_sys_msg{code=MsgCode, params=NParams});
send(Player, MsgCode, Params)->
    NParams = [translate(P) || P <- Params],
    packet:send(Player, #notify_sys_msg{code=MsgCode, params=NParams}).


translate(Data) when is_integer(Data) ->
    integer_to_list(Data);
translate(Data) when is_float(Data) ->
    [Str] = io_lib:format("~p", [Data]),
    Str;
translate(Data) when is_atom(Data) ->
    atom_to_list(Data);
translate(Data) when is_binary(Data) ->
    binary_to_list(Data);
translate(Data) when is_list(Data) ->
    Data;
translate(Data) ->
    erlang:error({badtype, Data}).
