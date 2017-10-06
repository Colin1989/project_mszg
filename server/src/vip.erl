%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created : 15 Jul 2014 by whl <>
%%%-------------------------------------------------------------------
-module(vip).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("event_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").

%% API
-export([get_level/0,
     get_privilege_count/1,
     notify_vip_rewarded_info/0,
     get_new_level/2]).

-compile(export_all).
%%%===================================================================
%%% API
%%%===================================================================
start() ->
	packet:register(?msg_req_vip_daily_reward, {?MODULE, proc_req_vip_daily_reward}),
	packet:register(?msg_req_vip_grade_reward, {?MODULE, proc_req_vip_grade_reward}),
	ok.

notify_vip_rewarded_info() ->
	DailyRewardInfo = get_daily_rewarded(),
	GradeRewardList = get_grade_rewarded_list(),
	packet:send(#notify_vip_reward_info{level_rewarded_list = GradeRewardList, daily_rewarded = DailyRewardInfo}),
	ok.

get_level() ->
    UserID = player:get_player_id(),
    get_level(UserID).
get_level(UserID) ->
	User = player_role:get_user(UserID),
	case User:vip_level() of
		undefined ->
			0;
		_ ->
			User:vip_level()
	end.


get_new_level(UserID, NewMoney) ->
    CurLevel = get_level(UserID),
    caculate_level(CurLevel, NewMoney).
%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求vip每日奖励
%% @end
%%--------------------------------------------------------------------
proc_req_vip_daily_reward(#req_vip_daily_reward{}) ->
	case get_daily_rewarded() of
		0 ->
                    cache_with_expire:set("vip:daily_rewarded", player:get_role_id(), 1, day),
                    send_daily_reward(),
			packet:send(#notify_vip_daily_reward_result{result = ?common_success});
		1 ->
			packet:send(#notify_vip_daily_reward_result{result = ?common_failed})
	end.


get_daily_rewarded() ->
	case cache_with_expire:get("vip:daily_rewarded", player:get_role_id()) of
		[] ->
			0;
		[{_, _Value}] ->
			1
	end.

send_daily_reward() ->
	Level = get_level(),
	case Level > 0 of
		true ->
			IDs = get_tplt_daily_gift_bag_ids(Level),
			Amounts = get_tplt_daily_gift_bag_amounts(Level),
			reward:give(IDs, Amounts, ?st_vip)
	end.
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求vip等级奖励
%% @end
%%--------------------------------------------------------------------
proc_req_vip_grade_reward(#req_vip_grade_reward{level = Level}) ->
    CurLevel =get_level(),
    RewardList = get_grade_rewarded_list(),
    case CurLevel >= Level of
	true ->
	    case lists:any(fun(E) -> Level =:= E end, RewardList) of
		false ->
                    redis:hset("vip:grade_rewarded", player:get_role_id(), [Level | RewardList]),
                    send_grade_reward(Level),
		    packet:send(#notify_vip_grade_reward_result{result = ?common_success});
		true ->
		    packet:send(#notify_vip_daily_reward_result{result = ?common_failed})
	    end;
	false ->
	    packet:send(#notify_vip_daily_reward_result{result = ?common_failed})
    end.


get_grade_rewarded_list() ->
	case redis:hget("vip:grade_rewarded", player:get_role_id()) of
		undefined ->
			[];
		Other ->
			Other
	end.

send_grade_reward(Level) ->
	case Level > 0 of
		true ->
			IDs = get_tplt_grade_gift_bag_ids(Level),
			Amounts = get_tplt_grade_gift_bag_amounts(Level),
			reward:give(IDs, Amounts, ?st_vip)
	end.

caculate_level(Level, NewMoney) ->
	case Level >= 15 of
		true ->
			15;
		false ->
			NextNeedMoney = get_tplt_need_money(Level + 1),
			case NewMoney < NextNeedMoney of
				true ->
					Level;
				false ->
					caculate_level(Level + 1, NewMoney)
			end
	end.

get_privilege_count(N) ->
    Level = get_level(),
    case Level > 0 of
	true ->
	    PrivilegeList = get_privilege_list(Level),
	    Count = case lists:keyfind(N, 1, PrivilegeList) of
			{_ID, Amount} ->
			    Amount;
			false ->
			    0
		    end,
	    Count;
	false ->
	    0
    end.

get_privilege_list(Level) ->
    IDs = get_tplt_privilege_ids(Level),
    Amounts = get_tplt_privilege_amounts(Level),
    lists:zipwith(fun(X, Y) -> {X, Y} end, IDs, Amounts).

%% get_privilege_list(Level) ->
%% 	case get(vip_privilege_list) of
%% 		undefined ->
%% 			List = reset_privilege_list(Level),
%% 			List;
%% 		PrivilegeList ->
%% 			PrivilegeList
%% 	end.


%% reset_privilege_list(Level) ->
%% 	IDs = get_tplt_privilege_ids(Level),
%% 	Amounts = get_tplt_privilege_amounts(Level),
%% 	InitList = [{1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}, {7, 0},{8,0},{9,0},{10,0}],
%% 	List = gen_privilege_list(InitList, IDs, Amounts),
%% 	put(vip_privilege_list, List),
%% 	List.
%%
%%
%% gen_privilege_list(List, [], _Amounts) ->
%% 	List;
%% gen_privilege_list(List, [ID | IDs], [Amount | Amounts]) ->
%% 	NewList = lists:keyreplace(ID, 1, List, {ID, Amount}),
%% 	gen_privilege_list(NewList, IDs, Amounts).

%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------

get_tplt(ID) ->
	tplt:get_data(vip_tplt, ID).

get_tplt_need_money(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.need_money.

get_tplt_privilege_ids(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.privilege_ids.

get_tplt_privilege_amounts(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.privilege_amounts.

%%--------------------------------------------------------------------
%% @doc
%% @spec 等级礼包
%% @end
%%--------------------------------------------------------------------
get_tplt_grade_gift_bag_ids(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.grade_gift_bag_ids.
get_tplt_grade_gift_bag_amounts(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.grade_gift_bag_amounts.

%%--------------------------------------------------------------------
%% @doc
%% @spec 每日礼包
%% @end
%%--------------------------------------------------------------------
get_tplt_daily_gift_bag_ids(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.daily_gift_bag_ids.
get_tplt_daily_gift_bag_amounts(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#vip_tplt.daily_gift_bag_amounts.
