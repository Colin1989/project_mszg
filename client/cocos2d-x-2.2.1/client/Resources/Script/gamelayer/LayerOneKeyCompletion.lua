----------------------------------------------------------------------
-- 作者：songcy
-- 描述：一键补全
----------------------------------------------------------------------

LayerOneKeyCompletion = {}

local rootView = nil
local dataCell = nil
local equipmentTable = {}
local productTable = {}
local mProductId = nil
local mIsRemain = nil
local mIsTimes = nil

-- 获取物品信息
local function getItemByIdAndType(id)
	return LogicTable.getItemById(id)
end

-- 点击关闭按钮
local function clickCloseBtn()
	UIManager.pop("UI_OneKeyCompletion")
end



local function enterToCopy()
	local passCopyTb = CopyDateCache.getInfo()

end 

local function getAllPay()
	if productTable == nil then
		return
	end
	local allPay = 0
	if ModelPlayer.getVipLevel() > 0 then
		for k, v in pairs(productTable) do
			local tbRow = LogicTable.getProductInfoById(v.id)
			local price = (tbRow.vip_discount == 0) and tbRow.price or (tbRow.price*tbRow.vip_discount*0.01)
			allPay = allPay + (price * v.times)
		end
	else
		for k, v in pairs(productTable) do
			local tbRow = LogicTable.getProductInfoById(v.id)
			local price = tonumber(tbRow.price)
			allPay = allPay + (price * v.times)
		end
	end
	return allPay
end

-- btn确认
local function dialogSureCall()
	mIsTimes = #productTable
	for k, v in pairs(productTable) do
		NetLogic.requestBuyMallItem(v.id, v.times)
	end
end

-- 一键补齐
local function clickAllPayCall()
	local strDesc = GameString.get("ShopMall_TIPS_MS_FAIL")
	local allPay = getAllPay()
	if CommonFunc_payConsume(2, allPay) then
		return
	end
	local str = "ONE_KEY_BUY_ALL"
	local diaMsg = 
	{
		strText = string.format(GameString.get(str, allPay)),
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end

--
local function onClick(typeName, widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		if widgetName == "Button_cancle" then
			clickCloseBtn()
		elseif widgetName == "Button_sure" then
			clickAllPayCall()
		end
	end
end

-- 单独补齐
local function clickOnePayCall(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local dataId = tostring(widget:getTag())
	mIsRemain = true
	mProductId = nil
	for k, v in pairs(productTable) do
		if v.id == dataId then
			mProductId = v.id
			local tbRow = LogicTable.getProductInfoById(v.id)
			local strDesc = (tbRow.price_type == "1") and GameString.get("ShopMall_TIPS_JB_FAIL") or GameString.get("ShopMall_TIPS_MS_FAIL")
			local onePay = 0
			if ModelPlayer.getVipLevel() > 0 then
				local price = (tbRow.vip_discount == 0) and tbRow.price or (tbRow.price*tbRow.vip_discount*0.01)
				onePay = price * v.times
			else
				local price = tonumber(tbRow.price)
				onePay = price * v.times
			end
			if CommonFunc_payConsume(2, onePay) then
				return
			end
			
			local function dialogPayCall()
				NetLogic.requestBuyMallItem(v.id, v.times)
				if #productTable == 1 then
					mIsRemain = false
				-- else
					-- table.remove(productTable, k)
				end
			end
			
			local str = (tbRow.price_type == "1") and "ShopMall_BUY1_TIPS" or "ShopMall_BUY_TIPS"
			local diaMsg = 
			{
				strText = string.format(GameString.get(str, onePay, getItemByIdAndType(tbRow.item_id).name)),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {dialogPayCall, nil}
			}
			UIManager.push("UI_ComfirmDialog", diaMsg)
		end
	end
end

-- 副本获取
local function clickGainCall(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local dataId = tostring(widget:getTag())
	local tbRow = LogicTable.getProductInfoById(dataId)
	local widgetName = widget:getName()
	local AllGroup = LogicTable.getAllCopyGroup()
	if tbRow.item_sources == "1" then			-- 普通副本界面/宝石
		for key, val in pairs(AllGroup) do
			local status = CopyDateCache.getGroupStatusById(val.id)
			if val.type == "1" and status == "doing" then
				setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
				LayerCopy.createCopyGroupByMode(1) --1:普通副本群
				LayerCopy.create_CopyByMode(val.id)
				break
			end
			if key == #AllGroup then
				setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
				LayerCopy.createCopyGroupByMode(1) --1:普通副本群
				LayerCopy.create_CopyByMode(118)
			end
		end
	elseif tbRow.item_sources == "2" then		-- 精英副本界面/蓝色材料
		for key, val in pairs(AllGroup) do
			local status = CopyDateCache.getGroupStatusById(val.id)
			if val.type == "2" and status == "doing" then
				setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
				LayerCopy.createCopyGroupByMode(2) --1:普通副本群
				LayerCopy.create_CopyByMode(val.id)
				break
			end
			if key == #AllGroup then
				setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
				LayerCopy.createCopyGroupByMode(2) --1:普通副本群
				LayerCopy.create_CopyByMode(218)
			end
		end
	elseif tbRow.item_sources == "3" then		-- BOSS副本界面/紫色材料
		if CopyDateCache.getCopyStatus(LIMIT_ENTER_BOSS.copy_id) ~= "pass" and tonumber(LIMIT_ENTER_BOSS.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ENTER_BOSS.copy_id),LIMIT_ENTER_BOSS.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
        setConententPannelJosn(LayerChenallBoss,LayerChenallBoss.josnFile,LayerChenallBoss.josnFile)
		-- UIManager.pop("UI_OneKeyCompletion")
	elseif tbRow.item_sources == "4" then		-- 活动副本界面/橙色材料
		if CopyDateCache.getCopyStatus(LIMIT_ACTIVITY_COPY.copy_id) ~= "pass" and tonumber(LIMIT_ACTIVITY_COPY.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ACTIVITY_COPY.copy_id),LIMIT_ACTIVITY_COPY.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerActivityCopyGroup, "ActivityCopyGroup.json", widgetName)
		-- UIManager.pop("UI_OneKeyCompletion")
	elseif tbRow.item_sources == "5" then		-- 装备副本界面/重铸材料
		setConententPannelJosn(LayerBackpack,"Backpack_Main.json",weightName)
		LayerBackpack.switchTag("Button_Equip")
		LayerBackpack.switchUILayer("UI_equip_body")
	else
		-- widget:setTouchEnabled(false)
		-- widget:setVisible(false)
	end
	UIManager.pop("UI_OneKeyCompletion")
	if UIManager.getTopLayerName() == "UI_Smith_upGrade" then
		UIManager.pop("UI_Smith_upGrade")
	end
end

local function getProductNodeById(cell, data, index)
	if nil == dataCell then
		dataCell = GUIReader:shareReader():widgetFromJsonFile("OneKeyCompletion_2.json")
	end
	local mCell = dataCell:clone()
	dataCell:retain()
	
	-- 头像
	local head = CommonFunc_AddGirdWidget(data.item_id, 0, 0, nil, mCell:getChildByName("ImageView_head"))
	
	-- 名称
	local labelName = tolua.cast(mCell:getChildByName("Label_name"), "UILabel")
	labelName:setText(getItemByIdAndType(data.item_id).name)
	
	-- 数量
	local labelNum = tolua.cast(mCell:getChildByName("Label_num"), "UILabel")
	local amount = data.item_amount * data.times
	labelNum:setText(tostring(amount))
	
	-- 价格
	local labelPay = tolua.cast(mCell:getChildByName("Label_pay"), "UILabel")
	local pay = 0
	if ModelPlayer.getVipLevel() > 0 then
		local price = (data.vip_discount == 0) and data.price or (data.price*data.vip_discount*0.01)
		pay = price * data.times
	else
		local price = tonumber(data.price)
		pay = price * data.times
	end
	labelPay:setText(tostring(pay))
	
	-- 单独补齐
	local btnPay = tolua.cast(mCell:getChildByName("Button_pay"), "UIButton")
	btnPay:setTag(data.id)
	btnPay:registerEventScript(clickOnePayCall)
	btnPay:setTouchEnabled(true)
	
	-- 副本获得
	local btnGain = tolua.cast(mCell:getChildByName("Button_gain"), "UIButton")
	btnGain:setTag(data.id)
	local tbRow = LogicTable.getProductInfoById(data.id)
	if tbRow.item_sources == "5" then			-- 重铸材料
		local gainImage = tolua.cast(mCell:getChildByName("ImageView_72"), "UIImageView")
		gainImage:loadTexture("text_fenjiezhuangbei.png")
	end
	if tbRow.item_sources == "0" then			-- 
		btnGain:setTouchEnabled(false)
		btnGain:setVisible(false)
	else
		btnGain:registerEventScript(clickGainCall)
		btnGain:setTouchEnabled(true)
	end
	
	return mCell
end

-- 
local function initUI()
	-- 退出
	local cancleBtn = rootView:getWidgetByName("Button_cancle")
	cancleBtn:registerEventScript(onClick)
	-- 一键补齐
	local sureBtn = rootView:getWidgetByName("Button_sure")
	sureBtn:registerEventScript(onClick)
	-- 总价
	local labelAllPay = tolua.cast(rootView:getWidgetByName("Label_allpay"), "UILabel")
	labelAllPay:setText(tostring(getAllPay()))
end

-- 购买物品返回
local function Handle_req_oneKeyForPay(success)
	if nil == rootView then
		return
	end
	if false == success then
		return
	end
	
	mIsTimes = mIsTimes - 1
	if mIsRemain == false or mIsTimes == 0 then
		for k, v in pairs(productTable) do
			if k == 1 then
				Toast.show(GameString.get("ShopMall_PUR_GET", getItemByIdAndType(v.item_id).name, v.item_amount*v.times))
				-- 更新购买次数
				LayerShopMall.setLastPurchaseTimesById(v.id, v.times)
				mProductId = nil
			end
		end
		UIManager.pop("UI_OneKeyCompletion")
	elseif mIsRemain == true then
		for k, v in pairs(productTable) do
			if mProductId == nil and k == mIsTimes + 1 then
				Toast.show(GameString.get("ShopMall_PUR_GET", getItemByIdAndType(v.item_id).name, v.item_amount*v.times))
				LayerShopMall.setLastPurchaseTimesById(v.id, v.times)
			elseif mProductId ~= nil and mProductId == v.id then
				Toast.show(GameString.get("ShopMall_PUR_GET", getItemByIdAndType(v.item_id).name, v.item_amount*v.times))
				-- 更新购买次数
				LayerShopMall.setLastPurchaseTimesById(v.id, v.times)
				table.remove(productTable, k)
				mProductId = nil
				break
			end
		end
		
		local scrollView = tolua.cast(rootView:getWidgetByName("ScrollView_list"), "UIScrollView")
		UIScrollViewEx.show(scrollView, productTable, getProductNodeById, "V", 478, 133, 0, 1, 3, true, nil, true, true)
		initUI()
	end
	EventCenter_post(EventDef["ED_UPDATE_FOR_ONE_KEY"], success)
end

-- 列表
local function initProduct(tb)
	-- local tmpTbProductsInfo = LogicTable.getProductData()
	local tmpTbProductsInfo = LogicTable.getAllProductInfo()
	mIsRemain = true
	productTable = {}
	for k, v in pairs(tb) do
		local num = ModelBackpack.getItemByTempId(v.id)
		num = (num == nil) and 0 or tonumber(num.amount)
		if num < v.amount then
			for key, value in pairs(tmpTbProductsInfo) do
				if value.item_id == v.id then
					local temp = {}
					temp = value
					temp.times = math.ceil((v.amount - num) / tonumber(value.item_amount))
					table.insert(productTable, temp)
				end
			end
		end
	end
	mIsTimes = #productTable
	local scrollView = tolua.cast(rootView:getWidgetByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, productTable, getProductNodeById, "V", 478, 133, 0, 1, 3, true, nil, true, true)
	initUI()
end

-- 商品表中是否存在该物品
LayerOneKeyCompletion.isExists = function(tb)
	-- local tmpTbProductsInfo = LogicTable.getProductData()
	local tmpTbProductsInfo = LogicTable.getAllProductInfo()
	for k, v in pairs(tb) do
		local num = ModelBackpack.getItemByTempId(v.id)
		num = (num == nil) and 0 or tonumber(num.amount)
		if num < v.amount then
			for key, value in pairs(tmpTbProductsInfo) do
				if value.item_id == v.id then
					return true
				end
			end
		end
	end
	return false
end

-- tb
LayerOneKeyCompletion.init = function(tb)
	rootView =  UIManager.findLayerByTag("UI_OneKeyCompletion")
	initProduct(tb)
end

LayerOneKeyCompletion.destroy = function()
	rootView = nil
end

EventCenter_subscribe(EventDef["ED_BUY_MALL_ITEM"], Handle_req_oneKeyForPay)