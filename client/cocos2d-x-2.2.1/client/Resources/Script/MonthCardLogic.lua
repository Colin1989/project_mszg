----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-13
-- Brief:	月卡逻辑
----------------------------------------------------------------------
MonthCardLogic = {}
local mAwardStatus = 0				-- 是否已经领取奖励,0-已领取,1-未领取
local mRemainDays = 0				-- 月卡剩余天数
local mMonthCardId = 0				-- 月卡id
local mDailyTimerFlag = false
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	if 0 == mRemainDays then
		return
	end
	mAwardStatus = 1
	mRemainDays = mRemainDays - 1
	EventCenter_post(EventDef["ED_MONTH_CARD_INFO"])
end
----------------------------------------------------------------------
-- 处理通知月卡信息网络消息事件
local function handleNotifyMooncardInfo(packet)
	mAwardStatus = packet.award_status
	mRemainDays = packet.days_remain
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	EventCenter_post(EventDef["ED_MONTH_CARD_INFO"])
end
----------------------------------------------------------------------
-- 处理通知领取月卡每日奖励网络消息事件
local function handleNotifyGetMooncardDailyAwardResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		mAwardStatus = 0
		success = true
	end
	EventCenter_post(EventDef["ED_GET_MONTH_CARD_REWARD"], success)
end
----------------------------------------------------------------------
-- 请求领取月卡每日奖励
MonthCardLogic.requestGetMooncardDailyAward = function()
	local req = req_get_mooncard_daily_award()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_get_mooncard_daily_award_result"])
end
----------------------------------------------------------------------
-- 是否可领取奖励
MonthCardLogic.canGetAward = function()
	return 1 == mAwardStatus and mRemainDays > 0
end
----------------------------------------------------------------------
-- 获取月卡剩余天数
MonthCardLogic.getRemainDays = function()
	return mRemainDays
end
----------------------------------------------------------------------
-- 获取月卡id
MonthCardLogic.getMonthCardId = function()
	if 0 == mMonthCardId then
		local rechargeList = LogicTable.getRechargeTable(ChannelProxy.getChannelId())
		for key, val in pairs(rechargeList) do
			if 1 == val.type then		-- 月卡类型
				mMonthCardId = val.id
				break
			end
		end
	end
	return mMonthCardId
end
----------------------------------------------------------------------
-- 根据有没有月卡，判断进入那个界面
MonthCardLogic.judgeEnterMonthCardUI = function()
	local remainDays = MonthCardLogic.getRemainDays()
	if 0 == remainDays then		-- 无月卡
		UIManager.push("UI_MonthCard_No")
	else						-- 有月卡
		UIManager.push("UI_MonthCard")
	end
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_mooncard_info"], notify_mooncard_info, handleNotifyMooncardInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_get_mooncard_daily_award_result"], notify_get_mooncard_daily_award_result, handleNotifyGetMooncardDailyAwardResult)


