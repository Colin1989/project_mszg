%%%-------------------------------------------------------------------
%%% @author linyijie <>
%%% @copyright (C) 2013, linyijie
%%% @doc
%%%  模拟模板接口, 方便测试
%%% @end
%%% Created : 12 Nov 2013 by linyijie <>
%%%-------------------------------------------------------------------
-module(tplt_mock).
-export([find_mock/1, get_all_mock/1, stop/0]).

find_mock(Data) when is_tuple(Data)->
    find_mock([Data]);
find_mock(Data) when is_list(Data) ->
    meck:new(tplt, [no_link]),
    Expects = [{[element(1, D), element(2, D)], D} || D <- Data],
    Expects1 = Expects ++ 
	[{2, meck:exec(fun(Type, Key) -> erlang:error({not_found_data, Type, Key}) end)}],
    meck:expect(tplt, find, Expects1).

get_all_mock([Head | _]=Data) when is_list(Data) ->
    meck:new(tplt, [no_link]),
    TableName = element(1, Head),
    meck:expect(tplt, get_all, 
		[{[TableName], Data},
		 {1, meck:exec(fun(Name) -> 
				       erlang:error({not_found_data, Name}) 
			       end)}]).

stop() ->
    meck:unload(tplt).
    
    
    

