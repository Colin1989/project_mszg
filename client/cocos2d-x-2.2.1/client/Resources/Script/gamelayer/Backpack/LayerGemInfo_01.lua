----------------------------------------------------------------------
-- 宝石信息界面01，嵌套在背包界面内
----------------------------------------------------------------------
local mGemID = nil
local mItemID = nil
local mLayerRoot = nil
LayerGemInfo_01 = {
}

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		--if true == LayerGemInlay.bGemInlay then
			--LayerBackpack.switchUILayer("UI_gemInlay")
		--else
			LayerBackpack.switchUILayer("UI_equip_body")
		--end
	end
end

-- 点击合成按钮
local function clickCompoundBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		LayerBackpack.switchUILayer("UI_equip_body")
		LayerBackpack.switchUILayer("UI_gemCompound", mGemID)
	end
end

-- 确定出售
local function sureSell(count)
	LayerBackpack.callback_seed_sale_item(mGemID, count)
end

-- 点击出售按钮
local function clickSellBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local attr = ModelBackpack.getItemByInstId(mGemID)
		-- local param = {}
		-- param.maxValue = attr.amount
		-- param.initIndex = 1
		-- param.sure_callback = sureSell
		-- UIManager.push("UI_BuyInput", param)
		LayerBackpack.callback_seed_sale_item(mGemID, attr.amount)
	end
end

-- 点击镶嵌按钮
local function clickInlayBtn(typeName,widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		--LayerGemInlay.gemTempId = ModelBackpack.getItemTempId(mGemID)
		Log("clickInlayBtn*****************",mGemID,type(mGemID))
		LayerBackpack.seed_equipment_mountgem_result(mGemID)
	end
end

-- 点击卸载按钮
local function clickUnloadBtn(typeName,widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		--LayerGemInlay.gemTempId = mItemID
		LayerBackpack.seed_gem_unmounted_result(mItemID)
	end
end

function LayerGemInfo_01.destroy(newLayerName)
	mLayerRoot = nil
	if "UI_gemInlay" ~= newLayerName then
		--LayerGemInlay.bGemInlay = false
	end
end

-- 初始化,param={id, itemID}
function LayerGemInfo_01.init(root, param)
	mLayerRoot = root
	mGemID = param.id
	mItemID = param.itemID
	
	local itemRow, gemAttrRow = nil, nil
	if mGemID ~= nil then
		itemRow = LogicTable.getItemById(mItemID)
		gemAttrRow = ModelGem.getGemAttrRow(itemRow.sub_id)
	elseif mItemID ~= nil then
		itemRow = LogicTable.getItemById(mItemID)	
		gemAttrRow = ModelGem.getGemAttrRow(itemRow.sub_id)
	end
	-- 图标
	local iconImageView = tolua.cast(root:getChildByName("ImageView_head"), "UIImageView")
	CommonFunc_AddGirdWidget(itemRow.id, 1, nil, nil, iconImageView)
	-- 名字
	local nameLabel = tolua.cast(root:getChildByName("Label_name"), "UILabel")
	nameLabel:setText(gemAttrRow.name)
	-- 战斗力
	local abilityLabel = tolua.cast(root:getChildByName("Label_ability"), "UILabelAtlas")
	abilityLabel:setStringValue(tostring(gemAttrRow.combat_effectiveness))
	-- 描述
	local descLabel = tolua.cast(root:getChildByName("Label_info"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(355, 97))
	descLabel:setText(itemRow.describe)
	-- 价格
	local priceLabel = tolua.cast(root:getChildByName("LabelAtlas_price"), "UILabelAtlas")
	priceLabel:setStringValue(tostring(itemRow.sell_price))
	-- 属性
	local strGemAttrValue = CommonFunc_getAttrDescTable(gemAttrRow)
	for i=1, 3 do
		local attrLable = tolua.cast(root:getChildByName("Label_"..i), "UILabel")
		if nil == strGemAttrValue[i] then
			attrLable:setVisible(false)
		else
			attrLable:setVisible(true)
			attrLable:setText(strGemAttrValue[i])
		end
	end
	-- 关闭按钮
	local closeBtn = tolua.cast(root:getChildByName("Button_Close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 合成按钮
	local compoundBtn = tolua.cast(root:getChildByName("Button_1"), "UIButton")
	compoundBtn:registerEventScript(clickCompoundBtn)
	-- 出售按钮
	local sellBtn = tolua.cast(root:getChildByName("Button_2"), "UIButton")
	sellBtn:registerEventScript(clickSellBtn)
	-- 镶嵌按钮
	local inlayBtn = tolua.cast(root:getChildByName("Button_3"), "UIButton")
	inlayBtn:registerEventScript(clickInlayBtn)
	local inlayImage = tolua.cast(root:getChildByName("ImageView_1634"), "UIImageView")
	inlayImage:loadTexture("text_set.png")
	--if true == LayerGemInlay.bGemInlay then
		--CommonFunc_SetWidgetTouch(inlayBtn,true)
		--CommonFunc_SetWidgetTouch(compoundBtn,false)
		--CommonFunc_SetWidgetTouch(sellBtn,false)
	--else
		CommonFunc_SetWidgetTouch(inlayBtn,false)
	--end
	if mGemID == nil and mItemID ~= nil then
		CommonFunc_SetWidgetTouch(sellBtn,false)
		CommonFunc_SetWidgetTouch(compoundBtn,false)
		inlayBtn:registerEventScript(clickUnloadBtn)
		inlayImage:loadTexture("text_unload.png")
	end
	TipModule.onUI(root, "ui_geminfo_01")
	
	-- 产出地址及前往
	local bundle = {}
	bundle.temp_id = mItemID
	bundle.type = 7
	bundle.popUIName = param.popUIName
	bundle.popUIType = 1
	local dropCopy, dropStr = ItemOutput.getRoads(bundle)
	if dropCopy == nil and dropStr == nil then
		local dropImageView = tolua.cast(root:getChildByName("ImageView_2051"), "UIImageView")
		dropImageView:setVisible(false)
		local dropCopyBtn = tolua.cast(root:getChildByName("Button_dropCopy"), "UIButton")
		dropCopyBtn:setVisible(false)
	elseif dropCopy == nil and dropStr ~= nil then
		local labelDropCopy = tolua.cast(root:getChildByName("Label_dropCopy"), "UILabel")
		labelDropCopy:setText(dropStr)
		local dropCopyBtn = tolua.cast(root:getChildByName("Button_dropCopy"), "UIButton")
		dropCopyBtn:setVisible(false)
	elseif dropCopy ~= nil and dropStr ~= nil then
		local labelDropCopy = tolua.cast(root:getChildByName("Label_dropCopy"), "UILabel")
		labelDropCopy:setText(dropStr)
		local dropCopyBtn = tolua.cast(root:getChildByName("Button_dropCopy"), "UIButton")
		dropCopyBtn:setName("UI_gem_info_new")
		dropCopyBtn:setTag(dropCopy.id)
		dropCopyBtn:registerEventScript(ItemOutput.gotoCopy)
	end
end

