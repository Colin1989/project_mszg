%%% @author hongjx <>
%%% @copyright (C) 2014, hongjx
%%% @doc
%%%  ������ز���
%%%    (û��̵�������ɺ�ᱻ���������б��У�����Ϊ�����,�Ȳ߻������ݺ����Զ����½�)
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

%%-compile(export_all). %% ������

-export([start/0,
	 update_task_state/1
	 %%update_task_state/2
	]).

-export([proc_req_finish_task/1, 
	 proc_req_task_infos/1,
	 init_task_info/0
	]).

start() ->
    %% ���������б�
    %%packet:register(?msg_req_task_infos, {?MODULE, proc_req_task_infos}),
    %% �����������
    packet:register(?msg_req_finish_task,{?MODULE, proc_req_finish_task}),
    %% ����ͨ���¼�
    event_router:register(event_game_copy, {?MODULE, update_task_state}),

    event_router:register(event_sculpture_upgrade, {?MODULE, update_task_state}),
    %%init_task_info(),
  event_router:register(event_task_finish_times_update, {?MODULE, update_task_state}),
    ok.

%%-record(event_game_copy, {copy_id = 0, score = 0,  monsterids=[]}).

%%%===================================================================
%% ����������Ϣ
%%%===================================================================
update_task_state(#event_task_finish_times_update{amount = Amount, sub_type = SubType}) ->
    TaskStatics = db_get_task_list(player:get_role_id()),
    #task_statics{remain_list = RemainList} = TaskStatics,

    F = fun(#task_info{task_id = TaskID, has_finished = HasFinished} = X) ->
		#task_tplt{sub_type = Kind,
			   number = NeedCount} = tplt:get_data(task_tplt, TaskID),

		case HasFinished of
		    1 -> %% ����ɣ��Ͳ�������
			X;
		    _ ->
			case Kind of
			    SubType -> %% SubType 5: ǿ�� 6:�ֽ����� 7:ռ������

				#task_info{args = [OldN]} = X,

				case OldN + Amount < NeedCount of
				    true ->
					X#task_info{args = [OldN + Amount]};
				    _ -> %% ��������
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
			    _ -> % �������ͣ����ù�
				X
			end
		end
	end,

    %% ֻȡδ��ɵ�
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
		    1 -> %% ����ɣ��Ͳ�������
			X;
		    _ ->
			case Kind of
			    4 -> % ɱ����������
				%% ��ɴ���+1
				#task_info{args = [OldN]} = X,

				case OldN + Amount < NeedCount of
				    true ->
					X#task_info{args = [OldN + Amount]};
				    _ -> %% ��������
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
			    _ -> % �������ͣ����ù�
				X
			end
		end
	end,

    %% ֻȡδ��ɵ�
    NewList = [F(X) || X <- RemainList],
    db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList});
    %%io:format("new list ~p~n", [NewList]),
    %% case OldList =/= NewList of
    %% 	true ->
    %% 	    %% �浽���ݿ�
    %% 	    db_set_task_list(player:get_role_id(), NewList),
    %% 	    %% �и���Ҫ֪ͨ�ͻ���
    %% 	    packet:send(#notify_task_infos{type=?init, infos=NewList});
    %% 	_ ->
    %% 	    ok
    %% end;
update_task_state(Tuple) ->
    %%io:format("update_task_state ~p~n", [Tuple]),
    #event_game_copy{copy_id=CopyID, score=Score, monsterids=MonsterList} = Tuple,

    RoleId = player:get_role_id(),
    
    PassType = case Score of
		   0 -> 0; % ûͨ��
		   3 -> 2; % 3��ͨ��
		   _ -> 1  % ��ͨͨ��
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
%% ɱ��: �������id������
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
		    1 -> %% ����ɣ��Ͳ�������
			X;
		    _ ->
			case Kind of
			    1 -> % ɱ����������
				case (MonsterID =:= NeedMonsterID) and (Location =:= CopyID) of
				    true -> %% ���ﳡ��,�����ж�
					%% ��ɴ���+1
					#task_info{args = [OldN]} = X,

					case OldN + KillN < NeedCount of
					    true ->
						X#task_info{args = [OldN + KillN]};
					    _ -> %% ��������
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
			    _ -> % �������ͣ����ù�
				X
			end
		end
	end,
    NewList = [F(X) || X <- RemainList],
    TaskStatics#task_statics{remain_list = NewList};
    %%%db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList});	   
    %% ֻȡδ��ɵ�
    %% NewList = [F(X) || X <- OldList],
    %% %%io:format("new list ~p~n", [NewList]),
    %% case OldList =/= NewList of
    %% 	true ->
    %% 	    %% �浽���ݿ�
    %% 	    db_set_task_list(RoleId, NewList),
    %% 	    %% �и���Ҫ֪ͨ�ͻ���
    %% 	    packet:send(#notify_task_infos{type=?init, infos=NewList});
    %% 	_ ->
    %% 	    ok
    %% end;
%% ����ͨ��: ���븱��id��(ͨ������ 1=����ͨ�� 2=����ͨ�� 3=��ɱ���е���ͨ��)
update_task_state(_RoleId, {pass_copy, CopyID, PassType}, TaskStatics) ->
    %%OldList = db_get_task_list(RoleId),
    %%TaskStatics = db_get_task_list(RoleId),
    #task_statics{remain_list = RemainList} = TaskStatics,
    F = fun(#task_info{task_id = TaskID, has_finished = HasFinished} = X) ->
		#task_tplt{sub_type = Kind, location = Location,
			   clear_type = ClearType} = tplt:get_data(task_tplt, TaskID),
		case HasFinished of
		    1 -> %% ����ɣ��Ͳ�������
			X;
		    _ ->
			case Kind of
			    2 -> % ͨ����������
				case CopyID of
				    Location -> %% �����ص�һ��
					case PassType >= ClearType of
					    true -> %% ���������Ҫ��
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
						%% ��ɴ�����Ϊ1
						X#task_info{args = [1]};
					    _ -> %% ����Ҫ�󣬲��ô���
						X
					end;
				    _ ->
					X
				end;
			    _ -> % �������ͣ����ù�
				X
			end
		end
  end,

    %% ֻȡδ��ɵ�
    %% NewList = [F(X) || X <- OldList],
    %% case OldList =/= NewList of
    %% 	true ->
    %% 	    %% �浽���ݿ�
    %% 	    db_set_task_list(RoleId, NewList),
    %% 	    %% �и���Ҫ֪ͨ�ͻ���
    %% 	    packet:send(#notify_task_infos{type=?init, infos=NewList});
    %% 	_ ->
    %% 	    ok
    %% end.
    NewList = [F(X) || X <- RemainList],
    TaskStatics#task_statics{remain_list = NewList}.
    %%db_set_task_list(player:get_role_id(), TaskStatics#task_statics{remain_list = NewList}).


%%%===================================================================
%% ���������б�
%% [req_task_infos
%% ],
%%%===================================================================
proc_req_task_infos(#req_task_infos{})->
    RoleId = player:get_role_id(),
    %% ֻȡδ��ɵ�
    %% #task_statics{task_amount = Amount, cur_list = CurList, remain_list = RemainList} = db_get_task_list(RoleId),
    %% TaskList = [X || #task_info{has_finished=HasFinished}=X <- db_get_task_list(RoleId), 
    %% 	  HasFinished=:=0],
    %% packet:send(#notify_task_infos{type=?init, infos=TaskList}).
    notify_client_task_info(db_get_task_list(RoleId)).



%%%===================================================================
%% �����������
     %% [req_finish_task,%% ����������� 
     %%  {int, task_id}  % ����xml id
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
	false -> %% ���񲻴���
	    notify_finish_task_fail(?sg_task_not_exist,[]);
	#task_info{has_finished=HasFinished, args=Args} ->
	    case HasFinished of
		1 -> %% ���������
		    notify_finish_task_fail(?sg_task_has_finished,[]);
		_ ->
		    #task_tplt{need_level=NeedLevel} = Tplt,
		    case MyLevel < NeedLevel of
			true -> %% �ȼ�����
			    notify_finish_task_fail(?sg_task_player_level_not_enough,[]);
			_ ->
			    case check_sub_need(Tplt, Args) of
				true -> %% �����ͼ��ͨ��
				    %% ��������
				    do_finish_task(TaskID, TaskStatics),

				    %% ��������
				    give_reward(Tplt, Role),
				    %% ֪ͨ�������
				    packet:send(#notify_finish_task{is_success=?common_success,task_id=TaskID});
				_ ->
				    ok
			    end
		    end    		    
	    end
    end.


notify_finish_task_fail(MsgID, Args) ->
    %% ֪ͨ����û���
    packet:send(#notify_finish_task{is_success=?common_failed}),
    sys_msg:send_to_self(MsgID, Args).


%%%===================================================================
%%% �ڲ�ʵ�ֺ���
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
	    [] -> %% û�����񣬱���ԭ״, �������ɾͺ�
		NewInfo = OldInfo#task_info{has_finished=1},
		TaskStatics#task_statics{remain_list = lists:keyreplace(TaskID, #task_info.task_id, RemainList, NewInfo)};
	    NewTaskIDs -> %% ��������ȥ�����������, �������֪ͨ�ͻ���
		NewTasks = get_next_tasks(NewTaskIDs, RemainList),
		TaskStatics#task_statics{remain_list = (lists:keydelete(TaskID, #task_info.task_id, RemainList)) ++ NewTasks, 
					cur_list = (CurList -- [TaskID|NewTaskIDs]) ++ NewTaskIDs}
	end,

    RoleId = player:get_role_id(),
    %% �浽���ݿ�
    db_set_task_list(RoleId, NewTaskList).
    %% ֪ͨ�ͻ���
    %% packet:send(#notify_task_infos{type=?init, infos=NewTaskList}).
    %%notify_client_task_info(NewTaskList).



    

%% �����ͼ��
%% û���ⷵ��true
check_sub_need(#task_tplt{sub_type = Kind,
                          clear_type = ClearType,
                          collect_id = ItemID,
                          number = Amount
},             Args) ->
  Arg1 = hd(Args),
  case Kind of
    1 -> % ��ɱ����
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_monster_amount_not_enough, []);
        _ ->
          true
      end;
    2 -> % ͨ�ظ���
      case Arg1 < Amount of
        true ->
          case ClearType of
            1 -> % ����ͨ��
              notify_finish_task_fail(?sg_task_not_pass, []);
            2 -> % ����ͨ��
              notify_finish_task_fail(?sg_task_not_full_star_pass, []);
            3 -> % ��ɱ���е���ͨ��
              notify_finish_task_fail(?sg_task_not_kill_all_pass, [])
          end;
        _ ->
          true
      end;
    3 -> % �ռ���Ʒ
      %% �ѱ����ó������
      [{_ItemID, Count}] = player_pack:get_items_count([ItemID]),
      case Count < Amount of
        true ->
          notify_finish_task_fail(?sg_task_item_amount_not_enough, []);
        _ ->
          true
      end;
    4 -> % ���ܴ���
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_sculpture_upgrade_amount_not_enough, []);
        _ ->
          true
      end;
    5 -> %% 5 : ǿ��
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_advance_equipment_amount_not_enough, []);
        _ ->
          true
      end;
    6 -> %% 6:�ֽ�����
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_equipment_resolve_amount_not_enough, []);
        _ ->
          true
      end;
    7 -> %% 7:ռ������
      case Arg1 < Amount of
        true ->
          notify_finish_task_fail(?sg_task_sculpture_divine_amount_not_enough, []);
        _ ->
          true
      end
  end.


%% ������
give_reward(#task_tplt{reward_ids=RewardIDs, reward_amounts =RewardAmounts}, _Role) ->
  reward:give(RewardIDs, RewardAmounts, ?st_task_reward).

%% ȡ�������
%% ����:NextIDs �������id
get_next_tasks(NextIDs, RemainList) ->
    case NextIDs of
	[] -> %% ����û������
	    [];
	[0] -> %% ����û������
	    [];
	_ -> %% ��������
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
    

%% ��ʼ���������
init_task_args(TaskID) ->
  #task_tplt{sub_type = SubType} = tplt:get_data(task_tplt, TaskID),
  case SubType of
    1 -> %% ��ɱ��������
      [0];
    2 -> %% ͨ�ظ����Ƿ��������
      [0];
    3 -> %% �ռ���Ʒ
      [];
    4 -> %% ���ܴ���
      [0];
    5 -> %% ǿ������
      [0];
    6 -> %% �ֽ����
      [0];
    7 -> %% ռ�˴���
      [0]
  end.

%%--------------------------------------------------------------------
%% @doc
%%  ��ȡ�����б��б��ÿ��Ԫ�ض���#task_info
%% [task_info,
%%  {int, task_id},    % ����xml id, �������id����֪����������
%%  {int, has_finished},  % �Ƿ������ 0 δ��� 1 ���
%%  {array, int, args}  
%%    args �����б����ڱ�ʾ���ָ�������������������            
%%    ��������=1��ɱ����ʱ,args��ʾ: ��ɱ��������
%%    ��������=2ͨ�ظ���ʱ,args��ʾ: ͨ�ش���
%%    ��������=3�ռ���Ʒʱ,argsĿǰûֵ: ��Ϊ�ռ���Ʒ���������ҵ� 
%% ],
%% @end
%%--------------------------------------------------------------------
%% ȡ�����б�
db_get_task_list(RoleId) ->
    OrgNewStatics = get_task_list(RoleId),
    %%io:format("1~n"),
    NewStatics = search_new_tasks(OrgNewStatics),
    %%io:format("NewStatics:~p~n", [NewStatics]),
    set_task_list(RoleId, NewStatics),
    NewStatics.





%%��ȡ�¼���ģ��������ID
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

%% �������б�
db_set_task_list(RoleId, TaskStatics) ->
    set_task_list(RoleId, TaskStatics).


%% db_update_task_list(Task) ->
    
%%     case CurList of
%% 	FinishList = lists:filter(fun(X) ->
%% 					  lists:keyfind(X, #task_info.task_id, RemainList)
%% 				  end, CurList),
	
%%     end,
    
%%     ok.

%% �жϲ߻����Ƿ�����������
search_new_tasks(#task_statics{cur_list = IDList, remain_list = AllTask} = TaskStatics) ->
    F = fun(X, {CurList, RemainList}) ->
		case lists:filter(fun(#task_info{task_id=TaskID, has_finished=HasFinished}) -> 
					(TaskID =:= X) and (HasFinished =/= 0)  
				  end, RemainList) of
		    [] -> % δ���
			{[X | CurList], RemainList};
		    FinishTask -> % ����� ���Ƿ�����������
			#task_tplt{next_ids=NextIDs}=tplt:get_data(task_tplt, X),
			case get_next_task_ids(NextIDs) of
			    [] -> %% û�����񣬱���ԭ״
				{[X | CurList], RemainList};
			    NewTaskIds -> %% ��������ȥ�����������
				NewTasks = get_next_tasks(NewTaskIds, RemainList),
				{NewTaskIds ++ CurList, (RemainList ++ NewTasks) -- FinishTask}
			end
		end
	end,
    
    {NewCur, NewRemain} = lists:foldr(F, {[], AllTask}, IDList),
    TaskStatics#task_statics{cur_list = NewCur, remain_list = NewRemain}.


%%�ж�����ID�Ƿ��ڱ�����
is_task_exist(AllTask, TaskId)->
    case lists:keyfind(TaskId, #task_info.task_id, AllTask) of
	false ->
	    false;
	_ ->
	    true
    end.



%%��ȡ�����б����ȴӽ����ֵ�
get_task_list(RoleId)->
    Key = task_list,
    case get(task_list) of
	undefined ->
	    case cache:get(Key, RoleId) of
		%% �������б�(û��̵�������ɺ�ᱻ���������б��У�����Ϊ�����,�Ȳ߻������ݺ����Զ����½�)
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
		_ -> %% û�����б�ȡ��ʼ����
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

%%��������Ϣ�����ڽ����ֵ���
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

%%����������ʱ���������б�
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





















