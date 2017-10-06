-module(regular).

-export([start/0, str_match/2, str_replace/3, str_split_not_empty/3, str_split_not_empty/2, str_split/2, str_split/3]).


start()->
    ets:new(?MODULE, [named_table, public]),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @×Ö·û´®Æ¥Åä
%% @end
%%-------------------------------------------------------------------- 
str_match(String, RegStr)->
    re:run(String, compile(RegStr)).
%%--------------------------------------------------------------------
%% @doc
%% @×Ö·û´®Ìæ»»
%% @end
%%-------------------------------------------------------------------- 
str_replace(String, RegStr, RepStr)->
    re:replace(String, compile(RegStr), RepStr, [{return, list},global]).

%%--------------------------------------------------------------------
%% @doc
%% @×Ö·û´®·Ö¸î
%% Option default:[{return,list}, trim],Òª°üº¬·Ö¸ô·ûÔò¼Ó()
%% @end
%%-------------------------------------------------------------------- 
str_split_not_empty(String, RegStr)->
    lists:filter(fun(X) -> length(X)>0 end,str_split_not_empty(String, RegStr, [{return,list}, trim])).


str_split_not_empty(String, RegStr, Option)->
    lists:filter(fun(X) -> length(X)>0 end,re:split(String, compile(RegStr), Option)).

str_split(String, RegStr)->
    str_split(String, RegStr, [{return,list}, trim]).


str_split(String, RegStr, Option)->
    re:split(String, compile(RegStr), Option).






compile(RegStr)->
    case ets:lookup(?MODULE, RegStr) of
	[] ->
	    {ok,Mp} = re:compile(RegStr),
	    ets:insert(?MODULE, {RegStr, Mp}),
	    Mp;
	[{_, Mp}] ->
	    Mp
    end.





