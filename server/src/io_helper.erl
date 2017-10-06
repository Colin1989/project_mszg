%%%-------------------------------------------------------------------
%%% @author  linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%%  ���˴�ӡ��Ϣ
%%% @end
%%% Created : 26 Apr 2010 by  <>
%%%-------------------------------------------------------------------
-module(io_helper).

-export([start/0, format/1, format/2]).

-include("packet_def.hrl"). 

start() ->
    filter().

%% ���ӹ�������
-ifdef(debug).
filter() ->
    %%put(��Ϣ���ͣ� ��Ϣ���ƣ�
    [put(Type, ok) || Type <- []].
-else.
filter() ->
    [].
-endif.


%% ��ʽ�����ݲ���ӡ����
-ifdef(debug).
-spec format(list(), any()) -> atom().
format(Format, {Type, _Data} = Args) ->
    case get(Type) of
	undefined -> %%���û�й������������ӡ������Ϣ
	    io:format(Format, [Args]);
	_ ->
	    ok
    end;
format(Format, {Type} = Args) ->
    case get(Type) of
	undefined -> %%���û�й������������ӡ������Ϣ
	    io:format(Format, [Args]);
	_ ->
	    ok
    end;
format(Format, Args) when is_list(Args) ->
    io:format(Format, Args);
format(Format, Args) ->
    io:format(Format, [Args]).
-else.
format(_Format, _Args) ->
    ok.
-endif.

-ifdef(debug).
format(Format) ->
    io:format(Format).
-else.
format(_Format) ->
    ok.
-endif.
