%% Author: NoteBook
%% Created: 2009-9-11
%% Description: Add description to client
-module(robot3).

%%
%% Include files
%%
-include("net_type.hrl").
-include("packet_def.hrl").  
-include("enum_def.hrl").

%%
%% Exported Functions
%%
-export([start/1, do_start/1,send_data/1,reconnect/0]). 
-compile(export_all).
%% 
%% API Functions
%%
start(Ip, Port, Count) ->
	ets:new(robot,[ordered_set, public, named_table]),
    start([Ip, Port, Count]).

start([Ip, Port]) ->
    io:format("111~n"),
    ets:new(robot,[ordered_set, public, named_table]),
    do_start([Ip, Port, 0]);
start([Ip, Port, Count]) ->
	ets:new(robot,[ordered_set, public, named_table]),
    do_start([Ip, Port, Count]).

do_start([Ip, Port, Count]) ->
    Socket = connect(Ip, list_to_integer(Port)),
    Account = get_account(Count),
    %%Data=#req_register{account="helloworld", name="Godlike", password="123456", age=10},
    send_data(Socket, #req_check_version{version = ?proto_ver}),
    Data = #req_login{account=Account, password="111111"},
    send_data(Socket, Data),
    set_data(pid, self()),
    loop(Socket, Account).
	
send_data(Data)->
    Pid = get_data(pid),
    Pid ! {robotcmd,Data}.

get_account(Count) when is_integer(Count) ->
    "test"++integer_to_list(Count);
get_account(Count) when is_list(Count) ->
    "test"++Count.


set_data(Key, Value) ->
    ets:insert(robot,{Key, Value}).

get_data(Key) ->
    case ets:lookup(robot, Key) of
	[] ->
	    io:format("get data error!~n",[]);
	[{_, Value}] ->
	    Value
    end.

%%
%% Add description of start/function_arity
%%
connect(Ip, Port) -> 
    {ok, Socket} = gen_tcp:connect(Ip, Port, [{packet, 4}]),
    Socket.

reconnect()->
    start("127.0.0.1", "8001", 1).
%%
%% Local Functions
%%

send_data(Socket, Data) ->
    {Type, Binary} = protocal:encode(Data),
    Msg = net_helper:make_net_binary(Type, Binary),
    gen_tcp:send(Socket, Msg),
    ok.


loop(Socket, Account) ->
    receive
	{tcp, Socket, Bin} ->
	    Binary = list_to_binary(Bin),
	    {MsgType, MsgData}= net_helper:get_data(Binary),
	    case MsgType of
		?msg_notify_heartbeat->
		    ok;
		_->printf("receive msg:{MsgType:~p, MsgData:~p}~n", [MsgType, MsgData])
	    end,
	    process(Socket, Account, MsgType, MsgData),
	    loop(Socket, Account);
	{tcp_closed, Socket} ->
	    printf("tcp close~n");
	{robotcmd,Data} ->
		send_data(Socket,Data),
		loop(Socket, Account)
    end.

process(Socket, Account, ?msg_notify_login_result, #notify_login_result{result=Result}) ->
    case Result of
	?login_success ->
	    %%TODO:登录成功的后续操作
	    ok;
	?login_norole ->
	    send_data(Socket, #req_create_role{roletype=1, nickname="test"++Account});
	_ ->
	    send_data(Socket, #req_register{account=Account, password="111111", channelid=1})
    end,
    ok;
process(Socket, Account, ?msg_notify_register_result, #notify_register_result{}) ->
    Data = #req_login{account=Account, password="111111"},
    send_data(Socket, Data),
    ok;
process(_Socket, _Account, ?msg_notify_create_role_result, #notify_create_role_result{}) ->
    ok;
process(_Socket, _Account, ?msg_notify_power_hp_msg, #notify_power_hp_msg{result=_Result,power_hp=_PowerHp}) ->
    ok;
process(_Socket, _Account, _, _MsgData) ->
    ok.


printf(_Str) ->
    io_helper:format(_Str),
    ok. 

printf(_Str, _Params) ->
    io_helper:format(_Str, _Params),
    ok.
%% 占卜
rand(N) ->
    send_data(#req_sculpture_divine{money_type=1, times=N}).
%% 卸下
off(Pos) ->
    send_data(#req_sculpture_takeoff{position=Pos}).

%% 穿上
on() ->
    on(1, 72057594038006936).
on(Pos, ID) ->
    send_data(#req_sculpture_puton{position=Pos, inst_id=ID}).

%% 升级
up(MainId, EatList) ->
    send_data(#req_sculpture_upgrade{main_id=MainId, eat_ids=EatList}).

%% 兑换
convert(ItemTpltId) ->
    send_data(#req_sculpture_convert{target_item_id=ItemTpltId}).

%% 兑换
get_task() ->
    send_data(#req_task_infos{}).

task(TaskID) ->
    send_data(#req_finish_task{task_id=TaskID}).


