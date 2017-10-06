%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2014, linyibin
%%% @doc
%%%
%%% @end
%%% Created : 12 Feb 2014 by linyibin <>
%%%-------------------------------------------------------------------
%% 
%%                    _ooOoo_
%%                   o8888888o
%%                   88" . "88
%%                   (| -_- |)
%%                   O\  =  /O
%%                ____/`---'\____
%%              .'  \\|     |//  `.
%%             /  \\|||  :  |||//  \
%%            /  _||||| -:- |||||-  \
%%            |   | \\\  -  /// |   |
%%            | \_|  ''\---/''  |   |
%%            \  .-\__  `-`  ___/-. /
%%          ___`. .'  /--.--\  `. . __
%%       ."" '<  `.___\_<|>_/___.'  >'"".
%%      | | :  `- \`.;`\ _ /`;.`/ - ` : | |
%%      \  \ `-.   \_ __\ /__ _/   .-` /  /
%% ======`-.____`-.___\_____/___.-`____.-'======
%%                    `=---='
%% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%%              佛祖保佑       永无BUG
%% 


-module(robot).

-behaviour(gen_server).

%% API
-export([start/6]).

-include("net_type.hrl").
-include("packet_def.hrl").  
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg_str.hrl").
-include("sys_msg.hrl").

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-compile(export_all).

-define(SERVER, ?MODULE).

-record(state, {ip,
		port,
		socket,
		account,
		password}).

%%%===================================================================
%%% API
%%%===================================================================
start(IP, Port, Account, Password, Sleep, ObserverPid) ->
    timer:sleep(Sleep),
    print("start:~p~n", [Account]),
    start_link(IP, Port, Account, Password, ObserverPid).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(IP, Port, Account, Password, ObserverPid) ->
    gen_server:start_link({local, list_to_atom(Account)}, ?MODULE, [IP, Port, Account, Password, ObserverPid], []).

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
init([IP, Port, Account, Password, ObserverPid]) ->
    %%rand:seed(datetime:time()),
    rand:seed(now()),
    Socket = connect(IP, list_to_integer(Port)),
    put(observer_pid, ObserverPid),
    login(Socket, Account, Password),
    put(socket, Socket),
    %%io:format("~p~n", [ObserverPid]),
    ObserverPid ! {update_amount, 1},
    {ok, #state{ip = IP,
		port = Port,
		socket = Socket,
		account = Account,
		password = Password
	       }}.

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
handle_cast({stop, Reason}, State)->
    {stop, {shutdown,Reason}, State};

handle_cast(_Msg, State) ->
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
handle_info({tcp, Socket, Bin}, #state{socket=Socket, account=Account}=State) ->
    Binary = list_to_binary(Bin),
    {MsgType, MsgData}= net_helper:get_data(Binary),
    case MsgType of
	?msg_notify_heartbeat->
	    ok;
	_->
	    case get(send_packet) of
		undefined ->
		    ok;
		Time ->
		    Cur = timer:now_diff(erlang:now(), Time),
		    ObserverPid = get(observer_pid),
		    %%io:format("delay:~p~n", [Cur]),
		    case MsgType of
			?msg_notify_rank_infos ->
			    io:format("~p delay ~pmic~n", [element(1, MsgData), Cur]);
			_ ->
			    ok
		    end,
		    case Cur >50000 of
			true ->
			    ok;
			    %%io:format("~p delay ~pmic~n", [element(1, MsgData), Cur]);
			_ ->
			    ok
		    end,
		    ObserverPid ! {delay, Cur},
		    put(send_packet, undefined),
		    ok
	    end,
	    ok
    end,
    process(Socket, Account, MsgType, MsgData), 
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    print("tcp close~n", []),
    {stop, {shutdown,tcp_closed}, State}.
    %% {noreply, State}.

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
terminate(_Reason, _State) ->
    ObserverPid = get(observer_pid),
    ObserverPid ! {update_amount, -1},
    RoleInfo = get_role_info(),
    case is_record(RoleInfo, notify_roleinfo_msg) of
	true ->
	    print("~p terminate!!!!!!!!!!!!!!!~n", [RoleInfo#notify_roleinfo_msg.nickname]);
	false ->
	    ok
    end,
    ok.

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
connect(Ip, Port) -> 
    {ok, Socket} = gen_tcp:connect(Ip, Port, [{packet, 4}]),
    Socket.

%% send_data(Socket, Data) ->
%%     {Type, Binary} = protocal:encode(Data),
%%     Msg = net_helper:make_net_binary(Type, Binary),
%%     gen_tcp:send(Socket, Msg),
%%     ok.


send_data(Socket, Data) ->
    Step = case get(step) of
	       undefined ->
		   1;
	       OrgStep ->
		   NewStep = case OrgStep+1 of
				 256 ->
				     1;
				 New ->
				     New
			     end,
		   %%put(step, NewStep),
		   NewStep
	   end,
    put(step, Step),
    {Type, Binary} = protocal:encode(Data),
    Msg = net_helper:make_net_binary(Type, Binary),
    gen_tcp:send(Socket, packet_crypto:encode(<<Step:?UCHAR,Msg/binary>>)),
    ObserverPid = get(observer_pid),
    
    %%io:format("~p~n", [ObserverPid]),
    ObserverPid ! increment,
    put(send_packet, erlang:now()),
    %%io:format("ssss~p~n", [ObserverPid]),
    ok.

login(Socket, Account, Password) ->
    send_data(Socket, #req_check_version{version = ?proto_ver}),
    Data = #req_login{account=Account, password=Password},
    send_data(Socket, Data).



%%登录回调处理
process(Socket, Account, ?msg_notify_login_result, #notify_login_result{id = PlayerId, result=Result, role_infos = RoleInfos}) ->
    case Result of
	?login_success ->
	    %%TODO:登录成功
	    %%timer:sleep(get_rand_second()),
	    %%[RoleInfo|_] = RoleInfos, 
	    set_player_id(PlayerId),
	    RoleInfo = lists:nth(rand:uniform(length(RoleInfos)), RoleInfos),
	    send_data(Socket, #req_select_role{role_id = RoleInfo#role_data.role_id}),
	    ok;
	?login_norole ->
	    %%io:format("1~n");%%
	    set_player_id(PlayerId),
	    send_data(Socket, #req_create_role{roletype=1, nickname="nick_"++Account});
	?login_noregister ->
	    send_data(Socket, #req_register{account=Account, password="111111", channelid=1})
    end;


process(_Socket, _Account, ?msg_notify_select_role_result, #notify_select_role_result{result = Result})->
    case  Result of
	?common_success ->
	    ok;
	    
	    %% timer:sleep(get_rand_second()),
	    %% send_data(Socket, #req_enter_game{id=11111, gametype=1, copy_id=1001});
	?common_failed ->
	    ok
    end;

process(Socket, Account, ?msg_notify_register_result, #notify_register_result{result = Result}) ->
    case Result of
	?common_success ->
	    Data = #req_login{account=Account, password="111111"},
	    send_data(Socket, Data);
	_ ->
	    io:format("RegisterErr:~p~n", [Result])
    end,
    ok;


process(Socket, Account, ?msg_notify_create_role_result, #notify_create_role_result{result = Result}) ->
    case Result of
	?common_success ->
	    ok;
	    %%proc_into_service(Socket);
	_ ->
	    send_data(Socket, #req_create_role{roletype=1, nickname=Account ++ "_err_" ++ integer_to_list(Result)})
    end,
    ok;


process(_Socket, _Account, ?msg_notify_power_hp_msg, #notify_power_hp_msg{result=_Result,power_hp=_PowerHp}) ->
    ok;


%% process(Socket, _Account, ?msg_notify_enter_game, #notify_enter_game{game_id=GameID}) ->
%%     send_data(Socket, #req_game_settle{game_id=GameID, result=1}),
%%     ok;


%% process(Socket, _Account, ?msg_notify_game_settle, #notify_game_settle{}) ->
%%     timer:sleep(get_rand_second()),
%%     send_data(Socket, #req_enter_game{id=11111, gametype=1, copy_id=1001}),
%%     ok;

process(_Socket, _Account, ?msg_notify_player_pack, Data) ->
    manage_player_pack(Data);

process(_Socket, _Account, ?msg_notify_sys_time, _Data) ->
    ok;%%manage_player_pack(Data);
process(_Socket, _Account, ?msg_notify_sculpture_infos, _Data) ->
    ok;
process(_Socket, _Account, ?msg_notify_equipment_infos, _Data) ->
    ok;


process(_Socket, _Account, ?msg_notify_roleinfo_msg, Data) ->
    Socket = get(socket),
    set_role_info(Data),
    proc_into_service(Socket),
    ok;
process(_Socket, _Account, ?msg_notify_role_info_change, Data) ->
    update_role_info(Data),
    ok;

process(_Socket, _Account, ?msg_notify_gold_update, Data)->
    update_gold(Data),
    ok;
process(_Socket, _Account, ?msg_notify_emoney_update, Data) ->
    update_emoney(Data),
    ok;





process(_Socket, _Account, _MsgType, MsgData) ->
    %%io:format("receive msg:{MsgType:~p, MsgData:~p}~n", [MsgType, MsgData]),
    process_response(MsgData),
    
    %% RoleInfo = get_role_info(),
    %% case RoleInfo of
    %% 	undefined ->
    %% 	    ok;
    %% 	_ ->
    %% 	    io:format("~p alive!!!!!!!!!!!!!!!~n", [RoleInfo#notify_roleinfo_msg.nickname])
    %% end,
    ok.

get_rand_second() ->
    random:seed(erlang:now()),
    Second = rand:uniform(30000, 180000),
    print("Second:~p~n", [Second]),
    Second.

proc_into_service(_Socket) ->
    case get(is_first) of
	undefined ->
	    put(is_first, false),
	    put(cur_action, 1),
	    to_next_action();
	_ ->
	    ok
    end,
    ok.




to_next_action() ->
    CurAction = get(cur_action),
    print("#########CurAction:~p, ContinueTime:~p~n", [CurAction, get(time)]),
    TestInfo = tplt:get_data(stress_test_tplt, CurAction),
    case TestInfo#stress_test_tplt.next_action of
	[] ->
	    %%terminate(normal,[]);
	    gen_server:cast(self(), {stop, {not_next_action, {cur_action, CurAction}}});
	_ ->
	    case get_next_action(rand:uniform(100), TestInfo#stress_test_tplt.next_action) of
		{NextAction, ContinueTime} ->

		    %%io:format("@@@@@@@@CurAction~p~n", [NextAction]),
		    process_action(NextAction, ContinueTime);
		_ ->
		    ok
	    end
    end,
    ok.


get_next_action(Res, [{NextId, Radio, MinTime, MaxTime}|Actionss]) ->
    case Res =< Radio of
	true ->
	    case NextId of
		0 ->
		    gen_server:cast(self(), {stop, {quit, {next_action, 0}}});
		_ ->
		    {NextId, rand:uniform(MaxTime - MinTime + 1) + MinTime - 1}
	    end;
	false ->
	    get_next_action(Res - Radio, Actionss)
    end.


process_action(NextAction, ContinueTime) ->
    put(cur_action, NextAction),
    put(time, ContinueTime),
    do_action(NextAction),
    ok.


process_response(Ack)->
    %% case get(cur_action) of
    %% 	Action ->
    %% 	    io:format("undef action:~p~n", [Action])
    %% end,
    %%io:format("Ack:~p~n", [Ack]),
    %%io:format("%%%%%%%%%%%CurAction:~p~n", [get(cur_action)]),
    case do_response(get(cur_action), Ack, get(time)) of
	true ->
	    to_next_action();
	false ->
	    ok
    end,
    ok.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%    逻辑和回调
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%获取副本信息
do_action(2) ->
    Socket = get_socket(),
    send_data(Socket, #req_last_copy{roleid = get_role_id()});
    


%%请求进入副本
do_action(3) ->
    Socket = get_socket(),
    CopyId = get_play_copy_id(),
    send_data(Socket, #req_enter_game{id=get_player_id(), gametype=1, copy_id=CopyId}),
    put(copy_id, CopyId);



%%请求副本结算
do_action(4) ->
    Socket = get_socket(),
    {Result, AllMap, GameId} = get_game_info(),
    case Result of
	?enter_game_success ->
	    {Items, Gold} = game_validation:get_items_and_gold(AllMap),
	    SettleInfo = #req_game_settle{result=1, game_id=GameId, life=100, maxlife=100,
					  cost_round=1,
					  killmonsters= battle:get_all_monsters(AllMap),
					  user_operations=[], pickup_items=Items, gold=Gold},
	    send_data(Socket, SettleInfo);
	_ ->
	    %%io:format("$$$$$$$$$$$$$$$$$$$$$"),
	    to_next_action()
    end;

%%装备升级
do_action(5) ->
    ok;

%%一键占卜
do_action(6) ->
    case get(divine_disable) of
	undefined ->
	   ok 
    end,
    ok;

%%副本扫荡
do_action(7) ->
    ok;

%%挑战
do_action(8) ->
    ok;

%%排行榜信息
do_action(9) ->
    case get(lists:concat([ranktype, rand:uniform(2)])) of
	undefined ->
	    Socket = get_socket(),
	    send_data(Socket, #req_get_rank_infos{type = ?battle_power_rank});
	_ ->
	    to_next_action()
    end,
    ok;

%%请求荣耀
do_action(10) ->
    case get(military_rank) of
	undefined ->
	    Socket = get_socket(),
	    send_data(Socket, #req_military_rank_info{});
	_ ->
	    to_next_action()
    end,
    ok;


%%宝石合成
do_action(11) ->
    ok;










do_action(Action) ->
    print("do undefined action:~p~n", [Action]).


%%副本信息
do_response(2, #notify_last_copy{copyinfos = CopyInfos}, ContinueTime) ->
    timer:sleep(ContinueTime * 1000),
    set_copy_info(CopyInfos),
    true;

do_response(3, #notify_enter_game{result=Result, gamemaps=AllMap,game_id=GameId}, ContinueTime) ->
    %%Socket = get_socket(),
    timer:sleep(ContinueTime * 1000),
    set_game_info({Result, AllMap, GameId}),
    %% case Result of
    %% 	?enter_game_success ->
    %% 	    {Items, Gold} = game_validation:get_items_and_gold(AllMap),
    %% 	    SettleInfo = #req_game_settle{result=1, game_id=GameId, life=100, maxlife=100,
    %% 					  monsterkill=game_copy:get_copy_monster_amount(get(copy_id)),
    %% 					  killmonsters= battle:get_all_monsters(AllMap),
    %% 					  user_operations=[], pickup_items=Items, gold=Gold},
    %% 	    send_data(Socket, SettleInfo);
    %% 	false ->
    %% 	    ok
    %% end,
    true;

do_response(4, #notify_game_settle{result=Result, score=Score}, ContinueTime) ->
    case Result of
	?game_win ->
	    past_copy(get(copy_id), Score);
	_ ->
	    ok
    end,
    timer:sleep(ContinueTime * 1000),
    true;


do_response(9, #notify_rank_infos{type = Type}, ContinueTime) ->
    put(lists:concat([ranktype, Type]), true),
    timer:sleep(ContinueTime * 1000),
    true;

do_response(10, #notify_military_rank_info{}, ContinueTime) ->
    put(military_rank, true),
    timer:sleep(ContinueTime * 1000),
    true;





do_response(_, #notify_sys_msg{code = Code}, _) ->
    case Code of
	?sg_game_not_enough_power ->
	    ok;
	?sg_game_not_enough_summon_stone->
	    ok;
	_ ->
	    ok
	    
    end,
    print("ErrMsg:~p~n", [lists:nth(Code, ?all_sys_msg_str)]),
    false;





do_response(CurAction, Data, ContinueTime) ->
    print("Unprocess Response{CurAction:~p,Data:~p,ContinueTime:~p}~n", [CurAction, Data, ContinueTime]),
    false.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   data manager
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_game_info() ->
    get(game_info).

set_game_info(GameInfo) ->
    put(game_info, GameInfo).


get_socket() ->
    get(socket).

%%副本数据管理
set_copy_info(CopyInfos) ->
    put(copy_info, CopyInfos).

get_copy_infos()->
    get(copy_info).

get_all_pass_copy_id() ->
    Infos = get_copy_infos(),
    [CopyId ||#copy_info{copy_id = CopyId} <- Infos].

past_copy(CopyId, Score) ->
    Infos = get_copy_infos(),
    case lists:keyfind(CopyId, #copy_info.copy_id, Infos) of
	false ->
	    set_copy_info([#copy_info{copy_id = CopyId, max_score = Score}|Infos]);
	Data ->
	    case Data#copy_info.max_score >= Score of
		true ->
		    ok;
		false ->
		    lists:keyreplace(CopyId, #copy_info.copy_id, Infos, Data#copy_info{max_score = Score})
	    end
    end.

get_unmaxscore_copy() ->
    Infos = get_copy_infos(),
    lists:filter(fun(#copy_info{max_score = MaxScore}) ->
			 MaxScore =/= 3
		 end, Infos).


get_can_cleanup_copy() ->
    Infos = get_copy_infos(),
    lists:filter(fun(#copy_info{copy_id = Id}) -> 
			 is_copy_normal(Id)
		 end, Infos).

is_copy_normal(CopyId) ->
    #copy_tplt{type = Type} = tplt:get_data(copy_tplt, CopyId),
    case Type of
	3 ->
	    false;
	_ ->
	    true
    end.

%%获取新副本
get_newcopy() ->
    AllPass = get_all_pass_copy_id(),
    AllData = tplt:get_all_data(copy_tplt),
    CanPlay = lists:filter(fun(#copy_tplt{pre_copy = PreCopy, id = CopyId}) -> 
				  case length(AllPass -- [CopyId]) =:= length(AllPass) of
				      true ->
					  check_copy_unlock(PreCopy, AllPass);
				      false ->
					  false
				  end
			  end, AllData),
    CanPlay.

get_play_copy_id()->
    case rand:uniform(3) of
	1 ->
	    case get_all_pass_copy_id() of
		[] ->
		    get_play_copy_id();
		AllPass  ->
		    lists:nth(rand:uniform(length(AllPass)), AllPass)
	    end;
	2 ->
	    case get_newcopy() of
		[] ->
		    get_play_copy_id();
		NewUnlocks ->
		    NewCopy = lists:nth(rand:uniform(length(NewUnlocks)), NewUnlocks),
		    NewCopy#copy_tplt.id
	    end;
	3 ->
	    case get_unmaxscore_copy() of
		[] ->
		    get_play_copy_id();
		NoMax ->
		    NewCopy = lists:nth(rand:uniform(length(NoMax)), NoMax),
		    NewCopy#copy_info.copy_id
	    end
    end.

%%判断副本是否解锁
check_copy_unlock([], _AllPass) ->
    true;
check_copy_unlock([PreCopy|PreCopys], AllPass) ->
    case length(AllPass -- [PreCopy]) =:= length(AllPass) of
	false ->
	    check_copy_unlock(PreCopys, AllPass);
	true ->
	    false
    end.
    
%%角色信息管理
get_role_id() ->
    RoleInfo = get_role_info(),
    RoleInfo#notify_roleinfo_msg.id.

set_player_id(Id) ->
    put(player_id, Id).

get_player_id() ->
    get(player_id).

get_role_info() ->
    get(role_info).

set_role_info(Info) ->
    put(role_info, Info).


update_gold(#notify_gold_update{})->
    ok.

update_emoney(#notify_emoney_update{})->
    ok.
update_role_info(#notify_role_info_change{type = Type, new_value = Value}) ->
    CurInfo = get(role_info),
    RecordInfo = record_info(fields, notify_roleinfo_msg),
    NameAtom = list_to_atom(Type),
    Index = length(lists:takewhile(fun(X) -> X =/= NameAtom end, RecordInfo)) + 2,
    set_role_info(setelement(Index, CurInfo, Value)).
    


%%背包管理模块
get_player_pack() ->
    case get(player_pack) of
	undefined ->
	    [];
	PackItems ->
	    PackItems
    end.

set_player_pack(NewItems) ->
    put(player_pack, NewItems).


manage_player_pack(#notify_player_pack{type=Type, pack_items=Items}) ->
    MyPack = get_player_pack(),
    case Type of
	?init ->
	    set_player_pack(Items);
	?append ->
	    set_player_pack(Items ++ MyPack);
	?delete ->
	    DelIds = [InstId ||#pack_item{id = InstId} <- Items],
	    NewItems = lists:filter(fun(#pack_item{id = NewInstId}) -> 
					    length(DelIds -- [NewInstId]) =:= length(DelIds)
				    end, MyPack),
	    set_player_pack(NewItems);
	?modify ->
	    ModifyIds = [InstId ||#pack_item{id = InstId} <- Items],
	    NewItems = lists:filter(fun(#pack_item{id = NewInstId}) -> 
					    length(ModifyIds -- [NewInstId]) =:= length(ModifyIds)
				    end, MyPack),
	    set_player_pack(Items ++ NewItems)
    end.



test_now_diff(Second) ->
    Old = erlang:now(),
    timer:sleep(trunc(Second * 1000)),
    io:format("timepass:~p~n", [timer:now_diff(erlang:now(), Old)]).


%%背包管理模块
%% get_player_pack() ->
%%     case get(player_pack) of
%% 	undefined ->
%% 	    [];
%% 	PackItems ->
%% 	    PackItems
%%     end.

%% set_player_pack(NewItems) ->
%%     put(player_pack, NewItems).


%% manage_player_pack(#notify_player_pack{type=Type, pack_items=Items}) ->
%%     MyPack = get_player_pack(),
%%     case Type of
%% 	?init ->
%% 	    set_player_pack(Items);
%% 	?append ->
%% 	    set_player_pack(Items ++ MyPack);
%% 	?delete ->
%% 	    DelIds = [InstId ||#pack_item{id = InstId} <- Items],
%% 	    NewItems = lists:filter(fun(#pack_item{id = NewInstId}) -> 
%% 					    length(DelIds -- [NewInstId]) =:= length(DelIds)
%% 				    end, MyPack),
%% 	    set_player_pack(NewItems);
%% 	?modify ->
%% 	    ModifyIds = [InstId ||#pack_item{id = InstId} <- Items],
%% 	    NewItems = lists:filter(fun(#pack_item{id = NewInstId}) -> 
%% 					    length(ModifyIds -- [NewInstId]) =:= length(ModifyIds)
%% 				    end, MyPack),
%% 	    set_player_pack(Items ++ NewItems)
%%     end.


print(_Str, _Args) ->
    ok.
    %%io:format(_Str, _Args).



