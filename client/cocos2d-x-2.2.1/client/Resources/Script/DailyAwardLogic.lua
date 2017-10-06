----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-14
-- Brief:	每日奖励
----------------------------------------------------------------------

local mContinueLoginDays = 0			-- 连续登录天数
local mHasGetDailyAward = true			-- 是否已获取每日奖励
local mHasGetDays3Award = true			-- 是否已获取连续登录3天奖励
local mHasGetDays7Award = true			-- 是否已获取连续登录7天奖励
local mHasGetDays15Award = true			-- 是否已获取连续登录15天奖励
local mDailyTimerFlag = false
DailyAwardLogic = {}
----------------------------------------------------------------------
-- 当天到达24:00:00
local function dailyTimerOver()
	local days = mContinueLoginDays + 1
	mHasGetDailyAward = false
	TipFunction.setFuncAttr("func_daily_award", "count", 0)
	if 3 == days then
		mHasGetDays3Award = false
	elseif 7 == days then
		mHasGetDays7Award = false
	elseif 15 == days then
		mHasGetDays15Award = false
	end
	EventCenter_post(EventDef["ED_DAILY_AWARD"])
end
----------------------------------------------------------------------
-- 通知连续登陆奖励信息
local function handleNofityContinueLoginAwardInfo(packet)
	mContinueLoginDays = packet.continue_login_days
	cclog("login days: "..packet.continue_login_days.." daily: "..packet.daily_award_status.." days3: "..packet.cumulative_award3_status.." days7: "..packet.cumulative_award7_status.." days15: "..packet.cumulative_award15_status)
	if 0 == packet.daily_award_status then
		mHasGetDailyAward = false
		TipFunction.setFuncAttr("func_daily_award", "count", 0)
	else
		mHasGetDailyAward = true
		TipFunction.setFuncAttr("func_daily_award", "count", 1)
	end
	if 0 == packet.cumulative_award3_status then
		mHasGetDays3Award = false
	else
		mHasGetDays3Award = true
	end
	if 0 == packet.cumulative_award7_status then
		mHasGetDays7Award = false
	else
		mHasGetDays7Award = true
	end
	if 0 == packet.cumulative_award15_status then
		mHasGetDays15Award = false
	else
		mHasGetDays15Award = true
	end
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	EventCenter_post(EventDef["ED_DAILY_AWARD"])
end
----------------------------------------------------------------------
-- 通知领取每日奖励结果
local function handleNotifyGetDailyAwardResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then	-- 领取成功
		success = true
	end
	EventCenter_post(EventDef["ED_DAILY_GET_AWARD"], success)
end
----------------------------------------------------------------------
-- 请求领取每日奖励
DailyAwardLogic.request_get_daily_award = function(awardType)
	local req = req_get_daily_award()
	req.type = awardType
	NetHelper.sendAndWait(req, NetMsgType["notify_get_daily_award_result"])
end
----------------------------------------------------------------------
-- 获取连续登录天数
DailyAwardLogic.getContinueDays = function()
	return mContinueLoginDays
end
----------------------------------------------------------------------
-- 是否已获取每日奖励
DailyAwardLogic.hasGetDailyAward = function()
	return mHasGetDailyAward
end
----------------------------------------------------------------------
-- 是否已获取连续登录3天奖励
DailyAwardLogic.hasGetDays3Award = function()
	return mHasGetDays3Award
end
----------------------------------------------------------------------
-- 是否已获取连续登录7天奖励
DailyAwardLogic.hasGetDays7Award = function()
	return mHasGetDays7Award
end
----------------------------------------------------------------------
-- 是否已获取连续登录15天奖励
DailyAwardLogic.hasGetDays15Award = function()
	return mHasGetDays15Award
end
----------------------------------------------------------------------
-- 是否有未领取的奖励
DailyAwardLogic.existAward = function()
	if false == mHasGetDailyAward then
		return true
	end
	if mContinueLoginDays >=3 then
		if false == mHasGetDays3Award then
			return true
		end
	end
	if mContinueLoginDays >=7 then
		if false == mHasGetDays7Award then
			return true
		end
	end
	if mContinueLoginDays >= 15 then
		if false == mHasGetDays15Award then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 监听通知系统时间消息
NetSocket_registerHandler(NetMsgType["msg_nofity_continue_login_award_info"], nofity_continue_login_award_info, handleNofityContinueLoginAwardInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_get_daily_award_result"], notify_get_daily_award_result, handleNotifyGetDailyAwardResult)

