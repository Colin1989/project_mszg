----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-10
-- Brief:	装备未穿戴界面
----------------------------------------------------------------------
LayerEquipNoPut = {}
LayerAbstract:extend(LayerEquipNoPut)
local root = nil 			--根节点
local mInstanceId = nil
local mExistFlag = false    --表示是否已经装备同类型的装备

-- 点击
LayerEquipNoPut.onClick = function(widget)
	local widgetName = widget:getName()
	if "Panel_equip_no_put" == widgetName or "ImageView_Select" == widgetName then
		UIManager.pop("UI_Equip_Noput")
	end
end

-- 点击装备按钮
local function clickPutBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local equip = ModelEquip.getEquipInfo(mInstanceId)
		
		local roleType = equip.type % 10
		if roleType ~= ModelPlayer.getRoleType() and roleType ~= 0 then	-- 非本职业装备
			Toast.show(GameString.get("Equip_STR_01"))
			return
		elseif equip.equip_use_level > ModelPlayer.getLevel() then		-- 等级不足
			Toast.show(GameString.get("Equip_STR_02"))
			return
		end
		
		
		if mExistFlag == true then
			local function senRequestPuton(mInstanceId)
				--卸下
				BackpackLogic.requestEquipmentPuton(mInstanceId)
				UIManager.pop("UI_Equip_Noput")
			end
			
			if  #equip.gems == 0 then
				senRequestPuton(mInstanceId)
			else
				local structConfirm = 
				{
					strText = GameString.get("Bag_change_equip"),
					buttonCount = 2,
					buttonName = {GameString.get("sure"), GameString.get("cancle")},
					buttonEvent = {senRequestPuton, nil},		--回调函数
					buttonEvent_Param = {mInstanceId, nil}			--函数参数
				}
				UIManager.push("UI_ComfirmDialog", structConfirm)
			end
		else
			UIManager.pop("UI_Equip_Noput")
			--装备
			BackpackLogic.requestEquipmentPuton(mInstanceId)
		end
		
	end
end


-- 点击对比按钮
local function clickComparisonBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		UIManager.pop("UI_Equip_Noput")
		local param = {}
		param.leftId = ModelEquip.getCurrEquipEx(mInstanceId)
		param.rightId = mInstanceId
		LayerBackpack.switchUILayer("UI_equip_comparison",param)
	end
end

-- 点击出售按钮
local function clickSellBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		UIManager.pop("UI_Equip_Noput")
		LayerBackpack.callback_seed_sale_item(mInstanceId,1,item_type["equipment"])
	end
end


--初始化按钮事件
local function initBtn(equipRow)
	-- 强化按钮
	--local strengthenBtn = root:getWidgetByName("Button_strengthen")
	--strengthenBtn:registerEventScript(clickStrengthenBtn)
	-- 装备按钮
	local putBtn = tolua.cast(root:getWidgetByName("Button_put"), "UIButton")
	putBtn:registerEventScript(clickPutBtn)
	-- 判断是否有宝石孔
	if 0 == equipRow.gem_trough then
		inlayBtn:setTouchEnabled(false)
		inlayBtn:loadTextureNormal("shortbutton_gray.png")
	end
	
	-- 当前身上装备ID
	local currentEquipID = ModelEquip.getCurrEquipEx(mInstanceId)
	-- 对比按钮
	local comparisonBtn = tolua.cast(root:getWidgetByName("Button_comparison"), "UIButton")
	local comparisonWord = comparisonBtn:getChildByName("ImageView_6684")
	if nil == currentEquipID then
		mExistFlag = false
		--comparisonBtn:loadTextureNormal("shortbutton_gray.png")
		Lewis:spriteShaderEffect(comparisonBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(comparisonWord:getVirtualRenderer(),"buff_gray.fsh",true)
		comparisonBtn:setTouchEnabled(false)
	else
		comparisonBtn:registerEventScript(clickComparisonBtn)
		mExistFlag = true
	end
	
	
	-- 出售按钮
	local sellBtn = tolua.cast(root:getWidgetByName("Button_sell"), "UIButton")
	sellBtn:registerEventScript(clickSellBtn)
	
	--侧边，按钮动画
	sellBtn:setVisible(false)
	comparisonBtn:setVisible(false)
	putBtn:setVisible(false)
	
	local function callBack_1()
		Commonfunc_dropAnimation(putBtn)
	end
	
	local function callBack_4()
		Commonfunc_dropAnimation(comparisonBtn)
	end
	local function callBack_5()
		Commonfunc_dropAnimation(sellBtn)
	end
	
	local delay = 0.1
	putBtn:runAction(CCCallFuncN:create(callBack_1))
	comparisonBtn:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay*3), CCCallFuncN:create(callBack_4)))
	sellBtn:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay*4), CCCallFuncN:create(callBack_5)))
	
	--[[
	local arr = CCArray:create()
	arr:addObject(CCCallFuncN:create(callBack_1))
	arr:addObject(CCDelayTime:create(delay))
	arr:addObject(CCCallFuncN:create(callBack_2))
	arr:addObject(CCDelayTime:create(delay))
	arr:addObject(CCCallFuncN:create(callBack_3))
	arr:addObject(CCDelayTime:create(delay))
	arr:addObject(CCCallFuncN:create(callBack_4))
	arr:addObject(CCDelayTime:create(delay))
	arr:addObject(CCCallFuncN:create(callBack_5))
	sellBtn:runAction(CCSequence:create(arr))
	]]--
end


-- 初始
LayerEquipNoPut.init = function(bundle)
	root = UIManager.findLayerByTag("UI_Equip_Noput")
	setOnClickListenner("Panel_equip_no_put")
	setOnClickListenner("ImageView_Select")
	
	--Log("LayerEquipNoPut.init************",bundle)
	mInstanceId = bundle.id
	-- 该物品是否当前穿戴在身上
	local equipRow, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(mInstanceId)
	local itemRow = LogicTable.getItemById(equipRow.id)
	local equipType, typeName, roleType, roleName = ModelEquip.getEquipType(mInstanceId)
	
	-- 等级
	local levelLabel = tolua.cast(root:getWidgetByName("Label_level"), "UILabel")
	levelLabel:setText(string.format("Lv.%d", equipRow.equip_use_level+0))
	levelLabel:setColor(BackpackLogic.getColour("level", equipRow.equip_use_level))
	-- 名称
	local nameLable = tolua.cast(root:getWidgetByName("Label_0"), "UILabel")
	local strengLevel = (equipRow.strengthen_level == nil) and 0 or tonumber(equipRow.strengthen_level)
	local equipName = (0 == strengLevel) and equipRow.name or GameString.get("Equip_strengthen", equipRow.name, tostring(strengLevel))
	nameLable:setText(equipName)
	nameLable:setColor(BackpackLogic.getColour("quality", itemRow.quality))
	-- 图标
	local iconImageView = tolua.cast(root:getWidgetByName("ImageView_Head"), "UIImageView")
	iconImageView:loadTexture(itemRow.icon)
	CommonFunc_SetQualityFrame(iconImageView, itemRow.quality, equipRow.strengthen_level)	-- 装备品质框
	-- 类型
	local typeLable = tolua.cast(root:getWidgetByName("Label_7"), "UILabel")
	typeLable:setText(string.format("%s", typeName))
	-- 星级
	local starLevel = CommonFunc_getQualityInfo(itemRow.quality).star
	for i=1, 5 do
		local starImageView = tolua.cast(root:getWidgetByName("star"..i), "UIImageView")
		starImageView:setVisible(starLevel >= i)
	end
	-- 战斗力
	local abilityLable = tolua.cast(root:getWidgetByName("ability"), "UILabelAtlas")
	abilityLable:setStringValue(tostring(equipRow.combat_effectiveness))
	-- 最大战斗力
	local maxAbilityLable = tolua.cast(root:getWidgetByName("ability_max"), "UILabelAtlas")
	maxAbilityLable:setStringValue(tostring(equipRow.max_combat_effectiveness))
	-- 基础属性值
	local attrLable = tolua.cast(root:getWidgetByName("Label_9"), "UILabel")
	local valueKey = CommonFunc_getEffectAttrs(baseEquip)[1]
	local valueString = CommonFunc_getAttrString(valueKey)
	if 0 == strengthenEquip[valueKey] then
		attrLable:setText(string.format("%s:%d", valueString, baseEquip[valueKey]))
	else
		attrLable:setText(string.format("%s:%d+%d", valueString, baseEquip[valueKey], strengthenEquip[valueKey]))
	end
	-- 职业
	local roleLable = tolua.cast(root:getWidgetByName("Label_2"), "UILabel")
	roleLable:setText(GameString.get("Profession")..":"..roleName)
	-- 描述
	local descLabel = tolua.cast(root:getWidgetByName("Label_6"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(320, 75))
	descLabel:setText(itemRow.describe)
	--售价
	local priceLabel = tolua.cast(root:getWidgetByName("Label_sell"), "UILabel")
	priceLabel:setText(tostring(equipRow.sell_price))
	-- 随机属性
	local randomWeaponAttr = CommonFunc_getAttrDescTable(randomEquip)
	local attrLabelName = {"Label_5", "Label_14", "Label_13", "Label_12"}
	for i=1, 4 do
		local attrLabel = tolua.cast(root:getWidgetByName(attrLabelName[i]), "UILabel")
		attrLabel:setVisible(false)
		if randomWeaponAttr[i] then
			attrLabel:setVisible(true)
			attrLabel:setText(randomWeaponAttr[i])
		end
	end
	-- 宝石孔(上限3个)
	for i=1, 3 do
		local gemIconImageView = tolua.cast(root:getWidgetByName("ImageView_price"..i), "UIImageView")
		if i <= equipRow.gem_trough then
			if i <= #gemEquip.gems then
				local gemAttrRow = ModelGem.getGemAttrRow(gemEquip.gems[i])
				gemIconImageView:loadTexture(gemAttrRow.small_icon)
				gemIconImageView:setVisible(true)
			else
				gemIconImageView:loadTexture("gem_blank.png")
			end
		else
			gemIconImageView:setVisible(false)
		end
	end
	initBtn(equipRow)
	-- 战斗力对比值
	local fightintNum = equipRow.combat_effectiveness
	local currEquip = ModelEquip.getEquipInfo(ModelEquip.getCurrEquipEx(mInstanceId))
	if currEquip then
		fightintNum = fightintNum - currEquip.combat_effectiveness
	end
	LayerBackpack.setFightingNum(fightintNum)
	TipModule.onUI(root, "ui_equipnoput")
end

-- 销毁
LayerEquipNoPut.destroy = function()
	mExistFlag = false 
end
