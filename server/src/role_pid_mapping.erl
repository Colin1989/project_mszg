-module(role_pid_mapping).
-export([mapping/2,unmapping/1,get_pid/1]).

-export([map_player_pid/2, unmap_player_pid/1, get_player_pid/1]).

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


map_player_pid(RoleId, Pid)->
    cache:set(role_playerpid_mapping,RoleId,Pid).


unmap_player_pid(RoleId) ->
    cache:delete(role_playerpid_mapping, RoleId).


get_player_pid(RoleId) ->
    case cache:get(role_playerpid_mapping,RoleId) of
	[] -> 
	    undefined;
	[Pid] ->
	    element(2,Pid)
    end.

