%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created :  8 Jul 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(online_award).

-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").

%%-record(online_award_info, {online_time = 0, has_gotten_award = []}).

%% API
-export([start/0,
	 proc_req_get_online_award/1,
	 notify_online_award_info/0,
	 update_online_time/0]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_get_online_award, {?MODULE, proc_req_get_online_award}),
    ok.


proc_req_get_online_award(#req_get_online_award{online_award_id = AwardId} = _Packet)->
    #online_award_tplt{lev_range = [Min, Max], minutes = Minutes, ids = Ids, amounts = Amounts} = tplt:get_data(online_award_tplt, AwardId),
    case check_online_award_enable(Min, Max, Minutes) of
	{true, HasGetAwards} ->
	    set_awards_info_in_cache(player:get_role_id(), [Minutes|HasGetAwards]),
	    reward:give(Ids, Amounts, ?st_online_award),
	    packet:send(#notify_get_online_award_result{result = ?common_success}),
	    ok;
	{false, lev_err} ->
	    sys_msg:send_to_self(?sg_online_award_lev_err, []),
	    packet:send(#notify_get_online_award_result{result = ?common_failed});
	{false, time_err} ->
	    sys_msg:send_to_self(?sg_online_award_time_err, []),
	    packet:send(#notify_get_online_award_result{result = ?common_failed});
	{false, has_gotten} ->
	    sys_msg:send_to_self(?sg_online_award_has_gotten, []),
	    packet:send(#notify_get_online_award_result{result = ?common_failed})
    end,
    ok.


notify_online_award_info() ->
    packet:send(#notify_online_award_info{total_online_time = get_total_online_time(player:get_role_id()), 
					  has_get_awards = has_get_awards()}),
    ok.




%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------





%%%===================================================================
%%% Internal functions
%%%===================================================================

check_online_award_enable(MinLev, MaxLev, Minutes)->
	RoleLev = player_role:get_level(),
	case (MinLev =< RoleLev) and (MaxLev >= RoleLev) of
	    true ->
		case get_total_online_time(player:get_role_id()) < Minutes * 60 of
		    true ->
			{false, time_err};
		    false ->
			HasGetAwards = has_get_awards(),
			case length(HasGetAwards) =:= length(HasGetAwards -- [Minutes]) of
			    true ->
				{true, HasGetAwards};
			    false ->
				{false, has_gotten}
			end
		end;
	    false ->
		{false, lev_err}
	end.
%%get all awards those has been gotten, awards given by total online time
has_get_awards() ->
    RoleId = player:get_role_id(),
    get_awards_info_from_cache(RoleId).



get_awards_info_from_cache(RoleId) ->
    case redis:hget("online_award:has_gotten_awards", RoleId) of
	undefined ->
	    [];
	Awards ->
	    Awards
    end.

set_awards_info_in_cache(RoleId, NewList) ->
    cache_with_expire:set("online_award:has_gotten_awards", RoleId , NewList, day).



update_online_time() ->
    RoleId = player:get_role_id(),
    TotalSecs = get_total_online_time(RoleId),
    set_total_online_time_on_cache(RoleId, TotalSecs),
    ok.

get_total_online_time(RoleId) ->
    TimePass = get_online_time(),
    CurSec = get_total_online_time_from_cache(RoleId),
    CurSec + TimePass.


get_total_online_time_from_cache(RoleId) ->
    case redis:hget("online_award:total_online_time", RoleId) of
	undefined ->
	    0;
	Time ->
	    Time
    end.

set_total_online_time_on_cache(RoleId, OnlineTime)->
    cache_with_expire:set("online_award:total_online_time", RoleId , OnlineTime, day).


get_online_time() ->
    OldTime = get(login_time),
    Localtime = erlang:localtime(),
    {Date, _} = Localtime,
    ContinueTime =  calendar:datetime_to_gregorian_seconds(Localtime) - calendar:datetime_to_gregorian_seconds(OldTime),
    TodayPass = calendar:datetime_to_gregorian_seconds(Localtime) - calendar:datetime_to_gregorian_seconds({Date, {0,0,0}}),
    case ContinueTime > TodayPass of
	true ->
	    TodayPass;
	false ->
	    ContinueTime
    end.

    
