----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-21
-- Brief:	技能碎片信息界面
----------------------------------------------------------------------
LayerSkillFragInfoLong = {}
LayerAbstract:extend(LayerSkillFragInfoLong)
local mPopCallback = nil
local mCallbackParam = nil
----------------------------------------------------------------------
-- 点击关闭界面
local function closeInfoUI(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillFragInfo_Long")
		if "function" == type(mPopCallback) then
			mPopCallback(mCallbackParam)
			mPopCallback = nil
		end
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={frag_id:技能碎片id, callback:界面关闭回调函数, param:回调函数的参数}
LayerSkillFragInfoLong.init = function(bundle)
    local root = UIManager.findLayerByTag("UI_SkillFragInfo_Long")
	local rootPanel = tolua.cast(root:getWidgetByName("Panel_root"), "UILayout")
	rootPanel:registerEventScript(closeInfoUI)
	
	local framePanel = tolua.cast(root:getWidgetByName("img_root"), "UILayout")
	framePanel:registerEventScript(closeInfoUI)
	CommonFunc_Add_Info_EnterAction(bundle,framePanel)
	
	--Log("*****LayerSkillFragInfoLong.init*********",bundle)
	--
	local skillFragInfo = SkillConfig.getSkillFragInfo(bundle.itemId)
	--local skillInfo = SkillConfig.getSkillInfo(skillFragInfo.skill_id)  --天赋碎片有问题
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(skillFragInfo.skill_id)
	local skillLevel = ModelSkill.getSkillLevel(skillFragInfo.skill_id)
	
	if tonumber(skillFragInfo.skill_id) == 0 then
		Toast.show("对应的技能Id为0，需要特殊处理到物品")
	end
	-- 碎片名称
	local fragNameLabel = tolua.cast(framePanel:getChildByName("skillfrag_name"), "UILabel")
	fragNameLabel:setText(skillFragInfo.name)
	-- 碎片说明
	local fragDescribeLabel = tolua.cast(framePanel:getChildByName("Label_frag_describe"), "UILabel")
	fragDescribeLabel:setText(skillFragInfo.desc)
	-- 技能说明
	local skillDescribeLabel = tolua.cast(framePanel:getChildByName("Label_skill_describe"), "UILabel")
	skillDescribeLabel:setText(SkillMgr.getDescription(skillFragInfo.skill_id, skillLevel))
end
----------------------------------------------------------------------
-- 销毁
LayerSkillFragInfoLong.destroy = function()
end
----------------------------------------------------------------------

