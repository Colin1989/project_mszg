----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-10
-- Brief:	装备穿戴界面
----------------------------------------------------------------------
LayerEquipPut = {}
LayerAbstract:extend(LayerEquipPut)
local root = nil 			--根节点
local mInstanceId = nil
local mIndex = 1			--表示当前选中的是第几个

-- 点击
LayerEquipPut.onClick = function(widget)
	TipModule.onClick(widget)
	local widgetName = widget:getName()
	if "Panel_equip_put" == widgetName or "ImageView_Select" == widgetName then
		UIManager.pop("UI_Equip_Put")
	end
end

-- 点击强化按钮
local function clickStrengthenBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		
		if CopyDateCache.getCopyStatus(LIMIT_EQIP_STREN.copy_id) ~= "pass" and tonumber(LIMIT_EQIP_STREN.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_EQIP_STREN.copy_id),LIMIT_EQIP_STREN.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		
		if ModelEquip.getEquipType(mInstanceId) == 5 then
			if  tonumber(LIMIT_JJC.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_JJC.copy_id) ~= "pass" then
				Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_JJC.copy_id),LIMIT_JJC.fbName))
				return
			end
			if LayerGameMedal.getMedalId() == nil then
				Toast.show(GameString.get("GAME_MEDAL_TIP_3"))
				return
			end
			UIManager.pop("UI_Equip_Put")
			LayerMain.pullPannel()
			setConententPannelJosn(LayerGameMedal, "GameMedal_1.json", "Layer_Game_Medal")
		else
			UIManager.pop("UI_Equip_Put")
			LayerMain.pullPannel()
			setConententPannelJosn(LayerSmithMain, "Smith_Main.json", "Panel_forge_build")
		end
		--LayerBackpack.switchUILayer("UI_strengthen", mInstanceId)
	end
end


-- 点击卸下按钮
local function clickUnloadBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local equipType = ModelEquip.getEquipType(mInstanceId)
		local equipRow, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(mInstanceId)
		
		
		local function senRequestTakeOff(equipType)
			--卸下
			BackpackLogic.requestEquipmentTakeoff(equipType)
			UIManager.pop("UI_Equip_Put")
		end
		
		if  #equipRow.gems == 0 then
			senRequestTakeOff(equipType)
		else
			local structConfirm = 
			{
				strText = GameString.get("Bag_unload_equip"),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {senRequestTakeOff, nil},		--回调函数
				buttonEvent_Param = {equipType, nil}			--函数参数
			}
			UIManager.push("UI_ComfirmDialog", structConfirm)
		end
	end
end

-- 点击镶嵌按钮
local function clickInlayBtn(typeName, widget)
	if "releaseUp" == typeName then	
		TipModule.onClick(widget)
		
		if CopyDateCache.getCopyStatus(LIMIT_GEM_INLAY.copy_id) ~= "pass" and  tonumber(LIMIT_GEM_INLAY.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_GEM_INLAY.copy_id),LIMIT_GEM_INLAY.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		UIManager.pop("UI_Equip_Put")
		--进入铁匠铺宝石镶嵌界面
		LayerMain.pullPannel()	
		LayerSmithMain.setIndex(2)
		LayerSmithGemInlay.setIndex(mIndex)
		setConententPannelJosn(LayerSmithMain, "Smith_Main.json", "Panel_forge_build")
		
	end
end

--初始化按钮事件
local function initBtn(equipRow)
	
	local itemRow = ModelEquip.getEquipRow(equipRow.temp_id)
	
	-- 强化按钮
	local strengthenBtn = root:getWidgetByName("Button_strengthen")
	strengthenBtn:registerEventScript(clickStrengthenBtn)
	-- 卸下按钮
	local unloadBtn = tolua.cast(root:getWidgetByName("Button_unload"), "UIButton")
	unloadBtn:registerEventScript(clickUnloadBtn)
	-- 镶嵌按钮
	local inlayBtn = tolua.cast(root:getWidgetByName("Button_inlay"), "UIButton")
	inlayBtn:registerEventScript(clickInlayBtn)
	-- 判断是否有宝石孔
	if 0 == equipRow.gem_trough then
		inlayBtn:setTouchEnabled(false)
		inlayBtn:loadTextureNormal("shortbutton_gray.png")
	end
	
	--侧边，按钮动画
	unloadBtn:setVisible(false)
	inlayBtn:setVisible(false)
	strengthenBtn:setVisible(false)
	
	local function callBack_1()
		Commonfunc_dropAnimation(strengthenBtn)
	end
	
	local function callBack_2()
		Commonfunc_dropAnimation(inlayBtn)
	end
	
	local function callBack_3()
		Commonfunc_dropAnimation(unloadBtn)
	end
	
	local delay = 0.1
	unloadBtn:runAction(CCCallFuncN:create(callBack_1))
	strengthenBtn:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFuncN:create(callBack_2)))
	strengthenBtn:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay*2), CCCallFuncN:create(callBack_3)))
	
end

-- 初始
LayerEquipPut.init = function(bundle)

	root = UIManager.findLayerByTag("UI_Equip_Put")
	local panel = tolua.cast(root:getWidgetByName("Panel_equip_put"), "UILayout")
	setOnClickListenner("Panel_equip_put")
	setOnClickListenner("ImageView_Select")
	
	--Log("LayerEquipPut.init************",bundle)
	mInstanceId = bundle.id
	mIndex = bundle.index
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
	LayerBackpack.setFightingNum(equipRow.combat_effectiveness)
	TipModule.onUI(panel, "ui_equipput")
end

-- 销毁
LayerEquipPut.destroy = function()
	
end

