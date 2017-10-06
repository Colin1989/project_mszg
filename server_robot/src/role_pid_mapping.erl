-module(role_pid_mapping).
-export([mapping/2,unmapping/1,get_pid/1]).

mapping(RoleId, Pid)->
    cache:set(role_pid_mapping,RoleId,Pid).


unmapping(RoleId) ->
    cache:delete(role_pid_mapping, RoleId).


get_pid(RoleId) ->
    case cache:get(role_pid_mapping,RoleId) of
	[] -> 
	    undefined;
	[Pid] ->
	    element(2,Pid)
    end.
