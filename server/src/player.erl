
%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%%
%%% @end
%%% Created : 29 Oct 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(player).
-include("enum_def.hrl").
-behaviour(gen_server).

%% API
-export([start_link/4, start_link/5]).
-export([set_player_id/1, get_player_id/0, get_player_id/1,set_role_id/1,get_role_id/0]).
 
%% gen_server callbacks

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

-include("packet_def.hrl").

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec设置玩家的ID
%% setPlayerID(PlayerId::uint64)->undefined::atom()|PlayerId::uint64
%% @end
%%--------------------------------------------------------------------
set_player_id(PlayerId)->
    put(playerid,PlayerId).

%%--------------------------------------------------------------------
%% @doc
%% @spec获得玩家的ID
%% getPlayerID()->result::atom()|PlayerID::uint64
%% @end
%%--------------------------------------------------------------------
get_player_id()->
    get(playerid).

get_player_id(RoleID) ->
    Role = player_role:get_role_info_by_roleid(RoleID),
    Role:user_id().

%%--------------------------------------------------------------------
%% @doc
%% @spec设置玩家的角色ID
%% set_role_id(RoleId::uint64)
%% @end
%%--------------------------------------------------------------------
set_role_id(RoleId)->
    put(roleid,RoleId).

%%--------------------------------------------------------------------
%% @doc
%% @spec获得玩家的角色ID
%% get_role_id()->undefined::atom()|RoleID::uint64
%% @end
%%--------------------------------------------------------------------
get_role_id()->
    get(roleid).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link(TcpPid) -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(TcpPid, PlayerId, Role, User) ->
    Ip = get(ip),
    gen_server:start_link(?MODULE, [TcpPid, PlayerId, Role, Ip, User], []).


start_link(TcpPid, PlayerId, Role, User, not_notify) ->
    Ip = get(ip),
    gen_server:start_link(?MODULE, [TcpPid, PlayerId, Role, Ip, User, not_notify], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([TcpPid, PlayerId, Role, Ip, User]) ->
    put(my_user_info, User),
    put(ip,Ip),
    process_flag(trap_exit, true),
    put(tcpid, TcpPid),
    rand:seed(now()),
    set_player_id(PlayerId),
    set_role_id(Role:role_id()),
    role_pid_mapping:mapping(Role:role_id(), TcpPid),
    role_pid_mapping:map_player_pid(Role:role_id(), self()),
	account_pid_mapping:map_player_pid(User:user_id(), self()),
	%%PlayerPack=player_pack:transform_items(player_pack:get_my_pack(),[]),
    %%packet:send(#notify_player_pack{type=?init,pack_items=PlayerPack}),
    player_pack:notify_init_player_pack(),
    daily_award:notify_sys_time(),
    friend:role_online_update(),
    friend:notify_makefriend_reqs_amount(),
    player_role:notify_role_info(Role),
    tutorial:notify_tutorial_progress(),
    sculpture_pack:notify_sculpture_infos(),
    task:proc_req_task_infos(#req_task_infos{}),
    equipment:proc_equipment_infos(#req_equipment_infos{}),
    assistance:insert_role_info(Role:role_id()),
    packet:send(#notify_be_challenged_times{times=challenge:get_be_challenge_amount()}),
    player_role:role_online(),
    %%challenge:update_honour(Role:honour()),
    military_rank:notify_military_rank_info(),
    daily_award:notify_daily_award_info(),
    summon_stone:notify_summon_stone_info(),
    activeness_task:notify_today_activeness_task(),
    benison:notify_benison_buff(),
    upgrade_task:notify_upgrade_task_rewarded_list(),
    assistance:notify_assistance_info(),
    online_award:notify_online_award_info(),
    alchemy:notify_alchemy_info(),
    mail:notify_email_list(),
    first_charge_reward:notify_first_charge_info(),
    vip:notify_vip_rewarded_info(),
    friend:notify_msg_count(),
    mooncard:proc_notify_mooncard_info(),
    invitation_code:notify_invite_code_info(),
    activity_copy:proc_notify_activity_copy_info(),
    chat:notify_notify_my_world_chat_info(),
    summon_stone:notify_boss_copy_fight_time(),
    sculpture:notify_divine_info(),
    talent:talent_login_init(), %%天赋信息信息推送
    sculpture:notify_skill_groups_info(),
    time_limit_reward:notify_rewarded_list(),
    %%ladder_match:notify_ladder_match_info(),
    notice:notify_list(),
    talent:unlock(1),
    activities:init_notify(),
    chat:notify_world_msg(TcpPid),
    equipment:send_medal_exchange_item(),
    {ok, #state{}};



init([TcpPid, PlayerId, Role, Ip, User, not_notify]) ->
    put(my_user_info, User),
    put(ip,Ip),
    process_flag(trap_exit, true),
    put(tcpid, TcpPid),
    rand:seed(now()),
    set_player_id(PlayerId),
    set_role_id(Role:role_id()),
    role_pid_mapping:mapping(Role:role_id(), TcpPid),
    role_pid_mapping:map_player_pid(Role:role_id(), self()),
    account_pid_mapping:map_player_pid(User:user_id(), self()),
    sculpture_pack:get_my_sculpture(),
    player_pack:get_my_pack(),
    sculpture_pack:get_my_sculpture(),
    friend:role_online_update(),
    assistance:insert_role_info(Role:role_id()),
    player_role:role_online(),
    
    online_award:notify_online_award_info(),
    {ok, #state{}}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({tcp_closed},_From,State)->
    %%put(is_repeat,true),
    %%gen_server:reply(_From, ok),
    {stop, normal, State};


handle_call({from_service, Packet}, _From, State) ->
    {Type, _Binary} = protocal:encode(Packet),
    Reply = packet:router({Type, {server, Packet}}),
    {reply, Reply, State};

handle_call({reget, roleinfo}, _From, State) ->
    case get_role_id() of
	undefined ->
	    ok;
	RoleId ->
	    player_role:reget_role_info(RoleId)
    end,
    {reply, ok, State};




handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast({packet, Packet}, State) ->
    packet:router(Packet),
    {noreply, State};
handle_cast({reselect_role, User},State)->
    %%put(is_repeat,true),
    %%gen_server:reply(_From, ok),
    %% Result = supervisor:terminate_child(get(tcpid), self()),
    %% io:format("Result:~p", [Result]),
    %%exit(self(),kill),
    %%put(reselect_role, true),
    {stop, {shutdown, {reselect_role, User}}, State};
    %%{noreply, State};
handle_cast(Msg, State) ->
    io_helper:format("player handle cast:~p~n", [Msg]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(Reason, _State) ->
    %% case get(check_amount) of
    %% 	0 ->
    %% 	    ok;
    %% 	_ ->
    %% 	    io:format("@@@@@@@@@@@@@@@@@@@@@@@@~nCheckoutLeft:~p~n@@@@@@@@@@@@@@@@@@~n", [get(check_amount)])

    %% end,
    %%io:format("self:~p,terminate~n", [self()]),
    %%case get(is_repeat) of
    %%	undefined ->
    friend:role_offline_update(),
    PlayerID = get_player_id(),
    %%account_pid_mapping:unmapping(PlayerID),
    RoleId = get_role_id(),
    role_pid_mapping:unmapping(RoleId),
    role_pid_mapping:unmap_player_pid(RoleId),
    account_pid_mapping:unmap_player_pid(PlayerID),
    player_role:role_offline(),
    %%	_ ->
    %%	    ok
    %% end,

    %%battle:clear_mapinfo(),
    {stop, Reason}.

%%--------------------------------------------------------------------
 %% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
