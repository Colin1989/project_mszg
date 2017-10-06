
----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-12-8
-- Brief:	有确定的装备信息界面（升阶后使用）
----------------------------------------------------------------------
local mRoot = nil			--界面根节点

LayerSmithEquipInfo = {}
LayerAbstract:extend(LayerSmithEquipInfo)
----------------------------------界面进入动画------------------------------------
local function enterAction()
	--背景淡入
	local bg = tolua.cast(mRoot:getWidgetByName("bg"), "UIImageView")
	bg:runAction(CCFadeIn:create(0.3))
	
	--转动的图片
	local light = tolua.cast(mRoot:getWidgetByName("light"),"UIImageView")
	light:setVisible(false)
	
	local function call_Func()
		light:runAction( CCRepeatForever:create(CCRotateBy:create(0.5,60)) )
	end
	
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(0.5) )
	array:addObject( CCShow:create() )
	array:addObject(  CCCallFuncN:create(call_Func) )
	light:runAction( CCSequence:create(array))
	
	--信息根节点(从上往下移动)
	local rootBg = tolua.cast(mRoot:getWidgetByName("ImageView_EquipBg"),"UIImageView")
	rootBg:setVisible(false)
	
	local distance = 600
	local DROPTIME = 1.0
	local pos = rootBg:getPosition()
	local newPos = ccp(pos.x ,pos.y + distance)	
	
	local array = CCArray:create()
	array:addObject( CCPlace:create(newPos) )
	array:addObject( CCShow:create())
	array:addObject(CCEaseBackInOut:create(CCMoveTo:create(DROPTIME,ccp(pos.x,pos.y))))
	rootBg:runAction(CCSequence:create(array))
end
----------------------------------------------------------------------
-- 点击
LayerSmithEquipInfo.onClick = function(widget)
	local widgetName = widget:getName()
	if  "Button_sure" == widgetName  or "rootview" == widgetName then  		
		UIManager.pop("UI_Smith_Equip_sure")
	end
end

-- 初始（itemId 物品Id，instId实例ID，)                 --position窗口的 位置,direct 划入方向）
LayerSmithEquipInfo.init = function(bundle)
	
	local root = UIManager.findLayerByTag("UI_Smith_Equip_sure")
	mRoot = root
	--setOnClickListenner("rootview")
	--setOnClickListenner("ImageView_EquipBg")
	setOnClickListenner("Button_sure")
	
	enterAction()
	 
	local equipRow, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(bundle.instId)
	local itemRow = LogicTable.getItemById(equipRow.temp_id)
	equipType, typeName, roleType, roleName = ModelEquip.getEquipType(bundle.instId)
	strenLevel = strengthenEquip.strengthen_level

	-- 名称
	local nameStr = itemRow.name.."("..typeName..")"
	local nameLable = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLable:setText(nameStr)
	nameLable:setColor(BackpackLogic.getColour("quality", itemRow.quality))

	-- 图标
	local iconImageView = tolua.cast(root:getWidgetByName("ImageView_Head"), "UIImageView")
	iconImageView:loadTexture(itemRow.icon)
	CommonFunc_SetQualityFrame(iconImageView, itemRow.quality, equipRow.strengthen_level)	-- 装备品质框
	
	--[[
	-- 等级
	local levelLabel = tolua.cast(root:getWidgetByName("Label_level"), "UILabel")
	levelLabel:setText(string.format("Lv.%d", equipRow.equip_use_level+0))
	levelLabel:setColor(BackpackLogic.getColour("level", equipRow.equip_use_level))
	-- 强化等级
	local levelStrLabel = tolua.cast(root:getWidgetByName("Label_strenLevel"), "UILabel")
	levelStrLabel:setText(string.format("%d", strenLevel))
	--levelStrLabel:setColor(BackpackLogic.getColour("level", equipRow.equip_use_level))
	]]--
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
LayerSmithEquipInfo.destroy = function()
end
