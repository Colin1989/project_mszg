----------------------------------------------------------------------
-- 宝石信息界面02，独立界面
----------------------------------------------------------------------
LayerGemInfo_02 = {}
LayerAbstract:extend(LayerGemInfo_02)

-- 点击
LayerGemInfo_02.onClick = function(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName or "Panel_20" == widgetName then
		UIManager.pop("UI_GemInfo")
	end
end

-- 初始化
LayerGemInfo_02.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_GemInfo")
	setOnClickListenner("rootview")
	setOnClickListenner("Panel_20")
	
	local baseAttr = LogicTable.getItemById(bundle.temp_id)
	local gemAttr = ModelGem.getGemAttrRow(baseAttr.sub_id)
	-- 图标
	local iconImageView = tolua.cast(root:getWidgetByName("ImageView_head"), "UIImageView")
	CommonFunc_AddGirdWidget(baseAttr.id, 1, nil, nil, iconImageView)
	-- 名称
	local nameLabel = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLabel:setText(gemAttr.name)
	-- 战斗力
	local abilityLabel = tolua.cast(root:getWidgetByName("Label_ability"), "UILabelAtlas")
	abilityLabel:setStringValue(tostring(gemAttr.combat_effectiveness))
	-- 描述
	local descLabel = tolua.cast(root:getWidgetByName("Label_info"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(307, 140))
	descLabel:setText(baseAttr.describe)
	-- 属性
	local strGemAttrValue = CommonFunc_getAttrDescTable(gemAttr)
	for i=1, 3 do
		local attrLable = tolua.cast(root:getWidgetByName("Label_"..i), "UILabel")
		if nil == strGemAttrValue[i] then
			attrLable:setVisible(false)
		else
			attrLable:setVisible(true)
			attrLable:setText(strGemAttrValue[i])
		end
	end
	
	-- 产出地址及前往
	local dropCopy, dropStr = ItemOutput.getRoads(bundle)
	if dropCopy == nil and dropStr == nil then
		local dropImageView = tolua.cast(root:getWidgetByName("ImageView_2055"), "UIImageView")
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
		dropCopyBtn:setName("UI_GemInfo")
		dropCopyBtn:setTag(dropCopy.id)
		dropCopyBtn:registerEventScript(ItemOutput.gotoCopy)
	end
end

-- 销毁
LayerGemInfo_02.destroy = function()
end
