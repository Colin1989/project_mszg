-module(broadcast).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").

-export([broadcast/2]).


broadcast(MstType, Params)->
    AllPids=redis_extend:get_members_info(online_roleid_set,role_pid_mapping),
    lists:foreach(fun({_, Pid}) ->
			  case Pid of
			    undefined ->
				ok;
			    Pid when is_pid(Pid) -> 
				  sys_msg:send(Pid,MstType,Params)
				%%packet:send(Pid,#notify_friend_list{type=?modify,friends=[MyInfo]})
			end
		  end, AllPids),
    ok.







