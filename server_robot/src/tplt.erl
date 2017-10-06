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

-behaviour(gen_server).

%% API
-export([start_link/0, 
	 get_data/2, 
	 is_exist/2, 
	 get_all_data/1, 
	 transform_filename_atom/1, 
	 get_size/1, 
	 info/1,
	 reload/0,
	 read_template_file/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

%%%===================================================================
%%% API1
%%%===================================================================

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
    io_helper:format("reload template start~n"),
    read_template_file("./template/"),
    io_helper:format("reload template end~n"),
    erlang:garbage_collect(self()),
    task:init_task_info(),
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
    task:init_task_info(),
    io_helper:format("read template end~n"),
    {ok, []}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

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
	 transform_file_to_dict(?field_type_list, FilePath1, File)
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

%% 从文件中读取内容,填充到dict中
transform_file_to_dict(FTList, FilePath, File) ->
    case filename:extension(File) of
	".xml" -> 
	    FileAtom = list_to_atom(filename:basename(File, ".xml")),
	    {ok, Xml} = file:read_file(FilePath++File),
	    {ok, {_Root, _, [{Name,_,_}|_]=Records}, _} = erlsom:simple_form(Xml),
	    case is_define_exist(list_to_atom(Name)) of
		false -> erlang:error({'program not define', File});
		true -> ok
	    end,
	    case ets:info(FileAtom) of
		undefined -> ok;
		_ -> 
		    ets:delete(FileAtom)
	    end,
	    ets:new(FileAtom, [ordered_set, public, named_table]),
	    F = fun({FieldName, _, C}, Row)->
			case C of
			    [] ->
				ok;
			    _ ->
				FieldAtom = list_to_atom(FieldName),
				case lists:keysearch(FieldAtom, 1, FTList) of			    
				    {value, {_, FTs}} ->
					case lists:keysearch(FileAtom, 1, FTList) of
					    false -> ok;
					    _ ->
						%% 检查头部Tag和文件名是否匹配
						case FileAtom =:= FieldAtom of
						    true -> ok;
						    _ ->					    
							erlang:error({filename_not_match, FieldAtom, FileAtom})
						end
					end,
					try
					    T = list_to_tuple([FieldAtom|transform_field_value(FileAtom, FTs, C, Row)]),

					    Key = element(2, T),
					    case ets:lookup(FileAtom, Key) of
						[] ->
						    ets:insert(FileAtom, {element(2, T), T});
						_ ->
						    erlang:error({key_reapeat, FileAtom, Key})
					    end
					catch
					    _:Reason ->
						erlang:error({Reason, {err_id, list_to_integer(hd(element(3, hd(C))))}})
					end;
				    _ -> 
					erlang:error({'not found', FieldAtom, FTList})
				end
			end,
			Row + 1
		end,
	    lists:foldl(F, 1, Records),
	    ok;
	_ ->
	    ok
    end.

%% 根据记录的类型定义, 把字符串转换成相应的值
transform_field_value(_File, [], [], _Row) ->
    [];
transform_field_value(File, [], Values, Row)->
    erlang:error({type_value_mismatch, [File, Values, Row]});
transform_field_value(File, FieldTypes, [], Row)->
    erlang:error({type_field_mismatch, [File, FieldTypes, Row]});
transform_field_value(File, [FieldType|FTRest], [{_, _, StringValue}|VRest], Row)->
    %% 此行保留用做调试用, 需要时开启
    %%io:format("~p~n", [{FieldType, FTRest, StringValue, Row}]),
    Value = case StringValue of 
		[]->
		    "";
		[NotEmpty]->
		    NotEmpty
	    end,
    [case FieldType of
	 int -> list_to_integer(string:strip(Value, both, $ ));
	 float -> trans_to_float(string:strip(Value, both, $ ));
	 string -> unicode:characters_to_binary(Value);
	 range -> get_range_field(Value); 
	 list_int -> get_list_int(Value);
	 list_tuple ->get_list_tuple(Value);
	 list_space_int ->
	     [list_to_integer(string:strip(Token, both, $ )) || Token <- string:tokens(Value, " ")];
	 list_space_float ->
	     [list_to_float(string:strip(Token, both, $ )) || Token <- string:tokens(Value, " ")];
	 list_float -> [list_to_float(string:strip(Token, both, $ ))
		      || Token <- string:tokens(Value, ",")];
	 list_string -> [unicode:characters_to_binary(string:strip(Token, both, $ ))
		      || Token <- string:tokens(Value, ",")];
	 exp_str ->
	     expression:trans_expression(Value);
	 _ -> erlang:error(badtype)
     end | transform_field_value(File, FTRest, VRest, Row)].

get_list_int(Value) when Value == "-1" ->
    [];
get_list_int(Value) ->
    [list_to_integer(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, ",")].

get_list_tuple(Value) when Value == "-1" ->
    [];

get_list_tuple(OldValue) ->
    Value = lists:concat(["[", OldValue, "]"]),
    {ok, Scan1, _} = erl_scan:string(Value++"."),
    {ok,P}=erl_parse:parse_exprs(Scan1),
    P1 = erl_eval:exprs(P, []),
    {_,P2,_} = P1,
    P2.

trans_to_float(Value) when is_list(Value)->
    case string:chr(Value, $.) of
	0 -> float(list_to_integer(Value));
	_ -> list_to_float(Value)
    end.

%% 判断制定的类型程序是否定义
is_define_exist(Type)->
    case lists:keyfind(Type, 1, ?field_type_list) of
	false -> false;
	_-> true
    end.

get_range_field([]) ->
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
%%------------------------------测试代码---------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).

is_define_exist_test()->
    false = is_define_exist(ttt),
    true = is_define_exist(house_tplt).

-endif.
