%%%-------------------------------------------------------------------
%%% @author linyibin <linyb@china-channel.com>
%%% @copyright (C) 2010, linyibin
%%% @doc
%%% 
%%% @end 
%%% Created :  6 Aug 2010 by linyibin <linyb@china-channel.com>
%%%-------------------------------------------------------------------
-module(json).
-export([decode/1, encode/1, get_field/2]).
-export([get_value/2, get_value/3]).

decode(S) ->
    rfc4627:decode(S).

encode(S) ->
    rfc4627:encode(S).

get_field(Obj, Key) ->
    rfc4627:get_field(Obj, Key).

get_value(Obj, Key)->
    get_value(Obj, Key, undefined).

get_value(Obj, Key, Default)->
    %% data_helper:format("get value:~p, ~p, ~p~n", [Obj, Key, rfc4627:get_field(Obj, Key)]),
    case rfc4627:get_field(Obj, Key) of
	{ok, Value} -> Value;
	{ok, Value, _}	 -> Value;
	_ -> Default
    end.
