----------------------------------------------------------------------
-- 装备详情界面02，独立界面
----------------------------------------------------------------------
LayerEquipInfo_02 = {}
LayerAbstract:extend(LayerEquipInfo_02)

-- 点击
LayerEquipInfo_02.onClick = function(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName or "ImageView_Select_0_Copy0" == widgetName then
		UIManager.pop("UI_EquipInfo")
	end
end

-- 初始
LayerEquipInfo_02.init = function(bundle)
	--Log("LayerEquipInfo_02.init****************",bundle)
	local root = UIManager.findLayerByTag("UI_EquipInfo")
	setOnClickListenner("rootview")
	setOnClickListenner("ImageView_EquipBg")
	
	local rootPanel = tolua.cast(root:getWidgetByName("ImageView_EquipBg"), "UILayout")
	CommonFunc_Add_Info_EnterAction(bundle,rootPanel)
	
	local equipRow, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(bundle.instId)
	local typeName,roleName,strenLevel
	local itemRow = LogicTable.getItemById(bundle.itemId)
	if equipRow == nil then
		equipRow = ModelEquip.getEquipRow(bundle.itemId)
		typeName = CommonFunc_GetEquipTypeString(equipRow.type)
		roleName = CommonFunc_GetRoleTypeString(equipRow.type%10)
		strenLevel = 0
	else
		equipType, typeName, roleType, roleName = ModelEquip.getEquipType(bundle.instId)
		strenLevel = strengthenEquip.strengthen_level
	end
	
	-- 名称
	local nameStr = itemRow.name.."("..typeName..")"
	local nameLable = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLable:setText(nameStr)
	nameLable:setColor(BackpackLogic.getColour("quality", itemRow.quality))
	
	-- 等级
	local levelLabel = tolua.cast(root:getWidgetByName("Label_level"), "UILabel")
	levelLabel:setText(string.format("Lv.%d", equipRow.equip_use_level+0))
	levelLabel:setColor(BackpackLogic.getColour("level", equipRow.equip_use_level))
	-- 强化等级
	local levelStrLabel = tolua.cast(root:getWidgetByName("Label_strenLevel"), "UILabel")
	levelStrLabel:setText(string.format("%d", strenLevel))
	--levelStrLabel:setColor(BackpackLogic.getColour("level", equipRow.equip_use_level))
	-- 星级
	local starLevel = CommonFunc_getQualityInfo(itemRow.quality).star
	local typeLable = tolua.cast(root:getWidgetByName("Label_qua"), "UILabel")
	typeLable:setText(GameString.get("Public_Info_star",tonumber(starLevel)))
	
	-- 战斗力
	local abilityLable = tolua.cast(root:getWidgetByName("ability"), "UILabel")
	abilityLable:setText(tostring(equipRow.combat_effectiveness))
	
	
	if baseEquip == nil or randomEquip == nil then
		-- 基础属性值
		local attrLable = tolua.cast(root:getWidgetByName("Label_baseAtt"), "UILabel")
		local valueKey = CommonFunc_getEffectAttrs(equipRow)[1]
		local valueString = CommonFunc_getAttrString(valueKey)
		local valNum = equipRow[valueKey]
		attrLable:setText(string.format("%s:%d", valueString, valNum))
			
		-- 随机属性
		local attrIds = nil
		attrIds = ModelEquip.getRandomMfRuleInfo(equipRow.mf_rule)

		for i=1, 3 do
			local attrLabel = tolua.cast(root:getWidgetByName("randAtt_"..i), "UILabel")
			attrLabel:setVisible(false)
			if attrIds and attrIds[i] then
				local attrInfo = ModelEquip.getRandomAttrInfo(attrIds[i])
				if attrInfo then
					local attrStr = CommonFunc_getAttrString(attrInfo.attr_type)..GameString.get("PUBLIC_COLON")..attrInfo.attr_value
					attrLabel:setText(attrStr)
					attrLabel:setVisible(true)
				end
			end
		end
	else
		-- 基础属性值
		local attrLable = tolua.cast(root:getWidgetByName("Label_baseAtt"), "UILabel")
		local valueKey = CommonFunc_getEffectAttrs(baseEquip)[1]
		local valueString = CommonFunc_getAttrString(valueKey)
		if 0 == strengthenEquip[valueKey] then
			attrLable:setText(string.format("%s:%d", valueString, baseEquip[valueKey]))
		else
			attrLable:setText(string.format("%s:%d+%d", valueString, baseEquip[valueKey], strengthenEquip[valueKey]))
		end
			
		-- 随机属性
		local randomWeaponAttr = CommonFunc_getAttrDescTable(randomEquip)
		for i=1, 3 do
			local attrLabel = tolua.cast(root:getWidgetByName("randAtt_"..i), "UILabel")
			attrLabel:setVisible(false)
			if randomWeaponAttr[i] then
				attrLabel:setVisible(true)
				attrLabel:setText(randomWeaponAttr[i])
			end
		end
	end
	
	-- 宝石孔(上限3个)
	for i=1, 3 do
		local gemIconImageView = tolua.cast(root:getWidgetByName("ImageView_price"..i), "UIImageView")
		if i <= equipRow.gem_trough then
			if nil ~= gemEquip then
				if i <= #gemEquip.gems then
					local gemAttrRow = ModelGem.getGemAttrRow(gemEquip.gems[i])
					gemIconImageView:loadTexture(gemAttrRow.small_icon)
				end
			end
			gemIconImageView:setVisible(true)
		else
			gemIconImageView:setVisible(false)
		end
	end
end

-- 销毁
LayerEquipInfo_02.destroy = function()
end
