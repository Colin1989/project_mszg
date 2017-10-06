%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created : 28 Apr 2014 by whl <>
%%%-------------------------------------------------------------------
-module(tutorial).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").
-include("event_def.hrl").

%% API
-export([start/0,
         notify_tutorial_progress/0,
         proc_req_set_tutorial_progress/1]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_set_tutorial_progress, {?MODULE, proc_req_set_tutorial_progress}),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
notify_tutorial_progress() ->
    Progress = get_progress_list(),
    packet:send(#notify_tutorial_progress{progress = Progress}).

proc_req_set_tutorial_progress(#req_set_tutorial_progress{progress = Progress}) ->
    ProgressList = get_progress_list(),
    case check_group_finish(ProgressList, Progress) of
	true ->
	    packet:send(#notify_set_tutorial_progress_result{result = ?common_failed});
	false ->
	    NewProgressList = [Progress|ProgressList],
	    cache:set(tutorial_progress, player:get_role_id(), NewProgressList),
	    log:create(tutorial_log, [player:get_role_id(), Progress, erlang:localtime()]),
	    give_need_item(Progress),
	    packet:send(#notify_set_tutorial_progress_result{result = ?common_success})
    end.
    %% NewProgressList = [Progress | (ProgressList -- [Progress])],
    %% RoleID = player:get_role_id(),
    %% cache:set(tutorial_progress, RoleID, NewProgressList),
    %% packet:send(#notify_set_tutorial_progress_result{result = ?common_success}).

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%校验是否已完成
check_group_finish(Status, GroupId) ->
    case lists:filter(fun(X) ->
			      X =:= GroupId
		      end, Status) of
	[] ->
	    false;
	_ ->
	    true
    end.
%%发放引导所需物品
give_need_item(Progress)->
    GroupInfo = tplt:get_data(tutorial_item_tplt, Progress),
    case GroupInfo#tutorial_item_tplt.gift_bag_id of
	0 ->
	    ok;
	GiftBagId ->
	    Data = tplt:get_data(gift_bag_tplt, GiftBagId),
	    reward:give(Data#gift_bag_tplt.item_id, Data#gift_bag_tplt.item_amount, ?st_tutorial)
    end.

get_progress_list() ->
    RoleID = player:get_role_id(),
    case cache:get(tutorial_progress, RoleID) of
	[] ->
	    [];
	[{_, ProgressInfo}] ->
	    ProgressInfo
    end.
