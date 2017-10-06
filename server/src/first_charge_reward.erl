%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc Ê×³å½±Àø
%%%
%%% @end
%%% Created : 15 Jul 2014 by whl <>
%%%-------------------------------------------------------------------
-module(first_charge_reward).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").

%% API
-export([start/0,
		 notify_first_charge_info/0,
		 get_reward_status/0]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
	packet:register(?msg_req_first_charge_reward, {?MODULE, proc_req_first_charge_reward}),
	ok.


%%--------------------------------------------------------------------
%% @doc
%% @spec Í¨ÖªÊ×³åÐÅÏ¢
%% @end
%%--------------------------------------------------------------------
notify_first_charge_info() ->
	Status = get_reward_status(),
	packet:send(#notify_first_charge_info{status = Status}),
	ok.


%%%===================================================================
%%% Internal functions
%%%===================================================================
proc_req_first_charge_reward(#req_first_charge_reward{}) ->
	case get_reward_status() of
		?charget_not_rewarded ->
			send_reward(),
			redis:hset("recharge:first_charge_is_rewarded", player:get_player_id(), 1),
			packet:send(#notify_first_charge_reward_result{result = ?common_success});
		_Other ->
			packet:send(#notify_first_charge_reward_result{result = ?common_failed})
	end.

get_reward_status() ->
	UserID = player:get_player_id(),
	case recharge:get_user_recharge_times() of %% Ê×³åË«±¶½±Àø
		0 ->
			?not_charge;
		_Other ->
			case redis:hget("recharge:first_charge_is_rewarded", UserID) of %% Ê×³åË«±¶½±Àø
				undefined ->
					?charget_not_rewarded;
				_Rewarded ->
					?rewarded
			end
	end.

send_reward() ->
	ID1 = config:get(first_charge_reward_item1_id),
	Amount1 = config:get(first_charge_reward_item1_amount),
	ID2 = config:get(first_charge_reward_item2_id),
	Amount2 = config:get(first_charge_reward_item2_amount),
	ID3 = config:get(first_charge_reward_item3_id),
	Amount3 = config:get(first_charge_reward_item3_amount),
	ID4 = config:get(first_charge_reward_item4_id),
	Amount4 = config:get(first_charge_reward_item4_amount),

	reward:give([ID1, ID2, ID3, ID4], [Amount1, Amount2, Amount3, Amount4], ?st_first_charge).
