----------------------------------------------------------------------
-- Author:	李慧琴
-- Date:	2014-11-11
-- Brief:	技能信息界面（长按）
----------------------------------------------------------------------
LayerSkillInfoLong = {}
LayerAbstract:extend(LayerSkillInfoLong)
----------------------------------------------------------------------
-- 点击关闭界面
local function closeInfoUI(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillInfo_Long")
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={skill_id:技能id, level:技能等级}
LayerSkillInfoLong.init = function(bundle)
	--Log("LayerSkillInfoLong.init***********",bundle)
    local root = UIManager.findLayerByTag("UI_SkillInfo_Long")
	local rootPanel = tolua.cast(root:getWidgetByName("SkillPanel"), "UILayout")
	rootPanel:registerEventScript(closeInfoUI)
	
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	framePanel:registerEventScript(closeInfoUI)
	CommonFunc_Add_Info_EnterAction(bundle,framePanel)
	--
	local skillInfo = SkillConfig.getSkillInfo(bundle.skill_id)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(bundle.skill_id)
	
	-- 技能名称
	local nameLabel = tolua.cast(framePanel:getChildByName("Label_name"), "UILabel")
	nameLabel:setText(skillBaseInfo.name)
	
	-- 技能品质
	local qualityLabel = tolua.cast(framePanel:getChildByName("Label_quality"), "UILabel")
	qualityLabel:setText(GameString.get("Public_Info_star",CommonFunc_getQualityInfo(skillBaseInfo.quality).star))
	-- 技能等级
	local levelLabel = tolua.cast(framePanel:getChildByName("Label_level"), "UILabel")
	levelLabel:setText(tostring(bundle.level))
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
	descLabel:setText(SkillMgr.getDescription(bundle.skill_id, bundle.level))
end
----------------------------------------------------------------------
-- 销毁
LayerSkillInfoLong.destroy = function()
end
----------------------------------------------------------------------

