%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  �¼�����Ϣ·����
%%% @end
%%% Created : 30 Oct 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(packet_router).

-export([start/0, router/1, router/2, register/2]).

start() ->
    ets:new(?MODULE, [named_table, public]).

%% ���Ͱ�������������
router({Type, Data}) ->
    router(Type, Data).
router(Type, Data) ->
    case ets:lookup(?MODULE, Type) of
	[] -> throw({not_found_function, Type});
	[{_Type,{Module,Fun}}]->Module:Fun(Data);
	[{_Type, Fun}] -> Fun(Data)
    end.

%% ����ϢЭ�����ͺͺ���
register(EventType, Fun) ->
    ets:insert(?MODULE, {EventType, Fun}).
