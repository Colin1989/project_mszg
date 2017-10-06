%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 15 Sep 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(activity_copy).


-include("tplt_def.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("event_def.hrl").


%% API
-export([start/0,
	 check_copy_unlock/1,
	 check_activities_opening/1,
	 proc_req_enter_activity_copy/1,
	 proc_req_settle_activity_copy/1,
	 proc_notify_activity_copy_info/0]).


%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_enter_activity_copy, {?MODULE, proc_req_enter_activity_copy}),
    packet:register(?msg_req_settle_activity_copy, {?MODULE, proc_req_settle_activity_copy}),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

proc_notify_activity_copy_info() ->
    packet:send(#notify_activity_copy_info{play_times = get_times()}).


proc_req_enter_activity_copy(#req_enter_activity_copy{copy_id = CopyId}) ->
    case check_copy_unlock(CopyId) of
	true ->
	    SuccessPacket = get_gameinfo(CopyId),
	    cache:set(list_to_atom(lists:concat(['reborn_times:', ?activity_copy])), player:get_role_id(), 0),
	    CopyInfo = tplt:get_data(activity_copy_tplt, CopyId),
	    cache_with_expire:increase("activity_copy:play_times", player:get_role_id(), day),
	    NewHp = power_hp:cost_hp(cost, player:get_role_id(), CopyInfo#activity_copy_tplt.need_power),%%扣体力
	    packet:send(#notify_role_info_change{type = "power_hp", new_value = NewHp}),
	    packet:send(SuccessPacket);
	false ->
	    packet:send(#notify_enter_activity_result{result = ?common_failed})
    end.

proc_req_settle_activity_copy(#req_settle_activity_copy{game_id = GameId, result = Result, pickup_items = PickItems, gold = Gold}) ->
    case battle:get_mapinfo() of
	{GameId,CopyId,AllMap}->
	    case game_validation:game_validate([],Result, Gold, PickItems, AllMap) of
		true ->
		    assistance:assistance_settle(Result, ?st_activity_copy_settle),
		    case Result of
			?game_lost->
			    game_log:write_game_log(Result, ?activity_copy, 
						    player:get_role_id(),
						    GameId,
						    0,%%Life,
						    0,%%MaxLife,
						    0,%%CostRound,
						    PickItems,0,0,
						    [], 
						    {GameId, CopyId, AllMap}, Gold),
			    packet:send(#notify_settle_activity_copy_result{result=?game_lost});
			?game_win ->
			    game_settle(Result, CopyId, GameId, PickItems, Gold)
			    %%game_copy:update_pass_copy(CopyId,{Result,Score})
		    end;
		false ->
		    packet:send(#notify_settle_activity_copy_result{result=?game_lost})	
	    end;
	_->
	    sys_msg:send_to_self(?sg_game_settle_error,[]),
	    packet:send(#notify_settle_activity_copy_result{result=?game_error})

    end,
    battle:clear_mapinfo().

game_settle(Result, CopyId, GameId ,PickUpItems, Gold)->
    RoleId = player:get_role_id(),
    CurRole = update_gold_exp(RoleId, CopyId, Gold),
    player_role:notify_role_info(CurRole),
    battle:giveout_items(PickUpItems, ?st_activity_copy_settle),
    game_log:write_game_log(Result, ?activity_copy, RoleId, GameId,
			    0,
			    0,%%,MaxLife
			    0,%%,CostRound
			    [], 0, 0, 
			    [], 
			    battle:get_mapinfo(),
			    Gold),
    activeness_task:update_activeness_task_status(activity_copy),
    event_router:send_event_msg(#event_activity_copy{result = Result}),
    packet:send(#notify_settle_activity_copy_result{result=?game_win}).

update_gold_exp(RoleId, CopyId, ExtraGold) ->
    Role = player_role:get_db_role(RoleId),
    CopyInfo = tplt:get_data(activity_copy_tplt, CopyId),
    {ok, NewRole} = player_role:add_exp(Role, CopyInfo#activity_copy_tplt.exp),
    player_role:add_gold(?st_activity_copy_settle, CopyInfo#activity_copy_tplt.gold + ExtraGold),       %%加金币
    Gold = CopyInfo#activity_copy_tplt.gold + Role:gold() + ExtraGold,
    CurRole = NewRole:set(gold, Gold),
    CurRole.



get_gameinfo(CopyId)->
    {GameId,AllMap}=game_copy:get_activity_copy_game_info(CopyId),
    battle:set_mapinfo(GameId,CopyId,AllMap),
    #notify_enter_activity_result{result=?enter_game_success, gamemaps=AllMap, game_id=GameId}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%判断活动副本是否解锁
check_copy_unlock(CopyId) ->
    CopyInfo = tplt:get_data(activity_copy_tplt, CopyId),
    ActiveType = CopyInfo#activity_copy_tplt.copy_group_id,
    ActivityInfo = tplt:get_data(activities_tplt, ActiveType),
    case player_role:level_check(CopyInfo#activity_copy_tplt.need_level) of
	true ->
	    case power_hp:get_power_hp() >= CopyInfo#activity_copy_tplt.need_power of
		true ->
		    case check_times_enough() of
			true ->
			    case check_activities_opening(ActivityInfo) of
				true ->
				    true;
				false ->
				    sys_msg:send_to_self(?sg_activity_copy_not_open, []),
				    false
			    end;
			false ->
			    sys_msg:send_to_self(?sg_activity_copy_times_use_up, []),
			    false
		    end;
		false ->
		    sys_msg:send_to_self(?sg_activity_copy_ph_not_enough, []),
		    false
	    end;
	false ->
	    sys_msg:send_to_self(?sg_activity_copy_level_not_enough, []),
	    false
    end.


%%检测剩余次数是否足够
check_times_enough() ->
    get_times() < config:get(activity_copy_free_time) + vip:get_privilege_count(9).


get_times() ->
    case redis:hget("activity_copy:play_times", player:get_role_id()) of
	undefined ->
	    0;
	Times ->
	    Times
    end.




%%判断活动是否处于开启状态，时间
check_activities_opening(ActivityInfo) ->
    {Date, _} = {{_, Month, Day}, {Hour, Min, _}} = erlang:localtime(),
    case ActivityInfo#activities_tplt.time_type of
	1 ->%%week
	    WeekDay = datetime:day_of_the_week(Date),
	    check_week_time(make_week_sec(WeekDay, Hour, Min, 0), ActivityInfo#activities_tplt.begin_time_array, 
			   ActivityInfo#activities_tplt.end_time_array);
	2 ->%%month
	    LastDayOfMonth = datetime:last_day_of_the_month(element(1, Date), element(2, Date)),
	    check_month_time({LastDayOfMonth, make_month_sec(LastDayOfMonth, Day, Hour, Min, 0)}, 
			     ActivityInfo#activities_tplt.begin_time_array, 
			   ActivityInfo#activities_tplt.end_time_array);
	3 ->%%year
	    check_year_time(make_year_sec(Month, Day, Hour, Min, 0), 
			    ActivityInfo#activities_tplt.begin_time_array, 
			   ActivityInfo#activities_tplt.end_time_array)
    end.


check_time_legal(StartSec, EndSec, NowSec) ->
    ((StartSec =< NowSec) andalso (EndSec >= NowSec))
	orelse((StartSec > EndSec) andalso ((StartSec =< NowSec) orelse(EndSec >= NowSec))).

%每周的活动
check_week_time(_, [], []) ->
    false;

check_week_time(NowSec, [{SWeekday, SHour, SMin}|BeginTimes], [{EWeekday, EHour, EMin}|EndTimes]) ->
    StartSec =make_week_sec(SWeekday, SHour, SMin, 0),
    EndSec = make_week_sec(EWeekday, EHour, EMin, 59),
    case check_time_legal(StartSec, EndSec, NowSec) of
	true ->
	    true;
	false ->
	    check_week_time(NowSec, BeginTimes, EndTimes)
    end.

make_week_sec(WeekDay, Hour, Min, Extra) ->
    WeekDay * 86400 + Hour * 3600 + Min * 60 + Extra.


%%每个月的活动
check_month_time(_, [], []) ->
    false;

check_month_time({LastDayOfMonth, NowSec} = Data, 
		 [{SMonthDay, SHour, SMin}|BeginTimes], [{EMonthDay, EHour, EMin}|EndTimes]) ->
    StartSec = make_month_sec(LastDayOfMonth, SMonthDay, SHour, SMin, 0),
    EndSec = StartSec = make_month_sec(LastDayOfMonth, EMonthDay, EHour, EMin, 59),
    case check_time_legal(StartSec, EndSec, NowSec) of
	true ->
	    true;
	false ->
	    check_month_time(Data, BeginTimes, EndTimes)
    end.

make_month_sec(LastDay, MonthDay, Hour, Min, Extra) ->
    RDay = case MonthDay < 0 of
	       true -> LastDay + 1 + MonthDay;
	       false -> MonthDay
	   end,
    RDay * 86400 + Hour * 3600 + Min * 60 + Extra.



%%每年的活动
check_year_time(_, [], []) ->
    false;

check_year_time(NowSec, [{SMonth, SDay, SHour, SMin}|BeginTimes], [{EMonth, EDay, EHour, EMin}|EndTimes]) ->
    StartSec = make_year_sec(SMonth, SDay, SHour, SMin, 0),
    EndSec = StartSec = make_year_sec(EMonth, EDay, EHour, EMin, 59),
    case check_time_legal(StartSec, EndSec, NowSec) of
	true ->
	    true;
	false ->
	    check_year_time(NowSec, BeginTimes, EndTimes)
    end.

make_year_sec(Month, Day, Hour, Min, Extra) ->
    Month * 2678400 + Day * 86400 + Hour * 3600 + Min * 60 + Extra.



