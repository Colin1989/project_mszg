----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-10
-- Brief:	宝石长按信息界面
----------------------------------------------------------------------
LayerGemInfo = {}
LayerAbstract:extend(LayerGemInfo)

-- 点击
LayerGemInfo.onClick = function(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName or "Panel_20" == widgetName then
		UIManager.pop("UI_GemInfo_Long")
	end
end

-- 初始化
LayerGemInfo.init = function(bundle)

	local root = UIManager.findLayerByTag("UI_GemInfo_Long")
	setOnClickListenner("rootview")
	setOnClickListenner("Panel_20")
	
	local rootPanel = tolua.cast(root:getWidgetByName("Panel_20"), "UILayout")
	CommonFunc_Add_Info_EnterAction(bundle,rootPanel)
	
	local baseAttr = LogicTable.getItemById(bundle.itemId)
	local gemAttr = ModelGem.getGemAttrRow(baseAttr.sub_id)
	-- 名称
	local nameLabel = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLabel:setText(gemAttr.name)
	-- 战斗力
	local abilityLabel = tolua.cast(root:getWidgetByName("Label_ability"), "UILabel")
	abilityLabel:setText(tostring(gemAttr.combat_effectiveness))
	-- 描述
	local descLabel = tolua.cast(root:getWidgetByName("Label_info"), "UILabel")
	descLabel:setText(baseAttr.describe)
	-- 属性
	local strGemAttrValue = CommonFunc_getAttrDescTable(gemAttr)
	local attrLable = tolua.cast(root:getWidgetByName("Label_"..1), "UILabel")
	attrLable:setText(strGemAttrValue[1])
	
	--售价
	local sellLabel = tolua.cast(root:getWidgetByName("Label_sell"), "UILabel")
	sellLabel:setText(baseAttr.sell_price)
end

-- 销毁
LayerGemInfo.destroy = function()
end
