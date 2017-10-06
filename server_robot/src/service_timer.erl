-module(service_timer).

-export([start/2, add_proc/3, proc_timer_event/1, delete_timer/1, clear_self_timer/0]).

start(TimeCell, TimerName)->
    TblName = list_to_atom(lists:concat([TimerName,'_event_tbl'])),
    ets:new(TblName, [bag, named_table, public]),
    ets:insert(TblName, {prev_timer, calendar:datetime_to_gregorian_seconds(erlang:localtime())}),
    
    Job = {{daily, {every, {TimeCell, sec}, {between, {0, am}, {11, 59, 59, pm}}}},
    	   {?MODULE, proc_timer_event, [TimerName]}},
    %% Job = {{daily, {every, {300, sec}, {between, {0, am}, {11, 59, 59, pm}}}},
    %% 	   {rank_statics, back_rank_info, [3]}},
    Ref = erlcron:cron(Job),
    ets:insert(TblName, {timer_ref, Ref}),
    Ref.



add_proc(TimerName, TriggerTime, FuncTuple)->
    TblName = list_to_atom(lists:concat([TimerName,'_event_tbl'])),
    add_my_timers(TimerName, TriggerTime, FuncTuple),
    ets:insert(TblName, {TriggerTime, FuncTuple}),
    ok.


delete_timer(TimerName)->
    TblName = list_to_atom(lists:concat([TimerName,'_event_tbl'])),
    [{_, TimerRef}] = ets:lookup(TblName, timer_ref),
    erlcron:cancel(TimerRef),
    ets:delete(TblName),
    ok.


clear_self_timer()->
    Timers = get_my_timers(),
    lists:foreach(fun({TimerName, Trigger, FuncTuple}) ->
			  ets:delete_object(TimerName, {Trigger, FuncTuple})
		  end, Timers).

get_my_timers()->
    case get(my_timer) of
	undefined ->
	    [];
	MyTimes ->
	    MyTimes
    end.

add_my_timers(TimerName , Trigger, FuncTuple)->
    put(my_timer, [{TimerName, Trigger, FuncTuple}|get_my_timers()]).


%% del_proc(TimerName, FuncTuple)->
%%     ok.


proc_timer_event(TimerName)->
    %%io:format("1~n"),
    TblName = list_to_atom(lists:concat([TimerName,'_event_tbl'])),
    CurTime = calendar:datetime_to_gregorian_seconds(erlang:localtime()),
    [{_, PrevTime}] = ets:lookup(TblName, prev_timer),
    TriggerList = make_trigger_list(PrevTime + 1, CurTime),
    %%io:format("~p~n", [TriggerList]),
    lists:foreach(fun(X) ->
			  case ets:lookup(TblName, X) of
			      [] ->
				  
				  ok;
			      EventList ->
				  lists:foreach(fun({_, {Module, Fun, Params}}) ->
							%%io:format("4~n"),
							case Module:Fun(Params) of
							    {stop, normal} ->
								ok;
							    {repeat, Trigger, {M, F, P}} when Trigger > CurTime->
								ets:insert(TblName, {Trigger, {M, F, P}});
							    _ ->
								ok
							end
						end, EventList),
				  ets:delete(TblName, X)
			  end
		     end,
		  TriggerList),
    %%io:format("3~n"),
    %%io:format("CurTime~p~n", [CurTime]),
    ets:delete(TblName, prev_timer),
    ets:insert(TblName, {prev_timer, CurTime}),
    ok.




make_trigger_list(CurTime, EndTime) when CurTime > EndTime ->
    [];
make_trigger_list(CurTime, EndTime) ->
    [CurTime| make_trigger_list(CurTime + 1, EndTime)].



    
