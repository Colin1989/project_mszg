-module(cache).
-export([start/0, start/1]).
-export([stop/0]).
-export([get/2, set/3, delete/2, delete/1, set/4, execute_cmd/1]).%%,get_all_info/2]). 
%%,count_statics_increase/3,get_count_statics/2]).
-export([to_hex/1]).
%%-export([insert/2,remove/2,getall/1,,is_member/2,get_member_amount/1,execute_cmd/1,get_table_len/1]).
-define(POOLNAME, server_cache_pool).

start() ->
    Path = code:where_is_file("cache.config"),
    {ok, [CacheOptions]} = file:consult(Path),
    case CacheOptions of
	[]->start([{adapter, ets}]);
	_->start(CacheOptions)
    end.

start(Options) ->
    AdapterName = proplists:get_value(adapter, Options, ets),
    Adapter	= list_to_atom(lists:concat(["cache_adapter_", AdapterName])),
    Adapter:start(Options),
    cache_sup:start_link(Options).

stop() ->
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @set(Key, Field, Val)->ok
%% @end
%%--------------------------------------------------------------------
%%redis&&ets
set(Key, Field, Val) ->
    cache_pool:call(?POOLNAME, {set, Key, Field, Val}),
    ok.


get(Key, Field) ->
    cache_pool:call(?POOLNAME, {get, Key, Field}).
%%--------------------------------------------------------------------
%% @doc
%% @delete(Key, Field, Val)->ok
%% @end
%%--------------------------------------------------------------------
delete(Key, Field) ->
    cache_pool:call(?POOLNAME, {delete, Key, Field}),
    ok.

delete(Key) ->
    cache_pool:call(?POOLNAME, {delete, Key}),
    ok.

%%redis
set(Key, Field, Val,Expire) ->
    cache_pool:call(?POOLNAME, {set, Key, Field, Val,Expire}),
    ok.

%% get_count_statics(Key, Field) ->
%%     cache_pool:call(?POOLNAME, {get_int, Key, Field}). 
%% count_statics_increase(Key, Field, Expire) ->
%%     cache_pool:call(?POOLNAME, {increase, Key, Field, Expire}),
%%     ok.

%%redis.set
%% insert(Key, Val)->
%%     cache_pool:call(?POOLNAME, {insert, Key, Val}),
%%     ok.
%% remove(Key, Val)->
%%     cache_pool:call(?POOLNAME, {remove, Key, Val}),
%%     ok.
%% is_member(Key, Val)->
%%     cache_pool:call(?POOLNAME, {is_member, Key, Val}).
%% get_member_amount(Key)->
%%     cache_pool:call(?POOLNAME, {get_member_amount, Key}).
%% getall(Key)->
%%     cache_pool:call(?POOLNAME, {getall, Key}).
%% get_all_info(Key, Tab)->
%%     cache_pool:call(?POOLNAME, {get_all_info, Key, Tab}).
%%redis eval
execute_cmd(Cmds)->
    cache_pool:call(?POOLNAME, {execute_cmd, Cmds}).


%% get_table_len(Key)->
%%     cache_pool:call(?POOLNAME, {get_table_len, Key}).

%% from mochiweb project, mochihex:to_hex/1
%% @spec to_hex(integer | iolist()) -> string()
%% @doc Convert an iolist to a hexadecimal string.
to_hex(0) ->
    "0";
to_hex(I) when is_integer(I), I > 0 ->
    to_hex_int(I, []);
to_hex(B) ->
    to_hex(iolist_to_binary(B), []).

%% @spec hexdigit(integer()) -> char()
%% @doc Convert an integer less than 16 to a hex digit.
hexdigit(C) when C >= 0, C =< 9 ->
    C + $0;
hexdigit(C) when C =< 15 ->
    C + $a - 10.

%% Internal API

to_hex(<<>>, Acc) ->
    lists:reverse(Acc);
to_hex(<<C1:4, C2:4, Rest/binary>>, Acc) ->
    to_hex(Rest, [hexdigit(C2), hexdigit(C1) | Acc]).

to_hex_int(0, Acc) ->
    Acc;
to_hex_int(I, Acc) ->
    to_hex_int(I bsr 4, [hexdigit(I band 15) | Acc]).
