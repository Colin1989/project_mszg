%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc 兑换码兑换相关
%%%
%%% @end
%%% Created : 22 Jul 2014 by whl <>
%%%-------------------------------------------------------------------
-module(redeem_code).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").

-include("thrift/rpc_types.hrl").

%% API
-export([send_reward/2,
	 start/0,
	 proc_req_convert_cdkey/1,
         set_CDKey_reward_item/2
	]).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    packet:register(?msg_req_convert_cdkey, {?MODULE, proc_req_convert_cdkey}).


proc_req_convert_cdkey({server, #req_convert_cdkey{award_id = RewardID}}) ->
    case get_reward_info(RewardID) of
        false ->
            erlang:error({"can't find cdkey reward, id:", RewardID}),
            ?rpc_ConvertResult_FAILED;
        {true, {RewardIDs, RewardAmounts}} ->
            reward:give(RewardIDs, RewardAmounts, ?st_redeem_code_award),
            RewardInfo = lists:zipwith(fun(X, Y) -> #award_item{temp_id = X, amount = Y} end, RewardIDs, RewardAmounts),
            packet:send(#notify_redeem_cdoe_result{awards = RewardInfo}),
            ?rpc_ConvertResult_SUCCESS
    end.


%%--------------------------------------------------------------------
%% @doc
%% @spec 设置奖励项
%% @end
%%--------------------------------------------------------------------
set_CDKey_reward_item(OptType, CDKeyItem) ->
    Result = case OptType of
                 ?rpc_CDKeyItemOptType_ADD ->
                     add_item(CDKeyItem);
                 ?rpc_CDKeyItemOptType_DEL ->
                     del_item(CDKeyItem);
                 ?rpc_CDKeyItemOptType_MODIFY ->
                     modify_item(CDKeyItem)
             end,
    Result.


add_item(CDKeyItem) ->
    OldList = get_reward_list_in_cache(),
    case lists:keyfind(CDKeyItem#cDKey_reward_item.id, #cDKey_reward_item.id, OldList) of
        false ->
            NewList = [CDKeyItem | OldList],
            set_reward_list(NewList),
            io_helper:format("NewList:~p~n", [NewList]),
            ?rpc_SetCDKeyItemResult_SUCCESS;
        _ ->
            ?rpc_SetCDKeyItemResult_FAILED
    end.

del_item(CDKeyItem) ->
    DelID = CDKeyItem#cDKey_reward_item.id,
    OldList = get_reward_list_in_cache(),
    NewList = lists:filter(
        fun(E) ->
            E#cDKey_reward_item.id =/= DelID
        end,
        OldList
    ),
    io_helper:format("NewList:~p~n", [NewList]),
    case NewList =:= OldList of
        true ->
            ?rpc_SetCDKeyItemResult_FAILED;
        false ->
            set_reward_list(NewList),
            ?rpc_SetCDKeyItemResult_SUCCESS
    end.

modify_item(CDKeyItem) ->
    OldList = get_reward_list_in_cache(),
    ModifyID = CDKeyItem#cDKey_reward_item.id,
    NewList = lists:keyreplace(ModifyID, #cDKey_reward_item.id, OldList, CDKeyItem),
    io_helper:format("NewList:~p~n", [NewList]),
    case NewList =:= OldList of
        true ->
            ?rpc_SetCDKeyItemResult_FAILED;
        false ->
            set_reward_list(NewList),
            ?rpc_SetCDKeyItemResult_SUCCESS
    end.

%% get_list() ->
%%     case get(cdkey_reward_list) of
%%         undefined ->
%%             CacheInfo = get_reward_list_in_cache(),
%%             put(cdkey_reward_list, CacheInfo),
%%             CacheInfo;
%%         Info ->
%%             Info
%%     end.

get_reward_list_in_cache() ->
    case redis:get("CDKey_reward_list") of
        undefined ->
            [];
        Info ->
            Info
    end.

set_reward_list(RewardList) ->
    %%put(cdkey_reward_list, RewardList),
    redis:set("CDKey_reward_list", RewardList),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 发放奖励
%% @end
%%--------------------------------------------------------------------
send_reward(RoleID, RewardID) ->
    case role_pid_mapping:get_pid(RoleID) of
	undefined ->
	    ?rpc_ConvertResult_FAILED;
	_Pid ->
	    PlayerPid = role_pid_mapping:get_player_pid(RoleID),
	    try
		case gen_server:call(PlayerPid, {from_service, #req_convert_cdkey{award_id = RewardID}}) of
		    Result when is_integer(Result) ->
			Result;
		    _ ->
			?rpc_ConvertResult_FAILED
		end
	    catch
	        _:_ ->
		    ?rpc_ConvertResult_FAILED
	    end
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec 通知客户端物品奖励
%% @end
%%--------------------------------------------------------------------
%% notify_to_client(RewardInfo, Pid) ->
%% 	packet:send(Pid, #notify_redeem_cdoe_result{awards = RewardInfo}).


get_reward_info(RewardID) ->
%%     List = get_reward_list_in_cache(),
%%     case lists:keyfind(RewardID, #cDKey_reward_item.id, List) of
%%         false ->
%%             false;
%%         Info ->
%%             {true, {Info#cDKey_reward_item.reward_ids, Info#cDKey_reward_item.reward_amounts}}
%%     end.
    RewardIDs = get_tplt_reward_ids(RewardID),
    RewardAmounts = get_tplt_reward_amounts(RewardID),
    {true, {RewardIDs, RewardAmounts}}.
%%--------------------------------------------------------------------
%% @doc
%% @spec 模版相关
%% @end
%%--------------------------------------------------------------------
%%
get_tplt(ID) ->
	tplt:get_data(redeem_code_reward_tplt, ID).

get_tplt_reward_ids(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#redeem_code_reward_tplt.reward_ids.

get_tplt_reward_amounts(ID) ->
	TpltInfo = get_tplt(ID),
	TpltInfo#redeem_code_reward_tplt.reward_amounts.
