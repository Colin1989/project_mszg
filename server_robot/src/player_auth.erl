
%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%
%%% @end
%%% Created : 30 Oct 2013 by linyibin <>1
%%%-------------------------------------------------------------------
-module(player_auth).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").

-define(account_status_normal, 1).

-export([call/1, start/0]).
-compile(export_all).

-define(role_status_normal, 1).
-define(role_status_del, 2).
-define(role_status_radical_del, 3).

start()->
    packet:register(?msg_req_reselect_role, {?MODULE, proc_req_reselect_role}),
    ok.


proc_req_reselect_role(#req_reselect_role{})->
    UserId = player:get_player_id(),
    Roles = get_db_role_info(UserId),
    [User] = db:find(db_user, [{user_id,'equals', UserId}]),
    RoleInfos = lists:map(fun({X, DelCase})-> 
				  {Status, TimeLeft} = case DelCase of
							   false ->
							       {2, 0};
							   {true, L} ->
							       {1, L}
						       end,
				  #role_data{role_id = X:role_id(), type = X:role_type(), 
					     lev = X:level(), name = X:nickname(),is_del = Status,
					     time_left = TimeLeft}
			  end, Roles),
    packet:send(#notify_roles_infos{role_infos = RoleInfos, emoney = User:emoney()}),
    %%io:format("self:~p~n", [self()]),
    gen_server:cast(self(), {reselect_role}),
    ok.
%--------------------------------------------------------------------
%% @doc
%% @spec版本检测
%% @end
%%--------------------------------------------------------------------
call({?msg_req_check_version, #req_check_version{version = Version}})->
    case Version == ?proto_ver of 
	true ->
	    packet:send(self(), #notify_check_version_result{result=?common_success});
	false ->
	    packet:send(self(), #notify_check_version_result{result=?common_failed}),
	    sys_msg:send(self(), ?sg_login_version_error, [integer_to_list(?proto_ver)])
    end,
    {next_state, wait_for_auth};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   对接
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
call({?msg_req_login_check, #req_login_check{uid = Uid, token = Token}})->
    {obj, ResponseList} = http_client:request_with_jason_encode([{app_id, config:get_server_config(app_id)}, 
								 {app_key, config:get_server_config(app_key)}, {token, Token}, {uid, Uid}]),
    %%io:format("ResponseList:~p~n", [ResponseList]),
    case proplists:get_value("success", ResponseList) of
	true ->
	    User = get_db_user_by_userid(list_to_integer(Uid)),
	    has_login(User:user_id()),
	    init_player_info(User),
	    try 
		Roles = get_db_role_info(User:user_id()),
		RoleInfos = lists:map(fun({X, DelCase})-> 
					      {Status, TimeLeft} = case DelCase of
								       false ->
									   {2, 0};
								       {true, L} ->
									   {1, L}
								   end,
					      #role_data{role_id = X:role_id(), type = X:role_type(), 
							 lev = X:level(), name = X:nickname(),is_del = Status,
						     time_left = TimeLeft}
				  end, Roles),
		packet:send(self(), #notifu_login_check_result{result = ?common_success, emoney = User:emoney(),
						     role_infos = RoleInfos}),
		redis:hset("player_tokens", User:user_id(), Token)
		%%io:format("~p",[RoleInfos]),
	    
	    catch
		_:_ ->
		    packet:send(self(), #notifu_login_check_result{result = ?common_failed})
	    end;
	false ->
	    packet:send(self(), #notifu_login_check_result{result = ?common_error, 
							   error_code = list_to_integer(binary_to_list(proplists:get_value("code", ResponseList)))})
    end,
    {next_state, wait_for_auth};





%--------------------------------------------------------------------
%% @doc
%% @spec登录
%% @end
%%--------------------------------------------------------------------
call({?msg_req_login, #req_login{account = Account} = Packet})->
    case login_check(Packet) of
	{?login_norole, UserId}->
	    packet:send(self(), #notify_login_result{result = ?login_norole, id=UserId}),
	    {next_state, wait_for_auth};
	ErrorCode when is_integer(ErrorCode)  ->
	    packet:send(self(), #notify_login_result{result = ErrorCode}),
	    {next_state, wait_for_auth};
	Roles ->
	    [{Role,_}|_] = Roles,
	    User = get_db_user_info(Account),
	    RoleInfos = lists:map(fun({X, DelCase})-> 
					  {Status, TimeLeft} = case DelCase of
								   false ->
								       {2, 0};
								   {true, L} ->
								       {1, L}
							       end,
					  #role_data{role_id = X:role_id(), type = X:role_type(), 
						     lev = X:level(), name = X:nickname(),is_del = Status,
						     time_left = TimeLeft}
				  end, Roles),
	    packet:send(self(), #notify_login_result{result = ?login_success, id=Role:user_id(), emoney = User:emoney(),
						     role_infos = RoleInfos}),
	    %%io:format("~p",[RoleInfos]),
	    {next_state, wait_for_auth}
	    %% {ok, Pid} = player:start_link(self(), Role:user_id(), Role),
	    %% put(player_pid, Pid),
	    %% {next_state, wait_for_data}
    end;



call({?msg_req_select_role, #req_select_role{role_id = RoleId} = Packet})->
    io_helper:format("~p~n", [Packet]),
    Roles = db:find(db_role,[{user_id,'equals',player:get_player_id()}]),
    case lists:filter(fun(X) -> X:role_id() =:= RoleId end, Roles) of
	[] ->
	    sys_msg:send(self(), ?sg_select_role_roleid_err, []),
	    packet:send(self(), #notify_select_role_result{result = ?common_failed}),
	    {next_state, wait_for_auth};
	[Role] ->
	    case Role:status() of
		?role_status_normal ->
		    packet:send(self(), #notify_select_role_result{result = ?common_success}),
		    {ok, Pid} = player:start_link(self(), Role:user_id(), Role),
		    put(player_pid, Pid),
		    {next_state, wait_for_data};
		_ ->
		    sys_msg:send(self(), ?sg_select_role_already_del, []),
		    packet:send(self(), #notify_select_role_result{result = ?common_failed}),
		    {next_state, wait_for_auth}
	    end
    end;


call({?msg_req_delete_role, #req_delete_role{role_id = RoleId} = Packet})->
    io_helper:format("~p~n", [Packet]),
    Roles = get_db_role_info(player:get_player_id()),%%db:find(db_role,[{user_id,'equals',player:get_player_id()}]),
    %% RoleInfos = lists:map(fun({X, DelCase})-> 
    %% 					  {Status, TimeLeft} = case DelCase of
    %% 								   false ->
    %% 								       {2, 0};
    %% 								   {true, L} ->
    %% 								       {1, L}
    %% 							       end,
    %% 					  #role_data{role_id = X:role_id(), type = X:role_type(), 
    %% 						     lev = X:level(), name = X:nickname(),is_del = Status,
    %% 						     time_left = TimeLeft}
    %% 				  end, Roles),
    case lists:filter(fun({X, _}) -> X:role_id() =:= RoleId end, Roles) of
	[] ->
	    sys_msg:send(self(), ?sg_del_role_roleid_err, []),
	    packet:send(self(), #notify_delete_role_result{result = ?common_failed});
	[{Role, _}] ->
	    case Role:status() =:= ?role_status_normal of
		true ->
		    process_delete_role(Roles, Role),
		    packet:send(self(), #notify_delete_role_result{result = ?common_success});
		false ->
		    sys_msg:send(self(), ?sg_del_role_already_del, []),
		    packet:send(self(), #notify_delete_role_result{result = ?common_failed})
	    end,
	    %% {ok, Pid} = player:start_link(self(), Role:user_id(), Role),
	    %% put(player_pid, Pid),
	    {next_state, wait_for_auth}
    end;

call({?msg_req_recover_del_role, #req_recover_del_role{role_id = RoleId} = Packet})->
    io_helper:format("~p~n", [Packet]),
    Roles = db:find(db_role,[{user_id,'equals',player:get_player_id()}]),
    case lists:filter(fun(X) -> X:role_id() =:= RoleId end, Roles) of
	[] ->
	    sys_msg:send(self(), ?sg_recover_role_roleid_err, []),
	    packet:send(self(), #notify_recover_del_role_result{result = ?common_failed});
	[Role] ->
	    case Role:status() =:= ?role_status_del of
		true ->
		    Price = config:get(recover_del_role_price),
		    case player_role:check_emoney_enough(Price) of
			true ->
			    MaxRoleAmount = config:get(max_role_amount),
			    case length(lists:filter(fun(X) ->X:status() =:= ?role_status_normal end, Roles)) of
				Rcount when Rcount >= MaxRoleAmount ->
				    sys_msg:send(self(), ?sg_recover_role_amount_exceeded, []),
				    packet:send(self(), #notify_recover_del_role_result{result = ?common_failed});
				_ ->
				    NewRole = Role:set([{status, ?role_status_normal}]),
				    player_role:save_my_db_role(NewRole),
				    player:set_role_id(RoleId),
				    player_role:reduce_emoney(?st_recover_del_role, Price),
				    cache:delete(role_del_time, RoleId),
				    packet:send(self(), #notify_recover_del_role_result{result = ?common_success})
			    end;
			false  ->
			    sys_msg:send(self(), ?sg_recover_role_emoney_not_enough, []),
			    packet:send(self(), #notify_recover_del_role_result{result = ?common_failed})
		    end;
		false ->
		    case  Role:status() of
			?role_status_normal ->
			    sys_msg:send(self(), ?sg_recover_role_status_normal, []),
			    packet:send(self(), #notify_recover_del_role_result{result = ?common_failed});
			?role_status_radical_del ->
			    sys_msg:send(self(), ?sg_recover_role_status_remove, []),
			    packet:send(self(), #notify_recover_del_role_result{result = ?common_failed})
		    end
		    
	    end,
	    %% {ok, Pid} = player:start_link(self(), Role:user_id(), Role),
	    %% put(player_pid, Pid),
	    {next_state, wait_for_auth}
    end;






%--------------------------------------------------------------------
%% @doc
%% @spec注册
%% @end
%%--------------------------------------------------------------------
call({?msg_req_register, #req_register {account=Account,channelid=ChannelId,password=Password,platformid=PlatformId} = Packet})->
    io_helper:format("proc req login: Packet:~p~n", [Packet]),
    case has_registered(Account) of
	false->
	    sys_msg:send(self(), ?sg_register_account_exist, []),
	    packet:send(self(), #notify_register_result{result=?register_failed});
	Id-> 
	    NewAccount=db_account_userid_mapping:new(id,Account,Id,datetime:local_time()),
	    NewAccount:save(),
	    NewUser=db_user:new( id,Id,?account_status_normal,Password,ChannelId,PlatformId,config:get(init_emoney),datetime:local_time()),
	    NewUser:save(),
	    Pack2=#notify_register_result{result=?register_success},
	    packet:send(self(), Pack2)
    end,
    {next_state, wait_for_auth};




%--------------------------------------------------------------------
%% @doc
%% @spec请求创建角色
%% @end
%%--------------------------------------------------------------------
call({?msg_req_create_role, #req_create_role{roletype=RoleType,nickname=NickName}=Packet})->
    io_helper:format("proc req create role: Packet:~p,NameLength:~p~n", [Packet, length(NickName)]),
    PlayerID=player:get_player_id(),
    case create_role_check(PlayerID, Packet) of
	ErrorCode when is_integer(ErrorCode) ->
	    packet:send(self(), #notify_create_role_result{result=ErrorCode}),
	    {next_state, wait_for_auth};
	true ->
	    process_create_role(PlayerID, RoleType, NickName),
	    {next_state, wait_for_data}
    end;




%--------------------------------------------------------------------
%% @doc
%% @spec断线重连
%% @end
%%--------------------------------------------------------------------
call({?msg_req_game_reconnect, #req_game_reconnect{uid=Uid, token=Token, role_id = RoleId}})->
    %%PlayerInfo = get_db_user_info(Account),
    %% PlayerInfo = get_db_user_by_userid(list_to_integer(Uid)),
    %% has_login(PlayerInfo:user_id()),
    %% case PlayerInfo:password() of
    %% 	Password ->
    %% 	    init_player_info(PlayerInfo),
    %% 	    case lists:filter(fun(X) -> X:role_id() =:= RoleId end,db:find(db_role,[{user_id,'equals',PlayerInfo:user_id()}])) of
    %% 		RoleList when length(RoleList)>=1->
    %% 		    packet:send(self(), #notify_reconnect_result{result=?reconnect_success,id=PlayerInfo:user_id()}),
    %% 		    [Role]=RoleList,
    %% 		    {ok, Pid} = player:start_link(self(), PlayerInfo:user_id(), Role),
    %% 		    put(player_pid, Pid)
    %% 	    end,
    %% 	    {next_state, wait_for_data};
    %% 	_ ->
    %% 	    packet:send(self(), #notify_reconnect_result{result=?reconnect_passworderror}),
    %% 	    sys_msg:send(self(), ?sg_login_passward_error, []),
    %% 	    {next_state, wait_for_auth}
    %% end.
    case redis:hget(player_tokens, list_to_integer(Uid)) of
	Token ->
	    PlayerInfo = get_db_user_by_userid(list_to_integer(Uid)),
	    has_login(PlayerInfo:user_id()),
	    init_player_info(PlayerInfo),
    	    case lists:filter(fun(X) -> X:role_id() =:= RoleId end,db:find(db_role,[{user_id,'equals',PlayerInfo:user_id()}])) of
    		RoleList when length(RoleList)>=1->
    		    packet:send(self(), #notify_reconnect_result{result=?reconnect_success,id=PlayerInfo:user_id()}),
    		    [Role]=RoleList,
    		    {ok, Pid} = player:start_link(self(), PlayerInfo:user_id(), Role),
    		    put(player_pid, Pid)
    	    end,
    	    {next_state, wait_for_data};
	_ ->
	    packet:send(self(), #notify_reconnect_result{result=?common_failed}),
	    sys_msg:send(self(), ?sg_reconnect_token_err, []),
	    {next_state, wait_for_auth}
    end.



%% check_role_del(Role)->
%%     case Role:status() of
%% 	?role_status_normal ->

%%     end
%%     case cache:get(role_del_time, Role:role_id()) of
%% 	[] ->
%% 	    false;
%% 	[{_, Time}] ->
%% 	    TimePass = datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(Time),
%% 	    MaxLeft = 86400 * 7,
%% 	    TimeLeft = case MaxLeft - TimePass of
%% 			   L when L < 0  ->
%% 			       0;
%% 			   L2 ->
%% 			       L2
%% 		       end,
%% 	    {true, TimeLeft}
%%     end.
get_role_radical_del_time(RoleId)->
    MaxLeft = config:get(remind_del_role_time),
    case cache:get(role_del_time, RoleId) of
	[] ->
	    cache:set(role_del_time,RoleId, erlang:localtime()),
	    MaxLeft;
	[{_, Time}] ->
	    TimePass = datetime:datetime_to_gregorian_seconds(erlang:localtime()) - datetime:datetime_to_gregorian_seconds(Time),
	    TimeLeft = case MaxLeft - TimePass of
			   L when L < 0  ->
			       0;
			   L2 ->
			       L2
		       end,
	    TimeLeft
    end.


process_delete_role(Roles, Role) ->
    DelRoles = lists:filter(fun({NRole, _}) -> 
				     NRole:status() =:= ?role_status_del
			     end, Roles),
    DelAmount = length(DelRoles),
    case DelAmount >= 4 of
	true ->
	    lists:keysort(2, DelRoles),
	    radical_del_role(DelAmount - 4 + 1, DelRoles);
	false ->
	    ok
    end,
    NewRole = Role:set([{status,?role_status_del}]),
    player_role:save_my_db_role(NewRole),
    cache:set(role_del_time, Role:role_id(), erlang:localtime()).

radical_del_role(Amount, DelRoles)->
    case Amount =<0  of
	true ->
	    ok;
	false ->
	    [{DelRole, _}|RolesLeft] = DelRoles,
	    cache:delete(role_del_time, DelRole:role_id()),
	    NewRole = DelRole:set([{status, ?role_status_radical_del}]),
	    player_role:save_my_db_role(NewRole),
	    radical_del_role(Amount - 1, RolesLeft)
    end.

%--------------------------------------------------------------------
%% @doc
%% @spec创建角色的校验
%% @end
%%--------------------------------------------------------------------

create_role_check(PlayerId, #req_create_role{roletype=_RoleType,nickname=NickName})->
    try
	is_name_existed(NickName),
	is_player_login(PlayerId),
	is_role_amount_exceeded(PlayerId),
	true
    catch
	throw:{create_role_error, Result}->
	    Result
    end.




%--------------------------------------------------------------------
%% @doc
%% @spec创建角色
%% @end
%%--------------------------------------------------------------------
process_create_role( PlayerID, RoleType, NickName)->
    RoleTplt = tplt:get_data(role_tplt,RoleType),
    RoleID = uuid:gen(),
    Skill1 = RoleTplt#role_tplt.skill1,
    Skill2 = RoleTplt#role_tplt.skill2,
    rand:seed(now()),
    ArmorItem = equipment:create_equipment_and_save(RoleTplt#role_tplt.armor,uuid:gen(),RoleID),
    WeaponItem = equipment:create_equipment_and_save(RoleTplt#role_tplt.weapon,uuid:gen(),RoleID),
    Sculpture = sculpture_pack:create_sculpture_and_save(?st_create_role, RoleTplt#role_tplt.init_sculpture, uuid:gen(), RoleID),
    Role = player_role:create(RoleID, NickName, PlayerID, RoleType, ArmorItem:equipment_id(), 
			      WeaponItem:equipment_id(), Skill1, Skill2 ,Sculpture:sculpture_id()),
    packet:send(self(), #notify_create_role_result{result=?create_role_success}),
    %%io:format("&&&&&&&&&&&&&&&&&&&&&&&&&&&&~p~n", [Role]),
    {ok, Pid} = player:start_link(self(), Role:user_id(), Role),
    put(player_pid, Pid).




%--------------------------------------------------------------------
%% @doc
%% @spec角色名是否存在
%% @end
%%--------------------------------------------------------------------
is_name_existed(NickName)->
    case db:find(db_role,[{nickname,'equals',NickName}]) of
	[] ->
	    
	    false;
	_ ->
	    sys_msg:send(self(), ?sg_create_role_name_exist, []),
	    throw({create_role_error, ?create_role_nameexisted})
    end.




%--------------------------------------------------------------------
%% @doc
%% @spec是否登录，登录后才能创建角色
%% @end
%%--------------------------------------------------------------------
is_player_login(PlayerId)->
    case PlayerId of
	undefined ->
	    sys_msg:send(self(), ?sg_create_role_not_login, []),
	    throw({create_role_error, ?create_role_nologin});
	_ ->
	    true
    end.




%--------------------------------------------------------------------
%% @doc
%% @spec角色数量是否越界
%% @end
%%--------------------------------------------------------------------
is_role_amount_exceeded(PlayerId)->
    MaxAmount = config:get(max_role_amount),
    Roles = db:find(db_role, [{user_id, 'equals', PlayerId}]),
    
    case length(lists:filter(fun(X) -> X:status() =:= ?role_status_normal end, Roles)) of
	Count when Count < MaxAmount ->
	    false;
	_ ->
	    sys_msg:send(self(), ?sg_create_role_amount_exceeded, []),
	    throw({create_role_error, ?create_role_failed})
    end.




%%--------------------------------------------------------------------
%% @doc
%% @spec登录校验
%% @end
%%--------------------------------------------------------------------
login_check(#req_login{account = Account, password = Password} = Packet)->
    io_helper:format("recv:~p~n",[Packet]),
    try
	UserInfo = get_db_user_info(Account),
	password_check(UserInfo, Password),
	has_login(UserInfo:user_id()),
	init_player_info(UserInfo),
	get_db_role_info(UserInfo:user_id())
    catch
	throw:{login_error, Result}->
	    Result
    end.




%--------------------------------------------------------------------
%% @doc
%% @spec初始化信息
%% @end
%%--------------------------------------------------------------------

init_player_info(UserInfo)->
    rand:seed(now()),
    player:set_player_id(UserInfo:user_id()),
    account_pid_mapping:mapping(UserInfo:user_id(),self()).





%--------------------------------------------------------------------
%% @doc
%% @spec获取玩家信息
%% @end
%%--------------------------------------------------------------------
get_db_user_info(Account)->
    case db:find(db_account_userid_mapping,[{account_id,'equals',Account}]) of
	[] ->
	    sys_msg:send(self(), ?sg_login_no_register, []),
	    throw({login_error, ?login_noregister}); 
	[AccountInfo] ->
	    UserId = AccountInfo:user_id(),
	    [UserInfo]=db:find(db_user,[{user_id,'equals',UserId}]),
	    case UserInfo:account_status() of
		?account_status_normal ->
		    UserInfo;
		_ ->
		    sys_msg:send(self(), ?sg_login_status_err, []),
		    throw({login_error, ?login_status_err})
	    end
    end.



get_db_user_by_userid(UserId) ->
    case db:find(db_user, [{user_id, 'equals', UserId}]) of
	[] ->
	    NewUser=db_user:new(id, UserId, ?account_status_normal, "", 0, 0, config:get(init_emoney), datetime:local_time()),
	    {ok, User} = NewUser:save(),
	    User;
	[User] ->
	    User
    end.





%%--------------------------------------------------------------------
%% @doc
%% @spec获取角色信息
%% @end
%%--------------------------------------------------------------------
get_db_role_info(UserId)->
    case db:find(db_role,[{user_id,'equals',UserId}]) of
	[] ->
	    throw({login_error, {?login_norole, UserId}});
	Roles ->
	    RoleLeft = lists:filter(fun(X) -> 
					    X:status() =/= ?role_status_radical_del
				    end, Roles),
	    NewRoles = lists:map(fun(X) -> 
					 case X:status() of
					     ?role_status_normal ->
						 {X, false};
					     ?role_status_del ->
						 {X, {true, get_role_radical_del_time(X:role_id())}}
					 end
				 end, RoleLeft),
	    case lists:filter(fun({X, DelCase}) -> 
				      case DelCase of
					  false ->
					      true;
					  {true, Left} ->
					      case Left =:= 0 of
						  true ->
						      cache:delete(role_del_time, X:role_id()),
						      NewRole = X:set([{status, ?role_status_radical_del}]),
						      player_role:save_my_db_role(NewRole);
						  false ->
						      ok
					      end,
					      Left =/= 0
				      end
			      end, NewRoles) of
		[] ->
		    throw({login_error, {?login_norole, UserId}});
		Rs ->
		    Rs
	    end
    end.




%%--------------------------------------------------------------------
%% @doc
%% @spec密码验证
%% @end
%%--------------------------------------------------------------------
password_check(UserInfo, Password)->
    case UserInfo:password() of
	Password ->
	    true;
	_ ->
	    sys_msg:send(self(), ?sg_login_passward_error, []),
	    throw({login_error, ?login_passworderror})
    end.



%%--------------------------------------------------------------------
%% @doc
%% @spec检测玩家是否已注册
%% has_registered(Account::string)->result::atom()|Uuid::uint64
%% @end
%%--------------------------------------------------------------------
has_registered(Account)->
    case db:find(db_account_userid_mapping,[{account_id,'equals',Account}]) of
	[]->
	    uuid:gen();
	_->
	    false
    end.



%%--------------------------------------------------------------------
%% @doc
%% @spec检测玩家是否已登录
%% has_login(PlayerId::uint64)->result::atom()|Uuid::uint64
%% @end
%%--------------------------------------------------------------------
has_login(PlayerId)->
    %%io:format("~p~n",[PlayerId]),
    case account_pid_mapping:has_mapped(PlayerId) of
	false->
	    false;
	TcpPid->
	    %%io:format("~p~n",[TcpPid]),
	    case erlang:is_process_alive(TcpPid) of
		true ->
		    io_helper:format("TcpPid:~p,self():~p~n", [TcpPid, self()]),
		    sys_msg:send(TcpPid,?sg_login_repeat_login,[]),
		    gen_fsm:sync_send_event(TcpPid,repeat_login_stop);
		false->
		    ok
	    end,
	    true
    end.



%%Role = role:new(id, uuid:gen(), "111111", "test", 1, calendar:local_time()),
%%io_helper:format("Role:~p~n", [Role]),
%%Role:save(),

%%Pack = #notify_login_result{result=1, nick_name="hello", sex = 1},
%%packet:send(Pack),

%%Pid = erlang:get(tcpid),
%%account_pid_mapping:mapping(Account, Pid),
%%ok.

%% proc_req_register(#req_register{account=Account,channelid=ChannelId,password=Password,platformid=PlatformId}=Packet)->
%%     io_helper:format("proc req login: Packet:~p~n", [Packet]),
%%     case has_registered(Account) of
%% 	false->
%% 	    Pack=#notify_register_result{result=?register_failed},
%% 	    packet:send(Pack);
%% 	Id-> 
%% 	    NewAccount=db_account_userid_mapping:new(id,Account,Id,datetime:local_time()),
%% 	    NewAccount:save(),
%% 	    NewUser=db_user:new(id,Id,Password,ChannelId,PlatformId,datetime:local_time()),
%% 	    %%try NewRole:save(),
%% 	    NewUser:save(),
%% 	    Pack2=#notify_register_result{result=?register_success},
%% 	    packet:send(Pack2)
%% 	    %%catch
%% 	    %%	_->Pack3=#req_register_result{result=2},
%% 	    %%		packet:send(Pack3)
%% 	    %%end
%%     end.




%% proc_req_create_role(#req_create_role{roletype=RoleType,nickname=NickName}=Packet)->
%%     io_helper:format("proc req login: Packet:~p~n", [Packet]),
%%     PlayerID=player:get_player_id(),
%%     case db:find(db_role,[{nickname,'equals',NickName}]) of
%% 	[]->

%% 	    case PlayerID of
%% 		undefined->
%%  		    Pack3=#notify_create_role_result{result=?create_role_nologin},
%% 		    packet:send(Pack3);
%% 		_ ->
%% 		    %%UserKey = db:generate_key("db_user", PlayerID),
%% 		    case db:count(db_role,[{user_id, 'equals', PlayerID}]) of
%% 			0->
%% 			    RoleTplt = tplt:get_data(role_tplt,RoleType),
%% 			    RoleID = uuid:gen(),
%% 			    Skill1 = RoleTplt#role_tplt.skill1,
%% 			    Skill2 = RoleTplt#role_tplt.skill2,
%% 			    rand:seed(now()),
%% 			    ArmorItem = equipment:create_equipment_and_save(RoleTplt#role_tplt.armor,uuid:gen(),RoleID),
%% 			    WeaponItem = equipment:create_equipment_and_save(RoleTplt#role_tplt.weapon,uuid:gen(),RoleID),
%% 			    Sculpture = sculpture:create_sculpture_and_save(RoleTplt#role_tplt.init_sculpture, uuid:gen(), RoleID),
%% 			    Role = player_role:create(RoleID, NickName, PlayerID, RoleType, ArmorItem:equipment_id(), 
%% 						      WeaponItem:equipment_id(), Skill1, Skill2 ,Sculpture:sculpture_id()),
%% 			    Pack1=#notify_create_role_result{result=?create_role_success},
%% 			    packet:send(Pack1),
%% 			    player:set_role_id(RoleID),
%% 			    PlayerPack=player_pack:transform_items(player_pack:get_my_pack(),[]),
%% 			    packet:send(#notify_player_pack{type=?init,pack_items=PlayerPack}),
%% 			    player_role:notify_role_info(Role),
%% 			    role_pid_mapping:mapping(RoleID,get(tcpid)),
%% 			    assistance:insert_role_info(RoleID),
%% 			    %% 提前发符文实例信息给客户端
%% 			    sculpture:proc_req_sculpture_infos(#req_sculpture_infos{}),
%% 			    task:proc_req_task_infos(#req_task_infos{}),

%% 			    equipment:proc_equipment_infos(#req_equipment_infos{});
			    
%% 			_->
%% 			    Pack5=#notify_create_role_result{result=?create_role_failed},
%% 			    packet:send(Pack5)
%% 		    end

%% 	    end;
%% 	_ ->
%% 	    Pack4=#notify_create_role_result{result=?create_role_nameexisted},
%% 	    packet:send(Pack4)
%%     end.
%%--------------------------------------------------------------------
%% @doc
%% @spec用于生成uuid，不重复
%% has_registered(Account::string)->result::atom()|Uuid::uint64
%% @end
%%--------------------------------------------------------------------
%%get_id(RetryTimes)->
%%	Uuid=uuid:gen(),
%%	case db:find("db_role-"++integer_to_list(Uuid)) of
%%		undefined->
%%			Uuid;
%%		_->
%%			if 
%%				RetryTimes>0 ->
%%					get_id(RetryTimes-1);
%%			true->
%%					failtogetid
%%			end
%%



    

%%--------------------------------------------------------------------
%% @doc
%% @spec处理登录请求
%% @end
%%--------------------------------------------------------------------
%% proc_req_login(Packet)->
%%     io_helper:format("proc req login: Packet:~p~n", [Packet]),
%%     case login_check(Packet) of
%% 	{?login_norole, UserId}->
%% 	    packet:send(#notify_login_result{result = ?login_norole, id=UserId});
%% 	?login_noregister ->
%% 	    packet:send(#notify_login_result{result = ?login_noregister}),
%% 	    sys_msg:send_to_self(?login_msg_noregister, []);
%% 	?login_passworderror ->
%% 	    packet:send(#notify_login_result{result = ?login_passworderror});
%% 	Role ->
%% 	    process_login(Role),
%% 	    packet:send(#notify_login_result{result = ?login_success, id=Role:user_id()})
%%     end.
%%--------------------------------------------------------------------
%% @doc
%% @spec数据校验合法后处理登录
%% @end
%%--------------------------------------------------------------------
%% process_login(Role)->
%%     RoleId=Role:role_id(),
%%     %%player:set_role_id(RoleId),
%%     %%role_pid_mapping:mapping(RoleId,get(tcpid)),
%%     PlayerPack=player_pack:transform_items(player_pack:get_my_pack(),[]),
%%     packet:send(#notify_player_pack{type=?init,pack_items=PlayerPack}),
%%     player_role:notify_role_info(Role),
%%     friend:role_online_update(),
%%     sculpture:proc_req_sculpture_infos(#req_sculpture_infos{}),
%%     task:proc_req_task_infos(#req_task_infos{}),
%%     equipment:proc_equipment_infos(#req_equipment_infos{}),
%%     assistance:insert_role_info(RoleId),
%%     packet:send(#notify_be_challenged_times{times=challenge:get_be_challenge_amount()}).




