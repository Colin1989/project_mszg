----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能养成界面
----------------------------------------------------------------------
LayerSkillDevelop = {}
local mRootNode = nil			-- 根节点
local mCurrData = nil			-- 当前页面技能数据
local isAll = false			-- 是否由全部标签下传来的
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		if isAll == true then
			LayerSkillMain.setTag(4)
		else
			LayerSkillMain.setTag(mCurrData.attribute_tag)
		end
		setConententPannelJosn(LayerSkillMain, "SkillMain.json", "SkillMainUI")
	end
end
----------------------------------------------------------------------
-- 点击装备按钮
local function clickEquipBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		LayerSkillEquip.setTag(mCurrData.attribute_tag)
		setConententPannelJosn(LayerSkillEquip, "SkillEquip.json", "SkillEquipUI")
	end
end
----------------------------------------------------------------------
-- 点击升级按钮
local function clickUpgradeBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		-- 满级
		if mCurrData.level == mCurrData.max_lev then
			Toast.show(GameString.get("SKILL_STR_04"))
			return
		end
		-- 下一级超过角色等级
		if mCurrData.level >= ModelPlayer.getLevel() then
			Toast.show(GameString.get("SKILL_STR_14"))
			return
		end
		-- 金币不足
		local skillUpgradeInfo = SkillConfig.getSkillUpgradeInfo(mCurrData.upgrate_cost_id, mCurrData.level)
		if CommonFunc_payConsume(1, skillUpgradeInfo.cost) then
			return
		end
		SkillLogic.requestSkillUpgrade(mCurrData.id)
	end
end
----------------------------------------------------------------------
-- 点击晋阶按钮
local function clickAdvanceBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		-- local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(mCurrData.advance_cost_id)
		-- if skillAdvanceInfo then
			-- mCurrData = SkillConfig.getSkillInfo(skillAdvanceInfo.advanced_id)
			-- mCurrData.level = ModelSkill.getSkillLevel(skillAdvanceInfo.advanced_id)
		-- end
		-- advanceAction(mRootNode, mCurrData)
		-- if true then return end
		-- 未解锁
		if "pass" ~= CopyDateCache.getCopyStatus(LIMIT_SKILL_ADVANCE.copy_id) and tonumber(LIMIT_SKILL_ADVANCE.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy", CopyDelockLogic.showNumberFBQById(LIMIT_SKILL_ADVANCE.copy_id), LIMIT_SKILL_ADVANCE.fbName))
			return
		end
		-- 满阶
		if 0 == mCurrData.advance_cost_id then
			Toast.show(GameString.get("SKILL_STR_05"))
			return
		end
		-- 碎片不足
		local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(mCurrData.advance_cost_id)
		if skillAdvanceInfo.need_amount > ModelSkill.getFragCount(skillAdvanceInfo.need_ids) then
			Toast.show(GameString.get("SKILL_STR_06"))
			return
		end
		SkillLogic.requestSkillAdvance(mCurrData.id)
	end
end
----------------------------------------------------------------------
--[[
-- 点击碎片图标
local function clickFragIcon(typeName, widget)
	if "releaseUp" == typeName then
		local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(mCurrData.advance_cost_id)
		local bundle = {}
		bundle.frag_id = skillAdvanceInfo.need_ids
		UIManager.push("UI_SkillFragInfo", bundle)
	end
end
]]--
----------------------------------------------------------------------
-- 满阶动画
local function fullAdvanceAction(rootView, isFullAdvance, actionCB)
	local advanceInfoPanel = tolua.cast(rootView:getChildByName("Panel_1655"), "UILayout")
	advanceInfoPanel:setEnabled(not isFullAdvance)
	local fullAdvanceInfoPanel = tolua.cast(rootView:getChildByName("Panel_1650"), "UILayout")
	fullAdvanceInfoPanel:setEnabled(false)
	if false == isFullAdvance then
		return
	end
	fullAdvanceInfoPanel:setVisible(true)
	local fullSkillImage = tolua.cast(rootView:getChildByName("ImageView_1652"), "UIImageView")
	CommonFunc_AddGirdWidget_Rune(mCurrData.id, mCurrData.level, nil, fullSkillImage)
	if nil == actionCB then
		fullAdvanceInfoPanel:setEnabled(true)
		return
	end
	local bottomBg = tolua.cast(rootView:getChildByName("ImageView_1065"), "UIImageView")
	local blinkImage = tolua.cast(rootView:getChildByName("ImageView_full_advance_blink"), "UIImageView")
	if nil == blinkImage then
		blinkImage = UIImageView:create()
		blinkImage:loadTexture("forge_recast_blickIcon.png")
		blinkImage:setScale9Enabled(true)
		blinkImage:setCapInsets(CCRectMake(0, 0, 0, 0))
		blinkImage:setSize(CCSizeMake(604, 276))
		blinkImage:setZOrder(3)
		blinkImage:setName("ImageView_full_advance_blink")
		blinkImage:setOpacity(0)
		bottomBg:addChild(blinkImage)
	end
	local actionArr = CCArray:create()
	actionArr:addObject(CCFadeIn:create(0.5))
	actionArr:addObject(CCDelayTime:create(0.1))
	actionArr:addObject(CCCallFunc:create(function()
		blinkImage:setOpacity(0)
		fullAdvanceInfoPanel:setEnabled(true)
		if actionCB then
			actionCB()
		end
	end))
	blinkImage:runAction(CCSequence:create(actionArr))
end
----------------------------------------------------------------------
-- 刷新界面
local function refreshUI(rootView, data)
	if nil == rootView then
		return
	end
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(data.id)
	-- 技能图标
	local skillIconImage = tolua.cast(rootView:getChildByName("ImageView_icon"), "UIImageView")
	CommonFunc_AddGirdWidget_Rune(data.id, data.level, nil, skillIconImage)
	-- 技能名称
	local skillNameLabel = tolua.cast(rootView:getChildByName("Label_name"), "UILabel")
	skillNameLabel:setText(skillBaseInfo.name)
	-- 品质
    --[[
	for i=1, 5 do
		local star = CommonFunc_getQualityInfo(skillBaseInfo.quality).star
		local starImage = tolua.cast(rootView:getChildByName("ImageView_star"..i), "UILabel")
		starImage:setVisible(star >= i)
	end
    ]]--
	-- 冷却回合
	local attrs = ModelPlayer.getPlayerAttr()
	local cdRound = SkillConfig.calcColdRound(skillBaseInfo.skill_cd, attrs.speed)
	local cdLabel = tolua.cast(rootView:getChildByName("Label_cd"), "UILabel")
	cdLabel:setText(cdRound..GameString.get("SKILL_STR_01"))

	-- 类型
	local typeLabel = tolua.cast(rootView:getChildByName("Label_type"), "UILabel")
	typeLabel:setText(SkillConfig.getTypeDescribe(data.desc_ids))
	-- 描述
	local describeLabel = tolua.cast(rootView:getChildByName("Label_describe"), "UILabel")
	describeLabel:setTextAreaSize(CCSizeMake(368, 125))
	describeLabel:setText(SkillMgr.getDescription(data.id, data.level))
	-- 升级花费
	local skillUpgradeInfo = SkillConfig.getSkillUpgradeInfo(data.upgrate_cost_id, data.level)
	local upgradeCostLabel = tolua.cast(rootView:getChildByName("Label_upgrade_cost"), "UILabel")
	local upgradeImage = tolua.cast(rootView:getChildByName("ImageView_upgrade"), "UIImageView")
	if nil == skillUpgradeInfo then
		upgradeCostLabel:setText("")
		upgradeImage:loadTexture("text_manji.png")
	else
		upgradeCostLabel:setText(tostring(skillUpgradeInfo.cost))
		upgradeImage:loadTexture("text_shengji.png")
	end
	-- 晋阶
	local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(data.advance_cost_id)
	local fragIconImage = tolua.cast(rootView:getChildByName("ImageView_frag_icon"), "UIImageView")
	local tipLabel = tolua.cast(rootView:getChildByName("Label_tip"), "UILabel")
	local fragProgressLabel = tolua.cast(rootView:getChildByName("Label_frag_progress"), "UILabel")
	local fragBarImage = tolua.cast(rootView:getChildByName("ImageView_frag_bar"), "UIImageView")
	local currIconImage = tolua.cast(rootView:getChildByName("ImageView_icon_curr"), "UIImageView")
	local nextIconImage = tolua.cast(rootView:getChildByName("ImageView_icon_next"), "UIImageView")
	local advanceImage = tolua.cast(rootView:getChildByName("ImageView_advance"), "UIImageView")
	local advanceBtn = tolua.cast(rootView:getChildByName("Button_advance"), "UIButton")
	local advanceTip = tolua.cast(rootView:getChildByName("ImageView_tip"), "UIImageView")
	if nil == skillAdvanceInfo or 0 == skillAdvanceInfo.advanced_id then	-- 满阶
		tipLabel:setText("")
		fragIconImage:setTouchEnabled(false)
		advanceImage:loadTexture("text_manjie.png")
		advanceBtn:setTouchEnabled(false)
		fullAdvanceAction(rootView, true, nil)
	else	-- 未满阶
		local currFragCount = ModelSkill.getFragCount(skillAdvanceInfo.need_ids)
		local skillFragInfo = SkillConfig.getSkillFragInfo(skillAdvanceInfo.need_ids)
		fragIconImage:loadTexture(skillFragInfo.icon)
		--fragIconImage:registerEventScript(clickFragIcon)
		fragIconImage:setTouchEnabled(true)
		
		--技能碎片，长按信息
		local function clickFragIcon(fragIconImage)
			local position,direct = CommonFuncJudgeInfoPosition(fragIconImage)
			local bundle = {}
			bundle.position = position
			bundle.direct = direct
			bundle.is_item = false
			bundle.itemId = skillAdvanceInfo.need_ids
			bundle.skill_id = skillAdvanceInfo.need_ids
			UIManager.push("UI_SkillFragInfo_Long", bundle)
		end
		UIManager.registerEvent(fragIconImage, nil, clickFragIcon, CommonFunc_longEnd_frag)
		fragIconImage:setTouchEnabled(true)
	
		tipLabel:setText(GameString.get("SKILL_STR_03", skillAdvanceInfo.need_amount, skillFragInfo.name))
		fragProgressLabel:setText(currFragCount.."/"..skillAdvanceInfo.need_amount)
		local fragBarScaleX = currFragCount/skillAdvanceInfo.need_amount
		advanceTip:setVisible(false)
		if fragBarScaleX >= 1 then
			fragBarScaleX = 1
			advanceTip:setVisible(true)
		end
		fragBarImage:setScaleX(fragBarScaleX)
		CommonFunc_AddGirdWidget_Rune(data.id, data.level, nil, currIconImage)
		CommonFunc_AddGirdWidget_Rune(skillAdvanceInfo.advanced_id, data.level, nil, nextIconImage)
		currIconImage:setTouchEnabled(true)
		nextIconImage:setTouchEnabled(true)
		
		
		--进阶前，技能长按信息
		local function clickCurSkillIcon(currIconImage)
			local position,direct = CommonFuncJudgeInfoPosition(currIconImage)
			local bundle = {}
			bundle.position = position
			bundle.direct = direct
			bundle.skill_id = data.id
			bundle.level = data.level

			UIManager.push("UI_SkillInfo_Long", bundle)
		end
		UIManager.registerEvent(currIconImage, nil, clickCurSkillIcon, CommonFunc_longEnd_skill)
		
		
		
		--进阶后，技能长按信息
		local function clickNextSkillIcon(nextIconImage)
			local position,direct = CommonFuncJudgeInfoPosition(nextIconImage)
			local bundle = {}
			bundle.position = position
			bundle.direct = direct
			bundle.skill_id = skillAdvanceInfo.advanced_id
			bundle.level = data.level
			UIManager.push("UI_SkillInfo_Long", bundle)
		end
		UIManager.registerEvent(nextIconImage, nil, clickNextSkillIcon, CommonFunc_longEnd_skill)
		
		
		advanceImage:loadTexture("text_jinjie.png")
		advanceBtn:setTouchEnabled(true)
		fullAdvanceAction(rootView, false, nil)
	end
end
----------------------------------------------------------------------
-- 设置返回标签为全部标签
LayerSkillDevelop.setIsAll = function()
	isAll = true
end

----------------------------------------------------------------------
-- 初始化
LayerSkillDevelop.init = function(rootView)
	mRootNode = rootView
	mCurrData = LayerSkillMain.getClickData()
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 装备按钮
	local equipBtn = tolua.cast(rootView:getChildByName("Button_1081"), "UIButton")
	equipBtn:registerEventScript(clickEquipBtn)
	-- 升级按钮
	local upgradeBtn = tolua.cast(rootView:getChildByName("Button_upgrade"), "UIButton")
	upgradeBtn:registerEventScript(clickUpgradeBtn)
	-- 晋阶按钮
	local advanceBtn = tolua.cast(rootView:getChildByName("Button_advance"), "UIButton")
	advanceBtn:registerEventScript(clickAdvanceBtn)
	-- 刷新界面
	refreshUI(rootView, mCurrData)
	TipModule.onUI(rootView, "ui_skilldevelop")
end
----------------------------------------------------------------------
-- 销毁
LayerSkillDevelop.destroy = function()
	mRootNode = nil
	mCurrData = nil
	isAll = false
end
----------------------------------------------------------------------
-- 获取当前页面技能信息
LayerSkillDevelop.getData = function()
	return mCurrData
end
----------------------------------------------------------------------
-- 升级动画
function upgradeAction(rootView, newData)
	-- 控件
	local bg = tolua.cast(rootView:getChildByName("background"), "UIImageView")
	local upgradeBg = tolua.cast(rootView:getChildByName("ImageView_1057"), "UIImageView")
	local upgradeBtn = tolua.cast(rootView:getChildByName("Button_upgrade"), "UIButton")
	local advanceBtn = tolua.cast(rootView:getChildByName("Button_advance"), "UIButton")
	advanceBtn:setTouchEnabled(false)
	local skillIconImage = tolua.cast(rootView:getChildByName("ImageView_icon"), "UIImageView")
	local skillIconPos = skillIconImage:getPosition()
	local upgradeBlinkImage = tolua.cast(rootView:getChildByName("ImageView_upgrade_blink"), "UIImageView")
	if nil == upgradeBlinkImage then
		upgradeBlinkImage = CommonFunc_createUIImageView(nil, skillIconPos, CCSizeMake(106, 106), "forge_recast_blickIcon.png", "ImageView_upgrade_blink", 100)
		upgradeBlinkImage:setOpacity(0)
		upgradeBg:addChild(upgradeBlinkImage)
	end
	local upgradeSuccessImage = tolua.cast(rootView:getChildByName("ImageView_upgrade_success"), "UIImageView")
	if nil == upgradeSuccessImage then
		upgradeSuccessImage = CommonFunc_createUIImageView(nil, ccp(0, 180), nil, "rune_up_suc.png", "ImageView_upgrade_success", 101)
		upgradeSuccessImage:setVisible(false)
		bg:addChild(upgradeSuccessImage)
	end
	upgradeSuccessImage:setVisible(false)
	upgradeSuccessImage:stopAllActions()
	-- 动作
	local function actionCB1()
		upgradeBlinkImage:setOpacity(0)
		refreshUI(rootView, newData)
	end
	local function actionCB2()
		advanceBtn:setTouchEnabled(true)
		upgradeSuccessImage:setVisible(false)
	end
	local actionArr1 = CCArray:create()
	actionArr1:addObject(CCFadeIn:create(0.6))
	actionArr1:addObject(CCCallFunc:create(actionCB1))
	upgradeBlinkImage:runAction(CCSequence:create(actionArr1))
	local actionArr2 = CCArray:create()
	actionArr2:addObject(CCEaseElasticIn:create(CCScaleTo:create(0.03, 1.0)))
	actionArr2:addObject(CCDelayTime:create(0.7))
	actionArr2:addObject(CCCallFunc:create(actionCB2))
	upgradeSuccessImage:setVisible(true)
	upgradeSuccessImage:setScale(1.3)
	upgradeSuccessImage:runAction(CCSequence:create(actionArr2))
end
----------------------------------------------------------------------
-- 晋阶动画
function advanceAction(rootView, newData)
	-- 控件
	local bg = tolua.cast(rootView:getChildByName("background"), "UIImageView")
	local upgradeBtn = tolua.cast(rootView:getChildByName("Button_upgrade"), "UIButton")
	upgradeBtn:setTouchEnabled(false)
	local advanceBtn = tolua.cast(rootView:getChildByName("Button_advance"), "UIButton")
	advanceBtn:setTouchEnabled(false)
	local fragIconImage = tolua.cast(rootView:getChildByName("ImageView_frag_icon"), "UIImageView")
	fragIconImage:setTouchEnabled(false)
	local tipLabel = tolua.cast(rootView:getChildByName("Label_tip"), "UILabel")
	tipLabel:setText("")
	local fragProgressLabel = tolua.cast(rootView:getChildByName("Label_frag_progress"), "UILabel")
	fragProgressLabel:setText("")
	local fragBarImage = tolua.cast(rootView:getChildByName("ImageView_frag_bar"), "UIImageView")
	local currIconPos = ccp(-119, -130)
	local nextIconPos = ccp(157, -130)
	local advanceBlinkImage = tolua.cast(rootView:getChildByName("ImageView_advance_blink"), "UIImageView")
	if nil == advanceBlinkImage then
		advanceBlinkImage = CommonFunc_createUIImageView(nil, ccp(0, 0), CCSizeMake(106, 106), "forge_recast_blickIcon.png", "ImageView_advance_blink", 100)
		advanceBlinkImage:setOpacity(0)
		bg:addChild(advanceBlinkImage)
	end
	local advanceSuccessImage = tolua.cast(rootView:getChildByName("ImageView_advance_success"), "UIImageView")
	if nil == advanceSuccessImage then
		advanceSuccessImage = CommonFunc_createUIImageView(nil, ccp(0, -180), nil, "upgrade_suc.png", "ImageView_advance_success", 101)
		advanceSuccessImage:setVisible(false)
		bg:addChild(advanceSuccessImage)
	end
	--
	local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(newData.advance_cost_id)
	if nil == skillAdvanceInfo or 0 == skillAdvanceInfo.advanced_id then	-- 满阶
		upgradeBtn:setTouchEnabled(true)
		advanceBtn:setTouchEnabled(false)
		fragIconImage:setTouchEnabled(false)
		fullAdvanceAction(rootView, true, function()
			refreshUI(rootView, newData)
		end)
		return
	end
	local skillFragInfo = SkillConfig.getSkillFragInfo(skillAdvanceInfo.need_ids)
	local currFragCount = ModelSkill.getFragCount(skillAdvanceInfo.need_ids)
	-- 动作
	local function actionCB4()
		upgradeBtn:setTouchEnabled(true)
		advanceBtn:setTouchEnabled(true)
		fragIconImage:setTouchEnabled(true)
		advanceBlinkImage:setOpacity(0)
		advanceSuccessImage:setVisible(false)
		refreshUI(rootView, newData)
	end
	local function actionCB3()
		local actionArr = CCArray:create()
		actionArr:addObject(CCEaseElasticIn:create(CCScaleTo:create(0.03, 1.0)))
		actionArr:addObject(CCDelayTime:create(0.5))
		actionArr:addObject(CCCallFunc:create(actionCB4))
		advanceSuccessImage:setVisible(true)
		advanceSuccessImage:setScale(1.3)
		advanceSuccessImage:runAction(CCSequence:create(actionArr))
	end
	local function actionCB2()
		local actionArr = CCArray:create()
		actionArr:addObject(CCFadeIn:create(0.5))
		actionArr:addObject(CCMoveTo:create(0.5, ccp(nextIconPos.x, nextIconPos.y)))
		actionArr:addObject(CCCallFunc:create(actionCB3))
		advanceBlinkImage:setPosition(currIconPos)
		advanceBlinkImage:runAction(CCSequence:create(actionArr))
	end
	local function actionCB1()
		local fragBarScaleX = currFragCount/skillAdvanceInfo.need_amount
		if fragBarScaleX > 1 then
			fragBarScaleX = 1
		end
		fragIconImage:loadTexture(skillFragInfo.icon)
		tipLabel:setText(GameString.get("SKILL_STR_03", skillAdvanceInfo.need_amount, skillFragInfo.name))
		fragProgressLabel:setText(currFragCount.."/"..skillAdvanceInfo.need_amount)
		fragBarImage:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.3, fragBarScaleX, 1.0), CCCallFunc:create(actionCB2)))
	end
	fragBarImage:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.0, 1.0), CCCallFunc:create(actionCB1)))
end
----------------------------------------------------------------------
-- 技能升级
local function handleSkillUpgrade(success)
	if nil == mRootNode or false == success then
		return
	end
	mCurrData.level = ModelSkill.getSkillLevel(mCurrData.id)
	upgradeAction(mRootNode, mCurrData)
end
----------------------------------------------------------------------
-- 技能晋阶
local function handleSkillAdvance(data)
	if nil == mRootNode or false == data.success then
		return
	end
	mCurrData = SkillConfig.getSkillInfo(data.new_temp_id)
	mCurrData.level = ModelSkill.getSkillLevel(data.new_temp_id)
	advanceAction(mRootNode, mCurrData)
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_UPGRADE"], handleSkillUpgrade)
EventCenter_subscribe(EventDef["ED_SKILL_ADVANCE"], handleSkillAdvance)

