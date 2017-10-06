----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能信息界面
----------------------------------------------------------------------
LayerSkillInfo = {}
LayerAbstract:extend(LayerSkillInfo)
local mPopCallback = nil
local mCallbackParam = nil
----------------------------------------------------------------------
-- 点击关闭界面
local function closeInfoUI(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillInfo")
		if "function" == type(mPopCallback) then
			mPopCallback(mCallbackParam)
			mPopCallback = nil
		end
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={skill_id:技能id, level:技能等级}
LayerSkillInfo.init = function(bundle)
    local root = UIManager.findLayerByTag("UI_SkillInfo")
	local rootPanel = tolua.cast(root:getWidgetByName("SkillPanel"), "UILayout")
	rootPanel:registerEventScript(closeInfoUI)
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	framePanel:registerEventScript(closeInfoUI)
	--
	mPopCallback = bundle.callback
	mCallbackParam = bundle.param
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
	descLabel:setTextAreaSize(CCSizeMake(376, 250))
	descLabel:setText(SkillMgr.getDescription(bundle.skill_id, bundle.level))
end
----------------------------------------------------------------------
-- 销毁
LayerSkillInfo.destroy = function()
end
----------------------------------------------------------------------

