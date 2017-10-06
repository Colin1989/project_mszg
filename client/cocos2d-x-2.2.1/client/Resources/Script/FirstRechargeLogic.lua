----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-15
-- Brief:	首充界面逻辑
----------------------------------------------------------------------
FirstRechargeLogic = {}
local mStatus = 0		--表示充过的状态

----------------------------------------------------------------------
-- 判断是达到领取首充的条件
FirstRechargeLogic.existAward = function()
	if mStatus == first_charge_status["not_charge"] then
		return false
	elseif mStatus == first_charge_status["charget_not_rewarded"] then
		return true
	elseif mStatus == first_charge_status["rewarded"] then
		return false
	end
end
-----------------------------------------------------------------------
-- 判断首充是否已被领取
FirstRechargeLogic.beReceived = function()
	if mStatus == first_charge_status["not_charge"] then
		return false
	elseif mStatus == first_charge_status["charget_not_rewarded"] then
		return false
	elseif mStatus == first_charge_status["rewarded"] then
		return true
	end
end
----------------------------------------------------------------------
-- 处理领取首充奖励信息
local function handleNofityFirstChargeInfo(packet)

	mStatus = packet.status
	EventCenter_post(EventDef["ED_FIRSTR_ECHARGE_GET"])
end
----------------------------------------------------------------------
-- 处理领取礼包
local function handleNofityGetFirstRechargeReward(packet)

	if packet.result == 1 then
		mStatus = 3	
		EventCenter_post(EventDef["ED_FIRSTR_ECHARGE_GET"])
		
		local idTb = {}
		local amountTb = {}
		for key,value in pairs(FirstRecharge_RewardTb) do
			table.insert(idTb,value.id)
			table.insert(amountTb,value.amount)
		end
		CommonFunc_showItemGetInfo(idTb, amountTb)
		
	end
end
----------------------------------------------------------------------
-- 请求领礼包
FirstRechargeLogic.requestGetReward = function()

	local tb = req_first_charge_reward()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_first_charge_reward_result"])
	
end
----------------------------------------------------------------------

-- 监听通知系首充奖励信息

NetSocket_registerHandler(NetMsgType["msg_notify_first_charge_info"], notify_first_charge_info, handleNofityFirstChargeInfo)	-- 监听首充信息
NetSocket_registerHandler(NetMsgType["msg_notify_first_charge_reward_result"], notify_first_charge_reward_result, handleNofityGetFirstRechargeReward)	-- 监听领取奖励