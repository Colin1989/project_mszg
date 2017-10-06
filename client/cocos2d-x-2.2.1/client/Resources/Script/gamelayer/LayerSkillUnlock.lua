----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能解锁界面
----------------------------------------------------------------------
LayerSkillUnlock = {}
LayerAbstract:extend(LayerSkillUnlock)
local mSkillId = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillUnlock")
    end
end
----------------------------------------------------------------------
-- 点击解锁按钮
local function clickUnlockBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		SkillLogic.requestSkillUnlock(mSkillId)
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={skill_id:技能id, level:技能等级}
LayerSkillUnlock.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_SkillUnlock")
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	--
	mSkillId = bundle.skill_id
	local skillInfo = SkillConfig.getSkillInfo(bundle.skill_id)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(bundle.skill_id)
	-- 技能图标
	local iconImage = tolua.cast(framePanel:getChildByName("ImageView_icon"), "UIImageView")
	CommonFunc_AddGirdWidget_Rune(bundle.skill_id, bundle.level, nil, iconImage)
	-- 技能名称
	local nameLabel = tolua.cast(framePanel:getChildByName("Label_name"), "UILabel")
	nameLabel:setText(skillBaseInfo.name)
	-- 技能品质
    --[[
	for i=1, 5 do
		local star = CommonFunc_getQualityInfo(skillBaseInfo.quality).star
		local starImage = tolua.cast(framePanel:getChildByName("ImageView_star"..i), "UIImageView")
		starImage:setVisible(star >= i)
	end
    ]]--
	-- 技能等级
    --[[
	local levelLabel = tolua.cast(framePanel:getChildByName("Label_level"), "UILabel")
	levelLabel:setText(tostring(bundle.level))
    ]]--
	-- 冷却时间
	local attrs = ModelPlayer.getPlayerAttr()
	local cdRound = SkillConfig.calcColdRound(skillBaseInfo.skill_cd, attrs.speed)
	local cdLabel = tolua.cast(framePanel:getChildByName("Label_cd"), "UILabel")
	cdLabel:setText(cdRound..GameString.get("SKILL_STR_01"))
	-- 技能类型
	local typeLabel = tolua.cast(framePanel:getChildByName("Label_type"), "UILabel")
	typeLabel:setText(SkillConfig.getTypeDescribe(skillInfo.desc_ids))
	-- 技能说明
	local descLabel = tolua.cast(framePanel:getChildByName("Label_desc"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(386, 160))
	descLabel:setText(SkillMgr.getDescription(bundle.skill_id, bundle.level))
	-- 碎片图标
	local skillFragInfo = SkillConfig.getSkillFragInfo(skillInfo.unlock_need_id)
	local fragIconImage = tolua.cast(framePanel:getChildByName("ImageView_frag_icon"), "UIImageView")
	fragIconImage:loadTexture(skillFragInfo.icon)
	fragIconImage:setTouchEnabled(true)
	
	--暂时不要
--[[
	--技能碎片，长按信息
	local function clickFragIcon(fragIconImage)
		local position,direct = CommonFuncJudgeInfoPosition(fragIconImage)
		local bundle = {}
		bundle.position = position
		bundle.direct = direct
		bundle.is_item = false
		bundle.itemId = skillInfo.unlock_need_id
		bundle.skill_id = skillInfo.unlock_need_id
		UIManager.push("UI_SkillFragInfo_Long", bundle)
	end
	UIManager.registerEvent(fragIconImage, nil, clickFragIcon, CommonFunc_longEnd_frag)	
	]]--	
	
	
	-- 碎片数量
	local currFragCount = ModelSkill.getFragCount(skillInfo.unlock_need_id)
	local fragBarImage = tolua.cast(framePanel:getChildByName("ImageView_frag_bar"), "UIImageView")
	local fragProgressLabel = tolua.cast(framePanel:getChildByName("Label_frag_progress"), "UILabel")
	local fragBarScaleX = currFragCount/skillInfo.unlock_need_amount
	if fragBarScaleX > 1 then
		fragBarScaleX = 1
	end
	fragBarImage:setScaleX(fragBarScaleX)
	fragProgressLabel:setText(currFragCount.."/"..skillInfo.unlock_need_amount)
	-- 解锁按钮
	local unlockImage = tolua.cast(framePanel:getChildByName("ImageView_unlock"), "UIImageView")
	local unlockBtn = tolua.cast(framePanel:getChildByName("Button_unlock"), "UIButton")
	unlockBtn:registerEventScript(clickUnlockBtn)
	if currFragCount >= skillInfo.unlock_need_amount then		-- 可解锁
		unlockBtn:setTouchEnabled(true)
		unlockBtn:loadTextureNormal("public_newbuttom_6.png")
		unlockBtn:loadTexturePressed("public_newbuttom_6.png")
		unlockImage:loadTexture("text_jiesuo.png")
	else	-- 材料不足
		unlockBtn:setTouchEnabled(false)
		unlockBtn:loadTextureNormal("public_gray_buttom.png")
		unlockBtn:loadTexturePressed("public_gray_buttom.png")
		unlockImage:loadTexture("text_jiesuo.png")
	end
	-- 关闭按钮
	local closeBtn = tolua.cast(framePanel:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	TipModule.onUI(root, "ui_skillunlock")
end
----------------------------------------------------------------------
-- 销毁
LayerSkillUnlock.destroy = function()
end
----------------------------------------------------------------------
-- 技能解锁
local function handleSkillUnlock(data)
	if false == data.success then
		return
	end
	UIManager.pop("UI_SkillUnlock")
	setConententPannelJosn(LayerSkillDevelop, "SkillDevelop.json", "SkillDevelopUI")
	Toast.show(GameString.get("SKILL_STR_07"))
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_UNLOCK"], handleSkillUnlock)
