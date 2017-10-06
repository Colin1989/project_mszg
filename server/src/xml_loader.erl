%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2015, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 14 Jan 2015 by shenlk <>
%%%-------------------------------------------------------------------
-module(xml_loader).

-behaviour(tplt_loader).
%% API
-export([read_file/2,
	trans_string/1,
	get_all_files/1]).

%%%===================================================================
%%% API
%%%===================================================================
get_all_files(Dir) ->
    filelib:fold_files(Dir, ".*.xml", false, fun(Filename, _AccIn)-> [Filename|_AccIn] end, []).
read_file(FilePath, File) ->
    case filename:extension(File) of
	".xml" -> 
	    FileAtom = list_to_atom(filename:basename(File, ".xml")),
	    {ok, Xml} = file:read_file(FilePath++File),
	    {ok, {_Root, _, [{Name,_,_}|_]=Records}, _} = erlsom:simple_form(Xml),
	    case list_to_atom(Name) of
		FileAtom ->
		    ok;
		_ ->
		    erlang:error(data_not_match_with_file)
	    end,
	    {FileAtom, [[get_col(C)||C <- R] || {_, _, R} <- Records]};
	_ ->
	    {undefined, []}
    end.

get_col({_,_,StringValue}) ->
    case StringValue of 
	[]->
	    "";
	[NotEmpty]->
	    NotEmpty
    end.



%% get_file_atom(Filename) ->
%%     filename:basename(Filename, ".xml").


trans_string(Value) ->
    unicode:characters_to_binary(Value).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% 从文件中读取内容,填充到dict中



%% case is_define_exist(list_to_atom(Name)) of
%% 		false -> erlang:error({'program not define', File});
%% 		true -> ok
%% 	    end,
%% 	    case ets:info(FileAtom) of
%% 		undefined -> ok;
%% 		_ -> 
%% 		    ets:delete(FileAtom)
%% 	    end,
%% 	    ets:new(FileAtom, [ordered_set, public, named_table]),
%% 	    F = fun({FieldName, _, C}, Row)->
%% 			case C of
%% 			    [] ->
%% 				ok;
%% 			    _ ->
%% 				
%% 		end,
%% 	    lists:foldl(F, 1, Records),
