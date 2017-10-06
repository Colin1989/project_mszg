%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%  —π¡¶≤‚ ‘π§æﬂ
%%% @end
%%% Created : 31 Oct 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(stress).

-define(rand_base, 2000).

-define(statics_base_time, 1000).

-export([start/1, spawn_robot/5, loop_observer/0, loop_statics/3]).



loop_observer() ->
    receive
	increment ->
	    increase();
	{update_amount, Amount} ->
	    update_amount(Amount);
	{From, get_count} ->
	    From!{self(), get_count(), get_robot_amount()}
    end,
    loop_observer().

loop_statics(OldValue, ObsPid, Time) ->
    timer:sleep(Time),
    ObsPid ! {self(), get_count},
    {NewValue, RobotAmount} = receive 
		   {ObsPid,Response, Amount}->
		       {Response, Amount}
	       end,
    io:format("CurRobot:~p       Status:~p/~pms~n", [RobotAmount, NewValue - OldValue, Time]),
    loop_statics(NewValue, ObsPid, Time).


increase() ->
    put(count, get_count()+1).

update_amount(Amount) ->
    put(robot_amount, get_robot_amount()+Amount).


get_robot_amount() ->
    case get(robot_amount) of
	undefined ->
	    0;
	Count ->
	    Count
    end.

get_count() ->
    case get(count) of
	undefined ->
	    0;
	Count ->
	    Count
    end.
    
start([Ip, Port, Count, BaseTime, Start]) ->
    %%put(start, Start),
    regular:start(),
    ObserverPid = spawn(?MODULE, loop_observer, []),
    spawn(?MODULE, loop_statics, [0,ObserverPid,?statics_base_time]),
    code:add_patha("../deps/erlsom/ebin"),
    tplt:read_template_file("./stress_test/"),
    tplt:read_template_file("./template/"),
    packet_crypto:init(),
    NCount = list_to_integer(Count),
    rand:seed(now()),
    do_start(Ip, Port, NCount + list_to_integer(Start), list_to_integer(Start), ObserverPid, list_to_integer(BaseTime)),
    timer:sleep(170000000).

do_start(_Ip, _Port, Start, Start, _ObserverPid, _BaseTime)->
    ok;
do_start(Ip, Port, Count, InitCount, ObserverPid, BaseTime) ->
     case (Count rem 50) == 0 of
     	true ->
     	    timer:sleep(BaseTime);
     	false ->
     	    ok
     end,
    spawn_robot(Ip, Port, Count, ObserverPid, BaseTime),
    do_start(Ip, Port, Count - 1, InitCount, ObserverPid, BaseTime).

%% spawn_robot(Ip, Port, 0, InitCount) ->
%%     spawn_robot(Ip, Port, InitCount, InitCount);
spawn_robot(Ip, Port, Count, ObserverPid, BaseTime) ->
    Account = "test" ++ integer_to_list(Count),
    spawn(robot, start, [Ip, Port, "robot_" ++ Account, "111111", rand:uniform(BaseTime),ObserverPid]).
    %%robot:start([Ip, Port, Account, "111111"]).

