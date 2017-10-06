--/**
-- *  @Brief: 商城
-- *  @Created by fjut on 14-03-27
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerShopMall = {}
local rootNode = nil

local m_postsTag = 999	--公告的

-- 分页按钮 xml table
local m_tbRadioBtnInfo = LogicTable.getRadioDataByType("1")
-- 公告 xml table
local m_tbPostInfo = LogicTable.getPostsData()
-- 商品限购次数信息
local m_tbLimitBuyTimes = {}
-- 公告内容
local m_posts = nil
-- 按钮 tag 增量
local m_radioBtnTagAdd = 10000
-- 分页layout tag 增量
local m_layerTagAdd = 20000
-- 选中的radio
local m_selectedRadioBtn = nil
-- 标签分页Id(从xml获取)
local m_tbRadioId = {}
-- 公告内容
local m_tbPostStr = {}
-- 购买物品ID
local m_productId = nil
-- 单次购买数量
local m_purNum = 1
-- cell信息
local m_tbCellInfo = {}
-- 商品信息xml table
local tmpTbProductsInfo = LogicTable.getProductData()
local m_tbProductsInfo = {}
-- 排序
function sortById(a, b)   
	return (tonumber(a.id) < tonumber(b.id))
end  
-- 标签分页排序
table.sort(m_tbRadioBtnInfo, sortById)
-- 商品信息排序
table.sort(tmpTbProductsInfo, sortById)

-- 获取物品信息
local function getItemByIdAndType(id)
	return LogicTable.getItemById(id)
end

-- 获取物品分类信息id table
local function getProductIdByTypeId(typeId)
	local tbId = {}
	for k, v in next, (m_tbProductsInfo) do
		if typeId == v.tag_id then
			table.insert(tbId, v.id)
		end
	end
	return tbId
end

-- 购买物品call
local function purCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	m_productId = tostring(sender:getTag())
	
	local tb = LogicTable.getProductInfoById(m_productId) 
	tb.type = 1
	UIManager.push("UI_ShopBuy", tb)
end

-- 获取cell node 
local function getProductNodeById(cell, data, index)
	local node = UILayout:create()
	node:setSize(CCSizeMake(268, 257))
	node:setTouchEnabled(true)
	node:setTag(tonumber(data.item_id))

	-- 物品详细信息
	local function showItemDetailCall(widget)
		local position,direct = CommonFuncJudgeInfoPosition(widget)
		local tb = {}
		tb.itemId = data.item_id
		tb.position = position
		tb.direct = direct
		if tonumber(data.tag_id) == 3 then 	   --是宝石	
			UIManager.push("UI_GemInfo_Long",tb)
		elseif tonumber(data.tag_id) == 2 then	--是物品
			UIManager.push("UI_ItemInfo_Long",tb)
		else
			Toast.show("该商品类型不存在，需要重新配置")
		end
	end
	
	--长按结束回调
	local function longClickCallback(widget)
		if tonumber(data.tag_id) == 2 then 		--是物品
			UIManager.pop("UI_ItemInfo_Long")
		elseif tonumber(data.tag_id) == 3 then	--是宝石
			UIManager.pop("UI_GemInfo_Long")
		end
	end

	UIManager.registerEvent(node, nil, showItemDetailCall, longClickCallback)
	
	-- bg
	local size = node:getSize()
	local sp = CommonFunc_getImgView("shop_cell_bg.png")
	sp:setPosition(ccp(size.width*0.5, size.height*0.5))
	node:addChild(sp)
	-- 头像
	local head = CommonFunc_getImgView(getItemByIdAndType(data.item_id).icon)
	head:setPosition(ccp(51, 204)) 
	node:addChild(head)
	local quality = LogicTable.getItemById(data.item_id).quality
	CommonFunc_SetQualityFrame(head, quality)
	-- 名称
	local nameText = getItemByIdAndType(data.item_id)
	local labelName
	if tonumber(data.item_amount) > 1 then
		labelName = CommonFunc_getLabel(GameString.get("ShopMall_Group",nameText.name), 20) 
	else
		labelName = CommonFunc_getLabel(nameText.name, 20) 
	end
	
	labelName:setPosition(ccp(176, 221))
	labelName:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	node:addChild(labelName)
	-- 数量
	local labelNum = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	labelNum:setAnchorPoint(ccp(1, 0.5))
	labelNum:setStringValue(tostring(data.item_amount))
	labelNum:setScale(0.6)
	labelNum:setPosition(ccp(40, -30))
	head:addChild(labelNum)
	-- 价格说明
	local priceDescImage = CommonFunc_getImgView("shop_text_spend.png")
	priceDescImage:setAnchorPoint(ccp(0, 0.5))
	priceDescImage:setPosition(ccp(20, 139))
	node:addChild(priceDescImage)
	local vipPriceDescImage = CommonFunc_getImgView("shop_text_spendvip.png")
	vipPriceDescImage:setAnchorPoint(ccp(0, 0.5))
	vipPriceDescImage:setPosition(ccp(20, 97))
	node:addChild(vipPriceDescImage)
	-- 货币类型 - 金币, 魔石
	local imgMoneyStr = (data.price_type == "1") and "goldicon_02.png" or "rmbicon.png"
	local imgMoneyNormal = CommonFunc_getImgView(imgMoneyStr)
	imgMoneyNormal:setPosition(ccp(130, 139))
	node:addChild(imgMoneyNormal)
	local imgMoneyVip = CommonFunc_getImgView(imgMoneyStr)
	imgMoneyVip:setPosition(ccp(130, 97))
	node:addChild(imgMoneyVip)
	-- 单价
	local labelPrice = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	labelPrice:setStringValue(tostring(data.price))
	labelPrice:setAnchorPoint(ccp(0, 0.5))
	labelPrice:setPosition(ccp(170, 139))
	labelPrice:setScale(0.7)
	node:addChild(labelPrice)
	-- vip价
	local price = (data.vip_discount == 0) and data.price or (data.price*data.vip_discount*0.01)
	labelVipPrice = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	labelVipPrice:setStringValue(string.format("%d", price))
	labelVipPrice:setAnchorPoint(ccp(0, 0.5))
	labelVipPrice:setPosition(ccp(170, 97))
	labelVipPrice:setScale(0.7)
	node:addChild(labelVipPrice)
	-- 购买
	local btnPur = CommonFunc_getButton("public_newbuttom.png", "public_newbuttom.png", "public_newbuttom.png")
	btnPur:setPosition(ccp(134, 46))
	btnPur:setTag(tonumber(data.id))
	btnPur:registerEventScript(purCall)
	local btnImage = CommonFunc_getImgView("text_buy.png")
	btnPur:addChild(btnImage)
	node:addChild(btnPur)
	-- 角标 0-不显示 1=限购、2=新品、3=推荐、4=热卖
	if tonumber(data.mark) ~= 0 then
		local tbIconName = {"shop_Decoration03.png", "shop_Decoration02.png", "shop_Decoration01.png", "shop_Decoration04.png"}
		local imgMark = CommonFunc_getImgView(tbIconName[tonumber(data.mark)])
		imgMark:setPosition(ccp(238, 226))
		node:addChild(imgMark)
	end
	return node
end

-- 切换显示分页(index from 1)
local function switchLayer(layerIndex)
	local tbId = getProductIdByTypeId(m_tbRadioId[layerIndex])
	local dataTable = {}
	for key, val in pairs(tbId) do
		local tbRow = LogicTable.getProductInfoById(val)
		if tbRow.client_show == "1" then   -- 显示
			table.insert(dataTable, tbRow)
		end
	end
	local scrollView = CommonFunc_getNodeByName(rootNode, "ScrollView_list", "UIScrollView")
	UIScrollViewEx.show(scrollView, dataTable, getProductNodeById, "V", 268, 250, 0, 2, 3, true, nil, true, true)
end

-- 分页按钮切换action
local function radioBtnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	-- 已经选中
	if m_selectedRadioBtn == sender then
	    return
	end
	m_selectedRadioBtn = sender
	for k, value in next, (m_tbRadioBtnInfo) do 
		local btn = rootNode:getChildByTag(k + m_radioBtnTagAdd)
		local nameImage = tolua.cast(btn:getChildByName("tag_name_image"), "UIImageView")
		local pos = btn:getPosition()
		if btn ~= sender then
			btn:setPosition(ccp(pos.x, 527))
			btn:setBright(true)
			nameImage:loadTexture(value.normal)
			nameImage:setPosition(ccp(0, 26))
		else
			btn:setPosition(ccp(pos.x, 529))
			btn:setBright(false)
			nameImage:loadTexture(value.current)
			nameImage:setPosition(ccp(0, 25))
		end	
	end
	switchLayer(sender:getTag() - m_radioBtnTagAdd)
end

-- 分页按钮init
local function initRadioBtn()
	if #(m_tbRadioBtnInfo) == 0 then
		cclog("radio btn tb param is bad (zero)!")
		return
	end	
	
	-- has been added
	if #(m_tbRadioId) > 0 then
		return	
	end
	
	local posX = 122
	local n = 0
	for k, v in next, (m_tbRadioBtnInfo) do
		n = n + 1
		local btn = CommonFunc_getButton("herobag_buttom_d.png", "herobag_buttom_h.png", "herobag_buttom_h.png")
		btn:setAnchorPoint(ccp(0.5, 0))
		btn:registerEventScript(radioBtnCall)
		btn:setTag(n + m_radioBtnTagAdd)
		btn:setZOrder(0)
		btn:setPosition(ccp(posX, 527))
		btn:setBright(true)
		local nameImage = CommonFunc_getImgView(v.normal)
		nameImage:setName("tag_name_image")
		nameImage:setPosition(ccp(0, 26))
		btn:addChild(nameImage)
		if n == 1 then
			btn:setPosition(ccp(posX, 529))
			btn:setBright(false)
			nameImage:loadTexture(v.current)
			nameImage:setPosition(ccp(0, 25))
			m_selectedRadioBtn = btn 
		end
		rootNode:addChild(btn)
		table.insert(m_tbRadioId, v.id)
		posX = posX + 113
	end	
end

-- 商品限购次数信息init
local function initLimitBuyTimesData()
	if #(m_tbLimitBuyTimes) > 0 then
		return
	end
	
	for k, v in next, (m_tbProductsInfo) do
		local tb = {}
		tb.id = v.id
		-- 为0不限制购买次数
		tb.buyLimitTimes = 0	
		tb.hasBuyTimes = 0
		table.insert(m_tbLimitBuyTimes, tb)
	end	
	-- 限购次数
	for k, v in next, (m_tbLimitBuyTimes) do
		local tbRow = LogicTable.getProductInfoById(v.id)
		v.buyLimitTimes = (tonumber(tbRow.buy_limit) == 0) and 1000000 or tonumber(tbRow.buy_limit)
	end	
end 

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	-- 关闭
	if sender:getName() == "btn_close" then
		LayerMain.pullPannel()
	-- 开通vip
	elseif sender:getName() == "btn_openVip" then 
		setConententPannelJosn(LayerVip, LayerVip.jsonFile, "LayerVip")
		EventCenter_post(EventDef["ED_ENTER_VIP"], LayerShopMall)
	elseif sender:getName() == "btn_recharge" then	--充值
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
		EventCenter_post(EventDef["ED_ENTER_RECHARGE"], LayerShopMall)
	end	
end
LayerShopMall.jsonFile = "ShopMall_1.json"
-- 获取公告数据
local function getPostData()
	if #(m_tbPostStr) > 0 then
		return m_tbPostStr
	end
	
	for k, v in next, (m_tbPostInfo) do
		local tb = {}
		local tbRow = LogicTable.getPostsInfoById(v.id)
		tb.msg = tbRow.text
		tb.priority = 3
		tb.times_left = 1
		if tbRow.display == "1" then
			table.insert(m_tbPostStr, tb)
		end
	end	
	
	return m_tbPostStr
end

local function getIsProfessionMatch(profession)
	local role = (ModelPlayer.getRoleType() == 0) and 0 or ModelPlayer.getRoleType()
	local tbArr = CommonFunc_split(profession, ",")
	for k = 1, #(tbArr), 1 do
		if tonumber(tbArr[k]) == 0 or tonumber(tbArr[k]) == role then
			return true
		end
	end
	
	return false
end

local  function  morePost(imgPostBg,postTag,msgTb,contentSize, duration, offsetTime, fontSize, fontColor, fontName)
	local layout = imgPostBg:getChildByName("post_panel")
	local label = tolua.cast(imgPostBg:getChildByTag(postTag),"UILabel")

	if layout == nil then
		-- layout
		layout = UILayout:create()
		layout:setSize(contentSize)
		layout:setName("post_panel")
		layout:setClippingEnabled(true)
		--layout:setBackGroundColor(ccc3(165,42,44))
		--layout:setBackGroundColorType(LAYOUT_COLOR_SOLID)
		layout:setPosition(ccp(5,4))
		-- label
		label = CommonFunc_getLabel(msgTb[1].msg, fontSize, fontColor, fontName)
		label:setAnchorPoint(ccp(0, 0.5))
		label:setPosition(ccp(layout:getSize().width, layout:getSize().height*0.5))
		label:setTag(postTag)
		label:setSize(CCSizeMake(100,27))
		label:setTextHorizontalAlignment(kCCTextAlignmentLeft)
		tolua.cast(label,"UILabel")
		layout:addChild(label)
		imgPostBg:addChild(layout)		
	end
	
	if label ~= nil then
		label:setText(msgTb[1].msg)
		label:setAnchorPoint(ccp(0,0.5))
		label:setPosition(ccp(layout:getSize().width, layout:getSize().height*0.5))	
	end

	local actionArr = CCArray:create()
	for key,value in pairs(msgTb) do
		m_isBroading = true
		local offset = 20
		local size = CCSizeMake(imgPostBg:getSize().width , imgPostBg:getSize().height)
		-- default value
		contentSize = (contentSize == nil) and CCSizeMake(640, 50) or contentSize
		local perDt = 4.5
		local dt 	= (contentSize.width > label:getSize().width) and perDt or label:getSize().width*1.5*perDt/contentSize.width
		duration 	= (duration == nil) and dt or duration
		offsetTime 	= (offsetTime == nil) and 5.0 or offsetTime
		-- action
		local function actionCall(pSender)
			if key == #msgTb then
				label:setText(msgTb[1].msg)
			else
				label:setText(msgTb[key+1].msg)
			end
			label:setAnchorPoint(ccp(0,0.5))
			label:setPosition(ccp(layout:getSize().width, layout:getSize().height*0.5))
		end
		local action1 = CCMoveBy:create(duration, ccp(-(label:getSize().width + layout:getSize().width+100), 0))
		local action2 = CCSequence:createWithTwoActions(action1, CCCallFuncN:create(actionCall)) 
		actionArr:addObject(action1)
		actionArr:addObject(action2)
	end
	local action  = CCRepeatForever:create(CCSequence:create(actionArr))
	label:runAction(action)
end

local function initUI()
	m_tbProductsInfo = {}
	for k = 1, #(tmpTbProductsInfo), 1 do
		local lv = (ModelPlayer.getLevel() == 0) and 0 or ModelPlayer.getLevel()
		if getIsProfessionMatch(tmpTbProductsInfo[k].profession) and lv >= tonumber(tmpTbProductsInfo[k].level) then
			table.insert(m_tbProductsInfo, tmpTbProductsInfo[k])
		end
	end
	
	m_tbCellInfo = {}
	-- 关闭btn event
	local btnClose = CommonFunc_getNodeByName(rootNode, "btn_close", "UIButton")
    btnClose:registerEventScript(btnCall)	
	-- 开通vip
	local btnVip = CommonFunc_getNodeByName(rootNode, "btn_openVip", "UIButton")
    btnVip:registerEventScript(btnCall)
	-- 充值
	local btnRecharge = CommonFunc_getNodeByName(rootNode, "btn_recharge", "UIButton")
	btnRecharge:registerEventScript(btnCall)
	-- 公告
	local imgPostBg = CommonFunc_getNodeByName(rootNode, "img_postBg", "UIImageView") 
	imgPostBg:setAnchorPoint(ccp(0,0))
	imgPostBg:setPosition(ccp(-170,243))
	
	morePost(imgPostBg,m_postsTag,getPostData(),CCSizeMake(450, 32), nil, 2.0, 25)

	-- 分页按钮init
	initRadioBtn()
	
	-- 商品限购次数信息init
	initLimitBuyTimesData()
	
	-- 切换显示分页
	switchLayer(1)
end

-- 获取商品的剩余购买次数
LayerShopMall.getLastPurchaseTimesById = function(id)
	local times = 0
	for k, v in next, (m_tbLimitBuyTimes) do
	    if v.id == id then
			times = v.buyLimitTimes - v.hasBuyTimes
			break
		end
	end	
	
	return times
end

-- 更新商品剩余购买次数
LayerShopMall.setLastPurchaseTimesById = function(id, num)
	for k, v in next, (m_tbLimitBuyTimes) do
	    if v.id == id then 
			num = ( (num == nil) or (type(num) ~= "number") ) and 0 or num
			v.hasBuyTimes = v.hasBuyTimes + num
			break
		end
	end	
end

-- net rec 已购商品次数
local function Handle_req_hasBuyTimes(resp)
	if nil == rootNode then
		return
	end
	local tbMsg = resp.buy_info_list
	if #tbMsg <= 0 then
		return
	end
	-- 商品已经购买次数
	local function getTimes(id)
		local times = 0
		for k1, v1 in next, (tbMsg) do
			if v1.mallitem_id == id then
				times = tonumber(v1.times)
				break
			end
		end	
		
		return times
	end
	-- 限购次数
	for k, v in next, (m_tbLimitBuyTimes) do
		local tbRow = LogicTable.getProductInfoById(v.id)
		v.hasBuyTimes = getTimes(tonumber(v.id))
	end	
end

-- net 请求
local function netReq()
	-- 商品购买数量
	local tb = req_has_buy_times()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_has_buy_times"]) 
end
	
LayerShopMall.init = function(root)
	-- add gui
	rootNode = root
	if rootNode == nil then
		cclog("LayerShopMall init nil") 
		return nil
	end	
	
	initUI()
	netReq()
	
	return rootNode
end

LayerShopMall.destroy = function()
	rootNode = nil
	m_tbRadioId = {}
	m_tbCellInfo = {}
	cclog("LayerShopMall destroy!")
end

NetSocket_registerHandler(NetMsgType["msg_notify_has_buy_times"], notify_has_buy_times, Handle_req_hasBuyTimes)












