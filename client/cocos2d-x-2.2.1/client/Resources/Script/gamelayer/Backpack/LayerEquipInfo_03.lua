----------------------------------------------------------------------
-- 装备详情界面03，对比界面，嵌套在背包界面内
----------------------------------------------------------------------
LayerEquipInfo_03 = {}
local mInstanceId = 0
local mLayerRoot = nil
local mEquipInfo = nil

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		LayerBackpack.switchUILayer("UI_equip_body")
	end
end

-- 点击出售按钮
local function clickSellBtn(typeName, widget)
	if "releaseUp" == typeName then
		-- local function callback()
			LayerBackpack.callback_seed_sale_item(mInstanceId,1,item_type["equipment"])
			LayerBackpack.switchUILayer("UI_equip_body")
		-- end
		-- local diaMsg = 
		-- {
			-- strText = string.format(GameString.get("EQUIPTRAIN_STR_06", mEquipInfo.sell_price)),
			-- buttonCount = 2,
			-- buttonName = {GameString.get("sure"), GameString.get("cancle")},
			-- buttonEvent = {callback, nil}
		-- }
		-- UIManager.push("UI_ComfirmDialog", diaMsg)
	end
end

-- 点击装备按钮
local function clickPutBtn(typeName, widget)
	if "releaseUp" == typeName then
	
		local equipRow, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(mInstanceId)
		
		
		if  #equipRow.gems == 0 then
			BackpackLogic.requestEquipmentPuton(mInstanceId)
		else
			local structConfirm = 
			{
				strText = GameString.get("Bag_change_equip"),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {BackpackLogic.requestEquipmentPuton, nil},		--回调函数
				buttonEvent_Param = {mInstanceId, nil}			--函数参数
			}
			UIManager.push("UI_ComfirmDialog", structConfirm)
		end
		
	end
end

-- 显示面板信息,bCurrent:是否为当前装备
local function showPanel(panel, instanceId, bCurrent)
	local equip, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(instanceId)
	local itemRow = LogicTable.getItemById(equip.id)
	local equipType, typeName, roleType, roleName = ModelEquip.getEquipType(instanceId)
	if instanceId == mInstanceId then
		mEquipInfo = equip
	end
	--当前穿戴标识
	local current_wight = panel:getChildByName("ImageView_CurrentTag")
	current_wight:setVisible(bCurrent)
	-- 等级
	local levelLabel = tolua.cast(panel:getChildByName("Label_8"), "UILabel")
	levelLabel:setText(string.format("Lv.%s", equip.equip_use_level))
	levelLabel:setColor(BackpackLogic.getColour("level", equip.equip_use_level))
	-- 名称
	local nameLable = tolua.cast(panel:getChildByName("Label_0"), "UILabel")
	nameLable:setText(equip.name)
	nameLable:setColor(BackpackLogic.getColour("quality", itemRow.quality))
	-- 星级
	local starLevel = CommonFunc_getQualityInfo(itemRow.quality).star
	for i=1, 5 do
		local starImageView = panel:getChildByName("star"..i)
		starImageView:setVisible(starLevel >= i)
	end
	-- 装备类别
	local typeLable = tolua.cast(panel:getChildByName("Label_7"), "UILabel")
	if equip.strengthen_level > 0 then
		typeName = GameString.get("Equip_strengthen", typeName, tostring(equip.strengthen_level))
	end
	typeLable:setText(string.format("%s", typeName))
	-- 图标
	local iconImageView = tolua.cast(panel:getChildByName("ImageView_Head"), "UIImageView")
	iconImageView:loadTexture(itemRow.icon)
	CommonFunc_SetQualityFrame(iconImageView, itemRow.quality, equip.strengthen_level)	-- 装备品质框
	-- 当前战斗力
	local curAbilityLable = tolua.cast(panel:getChildByName("ability"), "UILabelAtlas")
	curAbilityLable:setStringValue(tostring(equip.combat_effectiveness))
	-- 最大战斗力
	local maxAbilityLable = tolua.cast(panel:getChildByName("ability_max"), "UILabelAtlas")
	maxAbilityLable:setStringValue(tostring(equip.max_combat_effectiveness))
	-- 当前战斗力对比
	local curAbilityImabeView = tolua.cast(panel:getChildByName("ImageView_ability"), "UIImageView")
	curAbilityImabeView:setVisible(not bCurrent)
	local curAbilityAddLabel = tolua.cast(panel:getChildByName("ability_add"), "UILabelAtlas")
	curAbilityAddLabel:setVisible(not bCurrent)
	-- 最大战斗力对比
	local maxAbilityImabeView = tolua.cast(panel:getChildByName("ImageView_6264"), "UIImageView")
	maxAbilityImabeView:setVisible(not bCurrent)
	local maxAbilityAddLabel = tolua.cast(panel:getChildByName("ability_add_2"), "UILabelAtlas")
	maxAbilityAddLabel:setVisible(not bCurrent)
	--
	local currentEquipID = ModelEquip.getCurrEquipEx(mInstanceId)
	local currEquip = ModelEquip.getEquipInfo(currentEquipID)
	if false == bCurrent then
		-- 当前
		local curDiff = equip.combat_effectiveness - currEquip.combat_effectiveness
		if 0 == curDiff then
			curAbilityImabeView:setVisible(false)
			curAbilityAddLabel:setVisible(false)
		elseif curDiff > 0 then
			curAbilityImabeView:loadTexture("equipped_strengthen_modify04.png")
			curAbilityAddLabel:setColor(ccc3(0, 255, 0))
		elseif curDiff < 0 then
			curAbilityImabeView:loadTexture("equipped_strengthen_modify06.png")
			curAbilityAddLabel:setColor(ccc3(255, 0, 0))
		end
		curAbilityAddLabel:setStringValue(tostring(math.abs(curDiff)))
		-- 最大
		local maxDiff = equip.max_combat_effectiveness - currEquip.max_combat_effectiveness
		if 0 == maxDiff then
			maxAbilityImabeView:setVisible(false)
			maxAbilityAddLabel:setVisible(false)
		elseif maxDiff > 0 then
			maxAbilityImabeView:loadTexture("equipped_strengthen_modify04.png")
			maxAbilityAddLabel:setColor(ccc3(0, 255, 0))
		elseif maxDiff < 0 then
			maxAbilityImabeView:loadTexture("equipped_strengthen_modify06.png")
			maxAbilityAddLabel:setColor(ccc3(255, 0, 0))
		end
		maxAbilityAddLabel:setStringValue(tostring(math.abs(maxDiff)))
	end
	-- 基础属性值
	local attrLable = tolua.cast(panel:getChildByName("Label_9"), "UILabel")
	local valueKey = CommonFunc_getEffectAttrs(baseEquip)[1]
	local valueString = CommonFunc_getAttrString(valueKey)
	if 0 == strengthenEquip[valueKey] then
		attrLable:setText(string.format("%s:%d", valueString, baseEquip[valueKey]))
	else
		attrLable:setText(string.format("%s:%d+%d", valueString, baseEquip[valueKey], strengthenEquip[valueKey]))
	end
	-- 职业
	local roleLable = tolua.cast(panel:getChildByName("Label_2"), "UILabel")
	roleLable:setText(GameString.get("Profession")..":"..roleName)
	roleLable:setColor(BackpackLogic.getColour("roletype", roleType))
	-- 随机武器属性(上限3个)
	local randomAttr = CommonFunc_getAttrDescTable(randomEquip)
	local randomAttrLabelName = {"Label_4", "Label_10", "Label_5"}
	for i=1, 3 do
		local randomAttrLable = tolua.cast(panel:getChildByName(randomAttrLabelName[i]), "UILabel")
		if nil == randomAttr[i] then
			randomAttrLable:setVisible(false)
		else
			randomAttrLable:setVisible(true)
			randomAttrLable:setText(randomAttr[i])
		end
	end
	-- 宝石孔(上限3个)
	local gemLabel = panel:getChildByName("Label_11")
	gemLabel:setVisible(0 ~= gemEquip.gem_trough)
	for i=1, 3 do
		local gemIconImageView = tolua.cast(panel:getChildByName("ImageView_price"..i), "UIImageView")
		-- 宝石孔数量
		if i <= gemEquip.gem_trough then
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
	-- 宝石孔属性(上限3个)
	local gemAbilityTable = {}
	for k1, v1 in pairs(gemEquip.gems) do
		local attrTemp = ModelGem.getGemAttrRow(v1)
		local strTable = CommonFunc_getAttrDescTable(attrTemp)
		for k2, v2 in pairs(strTable) do
			table.insert(gemAbilityTable, v2)
		end
	end
	for i=1, 3 do
		local gemAbilityLable = tolua.cast(panel:getChildByName("gem"..i), "UILabel")
		if nil == gemAbilityTable[i] then
			gemAbilityLable:setVisible(false)
		else
			gemAbilityLable:setText(gemAbilityTable[i])
			gemAbilityLable:setVisible(true)
		end
	end
	-- 描述
	local descLabel = tolua.cast(panel:getChildByName("Label_6"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(250, 75))
	descLabel:setText(itemRow.describe)
	-- 价格
	local priceLable = tolua.cast(panel:getChildByName("LabelAtlas_price"), "UILabelAtlas")
	priceLable:setStringValue(tostring(equip.sell_price))
	-- 战斗力对比值
	local fightintNum = equip.combat_effectiveness
	if currEquip then
		fightintNum = fightintNum - currEquip.combat_effectiveness
	end
	LayerBackpack.setFightingNum(fightintNum)
end

-- 初始化,param={leftId=左边实例id,rightId=右边实例id}
function LayerEquipInfo_03.init(root,param)
	mLayerRoot = root
	mInstanceId = param.rightId
	-- 左/右边面板
	local leftPanel = root:getChildByName("LeftPanel")
	local rightPanel = leftPanel:clone()
	rightPanel:retain()
	local pos = CommonFunc_GetPos(leftPanel)
	rightPanel:setPosition(ccp(pos.x + 278, pos.y))
	root:addChild(rightPanel)
	-- 显示面板
	showPanel(leftPanel, param.leftId, true)
	showPanel(rightPanel, param.rightId, false)
	-- 关闭按钮
	local closeBtn = root:getChildByName("Button_Close")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 出售按钮
	local sellBtn = root:getChildByName("Button_1")
	sellBtn:registerEventScript(clickSellBtn)
	-- 装备按钮
	local putBtn = root:getChildByName("Button_2")
	putBtn:registerEventScript(clickPutBtn)
	
end

-- 销毁
function LayerEquipInfo_03.destroy()
	mLayerRoot = nil
end

--结束动画
function LayerEquipInfo_03.Action_onExit(callback_func)
	Animation_UIBag_Exit(mLayerRoot,0.5,callback_func)
end

local function handleEquipmentPuton(success)
	if nil == mLayerRoot or false == success then
		return
	end
	LayerBackpack.switchUILayer("UI_equip_body")
end

EventCenter_subscribe(EventDef["ED_EQUIPMENT_PUTON"], handleEquipmentPuton)
