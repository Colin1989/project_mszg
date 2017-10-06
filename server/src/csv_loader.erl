%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%
%%% @end
%%% Created :  4 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(csv_loader).

-behaviour(tplt_loader).
%%-include("record_type.hrl").
-include("tplt_field_type.hrl").



%% API
-export([start/0,
	get_all_files/1,
	trans_string/1,
	read_file/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3, find/2, get_all/1, reload/0]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
get_all_files(Dir) ->
    filelib:fold_files(Dir, ".*.xml", false, fun(Filename, _AccIn)-> [Filename|_AccIn] end, []).
trans_string(Value) ->
    list_to_binary(Value).

read_file(FilePath, File) ->
    case filename:extension(File) of
	".csv" -> 
	    FileAtom = list_to_atom(filename:basename(File, ".xml")),
	    [_Defs|Lines] = csv_processer:parse_file(FilePath++File, 1),
	    {FileAtom, Lines};
	_ ->
	    {undefined, []}
    end.

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start() ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    load_csv_from_dir("../ebin/template/"),
    {ok, #state{}}.

reload() ->
    gen_server:call(?SERVER, reload).
    %%load_csv_from_dir("../ebin/template/").

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(reload, _, State) ->
    Reply = ok,
    load_csv_from_dir("../ebin/template/"),
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% int -> list_to_integer(string:strip(Value, both, $ ));
%% float -> trans_to_float(string:strip(Value, both, $ ));
%% string -> unicode:characters_to_binary(Value);
%% range -> get_range_field(Value); 
%% list_int -> get_list_int(Value);
%% list_tuple ->get_list_tuple(Value);
%% list_space_int ->
%%     [list_to_integer(string:strip(Token, both, $ )) || Token <- string:tokens(Value, " ")];
%% list_space_float ->
%%     [list_to_float(string:strip(Token, both, $ )) || Token <- string:tokens(Value, " ")];
%% list_float -> [list_to_float(string:strip(Token, both, $ ))
%% 	       || Token <- string:tokens(Value, ",")];
%% list_string -> [unicode:characters_to_binary(string:strip(Token, both, $ ))
%% 		|| Token <- string:tokens(Value, ",")];
%% exp_str ->
%%     expression:trans_expression(Value);
%% _ -> erlang:error(badtype)

get_list_tuple("-1") ->
    [];

get_list_tuple(OldValue) ->
    Value = lists:concat(["[", OldValue, "]"]),
    {ok, Scan1, _} = erl_scan:string(Value++"."),
    {ok,P}=erl_parse:parse_exprs(Scan1),
    P1 = erl_eval:exprs(P, []),
    {_,P2,_} = P1,
    P2.

get_list_int( "-1" )->
    [];
get_list_int(Value) ->
    [list_to_integer(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, ",")].

get_list_float( "-1" )->
    [];
get_list_float(Value) ->
    [list_to_float(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, ",")].


get_list_space_int( "-1" )->
    [];
get_list_space_int(Value) ->
    [list_to_integer(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, ",")].

get_list_space_float( "-1" )->
    [];
get_list_space_float(Value) ->
    [list_to_float(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, ",")].

get_range_field("-1") ->
    {0, 0};
get_range_field(Value) ->
    IntList = [list_to_integer(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, "~")],
    case length(IntList) of
	2 -> list_to_tuple(IntList);
	1 -> {hd(IntList), hd(IntList)};
	_ -> 
	    erlang:error(bad_range, Value)
    end.


transform_colum(int, Value) ->
    list_to_integer(string:strip(Value, both, $ ));

transform_colum(string, Value) ->
    list_to_binary(Value);

transform_colum(list_int, Value) ->
    get_list_int(string:strip(Value, both, $ ));

transform_colum(list_tuple, Value) ->
    get_list_tuple(string:strip(Value));


transform_colum(exp_str, Value) ->
    expression:trans_expression(Value);

transform_colum(float, Value) ->
    list_to_float(string:strip(Value, both, $ ));

transform_colum(range, Value) ->
    get_range_field(string:strip(Value, both, $ ));

transform_colum(list_space_int, Value) ->
    get_list_space_int(string:strip(Value, both, $ ));
transform_colum(list_space_float, Value) ->
    get_list_space_float(string:strip(Value, both, $ ));
transform_colum(list_float, Value) ->
    get_list_float(string:strip(Value, both, $ ));

transform_colum(Type, _) ->
    erlang:error({badtype, Type}).    



record_def_transform([], [], RecordDes) ->
    lists:reverse(RecordDes);
record_def_transform([H|T], [HDef|TDef], RecordDes) ->
    record_def_transform(T, TDef, [transform_colum(HDef, H) | RecordDes]).

add_record(FileAtom, RecordSrc, ColumDef) ->
    %%io:format("LengthField:~p, LengthData~p~n", [RecordSrc, RecordSrc]),
    try
	RecordDes = record_def_transform(tuple_to_list(RecordSrc), ColumDef, []),
	T = list_to_tuple([FileAtom|RecordDes]),
	ets:insert(FileAtom, {element(2, T), T})
    catch
	_:Reason ->
	    erlang:error({Reason, {err_id, element(1, RecordSrc)}})
    end.

create_csv_table(FileAtom) ->
    case ets:info(FileAtom) of
	undefined -> ok;
	_ -> ets:delete(FileAtom)
    end,
    ets:new(FileAtom, [ordered_set, public, named_table]).

parse_lines(FileAtom, Lines) ->
    Recorddef = find_record_def(FileAtom, ?field_type_list),
    create_csv_table(FileAtom),
    ColumDef = element(2, Recorddef),
    [_|Records] = Lines,
    %%io:format("Recorddef:~p~n", [Recorddef]),
    case Recorddef of
	{error, record_not_defined} -> record_not_defined;
	_ -> lists:foreach(fun(X) -> add_record(FileAtom, X, ColumDef) end, Records)
	     %%[add_record(FileAtom, Record, ColumDef)||Record<-Records]
    end.

load_csv_file(Dir,Filename) ->
    FileAtom = list_to_atom(filename:basename(Filename, ".csv")),
    Filefullname = Dir ++ filename:basename(Filename),
    %%Lines = csv_helper:parse_file_to_list(Filefullname),
    %%io:format("FileAtom:~p~n", [FileAtom]),
    Lines = csv_processer:parse_file(Filefullname, 512),
    parse_lines(FileAtom, Lines).
    
load_csv_from_dir(Dir) ->
    filelib:fold_files(Dir, ".*.csv", true, fun(Filename,_AccIn)-> load_csv_file(Dir,Filename) end, []).

%%查找模板对就的定义(record)
find_record_def(Record_name, [H|T] ) ->
    [Type|_] = tuple_to_list(H),
    case Type of
	Record_name -> H;
	_ -> find_record_def(Record_name, T)
    end;
find_record_def(_Record_name, []) -> {error, record_not_defined}.

find(Type, Key) ->
    case ets:info(Type) of
	undefined -> erlang:error({csv_undefined, Type});
	_ -> case ets:lookup(Type, Key) of
		 [] -> erlang:error({not_found_data, Type, Key});
		 [{_,Record}] ->Record
	     end
    end.

get_all(Type) ->
    case ets:info(Type) of
	undefined -> erlang:error({csv_undefined, Type});
	_ ->
	    lists:reverse(ets:foldl(fun({_Key, Value}, AccIn)-> [Value | AccIn] end, [], Type))
    end.


