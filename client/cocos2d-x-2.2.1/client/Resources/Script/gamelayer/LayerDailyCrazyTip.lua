----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-05
-- Brief:	每日活跃奖励信息界面
----------------------------------------------------------------------
local mLayerRoot = nil
local mActivenessRewardId = 0

LayerDailyCrazyTip = {}
LayerAbstract:extend(LayerDailyCrazyTip)
----------------------------------------------------------------------
-- 获取奖励信息:图标,名字,类型,名字颜色
local function getRewardInfo(rewardId)
	local nameColor = ccc3(255, 255, 255)
	local quality = 1
	local rewardItemRow = LogicTable.getRewardItemRow(rewardId)
	if 7 == rewardItemRow.type then		-- 物品
		local itemRow = LogicTable.getItemById(rewardItemRow.temp_id)
		if item_type["equipment"] == itemRow.type then	-- 装备
			local equipRow = ModelEquip.getEquipRow(rewardItemRow.temp_id)
			local str1, str2 = CommonFunc_GetEquipTypeString(equipRow.type)
		end
		nameColor = BackpackLogic.getColour("quality", itemRow.quality)
		quality = itemRow.quality
	else
		nameColor = ccc3(255, 255, 255)
		quality = 1
	end
	return rewardItemRow.icon, rewardItemRow.name, nameColor, quality
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_DailyCrazyTip")
	end
end
----------------------------------------------------------------------
-- 点击领取按钮
local function clickGetBtn(typeName, widget)
	if "releaseUp" == typeName then
		widget:setTouchEnabled(false)
		DailyActivenessLogic.requestActivenessReward(mActivenessRewardId)
	end
end
----------------------------------------------------------------------
-- 创建奖励单元格
local function createReawardCell(cell, data, index)
	local iconStr, nameStr, nameColor, quality = getRewardInfo(data.rewardId)
	-- 背景
	local cellBg = UIImageView:create()
	cellBg:loadTexture("public2_bg_05.png")
	cellBg:setScale9Enabled(true)
	cellBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	cellBg:setSize(CCSizeMake(145, 149))
	-- 奖励名称
	local nameLabel = CommonFunc_getLabel(nameStr, 20, nameColor)
	nameLabel:setPosition(ccp(0, 56))
	cellBg:addChild(nameLabel)
	-- 奖励图标
	local iconImageView = UIImageView:create()
	iconImageView:loadTexture(iconStr)
	iconImageView:setScale(0.8)
	iconImageView:setPosition(ccp(0, 0))
	CommonFunc_SetQualityFrame(iconImageView, quality)
	cellBg:addChild(iconImageView)
	
	iconImageView:setTouchEnabled(true)
	local function clickSkillIcon(iconImageView)
		showLongInfoByRewardId(data.rewardId,iconImageView)
	end
	
	local function clickSkillIconEnd(iconImageView)
		longClickCallback_reward(data.rewardId,iconImageView)
	end

	UIManager.registerEvent(iconImageView, nil, clickSkillIcon, clickSkillIconEnd)
	
	
	
	
	-- 奖励数量
	local numLabel = CommonFunc_getLabel(tostring(data.rewardNum), 20, nameColor)
	numLabel:setPosition(ccp(0, -56))
	cellBg:addChild(numLabel)
	return cellBg
end
----------------------------------------------------------------------
-- 设置领取按钮状态
local function setGetBtnStatus()
	local getBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_get"), "UIButton")
	if 0 == DailyActivenessLogic.getAwardStatus(mActivenessRewardId) then
		getBtn:setTouchEnabled(true)
		getBtn:loadTextureNormal("onlinereward_buttom_receive.png")
	else
		getBtn:loadTextureNormal("onlinereward_buttom_receive2.png")
		getBtn:setTouchEnabled(false)
	end
end
----------------------------------------------------------------------
-- 领取奖励
local function handleGetActivenessAward(success)
	if nil == mLayerRoot then
		return
	end
	if true == success then
		UIManager.pop("UI_DailyCrazyTip")
		local activenessRewardRow = LogicTable.getActivenessRewardRow(mActivenessRewardId)
		CommonFunc_showItemGetInfo(activenessRewardRow.ids, activenessRewardRow.amounts)
		UIManager.popBounceWindow("UI_TempPack")
	else
		setGetBtnStatus()
	end
end
----------------------------------------------------------------------
-- 初始化
LayerDailyCrazyTip.init = function(activenessRewardId)
	mActivenessRewardId = activenessRewardId
	mLayerRoot = UIManager.findLayerByTag("UI_DailyCrazyTip")
	-- 关闭按钮
	local closeBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 领取按钮
	local getBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_get"), "UIButton")
	getBtn:registerEventScript(clickGetBtn)
	-- 列表
	local activenessRewardRow = LogicTable.getActivenessRewardRow(activenessRewardId)
	local dataTable = {}
	for i=1, #activenessRewardRow.ids do
		local dataCell = {}
		dataCell.rewardId = activenessRewardRow.ids[i] or 0
		dataCell.rewardNum = activenessRewardRow.amounts[i] or 0
		table.insert(dataTable, dataCell)
	end
	local scrollView = tolua.cast(mLayerRoot:getWidgetByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, dataTable, createReawardCell, "V", 145, 149, 10, 3, 3, true, nil, true, true)
	-- 标题
	local titleLabel = tolua.cast(mLayerRoot:getWidgetByName("Label_title"), "UILabel")
	titleLabel:setText(GameString.get("ACTIVENESS_STR_03", activenessRewardRow.need_activess))
	--
	setGetBtnStatus()
end
----------------------------------------------------------------------
-- 销毁
LayerDailyCrazyTip.destroy = function()
	mLayerRoot = nil
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_ACTIVENESS_AWARD_GET"], handleGetActivenessAward)

