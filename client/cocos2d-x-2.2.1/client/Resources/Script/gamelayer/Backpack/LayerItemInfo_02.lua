----------------------------------------------------------------------
-- 物品详情界面01，独立界面
----------------------------------------------------------------------
LayerItemInfo_02 = {}
LayerAbstract:extend(LayerItemInfo_02)

-- 点击
LayerItemInfo_02.onClick = function(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName or "Panel_20" == widgetName then
		UIManager.pop("UI_ItemInfo")
	end
end

-- 初始
LayerItemInfo_02.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_ItemInfo")
	setOnClickListenner("rootview")
	setOnClickListenner("Panel_20")
	--
	local icon, name, desc, qua
	if true == bundle.is_item then
		local itemRow = LogicTable.getItemById(bundle.temp_id)
		icon = itemRow.icon
		name = itemRow.name
		desc = itemRow.describe
		qua = itemRow.quality
	else
		local rewardItemRow = LogicTable.getRewardItemRow(bundle.temp_id)
		icon = rewardItemRow.icon
		name = rewardItemRow.name
		desc = rewardItemRow.description
		qua = 1
	end
	-- 图标
	local iconImageView = tolua.cast(root:getWidgetByName("ImageView_head"), "UIImageView")
	iconImageView:loadTexture(icon)
	CommonFunc_SetQualityFrame(iconImageView, qua)	-- 添加品质框
	-- 名称
	local nameLabel = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLabel:setText(name)
	-- 描述
	local descLabel = tolua.cast(root:getWidgetByName("Label_info"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(307, 150))
	descLabel:setText(desc)
	
	-- 产出地址及前往
	local dropCopy, dropStr = ItemOutput.getRoads(bundle)
	if dropCopy == nil and dropStr == nil then
		local dropImageView = tolua.cast(root:getWidgetByName("ImageView_2060"), "UIImageView")
		dropImageView:setVisible(false)
		local dropCopyBtn = tolua.cast(root:getWidgetByName("Button_dropCopy"), "UIButton")
		dropCopyBtn:setVisible(false)
	elseif dropCopy == nil and dropStr ~= nil then
		local labelDropCopy = tolua.cast(root:getWidgetByName("Label_dropCopy"), "UILabel")
		labelDropCopy:setText(dropStr)
		local dropCopyBtn = tolua.cast(root:getWidgetByName("Button_dropCopy"), "UIButton")
		dropCopyBtn:setVisible(false)
	elseif dropCopy ~= nil and dropStr ~= nil then
		local labelDropCopy = tolua.cast(root:getWidgetByName("Label_dropCopy"), "UILabel")
		labelDropCopy:setText(dropStr)
		local dropCopyBtn = tolua.cast(root:getWidgetByName("Button_dropCopy"), "UIButton")
		dropCopyBtn:setName("UI_ItemInfo")
		dropCopyBtn:setTag(dropCopy.id)
		dropCopyBtn:registerEventScript(ItemOutput.gotoCopy)
	end
end

-- 销毁
LayerItemInfo_02.destroy = function()
end
