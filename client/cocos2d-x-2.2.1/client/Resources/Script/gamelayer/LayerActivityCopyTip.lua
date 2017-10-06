----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-16
-- Brief:	活动副本详细信息界面
----------------------------------------------------------------------
LayerActivityCopyTip = {}
LayerAbstract:extend(LayerActivityCopyTip)
local mCopyRow = nil
----------------------------------------------------------------------
-- 进入游戏
local function enterGame()
	UIManager.pop("UI_ActivityCopyTip")
	if CopyDateCache.getCopyStatus(LIMIT_ASSISTANCE.copy_id) == "pass" and tonumber(LIMIT_ASSISTANCE.copy_id) ~= 1 then
		AssistanceLogic.setEnterType(1)
		UIManager.push("UI_Assistance")
	else
		FightStartup.startActivity(mCopyRow.id)
	end
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_ActivityCopyTip")
	end
end
----------------------------------------------------------------------
-- 点击确认按钮
local function clickSureBtn(typeName, widget)
	if "releaseUp" == typeName then
		enterGame()
	end
end
----------------------------------------------------------------------
-- 点击更换按钮
local function clickChangeBtn(typeName, widget)
	if "releaseUp" == typeName then
		local bundle = {}
		bundle.callback = enterGame
		UIManager.push("UI_SkillGroup", bundle)
	end
end
----------------------------------------------------------------------
-- 点击物品图标
local function clickAwardIcon(typeName, widget)
	if "releaseUp" == clickAwardIcon then
		CommonFunc_showInfo(0, widget:getTag())
	end
end
----------------------------------------------------------------------
-- 创建掉落物品单元格
local function createDropItemCell(cell, data, index)
	local node = CommonFunc_getImgView("Introduction_frame.png")
	-- 如果是装备特殊处理
	if 7 == data.type then			--物品
		local itemRow = LogicTable.getItemById(data.temp_id)
		if 1 == tonumber(itemRow.type) then
			local equipRow = ModelEquip.getEquipRow(data.temp_id)
			local strEquipType = CommonFunc_GetEquipTypeString(equipRow.type)
			local pross = CommonFunc_GetRoleTypeString(equipRow.type%10)
			-- 武器 + 职业
			local prossLabel = CommonFunc_createUILabel(nil, ccp(35, 0), nil, 16, CommonFunc_getQualityInfo(itemRow.quality).color, string.format("%s(%s)", strEquipType, pross), 2, 1)
			node:addChild(prossLabel)
		end
	end
	-- 名字
	local nameLabel = CommonFunc_createUILabel(nil, ccp(35, 20), nil, 19, ccc3(255, 255, 255), data.name, 1, 1)
	node:addChild(nameLabel)
	-- 掉落概率
	local rateLabel = CommonFunc_createUILabel(nil, ccp(35, -20), nil, 16, ccc3(255, 255, 255), GameString.get("DROP_RATE", GameString.get(CopyLogic.judgeRegion(data.drop_rate))), 3, 1)
	node:addChild(rateLabel)
	-- 图片
	local iconImage = CommonFunc_createUIImageView(nil, ccp(-79, 0), CCSizeMake(106, 106), "touming.png", string.format("headbackground_%d", index), 1)
	iconImage:setScale(0.7)
	iconImage:setTouchEnabled(true)
	iconImage:setTag(tonumber(data.id))
	node:addChild(iconImage)
	-- 品质框之类的
	FightOver_addQuaIconByRewardId(data.id, iconImage, 1, clickAwardIcon)
	return node
end
----------------------------------------------------------------------
-- 刷新技能组
local function refreshSkillGroup(rootView)
	local currSkillGroup = ModelSkill.getSkillGroup()
	for i=1, 4 do
		local skillImage = tolua.cast(rootView:getWidgetByName("ImageView_skill"..i), "UIImageView")
		local skill = ModelSkill.getSkill(currSkillGroup.skills[i])
		if nil == skill then
			skillImage:setTouchEnabled(false)
			skillImage:removeAllChildren()
			skillImage:loadTexture("public_runeback.png")
		else
			local function clickSkillIcon(typeName, widget)
				if "releaseUp" == typeName then
					local bundle = {}
					bundle.skill_id = skill.temp_id
					bundle.level = skill.value
					UIManager.push("UI_SkillInfo", bundle)
				end
			end
			CommonFunc_AddGirdWidget_Rune(skill.temp_id, skill.value, clickSkillIcon, skillImage)
		end
	end
end
----------------------------------------------------------------------
-- 初始化
LayerActivityCopyTip.init = function(copyId)
	mCopyRow = LogicTable.getActivityCopyRow(copyId)
	local rootNode = UIManager.findLayerByTag("UI_ActivityCopyTip")
	-- 关闭按钮
	local closeBtn = tolua.cast(rootNode:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 确认按钮
	local sureBtn = tolua.cast(rootNode:getWidgetByName("Button_sure"), "UIButton")
	sureBtn:registerEventScript(clickSureBtn)
	-- 更换按钮
	local changeBtn = tolua.cast(rootNode:getWidgetByName("Button_change"), "UIButton")
	changeBtn:registerEventScript(clickChangeBtn)
	-- 副本标题
	local nameLabel = tolua.cast(rootNode:getWidgetByName("Label_copy_name"), "UILabel")
	nameLabel:setText(mCopyRow.name)
	-- 副本描述
	local descLabel = tolua.cast(rootNode:getWidgetByName("Label_desc"), "UILabel")
	descLabel:setText(mCopyRow.describe)
	-- 消耗体力
	local phLabel = tolua.cast(rootNode:getWidgetByName("Label_ph"), "UILabel")
	phLabel:setText(tostring(mCopyRow.need_power))
	-- 金币奖励
	local goldLabel = tolua.cast(rootNode:getWidgetByName("Label_award_gold"), "UILabel")
	goldLabel:setText(tostring(mCopyRow.gold))
	-- 经验奖励
	local expLabel = tolua.cast(rootNode:getWidgetByName("Label_award_exp"), "UILabel")
	expLabel:setText(tostring(mCopyRow.exp))
	-- 推荐战斗力
	local battleLabel = tolua.cast(rootNode:getWidgetByName("Label_battle"), "UILabel")
	battleLabel:setText(tostring(mCopyRow.recommended_battle_power))
	-- 奖励列表
	local dropitems = CopyLogic.searchMonsterTable(mCopyRow.first_map_id, mCopyRow.dropitems)
	local data = {}
	for key, val in pairs(dropitems) do
		local rewardItemRow = LogicTable.getRewardItemRow(val.id)
		rewardItemRow.drop_rate = val.drop_rate
		table.insert(data, rewardItemRow)
	end
	local scrollView = tolua.cast(rootNode:getWidgetByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, data, createDropItemCell, "V", 231, 72, 10, 2, 3, true, nil, true, true)
	refreshSkillGroup(rootNode)
end
----------------------------------------------------------------------
-- 销毁
LayerActivityCopyTip.destroy = function()
end
----------------------------------------------------------------------
-- 获取副本id
LayerActivityCopyTip.getCopyId = function()
	return mCopyRow.id
end
----------------------------------------------------------------------
-- 技能组改变
local function handleSkillGroupChange(data)
	local root = UIManager.findLayerByTag("UI_ActivityCopyTip")
	if nil == root or false == data.success then
		return
	end
	refreshSkillGroup(root)
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_GROUP_CHANGE"], handleSkillGroupChange)
----------------------------------------------------------------------


