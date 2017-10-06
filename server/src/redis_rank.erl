-module(redis_rank).

%% -export([start/0,get_hrank/2,exchange_hrank/5, get_hrank_range/3, get_hrank_range_and_info/4,get_hrank_info_above/4]).

%% -export([insert_msg_and_return_amount/3,get_msg_and_delete/1,get_list_amount/1,srand_members/2,srand_members_info/3]).


%% -export([hash_mget/3]).

%% -export([back_up_rank_info/2]).

%% -compile(export_all).

%% start()->
%%     ets:new(redis_script, [ordered_set, public, named_table]),
%%     ets:insert(redis_script,{get_rank_above,binary_to_list(load_get_hrank_info_above_script())}),
%%     ets:insert(redis_script,{get_rank_range_with_info,binary_to_list(load_get_hrank_range_and_info_script())}),
%%     ets:insert(redis_script,{get_rank_range,binary_to_list(load_get_hrank_range_script())}),
%%     ets:insert(redis_script,{exchange_hrank,binary_to_list(load_exchange_hrank_script())}),
%%     ets:insert(redis_script,{get_hrank,binary_to_list(load_get_hrank_script())}),
%%     ets:insert(redis_script,{srand_members_info,binary_to_list(load_srand_members_info_script())}),
%%     ets:insert(redis_script,{bak_rank_info,binary_to_list(load_bak_rank_info_script())}),
%%     ok.


%% get_script(ScriptName)->
%%     [Element] = ets:lookup(redis_script,ScriptName),
%%     element(2,Element).


%% %%rand hash实现

%% %%---------------------------------
%% %%
%% %%   备份排名
%% %%
%% %%
%% %%---------------------------------

%% back_up_rank_info(Key, Length)->
%%     Cmds = ["EVALSHA",get_script(bak_rank_info),2,list_to_atom(lists:concat([Key,"_byrank"])), list_to_atom(lists:concat([Key,"_bak"])), Length],
%%     Result = cache:execute_cmd(Cmds),
%%     io:format("~p~n", [Result]).

%% load_bak_rank_info_script()->
%%     Cmd = ["SCRIPT","LOAD","local RankList = {}
%% 	    for i=1,tonumber(ARGV[1]) do table.insert(RankList, i) end
%% 	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
%%             local newrange = {}
%%             redis.call('del',KEYS[2])
%%             for k,v in pairs(ranklist)do if v then table.insert(newrange,v) table.insert(newrange,k) end end
%%             local infos = redis.call('hmset',KEYS[2],unpack(newrange))"],
%%     cache:execute_cmd(Cmd).



%% %%---------------------------------
%% %%
%% %%  获取玩家排名
%% %%
%% %%---------------------------------
%% get_hrank(Key,Field)->
%%     Cmds = ["EVALSHA",get_script(get_hrank),3,list_to_atom(lists:concat([Key,"_byobj"])),
%% 	    list_to_atom(lists:concat([Key,"_byrank"])),list_to_atom(lists:concat([Key,"_amount"])),
%% 	    term_to_binary(Field)],
%%     redis:trans_result(cache:execute_cmd(Cmds)).

%% load_get_hrank_script()->
%%     Cmd = ["SCRIPT","LOAD","local rank = redis.call('hget',KEYS[1],ARGV[1])
%%     if rank then
%%        return tonumber(rank)
%%     else
%%        rank = redis.call('incr',KEYS[3])
%%        redis.call('hset',KEYS[1],ARGV[1],rank)
%%        redis.call('hset',KEYS[2],rank,ARGV[1])
%%        return rank
%%     end"],
%%     cache:execute_cmd(Cmd).

%% %%---------------------------------
%% %%
%% %%  互换排名
%% %%
%% %%---------------------------------
%% exchange_hrank(Key, Obj1, Rank1, Obj2, Rank2)->
%%     %%io:format("##############~n~p:~p,~p:~p~n#############",[Obj1, Rank1, Obj2, Rank2]),
%%     Cmds = ["EVALSHA",get_script(exchange_hrank),2,list_to_atom(lists:concat([Key,"_byrank"])),list_to_atom(lists:concat([Key,"_byobj"])),
%% 	    Rank1,Rank2,term_to_binary(Obj1),term_to_binary(Obj2)],
%%     redis:trans_result(cache:execute_cmd(Cmds)).

%% load_exchange_hrank_script()->
%%     Cmd = ["SCRIPT","LOAD","local OrgObj = redis.call('hmget',KEYS[1],ARGV[1],ARGV[2])
%%     local OrgRank = redis.call('hmget',KEYS[2],ARGV[3],ARGV[4])
%%     redis.call('hmset',KEYS[1],ARGV[1],ARGV[4],ARGV[2],ARGV[3])
%%     redis.call('hmset',KEYS[2],ARGV[3],ARGV[2],ARGV[4],ARGV[1])
%%     if ARGV[3]~=OrgObj[1] and ARGV[4]~=OrgObj[2] then
%%         redis.call('hset',KEYS[1],OrgRank[2],OrgObj[1])
%%         redis.call('hset',KEYS[2],OrgObj[1],OrgRank[2])
%%         redis.call('hset',KEYS[1],OrgRank[1],OrgObj[2])
%%         redis.call('hset',KEYS[2],OrgObj[2],OrgRank[1])
%%     elseif ARGV[3]~=OrgObj[1] then redis.call('hset',KEYS[1],OrgRank[1],OrgObj[1])
%%        redis.call('hset',KEYS[2],OrgObj[1],OrgRank[1])
%%     elseif ARGV[4]~=OrgObj[2] then redis.call('hset',KEYS[1],OrgRank[2],OrgObj[2])
%%        redis.call('hset',KEYS[2],OrgObj[2],OrgRank[2]) end
%%     "],

   
%%     cache:execute_cmd(Cmd).


%% %%---------------------------------
%% %%
%% %% 获取区间
%% %%
%% %%---------------------------------
%% get_hrank_range(Key, StartRank, Length)->
%%     Cmds = ["EVALSHA",get_script(get_rank_range),1,list_to_atom(lists:concat([Key,"_byrank"])),StartRank, Length],
%%     RankList = cache:execute_cmd(Cmds),
%%     {NewList,_NextIndex} = 
%% 	lists:foldl(fun(X,{In,Index})-> {[{Index,redis:trans_result(X)}|In],Index+1} end, 
%% 		    {[],StartRank},lists:filter(fun(X)-> X=/=undefined end,RankList)),
%%     lists:reverse(NewList).

%% load_get_hrank_range_script()->
%%     Cmd = ["SCRIPT","LOAD","local RankList = {}
%% 	    for i=1,tonumber(ARGV[2]) do table.insert(RankList,tonumber(ARGV[1])+i-1) end
%% 	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
%%             local newrange = {}
%%             for k,v in pairs(ranklist) do if v then table.insert(newrange,v) end end
%%             return newrange"],
%%     cache:execute_cmd(Cmd).


%% get_hrank_range_and_info(Key, Key2, StartRank, Length)->
%%     Cmds = ["EVALSHA",get_script(get_rank_range_with_info),2,list_to_atom(lists:concat([Key,"_byrank"])),Key2,StartRank, Length],
%%     RankList = cache:execute_cmd(Cmds),
%%     trans_data(StartRank,RankList).

%% load_get_hrank_range_and_info_script()->
%%     Cmd = ["SCRIPT","LOAD","local RankList = {}
%% 	    for i=1,tonumber(ARGV[2]) do table.insert(RankList,ARGV[1]+i-1) end
%% 	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
%%             local newrange = {}
%%             for k,v in pairs(ranklist)do if v then table.insert(newrange,v)end end
%%             local infos = redis.call('hmget',KEYS[2],unpack(newrange))
%%             local newvals={}
%%             for k,v in pairs(newrange) do table.insert(newvals,v) table.insert(newvals,infos[k]) end
%%             return newvals
%%             "],
%%     cache:execute_cmd(Cmd).


%% %%---------------------------------
%% %%
%% %% 获取特定玩家前N名
%% %%
%% %%---------------------------------


%% get_hrank_info_above(Key, Key2, Id, N)->
%%     Cmds = ["EVALSHA",get_script(get_rank_above),4,list_to_atom(lists:concat([Key,"_byrank"])),list_to_atom(lists:concat([Key,"_byobj"])),Key2,
%% 	    list_to_atom(lists:concat([Key,"_amount"])),N,term_to_binary(Id)],
%%     [Rank|RankList]=cache:execute_cmd(Cmds),
%%     StartRank = case Rank >= N of
%% 		    true ->
%% 			Rank - N + 1;
%% 		    false ->
%% 			1
%% 		end,
%%     trans_data(StartRank,RankList).

%% load_get_hrank_info_above_script()->
%%     Cmd = ["SCRIPT","LOAD","local RankList = {}
%%             local therank = redis.call('hget',KEYS[2],ARGV[2])
%%             if therank then 
%%                 therank=tonumber(therank) 
%%             else 
%%                 therank = redis.call('incr',KEYS[4])
%%                 redis.call('hset',KEYS[2],ARGV[2],therank)
%%                 redis.call('hset',KEYS[1],therank,ARGV[2])
%%             end
%%             local startrank
%%             if therank >= tonumber(ARGV[1]) then startrank=therank-tonumber(ARGV[1])+1 else startrank=1 end
%% 	    for i=1,tonumber(ARGV[1]) do table.insert(RankList,startrank+i-1) end
%% 	    local ranklist = redis.call('hmget',KEYS[1],unpack(RankList))
%%             local newrange = {}
%%             for k,v in pairs(ranklist)do if v then table.insert(newrange,v)end end
%%             local infos = redis.call('hmget',KEYS[3],unpack(newrange))
%%             local newvals={therank}
%%             for k,v in pairs(newrange) do table.insert(newvals,v) table.insert(newvals,infos[k]) end
%%             return newvals
%%             "],
%%     cache:execute_cmd(Cmd).



%% trans_data(_Index,[])->
%%     [];

%% trans_data(Index,[Key,Info|Results])->
%%     NKey=case Key of
%% 	     KBin when is_binary(KBin)-> 
%% 		 binary_to_term(KBin);
%% 	     KOther->
%% 		 KOther
			
%% 	 end,
%%     Result=case Info of
%% 	       Bin when is_binary(Bin)-> 
%% 		   {Index,{NKey,binary_to_term(Bin)}};
%% 	       undefined->
%% 		   {Index,{NKey,undefined}};
%% 	       Other->
%% 		   {Index,{NKey,Other}}
%% 	   end,
%%     [Result|trans_data(Index+1, Results)].

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
%% %%---------------------------------
%% %%
%% %% 消息队列管理器
%% %%
%% %%---------------------------------

%% insert_msg_and_return_amount(Key,Val,Limit)->
%%     Cmd=[["LPUSH",Key,term_to_binary(Val)],["LTRIM",Key,0,Limit-1]],
%%     [Amount,_]=cache:execute_cmd(Cmd),
%%     case Amount > Limit of
%% 	true ->
%% 	    Limit;
%% 	false ->
%% 	    Amount
%%     end.

%% get_msg_and_delete(Key)->
%%     Cmd=[["LRANGE",Key,0,9],["DEL",Key]],
%%     [Infos,_]=cache:execute_cmd(Cmd),
%%     %%Cmd=["LRANGE",Key,0,9],
%%     %%Infos = cache:execute_cmd(Cmd),
%%     lists:map(fun(X)-> binary_to_term(X) end,Infos).

%% get_list_amount(Key)->
%%     Cmd=["LLEN",Key],
%%     cache:execute_cmd(Cmd).


%% %%---------------------------------
%% %%
%% %% 获取列表
%% %%
%% %%---------------------------------

%% srand_members_info(Key1,Key2,Count)->
%%     Cmds = ["EVALSHA",get_script(srand_members_info),2,Key1,Key2,Count],
%%     RankList = cache:execute_cmd(Cmds),
%%     trans_data(RankList).



%% srand_members(Key1,Count)->
%%     Cmd = ["SRANDMEMBER",Key1,Count],
%%     List = cache:execute_cmd(Cmd),
%%     lists:map(fun(X)-> binary_to_term(X) end,List).

%% load_srand_members_info_script()->
%%     Cmd = ["SCRIPT","LOAD","
%%              local List = redis.call('srandmember',KEYS[1],ARGV[1])
%%              if table.getn(List)>0 then
%%                   local InfoList = redis.call('hmget',KEYS[2],unpack(List))
%%                   local newtbl={}
%%                   for k,v in pairs(List) do
%%                       table.insert(newtbl,v) 
%%                       table.insert(newtbl,InfoList[k])
%%                   end
%%                   return newtbl
%%              else
%%                   return {}
%%              end
%%             "],
%%     cache:execute_cmd(Cmd).
    

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








