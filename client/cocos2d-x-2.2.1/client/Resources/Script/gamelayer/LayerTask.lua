----------------------------------------------------------------------
-- jaron.ho
-- 2014-03-14
-- 任务界面
----------------------------------------------------------------------

local mLayerTaskRoot = nil
local mScrollView = nil
local mTaskCell = nil
local mTempButton = nil
local taskInfo  -- 记录领取奖励的任务ID

LayerTask = {}
LayerAbstract:extend(LayerTask)

----------------------------------------------------------------------
-- 点击关闭
local function onClickCloseBtn(typeName, widget)
	LayerMain.pullPannel()
end
----------------------------------------------------------------------
-- 点击立即前往按钮
local function clickGotoPlayBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local task_id = widget:getTag()
		local task = LogicTable.getTaskRow(task_id)
		local task_sub_type = task.sub_type
		if 1 == task_sub_type or 2 == task_sub_type or 3 == task_sub_type then
			EventCenter_post(EventDef["ED_TaskToCopy"], task.location)
			UIManager.push("UI_CopyTips", task.location)
		else
			LayerMain.pullPannel(LayerTask)
		end
	end
end
----------------------------------------------------------------------
-- 点击领取奖励按钮
local function clickGetRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		mTempButton = widget
		mTempButton:setTouchEnabled(false)
		local task_id = widget:getTag()
		taskInfo = task_id
		TaskLogic.request_finish_task(task_id)
	end
end
----------------------------------------------------------------------
-- 获取控件坐标和大小
local function getPositionAndSize(ctrl)
	local pos = ctrl:getPosition()
	local size = ctrl:getContentSize()
	return pos, size
end
----------------------------------------------------------------------
-- 显示任务标题
local function showTaskCellTitle(cell, task)
	local titleCtrl = tolua.cast(cell:getChildByName("task_title"), "UIImageView")
	--
	local anchorPoint = titleCtrl:getAnchorPoint()
	local pos, size = getPositionAndSize(titleCtrl)
	local fontSize = 18
	local color = ccc3(255, 255, 255)	-- 白色
	pos = ccp(pos.x - anchorPoint.x*size.width, pos.y + (anchorPoint.y - 0.5)*size.height)
	local label1 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width / 2 + 10, 0), nil, fontSize, color, task.title)
	titleCtrl:addChild(label1)
	--
	if false == TaskLogic.isTaskLocked(task) then
		return
	end
	--
	pos, size = getPositionAndSize(label1)
	color = ccc3(0, 0, 0)			-- 黑色
	local label2 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width, 0), nil, fontSize, color, GameString.get("PUBLIC_L_BRACKET"))
	label1:addChild(label2)
	--
	pos, size = getPositionAndSize(label2)
	color = ccc3(255, 0, 0)			-- 红色
	local label3 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width, 0), nil, fontSize, color, GameString.get("TASK_STR_01", task.need_level))
	label2:addChild(label3)
	-- 
	pos, size = getPositionAndSize(label3)
	color = ccc3(0, 0, 0)			-- 黑色
	local label4 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width, 0), nil, fontSize, color, GameString.get("PUBLIC_R_BRACKET"))
	label3:addChild(label4)
end
----------------------------------------------------------------------
-- 显示任务目标
local function showTaskCellTarget(cell, task)
	local str_tb = CommonFunc_split(task.text, "{0}")
	local completeCount = TaskLogic.getTaskCompleteCount(task)
	local isFinished = TaskLogic.isTaskFinished(task)
	--
	local targetCtrl = tolua.cast(cell:getChildByName("task_target"), "UIImageView")
	--
	local anchorPoint = targetCtrl:getAnchorPoint()
	local pos, size = getPositionAndSize(targetCtrl)
	local fontSize = 18
	local color = ccc3(255, 255, 255)
	local zOrder = 3
	pos = ccp(pos.x - anchorPoint.x*size.width, pos.y + (anchorPoint.y - 0.5)*size.height)
	local label1 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width / 2 + 10, 0), nil, fontSize, nil, str_tb[1], nil, zOrder)
	targetCtrl:addChild(label1)
	-- 当前完成数量
	pos, size = getPositionAndSize(label1)
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
	else
		color = ccc3(255, 0, 0)		-- 红色
	end
	local label2 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width, 0), nil, fontSize, color, tostring(completeCount), nil, zOrder)
	label1:addChild(label2)
	-- 任务需要完成数量
	pos, size = getPositionAndSize(label2)
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
	else
		color = ccc3(255, 255, 255)	-- 白色
	end
	local label3 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width, 0), nil, fontSize, color, "/"..task.number, nil, zOrder)
	label2:addChild(label3)
	--
	pos, size = getPositionAndSize(label3)
	local label4 = CommonFunc_createUILabel(ccp(0, 0.5), ccp(size.width, 0), nil, fontSize, color, str_tb[2], nil, zOrder)
	label3:addChild(label4)
end
----------------------------------------------------------------------
-- 点击奖励图标
local function clickRewardIcon(widget)
	CommonFunc_showInfo(0, widget:getTag(), 0)
end
----------------------------------------------------------------------
-- 显示奖励图标和描述
local function showTaskCellRewardDescribe(bgCtrl, iconCtrl, labelBgCtrl, labelCtrl, icon, reward, rewardId)
	iconCtrl = tolua.cast(iconCtrl, "UIImageView")
	labelCtrl = tolua.cast(labelCtrl, "UILabel")
	bgCtrl:setVisible(true)
	iconCtrl:loadTexture(icon)
	iconCtrl:setTag(rewardId)
	iconCtrl:setTouchEnabled(true)
	--iconCtrl:registerEventScript(clickRewardIcon)
	
	local function clickSkillIcon(widget)
		showLongInfoByRewardId(rewardId,widget)
	end
	
	local function clickSkillIconEnd(widget)
		longClickCallback_reward(rewardId,widget)
	end
	
	UIManager.registerEvent(iconCtrl, clickRewardIcon, clickSkillIcon, clickSkillIconEnd)
			
	iconCtrl:setVisible(true)
	labelBgCtrl:setVisible(true)
	labelCtrl:setText(tostring(reward))
	labelCtrl:setVisible(true)
end
----------------------------------------------------------------------
-- 获取任务奖励控件,index:1,2,3
local function getTaskCellRewardCtrls(cell, index)
	local reward_bg = cell:getChildByName("reward_bg"..index)
	reward_bg:setVisible(false)
	local reward_icon = cell:getChildByName("reward_icon"..index)
	reward_icon:setVisible(false)
	local reward_label_bg = cell:getChildByName("reward_"..index)
	reward_label_bg:setVisible(false)
	local reward_label = cell:getChildByName("reward_label"..index)
	reward_label:setVisible(false)
	return reward_bg, reward_icon, reward_label_bg, reward_label
end
----------------------------------------------------------------------
-- 显示任务奖励
local function showTaskCellReward(cell, task)
	for i=1, 3 do
		local reward_bg, reward_icon, reward_label_bg, reward_label = getTaskCellRewardCtrls(cell, tostring(i))
		local rewardId = task.reward_ids[i]
		local rewardAmount = task.reward_amounts[i]
		if rewardId and rewardAmount then
			local rewardItem = LogicTable.getRewardItemRow(rewardId)
			--Log("showTaskCellReward***********",rewardId,rewardItem)
			showTaskCellRewardDescribe(reward_bg, reward_icon, reward_label_bg, reward_label, rewardItem.icon, rewardAmount, rewardId)
		end
	end
end
----------------------------------------------------------------------
-- 显示按钮
local function showTaskCellBtn(cell, task)
	-- 立即前往按钮
	local cell_goto_play_btn = cell:getChildByName("goto_play_btn")
	cell_goto_play_btn:registerEventScript(clickGotoPlayBtn)
	cell_goto_play_btn:setTag(task.id)
	cell_goto_play_btn:setEnabled(false)
	-- 领取奖励按钮
	local cell_get_reward_btn = cell:getChildByName("get_reward_btn")
	cell_get_reward_btn:registerEventScript(clickGetRewardBtn)
	cell_get_reward_btn:setTag(task.id)
	cell_get_reward_btn:setEnabled(false)
	-- 等级不足图标
	local cell_invalid_icon = cell:getChildByName("invalid_icon")
	cell_invalid_icon:setVisible(false)
	if true == TaskLogic.isTaskLocked(task) then						-- 等级不足
		cell_invalid_icon:setVisible(true)
	else																-- 等级达到
		if true == TaskLogic.isTaskFinished(task) then					-- 任务完成
			cell_get_reward_btn:setEnabled(true)
		else															-- 任务未完成
			cell_goto_play_btn:setEnabled(true)
		end
	end
end
----------------------------------------------------------------------
-- 显示任务类型
local function showTaskCellType(cell, task)
	-- 主线任务图标
	local cell_main_type_icon = cell:getChildByName("main_type_icon")
	cell_main_type_icon:setVisible(false)
	-- 支线任务图标
	local cell_sub_type_icon = cell:getChildByName("sub_type_icon")
	cell_sub_type_icon:setVisible(false)
	if 1 == task.main_type then						-- 主线任务
		cell_main_type_icon:setVisible(true)
	elseif 2 == task.main_type then					-- 支线任务
		cell_sub_type_icon:setVisible(true)
	end
end
----------------------------------------------------------------------
-- 创建任务条
local function createTaskCell(rowCell, task, index)
	if nil == mTaskCell then
		mTaskCell = GUIReader:shareReader():widgetFromJsonFile("TaskCell.json")
	end
	local cell = mTaskCell:clone()
	mTaskCell:retain()
	showTaskCellTitle(cell, task)			-- 任务标题
	showTaskCellTarget(cell, task)			-- 任务目标
	showTaskCellReward(cell, task)			-- 任务奖励
	showTaskCellBtn(cell, task)				-- 任务按钮
	showTaskCellType(cell, task)			-- 任务类型
	return cell
end
----------------------------------------------------------------------
-- 更新任务列表
local function updateTaskList()
	if nil == mLayerTaskRoot or nil == mScrollView then
		return
	end
	
	local taskIdList = {}
	local taskList = TaskLogic.getTaskList()
	for key, val in pairs(taskList) do
		local temp = LogicTable.getTaskRow(val.task_id)
		if false == TaskLogic.isTaskLocked(temp) then
			table.insert(taskIdList, temp)
		end
	end
	-- cclog("------------------------------>taskIdList")
	-- Log(taskIdList)
	UIScrollViewEx.show(tolua.cast(mScrollView, "UIScrollView"), taskIdList, createTaskCell, "V", 569, 204, 0, 1, 4, true, nil, true, true)
end
----------------------------------------------------------------------
-- 任务完成
local function taskFinished(success)
	if mTempButton and false == success then
		mTempButton:setTouchEnabled(true)
	end
	local task = LogicTable.getTaskRow(taskInfo)
	UIManager.push("UI_MissionComplete",task)
end
----------------------------------------------------------------------
-- 获取任务提示控件的位置和大小
local function getTaskCtrlPositionAndSize(ctrl)
	local x, y = ctrl:getPosition()
	local size = ctrl:getContentSize()
	return ccp(x, y), size
end
----------------------------------------------------------------------
-- 任务提示动作
local function taskTipRunAction(node)
	local delayTime = CCDelayTime:create(0.6)
	local moveBy = CCMoveBy:create(0.5, ccp(0, 30))
	local callFuncN = CCCallFuncN:create(
		function(sender)
			sender:getParent():removeChild(sender, true)
		end
	)
	local actionArray = CCArray:createWithCapacity(3)
	actionArray:addObject(delayTime)
	actionArray:addObject(moveBy)
	actionArray:addObject(callFuncN)
	node:runAction(CCSequence:create(actionArray))
end
----------------------------------------------------------------------
-- 初始化
LayerTask.init = function(rootView)
	-- 游戏事件注册
	EventCenter_subscribe(EventDef["ED_UPDATE_TASK_LIST"], updateTaskList)
	EventCenter_subscribe(EventDef["ED_TASK_FINISHED"], taskFinished)
	--
	mLayerTaskRoot = rootView
	
	-- 关闭
	local closeBtn = tolua.cast(mLayerTaskRoot:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(onClickCloseBtn)
	
	mScrollView = rootView:getChildByName("list")	-- 滚动层
	updateTaskList()
end
----------------------------------------------------------------------
-- 销毁
LayerTask.destroy = function()
	-- 游戏事件删除
	EventCenter_unsubscribe(EventDef["ED_UPDATE_TASK_LIST"], updateTaskList)
	EventCenter_unsubscribe(EventDef["ED_TASK_FINISHED"], taskFinished)
	--
	mLayerTaskRoot = nil
	mScrollView = nil
	mTempButton = nil
end
----------------------------------------------------------------------
-- 任务提示
LayerTask.showTip = function(task_id)
	local node = CCNode:create()
	local task = LogicTable.getTaskRow(task_id)
	local str_tb = CommonFunc_split(task.text, "{0}")
	local completeCount = TaskLogic.getTaskCompleteCount(task)
	local isFinished = TaskLogic.isTaskFinished(task)
	--
	local pos, size = ccp(0, 0), CCSizeMake(0, 0)
	local fontSize = 20
	local color = ccc3(255, 255, 255)
	local label1 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, nil, str_tb[1])
	node:addChild(label1)
	-- 完成数量
	pos, size = getTaskCtrlPositionAndSize(label1)
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
	else
		color = ccc3(255, 0, 0)		-- 红色
	end
	local label2 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, completeCount.."/"..task.number)
	node:addChild(label2)
	--
	pos, size = getTaskCtrlPositionAndSize(label2)
	color = ccc3(255, 255, 255)
	local label3 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, str_tb[2])
	node:addChild(label3)
	--
	pos, size = getTaskCtrlPositionAndSize(label3)
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
		local label4 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, GameString.get("TASK_STR_02"))
		node:addChild(label4)
		pos, size = getTaskCtrlPositionAndSize(label4)
	end
	--
	local winSize = CCDirector:sharedDirector():getWinSize()
	node:setPosition(ccp(winSize.width/2 - (pos.x + size.width)/2, winSize.height/2))
	g_rootNode:addChild(node, LAYER_ORDER)
	taskTipRunAction(node)
end
----------------------------------------------------------------------

