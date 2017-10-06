-module(redis_extend).

-export([start/0]).

-export([get_hrank/2,exchange_hrank/5, get_hrank_range/3, get_hrank_range_and_info/4,get_hrank_info_above/4]).

-export([insert_msg_and_return_amount/3,get_msg_and_delete/1, get_msg/1, srand_members_info/3,back_up_rank_info/2,get_members_info/2, get_send_hp_info/3]).

-export([update_rank/3, update_rank_by_bucket/3,mget_bucket_card/2, mrand_bucket_member/2]).

-export([increaseby/4, add_in_rank_with_limit_count/4]).

-export([get_belong_set/2, smismember/2]).

-export([smadd/3]).



smadd(Prefix, Ids, Value) ->
    Cmds = [["SADD", lists:concat([Prefix, Id]), term_to_str(Value)] || Id<- Ids],
    cache:execute_cmd(Cmds).
smismember(Id, Keys)->
    Cmds = [["SISMEMBER", Key, term_to_str(Id)] || Key <- Keys],
    %%cache:execute_cmd(Cmds),
    Results = case length(Cmds) of
		  0 ->
		      [];
		  1 ->
		      [redis:trans_result(cache:execute_cmd(Cmds))];
		  _ ->
		      redis:trans_result_list(cache:execute_cmd(Cmds))
	      end,
    Results.
    
get_belong_set(Id, Keys) ->
    Cmds = [["SISMEMBER", Key, term_to_str(Id)] || Key <- Keys],
    %%cache:execute_cmd(Cmds),
    Results = case length(Cmds) of
		  1 ->
		      [redis:trans_result(cache:execute_cmd(Cmds))];
		  _ ->
		      redis:trans_result_list(cache:execute_cmd(Cmds))
	      end,
    case length(lists:takewhile(fun(X) -> X=:=0 end, Results)) of
	Index when Index < length(Cmds)  ->
	    {Index + 1, lists:nth(Index + 1, Keys)};
	_ ->
	    undefined
    end.



start()->
    ets:new(redis_script, [ordered_set, public, named_table]),
    ets:insert(redis_script,{get_rank_above,binary_to_list(load_get_hrank_info_above_script())}),
    ets:insert(redis_script,{get_rank_range_with_info,binary_to_list(load_get_hrank_range_and_info_script())}),
    ets:insert(redis_script,{get_rank_range,binary_to_list(load_get_hrank_range_script())}),
    ets:insert(redis_script,{exchange_hrank,binary_to_list(load_exchange_hrank_script())}),
    ets:insert(redis_script,{get_hrank,binary_to_list(load_get_hrank_script())}),
    ets:insert(redis_script,{srand_members_info,binary_to_list(load_srand_members_info_script())}),
    ets:insert(redis_script,{bak_rank_info,binary_to_list(load_bak_rank_info_script())}),
    ets:insert(redis_script,{get_members_info,binary_to_list(load_get_members_info_script())}),
    ets:insert(redis_script,{get_send_hp_info,binary_to_list(load_get_send_hp_info_script())}),
    ets:insert(redis_script,{update_rank,binary_to_list(load_update_rank_script())}),
    ets:insert(redis_script, {update_rank_by_bucket, binary_to_list(load_update_rank_by_bucket_script())}),
    ok.


get_script(ScriptName)->
    [Element] = ets:lookup(redis_script,ScriptName),
    element(2,Element).


update_rank_by_bucket(Key, Field, NewBucket) ->
    Cmds = ["EVALSHA",get_script(update_rank_by_bucket),1, Key, redis:term_to_str(Field), redis:term_to_str(NewBucket)],
    redis:trans_result(cache:execute_cmd(Cmds)).
load_update_rank_by_bucket_script()->
    Cmd = ["SCRIPT","LOAD","
                            local mainKey = KEYS[1]
                            local hkey = mainKey .. ':mybucket'
                            local orgBucket = redis.call('hget', hkey, ARGV[1])
                            if not orgBucket then
	                             orgBucket = 0
                            end
                            if orgBucket == ARGV[2] then
                            	return 0
                            end
                            local orgBucketKey = mainKey .. ':bucket:' .. orgBucket
                            local curBucketKey = mainKey .. ':bucket:' .. ARGV[2]
                            redis.call('hset', hkey, ARGV[1], ARGV[2])
                            redis.call('srem', orgBucketKey, ARGV[1])
                            redis.call('sadd', curBucketKey, ARGV[1])
                            return 1"
	  ],
    cache:execute_cmd(Cmd).

mget_bucket_card(Key, BucketList) ->
    Cmds = [['SCARD', lists:concat([Key, ':bucket:', redis:term_to_str(Bucket)])] || Bucket <- BucketList],
    case length(Cmds) of
	1 ->
	    redis:trans_result(cache:execute_cmd(Cmds));
	_ ->
	    redis:trans_result_list(cache:execute_cmd(Cmds))
    end.

mrand_bucket_member(Key, RandList) ->
    Cmds = [['SRANDMEMBER', lists:concat([Key, ':bucket:', redis:term_to_str(Bucket)]), Amount] || {Bucket, Amount} <- RandList],
    %%io:format("~p~n", [Cmds]),
    case length(Cmds) of
	1 ->
	    redis:trans_result_list(cache:execute_cmd(Cmds));
	_ ->
	    lists:concat([redis:trans_result_list(Result) || Result <- cache:execute_cmd(Cmds)])
    end.



update_rank(RankType, ObjId, NewScore)->
    Cmds = ["EVALSHA",get_script(update_rank),1, RankType, ObjId, redis:term_to_str(NewScore)],
    
    redis:trans_result(cache:execute_cmd(Cmds)).


load_update_rank_script()->
    Cmd = ["SCRIPT","LOAD","
                            local orgScoreStr = redis.call('zscore', KEYS[1], ARGV[1])
                            if not orgScoreStr then
                                orgScoreStr = '0'
                            end
                            local orgScore = math.floor(tonumber(orgScoreStr)/10000)
                            if math.floor(ARGV[2]/10000) ~= orgScore then
                                redis.call('zadd', KEYS[1], ARGV[2], ARGV[1])
                                return 1
                            else
                                return 0
                            end"
	  ],
    cache:execute_cmd(Cmd).


%%---------------------------------
%%
%%   获取set里的对应详细信息
%%
%%
%%---------------------------------

get_members_info(Key, InfoTab)->
    Cmds = ["EVALSHA",get_script(get_members_info),2,Key, InfoTab],
    Result = cache:execute_cmd(Cmds),
    %%io:format("~ndddd:~p~n",[Result]).
    redis:trans_results(Result).

get_send_hp_info(Key, InfoTab, RoleID) ->
    Cmds = ["EVALSHA",get_script(get_send_hp_info),3,Key, InfoTab, RoleID],
    Result = cache:execute_cmd(Cmds),
    redis:trans_results2(Result).

load_get_members_info_script()->
    Cmd = ["SCRIPT","LOAD","local vals=redis.call('smembers',KEYS[1])
                            local infos = {}
                            if table.getn(vals) > 0 then 
                                infos=redis.call('hmget',KEYS[2],unpack(vals)) 
                            end
                            local newvals={} 
                            for k,v in pairs(vals) do 
                                table.insert(newvals,v) 
                                table.insert(newvals,infos[k]) 
                            end 
                            return newvals"],
    cache:execute_cmd(Cmd).

load_get_send_hp_info_script() ->
    Cmd = ["SCRIPT","LOAD","local vals=redis.call('smembers',KEYS[1])
                            local newvals={}
                            for k,v in pairs(vals) do
                                local my_key = KEYS[3]..v
                                local friend_key = v..KEYS[3]
                                local my_status = redis.call('hget', KEYS[2], my_key)
                                local friend_status = redis.call('hget', KEYS[2], friend_key)
                                table.insert(newvals,v)
                                table.insert(newvals,my_status)
                                table.insert(newvals,friend_status)
                            end
                            return newvals"],
    cache:execute_cmd(Cmd).

%%rand hash实现

%%---------------------------------
%%
%%   备份排名
%%
%%
%%---------------------------------

back_up_rank_info(Key, Length)->
    Cmds = ["EVALSHA",get_script(bak_rank_info),2,lists:concat([Key,"_byrank"]), lists:concat([Key,"_bak"]), Length],
    Result = cache:execute_cmd(Cmds),
    io:format("~p~n", [Result]).

load_bak_rank_info_script()->
    Cmd = ["SCRIPT","LOAD","local RankList = {}
	    for i=1,tonumber(ARGV[1]) do table.insert(RankList, i) end
	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
            local newrange = {}
            redis.call('del',KEYS[2])
            for k,v in pairs(ranklist)do if v then table.insert(newrange,v) table.insert(newrange,k) end end
            local infos = redis.call('hmset',KEYS[2],unpack(newrange))"],
    cache:execute_cmd(Cmd).



%%---------------------------------
%%
%%  获取玩家排名
%%
%%---------------------------------
get_hrank(Key,Field)->
    Cmds = ["EVALSHA",get_script(get_hrank),3,lists:concat([Key,"_byobj"]),
	    lists:concat([Key,"_byrank"]),lists:concat([Key,"_amount"]),
	    redis:term_to_str(Field)],
    redis:trans_result(cache:execute_cmd(Cmds)).

load_get_hrank_script()->
    Cmd = ["SCRIPT","LOAD","local rank = redis.call('hget',KEYS[1],ARGV[1])
    if rank then
       return tonumber(rank)
    else
       rank = redis.call('incr',KEYS[3])
       redis.call('hset',KEYS[1],ARGV[1],rank)
       redis.call('hset',KEYS[2],rank,ARGV[1])
       return rank
    end"],
    cache:execute_cmd(Cmd).

%%---------------------------------
%%
%%  互换排名
%%
%%---------------------------------
exchange_hrank(Key, Obj1, Rank1, Obj2, Rank2)->
    %%io:format("##############~n~p:~p,~p:~p~n#############",[Obj1, Rank1, Obj2, Rank2]),
    Cmds = ["EVALSHA",get_script(exchange_hrank),2,lists:concat([Key,"_byrank"]),lists:concat([Key,"_byobj"]),
	    Rank1,Rank2,redis:term_to_str(Obj1),redis:term_to_str(Obj2)],
    cache:execute_cmd(Cmds).

load_exchange_hrank_script()->
    Cmd = ["SCRIPT","LOAD","local OrgObj = redis.call('hmget',KEYS[1],ARGV[1],ARGV[2])
    local OrgRank = redis.call('hmget',KEYS[2],ARGV[3],ARGV[4])
    redis.call('hmset',KEYS[1],ARGV[1],ARGV[4],ARGV[2],ARGV[3])
    redis.call('hmset',KEYS[2],ARGV[3],ARGV[2],ARGV[4],ARGV[1])
    if ARGV[3]~=OrgObj[1] and ARGV[4]~=OrgObj[2] then
        redis.call('hset',KEYS[1],OrgRank[2],OrgObj[1])
        redis.call('hset',KEYS[2],OrgObj[1],OrgRank[2])
        redis.call('hset',KEYS[1],OrgRank[1],OrgObj[2])
        redis.call('hset',KEYS[2],OrgObj[2],OrgRank[1])
    elseif ARGV[3]~=OrgObj[1] then redis.call('hset',KEYS[1],OrgRank[1],OrgObj[1])
       redis.call('hset',KEYS[2],OrgObj[1],OrgRank[1])
    elseif ARGV[4]~=OrgObj[2] then redis.call('hset',KEYS[1],OrgRank[2],OrgObj[2])
       redis.call('hset',KEYS[2],OrgObj[2],OrgRank[2]) end
    "],

   
    cache:execute_cmd(Cmd).


%%---------------------------------
%%
%% 获取区间
%%
%%---------------------------------
get_hrank_range(Key, StartRank, Length)->
    Cmds = ["EVALSHA",get_script(get_rank_range),1,lists:concat([Key,"_byrank"]),StartRank, Length],
    RankList = cache:execute_cmd(Cmds),
    {NewList,_NextIndex} = 
	lists:foldl(fun(X,{In,Index})-> {[{Index,redis:trans_result(X)}|In],Index+1} end, 
		    {[],StartRank},lists:filter(fun(X)-> X=/=undefined end,RankList)),
    lists:reverse(NewList).

load_get_hrank_range_script()->
    Cmd = ["SCRIPT","LOAD","local RankList = {}
	    for i=1,tonumber(ARGV[2]) do table.insert(RankList,tonumber(ARGV[1])+i-1) end
	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
            local newrange = {}
            for k,v in pairs(ranklist) do if v then table.insert(newrange,v) end end
            return newrange"],
    cache:execute_cmd(Cmd).


get_hrank_range_and_info(Key, Key2, StartRank, Length)->
    Cmds = ["EVALSHA",get_script(get_rank_range_with_info),2,lists:concat([Key,"_byrank"]),Key2,StartRank, Length],
    RankList = cache:execute_cmd(Cmds),
    trans_data(StartRank,RankList).

load_get_hrank_range_and_info_script()->
    Cmd = ["SCRIPT","LOAD","local RankList = {}
	    for i=1,tonumber(ARGV[2]) do table.insert(RankList,ARGV[1]+i-1) end
	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
            local newrange = {}
            for k,v in pairs(ranklist)do if v then table.insert(newrange,v)end end
            local infos = redis.call('hmget',KEYS[2],unpack(newrange))
            local newvals={}
            for k,v in pairs(newrange) do table.insert(newvals,v) table.insert(newvals,infos[k]) end
            return newvals
            "],
    cache:execute_cmd(Cmd).


%%---------------------------------
%%
%% 获取特定玩家前N名
%%
%%---------------------------------


get_hrank_info_above(Key, Key2, Id, N)->
    Cmds = ["EVALSHA",get_script(get_rank_above),4,lists:concat([Key,"_byrank"]),list_to_atom(lists:concat([Key,"_byobj"])),Key2,
	    lists:concat([Key,"_amount"]),N,redis:term_to_str(Id)],
    [Rank|RankList]=cache:execute_cmd(Cmds),
    StartRank = case Rank >= N of
		    true ->
			Rank - N + 1;
		    false ->
			1
		end,
    trans_data(StartRank,RankList).

load_get_hrank_info_above_script()->
    Cmd = ["SCRIPT","LOAD","local RankList = {}
            local therank = redis.call('hget',KEYS[2],ARGV[2])
            if therank then 
                therank=tonumber(therank) 
            else 
                therank = redis.call('incr',KEYS[4])
                redis.call('hset',KEYS[2],ARGV[2],therank)
                redis.call('hset',KEYS[1],therank,ARGV[2])
            end
            local startrank
            if therank >= tonumber(ARGV[1]) then startrank=therank-tonumber(ARGV[1])+1 else startrank=1 end
	    for i=1,tonumber(ARGV[1]) do table.insert(RankList,startrank+i-1) end
	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
            local newrange = {}
            for k,v in pairs(ranklist)do if v then table.insert(newrange,v)end end
            local infos = redis.call('hmget',KEYS[3],unpack(newrange))
            local newvals={therank}
            for k,v in pairs(newrange) do table.insert(newvals,v) table.insert(newvals,infos[k]) end
            return newvals
            "],
    cache:execute_cmd(Cmd).



trans_data(_Index,[])->
    [];

trans_data(Index,[Key,Info|Results])->
    Result = {Index, {redis:trans_result(Key),redis:trans_result(Info)}},
    [Result|trans_data(Index+1, Results)].

%% trans_data([])->
%%     [];

%% trans_data([Key,Info|Results])->
    
%%     NKey=case Key of
%% 	     KBin when is_binary(KBin)-> 
%% 		 binary_to_term(KBin);
%% 	     KOther->
%% 		 KOther
			
%% 	 end,
%%     Result=case Info of
%% 	       Bin when is_binary(Bin)-> 
%% 		   {NKey,binary_to_term(Bin)};
%% 	       undefined->
%% 		   {NKey,undefined};
%% 	       Other->
%% 		   {NKey,Other}
%% 	   end,
%%     [Result|trans_data( Results)].



%%---------------------------------
%%
%% 消息队列管理器
%%
%%---------------------------------

insert_msg_and_return_amount(Key,Val,Limit)->
    Cmd=[["LPUSH",Key,redis:term_to_str(Val)],["LTRIM",Key,0,Limit-1]],
    [Amount,_]=cache:execute_cmd(Cmd),
    case Amount > Limit of
	true ->
	    Limit;
	false ->
	    Amount
    end.

get_msg_and_delete(Key)->
    Cmd=[["LRANGE",Key,0,9],["DEL",Key]],
    [Infos,_]=cache:execute_cmd(Cmd),
    lists:map(fun(X)-> redis:trans_result(X) end,Infos).


get_msg(Key)->
    Cmd=[["LRANGE",Key,0,-1]],
    Infos = cache:execute_cmd(Cmd),
    lists:map(fun(X)-> redis:trans_result(X) end,Infos).

%% get_list_amount(Key)->
%%     Cmd=["LLEN",Key],
%%     cache:execute_cmd(Cmd).


%%---------------------------------
%%
%% 获取列表
%%
%%---------------------------------

srand_members_info(Key1,Key2,Count)->
    Cmds = ["EVALSHA",get_script(srand_members_info),2,Key1,Key2,Count],
    RankList = cache:execute_cmd(Cmds),
    redis:trans_results(RankList).

%% srand_members(Key1,Count)->
%%     Cmd = ["SRANDMEMBER",Key1,Count],
%%     List = cache:execute_cmd(Cmd),
%%     lists:map(fun(X)-> binary_to_term(X) end,List).

load_srand_members_info_script()->
    Cmd = ["SCRIPT","LOAD","
             local List = redis.call('srandmember',KEYS[1],ARGV[1])
             if table.getn(List)>0 then
                  local InfoList = redis.call('hmget',KEYS[2],unpack(List))
                  local newtbl={}
                  for k,v in pairs(List) do
                      table.insert(newtbl,v) 
                      table.insert(newtbl,InfoList[k])
                  end
                  return newtbl
             else
                  return {}
             end
            "],
    cache:execute_cmd(Cmd).
    

%% hash_mget(term, Key, Fields) ->
%%     NewList = lists:map(fun(X) -> 
%% 				integer_to_list(X)
%% 			end, Fields),

%%     Cmd = ["HMGET",Key|NewList],
%%     Results = cache:execute_cmd(Cmd),
%%     lists:map(fun(X) -> binary_to_term(X) end, Results);



%% hash_mget(binary, Key, Fields) ->
%%     NewList = lists:map(fun(X) -> 
%% 				term_to_binary(X)
%% 			end, Fields),

%%     Cmd = ["HMGET",Key|NewList],
%%     Results = cache:execute_cmd(Cmd),
%%     lists:map(fun(X) -> 
%% 		      case X of
%% 			  undefined ->
%% 			      undefined;
%% 			  _ when is_binary(X) ->
%% 			      binary_to_term(X); 
%% 			  Other ->
%% 			      io:format("error:~p~n", [Other]),
%% 			      X
%% 		      end

%% 	      end, Results).




%% rrset(Key,Field,Value)->
%%     Cmd = ["HSET",Key,Field,data_trans:term_to_string(Value)],
%%     cache:execute_cmd(Cmd).


%% rrget(Key,Field)->
%%     Cmd = ["HGET", Key, Field],
%%     cache:execute_cmd(Cmd).

increaseby(Key, Field, Increment, Expire)->
    Cmd=[["HINCRBY", Key, redis:term_to_str(Field), Increment],
	 ["EVAL","if redis.call('ttl',KEYS[1])==-1 then 
redis.call('expire',KEYS[1],ARGV[1]) end",1,Key,Expire]],
    cache:execute_cmd(Cmd).


add_in_rank_with_limit_count(Key, Aparms, Start, Stop) ->
	Cmds = [["ZADD", Key|lists:map(fun term_to_str/1, Aparms)],["ZREMRANGEBYRANK", Key, Start, Stop]],
	cache:execute_cmd(Cmds).


term_to_str(Term)->
	data_trans:term_to_string(Term).
    






