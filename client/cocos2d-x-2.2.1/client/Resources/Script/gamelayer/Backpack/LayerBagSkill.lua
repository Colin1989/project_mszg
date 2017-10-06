----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-28
-- Brief:	背包技能信息
----------------------------------------------------------------------
LayerBagSkill = {}
local mLayerRoot = nil
----------------------------------------------------------------------
-- 点击更换技能按钮
local function clickChangeSkillBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerSkillEquip, "SkillEquip.json", "SkillEquipUI")
	end
end
-----------------------------------------------
-- 点击职业技能
local function clickJobImg(widget)
	local tb = SkillConfig.getSkillBaseInfo(widget:getTag())
	local position,direct = CommonFuncJudgeInfoPosition(widget)
	tb.position = position
	tb.direct = direct
	UIManager.push("UI_JobInfo",tb)
end
----------------------------------------------------------------------
-- 初始化
function LayerBagSkill.init(root)
	mLayerRoot = root
	
	-- 天赋技能
	local  initData = ModelPlayer.getRoleRow(ModelPlayer.getRoleType())
	local jobInfo1 = SkillConfig.getSkillBaseInfo(tonumber(initData.skill1))
	local jobImg1 =tolua.cast(mLayerRoot:getChildByName("ImageView_TF_1"), "UIImageView")
	jobImg1:loadTexture(jobInfo1.icon)
	jobImg1:setTag(tonumber(initData.skill1))
	UIManager.registerEvent(jobImg1, nil, clickJobImg, CommonFunc_longEnd_job)
	
	local jobInfo2 = SkillConfig.getSkillBaseInfo(tonumber(initData.skill2))
	local jobImg2 =tolua.cast(mLayerRoot:getChildByName("ImageView_TF_2"), "UIImageView")
	jobImg2:loadTexture(jobInfo2.icon)
	jobImg2:setTag(tonumber(initData.skill2))
	UIManager.registerEvent(jobImg2, nil, clickJobImg, CommonFunc_longEnd_job)
	
	-- 雕文技能
	local skillGroup = ModelSkill.getSkillGroup()
	for i=1, 4 do
		local skillImage = tolua.cast(mLayerRoot:getChildByName("ImageView_DW_"..i), "UIImageView")
		local skill = ModelSkill.getSkill(skillGroup.skills[i])
		if nil == skill then
			skillImage:loadTexture("public_runeback.png")
			skillImage:setTouchEnabled(false)
		else
			local function clickSkillIcon(widget)
				local position,direct = CommonFuncJudgeInfoPosition(widget)
				local bundle = {}
				bundle.skill_id = skill.temp_id
				bundle.level = skill.value
				bundle.position = position
				bundle.direct =direct
				UIManager.push("UI_SkillInfo_Long", bundle)
			end
			UIManager.registerEvent(skillImage, nil, clickSkillIcon, CommonFunc_longEnd_skill)
			
			CommonFunc_AddGirdWidget_Rune(skill.temp_id, skill.value, nil, skillImage)
			skillImage:setTouchEnabled(true)
		end
	end
	-- 更换技能按钮
	local changeSkillBtn = tolua.cast(mLayerRoot:getChildByName("Button_change_skill"), "UIButton")
	changeSkillBtn:registerEventScript(clickChangeSkillBtn)
	TipModule.onUI(root, "ui_skillinfo")
end
----------------------------------------------------------------------
-- 销毁
function LayerBagSkill.destroy()
	mLayerRoot = nil
end
----------------------------------------------------------------------
-- 进入
function LayerBagSkill.Action_onEnter()
	local widget = mLayerRoot:getChildByName("background")
	Animation_ScaleTo_FadeIn(widget, 0.4)
end
----------------------------------------------------------------------
-- 退出
function LayerBagSkill.onExit()
end
----------------------------------------------------------------------

