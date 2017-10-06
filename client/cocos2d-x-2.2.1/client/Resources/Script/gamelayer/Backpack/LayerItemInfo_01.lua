----------------------------------------------------------------------
-- 物品详情界面01，嵌套在背包界面内
----------------------------------------------------------------------
local mID = nil
local mTempID = nil
local mLayerRoot = nil
local mTempButton = nil
LayerItemInfo_01 = {}

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		LayerBackpack.switchUILayer("UI_equip_body")
	end
end

-- 确定出售
local function sureSell(count)
	LayerBackpack.callback_seed_sale_item(mID, count)
end

-- 点击出售按钮
local function clickSellBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local attr = ModelBackpack.getItemByInstId(mID)
		-- local param = {}
		-- param.maxValue = attr.amount
		-- param.initIndex = 1
		-- param.sure_callback = sureSell
		-- UIManager.push("UI_BuyInput", param)
        assert(attr~=nil,"ERROE LOG:mID:",mID)
		LayerBackpack.callback_seed_sale_item(mID, attr.amount)
	end
end

-- 点击使用按钮
local function clickUseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		mTempButton = widget
		mTempButton:setTouchEnabled(false)
		BackpackLogic.requestUseProps(mID)
	end
end

-- 处理使用道具
local function handleUseProps(data)
	if true == data.success then
		LayerBackpack.switchUILayer("UI_equip_body")
		local baseAttr = LogicTable.getItemById(mTempID)
		local giftRow = LogicTable.getGiftBagRow(baseAttr.sub_id)
		CommonFunc_showItemGetInfo(giftRow.reward_item_ids, giftRow.reward_item_amounts)
	else
		if mTempButton then
			mTempButton:setTouchEnabled(true)
		end
	end
end

-- 收到物品批量售出
local function handleItemsSale(data)
    if nil == mLayerRoot or not data.success then
        return
    end
    LayerBackpack.switchUILayer("UI_equip_body")
end

-- 初始,param={id=实例id, itemID=物品id}
function LayerItemInfo_01.init(root, param)
	mID = param.id
	mTempID = param.itemID
	mLayerRoot = root
	local baseAttr = LogicTable.getItemById(param.itemID)
	--入场动画
	--Animation_UIItem_Enter(root)
	-- 关闭按钮
	local closeBtn = root:getChildByName("Button_Close")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 出售按钮
	local sellBtn = root:getChildByName("Button_1")
	sellBtn:registerEventScript(clickSellBtn)
	-- 使用按钮
	local useBtn = root:getChildByName("Button_use")
	useBtn:registerEventScript(clickUseBtn)
	useBtn:setEnabled(false)
	if item_type["props"] == baseAttr.type then		-- 道具
		useBtn:setEnabled(true)
	end
	-- 图标
	local iconImageView = root:getChildByName("ImageView_head")
	tolua.cast(iconImageView, "UIImageView")
	iconImageView:loadTexture(baseAttr.icon)
	if item_type["equipment"] == baseAttr.type then
		local addData = ModelEquip.getEquipInfo(mID)
		CommonFunc_SetQualityFrame(iconImageView, baseAttr.quality, addData.strengthen_level)	-- 添加品质框
	else
		CommonFunc_SetQualityFrame(iconImageView, baseAttr.quality)	-- 添加品质框
	end
	-- 名称
	local nameLabel = root:getChildByName("Label_name")
	tolua.cast(nameLabel, "UILabel")
	nameLabel:setText(baseAttr.name)
	-- 描述
	local descLabel = root:getChildByName("Label_info")
	tolua.cast(descLabel, "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(354, 97))
	descLabel:setText(baseAttr.describe)
	-- 价格
	local priceLabel = root:getChildByName("LabelAtlas_price")
	tolua.cast(priceLabel, "UILabelAtlas")
	priceLabel:setStringValue(tostring(baseAttr.sell_price))
	TipModule.onUI(root, "ui_iteminfo_01")
	
	-- 产出地址及前往
	local bundle = {}
	bundle.temp_id = param.itemID
	bundle.type = param.type
	bundle.popUIName = param.popUIName
	bundle.popUIType = 1
	local dropCopy, dropStr = ItemOutput.getRoads(bundle)
	if dropCopy == nil and dropStr == nil then
		local dropImageView = tolua.cast(root:getChildByName("ImageView_2047"), "UIImageView")
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
		dropCopyBtn:setName("UI_item_info_new")
		dropCopyBtn:setTag(dropCopy.id)
		dropCopyBtn:registerEventScript(ItemOutput.gotoCopy)
	end
end

function LayerItemInfo_01.destroy()
	mID = nil
	mLayerRoot = nil
	mTempButton = nil
end

EventCenter_subscribe(EventDef["ED_USE_PROPS"], handleUseProps)
EventCenter_subscribe(EventDef["ED_ITEMS_SALE"], handleItemsSale)
