-module(redis).


-compile(export_all).




%%---------------------------------
%%
%%  Key(键)
%%
%%---------------------------------
del(Key)->
    cache:execute_cmd(["DEL", Key]).

exists(Key)->
    trans_result(cache:execute_cmd(["EXISTS", Key])).


expire(Key, Seconds)->
    trans_result(cache:execute_cmd(["EXPIRE", Key, Seconds])).

set(Key, Value)->
    trans_result(cache:execute_cmd(["SET", Key, term_to_str(Value)])).

get(Key)->
    trans_result(cache:execute_cmd(["GET", Key])).


ttl(_Key, _Expire)->
    ok.



%%---------------------------------
%%
%%  hash(哈希表)
%%
%%---------------------------------



hdel(Key, Field)->
    cache:execute_cmd(["HDEL", Key, term_to_str(Field)]).


hexists(Key, Field) ->
    cache:execute_cmd(["HEXISTS", Key, term_to_str(Field)]).


hget(Key, Field) ->
    trans_result(cache:execute_cmd(["HGET", Key, term_to_str(Field)])).

hset(Key, Field, Value) ->
    trans_result(cache:execute_cmd(["HSET", Key, term_to_str(Field), term_to_str(Value)])).

hsetnx(Key, Field, Value) ->
    trans_result(cache:execute_cmd(["HSETNX", Key, term_to_str(Field), term_to_str(Value)])).


hgetall(Key) ->
    Results = cache:execute_cmd(["HGETALL", Key]),
    trans_results(Results).

hincrby(Key, Field, Increment)->
    trans_result(cache:execute_cmd(["HINCRBY", Key, term_to_str(Field), Increment])).


hincrbyfloat(Key, Field, Increment)->
    trans_result(cache:execute_cmd(["HINCRBYFLOAT", Key, term_to_str(Field), Increment])).

hkeys(Key) ->
    trans_result_list(cache:execute_cmd(["HKEYS", Key])).

hvals(Key) ->
    trans_result_list(cache:execute_cmd(["HVALS", Key])).

hlen(Key) ->
    trans_result(cache:execute_cmd(["HLEN", Key])).

hmget(Key, Fields) ->
    case length(Fields) =:= 0 of
	true ->
	    [];
	false ->
	    Result = cache:execute_cmd(["HMGET", Key|lists:map(fun(X) -> term_to_str(X) end, Fields)]),
	    trans_result_to_tuple(Fields, Result)
    end.

hmset(Key, ValueSets) ->
    trans_result(cache:execute_cmd(["HMSET", Key|lists:map(fun(X) -> term_to_str(X) end, ValueSets)])).



%%---------------------------------
%%
%%  list(列表)
%%
%%---------------------------------
blpop(Keys, Timeout) ->
    trans_result_list(cache:execute_cmd(["BLPOP"|Keys] ++ [Timeout])).

brpop(Keys, Timeout) ->
    trans_result_list(cache:execute_cmd(["BRPOP"|Keys] ++ [Timeout])).

brpoplpush(Source, Destination, Timeout) ->
    trans_result_list(cache:execute_cmd(["BRPOPLPUSH", Source, Destination, Timeout])).

lindex(Key, Index) ->
    trans_result(cache:execute_cmd(["LINDEX", Key, Index])).

linsert(Key, Where, Relation, Value) ->
    trans_result(cache:execute_cmd(["LINSERT", Key, Relation, Where, Value])).

llen(Key) ->
    trans_result(cache:execute_cmd(["LLEN", Key])).

lpop(Key) ->
    trans_result(cache:execute_cmd(["LPOP", Key])).

rpop(Key) ->
    trans_result(cache:execute_cmd(["RPOP", Key])).


%%Values

lpush(Key, Values) ->
    trans_result(cache:execute_cmd(["LPUSH", Key|lists:map(fun(X)-> term_to_str(X) end, Values)])).

rpush(Key, Values) ->
    trans_result(cache:execute_cmd(["RPUSH", Key|lists:map(fun(X)-> term_to_str(X) end, Values)])).

lpushx(Key, Value) ->
    trans_result(cache:execute_cmd(["LPUSHX", Key, term_to_str(Value)])).

rpushx(Key, Value) ->
    trans_result(cache:execute_cmd(["RPUSHX", Key, term_to_str(Value)])).

lrange(Key, Start, End) ->
    trans_result_list(cache:execute_cmd(["LRANGE", Key, Start, End])).

lrem(Key, Count, Value) ->
    trans_result(cache:execute_cmd(["LREM", Key, Count, term_to_str(Value)])).

lset(Key, Index, Value) ->
    trans_result(cache:execute_cmd(["LSET", Key, Index, term_to_str(Value)])).

ltrim(Key, Start, End) ->
    trans_result(cache:execute_cmd(["LTRIM", Key, Start, End])).

rpoplpush(Source, Destination) ->
    trans_result(cache:execute_cmd(["RPOPLPUSH", Source, Destination])).





%%---------------------------------
%%
%%  set(集合)
%%
%%---------------------------------

sadd(Key, Members) ->
    trans_result(cache:execute_cmd(["SADD", Key|lists:map(fun term_to_str/1, Members)])).


scard(Key) ->
    trans_result(cache:execute_cmd(["SCARD", Key])).


sdiff(Keys) ->
    trans_result_list(cache:execute_cmd(["SDIFF"|Keys])).

sdiffstore(Destination, Keys) ->
    trans_result(cache:execute_cmd(["SDIFFSTORE",Destination|Keys])).

sinter(Keys) ->
    trans_result_list(cache:execute_cmd(["SINTER"|Keys])).

sinterstore(Destination, Keys) ->
    trans_result(cache:execute_cmd(["SINTERSTORE",Destination|Keys])).

sismember(Key, Member) ->
    trans_result(cache:execute_cmd(["SISMEMBER", Key, term_to_str(Member)])).


smembers(Key) ->
    trans_result_list(cache:execute_cmd(["SMEMBERS", Key])).

smove(Source, Destination, Member)->
    trans_result(cache:execute_cmd(["SMOVE", Source, Destination, term_to_str(Member)])).

spop(Key) ->
    trans_result(cache:execute_cmd(["SPOP", Key])).

srandmember(Key, Count) ->
    trans_result_list(cache:execute_cmd(["SRANDMEMBER", Key, Count])).

srem(Key, Members) ->
    trans_result(cache:execute_cmd(["SREM", Key|lists:map(fun term_to_str/1, Members)])).

sunion(Keys) ->
    trans_result_list(cache:execute_cmd(["SUNION"|Keys])).

sunionstore(Destination, Keys) ->
    trans_result(cache:execute_cmd(["SUNIONSTORE",Destination|Keys])).




%%---------------------------------
%%
%%  order set(有序集)
%%
%%---------------------------------

zadd(Key, Aparms)->
    trans_result(cache:execute_cmd(["ZADD", Key|lists:map(fun term_to_str/1, Aparms)])).

zcard(Key) ->
    trans_result(cache:execute_cmd(["ZCARD", Key])).

zcount(Key, Min, Max) ->
    trans_result(cache:execute_cmd(["ZCOUNT", Key, Min, Max])).

zincrby(Key, Increment, Member) ->
    trans_result(cache:execute_cmd(["ZINCRBY", Key, Increment, term_to_str(Member)])).

zrange(Key, Start, Stop, IsWithScore) ->
    case IsWithScore of
	true ->
	    trans_results(cache:execute_cmd(["ZRANGE", Key, Start, Stop, "WITHSCORES"]));
	false ->
	    trans_result_list(cache:execute_cmd(["ZRANGE", Key, Start, Stop]))
    end.

zrangebyscore(Key, Min, Max, IsWithScore) ->
    case IsWithScore of
	true ->
	    trans_results(cache:execute_cmd(["ZRANGEBYSCORE", Key, Min, Max, "WITHSCORES"]));
	false ->
	    trans_result_list(cache:execute_cmd(["ZRANGEBYSCORE", Key, Min, Max]))
    end.

zrank(Key, Member) ->
    trans_result(cache:execute_cmd(["ZRANK", Key, term_to_str(Member)])).


zrem(Key, Members) ->
    trans_result(cache:execute_cmd(["ZREM", Key|lists:map(fun term_to_str/1, Members)])).



zremrangebyrank(Key, Start, Stop) ->
    trans_result(cache:execute_cmd(["ZREMRANGEBYRANK", Key, Start, Stop])).

zremrangebyscore(Key, Min, Max) ->
    trans_result(cache:execute_cmd(["ZREMRANGEBYSCORE", Key, Min, Max])).


 

zrevrange(Key, Start, Stop, IsWithScore) ->
    case IsWithScore of
	true ->
	    trans_results(cache:execute_cmd(["ZREVRANGE", Key, Start, Stop, "WITHSCORES"]));
	false ->
	    trans_result_list(cache:execute_cmd(["ZREVRANGE", Key, Start, Stop]))
    end.

zrevrangebyscore(Key, Min, Max, IsWithScore) ->
    case IsWithScore of
	true ->
	    trans_results(cache:execute_cmd(["ZREVRANGEBYSCORE", Key, Min, Max, "WITHSCORES"]));
	false ->
	    trans_result_list(cache:execute_cmd(["ZREVRANGEBYSCORE", Key, Min, Max]))
    end.

zrevrank(Key, Member) ->
    trans_result(cache:execute_cmd(["ZREVRANK", Key, term_to_str(Member)])).


zscore(Key, Member) ->
    trans_result(cache:execute_cmd(["ZSCORE", Key, term_to_str(Member)])).


zunionstore(Dest, NumberKeys, Keys)->
    trans_result(cache:execute_cmd(["ZUNIONSTORE", Dest, NumberKeys|Keys])).






%%---------------------------------
%%
%% 结果转化
%%
%%---------------------------------
trans_result_to_tuple([],[]) ->
    [];

trans_result_to_tuple([Field|List1], [Value|List2]) ->
    [{Field, trans_result(Value)}| trans_result_to_tuple(List1, List2)].

trans_result_list(List)->
    lists:map(fun trans_result/1, List).

trans_results([])->
    [];
trans_results([Field,Value|Left]) ->
    [{bstr_to_term(Field),trans_result(Value)}|trans_results(Left)].

trans_results2([])->
    [];
trans_results2([Field,Value1,Value2|Left]) ->
    [{bstr_to_term(Field),trans_result(Value1),trans_result(Value2)}|trans_results2(Left)].

trans_result(Result)->
    case Result of
	_ when is_binary(Result) ->
	    bstr_to_term(Result);
	_ when is_number(Result) ->
	    Result;
	undefined ->
	    undefined;
	Other ->
	    io:format("return value:~p", [Other]),
	    Other
    end.
    



bstr_to_term(BinaryStr)->
    data_trans:string_binary_to_term(BinaryStr).


term_to_str(Term)->
    data_trans:term_to_string(Term).
    
