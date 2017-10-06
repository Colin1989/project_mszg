----------------------------------------------------------------------
-- jaron.ho
-- 2014-03-14
-- 任务系统
----------------------------------------------------------------------

TaskLogic = {}
TaskLogic.taskInfos = {}	-- 缓存本地任务列表

-- 根据任务类型排序,主线＞支线
local function sortByMainType(a, b)
	local aTask = LogicTable.getTaskRow(a.task_id)
	local bTask = LogicTable.getTaskRow(b.task_id)
	return aTask.main_type < bTask.main_type
end

-- 根据完成状态进行排序,已完成＞进行中＞已锁定
local function sortByStatus(a, b)
	local aTask = LogicTable.getTaskRow(a.task_id)
	local aStatus = 0	-- 0-已锁定,1-进行中,2-已完成
	if true == TaskLogic.isTaskLocked(aTask) then
		aStatus = 0
	else
		if true == TaskLogic.isTaskFinished(aTask, a.args) then
			aStatus = 2
		else
			aStatus = 1
		end
	end
	--
	local bTask = LogicTable.getTaskRow(b.task_id)
	local bStatus = 0	-- 0-已锁定,1-进行中,2-已完成
	if true == TaskLogic.isTaskLocked(bTask) then
		bStatus = 0
	else
		if true == TaskLogic.isTaskFinished(bTask, b.args) then
			bStatus = 2
		else
			bStatus = 1
		end
	end
	--
	return aStatus > bStatus
end

-- 通知任务列表
local function handleNotifyTaskInfos(packet)
	table.sort(packet.infos, sortByMainType)
	table.sort(packet.infos, sortByStatus)
	TaskLogic.taskInfos = packet.infos
	EventCenter_post("ED_UPDATE_TASK_LIST")
end

-- 通知任务完成
local function handleNotifyFinishTask(packet)
	local taskId = packet.task_id
	local isSuccess = packet.is_success
	if isSuccess == common_result["common_success"] then	-- 任务完成(领取奖励成功)
	else													-- 任务未完成(领取奖励失败)
	end
end

-- 监听任务状态
local function listenTaskStatus(taskSubId, id)
	for k, v in pairs(TaskLogic.taskInfos) do
		local task = LogicTable.getTaskRow(v.task_id)
		local findTask = false
		if 1 == taskSubId then			-- 击杀怪物
			if id == tonumber(task.monster_id) then
				findTask = true
				local count = TaskLogic.getTaskCompleteCount(task, v.args)
				TaskLogic.taskInfos[k].args[1] = count + 1
			end
		elseif 2 == taskSubId then		-- 通关副本
			if id == tonumber(task.location) then
				findTask = true
				local count = TaskLogic.getTaskCompleteCount(task, v.args)
				TaskLogic.taskInfos[k].args[1] = count + 1
			end
		elseif 3 == taskSubId then		-- 收集物品
			if id == tonumber(task.collect_id) then
				findTask = true
			end
		end
		if true == findTask then
			Toast.showTaskTip(v)		-- 界面提示
			break
		end
	end
end

-- 处理击杀怪物事件
local function handleKillMonster(monsterId)
	listenTaskStatus(1, monsterId)
end

-- 处理通关事件
local function handlePassLocation(locationId)
	listenTaskStatus(2, locationId)
end

-- 处理收集物品事件
local function handleCollectItem(itemId)
	listenTaskStatus(3, itemId)
end

-- 初始化
TaskLogic.init = function()
	NetSocket_registerHandler(NetMsgType["msg_notify_task_infos"], notify_task_infos(), handleNotifyTaskInfos)
	NetSocket_registerHandler(NetMsgType["msg_notify_finish_task"], notify_finish_task(), handleNotifyFinishTask)
end

-- 请求任务列表
TaskLogic.request_task_infos = function()
	local req = req_task_infos()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_task_infos"])
end

-- 请求完成任务
TaskLogic.request_finish_task = function(task_id)
	local req = req_finish_task()
	req.task_id = task_id
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_finish_task"])
end

-- 获取任务的完成数量
-- task:对应任务数据表中的记录
-- args:对应task_info结构中的args字段
TaskLogic.getTaskCompleteCount = function(task, args)
	local taskSubType = tonumber(task.sub_type)
	if 1 == taskSubType then			-- 击杀怪物
		return args[1]
	elseif 2 == taskSubType then		-- 通过副本
		return args[1]
	elseif 3 == taskSubType then		-- 收集物品
		local items = ModelPlayer.findBagByItemid(task.collect_id)
		return #items
	end
	return 0
end

-- 判断任务是否已经完成
TaskLogic.isTaskFinished = function(task, args)
	local completeCount = TaskLogic.getTaskCompleteCount(task, args)
	return tonumber(completeCount) >= tonumber(task.number)
end

-- 判断任务是否被锁定
TaskLogic.isTaskLocked = function(task)
	return tonumber(ModelPlayer.level) < tonumber(task.need_level)
end

TaskLogic.init()
-- 游戏事件注册
EventCenter_subscribe("ED_KILL_MONSTER", handleKillMonster)
EventCenter_subscribe("ED_PASS_LOCATION", handlePassLocation)
EventCenter_subscribe("ED_COLLECT_ITEM", handleCollectItem)
