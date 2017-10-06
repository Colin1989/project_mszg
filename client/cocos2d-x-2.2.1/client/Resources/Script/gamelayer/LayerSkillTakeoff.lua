----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能卸下界面
----------------------------------------------------------------------
LayerSkillTakeoff = {}
LayerAbstract:extend(LayerSkillTakeoff)
local mGroupIndex = nil
local mPosIndex = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillTakeoff")
    end
end
----------------------------------------------------------------------
-- 点击卸下按钮
local function clickTakeoffBtn(typeName, widget)
	if "releaseUp" == typeName then
		SkillLogic.requestSkillTakeoff(mGroupIndex, mPosIndex)
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={group:组索引, pos:位置}
LayerSkillTakeoff.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_SkillTakeoff")
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	--
	mGroupIndex = bundle.group
	mPosIndex = bundle.pos
	local skillGroup = ModelSkill.getSkillGroupByIndex(bundle.group)
	local skillID = skillGroup.skills[bundle.pos]
	local skillInfo = SkillConfig.getSkillInfo(skillID)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(skillID)
	local skillLevel = ModelSkill.getSkillLevel(skillID)
	-- 技能图标
	local iconImage = tolua.cast(framePanel:getChildByName("ImageView_icon"), "UIImageView")
	CommonFunc_AddGirdWidget_Rune(skillID, skillLevel, nil, iconImage)
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
	levelLabel:setText(tostring(skillLevel))
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
	descLabel:setTextAreaSize(CCSizeMake(360, 200))
	descLabel:setText(SkillMgr.getDescription(skillID, skillLevel))
	-- 卸下按钮
	local takeoffBtn = tolua.cast(framePanel:getChildByName("Button_takeoff"), "UIButton")
	takeoffBtn:registerEventScript(clickTakeoffBtn)
	-- 关闭按钮
	local closeBtn = tolua.cast(framePanel:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
end
----------------------------------------------------------------------
-- 销毁
LayerSkillTakeoff.destroy = function()
end
----------------------------------------------------------------------
-- 技能脱下
local function handleSkillTakeoff(data)
	if false == data.success then
		return
	end
	UIManager.pop("UI_SkillTakeoff")
	Toast.show(GameString.get("SKILL_STR_09"))
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_TAKEOFF"], handleSkillTakeoff)
