
----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-3-5
-- 描述：宝石镶嵌
----------------------------------------------------------------------
LayerGemInlay = {
}

LayerGemInlay.bGemInlay = false
LayerGemInlay.gemTempId = 0

local mLayerRoot = nil
-- 模式:1个宝石孔,2个宝石孔,3个宝石孔
-- key:1,2,3;itemID,widget
local mLayerMode = {}
-- 备份原始坐标
local mBackPos = {}
local mMovePos = {}
-- 装备实例id
local mEquipmentId = 0

local function onClickEvent(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		if "Button_close" == widgetName then
			LayerBackpack.switchUILayer("UI_equip_body")
			return
		end
		
		for i=1, 3 do
			if nil ~= mLayerMode[i] then
				local gemTempId = mLayerMode[i].itemID
				if widgetName == "Button_gem"..i then			-- 卸下宝石
					LayerGemInlay.gemTempId = gemTempId
					LayerBackpack.seed_gem_unmounted_result(gemTempId)
				elseif widgetName == "ImageView_gem"..i then
					local param = {}
					param.itemID = gemTempId
					LayerBackpack.switchUILayer("UI_gem_info_new", param)
				end
			end
		end
	end
end

-- 镶嵌动画
local function actionInlay(index)
	local action = CCMoveTo:create(0.5, mMovePos[index])
	action = CCEaseBackIn:create(action)
	mLayerMode[index].widget:runAction(action)
end

-- 卸下动画
local function actionUnwield(index)
	local action = CCMoveTo:create(0.5, mBackPos[index])
	mLayerMode[index].widget:runAction(action)
end

-- 添加宝石
local function addGem(gemTempIds)
	for key, val in pairs(gemTempIds) do
		for k, v in pairs(mLayerMode) do
			if nil == v.itemID then
				mLayerMode[k].itemID = val
				break
			end
		end
	end
end

-- 移除宝石
local function delGem(gemTempId)
	for key, val in pairs(mLayerMode) do
		if val.itemID == gemTempId then
			mLayerMode[key].itemID = nil
			actionUnwield(key)
			break
		end
	end
end

--获取当前镶嵌界面的装备
function LayerGemInlay.getCurrentEquipID()
	return mEquipmentId
end

-- 更新控件
local function updateWidget()
	if nil == mLayerRoot then
		return
	end
	
	for key, val in pairs(mLayerMode) do
		-- 打开的宝石孔
		if mLayerMode[key] ~= nil then
			local gemImageView = tolua.cast(mLayerRoot:getChildByName("ImageView_gem"..key), "UIImageView")
			local unwieldBtn = tolua.cast(mLayerRoot:getChildByName("Button_gem"..key), "UIButton")
			
			local itemID = mLayerMode[key].itemID
			if nil == itemID then
				gemImageView:removeAllChildren()
				gemImageView:setTouchEnabled(false)
				CommonFunc_SetWidgetTouch(unwieldBtn, false)
			else
				-- 添加装备格子
				local widgetGrid = CommonFunc_AddGirdWidget(itemID, 1)
				widgetGrid:setVisible(true)
				widgetGrid:setZOrder(1000)
				gemImageView:registerEventScript(onClickEvent)
				gemImageView:addChild(widgetGrid)
				gemImageView:setTouchEnabled(true)
				CommonFunc_SetWidgetTouch(unwieldBtn, true)
				unwieldBtn:registerEventScript(onClickEvent)
			end
		end
	end
end

local function setLayerMode(gemTrough)
	local function setNodeVisible(showTable, hideTable)
		showTable = showTable or {}
		hideTable = hideTable or {}
		mLayerMode = {}
		for key, val in pairs(showTable) do
			local gemImageView = mLayerRoot:getChildByName("ImageView_gem"..val)
			gemImageView:registerEventScript(onClickEvent)
			local btn = mLayerRoot:getChildByName("Button_gem" .. val)	
			btn:registerEventScript(onClickEvent)
			
			mLayerMode[val] = {}
		end
		
		for key, val in pairs(hideTable) do
			local widget = mLayerRoot:getChildByName("ImageView_node_"..val)
			CommonFunc_SetWidgetTouch(widget, false)
			
			mLayerMode[val] = nil
		end
	end
	
	if 0 == gemTrough then
		setNodeVisible(nil, {1,2,3})
	elseif 1 == gemTrough then
		setNodeVisible({1}, {2,3})
	elseif 2 == gemTrough then
		setNodeVisible({2,3}, {1})
	elseif 3 == gemTrough then
		setNodeVisible({1,2,3})
	end
	
	--
	for i=1, 3 do
		local widget = mLayerRoot:getChildByName("ImageView_node_"..i)
		local pos = CommonFunc_GetPos(widget)
		mBackPos[i] = pos
		
		if 1 == i then
			mMovePos[i] = ccp(pos.x, pos.y-20)
		elseif 2 == i then
			mMovePos[i] = ccp(pos.x+20, pos.y)
		elseif 3 == i then
			mMovePos[i] = ccp(pos.x-20, pos.y)
		end
		
		if mLayerMode[i] ~= nil then
			mLayerMode[i].widget = widget
		end
	end
end

-- 初始化
function LayerGemInlay.init(root, id)
	mLayerRoot = root
	id = id or mEquipmentId
	mEquipmentId = id
	
	LayerGemInlay.bGemInlay = true
	if "gem" ~= LayerBag.getBagType() then
		LayerBackpack.switchTag("Button_Gem")
	end
	local equip = ModelEquip.getEquipInfo(id)
	-- 设置模式
	setLayerMode(equip.gem_trough)
	-- 装备格子
	local equipImageView = mLayerRoot:getChildByName("ImageView_equip")
	local widget = CommonFunc_AddGirdWidget(equip.id, 1, equip.strengthen_level)
	equipImageView:addChild(widget)
	-- 关闭按钮
	local closeBtn = mLayerRoot:getChildByName("Button_close")	
	closeBtn:registerEventScript(onClickEvent)
	
	addGem(equip.gems)
	
	for key, val in pairs(mLayerMode) do
		if nil == val.itemID then
			val.widget:setPosition(mBackPos[key])
		else
			val.widget:setPosition(mMovePos[key])
		end
	end
	updateWidget()
	TipModule.onUI(root, "ui_geminlay")
end

-- 销毁
function LayerGemInlay.destroy(newLayerName)
	mLayerRoot = nil
	if "UI_gem_info_new" ~= newLayerName then
		LayerGemInlay.bGemInlay = false
	end
end

-- 成功卸下宝石
function LayerGemInlay.gemUnmountOk()
	delGem(LayerGemInlay.gemTempId)
	updateWidget()
end

