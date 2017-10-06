%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 20 May 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(rand_nickname).

-include("tplt_def.hrl").

%% API
-export([rand_nickname/0]).

%%%===================================================================
%%% API
%%%===================================================================
rand_nickname()->
    Res = rand:uniform(100),
    AllData = tplt:get_all_data(nickname_tplt),
    Data = find_range(AllData, Res),
    [FirstName] = rand:rand_members_from_list(Data#nickname_tplt.content, 1),
    [SecondName] = rand:rand_members_from_list(Data#nickname_tplt.secname, 1),
    lists:concat([binary_to_list(FirstName), binary_to_list(SecondName)]).

find_range([Data|AllData], Res)->
    #nickname_tplt{radio = Radio} = Data,
    case Radio >= Res of
	true ->
	    Data;
	false ->
	    find_range(AllData, Res - Radio)
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================


