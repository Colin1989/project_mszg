%%% @author hongjx <>
%%% @copyright (C) 2014, hongjx
%%% @doc
%%%  任务相关操作
%%%    (没后继的任务，完成后会被留在任务列表中，并标为已完成,等策划填数据后再自动往下接)
%%% @end
%%% Created :  5 Mar 2014 by hongjx <>

-module(task).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("event_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").
-include("tplt_def.hrl").
-include("business_log_def.hrl").
-record(task_statics, {task_amount = 0, cur_list = [], remain_list = []}).

%%-compile(export_all). %% 测试用

-export([start/0,
	 update_task_state/1
	 %%update_task_state/2
	]).

-export([proc_req_finish_task/1, 
	 proc_req_task_infos/1,
	 init_task_info/0
	]).

start() ->
    %% 请求任务列表
    %%packet:register(?msg_req_task_infos, {?MODULE, proc_req_task_infos}),
    %% 请求完成任务
    packet:register(?msg_req_finish_task,{?MODULE, proc_req_finish_task}),
    %% 监听通关事件
    event_router:register(event_game_copy, {?MODULE, update_task_state}),

    event_router:register(event_sculpture_upgrade, {?MODULE, update_task_state}),
    %%init_task_info(),
  event_router:register(event_task_finish_times_update, {?MODULE, update_task_state}),
    ok.

%%-record(event_game_copy, {copy_id = 0, score = 0,  monsterids=[]}).

%%%===================================================================
%% 更新任务信息
%%%===================================================================
update_task_state(#event_task_finish_times_update{amount = Amount, sub_type = SubType}) ->
    TaskStatics = db_get_task_list(player:get_role_id()),
    #task_statics{remain_list = RemainList} = TaskStatics,

    F = fun(#task_info{task_id = TaskID, has_finished = HasFinished} = X) ->
		#task_tplt{sub_type = Kind,
			   number = NeedCount} = tplt:get_data(task_tplt, TaskID),

		case HasFinished of
		    1 -> %% 已完成，就不折腾了
			X;
		    _ ->
			case Kind of
			    SubType -> %% SubType 5: 强化 6:分解任务 7:占卜任务

				#task_info{args = [OldN]} = X,

				case OldN + Amount < NeedCount of
				    true ->
					X#task_info{args = [OldN + Amount]};
				    _ -> %% 次数满了
					case OldN =:= NeedCount of
					    false ->
						log:create(business_log, [player:get_role_id(), 
									  TaskID, 
									  0, 
									  ?TASK,
									  erlang:localtime(), 
									  erlang:localtime(), 
									  0]);
					    true ->
						has_log
					end,
					X#task_info{args = [NeedCount]}
				end;
			    _ -> % 其他类型，不用管
				X
			end
		end
	end,

    %% 只取未完成的
    NewList = [F(X) || X <- RemainList],
    db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList});

update_task_state(#event_sculpture_upgrade{amount = Amount})->
    TaskStatics = db_get_task_list(player:get_role_id()),
    #task_statics{remain_list = RemainList} = TaskStatics,
    %%io:format("Input ~p~n", [Input]),

    F = fun(#task_info{task_id = TaskID, has_finished = HasFinished} = X) ->
		#task_tplt{sub_type = Kind,
			   number = NeedCount} = tplt:get_data(task_tplt, TaskID),
		%%io:format("NeedMonsterID ~p~n", [{NeedMonsterID, Location, NeedCount, Kind, X}]),

		case HasFinished of
		    1 -> %% 已完成，就不折腾了
			X;
		    _ ->
			case Kind of
			    4 -> % 杀怪类型任务
				%% 完成次数+1
				#task_info{args = [OldN]} = X,

				case OldN + Amount < NeedCount of
				    true ->
					X#task_info{args = [OldN + Amount]};
				    _ -> %% 次数满了
					case OldN =:= NeedCount of
					    false ->
						log:create(business_log, [player:get_role_id(), 
									  TaskID, 
									  0, 
									  ?TASK,
									  erlang:localtime(), 
									  erlang:localtime(), 
									  0]);
					    true ->
						has_log
					end,
					X#task_info{args = [NeedCount]}
				end;
			    _ -> % 其他类型，不用管
				X
			end
		end
	end,

    %% 只取未完成的
    NewList = [F(X) || X <- RemainList],
    db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList});
    %%io:format("new list ~p~n", [NewList]),
    %% case OldList =/= NewList of
    %% 	true ->
    %% 	    %% 存到数据库
    %% 	    db_set_task_list(player:get_role_id(), NewList),
    %% 	    %% 有更新要通知客户端
    %% 	    packet:send(#notify_task_infos{type=?init, infos=NewList});
    %% 	_ ->
    %% 	    ok
    %% end;
update_task_state(Tuple) ->
    %%io:format("update_task_state ~p~n", [Tuple]),
    #event_game_copy{copy_id=CopyID, score=Score, monsterids=MonsterList} = Tuple,

    RoleId = player:get_role_id(),
    
    PassType = case Score of
		   0 -> 0; % 没通关
		   3 -> 2; % 3星通关
		   _ -> 1  % 普通通关
	       end,
		   
    NewStatics = update_task_state(RoleId, {pass_copy, CopyID, PassType}, db_get_task_list(RoleId)),
    F = fun(MonsterID, Acc) ->
		case lists:keyfind(MonsterID, 1, Acc) of
		    false ->
			[{MonsterID, 1} | Acc];
		    {_, N} ->
			lists:keyreplace(MonsterID, 1, Acc, 
					 {MonsterID, N + 1})
		end
	end,

    L = lists:foldl(F, [], MonsterList),
    FinalStatics = lists:foldl(fun({MonsterID, KillN}, In) -> 
				       update_task_state(RoleId, {kill_monster, MonsterID, KillN, CopyID}, In)
			       end, NewStatics, L),
    db_set_task_list(player:get_role_id(), FinalStatics).	
    %% [update_task_state(RoleId, {kill_monster, MonsterID, KillN, CopyID}) 
    %%  || {MonsterID, KillN} <- L].
%% 杀怪: 传入怪物id和数量
update_task_state(_RoleId, {kill_monster, MonsterID, KillN, CopyID}, TaskStatics) ->
    %%OldList = db_get_task_list(RoleId),
    %%io:format("Input ~p~n", [Input]),
    %%TaskStatics = db_get_task_list(RoleId),
    #task_statics{remain_list = RemainList} = TaskStatics,
    F = fun(#task_info{task_id = TaskID, has_finished = HasFinished} = X) ->
		#task_tplt{sub_type = Kind, monster_id = NeedMonsterID,
			   location = Location,
			   number = NeedCount} = tplt:get_data(task_tplt, TaskID),
		%%io:format("NeedMonsterID ~p~n", [{NeedMonsterID, Location, NeedCount, Kind, X}]),

		case HasFinished of
		    1 -> %% 已完成，就不折腾了
			X;
		    _ ->
			case Kind of
			    1 -> % 杀怪类型任务
				case (MonsterID =:= NeedMonsterID) and (Location =:= CopyID) of
				    true -> %% 怪物场地,类型判断
					%% 完成次数+1
					#task_info{args = [OldN]} = X,

					case OldN + KillN < NeedCount of
					    true ->
						X#task_info{args = [OldN + KillN]};
					    _ -> %% 次数满了
						case OldN =:= NeedCount of
						    false ->
							log:create(business_log, [player:get_role_id(), 
										  TaskID, 
										  0, 
										  ?TASK,
										  erlang:localtime(), 
										  erlang:localtime(), 
										  0]);
						    true ->
							has_log
						end,
						X#task_info{args = [NeedCount]}
					end;
				    _ ->
					X
				end;
			    _ -> % 其他类型，不用管
				X
			end
		end
	end,
    NewList = [F(X) || X <- RemainList],
    TaskStatics#task_statics{remain_list = NewList};
    %%%db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList});	   
    %% 只取未完成的
    %% NewList = [F(X) || X <- OldList],
    %% %%io:format("new list ~p~n", [NewList]),
    %% case OldList =/= NewList of
    %% 	true ->
    %% 	    %% 存到数据库
    %% 	    db_set_task_list(RoleId, NewList),
    %% 	    %% 有更新要通知客户端
    %% 	    packet:send(#notify_task_infos{type=?init, infos=NewList});
    %% 	_ ->
    %% 	    ok
    %% end;
%% 副本通关: 传入副本id和(通关类型 1=常规通关 2=三星通关 3=击杀所有敌人通关)
update_task_state(_RoleId, {pass_copy, CopyID, PassType}, TaskStatics) ->
    %%OldList = db_get_task_list(RoleId),
    %%TaskStatics = db_get_task_list(RoleId),
    #task_statics{remain_list = RemainList} = TaskStatics,
    F = fun(#task_info{task_id = TaskID, has_finished = HasFinished} = X) ->
		#task_tplt{sub_type = Kind, location = Location,
			   clear_type = ClearType} = tplt:get_data(task_tplt, TaskID),
		case HasFinished of
		    1 -> %% 已完成，就不折腾了
			X;
		    _ ->
			case Kind of
			    2 -> % 通关类型任务
				case CopyID of
				    Location -> %% 副本地点一致
					case PassType >= ClearType of
					    true -> %% 超过或等于要求
						case X#task_info.args of
						    [0] ->
							io_helper:format("taskID:~p~n", [TaskID]),
							log:create(business_log, [player:get_role_id(), 
										  TaskID, 
										  0, 
										  ?TASK,
										  erlang:localtime(), 
										  erlang:localtime(), 
										  0]);
						    [1] ->
							has_log
						end,
						%% 完成次数设为1
						X#task_info{args = [1]};
					    _ -> %% 低于要求，不用处理
						X
					end;
				    _ ->
					X
				end;
			    _ -> % 其他类型，不用管
				X
			end
		end
  end,

    %% 只取未完成的
    %% NewList = [F(X) || X <- OldList],
    %% case OldList =/= NewList of
    %% 	true ->
    %% 	    %% 存到数据库
    %% 	    db_set_task_list(RoleId, NewList),
    %% 	    %% 有更新要通知客户端
    %% 	    packet:send(#notify_task_infos{type=?init, infos=NewList});
    %% 	_ ->
    %% 	    ok
    %% end.
    NewList = [F(X) || X <- RemainList],
    TaskStatics#task_statics{remain_list = NewList}.
    %%db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList}).


%%%===================================================================
%% 请求任务列表
%% [req_task_infos
%% ],
%%%===================================================================
proc_req_task_infos(#req_task_infos{})->
    RoleId = player:get_role_id(),
    %% 只取未完成的
    %% #task_statics{task_amount = Amount, cur_list = CurList, remain_list = RemainList} = db_get_task_list(RoleId),
    %% TaskList = [X || #task_info{has_finished=HasFinished}=X <- db_get_task_list(RoleId), 
    %% 	  HasFinished=:=0],
    %% packet:send(#notify_task_infos{type=?init, infos=TaskList}).
    notify_client_task_info(db_get_task_list(RoleId)).



%%%===================================================================
%% 请求完成任务
     %% [req_finish_task,%% 请求完成任务 
     %%  {int, task_id}  % 任务xml id
     %% ],
%%%===================================================================
proc_req_finish_task(#req_finish_task{task_id=TaskID})->
    RoleId = player:get_role_id(),
    %%[Role|_] = db:find(db_role,[{role_id,'equals',RoleId}]),
    Role = player_role:get_db_role(RoleId),
    MyLevel = Role:level(),
    Tplt = tplt:get_data(task_tplt, TaskID),
    
    TaskStatics = db_get_task_list(RoleId),
    #task_statics{cur_list = CurList, remain_list = RemainList} = TaskStatics,
    case get_task_info(TaskID, CurList, RemainList) of
	false -> %% 任务不存在
	    notify_finish_task_fail(?sg_task_not_exist,[]);
	#task_info{has_finished=HasFinished, args=Args} ->
	    case HasFinished of
		1 -> %% 任务已完成
		    notify_finish_task_fail(?sg_task_has_finished,[]);
		_ ->
		    #task_tplt{need_level=NeedLevel} = Tplt,
		    case MyLevel < NeedLevel of
			true -> %% 等级不够
			    notify_finish_task_fail(?sg_task_player_level_not_enough,[]);
			_ ->
			    case check_sub_need(Tplt, Args) of
				true -> %% 子类型检查通过
				    %% 保存任务
				    do_finish_task(TaskID, TaskStatics),

				    %% 给任务奖励
				    give_reward(Tplt, Role),
				    %% 通知任务完成
				    packet:send(#notify_finish_task{is_success=?common_success,task_id=TaskID});
				_ ->
				    ok
			    end
		    end    		    
	    end
    end.


notify_finish_task_fail(MsgID, Args) ->
    %% 通知任务还没完成
    packet:send(#notify_finish_task{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).


%%%===================================================================
%%% 内部实现函数
%%%===================================================================

get_task_info(TaskID, TaskList, RemainList) ->
    %%io:format("TaskList:~p,TaskId:~p", [TaskList, TaskID]),
    case length(TaskList -- [TaskID]) =:= length(TaskList) of
	true ->
	    false;
	 _->
	    lists:keyfind(TaskID, #task_info.task_id, RemainList)
    end.

do_finish_task(TaskID, TaskStatics) ->
    #task_statics{cur_list = CurList, remain_list = RemainList} = TaskStatics,
    OldInfo = get_task_info(TaskID, CurList, RemainList),
    #task_tplt{next_ids=NextIDs}=tplt:get_data(task_tplt, TaskID),
    NewTaskList =
	case get_next_task_ids(NextIDs) of 
	    [] -> %% 没新任务，保持原状, 设成已完成就好
		NewInfo = OldInfo#task_info{has_finished=1},
		TaskStatics#task_statics{remain_list = lists:keyreplace(TaskID, #task_info.task_id, RemainList, NewInfo)};
	    NewTaskIDs -> %% 有新任务，去除已完成任务, 添加任务通知客户端
		NewTasks = get_next_tasks(NewTaskIDs, RemainList),
		TaskStatics#task_statics{remain_list = (lists:keydelete(TaskID, #task_info.task_id, RemainList)) ++ NewTasks, 
					cur_list = (CurList -- [TaskID|NewTaskIDs]) ++ NewTaskIDs}
	end,

    RoleId = player:get_role_id(),
    %% 存到数据库
    db_set_task_list(RoleId, NewTaskList).
    %% 通知客户端
    %% packet:send(#notify_task_infos{type=?init, infos=NewTaskList}).
    %%notify_client_task_info(NewTaskList).



    

%% 子类型检查
%% 没问题返回true
check_sub_need(#task_tplt{sub_type = Kind,
                          clear_type = ClearType,
                          collect_id = ItemID,
                          number = Amount
},             Args) ->
  Arg1 = hd(Args),
  case Kind of
    1 -> % 击杀怪物
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_monster_amount_not_enough, []);
        _ ->
          true
      end;
    2 -> % 通关副本
      case Arg1 < Amount of
        true ->
          case ClearType of
            1 -> % 常规通关
              notify_finish_task_fail(?sg_task_not_pass, []);
            2 -> % 三星通关
              notify_finish_task_fail(?sg_task_not_full_star_pass, []);
            3 -> % 击杀所有敌人通关
              notify_finish_task_fail(?sg_task_not_kill_all_pass, [])
          end;
        _ ->
          true
      end;
    3 -> % 收集物品
      %% 把背包拿出来检查
      [{_ItemID, Count}] = player_pack:get_items_count([ItemID]),
      case Count < Amount of
        true ->
          notify_finish_task_fail(?sg_task_item_amount_not_enough, []);
        _ ->
          true
      end;
    4 -> % 充能次数
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_sculpture_upgrade_amount_not_enough, []);
        _ ->
          true
      end;
    5 -> %% 5 : 强化
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_advance_equipment_amount_not_enough, []);
        _ ->
          true
      end;
    6 -> %% 6:分解任务
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_equipment_resolve_amount_not_enough, []);
        _ ->
          true
      end;
    7 -> %% 7:占卜任务
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_sculpture_divine_amount_not_enough, []);
        _ ->
          true
      end
  end.


%% 给奖励
give_reward(#task_tplt{reward_ids=RewardIDs, reward_amounts =RewardAmounts}, _Role) ->
  reward:give(RewardIDs, RewardAmounts, ?st_task_reward).

%% 取后继任务
%% 参数:NextIDs 后继任务id
get_next_tasks(NextIDs, RemainList) ->
    case NextIDs of
	[] -> %% 还是没新任务
	    [];
	[0] -> %% 还是没新任务
	    [];
	_ -> %% 有新任务
	    NewIds = lists:filter(fun(TaskID) ->
					  not is_task_exist(RemainList, TaskID)   
				  end, NextIDs),
	     [#task_info{task_id=NewID, has_finished=0,args=init_task_args(NewID)} 
	      || NewID <- NewIds ]
    end.

get_next_task_ids(NextIDs) ->
    case NextIDs  of
	[0] ->
	    [];
	_ ->
	    NextIDs
    end.
    

%% 初始化任务参数
init_task_args(TaskID) ->
  #task_tplt{sub_type = SubType} = tplt:get_data(task_tplt, TaskID),
  case SubType of
    1 -> %% 击杀怪物数量
      [0];
    2 -> %% 通关副本是否按条件完成
      [0];
    3 -> %% 收集物品
      [];
    4 -> %% 充能次数
      [0];
    5 -> %% 强化次数
      [0];
    6 -> %% 分解次数
      [0];
    7 -> %% 占扑次数
      [0]
  end.

%%--------------------------------------------------------------------
%% @doc
%%  存取任务列表，列表的每个元素都是#task_info
%% [task_info,
%%  {int, task_id},    % 任务xml id, 根据这个id可以知道任务类型
%%  {int, has_finished},  % 是否已完成 0 未完成 1 完成
%%  {array, int, args}  
%%    args 参数列表用于表示各种复杂任务条件的完成情况            
%%    任务类型=1击杀怪物时,args表示: 击杀怪物数量
%%    任务类型=2通关副本时,args表示: 通关次数
%%    任务类型=3收集物品时,args目前没值: 因为收集物品背包可以找到 
%% ],
%% @end
%%--------------------------------------------------------------------
%% 取任务列表
db_get_task_list(RoleId) ->
    OrgNewStatics = get_task_list(RoleId),
    %%io:format("1~n"),
    NewStatics = search_new_tasks(OrgNewStatics),
    %%io:format("NewStatics:~p~n", [NewStatics]),
    set_task_list(RoleId, NewStatics),
    NewStatics.





%%获取新加入模板表的任务ID
get_newer_task(Start)->
    AllTaskId = get_all_task_id(),
    %%io:format("~p~n", [AllTaskId]),
    Len = length(AllTaskId) - Start,
    {lists:sublist(AllTaskId, Start + 1, Len), length(AllTaskId)}.


get_all_task_id()->
    case redis:get(all_task_id) of
	undefined ->
	    [];
	Other ->
	    Other
    end.

%% 存任务列表
db_set_task_list(RoleId, TaskStatics) ->
    set_task_list(RoleId, TaskStatics).


%% db_update_task_list(Task) ->
    
%%     case CurList of
%% 	FinishList = lists:filter(fun(X) ->
%% 					  lists:keyfind(X, #task_info.task_id, RemainList)
%% 				  end, CurList),
	
%%     end,
    
%%     ok.

%% 判断策划填是否填新任务了
search_new_tasks(#task_statics{cur_list = IDList, remain_list = AllTask} = TaskStatics) ->
    F = fun(X, {CurList, RemainList}) ->
		case lists:filter(fun(#task_info{task_id=TaskID, has_finished=HasFinished}) -> 
					(TaskID =:= X) and (HasFinished =/= 0)  
				  end, RemainList) of
		    [] -> % 未完成
			{[X | CurList], RemainList};
		    FinishTask -> % 已完成 看是否填新任务了
			#task_tplt{next_ids=NextIDs}=tplt:get_data(task_tplt, X),
			case get_next_task_ids(NextIDs) of
			    [] -> %% 没新任务，保持原状
				{[X | CurList], RemainList};
			    NewTaskIds -> %% 有新任务，去除已完成任务
				NewTasks = get_next_tasks(NewTaskIds, RemainList),
				{NewTaskIds ++ CurList, (RemainList ++ NewTasks) -- FinishTask}
			end
		end
	end,
    
    {NewCur, NewRemain} = lists:foldr(F, {[], AllTask}, IDList),
    TaskStatics#task_statics{cur_list = NewCur, remain_list = NewRemain}.


%%判断任务ID是否在表里面
is_task_exist(AllTask, TaskId)->
    case lists:keyfind(TaskId, #task_info.task_id, AllTask) of
	false ->
	    false;
	_ ->
	    true
    end.



%%获取任务列表，优先从进程字典
get_task_list(RoleId)->
    Key = task_list,
    case get(task_list) of
	undefined ->
	    case cache:get(Key, RoleId) of
		%% 有任务列表(没后继的任务，完成后会被留在任务列表中，并标为已完成,等策划填数据后再自动往下接)
		[{_, #task_statics{task_amount = Length, remain_list = RemainList} = TaskStatics}]-> 
		    case get_newer_task(Length) of
			{[], Length} ->
			    put(task_list, TaskStatics),
			    TaskStatics;
			{NewIds, NewLength}->
			    Newnew = TaskStatics#task_statics{task_amount = NewLength, remain_list = RemainList ++ get_next_tasks(NewIds, RemainList)},
			    %%io:format("Newnew:~p~n", [Newnew]),
			    put(task_list, Newnew),
			    cache:set(task_list, RoleId, Newnew),
			    Newnew
		    end;
		_ -> %% 没任务列表，取初始任务
		    IDList = config:get(first_task_list),
		    {AllTaskId, _} = get_newer_task(0),
		    %%io:format("~p",[AllTaskId]),
		    AllTask = [#task_info{has_finished=0, task_id=ID, args=init_task_args(ID)} || ID <- AllTaskId],
		    TaskStatics = #task_statics{task_amount = length(AllTask), cur_list = IDList, remain_list = AllTask},
		    cache:set(Key, RoleId, TaskStatics),
		    put(task_list, TaskStatics),
		    TaskStatics
	    end;
	TaskList when is_record(TaskList, task_statics)->
	    TaskList
    end.

%%把任务信息保存在进程字典里
set_task_list(RoleId, TaskStatics) ->
    case get_task_list(RoleId) of
	TaskStatics ->
	    ok;
	OrgStatics ->
	    NotifyList = make_notify_list(TaskStatics),
	    case make_notify_list(OrgStatics) of
		NotifyList ->
		    ok;
		_ ->
		    do_notify_task_lists(NotifyList)
		    %%packet:send(#notify_task_infos{type=?init, infos=NotifyList})
	    end,
	    cache:set(task_list, RoleId, TaskStatics),
	    put(task_list, TaskStatics)
    end.

%_client_task_info(NewTaskList)

notify_client_task_info(TaskStatics)->
    NewTaskList = make_notify_list(TaskStatics),
    do_notify_task_lists(NewTaskList).
    %%packet:send(#notify_task_infos{type=?init, infos=NewTaskList}).

make_notify_list(#task_statics{cur_list = CurList, remain_list = RemainList})->
    %%io:format("CurList:~p~nRemainList:~p~n", [CurList, RemainList]),
    NotifyList = lists:map(fun(X) ->
				   lists:keyfind(X, #task_info.task_id, RemainList)
			   end, CurList),
    lists:filter(fun(#task_info{has_finished = HasFinished}) -> 
			 HasFinished =:= 0
		 end, NotifyList).

do_notify_task_lists(NotifyList)->
    case NotifyList of	
	[] ->
	    ok;
	_ ->
	    packet:send(#notify_task_infos{type=?init, infos=NotifyList})
    end.

%%服务器启动时更新任务列表
init_task_info()->
    AllTask = lists:map(fun(#task_tplt{id = TaskId}) -> 
				TaskId
			end, tplt:get_all_data(task_tplt)),
    {List, Length} = get_newer_task(0),
    case length(AllTask) of
	Length ->
	    ok;
	_ ->
	    redis:set(all_task_id, List ++ (AllTask -- List))
    end.





















