----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能组选择界面
----------------------------------------------------------------------
LayerSkillGroup = {}
LayerAbstract:extend(LayerSkillGroup)
local mEnterCallback = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillGroup")
    end
end
----------------------------------------------------------------------
-- 点击进入游戏按钮
local function clickEnterBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_SkillGroup")
		if "function" == type(mEnterCallback) then
			mEnterCallback()
			mEnterCallback = nil
		end
    end
end
----------------------------------------------------------------------
-- 点击勾选框
local function clickSelectFrame(typeName, widget)
	if "releaseUp" == typeName then
		SkillLogic.requestChangeSkillGroup(widget:getTag())
	end
end
----------------------------------------------------------------------
-- 设置技能组开启状态
local function setSkillGroupOpenStatus(rootView, groupIndex, isOpened, isSelected)
	local groupImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex), "UIImageView")
	groupImage:setTag(groupIndex)
	local titleImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_title"), "UIImageView")
	local selectFrameImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_select_frame"), "UIImageView")
	selectFrameImage:setTag(groupIndex)
	selectFrameImage:registerEventScript(clickSelectFrame)
	local selectImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_select"), "UIImageView")
	local openImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_open"), "UIImageView")
	if nil == openImage then
		openImage = CommonFunc_createUIImageView(nil, nil, nil, "rune_equip_weikaiqi.png", "ImageView_group"..groupIndex.."_open", nil)
		groupImage:addChild(openImage)
	end
	if true == isOpened then	-- 开启
		titleImage:setVisible(true)
		selectFrameImage:setTouchEnabled(not isSelected)
		selectImage:setVisible(isSelected)
		openImage:setVisible(false)
	else						-- 未开启
		titleImage:setVisible(false)
		selectFrameImage:setTouchEnabled(false)
		selectImage:setVisible(false)
		openImage:setVisible(true)
	end
	for i=1, 4 do
		local skillImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_icon"..i), "UIImageView")
		skillImage:setEnabled(isOpened)
		skillImage:removeAllChildren()
		skillImage:loadTexture("public_runeback.png")
	end
end
----------------------------------------------------------------------
-- 设置技能组
local function setSkillGroup(rootView, index, limitSkillGroup, selectIndex)
	if nil == limitSkillGroup or 1 == tonumber(limitSkillGroup.copy_id) or "pass" == CopyDateCache.getCopyStatus(limitSkillGroup.copy_id) then
		setSkillGroupOpenStatus(rootView, index, true, index == selectIndex)
		local skillGroup = ModelSkill.getSkillGroupByIndex(index)
		for i=1, 4 do
			local skillImage = tolua.cast(rootView:getChildByName("ImageView_group"..index.."_icon"..i), "UIImageView")
			local skill = ModelSkill.getSkill(skillGroup.skills[i])
			if nil == skill then
				skillImage:setTouchEnabled(false)
			else
				local function clickSkillImage(typeName, widget)
					if "releaseUp" == typeName then
						local bundle = {}
						bundle.skill_id = skill.temp_id
						bundle.level = skill.value
						UIManager.push("UI_SkillInfo", bundle)
					end
				end
				CommonFunc_AddGirdWidget_Rune(skill.temp_id, skill.value, clickSkillImage, skillImage)
			end
		end
	else
		setSkillGroupOpenStatus(rootView, index, false, false)
		local groupImage = tolua.cast(rootView:getChildByName("ImageView_group"..index), "UIImageView")
		groupImage:setTouchEnabled(true)
		groupImage:registerEventScript(function(typeName, widget)
			if "releaseUp" == typeName then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy", CopyDelockLogic.showNumberFBQById(limitSkillGroup.copy_id), limitSkillGroup.fbName))
			end
		end)
	end
end
----------------------------------------------------------------------
-- 刷新技能组
local function refreshSkillGroup(rootView)
	local currSkillGroup = ModelSkill.getSkillGroup()
	setSkillGroup(rootView, 1, nil, currSkillGroup.index)
	setSkillGroup(rootView, 2, LIMIT_SKILL_GROUP2, currSkillGroup.index)
	setSkillGroup(rootView, 3, LIMIT_SKILL_GROUP3, currSkillGroup.index)
end
----------------------------------------------------------------------
-- 初始化:bundle={callback:界面关闭回调函数}
LayerSkillGroup.init = function(bundle)
	mEnterCallback = bundle.callback
	local root = UIManager.findLayerByTag("UI_SkillGroup")
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	-- 关闭按钮
	local closeBtn = tolua.cast(framePanel:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 确定按钮
	local sureBtn = tolua.cast(framePanel:getChildByName("Button_sure"), "UIButton")
	sureBtn:registerEventScript(clickCloseBtn)
	-- 进入游戏按钮
	local enterBtn = tolua.cast(framePanel:getChildByName("Button_enter"), "UIButton")
	enterBtn:registerEventScript(clickEnterBtn)
	-- 
	if nil == bundle.callback then
		sureBtn:setEnabled(true)
		enterBtn:setEnabled(false)
	else
		sureBtn:setEnabled(false)
		enterBtn:setEnabled(true)
	end
	refreshSkillGroup(framePanel)
end
----------------------------------------------------------------------
-- 销毁
LayerSkillGroup.destroy = function()
end
----------------------------------------------------------------------
-- 技能组改变
local function handleSkillGroupChange(data)
	local root = UIManager.findLayerByTag("UI_SkillGroup")
	if nil == root or false == data.success then
		return
	end
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	refreshSkillGroup(framePanel)
	Toast.show(GameString.get("SKILL_STR_10"))
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_GROUP_CHANGE"], handleSkillGroupChange)

