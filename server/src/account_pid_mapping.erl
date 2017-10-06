%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  账号和玩家进程的映射
%%% @end
%%% Created : 30 Oct 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(account_pid_mapping).

-export([start/0, mapping/2, unmapping/1, get_pid/1,has_mapped/1]).

-export([map_player_pid/2, unmap_player_pid/1, get_player_pid/1]).

start() ->
    %%ets:new(account_pid_mapping, [named_table, public]).
    ok.

%% 账号和pid的映射
mapping(Account, Pid) ->
    %%ets:insert(account_pid_mapping, {Account, Pid}).
    cache:set(account_pid_mapping,Account,Pid).

%% 解除账号和pid的映射
unmapping(Account) ->
    %%ets:delete(account_pid_mapping, Account).
    cache:delete(account_pid_mapping, Account).


%% 发送包给处理函数处理
get_pid(Account) ->
    case cache:get(account_pid_mapping,Account) of
	[] -> 
	    undefined;
	[Pid] ->
	    element(2,Pid)
    end.
%%查看账号是否已经登录
has_mapped(Account)->
    case cache:get(account_pid_mapping,Account) of
	[] -> 
	    false;
	[Pid] ->
	    element(2,Pid)
    end.


%% 账号和playerpid的映射
map_player_pid(Account, Pid) ->
	cache:set(account_playerpid_mapping, Account, Pid).

%% 解除账号和playerpid的映射
unmap_player_pid(Account) ->
	cache:delete(account_playerpid_mapping, Account).


%% 发送包给处理函数处理
get_player_pid(Account) ->
    case cache:get(account_playerpid_mapping, Account) of
	[] ->
	    undefined;
	[Pid] ->
	    element(2, Pid)
    end.
