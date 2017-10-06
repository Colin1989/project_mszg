----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-11-13
-- Brief:	限时奖励逻辑
----------------------------------------------------------------------
TimeLimitRewardLogic = {}
local mRewardList = {}
----------------------------------------------------------------------
local function handleClearData()
	mRewardList = {}
end
----------------------------------------------------------------------
-- 处理通知限时奖励列表网络消息事件
local function handleNotifyTimeLimitRewardedList(resp)
	--[[
		tb.id = 0				-- 奖励id
		tb.count = 0			-- 已领取数量
		tb.rewarded_time = 0	-- 上次领取时间
	]]
	mRewardList = resp.list
	EventCenter_post(EventDef["ED_TIME_LIMIT_REWARD_LIST"])
end
----------------------------------------------------------------------
-- 处理通知领取限时奖励网络消息事件
local function handleNotifyTimeLimitReward(resp)
	local data = {}
	data.success = false
	if common_result["common_success"] == resp.result then
		data.success = true
	end
	EventCenter_post(EventDef["ED_TIME_LIMIT_REWARD_GET"], data)
end
----------------------------------------------------------------------
-- 请求领取限时奖励
TimeLimitRewardLogic.requestTimeLimitReward = function(rewardId)
	local req = req_time_limit_reward()
	req.id = rewardId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_time_limit_reward"])
end
----------------------------------------------------------------------
-- 获取已领取奖励信息
TimeLimitRewardLogic.getRewardedInfo = function(rewardId)
	for key, val in pairs(mRewardList) do
		if rewardId == val.id then
			return val
		end
	end
	return nil
end
----------------------------------------------------------------------
-- 限时奖励信息:领取状态,信息
TimeLimitRewardLogic.rewardInfo = function(rewardId)
	local row = LogicTable.getTimeLimitRewardRow(rewardId)
	local startHour, startMinute, stattSecond = row.start_time[1][1], row.start_time[1][2], row.start_time[1][3]
	local endHour, endMinute, endSecond = row.end_time[1][1], row.end_time[1][2], row.end_time[1][3]
	local nowDate = SystemTime.getServerDate()
	local nowTime = SystemTime.getServerTime()
	local startTime = SystemTime.dateToTime({year=nowDate.year, month=nowDate.month, day=nowDate.day, hour=startHour, minute=startMinute, second=stattSecond})
	local endTime = SystemTime.dateToTime({year=nowDate.year, month=nowDate.month, day=nowDate.day, hour=endHour, minute=endMinute, second=endSecond})
	if nowTime >= startTime and nowTime <= endTime then		-- 在规定时间内
		local info = TimeLimitRewardLogic.getRewardedInfo(rewardId)
		if nil == info then
			return 1, row		-- 可领取(从未领取过)
		end
		local rewardTime = SystemTime.dateToTime(info.rewarded_time)
		if info.count < row.count and rewardTime + row.cd_time >= nowTime then
			return 2, row		-- 可领取(已领取过,但次数未到,且冷却时间已过)
		end
		return 3, row			-- 不可领取(次数达到,或冷却时间未过)
	end
	return 4, row				-- 不可领取(在规定时间外)
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_time_limit_rewarded_list"], notify_time_limit_rewarded_list, handleNotifyTimeLimitRewardedList)
NetSocket_registerHandler(NetMsgType["msg_notify_time_limit_reward"], notify_time_limit_reward, handleNotifyTimeLimitReward)
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)

