%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 18 Sep 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(chat).


-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("thrift/rpc_types.hrl").
-include("common_def.hrl").


-define(world_chat_priority, 1).

%% API
-export([start/0, 
	 valid_chat/0,
	 push_my_queue/0,
	 proc_req_chat_in_world_channel/1,
	 notify_notify_my_world_chat_info/0,
	notify_world_msg/1]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
%% check(Int, Index) ->
%%     Head = Index - 1,
%%     Tail = 32 - Index,
%%     <<_:Tail/integer, Res:1/integer, _:Head/integer>> = <<Int:32/integer>>,
%%     Res.

%% get_new_role_status(Status, Index, Case) ->
%%     Head = Index - 1,
%%     Tail = 32 - Index,
%%     <<H:Tail/integer, _:1/integer, T:Head/integer>> = <<Status:32/integer>>,
%%     <<NewStatus:32/integer>> = <<H:Tail/integer, Case:1/integer, T:Head/integer>>,
%%     NewStatus.

start() ->
    packet:register(?msg_req_chat_in_world_channel, {?MODULE, proc_req_chat_in_world_channel}),
    packet:register(?msg_req_get_role_detail_info, {?MODULE, proc_req_get_role_detail_info}),
    ok.

proc_req_get_role_detail_info(#req_get_role_detail_info{role_id = RoleId}) ->
    RoleInfo = player_role:get_role_detail_by_roleid(RoleId),
    packet:send(RoleInfo).


notify_notify_my_world_chat_info() ->
    packet:send(#notify_my_world_chat_info{speek_times = get_world_chat_times(), extra_times = get_extra_times()}).


proc_req_chat_in_world_channel(#req_chat_in_world_channel{msg = Msg} = _Packet) ->
    case valid_chat() of
	true ->
	    case length(Msg) > get_world_chat_byte_limit() of
		false ->
		    Role = player_role:get_db_role(player:get_role_id()),
		    Packet = #notify_world_channel_msg{msg = Msg, 
						       speaker_id = player:get_role_id(), 
						       speaker = Role:nickname()},
		    AllPids= [ X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end, 
							   redis_extend:get_members_info(online_roleid_set,role_pid_mapping))],
		    broadcast_server:broadcast_packet(AllPids, Packet, ?world_chat_priority),
		    push_my_queue(),
				save_world_msg(Packet),
		    packet:send(#notify_chat_in_world_channel_result{result = ?common_success});
		true ->
		    packet:send(#notify_chat_in_world_channel_result{result = ?common_failed})
	    end;
	false ->
	    packet:send(#notify_chat_in_world_channel_result{result = ?common_failed})
    end,
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------


%%%===================================================================
%%% Internal functions
%%%===================================================================

get_timelong() ->
    config:get(chat_how_long_time).

get_times_limit() ->
    config:get(chat_times_limit).

get_intervals() ->
    config:get(chat_min_intervals).

get_free_times() ->
    config:get(chat_free_times).

get_world_chat_cost() ->
    config:get(world_chat_price).

get_world_chat_sale_pertimes() ->
    config:get(world_chat_sale_pertimes).


get_world_chat_byte_limit() ->
    config:get(world_chat_byte_limit).



push_my_queue() ->
    NewTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
    Queue = get_my_queue(),
    set_my_queue(queue:in(NewTime, Queue)).


get_my_queue() ->
    case get(my_chat_queue) of
	undefined ->
	    Queue = queue:new(),
	    set_my_queue(Queue),
	    Queue;
	Queue ->
	    Queue
    end.

set_my_queue(Queue) ->
    put(my_chat_queue, Queue).



valid_chat() ->
    case queue:len(get_my_queue()) >= get_times_limit() of
	true ->
	    CurTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()),
	    NewQueue = pop_expire_info(get_my_queue(), CurTime),
	    case queue:len(NewQueue) < get_times_limit() of
		true ->
		    case queue:len(NewQueue) of
			0 ->
			    check_other();
			_ ->
			    Last = queue:last(NewQueue),
			    case (CurTime - Last) >= get_intervals() of
				true ->
				    check_other();
				false ->
				    sys_msg:send_to_self(?sg_world_chat_too_quick, []),
				    false
			    end
		    end;
		false ->
		    sys_msg:send_to_self(?sg_world_chat_too_quick, []),
		    false
	    end;
	false ->
	    check_other()
    end.

check_other() ->
    case player_role:check_role_in_status(?rpc_RoleStatus_MUTE) of
	true ->
	    sys_msg:send_to_self(?sg_world_chat_mute, []),
	    false;
	false ->
	    FreeTimes = get_free_times(),
	    case cache_with_expire:increase("world_chat:speak_times", player:get_role_id(), day) of
		Times when Times > FreeTimes ->
		    Cost = get_world_chat_cost(),
		    case get_extra_times() > 0  of
			true ->
			    reduce_extra_times(),
			    true;
			false ->
			    case player_role:check_emoney_enough(Cost) of
				true ->
				    proc_buy_extra_times(Cost, get_world_chat_sale_pertimes() - 1, Times),
				    %%player_role:reduce_emoney(?st_world_chat, Cost),
				    true;
				false ->
				    sys_msg:send_to_self(?sg_world_chat_emoney_not_enough, []),
				    cache_with_expire:increase("world_chat:speak_times", player:get_role_id(), -1, day),
				    false
			    end
		    end;
		Times ->
		    io_helper:format("NewSpeakTimes:~p~n", [Times]),
		    true
	    end
    end.


get_world_chat_times() ->
    case redis:hget("world_chat:speak_times", player:get_role_id()) of
	undefined ->
	    0;
	Times ->
	    Times
    end.

get_extra_times() ->
    case get(world_chat_extra_times) of
	undefined ->
	    Times = case redis:hget("world_chat:extra_times", player:get_player_id()) of
			undefined ->
			    0;
			CurTimes ->
			    CurTimes
		    end,
	    put(world_chat_extra_times, Times),
	    Times;
	Times ->
	    Times
    end.

increase_extra_times(Increase) ->
    OldTimes = get_extra_times(),
    NewTimes = OldTimes + Increase,
    put(world_chat_extra_times, NewTimes),
    redis:hset("world_chat:extra_times", player:get_player_id(), NewTimes).
reduce_extra_times() ->
    OldTimes = get_extra_times(),
    put(world_chat_extra_times, OldTimes - 1),
    redis:hset("world_chat:extra_times", player:get_player_id(), OldTimes - 1).


proc_buy_extra_times(Cost, ExtraTimes, Times) ->
    player_role:reduce_emoney(?st_world_chat, Cost),
    increase_extra_times(ExtraTimes),
    packet:send(#notify_my_world_chat_info{speek_times = Times, extra_times = ExtraTimes}).




pop_expire_info(Queue, CurTime) ->
    {Res, NewQueue} = queue:out(Queue),
    case Res of
	empty ->
	    set_my_queue(NewQueue),
	    NewQueue;
	{value, Time} ->
	    case (CurTime - Time) =< get_timelong() of
		true ->
		    FinalQueue = queue:in_r(Time, NewQueue),
		    set_my_queue(FinalQueue),
		    FinalQueue;
		false ->
		    pop_expire_info(NewQueue, CurTime)
	    end
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 通知最新几条世界消息
%% @end
%%--------------------------------------------------------------------
notify_world_msg(TcpPid) ->
	MsgList = get_world_msg_in_cache(),
	lists:foreach(
		fun(Packet) ->
			broadcast_server:broadcast_packet([TcpPid], Packet, ?world_chat_priority)
		end,
		MsgList).

get_world_msg_in_cache() ->
	redis:lrange('last_world_msg', 0, -1).

save_world_msg(Msg) ->
	redis:lpush('last_world_msg', [Msg]),
	redis:ltrim('last_world_msg', 0, config:get(save_world_msg_num) - 1).
