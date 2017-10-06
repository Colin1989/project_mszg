%%%-------------------------------------------------------------------
%%% @author lixc <>
%%% @copyright (C) 2014, lixc
%%% @doc
%%%
%%% @end
%%% Created :  6 Jan 2014 by lixc <>
%%%-------------------------------------------------------------------
-module(player_power_hp).

-include("packet_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-include("tplt_def.hrl").
%% API
-export([start/0,get_buy_times/0]).

%%%===================================================================
%%% API
%%%===================================================================
start() ->
    packet:register(?msg_req_buy_power_hp, fun proc_req_buy_power_hp/1),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @消耗体力
%% @end
%%--------------------------------------------------------------------
proc_req_buy_power_hp(#req_buy_power_hp{}=_Pack) ->
    RoleId = player:get_role_id(),
    Times = get_buy_times(RoleId),
    case check_whether_limit_exceeded(RoleId,Times) of
	true -> 
	    Price=get_power_hp_price(Times),
	    case player_role:check_emoney_enough(Price) of
		true ->
		    process_power_hp_buy(RoleId,Price),
		    packet:send(#notify_buy_power_hp_result{result=?common_success});
		false ->
		    packet:send(#notify_buy_power_hp_result{result=?common_failed}),
		    sys_msg:send_to_self(?sg_power_hp_emoney_not_enough,[])
	    end;
	false -> 
	    packet:send(#notify_buy_power_hp_result{result=?common_failed}),
	    sys_msg:send_to_self(?sg_power_hp_limit_exceeded,[])
    end.	
    %%RoleId = player:get_role_id(),
    %%CostHp = config:get(cost_power_hp),
    %%{Result,Power_hp} = power_hp:cost_hp(RoleId,CostHp),
    %%Pack1=#notify_power_hp_msg{result=Result,power_hp=Power_hp},
    %%packet:send(Pack1).
    
get_buy_times()->    
    RoleId=player:get_role_id(),
    get_buy_times(RoleId).
    
    
	    
%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @获得今天已购买次数
%% @end
%%--------------------------------------------------------------------
get_buy_times(RoleId)->
    Times=case cache_with_expire:get(power_hp_buy_times,RoleId) of
	      [] -> 0;
	      [Timeds|_] ->element(2,Timeds)
	  end,
    Times.

%%--------------------------------------------------------------------
%% @doc
%% @获取价格
%% @end
%%--------------------------------------------------------------------
%% get_power_hp_price(TheTime)->
%%     PriceInfo=tplt:get_data(power_hp_price,TheTime),
%%     PriceInfo#power_hp_price.price.


get_power_hp_price(Times) ->
    Fun = (tplt:get_data(expression_tplt, 20))#expression_tplt.expression,
    Fun([{'Times', Times}]).
    


%%--------------------------------------------------------------------
%% @doc
%% @检验今天可购买次数是否已用完
%% @end
%%--------------------------------------------------------------------
check_whether_limit_exceeded(_RoleId,Times)->
    BaseTimes = config:get(base_power_hp_buy_times) + vip:get_privilege_count(8),
    Times < BaseTimes.


%%--------------------------------------------------------------------
%% @doc
%% @购买
%% @end
%%--------------------------------------------------------------------
process_power_hp_buy(RoleId,Price)->
    player_role:reduce_emoney(?st_power_hp,Price),
    %%power_hp:recover_all_pwoer_hp(),
    power_hp:add_power_hp(?st_power_hp, config:get(base_power_hp)),
    cache_with_expire:increase(power_hp_buy_times,RoleId,day),
    ok.
