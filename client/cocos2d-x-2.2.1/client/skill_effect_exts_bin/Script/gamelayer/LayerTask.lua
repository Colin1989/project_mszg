----------------------------------------------------------------------
-- jaron.ho
-- 2014-03-14
-- 任务界面
----------------------------------------------------------------------

local mLayerTaskRoot = nil
local mScrollView = nil

LayerTask = {}
LayerAbstract:extend(LayerTask)

-- 点击关闭任务面板按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerMainEnter,"MainEnter_1.ExportJson")	
	end
end

-- 点击立即前往按钮
local function clickGotoPlayBtn(typeName, widget)
	if "releaseUp" == typeName then
		local task_id = widget:getTag()
		cclog("============= click goto play btn: "..task_id)
	end
end

-- 点击领取奖励按钮
local function clickGetRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		local task_id = widget:getTag()
		cclog("============= click get reward btn: "..task_id)
		TaskLogic.request_finish_task(task_id)
	end
end

-- 显示任务标题
local function showTaskCellTitle(cell, task)
	local titleCtrl = tolua.cast(cell:getChildByName("task_title"), "UIImageView")
	--
	local anchorPoint = titleCtrl:getAnchorPoint()
	local pos = titleCtrl:getPosition()
	local size = titleCtrl:getContentSize()
	local fontSize = 20
	local color = ccc3(255, 255, 255)	-- 白色
	pos = ccp(pos.x - anchorPoint.x*size.width, pos.y + (anchorPoint.y - 0.5)*size.height)
	local label1 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, task.title)
	cell:addChild(label1)
	--
	local locked = TaskLogic.isTaskLocked(task)
	if false == locked then
		return
	end
	--
	pos = label1:getPosition()
	size = label1:getContentSize()
	color = ccc3(0, 0, 0)			-- 黑色
	local label2 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, "（")
	cell:addChild(label2)
	--
	pos = label2:getPosition()
	size = label2:getContentSize()
	color = ccc3(255, 0, 0)			-- 红色
	local label3 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, "需要等级Lv"..task.need_level)
	cell:addChild(label3)
	-- 
	pos = label3:getPosition()
	size = label3:getContentSize()
	color = ccc3(0, 0, 0)			-- 黑色
	local label4 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, "）")
	cell:addChild(label4)
end

-- 显示任务目标
local function showTaskCellTarget(cell, task, args)
	local str_tb = CommonFunc_split(task.text, "{0}")
	local completeCount = TaskLogic.getTaskCompleteCount(task, args)
	local isFinished = TaskLogic.isTaskFinished(task, args)
	--
	local targetCtrl = tolua.cast(cell:getChildByName("task_target"), "UIImageView")
	--
	local anchorPoint = targetCtrl:getAnchorPoint()
	local pos = targetCtrl:getPosition()
	local size = targetCtrl:getContentSize()
	local fontSize = 20
	local color = ccc3(255, 255, 255)
	local zOrder = 3
	pos = ccp(pos.x - anchorPoint.x*size.width, pos.y + (anchorPoint.y - 0.5)*size.height)
	local label1 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, nil, str_tb[1], nil, zOrder)
	cell:addChild(label1)
	-- 当前完成数量
	pos = label1:getPosition()
	size = label1:getContentSize()
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
	else
		color = ccc3(255, 0, 0)		-- 红色
	end
	local label2 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, tostring(completeCount), nil, zOrder)
	cell:addChild(label2)
	-- 任务需要完成数量
	pos = label2:getPosition()
	size = label2:getContentSize()
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
	else
		color = ccc3(0, 0, 0)		-- 黑色
	end
	local label3 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, "/"..task.number, nil, zOrder)
	cell:addChild(label3)
	--
	pos = label3:getPosition()
	size = label3:getContentSize()
	local label4 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, str_tb[2], nil, zOrder)
	cell:addChild(label4)
end

-- 显示经验奖励
local function showTaskCellExpReward(bg, icon, label, expReward)
	icon = tolua.cast(icon, "UIImageView")
	label = tolua.cast(label, "UILabel")
	bg:setVisible(true)
	icon:setVisible(true)
	label:setVisible(true)
	label:setText("*"..tostring(expReward))
end

-- 显示金钱奖励
local function showTaskCellMoneyReward(bg, icon, label, moneyReward)
	icon = tolua.cast(icon, "UIImageView")
	label = tolua.cast(label, "UILabel")
	bg:setVisible(true)
	icon:setVisible(true)
	label:setVisible(true)
	label:setText("*"..tostring(moneyReward))
end

-- 显示物品奖励
local function showTaskCellItemReward(bg, icon, label, itemReward)
	icon = tolua.cast(icon, "UIImageView")
	label = tolua.cast(label, "UILabel")
	local item = LogicTable.getItemById(itemReward)
	bg:setVisible(true)
	icon:setVisible(true)
	label:setVisible(true)
	label:setText("*1")
end

-- 显示任务奖励
local function showTaskCellReward(cell, task)
	local reward_bg1 = cell:getChildByName("reward_bg1")
	reward_bg1:setVisible(false)
	local reward_icon1 = cell:getChildByName("reward_icon1")
	reward_icon1:setVisible(false)
	local reward_label1 = cell:getChildByName("reward_label1")
	reward_label1:setVisible(false)
	local reward_bg2 = cell:getChildByName("reward_bg2")
	reward_bg2:setVisible(false)
	local reward_icon2 = cell:getChildByName("reward_icon2")
	reward_icon2:setVisible(false)
	local reward_label2 = cell:getChildByName("reward_label2")
	reward_label2:setVisible(false)
	local reward_bg3 = cell:getChildByName("reward_bg3")
	reward_bg3:setVisible(false)
	local reward_icon3 = cell:getChildByName("reward_icon3")
	reward_icon3:setVisible(false)
	local reward_label3 = cell:getChildByName("reward_label3")
	reward_label3:setVisible(false)
	--
	local expReward = tonumber(task.exp_reward)
	local moneyReward = tonumber(task.money_reward)
	local itemReward = tonumber(task.item_reward)
	--
	if expReward > 0 then			-- 有经验奖励
		showTaskCellExpReward(reward_bg1, reward_icon1, reward_label1, expReward)
		if moneyReward > 0 then		-- 有金钱奖励
			showTaskCellMoneyReward(reward_bg2, reward_icon2, reward_label2, moneyReward)
			if itemReward > 0 then	-- 有物品奖励
				showTaskCellItemReward(reward_bg3, reward_icon3, reward_label3, itemReward)
			end
		else						-- 无金钱奖励
			if itemReward > 0 then	-- 有物品奖励
				showTaskCellItemReward(reward_bg2, reward_icon2, reward_label2, itemReward)
			end
		end
	else							-- 无经验奖励
		if moneyReward > 0 then		-- 有金钱奖励
			showTaskCellMoneyReward(reward_bg1, reward_icon1, reward_label1, moneyReward)
			if itemReward > 0 then	-- 有物品奖励
				showTaskCellItemReward(reward_bg2, reward_icon2, reward_label2, itemReward)
			end
		else						-- 无金钱奖励
			showTaskCellItemReward(reward_bg1, reward_icon1, reward_label1, itemReward)
		end
	end
end

-- 创建任务条
local function createTaskCell(taskInfo)
	local task = LogicTable.getTaskRow(taskInfo.task_id)
	local cell = GUIReader:shareReader():widgetFromJsonFile("TaskCell.ExportJson")
	-- 任务标题
	showTaskCellTitle(cell, task)
	-- 任务目标
	showTaskCellTarget(cell, task, taskInfo.args)
	-- 任务奖励
	showTaskCellReward(cell, task)
	-- 立即前往按钮
	local cell_goto_play_btn = cell:getChildByName("goto_play_btn")
	cell_goto_play_btn:registerEventScript(clickGotoPlayBtn)
	cell_goto_play_btn:setTag(task.id)
	-- 领取奖励按钮
	local cell_get_reward_btn = cell:getChildByName("get_reward_btn")
	cell_get_reward_btn:registerEventScript(clickGetRewardBtn)
	cell_get_reward_btn:setTag(task.id)
	-- 等级不足图标
	local cell_invalid_icon = cell:getChildByName("invalid_icon")
	if true == TaskLogic.isTaskLocked(task) then						-- 等级不足
		cell_invalid_icon:setVisible(true)
		cell_goto_play_btn:setEnabled(false)
		cell_get_reward_btn:setEnabled(false)
	else																-- 等级达到
		if true == TaskLogic.isTaskFinished(task, taskInfo.args) then	-- 任务完成
			cell_get_reward_btn:setEnabled(true)
			cell_goto_play_btn:setEnabled(false)
		else															-- 任务未完成
			cell_goto_play_btn:setEnabled(true)
			cell_get_reward_btn:setEnabled(false)
		end
		cell_invalid_icon:setVisible(false)
	end
	-- 主线任务图标
	local cell_main_type_icon = cell:getChildByName("main_type_icon")
	-- 支线任务图标
	local cell_sub_type_icon = cell:getChildByName("sub_type_icon")
	if 1 == tonumber(task.main_type) then						-- 主线任务
		cell_main_type_icon:setVisible(true)
		cell_sub_type_icon:setVisible(false)
	elseif 2 == tonumber(task.main_type) then					-- 支线任务
		cell_sub_type_icon:setVisible(true)
		cell_main_type_icon:setVisible(false)
	end
	return cell
end

-- 更新任务列表
local function updateTaskList()
	if nil == mLayerTaskRoot or nil == mScrollView then
		return
	end
	mScrollView:removeAllChildren()
	local cellArray = {}	-- 任务列表
	for key, value in pairs(TaskLogic.taskInfos) do
		table.insert(cellArray, createTaskCell(value))
	end
	setListViewAdapter(mLayerTaskRoot, tolua.cast(mScrollView, "UIScrollView"), cellArray, "V")
end

-- 初始化
LayerTask.init = function(rootView)
	mLayerTaskRoot = rootView
	mScrollView = rootView:getChildByName("list")	-- 滚动层
	local closeBtn = rootView:getChildByName("close_btn")
	closeBtn:registerEventScript(clickCloseBtn)
	updateTaskList()
end

-- 销毁
LayerTask.destory = function()
	mLayerTaskRoot = nil
	mScrollView = nil
end

-- 游戏事件注册
EventCenter_subscribe("ED_UPDATE_TASK_LIST", updateTaskList)
