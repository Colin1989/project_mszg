----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-09
-- Brief:	网络逻辑
----------------------------------------------------------------------
NetLogic = {}
----------------------------------------------------------------------
-- 处理通知兑换物品网络消息事件
local function handleNotifyExchangeItemResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	end
	EventCenter_post(EventDef["ED_EXCHANGE_ITEM"], success)
end
----------------------------------------------------------------------
-- 处理通知购买商城物品网络消息事件
local function handleNotifyBuyMallItemResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	end
	EventCenter_post(EventDef["ED_BUY_MALL_ITEM"], success)
end
----------------------------------------------------------------------
-- 处理通知购买积分商城物品网络消息事件
local function handleNotifyBuyPointMallItemResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	end
	EventCenter_post(EventDef["ED_BUY_POINT_MALL_ITEM"], success)
end
----------------------------------------------------------------------
-- 请求兑换物品
NetLogic.requestExchangeItem = function(exchangeId)
	local req = req_exchange_item()
	req.exchange_id = exchangeId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_exchange_item_result"])
end
----------------------------------------------------------------------
-- 请求购买商城物品
NetLogic.requestBuyMallItem = function(mallItemId, buyTimes)
	local req = req_buy_mall_item()
	req.mallitem_id = mallItemId
	req.buy_times = buyTimes
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_buy_mall_item_result"])
end
----------------------------------------------------------------------
-- 请求购买积分商城物品
NetLogic.requestBuyPointMallItem = function(mallItemId, buyTimes)
	local req = req_buy_point_mall_item()
	req.mallitem_id = mallItemId
	req.buy_times = buyTimes
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_buy_point_mall_item_result"])
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_exchange_item_result"], notify_exchange_item_result, handleNotifyExchangeItemResult)
NetSocket_registerHandler(NetMsgType["msg_notify_buy_mall_item_result"], notify_buy_mall_item_result, handleNotifyBuyMallItemResult)
NetSocket_registerHandler(NetMsgType["msg_notify_buy_point_mall_item_result"], notify_buy_point_mall_item_result, handleNotifyBuyPointMallItemResult)
