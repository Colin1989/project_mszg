%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created :  7 Jul 2014 by whl <>
%%%-------------------------------------------------------------------
-module(alchemy).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").

%% API
-export([start/0,
		 notify_alchemy_info/0,
		get_exp/0]).

-compile(export_all).
%%%===================================================================
%%% API
%%%===================================================================
start() ->
	packet:register(?msg_req_alchemy_info, {?MODULE, proc_req_alchemy_info}),
	packet:register(?msg_req_metallurgy, {?MODULE, proc_req_metallurgy}),
	packet:register(?msg_req_alchemy_reward, {?MODULE, proc_req_alchemy_reward}),
	ok.


%%--------------------------------------------------------------------
%% @doc
%% @spec 通知炼金术信息
%% @end
%%--------------------------------------------------------------------
notify_alchemy_info() ->
	RemainSecond = get_normal_metallurgy_remain_second(),
	Level = get_reward_level(),
	RewardedList = get_rewarded_list(),
	packet:send(#notify_alchemy_info{remain_normal_second = RemainSecond,
						advanced_count = get_advanced_metallurgy_times(),
					 level = Level, rewarded_list = RewardedList}).

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求炼金信息
%% @end
%%--------------------------------------------------------------------
proc_req_alchemy_info(_Packet) ->
	notify_alchemy_info().

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求炼金
%% @end
%%--------------------------------------------------------------------
proc_req_metallurgy(#req_metallurgy{type = Type}) ->
    case Type of
	1 -> %% 普通炼金
	    %NormalTimes = get_normal_metallurgy_times(),
	   % case NormalTimes >= config:get(nomrmal_metallurgy_free_times) + vip:get_privilege_count(6) of
	    case false of
		true ->
		    packet:send(#notify_metallurgy_reuslt{result = ?common_failed});
		false ->
		    RemainSecond = get_normal_metallurgy_remain_second(),
		    case RemainSecond > 0 of
			true ->
			    packet:send(#notify_metallurgy_reuslt{result = ?common_failed});
			false ->
			    Gold = get_tplt_normal_reward_gold(get_reward_level()),
			    player_role:add_gold(?st_alchemy, Gold),
			    Exp = config:get(nomrmal_metallurgy_exp),
			    add_exp(Exp),
			    %update_normal_metallurgy_times(NormalTimes + 1),
			    set_normal_metallurgy_time(),
			    notify_alchemy_info(),
			    activeness_task:update_activeness_task_status(alchemy),
			    packet:send(#notify_metallurgy_reuslt{result = ?common_success})
		    end
	    end;
	2 -> %% 高级炼金
	    AdvancedTimes = get_advanced_metallurgy_times(),
	    %case AdvancedTimes >= config:get(advanced_metallurgy_limit_times) + vip:get_privilege_count(7) of
	    case false of
		true ->
		    packet:send(#notify_metallurgy_reuslt{result = ?common_failed});
		false ->
		    Emoney = player_role:get_emoney(),
		    NeedEmoney = get_need_emoney(AdvancedTimes + 1),
		    case Emoney >= NeedEmoney of
			true ->
			    Gold = get_tplt_advanced_reward_gold(get_reward_level()),
			    player_role:add_gold(?st_alchemy, Gold),
			    Exp = config:get(advanced_metallurgy_exp),
			    add_exp(Exp),
			    player_role:reduce_emoney(?st_alchemy, NeedEmoney),
			    increase_advanced_metallurgy_times(),
			    notify_alchemy_info(),
			    activeness_task:update_activeness_task_status(alchemy),
			    packet:send(#notify_metallurgy_reuslt{result = ?common_success});
			false ->
			    packet:send(#notify_metallurgy_reuslt{result = ?common_failed})
		    end
	    end
    end.

get_need_emoney(Times) ->
	Fun = (tplt:get_data(expression_tplt, 31))#expression_tplt.expression,
	Fun([{'Times', Times}]).

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求获取炼金奖励
%% @end
%%--------------------------------------------------------------------
proc_req_alchemy_reward(#req_alchemy_reward{type = Type}) ->
	case check_is_rewarded(Type) of
		true ->
			packet:send(#notify_alchemy_reward_reuslt{result = ?common_failed});
		false ->
			NeedExp = config:get(list_to_atom(lists:concat([alchemy_reward_need_exp_, Type]))),
			case get_exp() >= NeedExp of
				true ->
					Level = player_role:get_level(),
					TpltInfo = get_tplt(Level),
					RewardID = lists:nth(Type, TpltInfo#alchemy_tplt.reward_ids),
					RewardAmount = lists:nth(Type, TpltInfo#alchemy_tplt.reward_amounts),
					reward:give([RewardID], [RewardAmount], ?st_alchemy),
					update_rewarded_list(Type),
					notify_alchemy_info(),
					packet:send(#notify_alchemy_reward_reuslt{result = ?common_success});
				false ->
					packet:send(#notify_alchemy_reward_reuslt{result = ?common_failed})
			end
	end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 获取炼金术信息相关
%% @end
%%--------------------------------------------------------------------
get_reward_level() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('alchemy:reward_level', RoleID) of
		[] ->
			Level = player_role:get_level(),
			cache_with_expire:set('alchemy:reward_level', player:get_role_id(), Level, day),
			Level;
		[{_Key, Value}] ->
			Value
	end.

get_normal_metallurgy_times() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('alchemy:normal_metallurgy_times', RoleID) of
		[] ->
			0;
		[{_Key, Value}] ->
			Value
	end.
update_normal_metallurgy_times(Count) ->
	cache_with_expire:set('alchemy:normal_metallurgy_times', player:get_role_id(), Count, day).

get_normal_metallurgy_remain_second() ->
	RoleID = player:get_role_id(),
	case cache:get('alchemy:normal_update_time', RoleID) of
		[] ->
			0;
		[{_Key, UpdateTime}] ->
			IntervalTime = config:get(nomrmal_metallurgy_CD) -
						   (datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(UpdateTime)),
			RemainSecond = case IntervalTime - 5 > 0 of
							   true ->
								   IntervalTime;
							   false ->
								   0
						   end,
			io_helper:format("RemainSecond:~p~n", [RemainSecond]),
			RemainSecond
	end.

set_normal_metallurgy_time() ->
	cache:set('alchemy:normal_update_time', player:get_role_id(), erlang:localtime()).

get_advanced_metallurgy_times() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('alchemy:advanced_metallurgy_times', RoleID) of
		[] ->
			0;
		[{_Key, Value}] ->
			Value
	end.

increase_advanced_metallurgy_times() ->
	cache_with_expire:increase('alchemy:advanced_metallurgy_times', player:get_role_id(), day).

get_rewarded_list() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('alchemy:rewarded_list', RoleID) of
		[] ->
			[];
		[{_Key, Value}] ->
			Value
	end.

update_rewarded_list(Type) ->
	cache_with_expire:set('alchemy:rewarded_list', player:get_role_id(), [Type | get_rewarded_list()], day).

check_is_rewarded(Type) ->
	lists:any(fun(E) -> Type =:= E end, get_rewarded_list()).
%%--------------------------------------------------------------------
%% @doc
%% @spec 获取炼金术经验相关
%% @end
%%--------------------------------------------------------------------
get_exp() ->
	RoleID = player:get_role_id(),
	case cache_with_expire:get('alchemy:exp', RoleID) of
		[] ->
			0;
		[{_Key, Value}] ->
			Value
	end.

add_exp(Exp) ->
	CurExp = get_exp(),
	set_exp(Exp + CurExp).

set_exp(Exp) ->
	cache_with_expire:set('alchemy:exp', player:get_role_id(), Exp, day),
	packet:send(#notify_role_info_change{type = "alchemy_exp", new_value = Exp}).
%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------

get_tplt(ID) ->
	tplt:get_data(alchemy_tplt, ID).

get_tplt_normal_reward_gold(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#alchemy_tplt.normal_reward_gold.

get_tplt_advanced_reward_gold(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#alchemy_tplt.advanced_reward_gold.