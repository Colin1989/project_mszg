----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-09
-- Brief:	兑换界面
----------------------------------------------------------------------
local mLayerRoot = nil
local mScrollView = nil
local mExchangeList = nil
local mExchangeId = nil

LayerCommodityConvert = {}
LayerAbstract:extend(LayerCommodityConvert)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", widget:getName())
	end
end

----------------------------------------------------------------------
-- 点击兑换按钮
local function clickExchangeBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		mExchangeId = widget:getTag()
		NetLogic.requestExchangeItem(mExchangeId)
	end
end
----------------------------------------------------------------------
-- 获取所需物品数量
local function getNeedItemCount(data)
	if 1 == data.type then			-- 1.金币
		return ModelPlayer.getGold()
	elseif 5 == data.type then		-- 5.战绩
		return ModelPlayer.getPoint()
	elseif 7 == data.type then		-- 7.物品,需要查找物品表
		local item = ModelBackpack.getItemByTempId(data.temp_id)
		if item then
			return item.amount
		end
	end
	return 0
end
----------------------------------------------------------------------
-- 创建兑换选项
local function createConvertCell(exchangeItemRow, index)
	-- 背景
	local node = CommonFunc_getImgView("commodity_convert_cell_bg.png")
	-- 兑换物品
	local aimItemRow = LogicTable.getRewardItemRow(exchangeItemRow.aim_item_id)
	-- 图标
	local aimItemImageView = CommonFunc_getImgView(aimItemRow.icon)
	CommonFunc_SetQualityFrame(aimItemImageView)
	
	aimItemImageView:setTouchEnabled(true)
	local function clickSkillIcon(aimItemImageView)
		showLongInfoByRewardId(aimItemRow.id,aimItemImageView)
	end
	
	local function clickSkillIconEnd(aimItemImageView)
		longClickCallback_reward(aimItemRow.id,aimItemImageView)
	end
	UIManager.registerEvent(aimItemImageView, nil, clickSkillIcon, clickSkillIconEnd)
		
	
	--[[
	aimItemImageView:registerEventScript(function(typeName, widget)
		if "releaseUp" == typeName then
			CommonFunc_showInfo(0, exchangeItemRow.aim_item_id, 0, true)
		end
	end)
	aimItemImageView:setTouchEnabled(true)
	]]--
	aimItemImageView:setPosition(ccp(-219, 17))
	node:addChild(aimItemImageView)
	-- 数量
	local aimItemCountLabel = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	aimItemCountLabel:setScale(0.7)
	aimItemCountLabel:setAnchorPoint(ccp(1, 0))
	aimItemCountLabel:setPosition(ccp(-178, -25))
	aimItemCountLabel:setStringValue(tostring(exchangeItemRow.aim_item_amount))
	node:addChild(aimItemCountLabel)
	-- 名称
	local aimItemNameLabel = CommonFunc_getLabel(aimItemRow.name, 20)
	aimItemNameLabel:setPosition(ccp(-219, -45))
	node:addChild(aimItemNameLabel)
	-- 需要物品
	local canExchange = true
	for i=1, #(exchangeItemRow.need_items) do
		local needItemId = exchangeItemRow.need_items[i]
		local needItemCount = exchangeItemRow.need_amounts[i]
		local needItemRow = LogicTable.getRewardItemRow(needItemId)
		-- 图标
		local needItemImageView = CommonFunc_getImgView(needItemRow.icon)
		CommonFunc_SetQualityFrame(needItemImageView)
		needItemImageView:setScale(0.8)
		
		needItemImageView:setTouchEnabled(true)
		local function clickSkillIcon(needItemImageView)
			showLongInfoByRewardId(needItemId,needItemImageView)
		end
		
		local function clickSkillIconEnd(needItemImageView)
			longClickCallback_reward(needItemId,needItemImageView)
		end
		UIManager.registerEvent(needItemImageView, nil, clickSkillIcon, clickSkillIconEnd)
		
		--[[
		needItemImageView:registerEventScript(function(typeName, widget)
			if "releaseUp" == typeName then
				CommonFunc_showInfo(0, needItemId)
			end
		end)
		]]--
		
		local width = needItemImageView:getContentSize().width
		local xPos = -116 + (i-1)*(width-4)
		needItemImageView:setPosition(ccp(xPos, 17))
		node:addChild(needItemImageView)
		-- 数量背景
		local needItemCountImage = CommonFunc_getImgView("public2_bg_05.png")
		needItemCountImage:setScale9Enabled(true)
		needItemCountImage:setCapInsets(CCRectMake(5, 5, 1, 1))
		needItemCountImage:setSize(CCSizeMake(63, 27))
		needItemCountImage:setAnchorPoint(ccp(0.5, 0.5))
		needItemCountImage:setPosition(ccp(xPos, -38))
		node:addChild(needItemCountImage)
		-- 数量
		local count = getNeedItemCount(needItemRow)
		local needItemCountLabel = CommonFunc_getLabel(tostring(needItemCount), 20)
		needItemCountLabel:setPosition(ccp(xPos, -38))
		if count >= tonumber(needItemCount) then
			needItemCountLabel:setColor(ccc3(0, 255, 0))
		else
			needItemCountLabel:setColor(ccc3(255, 0, 0))
			canExchange = false
		end
		node:addChild(needItemCountLabel)
	end
	
	-- 兑换按钮
	local exchangeBtn = CommonFunc_getButton("rankexchange_buttom.png", "rankexchange_buttom.png", "rankexchange_buttom_b.png")
	exchangeBtn:setName("btn_jjc_exchange"..index)
	--print(exchangeBtn:getName())
	exchangeBtn:setTag(exchangeItemRow.id)
	exchangeBtn:registerEventScript(clickExchangeBtn)
	exchangeBtn:setPosition(ccp(224, 0))
	exchangeBtn:setTouchEnabled(canExchange)
	exchangeBtn:setBright(canExchange)
	node:addChild(exchangeBtn)
	
	-- 感叹号
	local tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
	tipIcon:setName("tip_icon_"..index)
	exchangeBtn:addChild(tipIcon)
	tipIcon:setPosition(ccp(44, 30))
	tipIcon:setVisible(canExchange)
	
	return node
end
----------------------------------------------------------------------
-- 显示列表
local function showList()
	if nil == mExchangeList then
		mExchangeList = LogicTable.getExchangeItemTable()
	end
	mScrollView:removeAllChildren()
	
	local cellArray = {}	-- 活动列表
	for key, val in pairs(mExchangeList) do
		local exchangeCell = createConvertCell(val, key)
		exchangeCell:setName("btn_jjc_exchange_bar"..key)
		if exchangeCell then
			table.insert(cellArray, exchangeCell)
		end
	end
	setAdapterGridView(mScrollView, cellArray, 1, 0)
end

----------------------------------------------------------------------
-- 
LayerCommodityConvert.isShowTip = function()
	if CopyDelockLogic.judgeYNEnterById(LIMIT_LADDERMATCH.copy_id)== true then
		local mGetTipIcon = LogicTable.getExchangeItemTable()
		for key, val in pairs(mGetTipIcon) do
			local pRet = true
			for i = 1, #(val.need_items) do
				local needItemId = val.need_items[i]
				local needItemCount = val.need_amounts[i]
				local needItemRow = LogicTable.getRewardItemRow(needItemId)
				local count = getNeedItemCount(needItemRow)
				if count < tonumber(needItemCount) then
					pRet = false
				end
			end
			if pRet then
				return true
			end
		end
	end
	return false
end 

----------------------------------------------------------------------
-- 初始化
LayerCommodityConvert.init = function(rootView)
	mLayerRoot = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 列表
	mScrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	-- 显示列表
	showList()
end
----------------------------------------------------------------------
-- 销毁
LayerCommodityConvert.destroy = function()
	mLayerRoot = nil
	mScrollView = nil
end
----------------------------------------------------------------------
-- 处理兑换物品
local function handleExchangeItem(success)
	if nil == mLayerRoot then
		return
	end
	if true == success and mExchangeId then
		showList()
		local exchangeItemRow = LogicTable.getExchangeItemRow(mExchangeId)
		CommonFunc_showItemGetInfo({exchangeItemRow.aim_item_id}, {exchangeItemRow.aim_item_amount})
	end
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_EXCHANGE_ITEM"], handleExchangeItem)

