----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-05
-- Brief:	每日活跃度
----------------------------------------------------------------------
local mTotalOnlineTime = 0				-- 今日总上线时间(秒)
local mHasGetAwards = {}				-- 已领取奖励信息{5,15,30,60,120}
local mGetOnlineMinutes = nil			-- 请求领取的在线时间
local mDailyTimerFlag = false
local mOnlineTimer = nil				-- 在线定时器
ONLINE_TIMES = {5, 15, 30, 60, 120}		-- 在线时长:5,15,30,60,120分钟
OnlineRewardLogic = {}
----------------------------------------------------------------------
local function handleClearData()
	mDailyTimerFlag = false
	mOnlineTimer = nil
end
----------------------------------------------------------------------
local function handleBrokenLine()
	if mOnlineTimer then
		mOnlineTimer.stop()
		mOnlineTimer = nil
	end
end
----------------------------------------------------------------------
-- 每秒触发
local function timerFunc(tm)
	mTotalOnlineTime = mTotalOnlineTime + 1
	if mTotalOnlineTime <= ONLINE_TIMES[5]*60 then
		EventCenter_post(EventDef["ED_ONLINE_TIMER"], mTotalOnlineTime)
		if true == OnlineRewardLogic.existAward() then
			EventCenter_post(EventDef["ED_ONLINE_AWARD_INFO"])
			TipFunction.setFuncAttr("func_online_award", "waiting", false)
		else
			TipFunction.setFuncAttr("func_online_award", "waiting", true)
		end
	end
end
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	mTotalOnlineTime = 0
	mHasGetAwards = {}
	EventCenter_post(EventDef["ED_ONLINE_AWARD_INFO"])
	TipFunction.setFuncAttr("func_online_award", "count", 0)
end
----------------------------------------------------------------------
-- 处理通知今日在线奖励信息网络消息事件
local function handleNotifyOnlineAwardInfo(packet)
	mTotalOnlineTime = packet.total_online_time
	mHasGetAwards = packet.has_get_awards
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	handleBrokenLine()
	mOnlineTimer = CreateTimer(1, 0, timerFunc, nil)
	mOnlineTimer.start()
	TipFunction.setFuncAttr("func_online_award", "count", #mHasGetAwards)
	EventCenter_post(EventDef["ED_ONLINE_AWARD_INFO"])
end
----------------------------------------------------------------------
-- 处理通知领取在线奖励信息网络消息事件
local function handleNotifyGetOnlineAwardResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		table.insert(mHasGetAwards, mGetOnlineMinutes)
		success = true
		TipFunction.setFuncAttr("func_online_award", "count", #mHasGetAwards)
	end
	mGetOnlineMinutes = nil
	EventCenter_post(EventDef["ED_GET_ONLINE_AWARD"], success)
end
----------------------------------------------------------------------
-- 请求领取在线奖励
OnlineRewardLogic.requestGetOnlineAward = function(onlineAwardId, onlineMinutes)
	mGetOnlineMinutes = onlineMinutes
	local req = req_get_online_award()
	req.online_award_id = onlineAwardId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_get_online_award_result"])
end
----------------------------------------------------------------------
-- 该类型在线奖励是否可领取,onlineType(5,15,30,60,120)
OnlineRewardLogic.canGetAward = function(onlineType)
	local totalOnlineMinutes = mTotalOnlineTime/60
	if totalOnlineMinutes >= onlineType then
		for key, val in pairs(mHasGetAwards) do
			if val == onlineType then
				return false
			end
		end
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 该类型在线奖励是否已领取,onlineType(5,15,30,60,120)
OnlineRewardLogic.hasGetAward = function(onlineType)
	for key, val in pairs(mHasGetAwards) do
		if val == onlineType then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 是否有未领取的奖励
OnlineRewardLogic.existAward = function()
	for key, val in pairs(ONLINE_TIMES) do
		if true == OnlineRewardLogic.canGetAward(val) then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 获取可领取奖励剩余时间(秒)
OnlineRewardLogic.getRemainTime = function(totalOnlineTime)
	local onlineTimes = {ONLINE_TIMES[1]*60, ONLINE_TIMES[2]*60, ONLINE_TIMES[3]*60, ONLINE_TIMES[4]*60, ONLINE_TIMES[5]*60}
	if totalOnlineTime < onlineTimes[1] then
		return onlineTimes[1] - totalOnlineTime
	elseif totalOnlineTime >= onlineTimes[1] and totalOnlineTime < onlineTimes[2] then
		return onlineTimes[2] - totalOnlineTime
	elseif totalOnlineTime >= onlineTimes[2] and totalOnlineTime < onlineTimes[3] then
		return onlineTimes[3] - totalOnlineTime
	elseif totalOnlineTime >= onlineTimes[3] and totalOnlineTime < onlineTimes[4] then
		return onlineTimes[4] - totalOnlineTime
	elseif totalOnlineTime >= onlineTimes[4] and totalOnlineTime < onlineTimes[5] then
		return onlineTimes[5] - totalOnlineTime
	end
	return 0
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_online_award_info"], notify_online_award_info, handleNotifyOnlineAwardInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_get_online_award_result"], notify_get_online_award_result, handleNotifyGetOnlineAwardResult)
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)
EventCenter_subscribe(EventDef["ED_BROKEN_LINE"], handleBrokenLine)
