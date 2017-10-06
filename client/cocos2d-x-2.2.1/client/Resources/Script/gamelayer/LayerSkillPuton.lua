----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能穿上界面
----------------------------------------------------------------------
LayerSkillPuton = {}
LayerAbstract:extend(LayerSkillPuton)
local mGroupIndex = nil
local mSkillId = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillPuton")
    end
end
----------------------------------------------------------------------
-- 点击位置按钮
local function clickPosBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local posIndex = widget:getTag()
		SkillLogic.requestSkillPuton(mGroupIndex, posIndex, mSkillId)
    end
end
----------------------------------------------------------------------
-- 初始化,bundle={skill_id:技能id, level:技能等级}
LayerSkillPuton.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_SkillPuton")
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	--
	mSkillId = bundle.skill_id
	local skillInfo = SkillConfig.getSkillInfo(bundle.skill_id)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(bundle.skill_id)
	local currSkillGroup = ModelSkill.getSkillGroup()
	mGroupIndex = currSkillGroup.index
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
	descLabel:setTextAreaSize(CCSizeMake(374, 160))
	descLabel:setText(SkillMgr.getDescription(bundle.skill_id, bundle.level))
	-- 穿上按钮
	Log(currSkillGroup)
	for i=1, 4 do
		local posBtn = tolua.cast(framePanel:getChildByName("Button_pos"..i), "UIButton")
		posBtn:setTag(i)
		posBtn:registerEventScript(clickPosBtn)
		local posImage = tolua.cast(framePanel:getChildByName("ImageView_pos"..i), "UIImageView")
		if 0 == currSkillGroup.skills[i] then
			posBtn:loadTextureNormal("fight_lose_buttom.png")
			posBtn:loadTexturePressed("fight_lose_buttom.png")
			posImage:loadTexture("text_zhuangbeijineng.png")
		else
			posBtn:loadTextureNormal("rune_zhuangbei_button.png")
			posBtn:loadTexturePressed("rune_zhuangbei_button.png")
			-- posImage:loadTexture("text_tihuanjineng.png")
			posImage:loadTexture("text_zhuangbeijineng.png")
		end
	end
	-- 关闭按钮
	local closeBtn = tolua.cast(framePanel:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	TipModule.onUI(root, "ui_skillputon")
end
----------------------------------------------------------------------
-- 销毁
LayerSkillPuton.destroy = function()
end
----------------------------------------------------------------------
-- 技能穿上
local function handleSkillPuton(data)
	if false == data.success then
		return
	end
	UIManager.pop("UI_SkillPuton")
	Toast.show(GameString.get("SKILL_STR_08"))
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_PUTON"], handleSkillPuton)
