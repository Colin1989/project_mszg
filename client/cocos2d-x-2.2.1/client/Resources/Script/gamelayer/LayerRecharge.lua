----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-07
-- Brief:	充值界面
----------------------------------------------------------------------
local mRechargeList = nil

local mRootView = nil
-- 表示从什么界面进来的
local mEnter_layer = nil 
local mMonthInfo = {}	--月卡的数值

LayerRecharge = {}
LayerAbstract:extend(LayerRecharge)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		if mEnter_layer ~= nil then
			if mEnter_layer == "Main" then
				LayerMain.pullPannel()
			else
				setConententPannelJosn(mEnter_layer, mEnter_layer.jsonFile, widgetName)
			end
		else 
			setConententPannelJosn(LayerActivity, "Activity.json", "Activity")
		end 
	end
end
----------------------------------------------------------------------
-- -- 领取礼包按钮
local function clickGetRewardBtn(typeName, widget)
	if "releaseUp" ~= typeName then
		return
	end
	if FirstRechargeLogic.existAward() == false then
		Toast.show(GameString.get("Public_recharge_str5"))
	else
		FirstRechargeLogic.requestGetReward()
	end
end
----------------------------------------------------------------------
-- 点击购买按钮
local function clickBuyBtn(typeName, widget)
	if "releaseUp" == typeName then
		local isCloseBuy = false
		if true == isCloseBuy then
			Toast.show( GameString.get("RECHARGE_TIP_1"))
			return
		end
		local widgetName = widget:getName()
		local rechargeId = 1
		if widgetName == "Button_buyMonth" then
			rechargeId = mMonthInfo.id
		else
			rechargeId = widget:getTag()	
		end
		local rechargeRow = LogicTable.getRechargeRow(rechargeId)
		ChannelProxy.pay(tostring(rechargeId), tostring(rechargeRow.money/100.0), GameString.get("PUBLIC_CHONG_ZHI"))
	end
end
----------------------------------------------------------------------
--创建充值列表
local function createList(rootView)
	--列表
	local dataTable = {}	-- 活动列表
	for key, val in pairs(mRechargeList) do
		if val.type == 1 then
			mMonthInfo = val
			table.insert(dataTable, 1, val)
		elseif val.type == 2 then
			table.insert(dataTable, val)
		end
	end
	
	local scrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	local function createCellFunc(val)
		local node = nil
		node = CommonFunc_getImgView("public2_bg_07.png")
		node:setScale9Enabled(true)
		node:setCapInsets(CCRectMake(20, 20, 1, 1))
		node:setSize(CCSizeMake(280, 223))
		--放光的图片
		local bg = CommonFunc_getImgView("roleup_juesebg.png")
		bg:setPosition(ccp(0,0))
		node:addChild(bg)
		--充背景
		local rechargeBg = CommonFunc_getImgView("public2_bg_05.png")
		rechargeBg:setScale9Enabled(true)
		rechargeBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		rechargeBg:setSize(CCSizeMake(254, 49))
		rechargeBg:setPosition(ccp(0,70))
		node:addChild(rechargeBg)
		
		--魔石图片
		local emonyIcon = nil
		if val.type == 1 then
			emonyIcon = CommonFunc_getImgView("recharge_yueka.png")
		else
			emonyIcon = CommonFunc_getImgView("recharge_modify_3.png")
		end
		emonyIcon:setPosition(ccp(-90,0))
		rechargeBg:addChild(emonyIcon)
		--充lbl
		local text1 = nil
		local rechargeLbl = nil
		if val.type == 1 then
			text1 = GameString.get("Public_recharge_str3", val.reward_emoney)
			rechargeLbl = CommonFunc_getLabel(text1, 22)
			rechargeLbl:setColor(ccc3(172, 189, 23))
			rechargeLbl:setPosition(ccp(37, 0))
		else
			text1 = GameString.get("Public_recharge_str1", val.recharge_emoney)
			rechargeLbl = CommonFunc_getLabel(text1, 26)
			rechargeLbl:setPosition(ccp(41, 0))
		end
		rechargeBg:addChild(rechargeLbl)
		
		--送背景
		local rewardBg = CommonFunc_getImgView("public2_bg_05.png")
		rewardBg:setScale9Enabled(true)
		rewardBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		rewardBg:setSize(CCSizeMake(254, 49))
		rewardBg:setPosition(ccp(0,-6))
		node:addChild(rewardBg)
		
		--送图片
		local rewardIcon = CommonFunc_getImgView("recharge_modify_2.png")
		rewardIcon:setPosition(ccp(-93,0))
		rewardBg:addChild(rewardIcon)
		--送label
		local text2 = nil
		local rewardLabel = nil
		if val.type == 1 then
			local row = LogicTable.getMonthCardDaiylAwardRow(MonthCardLogic.getMonthCardId())
			text2 =GameString.get("Public_recharge_str4",row.amount[1])
			rewardLabel = CommonFunc_getLabel(text2, 22)
			rewardLabel:setPosition(ccp(37, 0))
		else
			text2 = GameString.get("Public_recharge_str2",val.reward_emoney)
			rewardLabel = CommonFunc_getLabel(text2, 26)
			rewardLabel:setPosition(ccp(41, 0))
		end
		rewardLabel:setColor(ccc3(13,232,220))
		rewardBg:addChild(rewardLabel)
		
		-- 购买按钮
		local buyBtn = CommonFunc_getButton("public_newbuttom_4.png", "public_newbuttom_4.png", "public_newbuttom_4.png")
		local text = string.format("%0.1f", val.money/100)..GameString.get("PUBLIC_RMB")
		if math.floor(val.money/100) == (val.money/100) then
			text = string.format("%d", val.money/100)..GameString.get("PUBLIC_RMB")
		end
		local buyLbl = CommonFunc_getLabel(text, 26)
		buyLbl:setColor(ccc3(228,240,151))
		buyBtn:addChild(buyLbl)
		buyBtn:setTag(val.id)
		if val.type == 1 then
			buyBtn:setName("Button_buyMonth")
		end
		buyBtn:registerEventScript(clickBuyBtn)
		buyBtn:setPosition(ccp(6, -68))
		node:addChild(buyBtn)
		return node
	end
	UIEasyScrollView:create(scrollView, dataTable, createCellFunc, 4, true, 8, 2, false, 223)
end
----------------------------------------------------------------------
-- 设置首充领取的四个奖励物品
local function setRewardItem()
	if mRootView == nil then
		return
	end
	for key,value in pairs(FirstRecharge_RewardTb) do
		local tempTb = LogicTable.getRewardItemRow(value.id)
		local image = mRootView:getChildByName(string.format("ImageView_%d",key))
		tolua.cast(image,"UIImageView")
		image:loadTexture(tempTb.icon)
		--长按
		image:setTouchEnabled(true)
		local function clickSkillIcon(image)
			showLongInfoByRewardId(tempTb.id,image)
		end
		
		local function clickSkillIconEnd(image)
			longClickCallback_reward(tempTb.id,image)
		end

		UIManager.registerEvent(image, nil, clickSkillIcon, clickSkillIconEnd)

		
		local numLbl = mRootView:getChildByName(string.format("num_%d",key))
		tolua.cast(numLbl,"UILabelAtlas")
		numLbl:setStringValue(tostring(value.amount))
		local nameLbl = mRootView:getChildByName(string.format("name_%d",key))
		tolua.cast(nameLbl,"UILabel")
		nameLbl:setText(tempTb.name)
	end
end
----------------------------------------------------------------------
-- 设置领取奖励按钮
local function setGetRewardBtn()
	if mRootView == nil then
		return
	end
	--领取礼包按钮
	local getRewardBtn = tolua.cast(mRootView:getChildByName("Button_getReward"), "UIButton")
	local tipIcon = getRewardBtn:getChildByName("tip_icon")
	if nil == tipIcon then
		tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setName("tip_icon")
		tipIcon:setPosition(ccp(43, 42))
		getRewardBtn:addChild(tipIcon)
	end
	tipIcon:setVisible(FirstRechargeLogic.existAward())
	
	if FirstRechargeLogic.beReceived() == true then
		getRewardBtn:setBright(false)
		getRewardBtn:setTouchEnabled(false)
	else
		getRewardBtn:setBright(true)
		getRewardBtn:setTouchEnabled(true)
		getRewardBtn:registerEventScript(clickGetRewardBtn)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerRecharge.init = function(rootView)
	if nil == mRechargeList then
		mRechargeList = LogicTable.getRechargeTable(ChannelProxy.getChannelId())
	end
	mRootView = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	--创建列表
	createList(mRootView)
	
	setRewardItem()
	setGetRewardBtn()
end
----------------------------------------------------------------------
-- 销毁
LayerRecharge.destroy = function()
	mRootView = nil
	mEnter_layer = nil
end
----------------------------------------------------------------------
local function handleEnter_Recharge(param)
	mEnter_layer = param
end
EventCenter_subscribe(EventDef["ED_ENTER_RECHARGE"], handleEnter_Recharge)

-- 游戏事件注册
EventCenter_subscribe(EventDef["ED_FIRSTR_ECHARGE_GET"], setGetRewardBtn)