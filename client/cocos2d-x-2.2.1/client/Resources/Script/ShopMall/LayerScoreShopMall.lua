--/**
-- *  @Brief: 积分商城
-- *  @Created by fjut on 14-04-10
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerScoreShopMall = {}
local rootNode = nil

-- 分页按钮 xml table
local m_tbRadioBtnInfo = LogicTable.getRadioDataByType("2")
-- 公告 xml table
local m_tbPostInfo = LogicTable.getPostsData()
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
-- 挑战者硬币信息
local mCoinInfo = nil
-- 单次购买数量
local m_purNum = 1
-- cell信息
local m_tbCellInfo = {}
-- 商品信息xml table
local tmpTbProductsInfo = LogicTable.getGameRankProductData()
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
		if tostring(typeId) == v.tag_id then
			table.insert(tbId, v.id)
		end
	end	
	return tbId
end

-- 购买物品返回
local function Handle_req_purchaseScoreMall(success)
	if nil == rootNode then
		return
	end
	if false == success then
		return
	end
	-- 我的积分
	local labelRewardScore = CommonFunc_getLabelByName(rootNode, "labelAtlas_score", nil, true)
    labelRewardScore:setStringValue(string.format("%d", ModelPlayer.getPoint()))
	-- 1007 为挑战者硬币ID
	mCoinInfo = ModelBackpack.getItemByTempId(1007)
	-- 我的挑战者硬币
	local labelatlas = tolua.cast(rootNode:getChildByName("labelAtlas_coin"), "UILabelAtlas")
	if mCoinInfo ~= nil then
		labelatlas:setStringValue(string.format("%d", mCoinInfo.amount))
	else
		labelatlas:setStringValue(string.format("%d", 0))
	end
end

EventCenter_subscribe(EventDef["ED_BUY_POINT_MALL_ITEM"], Handle_req_purchaseScoreMall)

-- 购买物品call
local function purCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	m_productId = tostring(sender:getTag())
	
	local tb = LogicTable.getGameRankProductInfoById(m_productId)
	tb.type = 2
	UIManager.push("UI_ShopBuy", tb)
end

-- 物品详细信息
local function showItemDetailCall(typeName, widget)
	if "releaseUp" == typeName then
		CommonFunc_showInfo(1, widget:getTag(), 0, nil, 1)
	end
end

-- 获取cell node 
local function getProductNodeById(cell, dataTable, index)
	local tbRow = LogicTable.getGameRankProductInfoById(dataTable.tbId)
	local node = UILayout:create()
	node:setSize(CCSizeMake(268, 257))
	node:setTouchEnabled(true)
	node:setTag(tonumber(tbRow.item_id))
	--node:registerEventScript(showItemDetailCall)
	--[[
	-- 物品详细信息
	local function showItemDetailCall(widget)
		local position,direct = CommonFuncJudgeInfoPosition(widget)
		local tb = {}
		tb.itemId = tbRow.item_id
		tb.position = position
		tb.direct = direct
		if tonumber(tbRow.tag_id) == 103 then 	   --是宝石	
			UIManager.push("UI_SkillFrag_Long",tb)
		elseif tonumber(tbRow.tag_id) == 102 then	--是技能
			UIManager.push("UI_ItemInfoInfo_Long",tb)
		else
			Toast.show("该商品类型不存在，需要重新配置")
		end
	end
	
	--长按结束回调
	local function longClickEnd(widget)
		if tonumber(tbRow.tag_id) == 102 then 		--是物品
			UIManager.pop("UI_ItemInfo_Long")
		elseif tonumber(tbRow.tag_id) == 103 then	--是技能
			UIManager.pop("UI_SkillFragInfo_Long")
		end
	end
	UIManager.registerEvent(node, nil, showItemDetailCall, longClickEnd)
	]]--
	
	local function clickSkillIcon(node)
		showLongInfoByRewardId(tbRow.item_id,node)
	end
	local function clickSkillIconEnd(node)
		longClickCallback_reward(tbRow.item_id,node)
	end
	UIManager.registerEvent(node, nil, clickSkillIcon, clickSkillIconEnd)
	
	-- bg
	local size = node:getSize()
	local sp = CommonFunc_getImgView("shop_cell_bg.png")
	sp:setPosition(ccp(size.width*0.5, size.height*0.5))
	node:addChild(sp)
	-- 头像
	-- local head = CommonFunc_getImgView(getItemByIdAndType(tbRow.item_id).icon)
	local head = CommonFunc_getImgView(LogicTable.getRewardItemRow(tbRow.item_id).icon)
	head:setPosition(ccp(51, 204))
	node:addChild(head)
	local quality = LogicTable.getItemById(tbRow.item_id).quality
	CommonFunc_SetQualityFrame(head, quality)
	-- 名称
	-- local nameText = getItemByIdAndType(tbRow.item_id)
	local nameText = LogicTable.getRewardItemRow(tbRow.item_id)
	local labelName
	if tonumber(tbRow.item_amount) > 1 then
		labelName = CommonFunc_getLabel(GameString.get("ShopMall_Group",nameText.name), 20) 
	else
		labelName = CommonFunc_getLabel(nameText.name, 20) 
	end
	labelName:setPosition(ccp(176, 196))
	labelName:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	node:addChild(labelName)
	-- 数量
	local labelNum = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	labelNum:setAnchorPoint(ccp(1, 0.5))
	labelNum:setStringValue(tostring(tbRow.item_amount))
	labelNum:setScale(0.6)
	labelNum:setPosition(ccp(40, -30))
	head:addChild(labelNum)
	-- 单价(积分)
	local imgWord = CommonFunc_getImgView(LogicTable.getRewardItemRow(tbRow.need_ids).icon)
	imgWord:setScale(0.4)
	imgWord:setAnchorPoint(ccp(0, 0.5))
	imgWord:setPosition(ccp(18, 112))
	node:addChild(imgWord)
	
	-- Log(LogicTable.getRewardItemRow(tbRow.need_ids))
	
	local labelPrice = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	labelPrice:setStringValue(tostring(tbRow.need_amounts))
	labelPrice:setAnchorPoint(ccp(0, 0.5))
	labelPrice:setPosition(ccp(110, 112))
	labelPrice:setScale(0.7)
	node:addChild(labelPrice)
	
	--[[
	-- 所需军衔
	local imgRank= CommonFunc_getImgView("Text_rank_01.png")
	imgRank:setAnchorPoint(ccp(0, 0.5))
	imgRank:setPosition(ccp(20, 97))
	node:addChild(imgRank)
	local labelRank
	if tbRow.need_rank == 0  then
		labelRank = CommonFunc_getLabel(GameString.get("PUBLIC_NONE"), 20)
	else
		labelRank = CommonFunc_getLabel(LogicTable.getMiltitaryRankRow(tbRow.need_rank).name, 20)
	end
	labelRank:setPosition(ccp(110, 97))
	labelRank:setAnchorPoint(ccp(0, 0.5))
	labelRank:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	node:addChild(labelRank)
	]]--
	-- 购买
	local btnPur = CommonFunc_getButton("public_newbuttom.png", "public_newbuttom.png", "public_newbuttom.png")
	btnPur:setPosition(ccp(134, 46))
	btnPur:setTag(dataTable.tbId)
	btnPur:registerEventScript(purCall)
	local btnImage = CommonFunc_getImgView("text_buy.png")
	btnPur:addChild(btnImage)
	node:addChild(btnPur)
	return node
end

-- 切换显示分页(index from 1)
local function switchLayer(layerIndex)
	local tbId = getProductIdByTypeId(m_tbRadioId[layerIndex])
	local dataTable = {}
	for key, val in pairs(tbId) do
		local dataCell = {}
		dataCell.tbId = tonumber(val)
		dataCell.layerIndex = layerIndex
		table.insert(dataTable, dataCell)
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

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	-- 关闭
	if sender:getName() == "btn_close" then
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", sender:getName())
	-- 开通vip
	elseif sender:getName() == "btn_openVip" then 
		cclog("testing, not open")
	end	
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
	-- 我的积分
	local labelRewardScore = CommonFunc_getLabelByName(rootNode, "labelAtlas_score", nil, true)
    labelRewardScore:setStringValue(string.format("%d", ModelPlayer.getPoint()))
	-- 挑战者硬币
	mCoinInfo = ModelBackpack.getItemByTempId(1007) -- 1007 为挑战者硬币ID
	local labelatlas = tolua.cast(rootNode:getChildByName("labelAtlas_coin"), "UILabelAtlas")
	if mCoinInfo ~= nil then
		labelatlas:setStringValue(string.format("%d", mCoinInfo.amount))
	else
		labelatlas:setStringValue(string.format("%d", 0))
	end
	-- 军衔显示
	-- local labelBattleResu =  CommonFunc_getNodeByName(rootNode, "Label_284", "UILabel")
	-- local miltitaryLevel = MiltitaryLogic.getMiltitaryLevel()
	-- local name = GameString.get("PUBLIC_NONE")
	-- if miltitaryLevel > 0 then
		-- local miltitaryRankRow = LogicTable.getMiltitaryRankRow(miltitaryLevel)
		-- name = miltitaryRankRow.name
	-- end
    -- labelBattleResu:setText(tostring(name))
	-- 分页按钮init
	initRadioBtn()
	-- 切换显示分页
	switchLayer(1)
end

LayerScoreShopMall.init = function(root)
	-- add gui
	rootNode = root
	if rootNode == nil then
		cclog("LayerScoreShopMall init nil") 
		return nil
	end	
	
	initUI()
	
	return rootNode
end

LayerScoreShopMall.destroy = function()
	m_tbRadioId = {}
	m_tbCellInfo = {}
	mCoinInfo = nil
	cclog("LayerScoreShopMall destroy!")
end















