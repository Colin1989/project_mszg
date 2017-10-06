%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  �˺ź���ҽ��̵�ӳ��
%%% @end
%%% Created : 30 Oct 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(account_pid_mapping).

-export([start/0, mapping/2, unmapping/1, get_pid/1,has_mapped/1]).

start() ->
    %%ets:new(account_pid_mapping, [named_table, public]).
    ok.

%% �˺ź�pid��ӳ��
mapping(Account, Pid) ->
    %%ets:insert(account_pid_mapping, {Account, Pid}).
    cache:set(account_pid_mapping,Account,Pid).

%% ����˺ź�pid��ӳ��
unmapping(Account) ->
    %%ets:delete(account_pid_mapping, Account).
    cache:delete(account_pid_mapping, Account).


%% ���Ͱ�������������
get_pid(Account) ->
    case cache:get(account_pid_mapping,Account) of
	[] -> 
	    throw(not_found_account_pid_mapping);
	[Pid] ->
	    element(2,Pid)
    end.
%%�鿴�˺��Ƿ��Ѿ���¼
has_mapped(Account)->
    case cache:get(account_pid_mapping,Account) of
	[] -> 
	    false;
	[Pid] ->
	    element(2,Pid)
    end.
    

