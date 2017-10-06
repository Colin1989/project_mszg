----------------------------------------------------------------------
-- 物品详情界面01，独立界面
----------------------------------------------------------------------
LayerItemInfo = {}
LayerAbstract:extend(LayerItemInfo)

-- 点击
LayerItemInfo.onClick = function(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName or "Panel_20" == widgetName then
		UIManager.pop("UI_ItemInfo_Long")
	end
end

-- 初始
LayerItemInfo.init = function(bundle)
	--Log("LayerItemInfo.init****************",bundle)
	local root = UIManager.findLayerByTag("UI_ItemInfo_Long")
	setOnClickListenner("rootview")
	setOnClickListenner("Panel_20")
	
	local rootPanel = tolua.cast(root:getWidgetByName("Panel_20"), "UILayout")
	CommonFunc_Add_Info_EnterAction(bundle,rootPanel)
	
	--
	local  name, desc
	if true == bundle.is_item then
		local itemRow = LogicTable.getItemById(bundle.itemId)
		name = itemRow.name
		desc = itemRow.describe
		sell = itemRow.sell_price
	else
		local rewardItemRow = LogicTable.getRewardItemRow(bundle.itemId)
		name = rewardItemRow.name
		desc = rewardItemRow.description
		sell = rewardItemRow.sell_price
	end
	-- 名称
	local nameLabel = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLabel:setText(name)
	-- 描述
	local descLabel = tolua.cast(root:getWidgetByName("Label_info"), "UILabel")
	descLabel:setText(desc)
	local sellBg = tolua.cast(root:getWidgetByName("ImageView_sell"), "UIImageView")
	if tonumber(sell) == 0 then
		sellBg:setVisible(false)
	else
		sellBg:setVisible(true)
		--售价
		local sellLabel = tolua.cast(root:getWidgetByName("Label_sell"), "UILabel")
		sellLabel:setText(sell)
	end
	
end

-- 销毁
LayerItemInfo.destroy = function()
end
