
----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-09
-- Brief:	打折限购界面逻辑
----------------------------------------------------------------------
DisResLogic = {}

local  mBuyTimesTb = nil		--保存已经购买过的情况
----------------------------------------------------------------------
-- 判断是达到炼金的条件
DisResLogic.existAward = function()
	return false	
end
----------------------------------------------------------------------
-- 清除缓存中数据
DisResLogic.destroy = function()
	mBuyTimesTb = nil	
end
----------------------------------------------------------------------
-- 获得已经购买过的情况列表
DisResLogic.getBuyList = function()
	return mBuyTimesTb	
end
----------------------------------------------------------------------
-- 处理已经购买次数
local function handleNofityHasBuyDisTimes(packet)
	mBuyTimesTb = packet.buy_info_list
	EventCenter_post(EventDef["ED_DIS_BUY_SUC"])
end
----------------------------------------------------------------------
-- 处理购买情况
local function handleNofityBuyItems(packet)		
	if packet.result == 1 then
		Toast.show(GameString.get("Public_MSG_PUR_SUCC"))
		--根据请求的id，更新已经请求过的次数
		for key,value in pairs(DisResLogic.getBuyList()) do
			if value.mallitem_id == packet.mall_item_id then
				 value.times = value.times + 1
			end	
		end
		EventCenter_post(EventDef["ED_DIS_BUY_SUC"])
	end
end
----------------------------------------------------------------------
-- 请求购买商品
DisResLogic.requestBuyDisItem = function(id)
	local tb = req_buy_discount_limit_item()
	tb.id = id
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_buy_discount_limit_item_result"])	
end
----------------------------------------------------------------------
-- 请求购买次数
DisResLogic.requestBuyTimes = function()
	local tb = req_has_buy_discount_item_times()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_has_buy_discount_item_times"])	
end
------------------------------------------------------------------

-- 监听打折限购信息
NetSocket_registerHandler(NetMsgType["msg_notify_has_buy_discount_item_times"], notify_has_buy_discount_item_times, handleNofityHasBuyDisTimes)		-- 监听已经购买次数
NetSocket_registerHandler(NetMsgType["msg_notify_buy_discount_limit_item_result"], notify_buy_discount_limit_item_result, handleNofityBuyItems)		-- 监听购买情况

