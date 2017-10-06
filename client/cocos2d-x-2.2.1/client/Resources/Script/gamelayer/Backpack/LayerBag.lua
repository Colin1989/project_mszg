LayerBag = {}

-- 背包数据
local mCurData = {}
-- 数据类型("equip",装备;"gem",宝石;"item",物品)
local mCurDataType = "equip"
-- 背包最大容量
local mGridMaxCount = 100
-- 点击模式:1.查看信息;2.选中状态(无类型限制);3.选中状态(只能选中装备)
local mClickMode = 1
-- 多选模式下,被选中的格子
local mSelectGrid = {}
-- 背包根节点
local mLayerRoot = nil
-- 备份按钮坐标,批量面板
local mBtnPos = {}
-- 一键选取标识
local mOneKeySelected = false
----------------------------------------------------------------------
-- 更新装备数据
local function updateEquipData()
	-- 装备排序函数
	local function sortEquip(a, b)
		-- 装备类型 -> 装备等级 -> 强化等级 -> 品质 -> 战斗力
		local aEquip = ModelEquip.getEquipInfo(a.id, true)
		local bEquip = ModelEquip.getEquipInfo(b.id, true)
		if nil == aEquip or nil == bEquip then
			return a.id < b.id
		end
		local aCanEquip = ModelEquip.canEquipPuton(a.itemid)
		local bCanEquip = ModelEquip.canEquipPuton(b.itemid)
		if aCanEquip == bCanEquip then
			if aEquip.equip_level == bEquip.equip_level then
				if aEquip.strengthen_level == bEquip.strengthen_level then
					if aEquip.item_row.quality == bEquip.item_row.quality then
						return aEquip.combat_effectiveness > bEquip.combat_effectiveness
					end
					return aEquip.item_row.quality > bEquip.item_row.quality
				end
				return aEquip.strengthen_level > bEquip.strengthen_level
			end
			return aEquip.equip_level > bEquip.equip_level
		end
		return aCanEquip < bCanEquip
	end
	-- 装备数据获取及排序
	local equipData, otherData = {}, {}
	local packData = ModelBackpack.getPack()
	for key, val in pairs(packData) do
		if item_type["equipment"] == val.itemtype then
			table.insert(equipData, val)
		else
			table.insert(otherData, val)
		end
	end
	table.sort(equipData, sortEquip)
	table.sort(otherData, function(a, b) return a.id < b.id end)
	return CommonFunc_joinArray(equipData, otherData)
end
----------------------------------------------------------------------
-- 更新宝石数据
local function updateGemData()
	-- 宝石数据获取及排序
	local gemData, otherData = {}, {}
	local packData = ModelBackpack.getPack()
	for key, val in pairs(packData) do
		if item_type["gem"] == val.itemtype then
			table.insert(gemData, val)
		else
			table.insert(otherData, val)
		end
	end
	table.sort(gemData, function(a, b) return a.itemid > b.itemid end)
	table.sort(otherData, function(a, b) return a.id < b.id end)
	return CommonFunc_joinArray(gemData, otherData)
end
----------------------------------------------------------------------
-- 更新背包数据
local function updateData(dataType)
	local curData = {}
	if "equip" == dataType then
		curData = updateEquipData()
	elseif "gem" == dataType then
		curData = updateGemData()
	elseif "item" == dataType then
		curData = ModelBackpack.getPack()
	end
	mCurData = CommonFunc_TableConverNumIndex(curData)
	for i=1, mGridMaxCount - #mCurData do
		table.insert(mCurData, "null")
	end
end
----------------------------------------------------------------------
-- 获得背包宝石数据
LayerBag.getGemData = function()
	updateData("gem")
	return mCurData
end
----------------------------------------------------------------------
-- 获取选择列表
function LayerBag.getSelectTable()
	local instIdCache = {}
	if nil == mSelectGrid then
		return instIdCache
	end
	for key, val in pairs(mSelectGrid) do
		table.insert(instIdCache, key)
	end
	return instIdCache
end
----------------------------------------------------------------------
-- 清除选择列表
local function clearSelectTable()
	for key, val in pairs(mSelectGrid) do
		if val.widget then
			val.widget:setVisible(false)
		end
	end
	mSelectGrid = {}
end
----------------------------------------------------------------------
-- 选中格子
local function selectGrid(instId, index, gridImage, isBatch)
	if nil == mSelectGrid[instId] then
		mCurData[index].isSelected = true
		local param = {}
		param.isBatch = isBatch
		param.instId = instId
		param.data = mCurData[index]
		mSelectGrid[instId] = {}
		if gridImage then
			local selectImage = gridImage:getChildByName("select_tick_image")
			selectImage:setVisible(true)
			mSelectGrid[instId].widget = selectImage
		end
		EventCenter_post(EventDef["ED_SELECT_BAG_GRID"], param)
	else
		if gridImage then
			local selectImage = gridImage:getChildByName("select_tick_image")
			selectImage:setVisible(true)
			mSelectGrid[instId].widget = selectImage
		end
	end
end
----------------------------------------------------------------------
-- 取消选中格子
local function unselectGrid(instId, index, isBatch)
	if mSelectGrid[instId] then
		mCurData[index].isSelected = false
		local param = {}
		param.isBatch = isBatch
		param.instId = instId
		param.data = mCurData[index]
		if mSelectGrid[instId].widget then
			mSelectGrid[instId].widget:setVisible(false)
		end
		mSelectGrid[instId] = nil
		EventCenter_post(EventDef["ED_SELECT_BAG_GRID"], param)
	end
end
----------------------------------------------------------------------
-- 设置格子选中状态
local function setGridSelectStatus(instId, index, gridImage)
	if nil == mSelectGrid[instId] then		-- 选中
		selectGrid(instId, index, gridImage, false)
	else									-- 取消选中
		unselectGrid(instId, index, false)
	end
end
----------------------------------------------------------------------
-- 更改点击模式:1.查看信息;2.选中状态(无类型限制);3.选中状态(只能选中装备)
local function changeClickMode(modeType)
	mClickMode = modeType
	clearSelectTable()
end
----------------------------------------------------------------------
-- 根据标签类型显示相应的控件
local function showWidgetByType(dataType)
	local girdCountLabel = tolua.cast(mLayerRoot:getChildByName("Label_GridCount"), "UILabelAtlas")
	local batchOkBtn = mLayerRoot:getChildByName("Button_batch_ok")
	local batchCancelBtn = mLayerRoot:getChildByName("Button_batch_cancle")
	local batchSellBtn = mLayerRoot:getChildByName("Button_batch_sell")
	--local batcnDecomposeBtn = mLayerRoot:getChildByName("Button_batch_decompose")
	CommonFunc_SetWidgetTouch(batchOkBtn, false)
	CommonFunc_SetWidgetTouch(batchCancelBtn, false)
	changeClickMode(1)
	local str = string.format("%d/%d", ModelBackpack.getCount(), ModelPlayer.getPackSpace())
	girdCountLabel:setStringValue(str)
	CommonFunc_SetWidgetTouch(girdCountLabel, true)
	CommonFunc_SetWidgetTouch(batchSellBtn, true)
	if "equip" == dataType then	-- 装备标签
		--CommonFunc_SetWidgetTouch(batcnDecomposeBtn, true)
	else						-- 非装备标签
		CommonFunc_SetWidgetTouch(batcnDecomposeBtn, false)
	end
	if "gem" == dataType or "item" == dataType then
		batchSellBtn:setPosition(ccp(360, mBtnPos["batch_sell_btn"].y))
	else
		batchSellBtn:setPosition(mBtnPos["batch_sell_btn"])
	end
end
----------------------------------------------------------------------
-- 批量操作面板显示动画,batchMode:1.出售,2.分解
local function batchPanelShowAction(batchMode)
	local batchOkBtn = tolua.cast(mLayerRoot:getChildByName("Button_batch_ok"), "UIButton")
	local batchOkImage = tolua.cast(mLayerRoot:getChildByName("ImageView_7420"), "UIImageView")
	if 1 == batchMode then
		batchOkImage:loadTexture("text_sell.png")
	elseif 2 == batchMode then
		batchOkImage:loadTexture("text_fenjie.png")
	end
	CommonFunc_SetWidgetTouch(batchOkBtn, true)
	local batchCancelBtn = mLayerRoot:getChildByName("Button_batch_cancle")
	CommonFunc_SetWidgetTouch(batchCancelBtn, true)
	local batchSellBtn = mLayerRoot:getChildByName("Button_batch_sell")
	CommonFunc_SetWidgetTouch(batchSellBtn, false)
	--local batchDecomposeBtn = mLayerRoot:getChildByName("Button_batch_decompose")
	--CommonFunc_SetWidgetTouch(batchDecomposeBtn, false)
end
----------------------------------------------------------------------
-- 批量操作面板隐藏动画
local function batchPanelHideAction()
	local batchOkBtn = mLayerRoot:getChildByName("Button_batch_ok")
	CommonFunc_SetWidgetTouch(batchOkBtn, false)
	local batchCancelBtn = mLayerRoot:getChildByName("Button_batch_cancle")
	CommonFunc_SetWidgetTouch(batchCancelBtn, false)
	local batchSellBtn = mLayerRoot:getChildByName("Button_batch_sell")
	CommonFunc_SetWidgetTouch(batchSellBtn, true)
	--local batchDecomposeBtn = mLayerRoot:getChildByName("Button_batch_decompose")
	--CommonFunc_SetWidgetTouch(batchDecomposeBtn, true)
	showWidgetByType(mCurDataType)
end
----------------------------------------------------------------------
-- 分页切换动画
local function switchButtonAction(widget, index)
	local dTime = (index - 1)%5 + 1
	-- 原始坐标备份
	local posBack = ccp(widget:getPosition().x, widget:getPosition().y)
	widget:setPosition(ccp(posBack.x + 800, posBack.y))
	local action = CCMoveTo:create(0.2 + dTime*0.1, posBack)
	widget:runAction(action)
end
----------------------------------------------------------------------
-- 播放格子进入动画
local function playGridAction(grids)
	for i=1, 10 do
		if grids[i] then
			switchButtonAction(grids[i], i)
		end
	end
end
----------------------------------------------------------------------
-- 确认出售
local function sureSell()
	local instIdCache = LayerBag.getSelectTable()
	if 0 == #instIdCache then
		Toast.Textstrokeshow(GameString.get("BAG_STR_01"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	LayerBackpack.seedSellItems(instIdCache)
end
----------------------------------------------------------------------
-- 确认分解
local function sureDecompose()
	local instIdCache = LayerBag.getSelectTable()
	if 0 == #instIdCache then
		Toast.Textstrokeshow(GameString.get("BAG_STR_02"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	BackpackLogic.requestEquipmentResolve(instIdCache)
end
----------------------------------------------------------------------
-- 点击出售面板按钮
local function clickSellPanelButtons(btnName)
	if "Button_batch_ok" == btnName then				-- 确认
		if 2 == mClickMode then
			sureSell()
		elseif 3 == mClickMode then
			sureDecompose()
		end
	elseif "Button_batch_cancle" == btnName then		-- 取消
		changeClickMode(1)
		batchPanelHideAction()
	elseif "Button_batch_sell" == btnName then			-- 出售多个
		changeClickMode(2)
		batchPanelShowAction(1)
	elseif "Button_batch_decompose" == btnName then		-- 分解多个
		changeClickMode(3)
		batchPanelShowAction(2)
	end
end
----------------------------------------------------------------------
-- 点击事件
local function onClickEvent(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		if "Button_batch_ok" == widgetName then					-- 确认
			clickSellPanelButtons(widgetName)
		elseif "Button_batch_cancle" == widgetName then			-- 取消
			clickSellPanelButtons(widgetName)
		elseif "Button_batch_sell" == widgetName then			-- 出售多个
			clickSellPanelButtons(widgetName)
		elseif "Button_batch_decompose" == widgetName then		-- 分解多个
			--clickSellPanelButtons(widgetName)
		end
	end
end

----------------------------------------------------------------------
-- 初始化
function LayerBag.init(root)
	mLayerRoot = root
	mCurDataType = "equip"
	mGridMaxCount = ModelPlayer.getPackSpace()
	mSelectGrid = {}
	mBtnPos = {}
	-- 批量操作确定按钮
	local batchOkBtn = mLayerRoot:getChildByName("Button_batch_ok")
	batchOkBtn:registerEventScript(onClickEvent)
	CommonFunc_SetWidgetTouch(batchOkBtn, false)
	mBtnPos["batch_ok_btn"] = CommonFunc_GetPos(batchOkBtn)
	-- 批量操作取消按钮
	local batchCancelBtn = mLayerRoot:getChildByName("Button_batch_cancle")
	batchCancelBtn:registerEventScript(onClickEvent)
	CommonFunc_SetWidgetTouch(batchCancelBtn, false)
	mBtnPos["batch_cancel_btn"] = CommonFunc_GetPos(batchCancelBtn)
	-- 批量出售按钮
	local batchSellBtn = mLayerRoot:getChildByName("Button_batch_sell")
	batchSellBtn:registerEventScript(onClickEvent)
	CommonFunc_SetWidgetTouch(batchSellBtn, true)
	mBtnPos["batch_sell_btn"] = CommonFunc_GetPos(batchSellBtn)
	-- 批量分解按钮
	--local batchDecomposeBtn = mLayerRoot:getChildByName("Button_batch_decompose")
	--batchDecomposeBtn:registerEventScript(onClickEvent)
	--CommonFunc_SetWidgetTouch(batchDecomposeBtn, true)
	--mBtnPos["batch_decompose_btn"] = CommonFunc_GetPos(batchDecomposeBtn)
	-- 格子列表
	local scrollview = tolua.cast(mLayerRoot:getChildByName("ScrollView_Backups"), "UIScrollView")
	CommonFunc_SetWidgetTouch(scrollview, false)
end
----------------------------------------------------------------------
-- 销毁
function LayerBag.destroy()
	mLayerRoot = nil
end
----------------------------------------------------------------------
-- 点击背包格子
local function clickGrid(widget, index, dataType)
	TipModule.onMessage("click_bag_grid", index)
	local itemData = mCurData[index]
	local instId = itemData.id
	local itemId = itemData.itemid
	if 1 == mClickMode then			-- 查看信息
		local param = {}
		param.id = instId
		param.itemID = itemId
		param.enterType = "roleinfo"	-- 入口类型(从符文信息界面进入)
		-- 点击装备格子
		if "equip" == dataType and item_type["equipment"] == itemData.itemtype then
			UIManager.push("UI_Equip_Noput",param)
		end
		-- 点击宝石格子
		if "gem" == dataType and item_type["gem"] == itemData.itemtype then
			LayerBackpack.switchUILayer("UI_gemCompound", param)
		end
		-- 点击物品格子
		if "item" == dataType then
			if item_type["equipment"] == itemData.itemtype then
				UIManager.push("UI_Equip_Noput",param)
			elseif item_type["gem"] == itemData.itemtype then
				LayerBackpack.switchUILayer("UI_gemCompound", param)
			else	-- item_type["varia"],item_type["props"],item_type["material"],item_type["rand_props"]
				LayerBackpack.switchUILayer("UI_item_info_new", param)
			end
		end
	elseif 2 == mClickMode then		-- 选中状态(无类型限制)
		setGridSelectStatus(instId, index, widget)
	elseif 3 == mClickMode then		-- 选中状态(只能选中装备)
		if item_type["equipment"] == itemData.itemtype then
			setGridSelectStatus(instId, index, widget)
		end
	end
end
----------------------------------------------------------------------
-- 设置装备格子
local function setEquipGrid(equip, widget)
	if nil == equip then
		widget:setColor(ccc3(140, 140, 140))
		return
	end
	-- 不可穿戴
	if 0 ~= ModelEquip.canEquipPuton(equip.id) then
		widget:setColor(ccc3(255, 50, 50))
	end
	-- 显示是否新获取装备标识
	local showNewAppend = true == LayerBackpack.isNewAppendEquip(equip.instid)
	local newAppendImage = widget:getChildByName("UIImageView_newAppend")
	if true == showNewAppend and nil == newAppendImage then
		newAppendImage = CommonFunc_getImgView("uiiteminfo_newzhuangbei.png")
		newAppendImage:setName("UIImageView_newAppend")
		newAppendImage:setPosition(ccp(10, -25))
		widget:addChild(newAppendImage)
	end
	if newAppendImage then
		newAppendImage:setVisible(showNewAppend)
	end
	
	-- 战力对比
	local curEquipID = ModelEquip.getCurrEquipEx(equip.instid)
	local curEquip = ModelEquip.getEquipInfo(curEquipID)
	if nil == curEquip then
		return
	end
	
	local iconStr = nil
	if equip.combat_effectiveness == curEquip.combat_effectiveness then
		return
	elseif equip.combat_effectiveness > curEquip.combat_effectiveness then
		iconStr = "equipped_strengthen_modify04.png"
	elseif equip.combat_effectiveness < curEquip.combat_effectiveness then
		iconStr = "equipped_strengthen_modify06.png"
	end
	
	local compareImage = tolua.cast(widget:getChildByName("UIImageView_compare"), "UIImageView")
	if nil == compareImage then
		compareImage = UIImageView:create()
		compareImage:setScale(0.7)
		compareImage:setPosition(ccp(35, 35))
		compareImage:setName("UIImageView_compare")
		widget:addChild(compareImage)
	end
	compareImage:loadTexture(iconStr)
	compareImage:setVisible(true)
end
----------------------------------------------------------------------
-- 设置宝石格子
local function setGemGrid(data, widget)
	if item_type["gem"] ~= data.itemtype then
		widget:setColor(ccc3(140, 140, 140))
		return
	end
end
-----------------------------------------------------------------------
--长按背包格子
local function tempLongClick(widget, index, dataType)
	local itemData = mCurData[index]
	local instId = itemData.id
	local itemId = itemData.itemid
	
	local param = {}
	param.instId = instId
	param.itemId = itemId
	param.enterType = "roleinfo"	-- 入口类型(从符文信息界面进入)
	local position,direct = CommonFuncJudgeInfoPosition(widget)
	param.position = position
	param.direct = direct
	param.is_item = false
	
	-- 点击装备格子
	if "equip" == dataType and item_type["equipment"] == itemData.itemtype then
		UIManager.push("UI_EquipInfo",param)
	end
	-- 点击宝石格子
	if "gem" == dataType and item_type["gem"] == itemData.itemtype then
		UIManager.push("UI_GemInfo_Long",param)
	end
	-- 点击物品格子
	if "item" == dataType then
		if item_type["equipment"] == itemData.itemtype then
			UIManager.push("UI_EquipInfo",param)
		elseif item_type["gem"] == itemData.itemtype then
			UIManager.push("UI_GemInfo_Long",param)
		else	
			param.is_item = true
			UIManager.push("UI_ItemInfo_Long",param)
		end
	end
end
--------------------------------------------------------------------------
--长按背包格子结束回调
local function tempLongClickCallback(widget, index, dataType)
	local itemData = mCurData[index]
	
		-- 点击装备格子
		if "equip" == dataType and item_type["equipment"] == itemData.itemtype then
			UIManager.pop("UI_EquipInfo")
		end
		-- 点击宝石格子
		if "gem" == dataType and item_type["gem"] == itemData.itemtype then
			UIManager.pop("UI_GemInfo_Long")
		end
		-- 点击物品格子
		if "item" == dataType then
			if item_type["equipment"] == itemData.itemtype then
				UIManager.pop("UI_EquipInfo")
			elseif item_type["gem"] == itemData.itemtype then
				UIManager.pop("UI_GemInfo_Long")
			else	
				UIManager.pop("UI_ItemInfo_Long")
			end
		end
end
----------------------------------------------------------------------
-- 设置格子
local function setBagGird(gridImage, index, dataType)
	local data = mCurData[index]
	gridImage:stopAllActions()
	gridImage:setColor(ccc3(255, 255, 255))
	local children = gridImage:getChildren()
	for i=0, children:count() - 1 do
		local child = tolua.cast(children:objectAtIndex(i), "UIWidget")
		child:setVisible(false)
	end
	if "null" == data then		-- 空格子
		gridImage:setTouchEnabled(false)
		CommonFunc_AddGirdWidget(nil, nil, nil, nil, gridImage)
	else						-- 非空格子
		gridImage:setTouchEnabled(true)
		-- 格子点击回调
		local callBackFunc = function(widget)
			clickGrid(gridImage, index, dataType)
		end
		local equip = nil
		if item_type["equipment"] == data.itemtype then
			equip = ModelEquip.getEquipInfo(data.id)
		end
		local num = equip and equip.strengthen_level or nil
		CommonFunc_AddGirdWidget(data.itemid, data.amount, num, nil, gridImage)
		gridImage:setTouchEnabled(true)
		
		--长按格子出现的事件
		local function longClickGrid(widget)
			tempLongClick(widget, index, dataType)
		end

		--长按格子结束回调
		local function longClickCallback(widget)
			tempLongClickCallback(widget, index, dataType)
		end
		UIManager.registerEvent(gridImage, callBackFunc, longClickGrid, longClickCallback)
		
		
		if "equip" == dataType then
			setEquipGrid(equip, gridImage)
		elseif "gem" == dataType then
			setGemGrid(data, gridImage)
		end
		-- 选中标识
		local selectImage = tolua.cast(gridImage:getChildByName("select_tick_image"), "UIImageView")
		if nil == selectImage then
			selectImage = UIImageView:create()
			selectImage:setName("select_tick_image")
			selectImage:loadTexture("tick.png")
			gridImage:addChild(selectImage)
		end
		selectImage:setVisible(false)
		if true == data.isSelected then
			selectGrid(data.sculpture_id, index, gridImage)
		end
	end
	return gridImage
end
----------------------------------------------------------------------
local function scrollCallback(scrollView)
	if nil == mLayerRoot then
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
	local silder = tolua.cast(mLayerRoot:getChildByName("Slider_455"), "UISlider")
	silder:setPercent(100 - ratio)
end
----------------------------------------------------------------------
local function createBagGrid(gridCell, gridData, index)
	local gridImage = tolua.cast(gridCell, "UIImageView")
	if nil == gridImage then
		gridImage = UIImageView:create()
		gridImage:setName("grid_"..index)
	end
	setBagGird(gridImage, index, mCurDataType)
	return gridImage
end
----------------------------------------------------------------------
-- 创建滚动层
local function createScrollView(dataType)
	updateData(dataType)
	local silder = tolua.cast(mLayerRoot:getChildByName("Slider_455"), "UISlider")
	silder:setPercent(0)
	local scrollView = tolua.cast(mLayerRoot:getChildByName("ScrollView_Backups"), "UIScrollView")
	local _, grids = UIScrollViewEx.show(scrollView, mCurData, createBagGrid, "V", 94, 94, 4, 5, 3, true, scrollCallback, false, true)
	if false == mOneKeySelected then
		playGridAction(grids)
	end
end
----------------------------------------------------------------------
-- 切换背包标签
function LayerBag.switchBag(dataType)
	if nil == mLayerRoot then
		return
	end
	dataType = dataType or mCurDataType
	mCurDataType = dataType
	createScrollView(dataType)
	showWidgetByType(dataType)
	TipModule.onUI(mLayerRoot, "ui_bag"..dataType)
end
----------------------------------------------------------------------
-- 获取当前背包数据
function LayerBag.getBagType()
	return mCurDataType
end
----------------------------------------------------------------------
