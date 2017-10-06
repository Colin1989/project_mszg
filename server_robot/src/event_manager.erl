-module(event_manager).


-export([start/0,register/2,unregister/2,send_event_msg/1,router/2]).


start()->
    ets:new(?MODULE, [bag, named_table, public]),
    ok.

send_event_msg(EventMsg)->
    Type = element(1,EventMsg),
    router(Type, EventMsg).


router(Type, Data) ->
    FunList =  ets:lookup(?MODULE, Type),

    lists:foreach(fun({_EventType, {Module,Fun}}) ->
			  %%io:format("event data ~p~n", [{Module, Fun, Data}]),			  
			  Module:Fun(Data) 
		  end,
		  FunList).


%% 绑定消息协议类型和函数
register(EventType, {Module, Fun}) ->
    case check_fun_export(Module, Fun) of
	true ->
	    ets:insert(?MODULE, {EventType, {Module, Fun}});
	false ->
	    throw(lists:concat([Module,'_not_export_',Fun,'/1']))
    end.


unregister(EventType, FunTuple) ->
    ets:delete_object(?MODULE, {EventType, FunTuple}).



check_fun_export(Module, Fun)->
    ModuleInfo = Module:module_info(),
    {_,ExtraInfo} = proplists:lookup(exports,ModuleInfo),
    FunList = proplists:lookup_all(Fun,ExtraInfo),
    case lists:filter(fun({_,ArgAmount})-> ArgAmount=:=1 end, FunList) of
	[] ->
	    false;
	[_Fun] ->
	    true
    end.
