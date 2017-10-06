----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-05
-- Brief:	每日活跃度
----------------------------------------------------------------------
local mActivenessInfo = {}				-- 活跃任务信息
mActivenessInfo.taskList = {}			-- 活跃任务列表
mActivenessInfo.rewardList = {}			-- 活跃度奖励列表
mActivenessInfo.activeness = 0			-- 当前活跃度
local mDailyTimerFlag = false

DailyActivenessLogic = {}
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	for key, val in pairs(mActivenessInfo.taskList) do
		mActivenessInfo.taskList[key].count = 0
	end
	for key, val in pairs(mActivenessInfo.rewardList) do
		mActivenessInfo.rewardList[key] = 0
	end
	mActivenessInfo.activeness = 0
	EventCenter_post(EventDef["ED_ACTIVENESS_AWARD"])
end
----------------------------------------------------------------------
-- 处理通知今日活跃任务
local function handleNofityTodayActivenessTask(packet)
	mActivenessInfo.taskList = packet.task_list
	mActivenessInfo.rewardList = packet.is_reward_activeness_item_info
	mActivenessInfo.activeness = packet.activeness
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	EventCenter_post(EventDef["ED_ACTIVENESS_AWARD"])
end
----------------------------------------------------------------------
-- 处理通知领取活跃度奖励结果
local function handleNotifyActivenessRewardResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then	-- 领取成功
		mActivenessInfo.rewardList[packet.reward] = 1
		success = true
	end
	EventCenter_post(EventDef["ED_ACTIVENESS_AWARD_GET"], success)
end
----------------------------------------------------------------------
-- 请求每日活跃任务
DailyActivenessLogic.requestTodayActivenessTask = function()
	local req = req_today_activeness_task()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_today_activeness_task"])
end
----------------------------------------------------------------------
-- 请求领取活跃度奖励
DailyActivenessLogic.requestActivenessReward = function(rewardId)
	local req = req_activeness_reward()
	req.reward = rewardId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_activeness_reward_result"])
end
----------------------------------------------------------------------
-- 获取活跃任务信息
DailyActivenessLogic.getActivenessInfo = function()
	return mActivenessInfo
end
----------------------------------------------------------------------
-- 活跃度奖励状态:0-可领取,1-不可领取,2-已领取
DailyActivenessLogic.getAwardStatus = function(rewardId)
	local status = mActivenessInfo.rewardList[rewardId] or 0
	local activenessRewardRow = LogicTable.getActivenessRewardRow(rewardId)
	if 0 == status then		-- 未领取
		if mActivenessInfo.activeness >= activenessRewardRow.need_activess then		-- 可领取
			return 0
		end
		-- 不可领取
		return 1
	end
	-- 已领取
	return 2
end
----------------------------------------------------------------------
-- 是否有未领取的奖励
DailyActivenessLogic.existAward = function()
	for i=1, 4 do
		if 0 == DailyActivenessLogic.getAwardStatus(i) then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 监听通知系统时间消息
NetSocket_registerHandler(NetMsgType["msg_notify_today_activeness_task"], notify_today_activeness_task, handleNofityTodayActivenessTask)
NetSocket_registerHandler(NetMsgType["msg_notify_activeness_reward_result"], notify_activeness_reward_result, handleNotifyActivenessRewardResult)

