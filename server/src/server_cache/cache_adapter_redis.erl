-module (cache_adapter_redis).
-author('shen_likun@163.com').
-behaviour(cache_adapter).

-define(cache_name,cache_redis_server).

-export([initConn/1, start/0, start/1, stop/1, terminate/1]).
-export([get/3, set/4, delete/2, delete/3, set/5, increase/4]).
-export([insert/3,remove/3,execute_cmd/2]).
%%-export([insert/3, remove/3, getall/2, get_all_info/3, is_member/3 , get_member_amount/2,execute_cmd/2, get_table_len/2]).

start() ->
    start([]).

start(Options) ->
    CacheServers = proplists:get_value(cache_servers, Options, []),
    {ok, _Pid} = redo:start_link(?cache_name, CacheServers),
    ok.

stop(Conn) ->
    redo:shutdown(Conn). 

initConn(_Options) ->
    {ok, ?cache_name}.

terminate(_Conn) ->
    ok.

get(Conn, Key, Field) ->
    case redo:cmd(Conn,["HGET",Key,term_to_str(Field)]) of
        Bin when is_binary(Bin)-> 
            [{Field,bstr_to_term(Bin)}];
	undefined->
	    [];
	Other->
	    Other
			
    end.

%% get_int(Conn, Key, Field) ->
%%     case redo:cmd(Conn,["HGET",Key,term_to_binary(Field)]) of
%%         Bin when is_binary(Bin)-> 
%% 	    List = binary_to_list(Bin),
%%             [{Field,list_to_integer(List)}];
%% 	undefined->
%% 	    [];
%% 	Other->
%% 	    Other
			
%%     end.
%%count_statics
set(Conn, Key, Field , Val, Expire) ->
    %%redo:cmd(Conn,["HSET",Key, term_to_binary(Field), term_to_binary(Val)]),
    %%eval "if redis.call('ttl',KEYS[1])==-1 then redis.call('expire',KEY[1],1000) end" 1 test
    %%[eval,"if redis.call('ttl',KEYS[1])==-1 then redis.call('expire',KEYS[1],ARGV[1]) end",1,test,datetime:get_today_left_second()],
    %%["EXPIRE",Key,datetime:get_today_left_second()]
    redo:cmd(Conn,[["HSET",Key, term_to_str(Field), term_to_str(Val)],
            ["EVAL","if redis.call('ttl',KEYS[1])==-1 then redis.call('expire',KEYS[1],ARGV[1]) end",1,Key,Expire]]).
set(Conn, Key, Field , Val) ->
    redo:cmd(Conn,["HSET",Key, term_to_str(Field), term_to_str(Val)]).

delete(Conn, Key)->
    redo:cmd(Conn,["DEL", Key]).

%% get_table_len(Conn, Key) ->
%%     redo:cmd(Conn, ["HLEN", Key]).

%%set
insert(Conn, Key, Val)->
    redo:cmd(Conn,["SADD", Key, term_to_str(Val)]).

remove(Conn, Key, Val)->
    redo:cmd(Conn,["SREM", Key, term_to_str(Val)]).

%% is_member(Conn, Key, Val)->
%%     case redo:cmd(Conn,["SISMEMBER", Key, term_to_str(Val)]) of
%% 	Bin when is_binary(Bin)-> 
%% 	    Result = bstr_to_term(Bin),
%%             Result =/= 0;
%% 	undefined->
%% 	    false;
%% 	Other->
%% 	    Other =/= 0 
%%     end.

%% get_member_amount(Conn, Key)->
%%     case redo:cmd(Conn,["SCARD", Key]) of
%% 	Bin when is_binary(Bin)-> 
%% 	    Result = bstr_to_term(Bin),
%%             Result;
%% 	Other->
%% 	    Other
%%     end.

%% getall(Conn, Key)->
%%     lists:map(fun(X) ->
%% 		      bstr_to_term(X)
%% 	      end, redo:cmd(Conn,["SMEMBERS", Key])).

%% get_all_info(Conn, Key, InfoTab)->
%%     Result = redo:cmd(Conn,["EVAL","local vals=redis.call('smembers',KEYS[1])
%%                                     local infos = {}
%%                                     if table.getn(vals) > 0 then infos=redis.call('hmget',KEYS[2],unpack(vals)) end
%%                                     local newvals={} 
%% for k,v in pairs(vals) do table.insert(newvals,v) table.insert(newvals,infos[k]) end return newvals",2,Key,InfoTab]),
%% %%io:format("~ndddd:~p~n",[Result]).
%%     trans_data(Result).
   %% lists:map(fun(X) ->
    %%		      trans_data(X)
    %%	      end, Result).

execute_cmd(Conn, Cmds)->
    redo:cmd(Conn,Cmds).
%% trans_data([])->
%%     [];

%% trans_data([Key,Info|Results])->
%%     NKey=case Key of
%% 	     KBin when is_binary(KBin)-> 
%% 		 bstr_to_term(KBin);
%% 	     KOther->
%% 		 KOther
			
%% 	 end,
%%     Result=case Info of
%% 	       Bin when is_binary(Bin)-> 
%% 		   {NKey,bstr_to_term(Bin)};
%% 	       undefined->
%% 		   {NKey,undefined};
%% 	       Other->
%% 		   {NKey,Other}
%% 	   end,
%%     [Result|trans_data(Results)].
%redo:cmd(Conn,["SMEMBERS", Key])).

%% local vals=redis.call(smembers,KEYS[1]) local newvals={} for k,v in pairs(vals) do table.insert(newvals,redis:call(hget,KEYS[2],v)) end return newvals











%%计数使用
increase(Conn,Key,Field,Expire)->
    %%["EVAL","local old = redis.call('hget',KEYS[1],ARGV[1]) ,local oldvalue ,
    %%if old then oldvalue=tonumber(old) else oldvalue=0 end ,redis.call('expire',KEYS[1],oldvalue+1) end",1,Key,Field]
    case Expire of
	-1 ->
	    redo:cmd(Conn,["HINCRBY", Key, term_to_str(Field),1]);
	_ ->
	    redo:cmd(Conn,[["HINCRBY", Key, term_to_str(Field),1],["EVAL","if redis.call('ttl',KEYS[1])==-1 then 
redis.call('expire',KEYS[1],ARGV[1]) end",1,Key,Expire]])
    end.
    %% case Expire of
%% 	-1 ->
%% 	    redo:cmd(Conn,["EVAL","local old = redis.call('hget',KEYS[1],ARGV[1]) local oldvalue 
%% if old then oldvalue=tonumber(old) else oldvalue=0 end  redis.call('hset',KEYS[1],ARGV[1],oldvalue+1)",1,Key,term_to_binary(Field)]);
%% 	_ ->
%%             redo:cmd(Conn,["EVAL","local old = redis.call('hget',KEYS[1],ARGV[1]) local oldvalue 
%% if old then oldvalue=tonumber(old) else oldvalue=0 end  redis.call('hset',KEYS[1],ARGV[1],oldvalue+1)
%% if redis.call('ttl',KEYS[1])==-1 then redis.call('expire',KEYS[1],ARGV[2]) end",1,Key,term_to_binary(Field),Expire])
%%     end.





delete(Conn, Key, Field) ->
    redo:cmd(Conn, ["HDEL", Key,term_to_str(Field)]).




bstr_to_term(BinaryStr)->
    data_trans:string_binary_to_term(BinaryStr).


term_to_str(Term)->
    data_trans:term_to_string(Term).
    



