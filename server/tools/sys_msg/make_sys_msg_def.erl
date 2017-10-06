%% Author: NoteBook
%% Created: 2009-9-3
%% Description: 该工具的作用是根据指定的结构生成策划所需要的xml源
-module(make_sys_msg_def).

-include("sys_msg_define.hrl").

%%
%% Exported Functions
%%
-export([start/0]).

%%
%% TODO: Add description of start/function_arity
%%
start() -> 
    make_sys_msg_def_file(),
    make_sys_msg_def_lua_file().
    %%make_mapping_files(),
    %%make_record_def_files(),
    %%make_cs_record_files(),
    %%make_cs_table_files(),
    %%make_tplt_field_type().

%% 生成读取xml数据需要的一些类型定义的文件
make_sys_msg_def_lua_file()->
    Str = get_def_str_lua(),
    StrList = get_all_sys_msg(),
    file:write_file("sys_msg.lua", "--sys_msg_def\nsys_msg =\n{" ++ Str ++ "}"),
    file:write_file("../../include/sys_msg_str.hrl", "-define(all_sys_msg_str, " ++ StrList ++ ").").


get_all_sys_msg() ->
    lists:concat(["[",get_def_str(?sys_msg_list),"\n                          eof\n                         ]"]).

get_def_str(List) ->
    case List of
	[] ->
	    [];
	[{_, DefList}|ListLeft] ->
	    [lists:concat(["\n                          ", Atom, ","])||{Atom, _} <- DefList] ++ get_def_str(ListLeft)
	    
    end.


get_def_str_lua()->
    {_, Str} = lists:foldl(fun(X,{In, DutyStrs})->
				      {Out, DutyStr} = get_one_duty_def_lua(X, In),
				      {Out, [DutyStr|DutyStrs]}
			      end, {1, []}, ?sys_msg_list),
    FinalStr = lists:concat(lists:reverse(Str)),
    lists:sublist(FinalStr, 1, length(FinalStr)-2) ++ "\n".
get_one_duty_def_lua(DutyDef,StartEnum)->
    {Out,Strs} = lists:foldl(fun(X, {In, Arr})->
				     
				     {In + 1, [lists:concat(["    [", In, "]", " = \"", get_msg_str(element(1,DutyDef), element(1,X)), "\",\n"])|Arr]}
			     end, {StartEnum, []}, element(2, DutyDef)),
    {Out, lists:concat(["\n\n    --",element(1,DutyDef),"\n",lists:concat(lists:reverse(Strs))])}.

make_sys_msg_def_file()->
    Str = get_def_str(),
    file:write_file("../../include/sys_msg.hrl", "%%sys_msg_def\n" ++ Str).

get_def_str()->
    {_, Str} = lists:foldl(fun(X,{In, DutyStrs})->
				      {Out, DutyStr} = get_one_duty_def(X, In),
				      {Out, [DutyStr|DutyStrs]}
			      end, {1, []}, ?sys_msg_list),
    lists:concat(lists:reverse(Str)).

get_one_duty_def(DutyDef,StartEnum)->
    {Out,Strs} = lists:foldl(fun(X, {In, Arr})->
				     
				     {In + 1, [lists:concat(["-define(", get_msg_str(element(1,DutyDef), element(1,X)), ", ",In,").     %%",element(2,X),"\n"])|Arr]}
			     end, {StartEnum, []}, element(2, DutyDef)),
    {Out, lists:concat(["\n\n%%",element(1,DutyDef),"\n",lists:concat(lists:reverse(Strs))])}.


get_msg_str(Duty, X)->
    lists:concat(["sg_", Duty, "_", X]).

