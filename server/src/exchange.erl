%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created :  8 Jul 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(exchange).

-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").

%% API
-export([start/0,
	proc_req_exchange_item/1,
	proc_req_emoney_2_gold/1,
	check_exchange_item_enough/2,
	delete_need_items/5]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_exchange_item, {?MODULE, proc_req_exchange_item}),
    packet:register(?msg_req_emoney_2_gold, {?MODULE, proc_req_emoney_2_gold}),
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
proc_req_exchange_item(#req_exchange_item{exchange_id = Id} = _Packet) ->
    NeedPassCopyID = game_copy:get_func_unlock_need_copy_id(22),
    case game_copy:check_copy_has_passed(NeedPassCopyID) of
	true ->
	    #exchange_item_tplt{aim_item_id = AimId,
				aim_item_amount = AimAmount,
				need_items = NeedItems,
				need_amounts = NeedAmounts} = tplt:get_data(exchange_item_tplt, Id),
	    case check_exchange_item_enough(NeedItems, NeedAmounts) of
		true ->
		    delete_need_items(?st_exchange_item, NeedItems, NeedAmounts, [], []),
		    reward:give([AimId], [AimAmount], ?st_exchange_item),
		    packet:send(#notify_exchange_item_result{result = ?common_success});
		false ->
		    sys_msg:send_to_self(?sg_exchange_item_not_enough, []),
		    packet:send(#notify_exchange_item_result{result = ?common_failed})
	    end;
	false ->
	    packet:send(#notify_exchange_item_result{result = ?common_failed}),
	    sys_msg:send_to_self(?sg_game_copy_not_pass, [])
    end.


%%%===================================================================
%%% Internal functions
%%%===================================================================

check_exchange_item_enough(NeedItems, NeedAmounts) ->
    case check_items_enough(NeedItems, NeedAmounts) of
	true ->
	    true;
	false ->
	    false
    end.




check_items_enough([], []) ->
    true;
check_items_enough([Id|Ids], [Amount|Amounts]) ->
    #reward_item_tplt{type = Type, temp_id = [TempId]} = tplt:get_data(reward_item_tplt, Id),
    case Type of
	1 ->
	    case player_role:check_gold_enough(Amount) of
		true ->
		    check_items_enough(Ids, Amounts);
		false ->
		    false
	    end;
	5 ->
	    case player_role:check_point_enough(Amount) of
		true ->
		    check_items_enough(Ids, Amounts);
		false ->
		    false
	    end;
	7 ->
	    case check_item_enough(TempId, Amount) of
		true ->
		    check_items_enough(Ids, Amounts);
		false ->
		    false
	    end;
	12 ->
				case player_role:check_battle_soul(Amount) of
					true ->
						check_items_enough(Ids, Amounts);
					false ->
						false
				end
    end.

check_item_enough(Id, Amount) ->
    [{Id, A}] = player_pack:get_items_count([Id]),
    A >= Amount.









%%删除
delete_need_items(SourceType, [], [], Items, _Sculptures) ->
    player_pack:delete_items(SourceType, Items);

delete_need_items(SourceType, [NeedItem|ItemsLeft], [NeedAmount|Amounts], Items, Sculptures) ->
    case delete_need_item(SourceType, NeedItem, NeedAmount) of
	{7, TempId} ->
	    delete_need_items(SourceType, ItemsLeft, Amounts, [{TempId,NeedAmount}|Items], Sculptures);
	{8, TempId} ->
	    delete_need_items(SourceType, ItemsLeft, Amounts, Items, [{TempId,NeedAmount}|Sculptures]);
	_ ->
	    delete_need_items(SourceType, ItemsLeft, Amounts, Items, Sculptures)
    end.


delete_need_item(SourceType, NeedItem, NeedAmount) ->
    #reward_item_tplt{type = Type, temp_id = [TempId]} = tplt:get_data(reward_item_tplt, NeedItem),
    case Type of
	1 ->%%金币
	    player_role:reduce_gold(SourceType, NeedAmount),
	    1;
	5 ->%%积分
	    player_role:reduce_point(SourceType, NeedAmount),
	    5;
	12 ->%%战魂
				player_role:reduce_battle_soul(SourceType, NeedAmount),
				5;
	7 ->%%物品
	    {7, TempId}
    end.



%%--------------------------------------------------------------------
%% @doc
%% @处理金币转换
%% @end
%%--------------------------------------------------------------------
proc_req_emoney_2_gold(#req_emoney_2_gold{emoney = Emoney}) ->
	case player_role:check_emoney_enough(Emoney) of
		true ->
			GetGold = Emoney * config:get(emoney_2_gold_count),
			player_role:add_gold(?st_emoney_2_gold,GetGold),
			player_role:reduce_emoney(?st_emoney_2_gold, Emoney),
			packet:send(#notify_emoney_2_gold_result{result = ?common_success});
		false ->
			packet:send(#notify_emoney_2_gold_result{result = ?common_failed})
	end.

