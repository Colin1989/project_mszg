%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 22 May 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(benison).


-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("common_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").

-define(benison_no_active, 1).
-define(benison_active, 2).
-define(benison_outof_date, 3).
-record(benison_info, {id = 0, status = ?benison_no_active}).
-record(benison_buff_info, {id = 0, ids = [], active_time = erlang:localtime(), duration = 0}).
%% API
-export([start/0, 
	 proc_req_benison_list/1,
	 proc_req_bless/1,
	 proc_req_refresh_benison_list/1]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    packet:register(?msg_req_benison_list, {?MODULE, proc_req_benison_list}),
    packet:register(?msg_req_bless, {?MODULE, proc_req_bless}),
    packet:register(?msg_req_refresh_benison_list, {?MODULE, proc_req_refresh_benison_list}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求祝福列表
%% @end
%%--------------------------------------------------------------------
proc_req_benison_list(Packet) ->
    io_helper:format("~p~n", [Packet]),
    BenisonList = get_benison_list(),
    notify_benison_list(BenisonList),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求祝福列表
%% @end
%%--------------------------------------------------------------------
proc_req_bless(#req_bless{benison_id = BenisonId} = Packet) ->
    io_helper:format("~p~n", [Packet]),
    BenisonList = get_benison_list(),
    case lists:keyfind(BenisonId, #benison_info.id, BenisonList) of
	false ->
	    packet:send(#notify_bless_result{result = ?common_failed}),
	    sys_msg:send_to_self(?sg_benison_bless_id_not_exist, []);
	Benison ->
	    BenisonData = tplt:get_data(benison_tplt, BenisonId),
	    case player_role:check_emoney_enough(BenisonData#benison_tplt.need_emoney) of
		true ->
		    case Benison#benison_info.status of
			?benison_no_active ->
			    player_role:reduce_emoney(?st_bless, BenisonData#benison_tplt.need_emoney),
			    activeness_task:update_activeness_task_status(benison),
			    process_bless(BenisonList, Benison, BenisonData),
			    packet:send(#notify_bless_result{result = ?common_success});
			_ ->
			    packet:send(#notify_bless_result{result = ?common_failed}),
			    sys_msg:send_to_self(?sg_benison_bless_has_active, [])
		    end;
		false ->
		    packet:send(#notify_bless_result{result = ?common_failed}),
		    sys_msg:send_to_self(?sg_benison_bless_emoney_not_enough, [])
	    end
    end,
    ok.


process_bless(OrgList, Benison, #benison_tplt{id = BenisonId, status_ids = Ids, duration = Duration}) ->
    NewList = lists:keyreplace(BenisonId, #benison_info.id, OrgList, Benison#benison_info{status = ?benison_active}),
    NewBuff = #benison_buff_info{id = BenisonId, ids = Ids, duration = Duration, active_time = erlang:localtime()},
    update_my_benison_buff(NewBuff),
    packet:send(#notify_role_bless_buff{benison_id = BenisonId, buffs = Ids, time_left = Duration}),
    update_benison_list(NewList).


%%--------------------------------------------------------------------
%% @doc
%% @spec 请求祝福列表
%% @end
%%--------------------------------------------------------------------
proc_req_refresh_benison_list(Packet) ->
    io_helper:format("~p~n", [Packet]),
    NeedGold = config:get(refresh_benison_list_gold_need),
    case player_role:check_gold_enough(NeedGold) of
	true ->
	    player_role:reduce_gold(?st_refresh_benison_list, NeedGold),
	    BenisonList = rand_benison_list(3),
	    packet:send(#notify_refresh_benison_list_result{result = ?common_success}),
	    notify_benison_list(BenisonList);
	false ->
	    packet:send(#notify_refresh_benison_list_result{result = ?common_failed}),
	    sys_msg:send_to_self(?sg_benison_refresh_not_enough_gold, [])
    end.

    



%%%===================================================================
%%% Internal functions
%%%===================================================================

notify_benison_list(BenisonList) ->
    {Benisons, Status} = lists:foldr(fun(X, {B, S})-> 
					     #benison_info{id = Id, status = Status} = X,
					     {[Id|B], [Status|S]}
				     end, {[], []}, BenisonList),
    packet:send(#notify_benison_list{benison_list = Benisons, benison_status = Status}).

%%获得祝福列表
get_benison_list()->
    case redis:hget('benison:mybenison_list', player:get_role_id()) of
	undefined ->
	    rand_benison_list(3);
	BenisonList ->
	    BenisonList
    end.


%%随机祝福列表
rand_benison_list(Amount)->
    AllBenisonList = tplt:get_all_data(benison_tplt),
    RandRes = rand:rand_members_from_list_not_repeat(AllBenisonList, Amount),
    BenisonList = [#benison_info{id = X#benison_tplt.id, status = ?benison_no_active} || X <- RandRes],
    %%redis:hset('benison:mybenison_list', player:get_role_id(), BenisonList),
    cache_with_expire:set('benison:mybenison_list', player:get_role_id(), BenisonList, day),
    BenisonList.

%%更新我的祝福列表信息
update_benison_list(NewList) ->
    redis:hset('benison:mybenison_list', player:get_role_id(), NewList),
    notify_benison_list(NewList).


%%获取我的祝福buff信息
get_my_benison_buff()->
    case redis:hget('benison:my_buff', player:get_role_id()) of
	undefined ->
	    undefined;
	BenisonBuffInfo ->
	    #benison_buff_info{id = Id, ids = Ids, active_time = ActiveTime, duration = Duration} = BenisonBuffInfo,
	    PassTime = datetime:datetime_to_gregorian_seconds(erlang:localtime()) - 
				   datetime:datetime_to_gregorian_seconds(ActiveTime),
	    case PassTime > Duration of
		true ->
		    redis:hdel('benison:my_buff', player:get_role_id()),
		    undefined;
		false ->
		    {Id, Ids, Duration - PassTime}
	    end
    end.

%%更新我的祝福BUFF信息
update_my_benison_buff(NewInfo) ->
    redis:hset('benison:my_buff', player:get_role_id(), NewInfo).



notify_benison_buff()->
    case get_my_benison_buff() of
	undefined ->
	    packet:send(#notify_role_bless_buff{benison_id = 0, buffs = [], time_left = 0});
	{Id, Buffs, TimeLeft} ->
	    packet:send(#notify_role_bless_buff{benison_id = Id, buffs = Buffs, time_left = TimeLeft})
    end.
    


