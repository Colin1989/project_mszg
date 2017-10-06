%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 23 Jul 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(mail).


-include("packet_def.hrl").
-include("thrift/rpc_types.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").



%% API
-export([start/0,
	 post_email/2,
	 notify_email_list/0,
	 proc_req_get_email_attachments/1,
	 proc_notify_email_add/1,
	 send_email/7
	]).

-define(mail_priority, 6).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
start() ->
    packet:register(?msg_req_get_email_attachments, {?MODULE, proc_req_get_email_attachments}),
    packet:register(?msg_notify_email_add, {?MODULE, proc_notify_email_add}),
    ok.

send_email(Id, Title, Content, Attachments, EndTime, Type, RoleIds) ->
    try
    NewAttachMents = [#award_item{temp_id = AwardId, amount = Amount} || #attachment{award_id = AwardId, amount = Amount} <- Attachments],
    NewEndTime = #stime{year = EndTime#time_format.year, 
			month = EndTime#time_format.month,
			day = EndTime#time_format.day,
			hour = EndTime#time_format.hour,
			minute = EndTime#time_format.minute,
			second = EndTime#time_format.second},
    Email = make_email(Id, Title, Content, NewAttachMents, NewEndTime, Type),
    io_helper:format("Email:~p~n", [Email]),
    Now = datetime:localtime(),
    case datetime:diff_time(Now, NewEndTime) =< 0 of
	true ->
	    ?rpc_SendEmail_TIMEERR;
	false ->
	    case check_type_illegel(Type) of
		true ->
		    case check_award_illegel(NewAttachMents) of
			true ->
			    case check_id_illegel(Id) of
				true ->
				    case Email#semail.type of
					?rpc_EmailType_ALL ->
					    post_email(Email, all);
					?rpc_EmailType_PRIVATE ->
					    post_email(Email, RoleIds)
				    end,
				    ?rpc_SendEmail_SUCCESS;
				false ->
				    ?rpc_SendEmail_IDREPEAT
			    end;
			false ->
			    ?rpc_SendEmail_ATTACHMENTERR 
		    end;
		false ->
		    ?rpc_SendEmail_TYPEERR
	    end
    end
    catch
	_:_ ->
	    ?rpc_SendEmail_FAILED
    end.


check_id_illegel(Id) ->
    case redis:hget("email:list", Id) of
	undefined ->
	    true;
	_ ->
	    false
    end.
check_type_illegel(Type) ->
    case Type of 
	?rpc_EmailType_ALL ->
	    true;
	?rpc_EmailType_PRIVATE ->
	    true;
	_ ->
	    false
    end.

check_award_illegel(Awards) ->
    try
	lists:foreach(fun(#award_item{temp_id = AwardId}) -> 
			      tplt:get_data(reward_item_tplt, AwardId)
		      end, Awards),
	true
    catch
	_:_ ->
	    false
    end.


proc_req_get_email_attachments(#req_get_email_attachments{email_id = EmailId} = Packet) ->
    io_helper:format("email:~p~n", [Packet]),
    MyEmails = get_my_emails(),
    case lists:keyfind(EmailId, #semail.id, MyEmails) of
	false ->
	    packet:send(#notify_get_email_attachments_result{result = ?common_failed});
	Email ->
	    process_get_attachments(Email),
	    packet:send(#notify_get_email_attachments_result{result = ?common_success})
    end.

process_get_attachments(Email) ->
    RoleId = player:get_role_id(),
    {Awards, Amounts} = lists:unzip([{AwardId, Amount} || #award_item{temp_id = AwardId, amount = Amount} <- Email#semail.attachments]),
    {PrivateEmails, OtherEmails} = get(my_emails),
    NewInfo = case Email#semail.type of
		  ?rpc_EmailType_PRIVATE ->
		      redis:srem(lists:concat(["email:box:", RoleId]), [Email#semail.id]),
		      {lists:keydelete(Email#semail.id, #semail.id, PrivateEmails), OtherEmails};
		  ?rpc_EmailType_ALL ->
		      redis:sadd(lists:concat(["email:get:", Email#semail.id]), [RoleId]),
		      {PrivateEmails, lists:keydelete(Email#semail.id, #semail.id, OtherEmails)}
	      end,
    put(my_emails, NewInfo),
    reward:give(Awards, Amounts, ?st_email_attachment).

proc_notify_email_add(#notify_email_add{new_email = NewEmail}) ->
    io_helper:format("############################~n"),
    case get(new_email) of
	undefined ->
	    put(new_email, [NewEmail]);
	NewEmails ->
	    put(new_email, [NewEmail|NewEmails])
    end.


notify_email_list() ->
    Emails = get_my_emails(),
    packet:send(#notify_email_list{emails = Emails}).



get_my_emails() ->
    AllEmails = case get(my_emails) of
		    undefined ->
			get_email_from_cache();
		    Emails ->
		     	add_new_emails(Emails)
		end,
    put(new_email, []),
    update_my_email(AllEmails).


%%合并新邮件列表
add_new_emails(Emails) ->
    case get(new_email) of
	undefined ->
	    Emails;
	[] ->
	    Emails;
	NewEmails ->
	    lists:foldl(fun(X, {Private, Other}) ->
				case X#semail.type of
				    ?rpc_EmailType_PRIVATE ->
					case lists:keyfind(X#semail.id, #semail.id, Private) of
					    false ->
						{[X|Private], Other};
					    _ ->
						ok
					end;
				    ?rpc_EmailType_ALL ->
					case lists:keyfind(X#semail.id, #semail.id, Other) of
					    false ->
						{Private, [X|Other]};
					    _ ->
						ok
					end
				end
			end, Emails, NewEmails)
    end.


update_my_email({PrivateEmails, OtherEmails}) ->
    NewPrivateEmails = update_private_email(PrivateEmails),
    NewOtherEmails = update_everyone_emmail(OtherEmails),
    put(my_emails, {NewPrivateEmails, NewOtherEmails}),
    %%Now = datetime:localtime(),
    lists:sort(fun(#semail{recv_time = RevTime}, #semail{recv_time = RevTime2}) -> 
		       %%datetime:stime_to_seconds(RevTime) =< datetime:stime_to_seconds(RevTime2)
		       datetime:diff_time(RevTime, RevTime2) >= 0
	       end, lists:concat([NewPrivateEmails,NewOtherEmails])).


%%丢弃已过期的私人邮件
update_private_email(PrivateEmails) ->
    Now = datetime:localtime(),
    RoleId = player:get_role_id(),
    %%io:format("PrivateEmails:~p~n", [PrivateEmails]),
    lists:foldl(fun(#semail{id = Id, end_time = EndTime} = Email, In) ->
			case datetime:diff_time(Now, EndTime) > 0 of
			    true ->
				[Email|In];
			    false ->
				redis:srem(lists:concat(["email:box:", RoleId]), [Id]),
				In
			    end
		end, [], PrivateEmails).

%%丢弃过期的公共邮件
update_everyone_emmail(Emails) ->
    Now = datetime:localtime(),
    Role = player_role:get_db_role(player:get_role_id()),
    RoleCreateTime = datetime:make_time(Role:create_time()),
    lists:foldl(fun(#semail{id = Id, end_time = EndTime, recv_time = RevTime} = Email, In) ->
			case datetime:diff_time(RoleCreateTime, RevTime) > 0 of
			    true ->
				case datetime:diff_time(Now, EndTime) > 0 of
				    true ->
					[Email|In];
				    false ->
					case get(my_emails) of
					    undefined ->
						redis:srem("email:box:all", [Id]);
					    %%redis:del(lists:concat(["email:get:", Id]));
					    _ ->
						ok
					end,
					In
				end;
			    false ->
				In
			end
		end, [], Emails).

%%从缓存里获取
get_email_from_cache() ->
    RoleId = player:get_role_id(),
    PrivateIds = redis:smembers(lists:concat(["email:box:", RoleId])),
    OtherIds = redis:smembers("email:box:all"),
    GottenInfos = redis_extend:smismember(RoleId, [lists:concat(["email:get:", OtherId]) || OtherId <- OtherIds]),
    FinalOtherIds = [Id ||{_, Id} <- lists:filter(fun({Flag, _})-> Flag =:= 0 end, lists:zip(GottenInfos, OtherIds))],
    AllEmails = redis:hmget("email:list", lists:concat([PrivateIds, FinalOtherIds])),
    PrivateAmount = length(PrivateIds),
    PrivateEmails = lists:sublist(AllEmails, PrivateAmount),
    OtherEmails = lists:sublist(AllEmails, PrivateAmount + 1, length(FinalOtherIds)),
    {[X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end,PrivateEmails)], 
     [X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end,OtherEmails)]}.






post_email(Email, all) ->
    Packet = #notify_email_add{new_email = Email},
    AllPids= [ X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end, redis_extend:get_members_info(online_roleid_set,role_pid_mapping))],
    EmailId = Email#semail.id,
    redis:hset("email:list", EmailId, Email),
    redis:sadd("email:box:all", [EmailId]),
    broadcast_server:broadcast_packet(AllPids, Packet, ?mail_priority),
    ok;
post_email(Email, RoleIds) ->
    io_helper:format("RoleIds~p~n", [RoleIds]),
    Packet = #notify_email_add{new_email = Email},
    AllPids = [ X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end, redis:hmget(role_pid_mapping, RoleIds))],
    EmailId = Email#semail.id,
    redis:hset("email:list", EmailId, Email),
    redis_extend:smadd("email:box:", RoleIds, Email#semail.id),
    broadcast_server:broadcast_packet(AllPids, Packet, ?mail_priority),
    ok.





%%%===================================================================
%%% Internal functions
%%%===================================================================

make_email(Id, Title, Content, Attachments, EndTime, Type) ->
    #semail{id = Id, 
	    title = Title, 
	    content = Content, 
	    attachments = Attachments, 
	    end_time = EndTime, 
	    recv_time = datetime:localtime(),
	    type = Type}.



