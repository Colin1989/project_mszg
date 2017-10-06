----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-28
-- Brief:	技能装备界面
----------------------------------------------------------------------
LayerSkillEquip = {}
local mRootNode = nil			-- 根节点
local mSkillInfoArray = nil
local mCurrTag = 4
local mGroupImageTable = {}
local mGroupParamTable = {}
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		LayerBackpack.returnSkillUI()
	end
end
----------------------------------------------------------------------
-- 点击技能按钮
local function clickSkillBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerSkillMain, "SkillMain.json", "SkillMainUI")
	end
end
----------------------------------------------------------------------
-- 点击单元格
local function clickCell(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local tag = widget:getTag()
		local index = math.floor(tag/1000)
		local status = tag%1000
		local data = mSkillInfoArray[index]
		local bundle = {}
		bundle.skill_id = data.id
		bundle.level = data.level
		if 4 == status or 5 == status then		-- 未解锁
			UIManager.push("UI_SkillInfo", bundle)
		else
			local groupIndex, pos = ModelSkill.getSkillPosition(data.id)
			if 0 == groupIndex or 0 == pos then		-- 未装备
				UIManager.push("UI_SkillPuton", bundle)
			else									-- 已装备
				local bundle1 = {}
				bundle1.group = groupIndex
				bundle1.pos = pos
				UIManager.push("UI_SkillTakeoff", bundle1)
			end
		end
	end
end
----------------------------------------------------------------------
-- 切换标签状态
local function changeTagStatus(rootView, tag, tagTb)
	if nil == rootView then
		return
	end
	local tagBtnName = {"Button_hurt", "Button_assist", "Button_treat", "Button_all"}
	local tagImageName = {"ImageView_hurt", "ImageView_assist", "ImageView_treat", "ImageView_all"}
	local tagBtnNormal = {"herobag_buttom_d.png", "herobag_buttom_d.png", "herobag_buttom_d.png", "herobag_buttom_d.png"}
	local tagBtnActive = {"herobag_buttom_h.png", "herobag_buttom_h.png", "herobag_buttom_h.png", "herobag_buttom_h.png"}
	local tagImageNormal = {"text_shanghai_n.png", "text_fuzhu_n.png", "text_zhiliao_n.png", "herobag_text_all_d.png"}
	local tagImageActive = {"text_shanghai_h.png", "text_fuzhu_h.png", "text_zhiliao_h.png", "herobag_text_all_h.png"}
	for i=1, #tagBtnName do
		local tagBtn = tolua.cast(rootView:getChildByName(tagBtnName[i]), "UIButton")
		local tagImage = tolua.cast(rootView:getChildByName(tagImageName[i]), "UIImageView")
		local tipImg = tolua.cast(rootView:getChildByName("tip_qipao"..i), "UIImageView")
		if nil == tipImg then
			tipImg = CommonFunc_getImgView("qipaogantanhao.png")
			tipImg:setName("tip_qipao"..i)
			tagBtn:addChild(tipImg)
		end
		if i ~= #tagBtnName then
			tipImg:setVisible(tagTb[i] or false)
		else
			tipImg:setVisible(#tagTb ~= 0)
		end
		local tagBtnPos = tagBtn:getPosition()
		if tag == i then
			tagBtn:setTag(1)
			tagBtn:loadTextureNormal(tagBtnActive[i])
			tagBtn:loadTexturePressed(tagBtnActive[i])
			tagImage:loadTexture(tagImageActive[i])
			tagBtn:setPosition(ccp(tagBtnPos.x, 126))
			-- tipImg:setPosition(ccp(tagBtnPos.x + 45, 147))
			tipImg:setPosition(ccp(45, 47))
		else
			tagBtn:setTag(0)
			tagBtn:loadTextureNormal(tagBtnNormal[i])
			tagBtn:loadTexturePressed(tagBtnNormal[i])
			tagImage:loadTexture(tagImageNormal[i])
			tagBtn:setPosition(ccp(tagBtnPos.x, 124))
			-- tipImg:setPosition(ccp(tagBtnPos.x + 40, 141))
			tipImg:setPosition(ccp(40, 41))
		end
	end
end
----------------------------------------------------------------------
-- 创建单元格
local function createCell(cell, data, index)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(data.id)
	local status = SkillLogic.getSkillStatus(data)
	local cell = UIImageView:create()
	cell:loadTexture("touming.png")
	-- 图标
	local iconImage = CommonFunc_AddGirdWidget_Rune(data.id, data.level, clickCell, nil)
	iconImage:setTag(index*1000 + status)
	iconImage:setName("skill_icon"..index)
	cell:addChild(iconImage)
	-- 未解锁覆盖层
	local function createTipBg()
		local img = UIImageView:create()
		img:loadTexture("icon_mask.png")
		img:setSize(CCSizeMake(94, 94))
		img:setScale9Enabled(true)
		img:setCapInsets(CCRectMake(0, 0, 0, 0))
		img:setPosition(ccp(0, 0))
		return img
	end
	if 1 == status then
		local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(data.advance_cost_id)
		if skillAdvanceInfo and skillAdvanceInfo.advanced_id > 0 then
			local currFragCount = ModelSkill.getFragCount(skillAdvanceInfo.need_ids)
			if currFragCount >= skillAdvanceInfo.need_amount then
				local tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
				tipIcon:setPosition(ccp(35, 35))
				cell:addChild(tipIcon)
			end
		end
	elseif 4 == status then
		local tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setPosition(ccp(35, 35))
		tipIcon:setZOrder(10)
		cell:addChild(tipIcon)
		cell:addChild(createTipBg())
	elseif 5 == status then			-- 未解锁
		cell:addChild(createTipBg())
	end
	return cell
end
----------------------------------------------------------------------
-- 滚动事件
local function scrollCallback(scrollView)
	if nil == mRootNode then
		return
	end
	if 1 == GuideMgr.guideStatus() then
		scrollView:scrollToTop(0.01, false)
		return
	end
	local height = scrollView:getInnerContainer():getSize().height
	local pos = scrollView:getInnerContainer():getPosition()
	local kuangH = scrollView:getSize().height
	local ratio = math.abs(pos.y)/(height - kuangH) * 100
	local silder = tolua.cast(mRootNode:getChildByName("Slider_scroll"), "UISlider")
	silder:setPercent(100 - ratio)
end
----------------------------------------------------------------------
-- 刷新列表
local function refreshList(rootView, attributeTag)
	if nil == rootView then
		return
	end
	mCurrTag = attributeTag
	changeTagStatus(rootView, attributeTag, SkillLogic.existUnlockAdvanceSkill())
	mSkillInfoArray = SkillLogic.getSkillArray(attributeTag)
	-- 排序算法:可晋阶 -> 可升级 -> 已解锁 -> 可解锁 -> 不可解锁
	local function sortFunc(a, b)
		local aStatus = SkillLogic.getSkillStatus(a)
		local bStatus = SkillLogic.getSkillStatus(b)
		if aStatus == bStatus then
			local aBaseInfo = SkillConfig.getSkillBaseInfo(a.id)
			local bBaseInfo = SkillConfig.getSkillBaseInfo(b.id)
			return aBaseInfo.quality > bBaseInfo.quality
		end
		return aStatus < bStatus
	end
	table.sort(mSkillInfoArray, sortFunc)
	local scrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, mSkillInfoArray, createCell, "V", 94, 94, 3, 5, 3, true, scrollCallback, true, true)
end
----------------------------------------------------------------------
-- 点击全部标签
local function clickAllTag(typeName, widget)
	if "releaseUp" == typeName then
		if 0 == widget:getTag() then
			refreshList(mRootNode, 4)
		end
	end
end
----------------------------------------------------------------------
-- 点击伤害标签
local function clickHurtTag(typeName, widget)
	if "releaseUp" == typeName then
		if 0 == widget:getTag() then
			refreshList(mRootNode, 1)
		end
	end
end
----------------------------------------------------------------------
-- 点击辅助标签
local function clickAssistTag(typeName, widget)
	if "releaseUp" == typeName then
		if 0 == widget:getTag() then
			refreshList(mRootNode, 2)
		end
	end
end
----------------------------------------------------------------------
-- 点击治疗标签
local function clickTreatTag(typeName, widget)
	if "releaseUp" == typeName then
		if 0 == widget:getTag() then
			refreshList(mRootNode, 3)
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
-- 获取技能组控件的位置
local function getGroupImageIndex(groupImage)
	for key, val in pairs(mGroupImageTable) do
		if groupImage:getTag() == val:getTag() then
			return key
		end
	end
end
----------------------------------------------------------------------
-- 技能选择动画
local function changeAction(rootView, selectIndex, doAction)
	-- 当前选择的技能组
	local selectGroupImage = tolua.cast(rootView:getChildByName("ImageView_group"..selectIndex), "UIImageView")
	selectGroupImage:setZOrder(30)
	local selectPosX = selectGroupImage:getPosition().x
	local selectPosY = selectGroupImage:getPosition().y
	local selectScaleX = selectGroupImage:getScaleX()
	local selectScaleY = selectGroupImage:getScaleY()
	local selectGroupImageIndex = getGroupImageIndex(selectGroupImage)
	if 1 == selectGroupImageIndex then
		return
	end
	-- 之前选择的技能组
	local oldGroupImage = mGroupImageTable[1]
	selectGroupImage:setZOrder(20)
	local oldPosX = oldGroupImage:getPosition().x
	local oldPosY = oldGroupImage:getPosition().y
	local oldScaleX = oldGroupImage:getScaleX()
	local oldScaleY = oldGroupImage:getScaleY()
	local oldGroupImageIndex = getGroupImageIndex(oldGroupImage)
	-- 获取另外一个技能组
	local otherGroupImage = nil
	for key, val in pairs(mGroupImageTable) do
		if selectGroupImageIndex ~= key and oldGroupImageIndex ~= key then
			otherGroupImage = val
			break
		end
	end
	otherGroupImage:setZOrder(10)
	-- 位置互调
	mGroupImageTable[selectGroupImageIndex] = oldGroupImage
	mGroupImageTable[oldGroupImageIndex] = selectGroupImage
	if false == doAction then
		selectGroupImage:setPosition(ccp(oldPosX, oldPosY))
		selectGroupImage:setScaleX(oldScaleX)
		selectGroupImage:setScaleY(oldScaleY)
		oldGroupImage:setPosition(ccp(selectPosX, selectPosY))
		oldGroupImage:setScaleX(selectScaleX)
		oldGroupImage:setScaleY(selectScaleY)
		return
	end
	-- 动画播放
	local function setSelectFrameTouchEnabled(enabled)
		local oldGroupIndex = oldGroupImage:getTag()
		local oldSelectFrameImage = tolua.cast(rootView:getChildByName("ImageView_group"..oldGroupIndex.."_select_area"), "UIImageView")
		local otherGroupIndex = otherGroupImage:getTag()
		local otherSelectFrameImage = tolua.cast(rootView:getChildByName("ImageView_group"..otherGroupIndex.."_select_area"), "UIImageView")
		oldSelectFrameImage:setTouchEnabled(enabled)
		otherSelectFrameImage:setTouchEnabled(enabled)
	end
	setSelectFrameTouchEnabled(false)
	local function callback()
		setSelectFrameTouchEnabled(true)
	end
	selectGroupImage:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.5, ccp(oldPosX, oldPosY)), CCCallFunc:create(callback)))
	selectGroupImage:runAction(CCScaleTo:create(0.5, oldScaleX, oldScaleY))
	oldGroupImage:runAction(CCMoveTo:create(0.5, ccp(selectPosX, selectPosY)))
	oldGroupImage:runAction(CCScaleTo:create(0.5, selectScaleX, selectScaleY))
end
----------------------------------------------------------------------
-- 设置技能组开启状态
local function setSkillGroupOpenStatus(rootView, groupIndex, isOpened, isSelected)
	local groupImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex), "UIImageView")
	groupImage:setTag(groupIndex)
	local titleImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_title"), "UIImageView")
	local selectFrameImage = tolua.cast(rootView:getChildByName("ImageView_group"..groupIndex.."_select_area"), "UIImageView")
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
	-- Log(limitSkillGroup)
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
						if index == selectIndex then
							bundle.group = index
							bundle.pos = i
							UIManager.push("UI_SkillTakeoff", bundle)
						else
							bundle.skill_id = skill.temp_id
							bundle.level = skill.value
							UIManager.push("UI_SkillInfo", bundle)
						end
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
-- 新手技能图标特殊处理
local function skillShowForGuide(rootView)
	-- 新手处理
	if 0 == GuideMgr.guideStatus() then
		return
	end
	local lockTb = {}
	if false == GuideMgr.checkProgress(GuideForce_UseAddBloodSkill) then
		if "pass" ~= CopyDateCache.getCopyStatus(GuideForce_UseAddBloodSkill.copy_id) then
			table.insert(lockTb, 2)
			table.insert(lockTb, 3)
			table.insert(lockTb, 4)
		end
	elseif false == GuideMgr.checkProgress(GuideForce_UseGroupAttackSkill) then
		if "pass" ~= CopyDateCache.getCopyStatus(GuideForce_UseGroupAttackSkill.copy_id) then
			table.insert(lockTb, 4)
		end
	end
	for key, val in pairs(lockTb) do
		local skillImage = tolua.cast(rootView:getChildByName("ImageView_group1_icon"..val), "UIImageView")
		Action_createLock94x94(skillImage, true, ccp(0, 0))
	end
end
----------------------------------------------------------------------
-- 初始化
LayerSkillEquip.init = function(rootView)
	mRootNode = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 技能按钮
	local skillBtn = tolua.cast(rootView:getChildByName("Button_skill"), "UIButton")
	skillBtn:registerEventScript(clickSkillBtn)
	-- 全部标签
	local allBtn = tolua.cast(rootView:getChildByName("Button_all"), "UIButton")
	allBtn:registerEventScript(clickAllTag)
	-- 伤害标签
	local hurtTag = tolua.cast(rootView:getChildByName("Button_hurt"), "UIButton")
	hurtTag:registerEventScript(clickHurtTag)
	-- 辅助标签
	local assistTag = tolua.cast(rootView:getChildByName("Button_assist"), "UIButton")
	assistTag:registerEventScript(clickAssistTag)
	-- 治疗标签
	local treatTag = tolua.cast(rootView:getChildByName("Button_treat"), "UIButton")
	treatTag:registerEventScript(clickTreatTag)
	-- 
	for i=1, 3 do
		local groupImage = tolua.cast(rootView:getChildByName("ImageView_group"..i), "UIImageView")
		mGroupImageTable[i] = groupImage
		mGroupParamTable[i] = {pos = groupImage:getPosition(), scaleX = groupImage:getScaleX(), scaleY = groupImage:getScaleY()}
	end
	-- 技能组
	refreshSkillGroup(rootView)
	-- 列表
	refreshList(rootView, mCurrTag)
	--
	local currSkillGroup = ModelSkill.getSkillGroup()
	changeAction(rootView, currSkillGroup.index, false)
	TipModule.onUI(rootView, "ui_skillequip")
	skillShowForGuide(rootView)
end
----------------------------------------------------------------------
-- 销毁
LayerSkillEquip.destroy = function()
	mRootNode = nil
	mCurrTag = 4
end
----------------------------------------------------------------------
-- 设置标签
LayerSkillEquip.setTag = function(attributeTag)
	mCurrTag = attributeTag
end
----------------------------------------------------------------------
-- 根据技能id获取控件名
LayerSkillEquip.getWidgetNameBySkillGroup = function(skillGroup)
	for key, val in pairs(mSkillInfoArray) do
		if skillGroup == val.skill_group then
			return "skill_icon"..key
		end
	end
end
----------------------------------------------------------------------
-- 技能装备
local function handleSkillEquip(data)
	if nil == mRootNode or false == data.success then
		return
	end
	refreshSkillGroup(mRootNode)
	refreshList(mRootNode, mCurrTag)
end
----------------------------------------------------------------------
-- 技能组改变
local function handleSkillGroupChange(data)
	if nil == mRootNode or false == data.success then
		return
	end
	refreshSkillGroup(mRootNode)
	changeAction(mRootNode, data.activate_group, true)
	Toast.show(GameString.get("SKILL_STR_10"))
end
----------------------------------------------------------------------
-- 处理新手引导
local function handleGuideGroup(start)
	if nil == mRootNode and start then
		return
	end
	skillShowForGuide(mRootNode)
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_PUTON"], handleSkillEquip)
EventCenter_subscribe(EventDef["ED_SKILL_TAKEOFF"], handleSkillEquip)
EventCenter_subscribe(EventDef["ED_SKILL_GROUP_CHANGE"], handleSkillGroupChange)
EventCenter_subscribe(EventDef["ED_GUIDE_GROUP"], handleGuideGroup)

