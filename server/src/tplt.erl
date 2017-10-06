%%%-------------------------------------------------------------------
%%% @author  linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%%  模板表读取进程, 该进程用于读取所有需要用到的模板表, 供其他进程查询数据
%%% @end
%%% Created : 31 Mar 2010 by  <>
%%%-------------------------------------------------------------------
-module(tplt).

-include_lib("xmerl/include/xmerl.hrl").
-include_lib("xmerl/include/xmerl_xsd.hrl").
-include("tplt_field_type.hrl").
-include("tplt_def.hrl").

-define(tplt_adapter, xml_loader).

-behaviour(gen_server).
-define(TEMPLATE_DIR, "./template/").
%% API
-export([start_link/0, 
	 get_data/2, 
	 is_exist/2, 
	 get_all_data/1, 
	 transform_filename_atom/1, 
	 get_size/1, 
	 info/1,
	 reload/0,
	 read_template_file/1,
	 get_all_files/0,
	 update/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-compile(export_all).

%%%===================================================================
%%% API1
%%%===================================================================
update(Filename) ->
    gen_server:cast(template, {update, Filename}).
get_all_files() ->
    ?tplt_adapter:get_all_files(?TEMPLATE_DIR).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, template}, ?MODULE, [], []).

%% 获得指定模板表的指定记录
%% 如果找不到返回empty
%% 如果找不到调用erlang:error().
-spec get_data(atom(), any()) -> tuple().
get_data(TpltName, Key) ->
    case get_data1(TpltName, Key) of
	empty -> erlang:error({not_found, TpltName, Key});
	Data -> Data
    end.

-spec get_data1(atom(), any()) -> tuple() | empty.
get_data1(TpltName, Key) when is_atom(TpltName), is_list(Key)->
    get_data1(TpltName, list_to_binary(Key));
get_data1(TpltName, Key) when is_atom(TpltName) ->
    case ets:lookup(TpltName, Key) of
        [{Key, Value}] ->
            Value;
	_Result -> empty
    end.


%% 取记录数
get_size(TpltName) ->
    ets:info(TpltName, size).

%% 判断指定的数据是否存在
-spec is_exist(atom(), any()) -> boolean().
is_exist(TpltName, Key) when is_atom(TpltName)->
    case ets:lookup(TpltName, Key) of
	[]-> false;
	_ -> true
    end.

info(TpltName) when is_atom(TpltName) ->
    ets:info(TpltName). 

%% 获得指定模板表的所有记录
%% 返回记录集的列表形式
-spec get_all_data(atom()) -> [tuple()].
get_all_data(TpltName) when is_atom(TpltName)->
    % 不使用默认的dict:to_list,因为该函数是产生[{Key,Value}]的列表
    % 而这边的需求是产生[Value]列表
    F = fun({_Key, Value}, AccIn)-> [Value | AccIn] end,
    lists:reverse(ets:foldl(F, [], TpltName)).

%% 转换指定的文件名为atom的方式
%% 如果文件名带有扩展名, 会自动去除
transform_filename_atom(Filename)->
    FileName1 = binary_to_list(Filename),
    io_helper:format("FileName1:~p~n", [FileName1]),
    case FileName1 =:= "0" of
	true ->[];
	_ -> list_to_atom(filename:basename(FileName1, ".xml"))
    end.

%% 重载Template文件

reload()->
    gen_server:call(template, reload),
    {ok,[]}.
    
    

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
    io_helper:format("read template start~n"),
    read_template_file("./template/"),
    erlang:garbage_collect(self()),
    run_after_load(),
    
    io_helper:format("read template end~n"),
    {ok, []}.


handle_call(reload, _, State) ->
    io_helper:format("reload template start~n"),
    read_template_file("./template/"),
    io_helper:format("reload template end~n"),
    erlang:garbage_collect(self()),
    run_after_load(),
    Reply = ok,
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


handle_cast({update, FileName}, State) ->
    transform_file_to_dict(FileName),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



%%%===================================================================
%%% Internal functions
%%%===================================================================
read_template_file(FilePath1)->
    {ok, Files} = get_file_list(FilePath1),
    [try
	 io_helper:format("File:~s~s~n",[FilePath1, File]),
	 {Time,Result} = timer:tc(?MODULE, transform_file_to_dict, [?field_type_list, FilePath1, File]),
	 io:format("load ~p cost:~pus~n", [File, Time]),
	 Result
     catch 
	 error: Msg ->
	     %% 处理错误，让讯息更明确
	     %% logger:delay_log(error, "file: ~p~n ~p~n stack:~p~n", 
	     %% 		      [File, Msg, erlang:get_stacktrace()]),
	     erlang:error({Msg, erlang:get_stacktrace()})		    
     end || File <- Files].

%% 获取文件列表
get_file_list(FilePath) -> 
    case file:list_dir(FilePath) of
	{ok, Files} -> {ok, Files};
	_ -> error
    end.

%%查找模板对就的定义(record)
find_record_def(FileAtom, FTList) ->
    case lists:keysearch(FileAtom, 1, FTList) of
	{value, {_, FTs}} ->
	    FTs;
	_ ->
	    erlang:error({'def not found ', FileAtom})
    end.

%%加载完模板表回调
run_after_load() ->
    io_helper:format("init_item_role_type~n"),
    item:init_item_role_type(),
    io_helper:format("check_tplt_data~n"),
    reward:check_tplt_data(),
    io_helper:format("init_task_info~n"),
    task:init_task_info(),
    io_helper:format("gen_sculpture_type~n"),
    sculpture_pack:gen_sculpture_type().

%%创建ETS表
create_tplt_table(FileAtom) ->
    case ets:info(FileAtom) of
	undefined -> ok;
	_ -> ets:delete(FileAtom)
    end,
    ets:new(FileAtom, [ordered_set, public, named_table]).

%%获取file内容保存到ETS表
transform_file_to_dict(File) ->
    transform_file_to_dict(?field_type_list, ?TEMPLATE_DIR, filename:basename(File)),
    ok.
transform_file_to_dict(FTList, FilePath1, File)->
    {FileAtom, Records} = ?tplt_adapter:read_file(FilePath1, File),
    case FileAtom of
	undefined ->
	    ok;
	_ ->
	    create_tplt_table(FileAtom),
	    FTs = find_record_def(FileAtom, FTList),
	    lists:foreach(fun(X) -> add_record(FileAtom, X, FTs) end, Records)
    end,
    ok.


add_record(FileAtom, RecordSrc, ColumDef) ->
    try
	%%io:format("~p~n", [RecordSrc]),
	RecordDes = record_def_transform(RecordSrc, ColumDef, []),
	T = list_to_tuple([FileAtom|RecordDes]),
	case ets:lookup(FileAtom, element(2, T)) of
	    [] ->
		ets:insert(FileAtom, {element(2, T), T});
	    _ ->
		erlang:error(key_reapeat)
	end

    catch
	_:Reason ->
	    erlang:error({Reason, {template, FileAtom}, {err_id, hd(RecordSrc)}})
    end.


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
    ?tplt_adapter:trans_string(Value);
    %%unicode:characters_to_binary(Value);

transform_colum(list_string, Value) ->
    [unicode:characters_to_binary(string:strip(Token, both, $ ))
		      || Token <- string:tokens(Value, ",")];

transform_colum(list_int, Value) ->
    get_list_int(string:strip(Value, both, $ ));

transform_colum(list_tuple, Value) ->
    get_list_tuple(string:strip(Value));


transform_colum(exp_str, Value) ->
    expression:trans_expression(Value);

transform_colum(float, Value) ->
    case string:chr(Value, $.) of
	0 -> float(list_to_integer(Value));
	_ -> list_to_float(Value)
    end;
    %%list_to_float(string:strip(Value, both, $ ));

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
record_def_transform([], _, _RecordDes) ->
    erlang:error({type_value_missing});
record_def_transform(_, [], _RecordDes) ->
    erlang:error({type_value_toomore});
record_def_transform([H|T], [HDef|TDef], RecordDes) ->
    record_def_transform(T, TDef, [transform_colum(HDef, H) | RecordDes]).























%% 判断制定的类型程序是否定义
is_define_exist(Type)->
    case lists:keyfind(Type, 1, ?field_type_list) of
	false -> false;
	_-> true
    end.








%%------------------------------测试代码---------------------------------------
%% -include_lib("eunit/include/eunit.hrl").
%% -ifdef(TEST).

%% is_define_exist_test()->
%%     false = is_define_exist(ttt),
%%     true = is_define_exist(house_tplt).

%% -endif.
