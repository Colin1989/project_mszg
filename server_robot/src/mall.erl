-module(mall).

-define(mall_item_type_sculpture,2).
-define(mall_item_type_item,1).
-include("packet_def.hrl").
-include("tplt_def.hrl").
-include("enum_def.hrl").
-include("sys_msg.hrl").
-include("common_def.hrl").
-export([start/0,proc_req_buy_mall_item/1,proc_req_has_buy_times/1,get_all_limit_item/0,proc_req_buy_point_mall_item/1]).

start()->
    packet:register(?msg_req_buy_mall_item,{?MODULE,proc_req_buy_mall_item}),
    packet:register(?msg_req_has_buy_times,{?MODULE,proc_req_has_buy_times}),
    packet:register(?msg_req_buy_point_mall_item,{?MODULE,proc_req_buy_point_mall_item}),
    ok.

proc_req_buy_point_mall_item(#req_buy_point_mall_item{mallitem_id=MallItemId, buy_times = Amount})->
    MallItemInfo = tplt:get_data(point_mall_tplt,MallItemId),
    %%Price = MallItemInfo#point_mall_tplt.price,
    case check_point_mall_item_buy_enable(MallItemInfo, Amount) of
	true ->
	    process_buy_mallitem_by_point(MallItemInfo, Amount),
	    packet:send(#notify_buy_point_mall_item_result{result=?common_success});
	FailedType ->
	    packet:send(#notify_buy_point_mall_item_result{result=FailedType})
    end,
    ok.

process_buy_mallitem_by_point(MallItemInfo, Amount)->
    Price = MallItemInfo#point_mall_tplt.price * Amount,
    ItemId = MallItemInfo#point_mall_tplt.item_id,
    %%player_pack:add_items(?st_point_mall_buy, [{ItemId, Amount}]),
    case MallItemInfo#point_mall_tplt.mall_item_type of
	?mall_item_type_item ->
	    %%sculpture:broadcast_buy_item(ItemId),
	    player_pack:add_items(?st_mall_buy,[{ItemId, Amount * MallItemInfo#point_mall_tplt.item_amount}]);
	?mall_item_type_sculpture ->
	    sculpture:broadcast_buy_item(ItemId),
	    sculpture_pack:add_sculptures(?st_mall_buy,[{ItemId, Amount * MallItemInfo#point_mall_tplt.item_amount}]),
	    sculpture_pack:notify_sculpture_pack_change()
    end,
    player_role:reduce_point(?st_point_mall_buy, Price),
    ok.

check_point_mall_item_buy_enable(MallItemInfo, Amount)->
    case MallItemInfo#point_mall_tplt.show =:= ?on_sale of
	true ->
	    case player_role:check_point_enough(MallItemInfo#point_mall_tplt.price * Amount) of
		true ->
		    case military_rank:get_level() >= MallItemInfo#point_mall_tplt.need_rank of
			false ->
			    sys_msg:send_to_self(?sg_point_mall_buy_rank_not_enough,[]),
			    ?common_failed;
			true ->
			    ItemId = MallItemInfo#point_mall_tplt.item_id,
			    case MallItemInfo#point_mall_tplt.mall_item_type of
				?mall_item_type_sculpture ->
				    case not sculpture_pack:check_pack_enough(Amount * MallItemInfo#point_mall_tplt.item_amount) of
					true ->
					    sys_msg:send_to_self(?sg_point_mall_buy_pack_exceeded,[]),
					    ?common_failed;
					false ->
					    true
				    end;
				?mall_item_type_item ->
				    case not player_pack:check_space_enough([{ItemId, Amount * MallItemInfo#point_mall_tplt.item_amount}]) of
					true ->
					    sys_msg:send_to_self(?sg_point_mall_buy_pack_exceeded,[]),
					    ?common_failed;
					false ->
					    true
				    end
			    end
		    end;
		false ->
		    sys_msg:send_to_self(?sg_point_mall_buy_point_not_enough,[]),
		    ?common_error
	    end; 
	false ->
	    sys_msg:send_to_self(?sg_point_mall_buy_not_on_sale,[]),
	    ?common_error
    end.
proc_req_buy_mall_item(#req_buy_mall_item{mallitem_id=MallItemId, buy_times = Amount}=Packet)->
    io_helper:format("~p~n",[Packet]),
    MallItemInfo = tplt:get_data(mall_item,MallItemId),
    Price = get_real_price(MallItemInfo),
    case check_buy_enable(MallItemInfo,Price, Amount) of
	true ->
	    process_buy_mallitem(MallItemInfo,Price,Amount),
	    packet:send(#notify_buy_mall_item_result{result=?common_success});
	FailedType ->
	    packet:send(#notify_buy_mall_item_result{result=FailedType})
    end,
    ok.

proc_req_has_buy_times(_Packet)->
    LimitItemIdList = get_all_limit_item(),
    InfoList = lists:map(fun({Id, Val}) -> 
				 #mall_buy_info{mallitem_id = Id, times = Val}
			 end, cache_with_expire:get('mall_item_buy_times:', LimitItemIdList, player:get_role_id())),
    packet:send(#notify_has_buy_times{buy_info_list = InfoList}).


get_all_limit_item()->
    MallItems = tplt:get_all_data(mall_item),
    lists:map(fun(Item) -> Item#mall_item.id end,lists:filter(fun(X)-> (X#mall_item.buy_limit > 0) and (X#mall_item.show =:= ?on_sale) end,MallItems)).
%%--------------------------------------------------------------------
%% @doc
%% @检测是否能购买
%% @end
%%--------------------------------------------------------------------

check_buy_enable(MallItemInfo,Price, Amount)->
    
    case is_on_sale(MallItemInfo) of
	true ->
	    case check_has_enough_money(MallItemInfo#mall_item.price_type,Price * Amount) of
		true ->
		    case is_buy_times_exceeded(MallItemInfo, Amount) of
			true ->
			    sys_msg:send_to_self(?sg_mall_buy_times_exceeded,[]),
			    ?common_failed;
			false ->
			    ItemId = MallItemInfo#mall_item.item_id,
			    case MallItemInfo#mall_item.mall_item_type of
				?mall_item_type_sculpture ->
				    case not sculpture_pack:check_pack_enough(Amount * MallItemInfo#mall_item.item_amount) of
					true ->
					    sys_msg:send_to_self(?sg_mall_buy_pack_exceeded,[]),
					    ?common_failed;
					false ->
					    true
				    end;
				?mall_item_type_item ->
				    case not player_pack:check_space_enough([{ItemId, Amount * MallItemInfo#mall_item.item_amount}]) of
					true ->
					    sys_msg:send_to_self(?sg_mall_buy_pack_exceeded,[]),
					    ?common_failed;
					false ->
					    true
				    end
			    end
		    end;
		false ->
		    sys_msg:send_to_self(?sg_mall_buy_money_not_enough,[]),
		    ?common_error
	    end; 
	false ->
	    sys_msg:send_to_self(?sg_mall_buy_not_on_sale,[]),
	    ?common_error
    end.


is_on_sale(MallItemInfo)->
    case MallItemInfo#mall_item.show of
	?on_sale ->
	    true;
	?not_on_sale ->
	    false
    end.
%%--------------------------------------------------------------------
%% @doc
%% @判断前是否够
%% @end
%%--------------------------------------------------------------------
check_has_enough_money(Type,Price)->
    case Type of
	?price_type_gold ->
	    player_role:check_gold_enough(Price);
	?price_type_emoney ->
	    player_role:check_emoney_enough(Price)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @获取真实价格
%% @end
%%--------------------------------------------------------------------
get_real_price(MallItemInfo)->
    OrgPrice = MallItemInfo#mall_item.price,
    case MallItemInfo#mall_item.vip_discount of
	0 ->
	    OrgPrice;
	VipDiscount ->
	    case is_vip() of
		true ->
		    (OrgPrice * VipDiscount) div 100; 
		false ->
		    OrgPrice
	    end
    end.

is_vip()->
    false.

%%--------------------------------------------------------------------
%% @doc
%% @处理购买
%% @end
%%--------------------------------------------------------------------

process_buy_mallitem(_MallItemInfo,_Price, Amount)->
    PriceType = _MallItemInfo#mall_item.price_type,
    ItemId = _MallItemInfo#mall_item.item_id,
    case PriceType of
	?price_type_gold ->
	    case _MallItemInfo#mall_item.mall_item_type of
		?mall_item_type_item ->
		    player_pack:add_items(?st_mall_buy,[{ItemId, Amount * _MallItemInfo#mall_item.item_amount}]);
		?mall_item_type_sculpture ->
		    sculpture:broadcast_buy_item(ItemId),
		    sculpture_pack:add_sculptures(?st_mall_buy,[{ItemId, Amount * _MallItemInfo#mall_item.item_amount}]),
		    sculpture_pack:notify_sculpture_pack_change()
	    end,
	    player_role:reduce_gold(?st_mall_buy,_Price * Amount);
	?price_type_emoney ->
	    case _MallItemInfo#mall_item.mall_item_type of
		?mall_item_type_item ->
		    player_pack:add_items(?st_mall_buy,[{ItemId, Amount * _MallItemInfo#mall_item.item_amount}]);
		?mall_item_type_sculpture ->
		    sculpture:broadcast_buy_item(ItemId),
		    sculpture_pack:add_sculptures(?st_mall_buy,[{ItemId, Amount * _MallItemInfo#mall_item.item_amount}]),
		    sculpture_pack:notify_sculpture_pack_change()
	    end,
	    player_role:reduce_emoney(?st_mall_buy,_Price * Amount)
    end,
    case _MallItemInfo#mall_item.buy_limit of
	0 ->
	    ok;
	_ ->
	    cache_with_expire:increase(lists:concat(['mall_item_buy_times:',_MallItemInfo#mall_item.id]),player:get_role_id(),Amount,day)
    end,
    ok.

is_buy_times_exceeded(_MallItemInfo, Amount)->
    BuyTimesLimit = _MallItemInfo#mall_item.buy_limit,
    %%ItemId = _MallItemInfo#mall_item.item_id,
    case BuyTimesLimit > 0 of
	true ->
	    HasBuyTimes=case cache_with_expire:get(lists:concat(['mall_item_buy_times:',_MallItemInfo#mall_item.id]),player:get_role_id()) of
			    [] -> 0;
			    [Times|_] ->element(2,Times)
			end,
	    (HasBuyTimes + Amount) > BuyTimesLimit;
	false ->
	    false
    end.
