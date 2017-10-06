----------------------------------------------------------------------
-- 作者：Lihq
-- 日期：2014-3-27
-- 描述：玩家体力建模
----------------------------------------------------------------------
ModelPower = {}

local mPowerHpPriceTable = XmlTable_load("power_hp_price.xml", "the_time")		-- 体力价格表
----------------------------------------------------------------------
-- 获取体力价格信息
ModelPower.getPowerHpPriceRow = function(theTime)
	local row = XmlTable_getRow(mPowerHpPriceTable, theTime, true)
	local powerHpPriceRow = {}
	
	powerHpPriceRow.the_time = row.the_time + 0			-- 购买次数
	powerHpPriceRow.price = row.price + 0				-- 价格(代币)
	
	return powerHpPriceRow
end
----------------------------------------------------------------------
-- 根据玩家等级获取体力上限值
ModelPower.getMaxPowerHp = function(level)
	return  PowerConfig["real_max"]
	--return PowerConfig["init_max"] + (level - 1)*PowerConfig["upgrade_add"]
end
----------------------------------------------------------------------
-- 每次恢复多少体力
ModelPower.getRecoverPowerHp = function()
	return PowerConfig["recover_power_hp"]
end
----------------------------------------------------------------------
-- 每隔多少秒恢复一次体力
ModelPower.getRecoverSeconds = function()
	return PowerConfig["recover_seconds"]
end
----------------------------------------------------------------------
-- 每次购买体力花费多少魔石
ModelPower.getPowerHpPrice = function()
	return PowerConfig["power_hp_price"]
end
----------------------------------------------------------------------
-- 请求购买体力
ModelPower.requestBuyPowerHp = function()
	local req = req_buy_power_hp()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_buy_power_hp_result"])
end
----------------------------------------------------------------------
-- 处理通知购买体力结果网络消息事件
local function handleNotifyBuyPowerHpResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
		-- 当日购买次数加1
		ModelPlayer.setHpPowerBuyTimes(ModelPlayer.getHpPowerBuyTimes() + 1)
		--ModelPlayer.setHpPower(PowerConfig["init_max"])
		EventCenter_post(EventDef["ED_UPDATE_ROLE_INFO"], "power_hp")
	end
	EventCenter_post(EventDef["ED_BUY_POWER_HP"], success)
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_buy_power_hp_result"], notify_buy_power_hp_result, handleNotifyBuyPowerHpResult)

