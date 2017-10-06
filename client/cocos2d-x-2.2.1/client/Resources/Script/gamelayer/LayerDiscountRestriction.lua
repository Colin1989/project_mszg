
----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-09
-- Brief:	打折限购界面
----------------------------------------------------------------------
local mLayerDiscountRestrictionRoot = nil

LayerDiscountRestriction = {}
LayerAbstract:extend(LayerDiscountRestriction)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
	end
end
----------------------------------------------------------------------
-- 点击充值按钮
local function clickChargeBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
	end
end
----------------------------------------------------------------------
-- 获取物品信息
local function getItemByIdAndType(id,types)
	if tonumber(types) == 1 then						--1是物品
		return LogicTable.getItemById(id)
	elseif tonumber(types) == 2 then					--2是碎片
		return SkillConfig.getSkillFragInfo(id)
	end
	
end
----------------------------------------------------------------------
--[[
-- 物品详细信息
local function showItemDetailCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end	
	CommonFunc_showInfo(1, sender:getTag(), 0)
end
]]--
----------------------------------------------------------------------
-- 根据物品id，获得已经购买的次数
local function getBuyTimesById(id)
	for key,value in pairs(DisResLogic.getBuyList()) do
		if tonumber(id) == value.mallitem_id then
			return value.times
		end
	end	
	return 0
end
----------------------------------------------------------------------
-- 购买物品call
local function purCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	m_productId = tostring(sender:getTag())
	
	local tbRow =  LogicTable.getDisInfoById(m_productId)
	if getBuyTimesById(m_productId) >= tbRow.limit_times then
		Toast.Textstrokeshow(GameString.get("Public_BuyTimes_Not_Enough"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	
	local price = tonumber(tbRow.discount_price)
	local str = (tbRow.price_type == "1") and "ShopMall_BUY1_TIPS" or "ShopMall_BUY_TIPS"
	local strDesc = (tbRow.price_type == "1") and GameString.get("ShopMall_TIPS_JB_FAIL") or GameString.get("ShopMall_TIPS_MS_FAIL")
	
	if CommonFunc_payConsume(2, price) then
		return
	end
	local diaMsg = 
	{
		strText = string.format(GameString.get(str, price, getItemByIdAndType(tbRow.temp_id,tbRow.type).name)),
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {DisResLogic.requestBuyDisItem,nil },
		buttonEvent_Param = {m_productId,nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
	
end
----------------------------------------------------------------------
--加载物品
local function loadItems(id)
	local tbRow = LogicTable.getDisInfoById(id)
	local hasBuyTimes = getBuyTimesById(id)		--已经购买过的次数
	--整个底板
	local node = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(266,245), "public2_bg_07.png", "nameBg", -1)
	node:setScale9Enabled(true)
	node:setTouchEnabled(true)
	node:setTag(tbRow.temp_id)
	--node:registerEventScript(showItemDetailCall)
	
	--长按
	local function clickSkillIcon(node)
		showLongInfoByRewardId(tbRow.temp_id,node)
	end
	
	local function clickSkillIconEnd(node)
		longClickCallback_reward(tbRow.temp_id,node)
	end

	UIManager.registerEvent(node, nil, clickSkillIcon, clickSkillIconEnd)
	
	
	--Log(getItemByIdAndType(tbRow.temp_id,tbRow.type))
	-- 头像
	local head = CommonFunc_getImgView(getItemByIdAndType(tbRow.temp_id,tbRow.type).icon)
	head:setPosition(ccp(-84, 72)) 
	node:addChild(head)
	CommonFunc_SetQualityFrame(head, 1)
	-- 数量
	local labelNum = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	labelNum:setStringValue(tostring(tbRow.amount))
	labelNum:setScale(0.7)
	labelNum:setPosition(ccp(30, -30))
	head:addChild(labelNum)
	--名称背景
	local  nameBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(47,92), CCSizeMake(160,33), "public2_bg_05.png", "nameBg", 1)
	nameBg:setScale9Enabled(true)
	node:addChild(nameBg)
	-- 名称
	local labelName = CommonFunc_getLabel(getItemByIdAndType(tbRow.temp_id,tbRow.type).name, 22) 
	labelName:setPosition(ccp(47, 91))
	labelName:setZOrder(5)
	labelName:setAnchorPoint(ccp(0.5, 0.5))
	labelName:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	node:addChild(labelName)
	-- 限购次数
	local leftTime = tbRow.limit_times -  hasBuyTimes
	local limitTimes =CommonFunc_createUILabel(ccp(0.5,0.5), ccp(49,53), nil, 22,ccc3(248,154,20), GameString.get("Public_Limit_Buy_Times",leftTime), 1, 5)	
	node:addChild(limitTimes)
	--原价背景
	local  normalBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,4), CCSizeMake(265,35), "public2_bg_21.png", "normalBg", 1)
	normalBg:setScale9Enabled(true)
	node:addChild(normalBg)
	--折扣价背景
	local  speBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,-36), CCSizeMake(265,35), "public2_bg_21.png", "speBg", 1)
	speBg:setScale9Enabled(true)
	
	node:addChild(speBg)
	-- 原价汉字
	local normalPrice =CommonFunc_createUILabel(ccp(0.5,0.5), ccp(-89,4), nil, 24,ccc3(255,255,255), GameString.get("Public_Normal_Price"), 1, 5)	
	node:addChild(normalPrice)
	-- 折扣价汉字
	local spePrice =CommonFunc_createUILabel(ccp(0.5,0.5), ccp(-86,-36), nil, 24,ccc3(255,204,0), GameString.get("Public_Spe_Price"), 1, 5)	
	node:addChild(spePrice)
	-- 原价
	local labelPrice =CommonFunc_createUILabel(ccp(0.5,0.5), ccp(58,4), nil, 24,ccc3(255,255,255),tostring(tbRow.price), 1, 5)	
	labelPrice:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	node:addChild(labelPrice)
	--原价打叉
	local  chacha = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(79,26), "chacha.png", "chacha", 0)
	labelPrice:addChild(chacha)
	-- 打折后售价
	local labelVipPrice =CommonFunc_createUILabel(ccp(0.5,0.5), ccp(56,-36), nil, 24,ccc3(255,255,255),tostring(tbRow.discount_price), 2, 5)	
	labelVipPrice:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	node:addChild(labelVipPrice)
	-- 购买
	local btnPur = CommonFunc_getButton("public_newbuttom.png", "public_newbuttom.png", "public_newbuttom.png")
	btnPur:setPosition(ccp(-3, -86))
	btnPur:setTag(tonumber(id))
	--购买的图片
	local buyImg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(64,32), "text_buy.png", "buy", 0)
	btnPur:addChild(buyImg)
	
	if hasBuyTimes >= tbRow.limit_times then
		btnPur:setBright(false)
		btnPur:setTouchEnabled(false)
		Lewis:spriteShaderEffect(btnPur:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(buyImg:getVirtualRenderer(),"buff_gray.fsh",true)
	else
		btnPur:setBright(true)
		btnPur:setTouchEnabled(true)
		Lewis:spriteShaderEffect(btnPur:getVirtualRenderer(),"buff_gray.fsh",false)
		Lewis:spriteShaderEffect(buyImg:getVirtualRenderer(),"buff_gray.fsh",false)
		btnPur:registerEventScript(purCall)	
	end
	node:addChild(btnPur)
	
		
	-- 角标 是否售罄
	if hasBuyTimes  >= tbRow.limit_times then	
		local imgMark = CommonFunc_getImgView("shop_Decoration06.png")
		imgMark:setPosition(ccp(-101, 87))
		imgMark:setZOrder(10)
		node:setTouchEnabled(false)
		btnPur:setTouchEnabled(false)
		node:addChild(imgMark)
	end
	
	-- 货币类型 - 金币, 魔石
	local imgMoneyStr = (tbRow.price_type == "1") and "goldicon_02.png" or "rmbicon.png"
	local imgMoneyNormal = CommonFunc_getImgView(imgMoneyStr)
	imgMoneyNormal:setPosition(ccp(-25, 0))
	normalBg:addChild(imgMoneyNormal)
	local imgMoneyVip = CommonFunc_getImgView(imgMoneyStr)
	imgMoneyVip:setPosition(ccp(-25, 0))
	speBg:addChild(imgMoneyVip)
	return node
			
end
----------------------------------------------------------------------
-- 获得上架的信息
local function getOnlineItems()
	local tb = {}
	local disItem = LogicTable.getDiscountInfo()
	for key,value in pairs(disItem) do
		if value.show == 1 then
			table.insert(tb,value)
		end
	end
	return tb
end
----------------------------------------------------------------------
-- 加载滚动条中的信息
local function loadScrollItems()
	if mLayerDiscountRestrictionRoot == nil then
		return
	end
	
	--滚动条
	local scrollView = tolua.cast(mLayerDiscountRestrictionRoot:getChildByName("ScrollView_624"), "UIScrollView")
	scrollView:removeAllChildren()   
	local disItem = getOnlineItems()
	local scrollItem ={}
	for key,value in pairs(disItem) do	
		local item = loadItems(value.id)
		table.insert(scrollItem,item) 
	end
	setAdapterGridView(scrollView,scrollItem,2,10)
end
----------------------------------------------------------------------
-- 初始化
LayerDiscountRestriction.init = function(rootView)
	
	mLayerDiscountRestrictionRoot = rootView
	
	--关闭按钮
	local closeBtn = tolua.cast(mLayerDiscountRestrictionRoot:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	
	--充值按钮
	local reChargeBtn = tolua.cast(mLayerDiscountRestrictionRoot:getChildByName("charge"), "UIButton")
	reChargeBtn:registerEventScript(clickChargeBtn)
	
	if DisResLogic.getBuyList() == nil then
		DisResLogic.requestBuyTimes()
	else
		loadScrollItems()
	end

	EventCenter_subscribe(EventDef["ED_DIS_BUY_SUC"],loadScrollItems) 	

end
----------------------------------------------------------------------
-- 销毁
LayerDiscountRestriction.destroy = function()
	
	mLayerDiscountRestrictionRoot = nil
	
end
----------------------------------------------------------------------
