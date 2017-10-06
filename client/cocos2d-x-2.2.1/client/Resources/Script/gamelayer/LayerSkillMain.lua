----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-21
-- Brief:	技能主界面
----------------------------------------------------------------------
LayerSkillMain = {}
local mRootNode = nil
local mSkillInfoArray = nil
local mCurrClickData = nil
local mCurrTag = 4
----------------------------------------------------------------------
-- 点击装备按钮
local function clickEquipBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerSkillEquip, "SkillEquip.json", "SkillEquipUI")
	end
end
----------------------------------------------------------------------
-- 点击单元格
local function clickCell(widget)
	TipModule.onClick(widget)
	local tag = widget:getTag()
	local index = math.floor(tag/1000)
	local status = tag%1000
	mCurrClickData = mSkillInfoArray[index]
	Log(mCurrClickData)
	if 4 == status or 5 == status then		-- 未解锁
		local bundle = {}
		bundle.skill_id = mCurrClickData.id
		bundle.level = mCurrClickData.level
		UIManager.push("UI_SkillUnlock", bundle)
	else
		if mCurrTag == 4 then
			LayerSkillDevelop.setIsAll()
		end
		setConententPannelJosn(LayerSkillDevelop, "SkillDevelop.json", "SkillDevelopUI")
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
			rootView:addChild(tipImg)
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
			tagBtn:setPosition(ccp(tagBtnPos.x, 614))
			tipImg:setPosition(ccp(tagBtnPos.x + 45, 635))
		else
			tagBtn:setTag(0)
			tagBtn:loadTextureNormal(tagBtnNormal[i])
			tagBtn:loadTexturePressed(tagBtnNormal[i])
			tagImage:loadTexture(tagImageNormal[i])
			tagBtn:setPosition(ccp(tagBtnPos.x, 608))
			tipImg:setPosition(ccp(tagBtnPos.x + 40, 625))
		end
	end
end
----------------------------------------------------------------------
-- 创建单元格
local function createCell(cell, data, index)
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(data.id)
	local status = SkillLogic.getSkillStatus(data)
	local cell = UIImageView:create()
	cell:loadTexture("public2_bg_07.png")
	cell:setScale9Enabled(true)
	cell:setCapInsets(CCRectMake(0, 0, 0, 0))
	cell:setSize(CCSizeMake(129, 181))
	cell:setTouchEnabled(true)
	cell:setTag(index*1000 + status)
	cell:setName("skill_name"..index)
	--cell:registerEventScript(clickCell)
	local function clickSkillIcon(cell)
		local position,direct = CommonFuncJudgeInfoPosition(cell)
		local bundle = {}
		bundle.skill_id = data.id
		bundle.level = data.level
		bundle.position = position
		bundle.direct =direct
		UIManager.push("UI_SkillInfo_Long", bundle)
	end
	UIManager.registerEvent(cell, clickCell, clickSkillIcon, CommonFunc_longEnd_skill)
	-- 名称
	local nameLabelBg = UIImageView:create()
	nameLabelBg:loadTexture("public2_bg_05.png")
	nameLabelBg:setScale9Enabled(true)
	nameLabelBg:setCapInsets(CCRectMake(0, 0, 0, 0))
	nameLabelBg:setSize(CCSizeMake(112, 27))
	nameLabelBg:setPosition(ccp(0, 72))
	local nameLabel = CommonFunc_createUILabel(nil, ccp(0, 0), nil, 20, ccc3(255, 255, 255), skillBaseInfo.name, nil, nil)
	nameLabelBg:addChild(nameLabel)
	cell:addChild(nameLabelBg)
	-- 图标
	local iconImage = CommonFunc_AddGirdWidget_Rune(data.id, data.level, nil, nil)
	iconImage:setPosition(ccp(0, 4))
	cell:addChild(iconImage)
	-- 碎片数量
	local starBg = UIImageView:create()
	starBg:loadTexture("public2_bg_21.png")
	starBg:setScale9Enabled(true)
	starBg:setCapInsets(CCRectMake(0, 0, 0, 0))
	starBg:setSize(CCSizeMake(127, 28))
	starBg:setPosition(ccp(0, -64))
	cell:addChild(starBg)
	local fragCountLabel = CommonFunc_createUILabel(nil, ccp(0, 0), nil, 20, ccc3(255, 255, 255), "", nil, nil)
	starBg:addChild(fragCountLabel)
	if 4 == status or 5 == status then
		local currFragCount = ModelSkill.getFragCount(data.unlock_need_id)
		fragCountLabel:setText(currFragCount.."/"..data.unlock_need_amount)
		if currFragCount >= data.unlock_need_amount then
			fragCountLabel:setColor(ccc3(0, 255, 0))
		end
	else
		local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(data.advance_cost_id)
		if skillAdvanceInfo and skillAdvanceInfo.advanced_id > 0 then
			local currFragCount = ModelSkill.getFragCount(skillAdvanceInfo.need_ids)
			fragCountLabel:setText(currFragCount.."/"..skillAdvanceInfo.need_amount)
			if currFragCount >= skillAdvanceInfo.need_amount then
				fragCountLabel:setColor(ccc3(0, 255, 0))
			end
		end
	end
	-- 其他状态
	local function createTipBg(isGray)
		local img = UIImageView:create()
		if isGray then
			img:loadTexture("icon_mask.png")
			img:setSize(CCSizeMake(130, 184))
		else
			img:loadTexture("public2_bg_21.png")
			img:setSize(CCSizeMake(128, 36))
		end
		img:setScale9Enabled(true)
		img:setCapInsets(CCRectMake(0, 0, 0, 0))
		img:setPosition(ccp(0, 0))
		return img
	end
	if 1 == status then				-- 可晋阶
		local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(data.advance_cost_id)
		if skillAdvanceInfo and skillAdvanceInfo.advanced_id > 0 then
			local currFragCount = ModelSkill.getFragCount(skillAdvanceInfo.need_ids)
			if currFragCount >= skillAdvanceInfo.need_amount then
				local tipBg = createTipBg(false)
				local tipLabel = CommonFunc_createUILabel(nil, ccp(-10, 0), nil, 24, ccc3(255, 219, 99), GameString.get("SKILL_STR_12"), nil, nil)
				local upImage = CommonFunc_createUIImageView(nil, ccp(50, 0), nil, "up.png", nil, nil)
				tipBg:addChild(tipLabel)
				tipBg:addChild(upImage)
				cell:addChild(tipBg)
				local tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
				tipIcon:setPosition(ccp(45, 45))
				cell:addChild(tipIcon)
			end
		end
	elseif 4 == status then			-- 可解锁
		local tipBg = createTipBg(false)
		local tipLabel = CommonFunc_createUILabel(nil, ccp(0, 0), nil, 24, ccc3(255, 219, 99), GameString.get("SKILL_STR_11"), nil, nil)
		tipBg:addChild(tipLabel)
		cell:addChild(tipBg)
		local tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setPosition(ccp(45, 45))
		cell:addChild(tipIcon)
	elseif 5 == status then			-- 不可解锁(材料不足)
		local tipBg = createTipBg(true)
		local tipLabel = CommonFunc_createUILabel(nil, ccp(0, 0), nil, 24, ccc3(255, 255, 255), GameString.get("SKILL_STR_13"), nil, nil)
		tipBg:addChild(tipLabel)
		cell:addChild(tipBg)
	end
	return cell
end
----------------------------------------------------------------------
-- 刷新列表
local function refreshList(rootView, attributeTag)
	if nil == rootView then
		return
	end
	mCurrTag = attributeTag
	mSkillInfoArray = SkillLogic.getSkillArray(attributeTag)
	changeTagStatus(rootView, attributeTag, SkillLogic.existUnlockAdvanceSkill())
	-- 排序算法:可解锁 -> 可晋阶 -> 可升级 -> 已解锁 -> 不可解锁
	local function sortFunc(a, b)
		local aStatus = SkillLogic.getSkillStatus(a)
		local bStatus = SkillLogic.getSkillStatus(b)
		if aStatus == bStatus then
			local aBaseInfo = SkillConfig.getSkillBaseInfo(a.id)
			local bBaseInfo = SkillConfig.getSkillBaseInfo(b.id)
			return aBaseInfo.quality > bBaseInfo.quality
		end
		if 4 == aStatus then
			return true
		end
		if 4 == bStatus then
			return false
		end
		return aStatus < bStatus
	end
	table.sort(mSkillInfoArray, function(a, b) return a.id < b.id end)
	local scrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, mSkillInfoArray, createCell, "V", 129, 181, 5, 4, 3, true, function(scrollView)
		if nil == mRootNode then
			return
		end
		if 1 == GuideMgr.guideStatus() then
			scrollView:scrollToTop(0.01, false)
		end
	end, true, true)
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		LayerMain.pullPannel(LayerSkillMain)
	end
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
			TipModule.onClick(widget)
			refreshList(mRootNode, 1)
		end
	end
end
----------------------------------------------------------------------
-- 点击辅助标签
local function clickAssistTag(typeName, widget)
	if "releaseUp" == typeName then
		if 0 == widget:getTag() then
			TipModule.onClick(widget)
			refreshList(mRootNode, 2)
		end
	end
end
----------------------------------------------------------------------
-- 点击治疗标签
local function clickTreatTag(typeName, widget)
	if "releaseUp" == typeName then
		if 0 == widget:getTag() then
			TipModule.onClick(widget)
			refreshList(mRootNode, 3)
		end
	end
end
----------------------------------------------------------------------
-- 初始化
LayerSkillMain.init = function(rootView)
	mRootNode = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 装备按钮
	local equipBtn = tolua.cast(rootView:getChildByName("Button_equip"), "UIButton")
	equipBtn:registerEventScript(clickEquipBtn)
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
	-- 列表
	refreshList(rootView, mCurrTag)
	TipModule.onUI(rootView, "ui_skillmain")
end
----------------------------------------------------------------------
-- 销毁
LayerSkillMain.destroy = function()
	mRootNode = nil
	mSkillInfoArray = nil
	mCurrTag = 4
end
----------------------------------------------------------------------
-- 获取选择数据
LayerSkillMain.getClickData = function()
	return mCurrClickData
end
----------------------------------------------------------------------
-- 设置标签
LayerSkillMain.setTag = function(attributeTag)
	mCurrTag = attributeTag
	refreshList(mRootNode, attributeTag)
end
----------------------------------------------------------------------
-- 根据技能组id获取控件名
LayerSkillMain.getWidgetNameBySkillGroup = function(skillGroup)
	for key, val in pairs(mSkillInfoArray) do
		if skillGroup == val.skill_group then
			return "skill_name"..key
		end
	end
end
----------------------------------------------------------------------

