%% Author: NoteBook
%% Created: 2009-9-18
%% Description: TODO: Add description to gen_protocal_charp
-module(gen_protocal_csharp).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start/0]).
-export([test/0]).
%%
%% API Functions
%%

start() ->
    StructList = protocal_def:get_struct_def(),
    TypeList = gen_common:get_type(),
    FileStr = make_include() ++ make_protocal(StructList, "", TypeList),
    file:write_file("NetPacket.cs",  FileStr),
    EnumStr = make_protocal_enum(protocal_def:get_enum_def(), ""),
    ConstStr = make_protocal_const(protocal_def:get_version()),
    file:write_file("EnumDef.cs",  EnumStr ++ "\n" ++ ConstStr),
    MsgTypeStr = make_protocal_msg_type(StructList, "", 1),
    file:write_file("NetMsgType.cs", MsgTypeStr).

%%
%% Local Functions
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成包含文件%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_include() ->
    "using System;
using System.Collections;".
    %% "#pragma once
    %% #include\"ByteArray.h\"
    %% #include\"BaseType.h\"
    %% #include\"INetPacket.h\"
    %% #include\"NetMsgType.h\"
    %% #include<string>
    %% #include<vector>
    %% ".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成函数的方法%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_protocal([], StructStr, _TypeList) ->
    StructStr;
make_protocal([Struct | Structs], StructStr, TypeList) ->
    [StructName | NewStructList] = Struct,
    VariableStr = make_protocal_Variable(NewStructList, "", TypeList),
    EncodeStr = make_protocal_encode(NewStructList, "", TypeList),
    DecodeStr = make_protocal_decode(NewStructList, "", TypeList),
    BuildStr = make_protocal_build(StructName),
    CreateStr = make_protocal_create(StructName),
    StructStr1 = StructStr ++ "\npublic class " ++ atom_to_list(StructName) ++ 
	" : INetPacket\n{\n" ++ 
	make_getmsgid(StructName) ++
	%% "    public int getMsgID()\n" ++
	%% "    {\n" ++
        %% "        return NetMsgType.msg_" ++ atom_to_list(StructName) ++ ";\n" ++
        %% "    }\n" ++
	VariableStr ++ EncodeStr ++ DecodeStr ++ BuildStr ++ CreateStr ++ "\n}\n",
    make_protocal(Structs, StructStr1, TypeList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成变量%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_protocal_Variable([], VariableStr, _TypeList) ->
    VariableStr;
make_protocal_Variable([{Type, Name} | Vars], VariableStr, TypeList) ->
    VariableStr1 = 
	case lists:keyfind(Type, 1, TypeList) of
	    {Type1, base_type} ->
		VariableStr ++ "    public " ++ get_csharp_type(Type1) ++ " " ++ get_csharp_Var(Name) ++ ";\n";
	    {Type1, string_type}  -> 
		VariableStr ++ "    public " ++ get_csharp_type(Type1) ++ " " ++ get_csharp_Var(Name) ++ " = \"\";\n";
	    {_Type, enum_type} ->
		VariableStr ++ "    public int " ++ get_csharp_Var(Name) ++ ";\n";
	    _ -> 
		VariableStr ++ "    public " ++ get_csharp_type(Type) ++ " " ++ get_csharp_Var(Name) ++ " = new " ++ get_csharp_type(Type) ++ "();\n"
	end,
    make_protocal_Variable(Vars, VariableStr1, TypeList);

make_protocal_Variable([{Type, Name, DefaultValue} | Vars], VariableStr, TypeList) 
  when Type =/= array ->
    VariableStr1 = 
	case lists:keyfind(Type, 1, TypeList) of
	    {Type1, base_type} ->
		VariableStr ++ "    public " ++ get_csharp_type(Type1) ++ " " ++ get_csharp_Var(Name) ++ " = " ++ get_default_value(Type, DefaultValue) ++ ";\n";
	    {Type1, string_type}  -> 
		VariableStr ++ "    public " ++ get_csharp_type(Type1) ++ " " ++ get_csharp_Var(Name) ++ " = " ++ get_default_value(Type, DefaultValue) ++ ";\n";
	    {_Type, enum_type} ->
		VariableStr ++ "    public int " ++ get_csharp_Var(Name) ++ ";\n";
	    _ -> 
		VariableStr ++ "    public " ++ get_csharp_type(Type) ++ " " ++ get_csharp_Var(Name) ++ " = new " ++ get_csharp_type(Type) ++ "();\n"
	end,
    make_protocal_Variable(Vars, VariableStr1, TypeList);

make_protocal_Variable([{array, Type, Name} | Vars], VariableStr, TypeList) ->
    VariableStr1 = 
	case lists:keyfind(Type, 1, TypeList) of
	    {_Type1, base_type} ->
		VariableStr ++ "    public ArrayList " ++ get_csharp_Var(Name) ++ " = new ArrayList();\n";
	    {_Type1, string_type}  -> 
		VariableStr ++ "    public ArrayList " ++ get_csharp_Var(Name) ++ " = new ArrayList();\n";
	    {_Type, enum_type} ->
		VariableStr ++ "    public ArrayList " ++ atom_to_list(Name) ++ " = new ArrayList();\n";
	    _ -> 
		VariableStr ++ "    public ArrayList " ++ get_csharp_Var(Name) ++ " = new ArrayList();\n"
	end,
    make_protocal_Variable(Vars, VariableStr1, TypeList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


make_protocal_build(StructName) ->
    "    public void build(ByteArray byteArray)\n" ++ 
    "    {\n" ++
    "        byteArray.Write(NetMsgType.msg_" ++ atom_to_list(StructName) ++ ");\n" ++
    "        encode(byteArray);\n" ++
    "    }\n".

make_protocal_create(StructName)->
    "    public INetPacket Create()\n" ++ 
    "    {\n" ++
    "       return new " ++ atom_to_list(StructName) ++ "();\n" ++
    "    }".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成encode%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% byteArray.write_uint16(account.size());
%%         for(int i=0; i<account.size();i++)
%%         {
%%             byteArray.write_string(account[i]);
%%         } 
make_protocal_encode([], EncodeStr, _TypeList) ->
    "    public void encode(ByteArray byteArray)
    {\n" ++ EncodeStr ++ "    }\n\n";
make_protocal_encode([Struct | Vars], EncodeStr, TypeList) ->
    EncodeStr1 = EncodeStr ++ make_protocal_encode_item(Struct, TypeList),
    make_protocal_encode(Vars, EncodeStr1, TypeList).

%% 生成decode中的数组 
make_protocal_encode_item({Type, Name}, TypeList) ->
    case lists:keyfind(Type, 1, TypeList) of
	{Type, base_type} ->
	    "    \tbyteArray.Write(" ++ get_csharp_Var(Name) ++ ");\n";
	{Type, string_type}  -> 
	    "    \tbyteArray.Write(" ++ get_csharp_Var(Name) ++ ");\n";
	{_Type, enum_type} ->
	    make_protocal_encode_item({int, Name}, TypeList);
	_ -> 
	    "        " ++  get_csharp_Var(Name) ++ ".encode(byteArray);\n\n"
    end;
make_protocal_encode_item({Type, Name, _DefaultValue}, TypeList) 
  when Type /= array->
    make_protocal_encode_item({Type, Name}, TypeList);
make_protocal_encode_item({array, Type, Name}, TypeList) ->
    case lists:keyfind(Type, 1, TypeList) of
	{Type1, base_type} ->
	    make_protocal_encode_item_base_type(Name, Type1);
	{Type1, string_type}  -> 
	    make_protocal_encode_item_base_type(Name, Type1);
	{_Type, enum_type} ->
	    make_protocal_encode_item({array, int, Name}, TypeList);
	_ -> 
	    NameStr = get_csharp_Var(Name),
	    "        byteArray.Write((UInt16)" ++ NameStr ++ ".Count);\n" ++
	    "        for(int i = 0; i < " ++ NameStr ++ ".Count; i++)\n" ++
	    "        {\n" ++
	    "            ((" ++ get_csharp_type(Type) ++ ")" ++  NameStr ++ "[i]).encode(byteArray);\n" ++
            "        }\n"
    end.

make_protocal_encode_item_base_type(Name, Type) ->
    NameStr = get_csharp_Var(Name),
    TypeStr = get_csharp_type(Type),
    "        byteArray.Write((UInt16)" ++ NameStr ++ ".Count);\n" ++
    "        for(int i = 0; i < " ++ NameStr ++ ".Count; i++)\n" ++ 
    "        {\n" ++ 
    "            byteArray.Write((" ++ TypeStr  ++ ")" ++ NameStr ++ "[i]);\n" ++ 
    "        }\n".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成decode%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_protocal_decode([], DecodeStr, _TypeList) ->
    "    public void decode(ByteArray byteArray)\n    {\n" ++ DecodeStr ++ "    }\n";
make_protocal_decode([Struct | Vars], DecodeStr, TypeList) ->
    DecodeStr1 = DecodeStr ++  make_protocal_decode_item(Struct, TypeList),
    make_protocal_decode(Vars, DecodeStr1, TypeList).

make_protocal_decode_item({Type, Name}, TypeList) ->
    case lists:keyfind(Type, 1, TypeList) of
	{Type1, base_type} ->
	    "        " ++ get_csharp_Var(Name) ++ " = byteArray.read_"++ atom_to_list(Type1) ++"();\n";
	{Type1, string_type}  -> 
	    "        " ++ get_csharp_Var(Name) ++ " = byteArray.read_"++ atom_to_list(Type1) ++"();\n";
	{_Type, enum_type} ->
	    make_protocal_decode_item({int, Name}, TypeList);
	_ -> 
	    "        " ++ get_csharp_Var(Name) ++ ".decode(byteArray);\n"
    end;
make_protocal_decode_item({Type, Name, _DefaultValue}, TypeList)
  when Type /= array->
    make_protocal_decode_item({Type, Name}, TypeList);
make_protocal_decode_item({array, Type, Name}, TypeList) ->
    case lists:keyfind(Type, 1, TypeList) of
	{Type1, base_type} ->
	    make_protocal_encode_item_decode_type(Name, Type1);
	{Type1, string_type}  -> 
	    make_protocal_encode_item_decode_type(Name, Type1);
	{_Type, enum_type} ->
	    make_protocal_decode_item({array, int, Name}, TypeList);
	_ -> 
	    TypeString = get_csharp_type(Type),
	    NameStr = get_csharp_Var(Name),
	    CountString = "CountOf" ++ NameStr,
	    ArrayString = "ArrayOf" ++ NameStr,
	    "        int " ++ CountString ++ " = byteArray.read_uint16();\n" ++
	    "        " ++ TypeString ++ "[] " ++ ArrayString ++ " = new " ++ TypeString ++ "[" ++ CountString ++ "];\n" ++
    	    "        for(int i = 0; i < " ++ CountString ++ "; i++)\n" ++
    	    "        {\n" ++
            "            " ++ ArrayString ++ "[i] = new " ++ TypeString ++ "();\n" ++
    	    "            ((" ++ get_csharp_type(Type) ++ ")" ++ ArrayString ++ "[i]).decode(byteArray);\n" ++ 
            "        }\n" ++
	    "        " ++ NameStr ++ ".Clear();\n" ++
            "        " ++ NameStr ++ ".AddRange(" ++ ArrayString ++ ");\n" 
    end.

make_protocal_encode_item_decode_type(Name, Type) ->
    NameStr = get_csharp_Var(Name),
    TypeStr = atom_to_list(Type),
    CountString = "CountOf" ++ NameStr,
    "        " ++ NameStr ++ ".Clear();\n" ++
    "        int " ++ CountString ++ " = byteArray.read_uint16();\n" ++
    "        for(int i = 0; i < " ++ CountString ++ "; i++)\n" ++
    "        {\n" ++
    "             " ++ NameStr ++ ".Add(byteArray.read_" ++ TypeStr ++ "());\n" ++
    "        }\n".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成网络类型%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_protocal_msg_type([], MsgTypeStr, _Index) ->
    "public class NetMsgType\n" ++ 
    "{\n" ++
    "    public static readonly short msg_none = 0;\n" ++
    MsgTypeStr ++ 
    "}";
make_protocal_msg_type([Struct|Structs], MsgTypeStr, Index) ->
    [StructName | _NewStructList] = Struct,
    make_protocal_msg_type(Structs, MsgTypeStr ++ "    public static readonly short msg_" ++ atom_to_list(StructName) ++ " = " ++ integer_to_list(Index) ++ ";\n", Index+1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成枚举类型%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_protocal_const(Ver) ->
    "public class Config
{
    public static readonly int PROTO_VER = " ++ integer_to_list(Ver) ++ ";
}\n".

make_protocal_enum([], EnumStr) ->
    EnumStr;
make_protocal_enum([Enum | Enums], EnumStr) ->
    {EnumName , EnumItems} = Enum,
    EnumStr1 = EnumStr ++ "public class " ++
	string:to_lower(atom_to_list(EnumName)) ++ "\n{\n" ++ 
	make_protocal_enum_item(EnumItems, 1, "") ++ "}\n",
    make_protocal_enum(Enums, EnumStr1).

make_protocal_enum_item([EnumItem | []], Index, EnumItemStr) ->
    EnumItemStr ++ "    public static readonly int " ++ atom_to_list(EnumItem) ++ " = " ++ integer_to_list(Index) ++ ";\n";
make_protocal_enum_item([EnumItem | EnumItems], Index, EnumItemStr) ->
    EnumItemStr1 = EnumItemStr ++ "    public static readonly int " ++ atom_to_list(EnumItem) ++ " = " ++ integer_to_list(Index) ++ ";\n",
    make_protocal_enum_item(EnumItems, Index + 1, EnumItemStr1).

get_csharp_Var(Type)->
    TypeString = atom_to_list(Type),
    case lists:keyfind(TypeString, 1, get_keyword_mapping()) of
	{TypeString, CSharpTypeString}->
	    CSharpTypeString;
	_ ->
	    TypeString
    end.
get_csharp_type(Type) -> 
    TypeString = atom_to_list(Type),
    case lists:keyfind(TypeString, 1, get_cshapr_type_mapping()) of
	{TypeString, CSharpTypeString}->
	    CSharpTypeString;
	_ ->
	    TypeString
    end.

get_cshapr_type_mapping()->
    [
     {"unint", "UInt"}, 
     {"int16", "Int16"}, 
     {"uint16", "UInt16"}, 
     {"int64", "Int64"}, 
     {"uint64", "UInt64"}, 
     {"uchar", "char"} 
    ].

get_keyword_mapping() ->
    [
     {"lock", "Lock"},
     {"params", "Params"}
    ].

make_getmsgid(StructName)->
    	"    public short getMsgID()\n" ++
	"    {\n" ++
        "        return NetMsgType.msg_" ++ atom_to_list(StructName) ++ ";\n" ++
        "    }\n".

get_default_value(Type, DefaultValue)
  when (Type == int orelse 
	Type == uint orelse
	Type == uint64 orelse
	Type == uint16 orelse
	Type == int64 orelse
	Type == short orelse
	Type == int16)
       andalso  is_integer(DefaultValue)->
    integer_to_list(DefaultValue);
get_default_value(Type, DefaultValue)
  when (Type == float orelse 
	Type == long orelse
	Type == double orelse
	Type == uint16 orelse
	Type == int64 orelse
	Type == int16)
       andalso is_float(DefaultValue)->
    float_to_list(DefaultValue);
get_default_value(char, DefaultValue) 
  when is_list(DefaultValue)->
    "'" ++ DefaultValue ++ "'";
get_default_value(string, DefaultValue)
  when is_atom(DefaultValue)->
    get_default_value(string, atom_to_list(DefaultValue));
get_default_value(string, DefaultValue) 
  when is_list(DefaultValue)->
    "\"" ++ DefaultValue ++ "\"".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%测试函数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test() ->
    %% 	test_make_protocal_encode_item(),
    %% 	test_make_protocal_decode_item(),
    %% 	test_make_protocal_encode(),
    %% 	test_make_protocal_decode().
    start().

%% test_make_protocal_encode_item() ->
%% 	"\t\tbyteArray.write_uint16(result.size());\n\t\tfor(int i=0; i<result.size();i++)\n\t{\n\t\t\tresult[i].encode(byteArray);\n\t}\n"
%% 		= make_protocal_encode_item({array, notify_login_result, result}, gen_common:get_type()),
%% 	"\t\tbyteArray.write_uint16(account.size());\n\t\tfor(int i=0; i<account.size();i++)\n\t{\n\t\t\tbyteArray.write_string(account[i]);\n\t}\n" 
%% 		= make_protocal_encode_item({array, string, account}, gen_common:get_type()),
%% 	"\t\tbyteArray.write_uint16(account.size());\n\t\tfor(int i=0; i<account.size();i++)\n\t{\n\t\t\tbyteArray.write_int(account[i]);\n\t}\n" 
%% 		= make_protocal_encode_item({array, login_result, account}, gen_common:get_type()),
%% 	"\t\tbyteArray.write_string(account);\n" = make_protocal_encode_item({string, account}, gen_common:get_type()),
%% 	"\t\tbyteArray.write_int(account);\n" = make_protocal_encode_item({login_result, account}, gen_common:get_type()),
%% 	"\t\taccount.encode(byteArray);\n" = make_protocal_encode_item({notify_login_result, account}, gen_common:get_type()).
%% 
%% test_make_protocal_decode_item() ->
%% 	"uint16 size = byteArray.read_uint16();\naccount.reserve(size);\nfor(int i=0; i<size;i++)\n{\n\taccount.push_back(byteArray.read_string());\n}\n"
%% 		= make_protocal_decode_item({array, string, account}, gen_common:get_type()),
%% 	"uint16 size = byteArray.read_uint16();\nresult.resize(size);\nfor(int i=0; i<size;i++)\n{\n\tresult[i].decode(byteArray);\n}\n"
%% 		= make_protocal_decode_item({array, notify_login_result, result}, gen_common:get_type()),
%% 	"uint16 size = byteArray.read_uint16();\naccount.reserve(size);\nfor(int i=0; i<size;i++)\n{\n\taccount.push_back(byteArray.read_int());\n}\n"
%% 		= make_protocal_decode_item({array, login_result, account}, gen_common:get_type()),
%% 	"account = byteArray.read_string();\n" = make_protocal_decode_item({string, account}, gen_common:get_type()),
%% 	"account = byteArray.read_int();\n" = make_protocal_decode_item({login_result, account}, gen_common:get_type()),
%% 	"account.decode(byteArray);\n" = make_protocal_decode_item({notify_login_result, account}, gen_common:get_type()).
%% 
%% test_make_protocal_encode() ->
%% 	Result = make_protocal_encode([{array, string, account},
%% 		 	{string, pwd},
%% 		 	{player_data, data},
%% 		 	{array, notify_login_result, result}], "", gen_common:get_type()),
%% 	io:format("~p~n", [Result]).
%% 
%% test_make_protocal_decode() ->
%% 	Result = make_protocal_decode([{array, string, account},
%% 		 	{string, pwd},
%% 		 	{player_data, data},
%% 		 	{array, notify_login_result, result}], "", gen_common:get_type()),
%% 	io:format("~p~n", [Result]).
%% 
%% test_make_protocal_Variable() ->
%% 	Result = make_protocal_Variable([{array, string, account},
%% 		 	{string, pwd},
%% 		 	{player_data, data},
%% 		 	{array, notify_login_result, result}], "", gen_common:get_type()),
%% 	io:format("~p~n", [Result]).
