-module(event_router).


-export([start/0,register/2,unregister/2,send_event_msg/1,router/2,unregister_myevent/2,reregister_myevent/2]).


start()->
    ets:new(?MODULE, [bag, named_table, public]),
    ok.

send_event_msg(EventMsg)->
    Type = element(1,EventMsg),
    router(Type, EventMsg).


router(Type, Data) ->
    FunList =  ets:lookup(?MODULE, Type),
    lists:foreach(fun({_, {Module,Fun}}) -> do_function(Type, {Module, Fun}, Data) end,FunList).

do_function(Type, {Module,Fun}, Data)->
    case is_ignoreevent(Type, {Module,Fun}) of
	true ->
	    ok;
	false ->
	    Module:Fun(Data) 
    end.


%% 绑定消息协议类型和函数
register(EventType, {Module, Fun}) ->
    case check_fun_export(Module, Fun) of
	true ->
	    ets:insert(?MODULE, {EventType, {Module, Fun}});
	false ->
	    throw(lists:concat([Module,'_not_export_',Fun,'/1']))
    end.

unregister_myevent(EventType, FunTuple)->
    IgnoreEvent = case get(my_ignore_event) of
		      undefined ->
			  dict:new();
		      Dict ->
			  Dict
		  end,
    NewDict = dict:append({EventType, FunTuple}, 1, IgnoreEvent),
    put(my_ignore_event, NewDict).

reregister_myevent(EventType, FunTuple)->
    IgnoreEvent = case get(my_ignore_event) of
		      undefined ->
			  dict:new();
		      Dict ->
			  Dict
		  end,
    NewDict = dict:erase({EventType, FunTuple}, IgnoreEvent),
    put(my_ignore_event, NewDict).

is_ignoreevent(EventType, FunTuple)->
    case get(my_ignore_event) of
	undefined ->
	    false;
	Dict ->
	    case dict:find({EventType, FunTuple}, Dict) of
		error ->
		    false;
		_ ->
		    true
	    end
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
