%% Author: NoteBook
%% Created: 2009-9-3
%% Description: 该工具的作用是根据指定的结构生成策划所需要的xml源
-module(make_xml_source).

-include("xml_define.hrl").

%%
%% Exported Functions
%%
-export([start/0]).

%%
%% TODO: Add description of start/function_arity
%%
start() -> 
    make_mapping_files(),
    make_record_def_files(),
    make_cs_record_files(),
    make_cs_table_files(),
    make_tplt_field_type().

%% 生成读取xml数据需要的一些类型定义的文件
make_tplt_field_type() ->
    %L = [make_one_record_type_def(RecordName, Fields) || {RecordName, Fields} <- ?tplt_list],
    Str = "-define(field_type_list, ([" ++ make_record_type_def(?tplt_list) ++ "])).",
    file:write_file("../../include/tplt_field_type.hrl", Str).

make_record_type_def([{RecordName, F}]) ->
    "{" ++ atom_to_list(RecordName) ++ ",[" ++ make_field_type("", F) ++ "]}";
make_record_type_def([{RecordName, F}|L]) ->
    "{" ++ atom_to_list(RecordName) ++ ",[" ++ make_field_type("", F) ++ "]},\n"
	++ make_record_type_def(L).

make_field_type(Str, [{Type, _Field}]) ->
    Str ++ atom_to_list(Type);
make_field_type(Str, [{Type, _Field}|Rest]) ->
    make_field_type(Str ++ atom_to_list(Type) ++ ",", Rest).

%% 生成xml对应的记录的定义文件
make_record_def_files()->
    L = [make_record_def(RecordName, get_record_fields(Fields)) || {RecordName, Fields} <- ?tplt_list],
    Str = lists:foldl(fun(E, S) -> S ++ E end, "", L),
    file:write_file("../../include/tplt_def.hrl", Str).

%% 生成每个结构体的c#定义
make_cs_record_files() ->
    L = [make_cs_record_def(RecordName, Fields) || {RecordName, Fields} <- ?tplt_list],
    Str = lists:foldl(fun(E, S) -> S ++ E end, "", L),
    file:write_file("tplt_def.cs", "using System.Collections.Generic;\nusing UnityEngine;\n" ++Str).

%% 生成cs版本的每个模板表里的数据集合对应的类
make_cs_table_files() ->
    L = [make_cs_record_table(RecordName, Fields) || {RecordName, Fields} <- ?tplt_list],
    Str = lists:foldl(fun(E, S) -> S ++ E end, "", L),
    file:write_file("tplt_table_def.cs", "using System.Collections.Generic;
using System.Xml;
using System;
using System.Collections;
using UnityEngine;
" ++Str).

make_cs_record_table(Record, Fields=[{Type, Name}|_]) ->
    io_lib:format(
   "public class ~p_table{
    public Hashtable datas = new Hashtable();
    public void read(string xmlStr){
         XmlDocument xd = new XmlDocument();
	     xd.LoadXml(xmlStr);

         if(!xd.HasChildNodes)
             return;

         foreach(XmlElement r in xd.DocumentElement.ChildNodes)
         {
             IEnumerator ienum = r.ChildNodes.GetEnumerator();
             ~p row = new ~p();
~s
             datas.Add(row.~p, row);
         }
      }
      public ~p get(~p key){
        return (~p)datas[key];
      }
   }
", [Record, Record, Record, read_data_to_struct("", Fields), Name, Record, Type, Record]).

read_data_to_struct(Str, []) ->
    Str;
read_data_to_struct(Str, [{Type, Name} | Rest]) ->
    read_data_to_struct(Str ++ get_convert_string(Type, Name), Rest).

get_convert_string(int, Name) ->
    io_lib:format(
"            if (ienum.MoveNext())
                 row.~p = Convert.ToInt32(((XmlNode)ienum.Current).InnerText);\n", [Name]);
get_convert_string(float, Name) ->
    io_lib:format(
"            if (ienum.MoveNext())
                 row.~p = Convert.ToSingle(((XmlNode)ienum.Current).InnerText);\n", [Name]);
get_convert_string(string, Name) ->
    io_lib:format(
"            if (ienum.MoveNext())
                 row.~p = ((XmlNode)ienum.Current).InnerText;\n", [Name]);
get_convert_string(vector3, Name) ->
    io_lib:format(
"            if (ienum.MoveNext()){
                 string[] sp = ((XmlNode)ienum.Current).InnerText.Split(new string[]{\" \", \",\", \", \"}, StringSplitOptions.RemoveEmptyEntries);
                 row.~p.x = Convert.ToSingle(sp[0]);
                 row.~p.y = Convert.ToSingle(sp[1]);
                 row.~p.z = Convert.ToSingle(sp[2]);}\n", [Name, Name, Name]);
get_convert_string(quaternion, Name) ->
    io_lib:format(
"            if (ienum.MoveNext()){
                 string[] sp = ((XmlNode)ienum.Current).InnerText.Split(new string[]{\" \", \",\", \", \"}, StringSplitOptions.RemoveEmptyEntries);
                 row.~p.x = Convert.ToSingle(sp[0]);
                 row.~p.y = Convert.ToSingle(sp[1]);
                 row.~p.z = Convert.ToSingle(sp[2]);
                 row.~p.w = Convert.ToSingle(sp[3]);}\n", [Name, Name, Name, Name]);
get_convert_string(color, Name) ->
    io_lib:format(
"            if (ienum.MoveNext()){
                 string[] sp = ((XmlNode)ienum.Current).InnerText.Split(new string[]{\" \", \",\", \", \"}, StringSplitOptions.RemoveEmptyEntries);
                 row.~p.r = Convert.ToSingle(sp[0]);
                 row.~p.g = Convert.ToSingle(sp[1]);
                 row.~p.b = Convert.ToSingle(sp[2]);}\n", [Name, Name, Name]);
get_convert_string(range, Name) ->
    get_convert_string(list_int, Name);
get_convert_string(list_int, Name) ->
    io_lib:format(
"            if (ienum.MoveNext())
                   foreach(string v in ((XmlNode)ienum.Current).InnerText.Split(new string[]{\" \", \",\", \", \"}, StringSplitOptions.RemoveEmptyEntries)){
                     row.~p.Add(Convert.ToInt32(v));
                }
", [Name]);
get_convert_string(list_float, Name) ->
    io_lib:format(
"           foreach(string v in ((XmlNode)ienum.Current).InnerText.Split(new string[]{\" \", \",\", \", \"}, StringSplitOptions.RemoveEmptyEntries)){
                     row.~p.Add(Convert.ToSingle(v));
                }
", [Name]);
get_convert_string(list_string, Name) ->
    io_lib:format(
"           foreach(string v in ((XmlNode)ienum.Current).InnerText.Split(new string[]{\" \", \",\", \", \"}, StringSplitOptions.RemoveEmptyEntries)){
                     row.~p.Add(v);
                }
", [Name]);
get_convert_string(_Type, _Name) ->
    "".


%% 生成一个record的定义
%% -record(item_tplt, {id, name}).
make_record_def(RecordName, Fields)->
    "-record(" ++ atom_to_list(RecordName) ++ ",{" ++ make_record_content("", Fields) ++ "}).\n".

make_record_content(Str, [Field]) ->
    Str ++ atom_to_list(Field);
make_record_content(Str, [Field|Rest]) ->
    make_record_content(Str ++ atom_to_list(Field) ++ ",", Rest).

%% 生成一个js版本的record的定义
%% class Item
%% {
%%     public int id;
%% }
make_cs_record_def(RecordName, Fields)->
    "public class " ++ atom_to_list(RecordName) ++ "\n{\n" ++ make_cs_record_content("", Fields) ++ "}\n".

make_cs_record_content(Str, []) ->
    Str;
make_cs_record_content(Str, [{Type, Name}|Rest]) ->
    make_cs_record_content(Str ++ "    public " ++ parse_cs_type(Type, Name), Rest).

parse_cs_type(list_int, Name) ->
    io_lib:format("List<int> ~p  = new List<int>();\n", [Name]);
parse_cs_type(list_float, Name) ->
    io_lib:format("List<float> ~p = new List<float>();\n", [Name]);
parse_cs_type(list_string, Name) ->
    io_lib:format("List<string> ~p = new List<string>();\n", [Name]);
parse_cs_type(color, Name) ->
    io_lib:format("Color ~p = new Color();\n", [Name]);
parse_cs_type(vector3, Name) ->
    io_lib:format("Vector3 ~p = new Vector3();\n", [Name]);
parse_cs_type(quaternion, Name) ->
    io_lib:format("Quaternion ~p = new Quaternion();\n", [Name]);
parse_cs_type(range, Name) ->
    parse_cs_type(list_int, Name);
parse_cs_type(Type, Name) ->
    atom_to_list(Type) ++ " " ++ atom_to_list(Name) ++ ";\n".



%% 生成mapping映射文件供excel映射使用
make_mapping_files()->
    [merge_content(RecordName, get_record_fields(Fields)) || {RecordName, Fields} <- ?tplt_list].

get_record_fields(Fields)->
    [FieldName||{_Type, FieldName}<- Fields].

merge_content(RecordName, Fields) ->
    Str = "<" ++ atom_to_list(RecordName) ++ ">",
    merge_content(RecordName, Fields, Str).

merge_content(RecordName, [Field|Rest], Str) ->
    Str1 = Str ++ "<" ++ atom_to_list(Field) ++ "/>",
    merge_content(RecordName, Rest, Str1);
merge_content(RecordName, [], Str) ->
    Str1 = Str ++ "</" ++ atom_to_list(RecordName) ++ ">",
    merge_root(RecordName, Str1).

merge_root(RecordName, Content) ->
    Str1 = "<root>" ++ Content ++ Content ++ "</root>",
    file:write_file(atom_to_list(RecordName) ++ "_mapping.xml", Str1).
