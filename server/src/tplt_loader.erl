%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2015, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 14 Jan 2015 by shenlk <>
%%%-------------------------------------------------------------------
-module(tplt_loader).

-export([behaviour_info/1]).

%% @spec behaviour_info( atom() ) -> [ {Function::atom(), Arity::integer()} ] | undefined
behaviour_info(callbacks) ->
    [{read_file, 2},
     {trans_string, 1},
     {get_all_files, 1}
    ];
behaviour_info(_Other) ->
    undefined.

