----------------------------------------------------------------------
-- jaron.ho
-- 2014-03-14
-- 任务系统
----------------------------------------------------------------------
local mTempTaskInfos = {}
local mTaskInfos = {}				-- 缓存本地任务列表
local mFinishedTaskInfos = {}		-- 缓存已完成的未领取奖励任务列表
TaskLogic = {}
----------------------------------------------------------------------
-- 获取任务状态
local function getTaskStatus(task_id)
	local taskRow = LogicTable.getTaskRow(task_id)
	local taskRow = LogicTable.getTaskRow(task_id)
	local status = 0	-- 0-已锁定,1-进行中,2-已完成
	if true == TaskLogic.isTaskLocked(taskRow) then
		status = 0
	else
		if true == TaskLogic.isTaskFinished(taskRow) then
			status = 2
		else
			status = 1
		end
	end
	return status
end
----------------------------------------------------------------------
-- 任务列表排序,1.新手 -> 2.已完成＞进行中＞已锁定 -> 3.主线＞支线
local function sortTask(a, b)
	local aTask = LogicTable.getTaskRow(a.task_id)
	local bTask = LogicTable.getTaskRow(b.task_id)
	local aStatus = getTaskStatus(a.task_id)
	local bStatus = getTaskStatus(b.task_id)
	-- 
	if 3 == aTask.main_type then	-- 新手任务
		if aTask.main_type == bTask.main_type then
			return aTask.id < bTask.id
		end
		return true
	else
		if 3 == bTask.main_type then
			return false
		end
	end
	if aStatus > bStatus then
		return true
	elseif aStatus == bStatus then
		return aTask.main_type < bTask.main_type
	else
		return false
	end
end
----------------------------------------------------------------------
-- 过滤任务列表
local function filterTaskInfos(allTaskInfos)
	mTaskInfos = {}
	mFinishedTaskInfos = {}
	for key, val in pairs(allTaskInfos) do
		-- 0.未完成任务,已完成任务未领取奖励;1.已完成任务且已领取奖励
		if 0 == val.has_finished then
			table.insert(mTaskInfos, val)
			local taskRow = LogicTable.getTaskRow(val.task_id)
			if true == TaskLogic.isTaskFinished(taskRow) and false == TaskLogic.isTaskLocked(taskRow) then
				table.insert(mFinishedTaskInfos, val)
			end
		end
	end
	table.sort(mTaskInfos, sortTask)
	EventCenter_post(EventDef["ED_UPDATE_TASK_LIST"])
end
----------------------------------------------------------------------
-- 通知副本信息
local function handleCopyInfos()
	filterTaskInfos(mTempTaskInfos)
end
----------------------------------------------------------------------
-- 通知任务列表
local function handleNotifyTaskInfos(packet)
	mTempTaskInfos = packet.infos
	filterTaskInfos(packet.infos)
end
----------------------------------------------------------------------
-- 通知任务完成
local function handleNotifyFinishTask(packet)
	local success = false
	if common_result["common_success"] == packet.is_success then	-- 任务完成(领取奖励成功)
		success = true
	end
	EventCenter_post(EventDef["ED_TASK_FINISHED"], success)
end
----------------------------------------------------------------------
-- 更新任务完成数量
local function updateTaskCompleteCount(taskRow)
	local count = TaskLogic.getTaskCompleteCount(taskRow)
	if count >= taskRow.number then
		return false
	end
	local index = TaskLogic.getTaskInfo(taskRow.id)
	mTaskInfos[index].args[1] = count + 1
	return true
end
----------------------------------------------------------------------
-- 更新击杀怪物数量
local function updateKillMonsterCount(param, taskRow)
	if param.monsterId ~= taskRow.monster_id or 
	   param.locationId ~= taskRow.location then
		return false
	end
	return updateTaskCompleteCount(taskRow)
end
----------------------------------------------------------------------
-- 更新通过副本数量
local function updatePassOverCount(locationId, taskRow)
	if locationId ~= taskRow.location then
		return false
	end
	return updateTaskCompleteCount(taskRow)
end
----------------------------------------------------------------------
-- 判断监听到的是否为指定的任务
local function checkIsTask(taskSubId, param, task_id)
	local taskRow = LogicTable.getTaskRow(task_id)
	if taskSubId ~= taskRow.sub_type then
		return false
	end
	if 1 == taskSubId then				-- 击杀怪物
		return updateKillMonsterCount(param, taskRow)
	elseif 2 == taskSubId then			-- 通关副本
		if taskRow.stars == param.stars then
			return updatePassOverCount(param.locationId, taskRow)
		end
	elseif 3 == taskSubId then			-- 收集物品
		return param.itemId == taskRow.collect_id
	elseif 4 == taskSubId then			-- 符文充能
		return updateTaskCompleteCount(taskRow)
	elseif 5 == taskSubType then		-- 强化装备
		return updateTaskCompleteCount(taskRow)
	elseif 6 == taskSubType then		-- 分解装备
		return updateTaskCompleteCount(taskRow)
	elseif 7 == taskSubType then		-- 占卜次数
		return updateTaskCompleteCount(taskRow)
	end
	return false
end
----------------------------------------------------------------------
-- 监听任务状态
local function listenTaskStatus(taskSubId, param)
	for k, v in pairs(mTaskInfos) do
		if true == checkIsTask(taskSubId, param, v.task_id) then
			LayerTask.showTip(v.task_id)		-- 界面提示
			-- 任务完成,播放音效
			local taskRow = LogicTable.getTaskRow(v.task_id)
			if TaskLogic.isTaskFinished(taskRow) then
				Audio.playEffectByTag(5)
			end
			break
		end
	end
end
----------------------------------------------------------------------
-- 处理击杀怪物事件
local function handleKillMonster(param)
	listenTaskStatus(1, param)
end
----------------------------------------------------------------------
-- 处理通关事件
local function handlePassLocation(param)
	listenTaskStatus(2, param)
end
----------------------------------------------------------------------
-- 处理收集物品事件
local function handleCollectItem(itemId)
	listenTaskStatus(3, {itemId=itemId})
end
----------------------------------------------------------------------
-- 处理强化装备
local function handleStrengthenEquip(data)
	if true == data.success then
		listenTaskStatus(5, nil)
	end
end
----------------------------------------------------------------------
-- 处理分解装备
local function handleResloveEquip(data)
	if true == data.success then
		listenTaskStatus(6, nil)
	end
end
----------------------------------------------------------------------
-- 请求任务列表
TaskLogic.request_task_infos = function()
	local req = req_task_infos()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_task_infos"])
end
----------------------------------------------------------------------
-- 请求完成任务
TaskLogic.request_finish_task = function(task_id)
	local req = req_finish_task()
	req.task_id = task_id
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_finish_task"])
end
----------------------------------------------------------------------
-- 获取任务列表
TaskLogic.getTaskList = function()
	return mTaskInfos
end
----------------------------------------------------------------------
-- 获取任务信息
TaskLogic.getTaskInfo = function(task_id)
	for k, v in pairs(mTaskInfos) do
		if task_id == v.task_id then
			return k, v
		end
	end
	return 0, nil
end
----------------------------------------------------------------------
-- 获取已完成的任务列表
TaskLogic.getFinishedTaskList = function()
	return mFinishedTaskInfos
end
----------------------------------------------------------------------
-- 获取任务的完成数量,-1没有该任务
TaskLogic.getTaskCompleteCount = function(taskRow)
	local index, taskInfo = TaskLogic.getTaskInfo(taskRow.id)
	if 0 == index then	-- 没有该条任务
		return 0
	end
	local taskSubType = taskRow.sub_type
	if 1 == taskSubType then			-- 击杀怪物
		return taskInfo.args[1]
	elseif 2 == taskSubType then		-- 通过副本
		return taskInfo.args[1]
	elseif 3 == taskSubType then		-- 收集物品
		local items = ModelPlayer.findBagByItemid(taskRow.collect_id)
		if nil == items then
			return 0
		end
		return #items
	elseif 4 == taskSubType then		-- 符文充能
		return taskInfo.args[1]
	elseif 5 == taskSubType then		-- 强化装备
		return taskInfo.args[1]
	elseif 6 == taskSubType then		-- 分解装备
		return taskInfo.args[1]
	elseif 7 == taskSubType then		-- 占卜次数
		return taskInfo.args[1]
	end
	return 0
end
----------------------------------------------------------------------
-- 判断任务是否已经完成
TaskLogic.isTaskFinished = function(taskRow)
	local count = TaskLogic.getTaskCompleteCount(taskRow)
	return count >= taskRow.number
end
----------------------------------------------------------------------
-- 判断任务是否被锁定
TaskLogic.isTaskLocked = function(taskRow)
	if taskRow.need_level > ModelPlayer.getLevel() then		-- 等级不足
		return true
	end
		
	if taskRow.location > 0 then
		local copyInfo = LogicTable.getCopyById(taskRow.location)
		if tonumber(copyInfo.type) == 2 and CopyDateCache.getCopyStatus(LIMIT_EQUIP_JYFB.copy_id) ~= "pass" then 
			return true
		end
		if tonumber(copyInfo.type) == 3 and CopyDateCache.getCopyStatus(LIMIT_ENTER_BOSS.copy_id) ~= "pass" then 
			return true
		end
		if "lock" == CopyDateCache.getCopyStatus(taskRow.location) then	-- 副本未解锁
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_task_infos"], notify_task_infos, handleNotifyTaskInfos)
NetSocket_registerHandler(NetMsgType["msg_notify_finish_task"], notify_finish_task, handleNotifyFinishTask)
-- 游戏事件注册
EventCenter_subscribe(EventDef["ED_COPY_INFOS"], handleCopyInfos)
EventCenter_subscribe(EventDef["ED_KILL_MONSTER"], handleKillMonster)
EventCenter_subscribe(EventDef["ED_PASS_LOCATION"], handlePassLocation)
EventCenter_subscribe(EventDef["ED_COLLECT_ITEM"], handleCollectItem)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_STRENGTHEN"], handleStrengthenEquip)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_RESLOVE"], handleResloveEquip)

