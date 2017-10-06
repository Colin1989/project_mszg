%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created :  7 Nov 2014 by whl <>
%%%-------------------------------------------------------------------
-module(notice).

-include("thrift/rpc_types.hrl").
-include("packet_def.hrl").
-include("enum_def.hrl").

%% API
-export([set/2,
         notify_list/0,
         start/0,
         proc_req_req_notice_list/1,
         proc_req_notice_item_detail/1,
         del_send_notice_detail_list/0]).

-define(notice_priority, 7).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_notice_list, {?MODULE, proc_req_req_notice_list}),
    packet:register(?msg_req_notice_item_detail, {?MODULE, proc_req_notice_item_detail}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 处理后台的更新请求
%% @end
%%--------------------------------------------------------------------
notify_list() ->
    List = get_list(),
    FixList = lists:map(
        fun(E) ->
            trans_to_list_item_format(E)
        end,
        List
    ),
    packet:send(#notify_notice_list{list = FixList}).

%%--------------------------------------------------------------------
%% @doc
%% @spec 处理后台的更新请求
%% @end
%%--------------------------------------------------------------------
set(NoticeOptType, NoticeInfo) ->
    Result = case NoticeOptType of
                 ?rpc_NoticeOptType_ADD ->
                     add_item(NoticeInfo);
                 ?rpc_NoticeOptType_DEL ->
                     del_item(NoticeInfo);
                 ?rpc_NoticeOptType_MODIFY ->
                     modify_item(NoticeInfo)
             end,
    Result.

trans_to_list_item_format(NoticeInfo) ->
    CreateTime = time_format_2_stime(NoticeInfo#notice_item.create_time),
    StartTime = time_format_2_stime(NoticeInfo#notice_item.start_time),
    EndTime = time_format_2_stime(NoticeInfo#notice_item.end_time),
    #notice_list_item{id = NoticeInfo#notice_item.id,
                      title = NoticeInfo#notice_item.title,
                      sub_title = NoticeInfo#notice_item.sub_title,
                      icon = NoticeInfo#notice_item.icon,
                      mark_id = NoticeInfo#notice_item.mark_id,
                      create_time = CreateTime,
                      priority = NoticeInfo#notice_item.priority,
                      top_pic = NoticeInfo#notice_item.top_pic,
                      start_time = StartTime,
                      end_time = EndTime}.

trans_to_detail_format(NoticeInfo) ->
    #notice_item_detail{id = NoticeInfo#notice_item.id,
                        title = NoticeInfo#notice_item.title,
                        sub_title = NoticeInfo#notice_item.sub_title,
                        icon = NoticeInfo#notice_item.icon,
                        content = NoticeInfo#notice_item.content,
                        toward_id = NoticeInfo#notice_item.toward_id,
                        mark_id = NoticeInfo#notice_item.mark_id}.

time_format_2_stime(Time) ->
    #stime{year = Time#time_format.year,
           month = Time#time_format.month,
           day = Time#time_format.day,
           hour = Time#time_format.hour,
           minute = Time#time_format.minute,
           second = Time#time_format.second}.


add_item(NoticeInfo) ->
    OldList = get_list(),
    case lists:keyfind(NoticeInfo#notice_item.id, #notice_item.id, OldList) of
        false ->
            NewList = [NoticeInfo | OldList],
            io_helper:format("OldList:~p~n", [OldList]),
            io_helper:format("NewList:~p~n", [NewList]),
            set_notice_list(NewList),
            Packet = #notify_notice_item_add{item_info = trans_to_list_item_format(NoticeInfo)},
            AllPids= [ X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end, redis_extend:get_members_info(online_roleid_set,role_pid_mapping))],
            io_helper:format("Packet:~p~n", [Packet]),
            broadcast_server:broadcast_packet(AllPids, Packet, ?notice_priority),
            ?rpc_SetNoticeResult_SUCCESS;
        _ ->
            ?rpc_SetNoticeResult_FAILED
    end.

del_item(NoticeInfo) ->
    DelID = NoticeInfo#notice_item.id,
    OldList = get_list(),
    NewList = lists:filter(
        fun(E) ->
            E#notice_item.id =/= DelID
        end,
        OldList
    ),
    io_helper:format("NewList:~p~n", [NewList]),
    case NewList =:= OldList of
        true ->
            ?rpc_SetNoticeResult_FAILED;
        false ->
            set_notice_list(NewList),
            Packet = #notify_notice_item_del{del_id = NoticeInfo#notice_item.id},
            AllPids= [ X || {_, X} <- lists:filter(fun({_, X}) -> X =/= undefined end, redis_extend:get_members_info(online_roleid_set,role_pid_mapping))],
            io_helper:format("Packet:~p~n", [Packet]),
            broadcast_server:broadcast_packet(AllPids, Packet, ?notice_priority),
            ?rpc_SetNoticeResult_SUCCESS
    end.

modify_item(NoticeInfo) ->
    OldList = get_list(),
    ModifyID = NoticeInfo#notice_item.id,
    NewList = lists:keyreplace(ModifyID, #notice_item.id, OldList, NoticeInfo),
    io_helper:format("NewList:~p~n", [NewList]),
    case NewList =:= OldList of
        true ->
            ?rpc_SetNoticeResult_FAILED;
        false ->
            set_notice_list(NewList),
            ?rpc_SetNoticeResult_SUCCESS
    end.

get_list() ->
    get_notice_list_in_cache().
%%     case get(notice_list) of
%%         undefined ->
%%             CacheInfo = get_notice_list_in_cache(),
%%             put(notice_list, CacheInfo),
%%             CacheInfo;
%%         Info ->
%%             Info
%%     end.

get_notice_list_in_cache() ->
    case redis:get("notice_list") of
        undefined ->
            [];
        Info ->
            Info
    end.

set_notice_list(NoticeList) ->
%%     put(notice_list, NoticeList),
    redis:set("notice_list", NoticeList),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求公告列表
%% @end
%%--------------------------------------------------------------------

proc_req_req_notice_list(#req_notice_list{}) ->
    notify_list().
%%--------------------------------------------------------------------
%% @doc
%% @spec 请求公告详情
%% @end
%%--------------------------------------------------------------------
proc_req_notice_item_detail(#req_notice_item_detail{id = ID}) ->
    case can_get_detail(ID) of
        true ->
            case get_notice_item_detail(ID) of
                {true, Info} ->
                    set_send_detail_list(ID),
                    packet:send(#notify_notice_item_detail{result = ?common_success, item_info = Info});
                false ->
                    packet:send(#notify_notice_item_detail{result = ?common_failed})
            end;
        false ->
            packet:send(#notify_notice_item_detail{result = ?common_failed})
    end.

get_notice_item_detail(ID) ->
    List = get_list(),
    case lists:keyfind(ID, #notice_item.id, List) of
        false ->
            io_helper:format("notice data error, can't get id:~p~n", [ID]),
            false;
        Item ->
            {true, trans_to_detail_format(Item)}
    end.

can_get_detail(ID) ->
    List =  get_send_detail_list(),
    lists:all(fun(E) -> ID =/= E end, List).

get_send_detail_list() ->
    case redis:hget("notice:send_detail_list", player:get_role_id()) of
        undefined ->
            [];
        List ->
            List
    end.

set_send_detail_list(ID) ->
    OldList = get_send_detail_list(),
    redis:hset("notice:send_detail_list", player:get_role_id(), [ID| OldList]).

del_send_notice_detail_list() ->
    %%io_helper:format("del_send_notice_detail_list"),
    redis:hdel("notice:send_detail_list", player:get_role_id()).

%%%===================================================================
%%% Internal functions
%%%===================================================================
