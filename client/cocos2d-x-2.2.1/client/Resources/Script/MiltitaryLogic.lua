----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-06-17
-- Brief:	军衔逻辑
----------------------------------------------------------------------
local mMiltitaryInfo = {}
mMiltitaryInfo.level = 0				-- 军衔等级
mMiltitaryInfo.is_rewarded = false		-- 是否已领取奖励
local mDailyTimerFlag = false

MiltitaryLogic = {}
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	mMiltitaryInfo.level = 0
	mMiltitaryInfo.is_rewarded = false
	-- 周一,重新计算军衔等级
	-- if 1 == SystemTime.getServerDate().wday then
		MiltitaryLogic.requestMilitaryRankInfo()
	-- end
end
----------------------------------------------------------------------
-- 处理通知军衔排行信息网络消息事件
local function handleNotifyMilitaryRankInfo(packet)
	mMiltitaryInfo.level = packet.level						-- 军衔等级
	mMiltitaryInfo.is_rewarded = 1 == packet.is_rewarded	-- 0.未领取,1.已领取
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	if mMiltitaryInfo.is_rewarded then
		TipFunction.setFuncAttr("func_miltitary_award", "count", 1)
	else
		TipFunction.setFuncAttr("func_miltitary_award", "count", 0)
	end
	EventCenter_post(EventDef["ED_MILTITARY_RANK_GET_REWARD"])
end
----------------------------------------------------------------------
-- 处理通知军衔奖励领取网络消息事件
local function handleNotifyMilitaryRankRewardResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
		mMiltitaryInfo.is_rewarded = true
		TipFunction.setFuncAttr("func_miltitary_award", "count", 1)
	end
	EventCenter_post(EventDef["ED_MILTITARY_RANK_GET_REWARD"], success)
end
----------------------------------------------------------------------
-- 请求军衔排行信息
MiltitaryLogic.requestMilitaryRankInfo = function()
	local req = req_military_rank_info()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_military_rank_info"])
end
----------------------------------------------------------------------
-- 请求领取军衔奖励
MiltitaryLogic.requestMilitaryRankReward = function()
	local req = req_military_rank_reward()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_military_rank_reward_result"])
end
----------------------------------------------------------------------
-- 获取军衔等级
MiltitaryLogic.getMiltitaryLevel = function()
	return mMiltitaryInfo.level
end
----------------------------------------------------------------------
-- 是否有未领取的奖励
MiltitaryLogic.existAward = function()
	return mMiltitaryInfo.level > 0 and false == mMiltitaryInfo.is_rewarded
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_military_rank_info"], notify_military_rank_info, handleNotifyMilitaryRankInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_military_rank_reward_result"], notify_military_rank_reward_result, handleNotifyMilitaryRankRewardResult)

