%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%
%%% @end
%%% Created :  4 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(csv_loader).

-behaviour(gen_server).
-include("record_type.hrl").

%% API
-export([start/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3, find/2, get_all/1]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

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

transform_colum(int, Value) ->
    list_to_integer(Value);
transform_colum(float, Value) ->
    list_to_float(Value);
transform_colum(string, Value) ->
    Value.    

record_def_transform([], [], RecordDes) ->
    lists:reverse(RecordDes);
record_def_transform([H|T], [HDef|TDef], RecordDes) ->
    record_def_transform(T, TDef, [transform_colum(HDef, H) | RecordDes]).

add_record(FileAtom, RecordSrc, ColumDef) ->
    RecordDes = record_def_transform(RecordSrc, ColumDef, []),
    T = list_to_tuple([FileAtom|RecordDes]),
    ets:insert(FileAtom, {element(2, T), T}).

create_csv_table(FileAtom) ->
    case ets:info(FileAtom) of
	undefined -> ok;
	_ -> ets:delete(FileAtom)
    end,
    ets:new(FileAtom, [ordered_set, protected, named_table]).

parse_lines(FileAtom, Lines) ->
    Recorddef = find_record_def(FileAtom, ?record_type),
    create_csv_table(FileAtom),
    [_|ColumDef] = tuple_to_list(Recorddef),
    [_|Records] = Lines,
    case Recorddef of
	{error, record_not_defined} -> record_not_defined;
	_ -> [add_record(FileAtom, Record, ColumDef)||Record<-Records]
    end.

load_csv_file(Dir,Filename) ->
    FileAtom = list_to_atom(filename:basename(Filename, ".csv")),
    Filefullname = Dir ++ filename:basename(Filename),
    Lines = csv_helper:parse_file_to_list(Filefullname),
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


