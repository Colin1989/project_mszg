-module(friend).
-export([start/0,
	 set_sculpture_update/1,
	 role_online_update/0,
	 role_offline_update/0,
	 set_myinfo_update/0,
	 %%make_friend_data/2,
	 get_battle_power/0,
	 make_battle_info/1
	 %%get_rfriend_data/2
	]).

-export([proc_search_friend/1,
	 proc_add_friend/1,
	 proc_del_friend/1,
	 proc_get_friends/1,
	 proc_send_chat_msg/1,
	 proc_reply_add_friend/1
	]).
%%-compile(export_all).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("record_def.hrl").

start()->
    packet:register(?msg_req_search_friend,{?MODULE,proc_search_friend}),
    packet:register(?msg_req_add_friend, {?MODULE, proc_add_friend}),
    packet:register(?msg_req_del_friend, {?MODULE, proc_del_friend}),
    packet:register(?msg_req_get_friends,{?MODULE, proc_get_friends}),
    packet:register(?msg_req_send_chat_msg,{?MODULE, proc_send_chat_msg}),
    packet:register(?msg_req_proc_reqfor_add_friend,{?MODULE, proc_reply_add_friend}),
    ok.



%% get_friends()->
%%     ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec回应添加
%% @end
%%--------------------------------------------------------------------
proc_reply_add_friend(#req_proc_reqfor_add_friend{answer=Answer,friend_id=FriendId}=_Pack)->
    case Answer of
	?agree ->
	    case redis:sismember(lists:concat([role,'_friends:',player:get_role_id()]),FriendId) of
		1 -> ok;
		0 -> 
		    case check_friend_limit_exceeded(player:get_role_id()) of
			false ->
			    case check_friend_limit_exceeded(FriendId) of
				false ->
				    notify_friend_add(player:get_role_id(),FriendId);
				true ->
				    sys_msg:send_to_self(?sg_friend_add_aim_limit_exceeded,[])
				    
			    end;
			true ->
			    sys_msg:send_to_self(?sg_friend_add_limit_exceeded,[])
		    end
		    
	    end;
	?defuse ->
	    send_defuse_msg_to_client(FriendId),
	    ok
    end.

send_defuse_msg_to_client(FriendId)->
    case role_pid_mapping:get_pid(FriendId) of
	undefined ->
	    ok;
	Pid ->
	    packet:send(Pid, #notify_add_friend_defuse_msg{role_id = player:get_role_id()})
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec查找好友
%% @end
%%--------------------------------------------------------------------
proc_search_friend(#req_search_friend{nickname=NickName}=_Pack)->
    case player_role:get_role_by_nickname(NickName) of
	[] ->
	    packet:send(#notify_search_friend_result{result=?common_failed});
	[Role] ->
	    Status=case role_pid_mapping:get_pid(Role:role_id()) of
		       undefined -> 
			   ?offline;
		       _ ->
			   ?online
		   end,
	    FriendData = roleinfo_manager:get_roleinfo(Role:role_id()),
	    FriendInfo = make_friend_info(Role:role_id(), FriendData),
	    packet:send(#notify_search_friend_result{result=?common_success,
						     role_info=FriendInfo#friend_info{status=Status}})
    end.


check_friend_limit_exceeded(RoleId)->
    Amount = get_friend_amount(RoleId),
    MaxAmount = config:get(max_friend_amount),
    Amount >= MaxAmount.

get_friend_amount(RoleId)->
    Amount = redis:scard(lists:concat([role,'_friends:',RoleId])),
    Amount.

%%--------------------------------------------------------------------
%% @doc
%% @spec添加好友
%% @end
%%--------------------------------------------------------------------
proc_add_friend(#req_add_friend{friend_id=FriendId}=_Pack)->
    case FriendId =:= player:get_role_id() of
	true ->
	    sys_msg:send_to_self(?sg_friend_add_self,[]),
	    packet:send(#notify_add_friend_result{result=?common_error});
	false ->
	    case redis:sismember(lists:concat([role,'_friends:',player:get_role_id()]),FriendId) of
		1 ->
		    sys_msg:send_to_self(?sg_friend_add_exist,[]),
		    packet:send(#notify_add_friend_result{result=?common_error});
		0 ->
		    case role_pid_mapping:get_pid(FriendId) of
			undefined ->
			    sys_msg:send_to_self(?sg_friend_add_offline,[]),
			    packet:send(#notify_add_friend_result{result=?common_error});
			Pid ->
			    case check_friend_limit_exceeded(player:get_role_id()) of
				false ->
				    Packdd = #notify_req_for_add_friend{friend_id=player:get_role_id(), 
									role_data=make_friend_data(roleinfo_manager:get_roleinfo(player:get_role_id()))},
				    %%io_helper:format("~p~n",[Packdd]),
				    packet:send(Pid,Packdd),
				    packet:send(#notify_add_friend_result{result=?common_success});
				true ->
				    sys_msg:send_to_self(?sg_friend_add_limit_exceeded,[]),
				    packet:send(#notify_add_friend_result{result=?common_error})
			    end
		    end
	    
	    end

    end.
    
    %%cache:insert(lists:concat([role,player:get_role_id(),'_friends']),FriendId),
    %%cache:insert(lists:concat([role,FriendId,'_friends']),player:get_role_id()),
    %%FriendInfo = get_friend_info(FriendId),
    %%packet:send(#notify_add_friend_result{result=?common_success,new_friend=#friend_info{friend_id=FriendId,info=FriendInfo}}),
    %%ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec下放好友增加提示
%% @end
%%--------------------------------------------------------------------
notify_friend_add(Id1,Id2)->
    redis:sadd(lists:concat([role,'_friends:',Id1]),[Id2]),
    redis:sadd(lists:concat([role,'_friends:',Id2]),[Id1]),
    FriendInfo1 = roleinfo_manager:get_roleinfo(Id1),
    FriendInfo2 = roleinfo_manager:get_roleinfo(Id2),
    case role_pid_mapping:get_pid(Id1) of
	undefined ->
	    ok;
	Pid -> 
	    packet:send(Pid,#notify_friend_list{type=?append,friends=[make_friend_info(Id2, FriendInfo2)]})
    end,
    case role_pid_mapping:get_pid(Id2) of
	undefined ->
	    ok;
	Pid2 -> 
	    packet:send(Pid2,#notify_friend_list{type=?append,friends=[make_friend_info(Id1, FriendInfo1)]})
    end.

make_friend_info(FriendId, FriendData)->
    %%io_helper:format("~n###################~n~p:~p~n#################~n",[FriendId,FriendData]),
    #friend_info{friend_id=FriendId,nickname=FriendData#role_info_detail.nickname,status=FriendData#role_info_detail.status,
		head=FriendData#role_info_detail.type,level=FriendData#role_info_detail.level,
		public=FriendData#role_info_detail.public,battle_prop=make_battle_info(FriendData#role_info_detail.battle_prop)}.

make_friend_data(FriendData) ->
    #friend_data{nickname = FriendData#role_info_detail.nickname, status = FriendData#role_info_detail.status, 
		 head = FriendData#role_info_detail.type,level=FriendData#role_info_detail.level,
		public=FriendData#role_info_detail.public,battle_prop=make_battle_info(FriendData#role_info_detail.battle_prop)}.


%% -record(role_attr_detail, {sculptures, equipments, life, speed, atk, hit_ratio, miss_ratio, critical_ratio, tenacity, battle_power}).
make_battle_info(Data)->
    #battle_info{atk = Data#role_attr_detail.atk, life = Data#role_attr_detail.life, speed = Data#role_attr_detail.speed, 
		 hit_ratio = Data#role_attr_detail.hit_ratio, miss_ratio = Data#role_attr_detail.miss_ratio,
		 critical_ratio = Data#role_attr_detail.critical_ratio, tenacity = Data#role_attr_detail.tenacity, 
		 power = Data#role_attr_detail.battle_power, sculpture = Data#role_attr_detail.sculptures}.
    
    
%%--------------------------------------------------------------------
%% @doc
%% @spec删除好友
%% @end
%%--------------------------------------------------------------------
proc_del_friend(#req_del_friend{friend_id=FriendId}=_Pack)->
    redis:srem(lists:concat([role,'_friends:',player:get_role_id()]),[FriendId]),
    redis:srem(lists:concat([role,'_friends:',FriendId]),[player:get_role_id()]),
    case role_pid_mapping:get_pid(FriendId) of
	undefined ->
	    ok;
	Pid -> 
	    packet:send(Pid,#notify_friend_list{type=?delete,friends=[#friend_info{friend_id=player:get_role_id()}]})
    end,
    packet:send(#notify_friend_list{type=?delete,friends=[#friend_info{friend_id=FriendId}]}),
    packet:send(#notify_del_friend_result{result=?common_success}),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec获取好友列表
%% @end
%%--------------------------------------------------------------------
proc_get_friends(#req_get_friends{}=_Pack)->
    Friend=redis_extend:get_members_info(lists:concat([role,'_friends:',player:get_role_id()]),role_info_detail),
    FriendPids=redis_extend:get_members_info(lists:concat([role,'_friends:',player:get_role_id()]),role_pid_mapping),
    FriendList=lists:map(fun(X) ->
				 {Id, FriendInfo} = X,
				 case roleinfo_manager:upgrade_data(Id, FriendInfo) of
				     undefined ->
					 redis:srem(lists:concat([role,'_friends:',player:get_role_id()]),[Id]),
					 redis:srem(all_roleid_set, [Id]),
					 #friend_info{friend_id=0};
				     Info ->
					 make_friend_info(Id, Info)
				 end
			 end,Friend),
    FinalList1=lists:filter(fun(X) ->
				   X#friend_info.friend_id =/= 0
			   end,FriendList),
    FinalList = lists:map(fun(X) ->
				  case proplists:lookup(X#friend_info.friend_id, FriendPids) of
				      {_, undefined}->
					  X#friend_info{status = ?offline};
				      _ ->
					  X#friend_info{status = ?online}
				  end
			  end, FinalList1),
    packet:send(#notify_friend_list{type=?init,friends=FinalList}),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec发送信息
%% @end
%%--------------------------------------------------------------------
proc_send_chat_msg(#req_send_chat_msg{friend_id=FriendId,chat_msg=Msg})->
    io_helper:format("send:~p to:~p~n",[Msg,FriendId]),
    case role_pid_mapping:get_pid(FriendId) of
	undefined -> 
	    packet:send(#notify_send_chat_msg_result{result=?common_failed});
	Pid ->
	    packet:send(Pid,#notify_receive_chat_msg{friend_id=player:get_role_id(),chat_msg=Msg}),
	    packet:send(#notify_send_chat_msg_result{result=?common_success})
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec通知好友自己信息更新
%% @end
%%--------------------------------------------------------------------
notify_friends_my_info_change(MyData)->
    FriendPids=redis_extend:get_members_info(lists:concat([role,'_friends:',player:get_role_id()]),role_pid_mapping),
    MyInfo=make_friend_info(player:get_role_id(),MyData),%%#friend_info{friend_id=player:get_role_id(),info=MyData},
    lists:foldl(fun({_Id, Pid}, _In) ->
			case Pid of
			    undefined ->
				ok;
			    Pid when is_pid(Pid) -> 
				packet:send(Pid,#notify_friend_list{type=?modify,friends=[MyInfo]})
			end
		end,[],FriendPids).
%%--------------------------------------------------------------------
%% @doc
%% @spec好友信息更新
%% @end
%%--------------------------------------------------------------------
role_online_update()->
    RoleId=player:get_role_id(),
    %% RoleInfo=make_friend_data(RoleId,?online),
    %%RoleInfo=get_rfriend_data(RoleId, get_friend_info(RoleId)),%%make_friend_data(RoleId,?offline),
    %%RoleInfo = roleinfo_manager:get_roleinfo(RoleId),
    %%io:format("RoleInfo:~p~n",[RoleInfo]),
    %%NewRoleInfo = RoleInfo#role_info_detail{status = ?online},
    %%roleinfo_manager:set_roleinfo(RoleId, NewRoleInfo),
    NewRoleInfo = roleinfo_manager:remake_roleinfo_detail(RoleId, ?online),
    roleinfo_manager:put_roleinfo(NewRoleInfo),
    %%NewInfo=RoleInfo#friend_data{status=?online},
    %%cache:set(friend_info,RoleId,RoleInfo),
    %%packet:send(#notify_role_battle_power{value = RoleInfo#friend_data.battle_prop#battle_info.power}),
    rank_statics:update_rank(battle_power_rank, player:get_role_id(), NewRoleInfo#role_info_detail.battle_prop#role_attr_detail.battle_power),
    rank_statics:update_rank(role_lev_rank, player:get_role_id(), NewRoleInfo#role_info_detail.level),
    set_battle_power(NewRoleInfo#role_info_detail.battle_prop#role_attr_detail.battle_power),
    notify_friends_my_info_change(NewRoleInfo).



role_offline_update()->
    RoleId=player:get_role_id(),
    case RoleId of
	undefined ->
	    ok;
	_ ->
	    RoleInfo=roleinfo_manager:get_roleinfo(RoleId),%%get_rfriend_data(RoleId, get_friend_info(RoleId)),%%make_friend_data(RoleId,?offline),
	    %%io:format("RoleInfo:~p~n",[RoleInfo]),
	    NewRoleInfo = RoleInfo#role_info_detail{status = ?offline},
	    roleinfo_manager:set_roleinfo(RoleId, NewRoleInfo),
	    %%NewInfo=RoleInfo#friend_data{status=?offline},
	    %%cache:set(friend_info,RoleId,RoleInfo),
	    %%rank_statics:update_rank(battle_power_rank, player:get_role_id(), RoleInfo#friend_data.battle_prop#battle_info.power),
	    %%rank_statics:update_rank(role_lev_rank, player:get_role_id(), RoleInfo#friend_data.level),
	    notify_friends_my_info_change(NewRoleInfo) 
	    %%cache:set(friend_info, RoleId, NewRoleInfo)
    end.

%% set_role_info()->
%%     RoleId=player:get_role_id(),
%%     RoleInfo=make_friend_data(RoleId,?online),
%%     set_roleinfo(RoleId, RoleInfo).
    %%cache:set(friend_info,RoleId,RoleInfo).


set_battle_power(Power)->
    put(battle_power,Power).

get_battle_power()->
    get(battle_power).
%%--------------------------------------------------------------------
%% @doc
%% @spec更新玩家符文信息[{2,101},{3,100}]
%% @end
%%--------------------------------------------------------------------
set_sculpture_update(UpdateList)->
    OrgInfo = roleinfo_manager:get_roleinfo(player:get_role_id()),
    Sculptures = lists:foldl(fun({Pos, TempId} ,In) -> 
				     lists:sublist(In,1,Pos-1) ++ [TempId] ++ lists:sublist(In,Pos+1,4)
			     end,OrgInfo#role_info_detail.battle_prop#role_attr_detail.sculptures,UpdateList),
    CurInfo = OrgInfo#role_info_detail{battle_prop = OrgInfo#role_info_detail.battle_prop#role_attr_detail{sculptures=Sculptures}},
    roleinfo_manager:set_roleinfo(player:get_role_id(), CurInfo).
    %%cache:set(friend_info,player:get_role_id(),CurInfo).


set_myinfo_update()->
    OrgInfo = roleinfo_manager:get_roleinfo(player:get_role_id()),
    OrgPower = OrgInfo#role_info_detail.battle_prop#role_attr_detail.battle_power,
    OrgLev = OrgInfo#role_info_detail.level,
    AttrProp = battle_power:get_role_battle_prop(),
    Sculptures = OrgInfo#role_info_detail.battle_prop#role_attr_detail.sculptures,
    %%[Role] = db:find(db_role,[{role_id,'equals',player:get_role_id()}]),
    Role = player_role:get_db_role(player:get_role_id()),
    BattleProp = #role_attr_detail{sculptures = Sculptures,life = AttrProp#battle_prop.life, speed = AttrProp#battle_prop.speed,
			      atk = AttrProp#battle_prop.atk, hit_ratio = AttrProp#battle_prop.hit_ratio,
			      miss_ratio = AttrProp#battle_prop.miss_ratio, critical_ratio = AttrProp#battle_prop.critical_ratio,
			      tenacity = AttrProp#battle_prop.tenacity, battle_power = AttrProp#battle_prop.power},
    
    CurInfo=#role_info_detail{status=?online,type=Role:role_type(),nickname=Role:nickname(),
			    level=Role:level(),public="test",battle_prop=BattleProp},
    %%cache:set(friend_info,player:get_role_id(),CurInfo),
    roleinfo_manager:set_roleinfo(player:get_role_id(), CurInfo),
    case AttrProp#battle_prop.power of
	OrgPower ->
	    ok;
	NewPower ->
	    rank_statics:update_rank(battle_power_rank, player:get_role_id(), NewPower),
	    packet:send(#notify_role_info_change{type = "battle_power", new_value = NewPower}),
	    set_battle_power(NewPower)
    end,
    case Role:level() of
	OrgLev ->
	    ok;
	NewLev ->
	    rank_statics:update_rank(role_lev_rank, player:get_role_id(), NewLev)
    end.
    %%notify_friends_my_info_change(RoleInfo).

%%--------------------------------------------------------------------
%% @doc
%% @spec获得好友信息
%% @end
%%--------------------------------------------------------------------
%% get_friend_info(FriendId)->
%%     case cache:get(friend_info,FriendId) of
%% 	[] ->
%% 	    case make_friend_data(FriendId,?offline) of
%% 		undefined ->
%% 		    redis:srem(lists:concat([role,'_friends:',player:get_role_id()]),[FriendId]),
%% 		    undefined;
%% 		FriendInfo ->
%% 		    FriendInfo
%% 	    end;
%% 	[{FriendId,Friend}] ->
%% 	    case is_record(Friend,friend_data)  orelse (not is_record(Friend#friend_data.battle_prop,battle_info))of
%% 		true ->
%% 		    Friend;
%% 		false ->
%% 		    make_friend_data(FriendId)
%% 		%%    case make_friend_info(FriendId,?offline) of
%% 		%%	undefined ->
%% 		%%	    cache:remove(lists:concat([role,player:get_role_id(),'_friends']),FriendId),
%% 		%%	    undefined;
%% 		%%	FriendInfo ->
%% 		%%	    FriendInfo
%% 		%%    end
%% 	    end
%%     end.


%% %%--------------------------------------------------------------------
%% %% @doc
%% %% @spec生成好友信息
%% %% @end
%% %%--------------------------------------------------------------------
%% make_friend_data(Id,Status)->
%%     case player_role:get_db_role(Id) of
%% 	undefined -> 
%% 	    io_helper:format("~n##########~p##########~n",[Id]),
	    
%% 	    redis:srem(all_roleid_set, [Id]),
%% 	    redis:srem(lists:concat([role,'_friends:',player:get_role_id()]),[Id]),
%% 	    undefined;
%% 	Role ->
%% 	    Sculptures = get_sculpture_tempids([Role:sculpture1(),Role:sculpture2(),Role:sculpture3(),Role:sculpture4()]),
%% 	    AttrProp = player_role:get_role_battle_prop(Id),
%% 	    BattleProp = #battle_info{sculpture = Sculptures,life = AttrProp#battle_prop.life, speed = AttrProp#battle_prop.speed,
%% 				     atk = AttrProp#battle_prop.atk, hit_ratio = AttrProp#battle_prop.hit_ratio,
%% 				     miss_ratio = AttrProp#battle_prop.miss_ratio, critical_ratio = AttrProp#battle_prop.critical_ratio,
%% 				     tenacity = AttrProp#battle_prop.tenacity, power = AttrProp#battle_prop.power},
%% 	    FriendInfo=#friend_data{status=Status,head=Role:role_type(),nickname=Role:nickname(),
%% 				    level=Role:level(),public="test",battle_prop=BattleProp},
%% 	    cache:set(friend_info, Id, FriendInfo),
%% 	    FriendInfo
%%     end.

%% get_sculpture_tempids(Sculptures)->
%%     lists:map(fun(X) -> 
%% 		      case X of
%% 			  0 ->
%% 			      #sculpture_data{};
%% 			  _ ->
%% 			      sculpture:get_sculpture_tempid_and_lev(X)
%% 		      end
%% 	      end,Sculptures).
%% make_friend_data(Id)->
%%     make_friend_data(Id,?offline).


%% get_rfriend_data(FriendId, Data)->
%%     case Data of
%% 	_ when  not is_record(Data,friend_data) orelse (not is_record(Data#friend_data.battle_prop,battle_info)) ->
%% 		%%orelse
%% 		%%not is_record(Data#friend_data.battle_prop#battle_info.power, sculpture_data)->
%% 	    Info=make_friend_data(FriendId),
%% 	    case Info of
%% 		undefined ->
%% 		    undefined;
%% 		_ ->
%% 		    Info
%% 	    end; 
%% 	_ ->
%% 	    Data

%%     end.


%%proc_recv_chat_msg(_Pack)->
    
%%    ok.
    
