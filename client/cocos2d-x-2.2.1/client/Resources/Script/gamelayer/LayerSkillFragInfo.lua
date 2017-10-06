----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-21
-- Brief:	技能碎片信息界面
----------------------------------------------------------------------
LayerSkillFragInfo = {}
LayerAbstract:extend(LayerSkillFragInfo)
local mPopCallback = nil
local mCallbackParam = nil
----------------------------------------------------------------------
-- 点击关闭界面
local function closeInfoUI(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillFragInfo")
		if "function" == type(mPopCallback) then
			mPopCallback(mCallbackParam)
			mPopCallback = nil
		end
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={frag_id:技能碎片id, callback:界面关闭回调函数, param:回调函数的参数}
LayerSkillFragInfo.init = function(bundle)
    local root = UIManager.findLayerByTag("UI_SkillFragInfo")
	local rootPanel = tolua.cast(root:getWidgetByName("SkillFragPanel"), "UILayout")
	rootPanel:registerEventScript(closeInfoUI)
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	framePanel:registerEventScript(closeInfoUI)
	--
	mPopCallback = bundle.callback
	mCallbackParam = bundle.param
	local skillFragInfo = SkillConfig.getSkillFragInfo(bundle.frag_id)
	local skillInfo = SkillConfig.getSkillInfo(skillFragInfo.skill_id)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(skillFragInfo.skill_id)
	local skillLevel = ModelSkill.getSkillLevel(skillFragInfo.skill_id)
	-- 碎片图标
	local fragIconImage = tolua.cast(framePanel:getChildByName("ImageView_frag_icon"), "UIImageView")
	fragIconImage:loadTexture(skillFragInfo.icon)
	-- 碎片名称
	local fragNameLabel = tolua.cast(framePanel:getChildByName("Label_frag_name"), "UILabel")
	fragNameLabel:setText(skillFragInfo.name)
	-- 碎片说明
	local fragDescribeLabel = tolua.cast(framePanel:getChildByName("Label_frag_describe"), "UILabel")
	fragDescribeLabel:setTextAreaSize(CCSizeMake(371, 70))
	fragDescribeLabel:setText(skillFragInfo.desc)
	-- 技能图标
	local skillIconImage = tolua.cast(framePanel:getChildByName("ImageView_skill_icon"), "UIImageView")
	CommonFunc_AddGirdWidget_Rune(skillFragInfo.skill_id, skillLevel, nil, skillIconImage)
	-- 技能名称
	local skillNameLabel = tolua.cast(framePanel:getChildByName("Label_skill_name"), "UILabel")
	skillNameLabel:setText(skillBaseInfo.name)
	-- 技能品质
	for i=1, 5 do
		local star = CommonFunc_getQualityInfo(skillBaseInfo.quality).star
		local skillStarImage = tolua.cast(framePanel:getChildByName("ImageView_skill_star"..i), "UIImageView")
		skillStarImage:setVisible(star >= i)
	end
	-- 技能说明
	local skillDescribeLabel = tolua.cast(framePanel:getChildByName("Label_skill_describe"), "UILabel")
	skillDescribeLabel:setTextAreaSize(CCSizeMake(371, 70))
	skillDescribeLabel:setText(SkillMgr.getDescription(skillFragInfo.skill_id, skillLevel))
end
----------------------------------------------------------------------
-- 销毁
LayerSkillFragInfo.destroy = function()
end
----------------------------------------------------------------------

