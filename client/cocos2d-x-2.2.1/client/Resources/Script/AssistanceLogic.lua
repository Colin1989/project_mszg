----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-03
-- Brief:	援军逻辑
----------------------------------------------------------------------
local mLotteryTimes = 0				-- 已领取友情点奖励次数
local mRefreshTimes = 0				-- 已刷新援军列表次数
local mDonorInfo = nil				-- 当前选择的援军信息
local mEnterType = 0				-- 进入战斗入口类型(0.普通副本,精英副本,BOSS副本,1.活动副本)
local mDailyTimerFlag = false	
AssistanceLogic = {}
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	mLotteryTimes = 0
	mRefreshTimes = 0
	FriendPointLogic.requestRefreshlotteryList()
	EventCenter_post(EventDef["ED_FRIEND_POINT_TIME_OVER"])
	ModelPlayer.setFriendPoint(0)
end
----------------------------------------------------------------------
-- 处理通知援军信息网络消息事件
local function handleNotifyAssistanceInfo(packet)
	mLotteryTimes = packet.lottery_times
	mRefreshTimes = packet.refresh_times
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	EventCenter_post(EventDef["ED_FRIEND_POINT_GET"])
end
----------------------------------------------------------------------
-- 处理通知援军列表网络消息事件
local function handleNotifyAssistanceList(packet)
	EventCenter_post(EventDef["ED_DONOR_LIST"], packet.donors)
end
----------------------------------------------------------------------
-- 处理通知刷新援军列表网络消息事件
local function handleNotifyRefreshAssistanceListResult(packet)
end
----------------------------------------------------------------------
-- 处理通知选择援军网络消息事件
local function handleNotifySelectDonorResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	end
	EventCenter_post(EventDef["ED_SELECT_DONOR"], success)
end
----------------------------------------------------------------------
-- 请求援军列表
AssistanceLogic.requestAssistanceList = function()
	local req = req_assistance_list()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_assistance_list"]) 
end
----------------------------------------------------------------------
-- 请求刷新援军列表
AssistanceLogic.requestRefreshAssistanceList = function()
	local req = req_refresh_assistance_list()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_refresh_assistance_list_result"])
end
----------------------------------------------------------------------
-- 请求选择援军
AssistanceLogic.requestSelectDonor = function(donorId)
	local req = req_select_donor()
	req.donor_id = donorId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_select_donor_result"])
end
----------------------------------------------------------------------
-- 获取已领取友情点奖励次数
AssistanceLogic.getLotteryTimes = function()
	return mLotteryTimes
end
----------------------------------------------------------------------
-- 获取已刷新援军列表次数
AssistanceLogic.getRefreshTimes = function()
	return mRefreshTimes
end
----------------------------------------------------------------------
-- 设置当前选择的援军信息
AssistanceLogic.setDonorInfo = function(donorInfo)
	--[[
	donor = 
	{
		role_id = 0
		rel = 0
		level = 0
		role_type = 0
		nick_name = ""
		friend_point = 0
		power = 0
		sculpture = {}
		is_used = 0
	}
	]]
	mDonorInfo = donorInfo
end
----------------------------------------------------------------------
-- 获取当前选择的援军信息
AssistanceLogic.getDonorInfo = function()
	return mDonorInfo
end
----------------------------------------------------------------------
-- 设置进入战斗类型
AssistanceLogic.setEnterType = function(enterType)
	mEnterType = enterType or 0
end
----------------------------------------------------------------------
-- 获取进入战斗类型
AssistanceLogic.getEnterType = function()
	return mEnterType
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_assistance_info"], notify_assistance_info, handleNotifyAssistanceInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_assistance_list"], notify_assistance_list, handleNotifyAssistanceList)
NetSocket_registerHandler(NetMsgType["msg_notify_refresh_assistance_list_result"], notify_refresh_assistance_list_result, handleNotifyRefreshAssistanceListResult)
NetSocket_registerHandler(NetMsgType["msg_notify_select_donor_result"], notify_select_donor_result, handleNotifySelectDonorResult)

