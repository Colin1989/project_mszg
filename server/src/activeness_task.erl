%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created :  3 May 2014 by whl <>
%%%-------------------------------------------------------------------
-module(activeness_task).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("event_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").
-include("business_log_def.hrl").

-record(activeness_status, {task_status = [], activeness_point = 0, reward_status=[0,0,0,0]}).

%% API
-export([start/0,
         notify_today_activeness_task/0,
         update_activeness_task_status/1]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_activeness_reward, {?MODULE, proc_req_activeness_reward}), %% 请求获取奖励
    packet:register(?msg_req_today_activeness_task, {?MODULE, proc_req_today_activeness_task}),
    %% 监听通关事件
    event_router:register(event_game_copy, {?MODULE, update_activeness_task_status}),
    event_router:register(event_divine, {?MODULE, update_activeness_task_status}),
    event_router:register(event_sculpture_upgrade, {?MODULE, update_activeness_task_status}),
    ok.


proc_req_today_activeness_task(_)->
    notify_today_activeness_task().
%%--------------------------------------------------------------------
%% @doc
%% @spec 通知今天活跃度任务
%% @end
%%--------------------------------------------------------------------
proc_req_activeness_reward(#req_activeness_reward{reward = RewardID}) when RewardID >= 1, RewardID < 5 ->
    case is_reward_has_gotten(RewardID) of
	false ->
	    NeedActiveness = get_reward_tplt_need_activeness(RewardID),
	    case get_activeness_point() >= NeedActiveness of
		true ->
		    send_reward(RewardID),
		    %%RoleID = player:get_role_id(),
		    %%CacheName = list_to_atom(lists:concat([is_get_activeness_reward_item, RewardID])),
		    %%cache_with_expire:set(CacheName, RoleID, 1, day),
		    %%io:format("1~n"),
		    update_reward_activeness(RewardID),
		    %%io:format("2~n"),
		    notify_today_activeness_task(),
		    packet:send(#notify_activeness_reward_result{reward = RewardID, result = ?common_success});
		false ->
		    packet:send(#notify_activeness_reward_result{result = ?common_failed}),
		    sys_msg:send_to_self(?sg_activeness_reward_point_not_enough, [])
	    end;
	true ->
	    packet:send(#notify_activeness_reward_result{result = ?common_failed}),
	    sys_msg:send_to_self(?sg_activeness_reward_has_gotten, []),
	    has_gotten
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec 通知今天活跃度任务
%% @end
%%--------------------------------------------------------------------
notify_today_activeness_task() ->
    #activeness_status{task_status = TaskStatus, reward_status = RewardStatus, activeness_point = Point} = get_activeness_status(),
    packet:send(#notify_today_activeness_task{task_list = TaskStatus,
					      is_reward_activeness_item_info = RewardStatus,
					      activeness = Point}).



%%%===================================================================
%%% Internal functions
%%%===================================================================

%%更新杀怪和通关(普通)副本
update_activeness_task_status(#event_game_copy{copy_id = CopyId, score = Score, monsterids = _MonsterId, count = Count}) ->
    CurStatus = get_activeness_status(),
    #activeness_status{activeness_point = _Point, task_status = TaskStatus} = CurStatus,
    CopyInfo = game_copy:get_copy_info(CopyId),
    {CopyTask, CopyIndex} = case CopyInfo#copy_tplt.type of
                                1 -> %% 普通
                                    {get_task_item_by_id(TaskStatus, 1), 1};
                                2 -> %% 精英
                                    {get_task_item_by_id(TaskStatus, 2), 2};
                                3 -> %% boss
                                    {get_task_item_by_id(TaskStatus, 3), 3}
                            end,
    {NewCopyTask, AddPoint} = case (CopyTask#activeness_task_item.count < get_task_tplt_maxtimes(CopyIndex)) and (Score > 0) of
                                   true ->
                                       MaxTimes = get_task_tplt_maxtimes(CopyIndex),
                                       case CopyTask#activeness_task_item.count + Count < MaxTimes of
                                           true ->
                                               log:create(business_log, [player:get_role_id(), CopyIndex, ?bs_activeness_task, ?TASK, erlang:localtime(), erlang:localtime(), Count]),
                                               {CopyTask#activeness_task_item{count = CopyTask#activeness_task_item.count + Count}, get_task_tplt_award_pertime(CopyIndex) * Count};
                                           false ->
                                               AddCount = MaxTimes - CopyTask#activeness_task_item.count,
                                               log:create(business_log, [player:get_role_id(), CopyIndex, ?bs_activeness_task, ?TASK, erlang:localtime(), erlang:localtime(), AddCount]),
                                               {CopyTask#activeness_task_item{count = MaxTimes}, get_task_tplt_award_pertime(CopyIndex) * AddCount}
                                       end;
                                   false ->
                                       {CopyTask, 0}
                               end,
    case AddPoint =:= 0 of
        true ->
            ok;
        false ->
            NewTaskStatus = lists:keyreplace(CopyIndex, #activeness_task_item.id, TaskStatus, NewCopyTask),
            update_task_status(NewTaskStatus),
            increase_activeness_point(AddPoint),
            notify_today_activeness_task()
    end;

%%召唤
update_activeness_task_status(#event_divine{times = Times}) ->
    CurStatus = get_activeness_status(),
    #activeness_status{task_status = TaskStatus} = CurStatus,
    Index = 6,
    DivineTask = get_task_item_by_id(TaskStatus, Index),
    {NewDivineTask, AddPoint} = case DivineTask#activeness_task_item.count < get_task_tplt_maxtimes(Index)of
				    true ->
					Len = case get_task_tplt_maxtimes(Index) - DivineTask#activeness_task_item.count of
						  Left when Left > Times ->
						      Times;
						  _Left ->
						      _Left
					      end,
					log:create(business_log, [player:get_role_id(), Index, ?bs_activeness_task, ?TASK, erlang:localtime(), erlang:localtime(), Len]),
					{DivineTask#activeness_task_item{count = DivineTask#activeness_task_item.count + Len},
					 get_task_tplt_award_pertime(Index) * Len};
				    false ->
					{DivineTask, 0}
				end,
    case AddPoint =:= 0 of
	true ->
	    ok;
	false ->
	    NewTaskStatus = lists:keyreplace(Index, #activeness_task_item.id, TaskStatus, NewDivineTask),
	    update_task_status(NewTaskStatus),
	    increase_activeness_point(AddPoint),
	    notify_today_activeness_task()
    end;

%%技能升级
update_activeness_task_status(#event_sculpture_upgrade{amount = Times}) ->
    CurStatus = get_activeness_status(),
    #activeness_status{task_status = TaskStatus} = CurStatus,
    Index = 12,
    DivineTask = get_task_item_by_id(TaskStatus, Index),
    {NewDivineTask, AddPoint} = case DivineTask#activeness_task_item.count < get_task_tplt_maxtimes(Index)of
				    true ->
					Len = case get_task_tplt_maxtimes(Index) - DivineTask#activeness_task_item.count of
						  Left when Left > Times ->
						      Times;
						  _Left ->
						      _Left
					      end,
					log:create(business_log, [player:get_role_id(), Index, ?bs_activeness_task, ?TASK, erlang:localtime(), erlang:localtime(), Len]),
					{DivineTask#activeness_task_item{count = DivineTask#activeness_task_item.count + Len},
					 get_task_tplt_award_pertime(Index) * Len};
				    false ->
					{DivineTask, 0}
				end,
    case AddPoint =:= 0 of
	true ->
	    ok;
	false ->
	    NewTaskStatus = lists:keyreplace(Index, #activeness_task_item.id, TaskStatus, NewDivineTask),
	    update_task_status(NewTaskStatus),
	    increase_activeness_point(AddPoint),
	    notify_today_activeness_task()
    end;

update_activeness_task_status(TaskTag) ->
    CurStatus = get_activeness_status(),
    #activeness_status{task_status = TaskStatus} = CurStatus,
    TaskIndex = taskTag2Index(TaskTag),
    Task = get_task_item_by_id(TaskStatus, TaskIndex),
    {NewTask, AddPoint} = case Task#activeness_task_item.count < get_task_tplt_maxtimes(TaskIndex) of
                              true ->
                                  log:create(business_log, [player:get_role_id(), TaskIndex, ?bs_activeness_task, ?TASK, erlang:localtime(), erlang:localtime(), 0]),
                                  {Task#activeness_task_item{count = Task#activeness_task_item.count + 1},
                                   get_task_tplt_award_pertime(TaskIndex)};
                              false ->
                                  {Task, 0}
                          end,
    case AddPoint =:= 0 of
        true ->
            ok;
        false ->
            NewTaskStatus = lists:keyreplace(TaskIndex, #activeness_task_item.id, TaskStatus, NewTask),
            update_task_status(NewTaskStatus),
            increase_activeness_point(AddPoint),
            notify_today_activeness_task()
    end.

taskTag2Index(TaskTag) ->
    TaskTagList = [{activity_copy,4},{push_tower,5},{challenge,7},
                   {train_match,8},{ladder_match,9},{alchemy,10},{benison,11},{equipment_strengthen,12}],
    {_Tag, Index} = lists:keyfind(TaskTag, 1, TaskTagList),
    Index.

get_task_item_by_id(Items, Id)->
    lists:keyfind(Id, #activeness_task_item.id, Items).




%%--------------------------------------------------------------------
%% @doc
%% @spec 获取是否已经领奖相关信息
%% @end
%%--------------------------------------------------------------------
get_reward_status() ->
    case cache_with_expire:get('activeness:reward_status', player:get_role_id()) of
	[] ->
	    [0, 0, 0, 0];
	[{_, Value}] ->
	    Value
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 判断该礼包是否已经领取过
%% @end
%%--------------------------------------------------------------------
is_reward_has_gotten(RewardType) ->
    #activeness_status{reward_status = RewardStatus} = get_activeness_status(),
    case lists:nth(RewardType, RewardStatus) of
	1 ->
	    true;
	0 ->
	    false
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 设置此类型活跃度已经领取过
%% @end
%%--------------------------------------------------------------------
update_reward_activeness(TaskType) ->
    OldStatus = get_activeness_status(),
    OldRewardStatus = OldStatus#activeness_status.reward_status,
    NewRewardStatus = lists:sublist(OldRewardStatus, 1, TaskType - 1) ++ [1|lists:sublist(OldRewardStatus, TaskType + 1, 4 - TaskType)],
    RoleID = player:get_role_id(),
    reset_activeness_status(OldStatus#activeness_status{reward_status = NewRewardStatus}),
    %%CacheName = list_to_atom(lists:concat([activeness_rewarded_, TaskType])),
    cache_with_expire:set('activeness:reward_status', RoleID, NewRewardStatus, day).
    %%cache_with_expire:set(CacheName, RoleID, 1, day).


%%--------------------------------------------------------------------
%% @doc
%% @spec 获取当天活跃度任务列表
%% @end
%%--------------------------------------------------------------------
get_task_list() ->
    %%1 monster,2: copy, 3: push_tower, 4:benison, 5:divine, 6:clean_up, 7:train_match 8:friend_lottery 9:ladder_match 10:alchemy
    case cache_with_expire:get('activeness:task_status', player:get_role_id()) of
	[] ->
	    [ #activeness_task_item{id = Id, count = 0} || Id <- [1,2,3,4,5,6,7,8,9,10,11,12]];
	[{_, Status}] ->
	    Status

    end.

update_task_status(NewStatus) ->
    OldStatus = get_activeness_status(),
    reset_activeness_status(OldStatus#activeness_status{task_status = NewStatus}),
    cache_with_expire:set('activeness:task_status', player:get_role_id(), NewStatus, day).
%%--------------------------------------------------------------------
%% @doc
%% @spec 增加活跃度
%% @end
%%--------------------------------------------------------------------
get_activeness_point() ->
    RoleID = player:get_role_id(),
    case cache_with_expire:get('activeness:gain_point', RoleID) of
	[] ->
	    0;
	[{_Key, Value}] ->
	    Value
    end.



increase_activeness_point(Amount) ->
    RoleID = player:get_role_id(),
    OldStatus = get_activeness_status(),
    reset_activeness_status(OldStatus#activeness_status{activeness_point = OldStatus#activeness_status.activeness_point + Amount}),
    cache_with_expire:increase('activeness:gain_point', RoleID, Amount, day).

get_activeness_status() ->
    case get(activeness_status) of
	undefined ->
	    reget_activeness_status();
	CurStatus ->
	    LastTime = get(last_req_time),
	    case datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(LastTime) < 86400 of
		true ->
		    CurStatus;
		false ->
		    reget_activeness_status()
	    end
	    
    end.


reget_activeness_status() ->
    Status = #activeness_status{task_status = get_task_list(), 
				activeness_point = get_activeness_point(),
				reward_status = get_reward_status()},
    put(activeness_status, Status),
    put(last_req_time, {erlang:date(),{0,0,0}}),
    Status.

reset_activeness_status(NewStatus) ->
    put(activeness_status, NewStatus).



%%--------------------------------------------------------------------
%% @doc
%% @spec 发送奖励
%% @end
%%--------------------------------------------------------------------
send_reward(ID) ->
  RewardIDs = get_reward_tplt_ids(ID),
  RewardAmounts = get_reward_tplt_amounts(ID),
  SourceType = ?st_activeness_task,
  reward:give(RewardIDs, RewardAmounts, SourceType).

%%--------------------------------------------------------------------
%% @doc
%% @spec 奖励模版相关
%% @end
%%--------------------------------------------------------------------
get_reward_tplt(ID) ->
  tplt:get_data(activeness_reward_tplt, ID).

get_reward_tplt_ids(ID) ->
  RewardInfo = get_reward_tplt(ID),
  RewardInfo#activeness_reward_tplt.ids.

get_reward_tplt_amounts(ID) ->
  RewardInfo = get_reward_tplt(ID),
  RewardInfo#activeness_reward_tplt.amounts.

get_reward_tplt_need_activeness(ID) ->
  RewardInfo = get_reward_tplt(ID),
  RewardInfo#activeness_reward_tplt.need_activess.




%%--------------------------------------------------------------------
%% @doc
%% @spec 任务模版相关
%% @end
%%--------------------------------------------------------------------
get_task_tplt(ID) ->
  tplt:get_data(activeness_task_tplt, ID).

get_task_tplt_maxtimes(ID) ->
  RewardInfo = get_task_tplt(ID),
  RewardInfo#activeness_task_tplt.max_times.

get_task_tplt_award_pertime(ID) ->
  RewardInfo = get_task_tplt(ID),
  RewardInfo#activeness_task_tplt.award_pertime.

