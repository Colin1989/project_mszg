--region LayerRuneReward.lua
--Author : songcy
--Date   : 2014/10/23

LayerRuneReward = {}

local mRootView = nil
local typeIndex = nil
local tbRewardList = {}

-- 长按事件的ID和控件
local touchId = nil
local touchWidget = nil

local payTb = {
			[1] = {icon = "goldicon_02.png", price = RUNE_ONE_NORMAL_PAY},
			[2] = {icon = "goldicon_02.png", price = RUNE_TEN_NORMAL_PAY},
			[3] = {icon = "rmbicon.png", price = RUNE_ONE_SPECIAL_PAY},
			[4] = {icon = "rmbicon.png", price = RUNE_TEN_SPECIAL_PAY},
}

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_RuneReward")
		TipModule.onClick(widget)
	end
end

-- 发送寻宝类型
local function sendRuneMsg(typeIndex)
	LayerRune.updateUnlockSkill()
	local tb = req_sculpture_divine()
	tb.type = tonumber(typeIndex)
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_divine"])
end

--[[
--点击图片查看详细信息
local function iconClick(clickType,widget)
	if clickType ~= "releaseUp" then
		return
	end
	CommonFunc_showInfo(0, widget:getTag(), 0, nil, 1)
end
]]--

-- 点击再抽一次
local function clickAgainBtn(typeName, widget)
	if "releaseUp" ~= typeName then
		return
	end
	-- 单次普通寻宝
	if typeIndex == 1 then
		-- 金币不足
		if CommonFunc_payConsume(1, RUNE_ONE_NORMAL_PAY) then
			return
		end
			
		local function dialogSureCall()
			sendRuneMsg(typeIndex)
		end
		local str = "RUNE_NORMAL_PAY_ONE"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RUNE_ONE_NORMAL_PAY)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	-- 十次普通寻宝
	elseif typeIndex == 2 then
		-- 金币不足
		if CommonFunc_payConsume(1, RUNE_TEN_NORMAL_PAY) then
			return
		end
		
		local function dialogSureCall()
			sendRuneMsg(typeIndex)
		end
		local str = "RUNE_NORMAL_PAY_TEN"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RUNE_TEN_NORMAL_PAY)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	-- 单次特殊寻宝
	elseif typeIndex == 3 then
		if CommonFunc_payConsume(2, RUNE_ONE_SPECIAL_PAY) then
			return
		end
		
		local function dialogSureCall()
			sendRuneMsg(typeIndex)
		end
		local str = "RUNE_SPECIAL_PAY_ONE"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RUNE_ONE_SPECIAL_PAY)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	-- 十次特殊寻宝
	elseif typeIndex == 4 then
		-- 魔石不足
		if CommonFunc_payConsume(2, RUNE_TEN_SPECIAL_PAY) then
			return
		end
		
		local function dialogSureCall()
			sendRuneMsg(typeIndex)
		end
		local str = "RUNE_SPECIAL_PAY_TEN"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RUNE_TEN_SPECIAL_PAY)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	end
end

-- 展示结束
LayerRuneReward.showOver = function()
	local againBtn = tolua.cast(mRootView:getChildByName("Button_again"), "UIButton")
	againBtn:setTouchEnabled(true)
	local payImage = tolua.cast(mRootView:getChildByName("ImageView_178"), "UIImageView")
	payImage:loadTexture(payTb[typeIndex].icon)
	local payPrice = tolua.cast(mRootView:getChildByName("Label_pay"), "UILabel")
	payPrice:setText(payTb[typeIndex].price)

	local arr_5 = CCArray:create()
	arr_5:addObject(CCDelayTime:create(0.2))
	local spawnAction_5 = CCSpawn:createWithTwoActions(
		CCScaleTo:create(0.3, 1.0),
		CCFadeIn:create(0.3))
	arr_5:addObject(spawnAction_5)
	payImage:runAction(CCSequence:create(arr_5))
end

-- 展示
local key = 1
-- local amount = {}
LayerRuneReward.showReward = function(Index)
	key = Index or 1
	local data = tbRewardList[key]
	-- amount[key] = data.amount
	if data == nil then
		cclog("data == nil")
		return
	end
	local isPause = false
	local showTip = false
	local row = nil
	if data.type == 8 then
		local tbSkill = SkillConfig.getSkillInfo(data.temp_id)
		local unlockSkillTb = LayerRune.getUnlockSkill()
		for key, val in pairs(unlockSkillTb) do
			if tonumber(tbSkill.skill_group) == tonumber(val) then			-- 已解锁
				showTip = true
				row = SkillConfig.getSkillFragInfo(tbSkill.unlock_need_id)
				row.amount = tbSkill.equal_frags_amount
				break
			end
			if key == #unlockSkillTb then
				
			end
		end
		isPause = true
	end
	local rewardImage = tolua.cast(mRootView:getChildByName(string.format("icon_%d",key)),"UIImageView")		--奖励Icon
	rewardImage:loadTexture(data.icon)
	rewardImage:setTag(data.temp_id)
	rewardImage:setOpacity(0)
	rewardImage:setScale(0)
	CommonFunc_SetQualityFrame(rewardImage)
	
	local qualityImage = tolua.cast(rewardImage:getChildByName("UIImageView_quality"), "UIImageView")
	qualityImage:setOpacity(0)
	qualityImage:setScale(0)
	-- qualityImage:runAction(CCFadeIn:create(0.3))
	
	local whiteImage = tolua.cast(mRootView:getChildByName(string.format("white_%d",key)),"UIImageView")
	
	local function callBackFunc_1(sender)
		rewardImage:setTouchEnabled(true)
		--rewardImage:registerEventScript(iconClick)
		
		local function clickSkillIcon(rewardImage)
			touchId = data.id
			touchWidget = rewardImage
			showLongInfoByRewardId(data.id,rewardImage)
		end
		
		local function clickSkillIconEnd(rewardImage)
			longClickCallback_reward(data.id,rewardImage)
			touchId = nil
			touchWidget = nil
		end
		UIManager.registerEvent(rewardImage, nil, clickSkillIcon, clickSkillIconEnd)
		
		local tipPanel = tolua.cast(mRootView:getChildByName(string.format("tipPanel_%d",key)),"UIImageView")
		local tipLabel = tolua.cast(mRootView:getChildByName(string.format("tipLabel_%d",key)), "UILabel")
		tipLabel:setText(data.amount)
		local arr_4 = CCArray:create()
		arr_4:addObject(CCDelayTime:create(0.2))
		local spawnAction_4 = CCSpawn:createWithTwoActions(
		CCScaleTo:create(0.3, 1.0),
		CCFadeIn:create(0.3))
		arr_4:addObject(spawnAction_4)
		tipPanel:runAction(CCSequence:create(arr_4))
		
		if isPause == false then
			if tbRewardList[key + 1] ~= nil then
				LayerRuneReward.showReward(key + 1)
			else
				LayerRuneReward.showOver()
			end
		else
			if UIManager.getTopLayerName() == "UI_ItemInfo" or UIManager.getTopLayerName() == "UI_GemInfo" then
				UIManager.pop(UIManager.getTopLayerName())
			end
			if touchId ~= nil and touchWidget ~= nil then
				longClickCallback_reward(touchId, touchWidget)
				touchId = nil
				touchWidget = nil
			end
			if GuideMgr.guideStatus() > 0 then	-- 新手教程阶段,不弹碎片介绍界面
				if tbRewardList[key + 1] ~= nil then
					LayerRuneReward.showReward()
				else
					LayerRuneReward.showOver()
				end
			else
				local bundle = data
				bundle.runeType = typeIndex
				if tbRewardList[key + 1] ~= nil then
					bundle.param = key + 1
					bundle.callback = LayerRuneReward.showReward
				else
					bundle.callback = LayerRuneReward.showOver
				end
				UIManager.push("UI_RuneShow",bundle)
				if showTip == true then
					Toast.show(GameString.get("RUNE_UNLOCK_SKILL_TIP_1", row.name, row.amount))
				end
			end
			isPause = false
		end
	end
	
	local arr_1 = CCArray:create()
	arr_1:addObject(CCDelayTime:create(0.2))
	local spawnAction_1 = CCSpawn:createWithTwoActions(
		CCScaleTo:create(0.3, 1.0),
		CCFadeIn:create(0.3))
	arr_1:addObject(spawnAction_1)
	arr_1:addObject(CCCallFuncN:create(callBackFunc_1))
	rewardImage:runAction(CCSequence:create(arr_1))
	local arr_2 = CCArray:create()
	arr_2:addObject(CCDelayTime:create(0.2))
	local spawnAction_2 = CCSpawn:createWithTwoActions(
		CCScaleTo:create(0.3, 1.0),
		CCFadeIn:create(0.3))
	arr_2:addObject(spawnAction_2)
	qualityImage:runAction(CCSequence:create(arr_2))
	local arr_3 = CCArray:create()
	arr_3:addObject(CCDelayTime:create(0.2))
	arr_3:addObject(CCScaleTo:create(0.3, 1.0))
	arr_3:addObject(CCFadeOut:create(0.2))
	whiteImage:runAction(CCSequence:create(arr_3))
end

--设置icon动态排列,根据传过来的个数
local function drawToumingImg(number)
	local mScrollView = tolua.cast(mRootView:getChildByName("ScrollView_rewardList"),"UIScrollView")	-- 新功能背景
	local mScrollViewWidth = mScrollView:getInnerContainerSize().width				-- 列表宽
	local mScrollViewHeight = mScrollView:getInnerContainerSize().height			-- 列表高
	
	local deltaX = 11			-- 表示两个Icon横轴中间的距离
	local deltaY = 0			-- 表示两个Icon纵轴中间的距离
	
	local widget_width = 94		-- 图标宽度
	local widget_height = 130		-- 图标高度
	-- local name_position_y = 20
	
	local rowNum = 5
	local columnNum = math.ceil(number / rowNum)
	local detalX = (mScrollViewWidth % (rowNum * widget_width))/(rowNum + 1)  -- 向左偏移已至居中
	local detalY = (mScrollViewHeight % (columnNum * widget_height))/(columnNum + 1)
	
	-- local scrollViewHeight = columnNum * widget_height + (columnNum + 1) * deltaY
	-- if mScrollViewHeight < scrollViewHeight then
		-- mScrollViewHeight = scrollViewHeight
	-- end
	-- 设置列表宽高
	-- mScrollView:setInnerContainerSize(CCSizeMake(mScrollViewWidth, mScrollViewHeight + 10))
	
	local tempCount = 0
	for y = 1,columnNum,1 do
		for x = 1,rowNum,1 do
			tempCount = tempCount + 1
			local position_x = detalX * x + widget_width * (x - 1) + widget_width / 2		--表示放置的横轴位置
			local position_y = mScrollViewHeight - (y * deltaY + widget_height * (y - 1) + widget_height / 2) + 10
			
			-- 图片
			local img = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(position_x,position_y),
						CCSizeMake(94,94), "touming.png",string.format("icon_%d",tempCount),1 )
			mScrollView:addChild(img)
			
			-- 白光特效
			local white = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(position_x,position_y),
						CCSizeMake(94,94), "forge_recast_blickIcon.png",string.format("white_%d",tempCount),3)
			mScrollView:addChild(white)
			
			-- 文本背景框
			local tipPanel = UIImageView:create()
			tipPanel:loadTexture("public2_bg_05.png")
			tipPanel:setScale9Enabled(true)
			tipPanel:setCapInsets(CCRectMake(0, 0, 0, 0))
			tipPanel:setSize(CCSizeMake(84, 22))
			tipPanel:setAnchorPoint(ccp(0.5, 0.5))
			tipPanel:setPosition(ccp(0, -62))
			tipPanel:setName(string.format("tipPanel_%d",tempCount))
			-- tipPanelRoot:addWidget(tipPanel)
			img:addChild(tipPanel)
			
			-- 显示文本
			local tipLabel = UILabel:create()
			tipLabel:setFontName("Arial")
			tipLabel:setFontSize(22)
			tipLabel:setColor(ccc3(255, 255, 255))
			-- tipLabel:setTextAreaSize(CCSizeMake(95, 28))
			tipLabel:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter)
			tipLabel:setTextHorizontalAlignment(kCCTextAlignmentLeft)
			tipLabel:setAnchorPoint(ccp(0.5, 0.5))
			tipLabel:setPosition(ccp(0, 0))
			tipLabel:setName(string.format("tipLabel_%d",tempCount))
			tipPanel:addChild(tipLabel)
			
			-- tipLabel = tolua.cast(tipPanel:getChildByName(string.format("tipLabel_%d",tempCount)), "UILabel")
			-- tipLabel:setText(tbRewardList[1].amount)
			
			if tempCount == number then
				break
			end
		end
	end
end

-- 初始化
LayerRuneReward.init = function(packet)
	cclog(#packet.reward_list)
	if #packet.reward_list == 0 then
		cclog("LayerRuneReward error")
		return
	end
	-- mRootView = nil
	mRootView = UIManager.findLayerByTag("UI_RuneReward"):getWidgetByName("Panel_124")
	
	local mScrollView = tolua.cast(mRootView:getChildByName("ScrollView_rewardList"),"UIScrollView")
	mScrollView:jumpToTop()
	mScrollView:removeAllChildren()
	
	typeIndex = packet.type
	tbRewardList = {}
	for key,val in pairs(packet.reward_list) do
		local rewardItem = LogicTable.getRewardItemRow(val.id)
		rewardItem.amount = val.amount
		
		table.insert(tbRewardList, rewardItem)
	end
	
	-- 关闭
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	
	local againBtn = tolua.cast(mRootView:getChildByName("Button_again"), "UIButton")
	againBtn:registerEventScript(clickAgainBtn)
	againBtn:setTouchEnabled(false)
	-- againBtn:setOpacity(0)
	
	
	drawToumingImg(#tbRewardList)
	for key,value in pairs(tbRewardList) do
		local whiteImage = tolua.cast(mRootView:getChildByName(string.format("white_%d",key)),"UIImageView")		--奖励Icon
		-- whiteImage:setOpacity(0)
		whiteImage:setScale(0)
		
		local tipPanel = tolua.cast(mRootView:getChildByName(string.format("tipPanel_%d",key)),"UIImageView")
		tipPanel:setOpacity(0)
		tipPanel:setScale(0)
		
		local payImage = tolua.cast(mRootView:getChildByName("ImageView_178"), "UIImageView")
		-- payImage:setOpacity(0)
		payImage:setScale(0)
	end
	
	key = 1
	LayerRuneReward.showReward()
	TipModule.onUI(mRootView, "ui_runereward")
end

-- 销毁
LayerRuneReward.destroy = function()
	mRootView = nil
	tbRewardList = {}
end