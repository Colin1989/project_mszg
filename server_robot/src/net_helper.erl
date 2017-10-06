%% Author: NoteBook
%% Created: 2009-9-12
%% Description: Add description to net
-module(net_helper).

-include("packet_def.hrl").
-include("net_type.hrl").

-export([encode_string/1, encode_list/2, decode_base_type/2, decode_string/1, decode/3, 
	 get_encode_binary_data/1, get_data/1, get_data/2, get_type/1]).
-export([packet_encode/1, packet_decode/2, make_net_binary/1, make_net_binary/2]).

%% 序列化字符串
encode_string(Str) when is_list(Str)->
    Len = length(Str),
    <<Len:?UINT16, (list_to_binary(Str))/binary>>;
encode_string(StrAtom) when is_atom(StrAtom)->
    encode_string(atom_to_list(StrAtom));
encode_string(Str) when is_binary(Str)->
    Len = size(Str),
    <<Len:?UINT16, Str/binary>>.

%% 反序列化字符串 
decode_string(Binary) ->
    <<Len:?UINT16, Bin1/binary>> = Binary,
    {Str, Bin2} = split_binary(Bin1, Len),
    {binary_to_list(Str), Bin2}.

%% 序列化列表
encode_list(F, List) when is_list(List) ->
    Len = length(List),
    <<Len:?UINT16, (list_to_binary([F(E) || E<-List]))/binary>>;
encode_list(F, Array) -> %% 对array的序列化
    case array:is_array(Array) of
	true ->
	    encode_list(F, array:to_list(Array));
	false ->
	    erlang:error({badarg, Array})
    end.

%% 反序列化基本类型
decode_base_type(int, Bin) ->
    <<Value:?INT, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(uint, Bin) ->
    <<Value:?UINT, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(int16, Bin) ->
    <<Value:?INT16, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(uint16, Bin) ->
    <<Value:?UINT16, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(int64, Bin) ->
    <<Value:?INT64, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(uint64, Bin) ->
    <<Value:?UINT64, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(short, Bin) ->
    <<Value:?SHORT, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(ushort, Bin) ->
    <<Value:?USHORT, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(long, Bin) ->
    <<Value:?LONG, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(ulong, Bin) ->
    <<Value:?ULONG, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(char, Bin) ->
    <<Value:?CHAR, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(uchar, Bin) ->
    <<Value:?UCHAR, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(float, Bin) ->
    <<Value:?FLOAT, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(double, Bin) ->
    <<Value:?DOUBLE, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(bool, Bin) ->
    <<Value:?BOOL, Bin1/binary>> = Bin,
    {Value, Bin1};
decode_base_type(string, Bin) ->
    decode_string(Bin).

%%反序列化的帮助函数, 自动生成的反序列化代码会调用
decode([], Binary, ReturnList) ->
    Record = list_to_tuple(lists:reverse(ReturnList)), 
    {Record, Binary};

decode([{array, user_define, Fun} | Rest], Binary, ReturnList) ->
    {Value, Bin} = decode_list({user_define, Fun}, Binary),
    decode(Rest, Bin, [Value | ReturnList]);

decode([{array, BaseType} | Rest], Binary, ReturnList) ->
    {Value, Bin} = decode_list(BaseType, Binary),
    decode(Rest, Bin, [Value | ReturnList]);

decode([{user_define, Fun} | Rest], Binary, ReturnList) ->
    {Value, Bin} = Fun(Binary),
    decode(Rest, Bin, [Value | ReturnList]);
decode([Type | Rest], Binary, ReturnList) ->
    {Value, Bin} = decode_base_type(Type, Binary),
    decode(Rest, Bin, [Value | ReturnList]).


%% 反序列化列表
decode_list({user_define, F}, Binary) ->
    <<Len:?UINT16, Bin/binary>> = Binary,
    decode_list_1(F, Bin, Len, []);

decode_list(BaseType, Binary) ->
    <<Len:?UINT16, Bin/binary>> = Binary,
    F = fun(Bin2) -> decode_base_type(BaseType, Bin2) end,
    decode_list_1(F, Bin, Len, []).

decode_list_1(_F, Binary, 0, List) ->
    {lists:reverse(List), Binary};
decode_list_1(F, Binary, Len, List) ->
    {Data, Bin1} = F(Binary),
    decode_list_1(F, Bin1, Len-1, [Data | List]).

%% 获得一个结构体序列化后的二进制数据
get_encode_binary_data({_Type, Binary}) ->
    Binary.


%% 解码二进制数据, 返回对应的结构体内容
get_data(RawBinary) ->
    {Type, Rest} = packet_decode(RawBinary),
    {Data, _Bin} = protocal:decode(Type, Rest),
    {Type, Data}.
%% 解码二进制数据, 返回对应的结构体内容(检查步进值是否一致)
get_data(RawBinary, WantPacketCount) ->
    {Type, Rest} = packet_decode(RawBinary, WantPacketCount),
    {Data, _Bin} = protocal:decode(Type, Rest),
    {Type, Data}.

get_type(Binary) ->
    <<Type:?UINT16, _Rest/binary>> = Binary,
    Type.

%% 生成网络消息的二进制数据
make_net_binary(Type, null) -> %只有网络类型, 不需要结构体数据的网络消息
    net_helper:packet_encode(<<Type:?UINT16>>);
make_net_binary(Type, Binary) ->
    net_helper:packet_encode(<<Type:?UINT16, Binary/binary>>).

make_net_binary({Type, Binary}) ->
    make_net_binary(Type, Binary).

%%-ifdef(crypto).
packet_decode(Binary, WantPacketCount) ->
    io_helper:format("WantPacketCount:~p~n", [WantPacketCount]),
    <<_WantPacketCount:?UCHAR, RawBinary/binary>> = packet_crypto:decode(Binary),
    <<WantPacketCount:?UCHAR, Type:?UINT16, Rest/binary>> = RawBinary,
    {Type, Rest}.
packet_decode(RawBinary) ->
    <<Type:?UINT16, Rest/binary>> = RawBinary,
    {Type, Rest}.
packet_encode(RawBinary) ->
    RawBinary.
%% -else.
%% packet_decode(Binary, WantPacketCount) ->
%%     io:format("WantPacketCount:~p~n", [WantPacketCount]),
%%     %%<<_WantPacketCount:?UCHAR, RawBinary/binary>> = packet_crypto:decode(Binary),
%%     <<WantPacketCount:?UCHAR, Type:?UINT16, Rest/binary>> = Binary,
%%     %% <<Type:?UINT16, Rest/binary>> = RawBinary,
%%     {Type, Rest}.
%% packet_decode(RawBinary) ->
%%     <<Type:?UINT16, Rest/binary>> = RawBinary,
%%     {Type, Rest}.
%% packet_encode(RawBinary) ->
%%     RawBinary.
%% -endif.
%% -else.
%% packet_decode(RawBinary, WantPacketCount) ->
%%     Binary = packet_crypto:decode(RawBinary),
%%     <<WantPacketCount:?UCHAR, Type:?UINT16, Rest/binary>> = Binary,
%%     {Type, Rest}.
%% packet_decode(RawBinary) ->
%%     Binary = packet_crypto:decode(RawBinary),
%%     <<_PacketCount:?UCHAR, Type:?UINT16, Rest/binary>> = Binary,
%%     {Type, Rest}.
%% packet_encode(RawBinary) ->
%%     packet_crypto:encode(RawBinary).
%% -endif.

