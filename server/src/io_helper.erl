%%%-------------------------------------------------------------------
%%% @author  linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%%  过滤打印信息
%%% @end
%%% Created : 26 Apr 2010 by  <>
%%%-------------------------------------------------------------------
-module(io_helper).

-export([start/0, format/1, format/2]).

-include("packet_def.hrl"). 

start() ->
    filter().

%% 增加过滤条件
-ifdef(debug).
filter() ->
    %%put(消息类型， 消息名称）
    [put(Type, ok) || Type <- []].
-else.
filter() ->
    [].
-endif.


%% 格式化数据并打印数据
-ifdef(debug).
-spec format(list(), any()) -> atom().
format(Format, {Type, _Data} = Args) ->
    case get(Type) of
	undefined -> %%如果没有过滤条件，则打印过滤信息
	    io:format(Format, [Args]);
	_ ->
	    ok
    end;
format(Format, {Type} = Args) ->
    case get(Type) of
	undefined -> %%如果没有过滤条件，则打印过滤信息
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
