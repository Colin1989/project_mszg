%%%-------------------------------------------------------------------
%%% @author whl <>
%%% @copyright (C) 2014, whl
%%% @doc
%%%
%%% @end
%%% Created : 28 Apr 2014 by whl <>
%%%-------------------------------------------------------------------
-module(summon_stone).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("tplt_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("record_def.hrl").
-include("event_def.hrl").

%% API
-export([start/0,
         proc_req_daily_summon_stone/1,
         proc_req_buy_summon_stone/1]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================
start()->
  packet:register(?msg_req_daily_summon_stone, {?MODULE,proc_req_daily_summon_stone}),
  packet:register(?msg_req_buy_summon_stone, {?MODULE,proc_req_buy_summon_stone}),
  ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 请求获取每日召唤石
%% @end
%%--------------------------------------------------------------------
proc_req_daily_summon_stone(#req_daily_summon_stone{}) ->
  RoleID = player:get_role_id(),
  case cache:get(daily_awarded_summon_stone_list, RoleID) of
    [] ->
      cache_with_expire:set(daily_awarded_summon_stone_list, RoleID, 1, day),
      Amount = config:get(daily_award_summon_stone_amount),
      player_role:add_summon_stone(?st_test, Amount),
      packet:send(#notify_daily_summon_stone{result = ?common_success});
    _ ->
      packet:send(#notify_daily_summon_stone{result = ?common_failed}),
      sys_msg:send_to_self(?sg_summon_stone_already_award, [])
  end,
  ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec 购买召唤石
%% @end
%%--------------------------------------------------------------------
proc_req_buy_summon_stone(#req_buy_summon_stone{}) ->
  HasBuyTimes = get_buy_times(),
  NeedEmoney = get_buy_need_emoney(HasBuyTimes),
  case player_role:check_emoney_enough(NeedEmoney) of
    true ->
      increase_buy_times(),
      AddCount = config:get(buy_summon_stone_amount),
      player_role:add_summon_stone(?st_test, AddCount),
      player_role:reduce_emoney(?st_test, NeedEmoney),
    packet:send(#notify_buy_summon_stone{result = ?common_success});
    false ->
      packet:send(#notify_buy_summon_stone{result = ?common_failed}),
      sys_msg:send_to_self(?sg_summon_stone_emoney_not_enough_to_buy, [])
  end.

notify_summon_stone_info() ->
  RoleID = player:get_role_id(),
  IsAward = case cache:get(daily_awarded_summon_stone_list, RoleID) of
              [] ->
                0;
              _ ->
                1
            end,
  HasBuyTime = get_buy_times(),
  packet:send(#notify_summon_stone_info{is_award = IsAward, has_buy_times = HasBuyTime}),
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================

increase_buy_times() ->
  RoleID = player:get_role_id(),
  cache_with_expire:increase(buy_summon_stone_times, RoleID, day),
  ok.

get_buy_times() ->
  RoleID = player:get_role_id(),
  case cache_with_expire:get(buy_summon_stone_times, RoleID) of
    [] -> 0;
    [Times | _] -> element(2, Times)
  end.


get_buy_need_emoney(Times) ->
    Fun = (tplt:get_data(expression_tplt, 15))#expression_tplt.expression,
    Fun([{'Times', Times}]).
