%%%-------------------------------------------------------------------
%%% @author shenlk <>
%%% @copyright (C) 2014, shenlk
%%% @doc
%%%
%%% @end
%%% Created : 13 Sep 2014 by shenlk <>
%%%-------------------------------------------------------------------
-module(mooncard).

-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("enum_def.hrl").
-include("common_def.hrl").
-include("sys_msg.hrl").


-record(mooncard_info, {type = 0, days_remain = 0, last_get_time = datetime:datetime_to_gregorian_seconds({erlang:date(), {0,0,0}})}).
%% API
-export([start/0, 
	 proc_req_buy_mooncard/1, 
	 proc_req_get_mooncard_daily_award/1, 
	 get_mooncard_info/0,
	 increase_remain_days/2,
	 increase_remain_days/3,
	 proc_notify_mooncard_info/0,
    is_mooncard_player/0]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_buy_mooncard, {?MODULE, proc_req_buy_mooncard}),
    packet:register(?msg_req_get_mooncard_daily_award, {?MODULE, proc_req_get_mooncard_daily_award}),
    ok.


%%通知客户端月卡信息
proc_notify_mooncard_info() ->
    activity_lottery:proc_moon_card_user(), %% 抽奖活动增加次数
    UserId = player:get_player_id(),
    MoonCardInfo = get_mooncard_info(),
    io_helper:format("MoonCardInfo:~p~n", [MoonCardInfo]),
    S = case redis:hget("mooncard:has_gotten", UserId) of
	    undefined ->
		1;
	    _ ->
		2
	end,
    packet:send(#notify_mooncard_info{days_remain = MoonCardInfo#mooncard_info.days_remain, award_status = S}).

%%购买月卡
proc_req_buy_mooncard({server, #req_buy_mooncard{type = Type, reward_emoney = RewardEmoney}}) ->
    increase_remain_days(Type, RewardEmoney),
    ok.

%%领取每日奖励
proc_req_get_mooncard_daily_award(_Packet) ->
    UserId = player:get_player_id(),
    MoonCardInfo = get_mooncard_info(),
    case redis:hget("mooncard:has_gotten", UserId) of
	undefined ->
	    case MoonCardInfo#mooncard_info.days_remain of
		D when D =< 0 ->
		    sys_msg:send_to_self(?sg_mooncard_daily_award_disable, []),
		    packet:send(#notify_get_mooncard_daily_award_result{result = ?common_failed});
		_ ->
		    AwardInfo = tplt:get_data(mooncard_daily_award_tplt, MoonCardInfo#mooncard_info.type),
		    cache_with_expire:increase("mooncard:has_gotten", UserId, day),
		    reward:give(AwardInfo#mooncard_daily_award_tplt.award_ids, AwardInfo#mooncard_daily_award_tplt.amount, ?st_mooncard_daily_card),
		    packet:send(#notify_get_mooncard_daily_award_result{result = ?common_success})
	    end;
	_ ->
	    sys_msg:send_to_self(?sg_mooncard_daily_award_gotten, []),
	    packet:send(#notify_get_mooncard_daily_award_result{result = ?common_failed})
    end,
    ok.

%%获取月卡剩余天数
get_mooncard_info() ->
    UserId = player:get_player_id(),
    get_mooncard_info(UserId).

get_mooncard_info(UserId) ->
    case redis:hget("mooncard:remain_days", UserId) of
	undefined ->
	    #mooncard_info{};
	Info = #mooncard_info{days_remain = Days, last_get_time = LastGet} ->
	    DaysPass = (datetime:datetime_to_gregorian_seconds(erlang:localtime()) - LastGet) div 86400,
	    case DaysPass of
		0 ->
		    Info;
		_ ->
		    case Days - DaysPass of
			DaysLeft when DaysLeft > 0 ->
			    NewInfo = Info#mooncard_info{days_remain = DaysLeft, last_get_time = 
							      datetime:datetime_to_gregorian_seconds({erlang:date(), {0,0,0}})},
			    redis:hset("mooncard:remain_days", UserId, NewInfo),
			    NewInfo;
			_ ->
			    redis:hdel("mooncard:remain_days", UserId),
			    #mooncard_info{}
		    end
	    end
    end.



increase_remain_days(Type, RewardEmoney) ->
    UserId = player:get_player_id(),
    increase_remain_days(UserId, Type, RewardEmoney),
    {AddEmoney, NewMoney, _VipLevel} = process_get_recharge_info(UserId,Type, RewardEmoney),
    player_role:add_emoney(?st_mooncard_buy_reward, AddEmoney),
    packet:send(#notify_role_info_change{type = "money", new_value = trunc(NewMoney)}),
    %%player_role:update_vip_level(player_role:get_user(UserId), VipLevel),
    case first_charge_reward:get_reward_status() of %% 是首冲时，通知可领取首冲奖励
        ?charget_not_rewarded ->
            packet:send(#notify_first_charge_info{status = ?charget_not_rewarded});
        _ ->
            ok
    end,
    proc_notify_mooncard_info(),
    ok.

increase_remain_days(UserId, Type, RewardEmoney) ->
    AwardInfo = tplt:get_data(mooncard_daily_award_tplt, Type),
    MooncardInfo = get_mooncard_info(UserId),
    redis:hset("mooncard:remain_days", 
	       UserId, 
	       #mooncard_info{days_remain = MooncardInfo#mooncard_info.days_remain + AwardInfo#mooncard_daily_award_tplt.day_amount, 
							      last_get_time = 
				  datetime:datetime_to_gregorian_seconds({erlang:date(), {0,0,0}}), 
							      type = Type}),
    case player:get_player_id() of
	UserId ->
	    ok;
	_ ->
            {AddEmoney, _NewMoney, _VipLevel} = process_get_recharge_info(UserId,Type, RewardEmoney),
	    [User] = db:find(db_user, [{user_id, 'equals', UserId}]),
            _NewUser = player_role:update_emoney_with_log(User, AddEmoney, ?st_mooncard_buy_reward)
            %%player_role:update_vip_level(NewUser, VipLevel, no_notify)
    end.

process_get_recharge_info(UserId, RechargeID, RewardEmoney) ->
    TpltInfo = tplt:get_data(recharge_tplt, RechargeID),
    ChargeMoney = TpltInfo#recharge_tplt.money,
    AddEmoney = case redis:hget("recharge:total_times", UserId) of %% 首冲双倍奖励
                    undefined ->
                        RewardEmoney * 2;
                    _Other ->
                        RewardEmoney
                end,
    CurMoney = recharge:get_user_money(UserId),
    NewMoney = CurMoney + ChargeMoney,
    VipLevel = vip:get_new_level(UserId, NewMoney),

    redis:hset("recharge:total_use_money", UserId, NewMoney),
    redis:hincrby("recharge:total_times", UserId, 1),

    {AddEmoney, NewMoney, VipLevel}.
%%--------------------------------------------------------------------
%% @doc
%% @spec 是否月卡用户
%% @end
%%--------------------------------------------------------------------
is_mooncard_player() ->
    CardInfo = get_mooncard_info(),
    CardInfo#mooncard_info.days_remain > 0.

%%%===================================================================
%%% Internal functions
%%%===================================================================
