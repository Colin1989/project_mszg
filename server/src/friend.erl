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
	 proc_reply_add_friend/1,
	 notify_makefriend_reqs_amount/0,
	 proc_req_get_makefriend_reqs/1,
         proc_req_msg_list/1,
         notify_msg_count/0
	]).
-compile(export_all).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("record_def.hrl").
-include("common_def.hrl").

start()->
    packet:register(?msg_req_search_friend,{?MODULE,proc_search_friend}),
    packet:register(?msg_req_add_friend, {?MODULE, proc_add_friend}),
    packet:register(?msg_req_del_friend, {?MODULE, proc_del_friend}),
    packet:register(?msg_req_get_friends,{?MODULE, proc_get_friends}),
    packet:register(?msg_req_msg_list,{?MODULE, proc_req_msg_list}),
    packet:register(?msg_req_send_chat_msg,{?MODULE, proc_send_chat_msg}),
    packet:register(?msg_req_proc_reqfor_add_friend,{?MODULE, proc_reply_add_friend}),
    packet:register(?msg_req_get_makefriend_reqs, {?MODULE, proc_req_get_makefriend_reqs}),
    packet:register(?msg_req_reward_hp_from_friend, {?MODULE, proc_req_reward_hp_from_friend}),
    packet:register(?msg_req_send_hp, {?MODULE, proc_req_send_hp}),
    ok.


proc_req_get_makefriend_reqs(_Packet) ->
    Friend=redis_extend:get_members_info(lists:concat([role,'_friend_req:', player:get_role_id()]),role_info_detail),
    FriendList=lists:map(fun(X) ->
				 {Id, FriendInfo} = X,
				 case roleinfo_manager:upgrade_data(Id, FriendInfo) of
				     undefined ->
					 #friend_info{friend_id=0};
				     Info ->
					 make_friend_info(Id, Info)
				 end
			 end, Friend),
    FinalList=lists:filter(fun(X) ->
				   X#friend_info.friend_id =/= 0
			   end,FriendList),
    packet:send(#notify_makefriend_reqs{reqs = FinalList}),
    redis:del(lists:concat([role,'_friend_req:', player:get_role_id()])),
    ok.

notify_makefriend_reqs_amount() ->
    Amount = redis:scard(lists:concat([role,'_friend_req:', player:get_role_id()])),
    packet:send(#notify_makefriend_reqs_amount{amount = Amount}).


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
			    %%sys_msg:send_to_self(?sg_friend_add_offline,[]),
			    add_to_req_list(FriendId);
			    %%packet:send(#notify_add_friend_result{result=?common_success});
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

add_to_req_list(FriendId) ->
    case redis:scard(lists:concat([role,'_friend_req:', FriendId])) >= 20 of
	true ->
	    packet:send(#notify_add_friend_result{result=?common_failed});
	false ->
	    packet:send(#notify_add_friend_result{result=?common_success}),
	    redis:sadd(lists:concat([role,'_friend_req:', FriendId]), [player:get_role_id()])
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
    %%io:format("FriendInfo1:~p~nFriendInfo2:~p ~n",[FriendInfo1, FriendInfo2]),
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

make_friend_info(FriendId, FriendData) ->
	%%io_helper:format("~n###################~n~p:~p~n#################~n",[FriendId,FriendData]),
	#friend_info{friend_id = FriendId, nickname = FriendData#role_info_detail.nickname, status = FriendData#role_info_detail.status,
				 head = FriendData#role_info_detail.type, level = FriendData#role_info_detail.level,
				 public = FriendData#role_info_detail.public, battle_prop = make_battle_info(FriendData#role_info_detail.battle_prop),
				 potence_level = FriendData#role_info_detail.potence_level, advanced_level = FriendData#role_info_detail.advanced_level}.

make_friend_data(FriendData) ->
	#friend_data{nickname = FriendData#role_info_detail.nickname, status = FriendData#role_info_detail.status,
				 head = FriendData#role_info_detail.type, level = FriendData#role_info_detail.level,
				 public = FriendData#role_info_detail.public, battle_prop = make_battle_info(FriendData#role_info_detail.battle_prop),
				 potence_level = FriendData#role_info_detail.potence_level, advanced_level = FriendData#role_info_detail.advanced_level}.


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
    FriendSendHPStatus = redis_extend:get_send_hp_info(lists:concat([role,'_friends:',player:get_role_id()]),"friend:send_hp", player:get_role_id()),
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

    ComradeList = invitation_code:get_comrade_list(player:get_role_id()),
    FinalList2 = lists:map(
        fun(X) ->
            {_FriendID, MySendStatus, FriendSendStatus} = proplists:lookup(X#friend_info.friend_id, FriendSendHPStatus),
            FixMyStatus = case MySendStatus of
                              undefined ->
                                  ?send_hp_none;
                              MStatsus ->
                                  MStatsus
                          end,
            FixFriendStatus = case FriendSendStatus of
                                  undefined ->
                                      ?send_hp_none;
                                  FStatsus ->
                                      FStatsus
                              end,
            IsComrade = case lists:any(fun(E) -> E =:= X#friend_info.friend_id end, ComradeList) of
                            true ->
                                1;
                            false ->
                                0
                        end,
            X#friend_info{my_send_status = FixMyStatus, friend_send_status = FixFriendStatus, is_comrade = IsComrade}
        end,
        FinalList1),

    FinalList = lists:map(fun(X) ->
				  case proplists:lookup(X#friend_info.friend_id, FriendPids) of
				      {_, undefined}->
					  X#friend_info{status = ?offline};
				      _ ->
					  X#friend_info{status = ?online}
				  end
			  end, FinalList2),

    packet:send(#notify_friend_list{type=?init,friends=FinalList}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求留言列表
%% @end
%%--------------------------------------------------------------------
notify_msg_count() ->
    packet:send(#notify_leave_msg_count{count = length(get_msg_list())}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求留言列表
%% @end
%%--------------------------------------------------------------------
proc_req_msg_list(#req_msg_list{}) ->
    MsgList = get_msg_list(),
    clean_up_msg(),
    packet:send(#notify_msg_list{msg_list = MsgList}).


get_msg_list() ->
    CacheName = list_to_atom(lists:concat(['leave_messsage:', player:get_role_id()])),
    redis_extend:get_msg(CacheName).

clean_up_msg() ->
    CacheName = list_to_atom(lists:concat(['leave_messsage:', player:get_role_id()])),
    redis:del(CacheName).
%%--------------------------------------------------------------------
%% @doc
%% @spec发送信息
%% @end
%%--------------------------------------------------------------------
proc_send_chat_msg(#req_send_chat_msg{friend_id = FriendId, chat_msg = Msg}) ->
    io_helper:format("send:~p to:~p~n", [Msg, FriendId]),
    case role_pid_mapping:get_pid(FriendId) of
        undefined ->
            CacheName = list_to_atom(lists:concat(['leave_messsage:', FriendId])),
            redis_extend:insert_msg_and_return_amount(CacheName, #leave_msg{role_id = player:get_role_id(), msg = Msg}, 30),
            packet:send(#notify_send_chat_msg_result{result = ?common_success});
        Pid ->
            packet:send(Pid, #notify_receive_chat_msg{friend_id = player:get_role_id(), chat_msg = Msg}),
            packet:send(#notify_send_chat_msg_result{result = ?common_success})
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
    %%io:format("#########################################~nRoleId:~p online~n####################################~n", [RoleId]),
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
	    %%io:format("#########################################~nRoleId:~p offline~n#########################################~n", [RoleId]),
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
%%     Sculptures = lists:foldl(fun({Pos, TempId} ,In) ->
%% 				     lists:sublist(In,1,Pos-1) ++ [TempId] ++ lists:sublist(In,Pos+1,4)
%% 			     end,OrgInfo#role_info_detail.battle_prop#role_attr_detail.sculptures,UpdateList),
    CurInfo = OrgInfo#role_info_detail{battle_prop = OrgInfo#role_info_detail.battle_prop#role_attr_detail{sculptures=UpdateList}},
    roleinfo_manager:set_roleinfo(player:get_role_id(), CurInfo).
    %%cache:set(friend_info,player:get_role_id(),CurInfo).


set_myinfo_update()->
    OrgInfo = roleinfo_manager:get_roleinfo(player:get_role_id()),
    OrgPower = OrgInfo#role_info_detail.battle_prop#role_attr_detail.battle_power,
    OrgLev = OrgInfo#role_info_detail.level,
    AttrProp = battle_power:get_role_battle_prop(),
    Sculptures = OrgInfo#role_info_detail.battle_prop#role_attr_detail.sculptures,
    Equipments = equipment:get_equipments_on_body(player:get_role_id(), equipment:get_equipment(player_role:get_db_role(player:get_role_id()))),
    %%[Role] = db:find(db_role,[{role_id,'equals',player:get_role_id()}]),
    Role = player_role:get_db_role(player:get_role_id()),
    BattleProp = #role_attr_detail{sculptures = Sculptures, equipments = Equipments, life = AttrProp#battle_prop.life, speed = AttrProp#battle_prop.speed,
			      atk = AttrProp#battle_prop.atk, hit_ratio = AttrProp#battle_prop.hit_ratio,
			      miss_ratio = AttrProp#battle_prop.miss_ratio, critical_ratio = AttrProp#battle_prop.critical_ratio,
			      tenacity = AttrProp#battle_prop.tenacity, battle_power = AttrProp#battle_prop.power},
    
    CurInfo=#role_info_detail{status=?online,type=Role:role_type(),nickname=Role:nickname(),
			    level=Role:level(),public="test",battle_prop=BattleProp, potence_level = Role:potence_level(), advanced_level = Role:advanced_level(),
					mitigation = equipment:get_mitigation(Equipments)},
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
%% @spec  发送好友体力
%% @end
%%--------------------------------------------------------------------
proc_req_send_hp(#req_send_hp{friend_id = FirendID}) ->
    case check_can_send_hp(FirendID) of
        true ->
            update_my_send_hp_status(FirendID, ?send_hp_done),
            notify_send_hp_to_friend(FirendID),
            packet:send(#notify_send_hp_result{result = ?common_success, friend_id = FirendID});
        false ->
            sys_msg:send_to_self(?sg_friend_help_hp_has_send, []),
            packet:send(#notify_send_hp_result{result = ?common_failed})
    end.

check_can_send_hp(FirendID) ->
    case redis:sismember(lists:concat([role,'_friends:',player:get_role_id()]),FirendID) of
        1 ->
            get_send_hp_status(player:get_role_id(), FirendID) =:= ?send_hp_none;
        0 ->
            false
    end.

notify_send_hp_to_friend(FirendID) ->
    case role_pid_mapping:get_pid(FirendID) of
        undefined ->
            ok;
        Pid ->
            packet:send(Pid, #notify_get_hp_help_from_friend{friend_id = player:get_role_id()})
    end.

update_my_send_hp_status(ToID, Status) ->
    update_role_send_hp_status(player:get_role_id(), ToID, Status).

update_role_send_hp_status(FromID, ToID, Status) ->
    cache_with_expire:set("friend:send_hp", get_send_hp_key_name(FromID, ToID), Status, day).

get_send_hp_status(FromID, ToID) ->
    case redis:hget("friend:send_hp", get_send_hp_key_name(FromID, ToID)) of
        undefined ->
            ?send_hp_none;
        Status ->
            Status
    end.

get_send_hp_key_name(FromID, ToID) ->
    {Key,[]} = string:to_integer(lists:concat([FromID, ToID])),
    Key.

%%--------------------------------------------------------------------
%% @doc
%% @spec  获取好友体力
%% @end
%%--------------------------------------------------------------------
proc_req_reward_hp_from_friend(#req_reward_hp_from_friend{friend_id = FirendID}) ->
    case check_get_reward_hp(FirendID) of
        true ->
            RewardHP = config:get(friend_send_hp_amount),
            power_hp:add_power_hp(?st_send_hp_from_friend, RewardHP),
            update_role_send_hp_status(FirendID, player:get_role_id(), ?send_hp_got),
            packet:send(#notify_reward_hp_from_friend_result{result = ?common_success, friend_id = FirendID});
        false ->
            packet:send(#notify_reward_hp_from_friend_result{result = ?common_failed})
    end.

check_get_reward_hp(FirendID) ->
    get_send_hp_status(FirendID, player:get_role_id()) =:= ?send_hp_done.

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
    
