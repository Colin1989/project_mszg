----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-4-2
-- 描述：装备强化
----------------------------------------------------------------------
LayerStrengthen = {
}

local mLayerRoot = nil
local mID = nil
local mMoneyCost = 0

-- 播放强化动画
local function playUpgradeAction(success)
	if nil == mLayerRoot then
		return
	end
	local successFrame = tolua.cast(mLayerRoot:getChildByName("ImageView_effect_frame_success"), "UIImageView")
	successFrame:stopAllActions()
	successFrame:setVisible(success)
	local failedFrame = tolua.cast(mLayerRoot:getChildByName("ImageView_effect_frame_failed"), "UIImageView")
	failedFrame:stopAllActions()
	failedFrame:setVisible(not success)
	
	-- 执行动作
	local function actionDone()
		successFrame:setVisible(false)
		failedFrame:setVisible(false)
	end
	
	local arr = CCArray:create()
	local show = CCShow:create()
	
	local frameFadeIn = CCFadeIn:create(0.5)
	local scale2 = CCScaleTo:create(0.2,1.0)
	local action = CCSpawn:createWithTwoActions(frameFadeIn,scale2)
	
	local frameFadeOut = CCFadeOut:create(0.5)
	local scale3 = CCScaleTo:create(0.2,1.1)
	local action2 = CCSpawn:createWithTwoActions(frameFadeOut,scale3)
	
	local action4 = CCEaseElasticIn:create(CCScaleTo:create(0.3,1.1))
	
	local action3 = CCEaseElasticOut:create(CCScaleTo:create(0.2,1.1))
	arr:addObject(show)
	--arr:addObject(frameFadeIn)
	--arr:addObject(action)
	--arr:addObject(action2)
	--arr:addObject(action3)
	arr:addObject(action4)
	if true == success then		
		successFrame:runAction(CCSequence:createWithTwoActions(CCSequence:create(arr), CCCallFunc:create(actionDone)))
	else
		failedFrame:runAction(CCSequence:createWithTwoActions(CCSequence:create(arr), CCCallFunc:create(actionDone)))	
	end
end

local function onClickEvent(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		if widgetName == "Button_close" then
			LayerBackpack.switchUILayer("UI_equip_body")
		elseif widgetName == "Button_Strengthen" then
			if CommonFunc_payConsume(1, mMoneyCost) then
				return
			end
			widget:setTouchEnabled(false)
			BackpackLogic.requestEquipmentStrengthen(mID)
		elseif widgetName == "Button_one_key_strenghten" then
			LayerBackpack.oneKeyStrenghten(mID)
		elseif widgetName == "Button_equip" then
			BackpackLogic.requestEquipmentPuton(mID)
		end	
	end
end

function LayerStrengthen.Action_onExit(callback_func)
	Animation_UIBag_Exit(mLayerRoot, 0.5, callback_func)
end

-- 是否以强化到最高等级
local function checkMaxLevel(bMax)
	local maxLabel = mLayerRoot:getChildByName("Label_maxLevel")
	local strengthenBtn = tolua.cast(mLayerRoot:getChildByName("Button_Strengthen"), "UIButton")
	local oneKeyStrengthenBtn = tolua.cast(mLayerRoot:getChildByName("Button_one_key_strenghten"), "UIButton")
	local oneKeyStrengthenImage = tolua.cast(mLayerRoot:getChildByName("ImageView_8801"), "UIImageView")
	if true == bMax then	-- 当前已满级
		maxLabel:setVisible(true)
		strengthenBtn:setTouchEnabled(false)
		strengthenBtn:loadTextureNormal("equipped_strengthen_buttom2.png")
		oneKeyStrengthenBtn:setTouchEnabled(false)
		oneKeyStrengthenBtn:loadTextureNormal("public_gray_buttom.png")
		oneKeyStrengthenImage:loadTexture("yijianqianghua_gray.png")
	else
		maxLabel:setVisible(false)
		strengthenBtn:setTouchEnabled(true)
		strengthenBtn:loadTextureNormal("equipped_strengthen_buttom.png")
		oneKeyStrengthenBtn:setTouchEnabled(true)
		oneKeyStrengthenBtn:loadTextureNormal("public_newbuttom2.png")
		oneKeyStrengthenImage:loadTexture("yijianqianghua.png")
	end
end

-- 设置穿戴装备按钮
local function setDressEquipBtn()
	local equipBtn = mLayerRoot:getChildByName("Button_equip")
	local currentEquipID = ModelEquip.getCurrEquipEx(mID)
	local equip = ModelEquip.getEquipInfo(mID)
	local roleType = equip.type % 10
	local canEquip = true
	if currentEquipID == mID then											-- 已装备
		canEquip = false
	elseif roleType ~= ModelPlayer.getRoleType() and roleType ~= 0 then		-- 非本职业装备
		canEquip = false
	elseif equip.equip_use_level > ModelPlayer.getLevel() then				-- 等级不足
		canEquip = false
	end
	equipBtn:setTouchEnabled(canEquip)
	equipBtn:setBright(canEquip)
end

-- 更新控件
local function updataWidget()
	local equip, baseEquip, strenghenEquip = ModelEquip.getEquipInfo(mID)
	local itemRow = LogicTable.getItemById(equip.id)
	-- 强化属性标识
	local valueKey = CommonFunc_getEffectAttrs(equip)[1]
	-- 强化属性表
	local strengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id)
	if strengthenRow then
		valueKey = strengthenRow.attr_types
	end
	local nextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	checkMaxLevel(nil == nextStrengthenRow)
	if nextStrengthenRow then
		valueKey = nextStrengthenRow.attr_types
	end
	-- 能力数值
	local valNum = {}
	valNum[1] = {baseEquip[valueKey], strenghenEquip[valueKey]}
	valNum[2] = valNum[1]
	-- 战斗力
	local fighting = {}
	fighting[1] = equip.combat_effectiveness
	fighting[2] = fighting[1]
	-- 强化等级
	local strengthenLevel = {}
	strengthenLevel[1] = equip.strengthen_level
	strengthenLevel[2] = strengthenLevel[1]
	-- 强化费用
	mMoneyCost = 0
	-- 强化成功率
	local strengthenRate = 0
	if nextStrengthenRow then
		strengthenLevel[2] = equip.strengthen_level + 1
		valNum[2] = {baseEquip[valueKey], nextStrengthenRow.attr_values}
		fighting[2] = equip.combat_effectiveness - strenghenEquip.combat_effectiveness + nextStrengthenRow.strengthen_battle_power
		
		mMoneyCost = nextStrengthenRow.need_amount
		strengthenRate = nextStrengthenRow.strengthen_rate
	end
	-- 强化金币消耗
	local moneyLabel = tolua.cast(mLayerRoot:getChildByName("Label_money"), "UILabelAtlas")
	moneyLabel:setStringValue(tostring(mMoneyCost))
	-- 强化概率
	local winLabel = tolua.cast(mLayerRoot:getChildByName("Label_win"), "UILabel")
	winLabel:setText(tostring(strengthenRate).."%")
	-- 战斗力对比值
	local fightAddLabel = tolua.cast(mLayerRoot:getChildByName("fighting_add"), "UILabelAtlas")
	fightAddLabel:setStringValue(tostring(fighting[2] - fighting[1]))
	-- 属性对比值
	local valueAddLabel = tolua.cast(mLayerRoot:getChildByName("value_add"), "UILabelAtlas")
	valueAddLabel:setStringValue(tostring((valNum[2][1] + valNum[2][2]) - (valNum[1][1] + valNum[1][2])))
	-- 
	local valueString = CommonFunc_getAttrString(valueKey)
	for i=1, 2 do
		-- 图标
		local iconImage = mLayerRoot:getChildByName("ImageView_icon_"..i)
		CommonFunc_AddGirdWidget(equip.id, 1, strengthenLevel[i], nil, iconImage)
		-- 类型
		local strEquipType = CommonFunc_GetEquipTypeString(equip.type)
		local typeLabel = tolua.cast(mLayerRoot:getChildByName("Label_type_"..i), "UILabel")
		if strengthenLevel[i] > 0 then
			strEquipType = GameString.get("Equip_strengthen", strEquipType, tostring(strengthenLevel[i]))
		end
		typeLabel:setText(strEquipType)
		-- 名称
		local nameLabel = tolua.cast(mLayerRoot:getChildByName("Label_name_"..i), "UILabel")
		nameLabel:setText(equip.name)
		-- 星级
		local starLevel = CommonFunc_getQualityInfo(itemRow.quality).star
		for j=1, 5 do
			local starImageView = mLayerRoot:getChildByName(string.format("star%d_%d", i, j))
			starImageView:setVisible(starLevel >= j)
		end
		-- 属性
		local attrLabel = tolua.cast(mLayerRoot:getChildByName("Label_attr_"..i), "UILabel")
		if 0 == valNum[i][2] then
			attrLabel:setText(string.format("%s:%d", valueString, valNum[i][1]))
		else
			attrLabel:setText(string.format("%s:%d+%d", valueString, valNum[i][1], valNum[i][2]))
		end
		-- 战斗力
		local fightLabel = tolua.cast(mLayerRoot:getChildByName("LabelAtlas_fighting_"..i), "UILabelAtlas")
		fightLabel:setStringValue(tostring(fighting[i]))
	end
	-- 战斗力对比值
	local currentEquipID = ModelEquip.getCurrEquipEx(mID)
	local currEquip, _, _, _, _ = ModelEquip.getEquipInfo(currentEquipID)
	local fightintNum = equip.combat_effectiveness
	if currEquip then
		fightintNum = fightintNum - currEquip.combat_effectiveness
	end
	LayerBackpack.setFightingNum(fightintNum)
end

-- 初始化
function LayerStrengthen.init(root, id)
	mLayerRoot = root
	mID = id
	--
	local equip = ModelEquip.getEquipInfo(id)
	local itemRow = LogicTable.getItemById(equip.id)
	-- 关闭按钮
	local closeBtn = root:getChildByName("Button_close")
	closeBtn:registerEventScript(onClickEvent)
	-- 强化按钮
	local strengthenBtn = root:getChildByName("Button_Strengthen")
	strengthenBtn:registerEventScript(onClickEvent)
	-- 一键强化按钮
	local oneKeyStrengthenBgImage = tolua.cast(root:getChildByName("ImageView_8799"), "UIImageView")
	local oneKeyStrengthenBtn = root:getChildByName("Button_one_key_strenghten")
	oneKeyStrengthenBtn:registerEventScript(onClickEvent)
	-- 装备按钮
	local equipBgImage = tolua.cast(root:getChildByName("ImageView_8800"), "UIImageView")
	local equipBtn = root:getChildByName("Button_equip")
	equipBtn:registerEventScript(onClickEvent)
	-- 按钮动画
	local strengthenBtnPos = strengthenBtn:getPosition()
	local equipBtnPos = CommonFunc_GetPos(equipBtn)
	local equipBtnBgPos = CommonFunc_GetPos(equipBgImage)
	local oneKeyStrengthenBtnPos = CommonFunc_GetPos(oneKeyStrengthenBtn)
	local oneKeyStrengthenBtnBgPos = CommonFunc_GetPos(oneKeyStrengthenBgImage)
	equipBtn:setPosition(strengthenBtnPos)
	equipBgImage:setPosition(strengthenBtnPos)
	oneKeyStrengthenBtn:setPosition(strengthenBtnPos)
	oneKeyStrengthenBgImage:setPosition(strengthenBtnPos)
	Animation_MoveTo_Rebound(equipBtn, 1, equipBtnPos)
	Animation_MoveTo_Rebound(equipBgImage, 1, equipBtnBgPos)
	Animation_MoveTo_Rebound(oneKeyStrengthenBtn, 1, oneKeyStrengthenBtnPos)
	Animation_MoveTo_Rebound(oneKeyStrengthenBgImage, 1, oneKeyStrengthenBtnBgPos)
	-- 更新控件
	setDressEquipBtn()
	updataWidget()
end

-- 销毁
function LayerStrengthen.destroy()
	mLayerRoot = nil
end

--
local function playLoadingAction(num)
	local widget = tolua.cast(mLayerRoot:getChildByName("ImageView_loading"), "UIImageView")
	widget:setScaleX(0.0)
	local scaleAction = CCScaleTo:create(0.6, num/100, 1.0)
	widget:runAction(CCEaseSineIn:create(scaleAction))
end

-- 收到装备强化
local function handleEquipmentStrengthen(data)
	if nil == mLayerRoot then
		return
	end
	local strengthenBtn = mLayerRoot:getChildByName("Button_Strengthen")
	strengthenBtn:setTouchEnabled(true)
	if true == data.success then		-- 成功
		--Toast.Textstrokeshow(GameString.get("Equip_STR_04"),ccc3(255,255,255),ccc3(0,0,0),30)
		updataWidget()
		playLoadingAction(100)
	end
	playUpgradeAction(data.success)
end

-- 收到穿上装备
local function handleDressEquip(success)
	if nil == mLayerRoot or false == success then
		return
	end
	setDressEquipBtn()
end

EventCenter_subscribe(EventDef["ED_EQUIPMENT_STRENGTHEN"], handleEquipmentStrengthen)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_PUTON"], handleDressEquip)
