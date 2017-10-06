--/**
-- *  @Brief: 援助
-- *  @Created by fjut on 14-03-18
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */
----------------------------------------------------------------------
local mRootNode = nil
local mSelectDonorCell = nil		-- 选中的cell
local mDonorList = {}				-- 援军数据列表
local CELL_TAG = 10000				-- 援军选项tag起始

LayerAssistance = {}
LayerAbstract:extend(LayerAssistance)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_Assistance")
	end
end
----------------------------------------------------------------------
-- 点击刷新按钮
local function clickRefreshBtn(typeName, widget)
	if "releaseUp" == typeName then
		local function okFunc()
			AssistanceLogic.requestRefreshAssistanceList()
		end
		local freeRefreshTimes = ASSIST_FREE_REFRESH_TIMES - AssistanceLogic.getRefreshTimes()
		local tipStr = GameString.get("Assistance_str_03")
		if freeRefreshTimes > 0 then
			tipStr = GameString.get("Assistance_str_05")
		end
		local structConfirm = 
		{
			strText = tipStr,
			buttonCount = 2,
			buttonEvent = {okFunc, nil}
		}
		UIManager.push("UI_ComfirmDialog", structConfirm)
		return
	end
end
----------------------------------------------------------------------
-- 点击进入按钮
local function clickEnterBtn(typeName, widget)
	if "releaseUp" == typeName then
		if nil == mSelectDonorCell then
			Toast.Textstrokeshow(GameString.get("Assistance_str_01", str), ccc3(255,255,255), ccc3(0,0,0), 30)
			return
		end
		TipModule.onClick(widget)
		local index = mSelectDonorCell:getTag() - CELL_TAG
		local data = mDonorList[index]
		AssistanceLogic.requestSelectDonor(data.role_id)
	end
end
----------------------------------------------------------------------
-- 选取援军
local function selectAssistance(widget)
	TipModule.onMessage("click_assistance", widget:getTag())
	tolua.cast(widget, "UIImageView")
	if mSelectDonorCell then
		mSelectDonorCell:loadTexture("assistance_cell_bg.png")
	end
	widget:loadTexture("assistance_cell_bg_active.png")
	mSelectDonorCell = widget
end
----------------------------------------------------------------------
-- 点击援军
local function clickCell(typeName, widget)
	if "releaseUp" == typeName then
		if mSelectDonorCell == widget then
			return
		end
		selectAssistance(widget)
	end
end
----------------------------------------------------------------------
-- 创建援军选项
local function createCell(data, index)
	local cellNode = CommonFunc_getImgView("assistance_cell_bg.png")
	cellNode:setName("friend"..index)
	cellNode:registerEventScript(clickCell)
	cellNode:setTouchEnabled(true)
	cellNode:setTag(CELL_TAG + index)
	-- 头像
	local imgHead = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(data.role_type,data.advanced_level))
	imgHead:setPosition(ccp(-216, 0))
	cellNode:addChild(imgHead)
	-- 昵称
	local labelNick = CommonFunc_getLabel(data.nick_name, 20)
	labelNick:setPosition(ccp(-81, 40))
	cellNode:addChild(labelNick)
	-- 友情点
	local labelFri = CommonFunc_getLabel(string.format("%d", data.friend_point), 20)
	labelFri:setPosition(ccp(133, 40))
	cellNode:addChild(labelFri)
	-- 技能头像
	local imgSkill = CommonFunc_AddGirdWidget_Rune(data.sculpture.temp_id, data.sculpture.level)
	imgSkill:setPosition(ccp(216, 0))
	imgSkill:setTouchEnabled(true)
	
	local function clickSkillIcon(imgSkill)
		local position,direct = CommonFuncJudgeInfoPosition(imgSkill)
		local bundle = {}
		bundle.skill_id = data.sculpture.temp_id
		bundle.level = data.sculpture.level
		bundle.position = position
		bundle.direct =direct
		UIManager.push("UI_SkillInfo_Long", bundle)
	end
	UIManager.registerEvent(imgSkill, nil, clickSkillIcon, CommonFunc_longEnd_skill)
	--[[
	imgSkill:registerEventScript(function(typeName, widget)
							if "releaseUp" == typeName then
								local bundle = {}
								bundle.skill_id = data.sculpture.temp_id
								bundle.level = data.sculpture.level
								UIManager.push("UI_SkillInfo", bundle)
							end
						end)
	]]--
	
	cellNode:addChild(imgSkill)
	-- 技能名称
	local desc =   SkillDescription.reinforce(data.sculpture.temp_id, data.sculpture.level) --SkillMgr.getDescription(data.sculpture.temp_id, data.sculpture.level)
	local labelSkillName = CommonFunc_getLabel(desc, 18)
	labelSkillName:setAnchorPoint(ccp(0, 1))
	labelSkillName:setTextAreaSize(CCSizeMake(320, 65))
	labelSkillName:setPosition(ccp(-156, 18))
	cellNode:addChild(labelSkillName)
	-- 好友标识
	if true == FriendDataCache.judgeIsMyFriend(data.role_id) then
		local friendTip = CommonFunc_getImgView("assistance_friend_tip.png")
		friendTip:setPosition(ccp(-243, 37))
		cellNode:addChild(friendTip)
	end
	-- 是否已被使用
	if 1 == data.is_used then
		cellNode:setTouchEnabled(false)
		imgSkill:setTouchEnabled(false)
		local grayImage = CommonFunc_getImgView("hei.png")
		grayImage:setScaleX(620/128)
		grayImage:setScaleY(152/120)
		cellNode:addChild(grayImage)
		local usedTip = CommonFunc_getImgView("assistance_used_tip.png")
		cellNode:addChild(usedTip)
	end
	return cellNode
end
----------------------------------------------------------------------
-- 默认选中第一个未被使用的援军
local function initAssistance(donorList)
	for key, val in pairs(donorList) do
		if val.is_used ~= 1 and mSelectDonorCell == nil then
			local scrollView = tolua.cast(mRootNode:getChildByName("ScrollView_list"), "UIScrollView")
			if (#donorList - key) <= 2 then
				scrollView:jumpToPercentVertical(100)
			else
				scrollView:jumpToPercentVertical((key - (1 + 0.01 * (1.56 * key))) / (#donorList - 4) * 100)
			end
			local widget = scrollView:getChildByTag(CELL_TAG + key)
			selectAssistance(widget)
			return
		end
	end
end
----------------------------------------------------------------------
-- 显示援军列表
local function showScrollView(donorList)
	if nil == mRootNode then
		return
	end
	mSelectDonorCell = nil
	local scrollView = tolua.cast(mRootNode:getChildByName("ScrollView_list"), "UIScrollView")
	scrollView:removeAllChildren()
	local cellArray = {}
	for key, val in pairs(donorList) do
		table.insert(cellArray, createCell(val, key))
	end
	setAdapterGridView(scrollView, cellArray, 1, 0)
	if 0 == GuideMgr.guideStatus() then
		-- 默认选中援军
		initAssistance(donorList)
	end
	-- 免费刷新次数
	local freeRefreshTimes = ASSIST_FREE_REFRESH_TIMES - AssistanceLogic.getRefreshTimes()
	if freeRefreshTimes < 0 then
		freeRefreshTimes = 0
	end
	local freeRefreshLabel = tolua.cast(mRootNode:getChildByName("Label_free"), "UILabel")
	freeRefreshLabel:setText(tostring(freeRefreshTimes))
end
----------------------------------------------------------------------
-- 初始化
LayerAssistance.init = function()
	mRootNode = UIManager.findLayerByTag("UI_Assistance"):getWidgetByName("panel")
	-- 关闭按钮
	local closeBtn = tolua.cast(mRootNode:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 刷新按钮
	local refreshBtn = tolua.cast(mRootNode:getChildByName("Button_refresh"), "UIButton")
	refreshBtn:registerEventScript(clickRefreshBtn)
	-- 进入按钮
	local enterBtn = tolua.cast(mRootNode:getChildByName("Button_enter"), "UIButton")
	enterBtn:registerEventScript(clickEnterBtn)
	AssistanceLogic.requestAssistanceList()
	TipModule.onUI(mRootNode, "ui_assistance_select")
end
----------------------------------------------------------------------
-- 销毁
LayerAssistance.destroy = function()
	mRootNode = nil
	mSelectDonorCell = nil
end
----------------------------------------------------------------------
-- 处理援军列表
local function handleDonorList(donorList)
	if nil == mRootNode or 0 == #donorList then
		return
	end
	mDonorList = donorList
	showScrollView(mDonorList)
end
----------------------------------------------------------------------
-- 处理选择援军
local function handleSelectDonor(success)
	if nil == mRootNode or nil == mSelectDonorCell or false == success then
		return
	end
	-- 援军
	local index = mSelectDonorCell:getTag() - CELL_TAG
	AssistanceLogic.setDonorInfo(mDonorList[index])
	-- 进入战斗
	UIManager.pop("UI_Assistance")
	local enterType = AssistanceLogic.getEnterType()
	if 0 == enterType then
		FightStartup.startStage(LayerCopyTips.getId())
	elseif 1 == enterType then
		FightStartup.startActivity(LayerActivityCopyTip.getCopyId())
	end
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_DONOR_LIST"], handleDonorList)
EventCenter_subscribe(EventDef["ED_SELECT_DONOR"], handleSelectDonor)

