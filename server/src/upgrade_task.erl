%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc 冲级任务
%%%
%%% @end
%%% Created : 18 Jul 2014 by whl <>
%%%-------------------------------------------------------------------
-module(upgrade_task).

-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").

%% API
-export([start/0,
		 notify_upgrade_task_rewarded_list/0]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
start()->
	packet:register(?msg_req_upgrade_task_reward, {?MODULE, proc_req_upgrade_task_reward}),
	ok.

notify_upgrade_task_rewarded_list() ->
	packet:send(#notify_upgrade_task_rewarded_list{reward_ids = get_rewarded_list()}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 奖励请求
%% @end
%%--------------------------------------------------------------------

proc_req_upgrade_task_reward(#req_upgrade_task_reward{task_id = TaskID}) ->
	RoleLevel = player_role:get_level(),
	case get_tplt_level(TaskID) > RoleLevel of
		true ->
			packet:send(#notify_upgrade_task_reward_result{result = ?common_failed, task_id = TaskID});
		false ->
			case is_rewarded(TaskID) of
				true ->
					packet:send(#notify_upgrade_task_reward_result{result = ?common_failed, task_id = TaskID});
				false ->
					give_reward(TaskID),
					update_rewarded_list(TaskID),
					packet:send(#notify_upgrade_task_reward_result{result = ?common_success, task_id = TaskID})
			end
	end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec 判断奖励是否已领
%% @end
%%--------------------------------------------------------------------
is_rewarded(TaskID) ->
	case get_rewarded_list() of
		[] ->
			false;
		RewaredList ->
			lists:any(fun(E) -> TaskID =:= E end, RewaredList)
	end.

update_rewarded_list(TaskID) ->
	RewaredList = get_rewarded_list(),
	cache:set('upgrade_task:rewared_list', player:get_role_id(), [TaskID | RewaredList]).

get_rewarded_list() ->
	case cache:get('upgrade_task:rewared_list', player:get_role_id()) of
		[] ->
			[];
		[{_RoleID, RewaredList}] ->
			RewaredList
	end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 发送奖励
%% @end
%%--------------------------------------------------------------------
give_reward(TaskID) ->
	TpltInfo = get_tplt(TaskID),
	SourceType = ?st_task_reward,
	reward:give(TpltInfo#upgrade_task_tplt.reward_ids, TpltInfo#upgrade_task_tplt.reward_amounts, SourceType).

%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------
get_tplt(ID) ->
	tplt:get_data(upgrade_task_tplt, ID).

get_tplt_level(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#upgrade_task_tplt.level.