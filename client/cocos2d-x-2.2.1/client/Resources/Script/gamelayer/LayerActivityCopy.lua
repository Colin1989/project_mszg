----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-15
-- Brief:	活动副本界面
----------------------------------------------------------------------
LayerActivityCopy = {}
local mRootNode = nil
local mCopyTable = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerActivityCopyGroup, "ActivityCopyGroup.json", widgetName)
	end
end
----------------------------------------------------------------------
-- 副本点击事件
local function clickActivityCopy(typeName, widget)
	if "releaseUp" == typeName then
		local index = widget:getTag()
		local data = mCopyTable[index]
		local playerLevel = ModelPlayer.getLevel()
		if playerLevel < data.need_level then
			Toast.Textstrokeshow(GameString.get("ACTIVITY_COPY_STR_01", data.need_level), ccc3(255,255,255), ccc3(0,0,0), 30)
		else
			local remainPlayTimes = ACTIVITY_COPY_PLAY_TIMES - CopyLogic.getActivityCopyPlayTimes()
			if remainPlayTimes <=0 then
				Toast.Textstrokeshow(GameString.get("ACTIVITY_COPY_STR_02"), ccc3(255,255,255), ccc3(0,0,0), 30)
				return
			end
			if ModelPlayer.getHpPower() < ACTIVITY_COPY_COST_PH then
				Toast.Textstrokeshow(GameString.get("Public_Power_BZ"), ccc3(255,255,255), ccc3(0,0,0), 30)
				return
			end
			UIManager.push("UI_ActivityCopyTip", data.id)
		end
	end
end
----------------------------------------------------------------------
-- 创建副本
local function createCopyCell(cell, data, index)
	local playerLevel = ModelPlayer.getLevel()
	local node = CommonFunc_getImgView("fuben_bg.png")
	node:setTouchEnabled(true)
	node:setTag(index)
	node:registerEventScript(clickActivityCopy)
	-- 副本图标
	local iconImage = CommonFunc_getImgView(data.small_icon)
	iconImage:setPosition(ccp(0, 23))
	node:addChild(iconImage)
	-- 左右门
	local rightDoorImage = CommonFunc_getImgView("fuben_door_right.png")
	rightDoorImage:setPosition(ccp(55, 17))
	rightDoorImage:setName("rightDoorImage"..data.id)
	node:addChild(rightDoorImage)
	local leftDoorImage = CommonFunc_getImgView("fuben_door_left.png")
	leftDoorImage:setPosition(ccp(-42, 17))
	leftDoorImage:setName("leftDoorImage"..data.id)
	node:addChild(leftDoorImage)
	if playerLevel >= data.need_level then
		rightDoorImage:setVisible(false)
		leftDoorImage:setVisible(false)
	end
	-- 外框
	local frameImage = CommonFunc_getImgView("fuben_frame_hd.png")
	node:addChild(frameImage)
	-- 等级
	local levelLabel = CommonFunc_getLabel(GameString.get("ACTIVITY_COPY_STR_01", data.need_level), 22)
	levelLabel:setPosition(ccp(0, -53))
	levelLabel:setName("levelLabel"..data.id)
	node:addChild(levelLabel)
	-- 描述
	local nameLabel = CommonFunc_getLabel(data.name, 22)
	nameLabel:setPosition(ccp(0, -53))
	nameLabel:setName("nameLabel"..data.id)
	node:addChild(nameLabel)
	-- 等级限制
	if playerLevel < data.need_level then
		nameLabel:setVisible(false)
	else
		levelLabel:setVisible(false)
	end
	return node
end
----------------------------------------------------------------------
-- 开门
local function openDoor(copyId)
	if nil == mRootNode then
		return
	end
	local function doOpenDoorAction(imageView, distance)
		local moving = CCEaseBackOut:create(CCMoveBy:create(5.5, CCPointMake(distance, 0)))
		imageView:runAction(moving)
	end
	local rightDoorImage = tolua.cast(mRootNode:getChildByName("rightDoorImage"..copyId), "UIImageView")
	rightDoorImage:setVisible(true)
	doOpenDoorAction(rightDoorImage, 108)
	local leftDoorImage = tolua.cast(mRootNode:getChildByName("leftDoorImage"..copyId), "UIImageView")
	leftDoorImage:setVisible(true)
	doOpenDoorAction(leftDoorImage, -131)
	--
	local levelLabel = tolua.cast(mRootNode:getChildByName("levelLabel"..copyId), "UILabel")
	local nameLabel = tolua.cast(mRootNode:getChildByName("nameLabel"..copyId), "UILabel")
	local copyRow = LogicTable.getActivityCopyRow(copyId)
	if ModelPlayer.getLevel() < copyRow.need_level then
		nameLabel:setVisible(false)
		levelLabel:setVisible(true)
	else
		levelLabel:setVisible(false)
		nameLabel:setVisible(true)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerActivityCopy.init = function(rootView)
	mRootNode = rootView
    -- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 挑战次数
	local countLabel = tolua.cast(rootView:getChildByName("Label_count"), "UILabel")
	countLabel:setText(tostring(ACTIVITY_COPY_PLAY_TIMES + getVipAddValueById(9) - CopyLogic.getActivityCopyPlayTimes()))
	-- 体力消耗
	local phLabel = tolua.cast(rootView:getChildByName("Label_ph"), "UILabel")
	phLabel:setText(tostring(ACTIVITY_COPY_COST_PH))
	-- 副本列表
	local groupId = LayerActivityCopyGroup.getGroupId()
	mCopyTable = LogicTable.getActivityCopyTable(groupId)
	local scrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, mCopyTable, createCopyCell, "V", 268, 198, 13, 2, 3, true, nil, true, true)
end
----------------------------------------------------------------------
-- 销毁
LayerActivityCopy.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------
-- 活动副本信息
local function handleActivityCopyInfo()
	if nil == mRootNode then
		return
	end
	local countLabel = tolua.cast(mRootNode:getChildByName("Label_count"), "UILabel")
	countLabel:setText(tostring(ACTIVITY_COPY_PLAY_TIMES + getVipAddValueById(9) - CopyLogic.getActivityCopyPlayTimes()))
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_ACTIVITY_COPY_INFO"], handleActivityCopyInfo)


