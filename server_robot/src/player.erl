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
-export([start_link/3]).
-export([set_player_id/1, get_player_id/0,set_role_id/1,get_role_id/0]).
 
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
start_link(TcpPid, PlayerId, Role) ->
    Ip = get(ip),
    gen_server:start_link(?MODULE, [TcpPid, PlayerId, Role, Ip], []).

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
init([TcpPid, PlayerId, Role, Ip]) ->
    put(ip,Ip),
    process_flag(trap_exit, true),
    put(tcpid, TcpPid),
    rand:seed(now()),
    set_player_id(PlayerId),
    set_role_id(Role:role_id()),
    role_pid_mapping:mapping(Role:role_id(), TcpPid),
    %%PlayerPack=player_pack:transform_items(player_pack:get_my_pack(),[]),
    %%packet:send(#notify_player_pack{type=?init,pack_items=PlayerPack}),
    player_pack:notify_init_player_pack(),
    daily_award:notify_sys_time(),
    friend:role_online_update(),
    player_role:notify_role_info(Role),
    tutorial:notify_tutorial_progress(),
    sculpture:proc_req_sculpture_infos(#req_sculpture_infos{}),
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
handle_cast({reselect_role},State)->
    %%put(is_repeat,true),
    %%gen_server:reply(_From, ok),
    %% Result = supervisor:terminate_child(get(tcpid), self()),
    %% io:format("Result:~p", [Result]),
    %%exit(self(),kill),
    %%put(reselect_role, true),
    {stop, {shutdown, reselect_role}, State};
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
	    %%PlayerID = get_player_id(),
	    %%account_pid_mapping:unmapping(PlayerID),
	    RoleId = get_role_id(),
	    role_pid_mapping:unmapping(RoleId),
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
