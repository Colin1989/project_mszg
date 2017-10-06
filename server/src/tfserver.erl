-module(tfserver).

-export([start/0, start/1, start_link/2, handle_function/2]).

-include("thrift/rpc_types.hrl").
-include("thrift/rpc_constants.hrl").
-include("packet_def.hrl").

-record(options, {port = config:get_server_config(thrift_port),
                  server_opts = []}).

start() -> start([]).
start(Args) ->
    #options{port = Port, server_opts = ServerOpts} = parse_args(Args),
    spawn(fun() -> start_link(Port, ServerOpts), receive after infinity -> ok end end).

parse_args(Args) -> parse_args(Args, #options{}).
parse_args([], Opts) -> Opts;
parse_args([Head | Rest], Opts) ->
    NewOpts =
        case catch list_to_integer(Head) of
            Port when is_integer(Port) ->
                Opts#options{port = Port};
            _Else ->
                case Head of
                    "framed" ->
                        Opts#options{server_opts = [{framed, true} | Opts#options.server_opts]};
                    "" ->
                        Opts;
                    _Else ->
                        erlang:error({bad_arg, Head})
                end
        end,
    parse_args(Rest, NewOpts).



start_link(Port, ServerOpts) ->
    thrift_socket_server:start([{handler, ?MODULE},
                                {service, rpcService_thrift},
                                {port, Port}] ++
                               ServerOpts).




trans_timestamp_to_time_format(Time) ->
    #time_format{year = Time#stime.year, 
			month = Time#stime.month,
			day = Time#stime.day,
			hour = Time#stime.hour,
			minute = Time#stime.minute,
			second = Time#stime.second}.


handle_function(convertCDKey, {RoleId, GiftId}) ->
    io_helper:format("convertCDKey~n"),
    S = redeem_code:send_reward(RoleId, GiftId),
    {reply, S};


handle_function(sendEmail, {Id, Title, Content, Attachments, EndTime, Type, RoleIds}) ->
    io_helper:format("sendEmail~n"),
    S = mail:send_email(Id, binary_to_list(Title), binary_to_list(Content), Attachments, EndTime, Type, RoleIds),
    {reply, S};


handle_function(recharge, {UserID, OrderID , Money, RechargeID}) ->
    io_helper:format("recharge~n"),
    io_helper:format("UserID:~p--OrderID:~p--Money:~p--RechargeID:~p--~n", [UserID, OrderID , Money, RechargeID]),
    S = recharge:recharge(UserID, OrderID , Money, RechargeID),
    {reply, S};

handle_function(get_role_info_by_nickname, {NickName}) ->
    io_helper:format("get ~p's info ~n", [NickName]),
    RoleInfo = case player_role:get_role_by_nickname(binary_to_list(NickName)) of
		   [] ->
		       #role_info{role_id = 0};
		   [Role] ->
		       User = player_role:get_user(Role:user_id()),
		       #role_info{user_id = Role:user_id(), 
				  role_id = Role:role_id(), 
				  role_status = Role:role_status(),
				  nick_name = Role:nickname(),
				  level = Role:level(),
				  exp = Role:exp(),
				  gold = Role:gold(),
				  emoney = User:emoney(),
				  create_time = trans_timestamp_to_time_format(datetime:make_time(Role:create_time())),
                       vip = User:vip_level()}
	       end,
    {reply, RoleInfo};


%% handle_function(kick_role_by_roleid, {RoleId, OptType}) ->
%%     Result = player_role:kick_role_by_roleid(RoleId, OptType),
%%     {reply, Result};

handle_function(modify_rolestatus_by_roleid, {RoleId, StatusType, OptType}) ->
    case (StatusType =< ?rpc_MaxStatusType) andalso (OptType =< ?rpc_ModifyType) of
	true ->
	    Result = player_role:modify_rolestatus_by_roleid(RoleId, StatusType, OptType),
	    {reply, Result};
	false ->
	    {reply, ?rpc_ModifyRoleStatusResult_STATUS_ERR}
    end;



handle_function(get_online_role_amount, {}) ->
    Amount = player_role:get_online_role_amount(),
    {reply, Amount};

handle_function(broadcast_service_msg, {Msg, RepeatTimes, Priority}) ->
    broadcast:broadcast_service_msg(Msg, RepeatTimes, Priority),
    ok;


handle_function(set_notice, {NoticeOptType, NoticeInfo}) ->
     FixNoticeInfo = NoticeInfo#notice_item{title = binary_to_list(NoticeInfo#notice_item.title),
                                            sub_title = binary_to_list(NoticeInfo#notice_item.sub_title),
                                            content = binary_to_list(NoticeInfo#notice_item.content)},
     Reslult = notice:set(NoticeOptType, FixNoticeInfo),
    {reply, Reslult};

handle_function(set_CDKey_reward_item, {OptType, CDKeyItem}) ->
    io:format("OptType:~p -- CDKeyItem:~p~n", [OptType, CDKeyItem]),
    Reslult = redeem_code:set_CDKey_reward_item(OptType, CDKeyItem),
    {reply, Reslult};

handle_function(get_all_role_count, {}) ->
    Num = length(redis:sinter([all_roleid_set])),
    io:format("get_all_role_count:~p~n", [Num]),
    {reply, Num};

handle_function(Func, Args) ->
    io:format("Func:~p, Args:~p~n", [Func, Args]),
    ok.


