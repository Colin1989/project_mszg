----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面（装备强化）
----------------------------------------------------------------------
local mLayerRoot = nil	
local m_moneyCost = 0		--强化所需费用
local mcurEquipList = nil	--当前身上装备的所有实例ID(包括装备的和没有装备的)
local m_clickEquip = 1 		--表示当前点击的是那件装备（默认选中第一件）

LayerSmithStrength = {}
LayerAbstract:extend(LayerSmithStrength)

-----------------------------------------动画-------------------------------------------
--强化成功或失败动画
local function playStrenAction(success)
	if nil == mLayerRoot then
		return
	end
	
	local scroll = tolua.cast(mLayerRoot:getChildByName("ScrollView_Strengthen"), "UIScrollView")
	local panel = tolua.cast(scroll:getChildByName("root"..m_clickEquip), "UIImageView")
	
	--print("playStrenAction****************",m_clickEquip,panel,"root"..m_clickEquip)
	local resultImg = tolua.cast(panel:getChildByName("strenResultImg"), "UIImageView")
	if true == success then		
		resultImg:loadTexture("strength_suc.png")
	else
		resultImg:loadTexture("strength_fail.png")
	end
	resultImg:setScale(0)
	resultImg:stopAllActions()
	
	-- 执行动作
	local function actionDone()
		resultImg:setVisible(false)
	end
	
	local frameFadeIn = CCFadeIn:create(0.2)
	local scale2 = CCScaleTo:create(0.1,0)
	local action = CCSpawn:createWithTwoActions(frameFadeIn,scale2)
	
	local arr = CCArray:create()
	arr:addObject(CCShow:create())
	arr:addObject(action)
	arr:addObject(CCEaseElasticOut:create(CCScaleTo:create(0.3,1.2)))
	arr:addObject(CCCallFunc:create(actionDone))
	arr:addObject(CCDelayTime:create(0.5))
	--arr:addObject(CCCallFunc:create(setFullLevel))
	resultImg:runAction(CCSequence:create(arr))
end

----------------------------------------------------------------------------------
--进阶
local function clickUpgrade(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		local index =tonumber(string.sub(widgetName,-1,-1))
		
		m_clickEquip = index
		local tb = {}
		tb.instId = mcurEquipList[tonumber(index)]
		tb.index = index
		UIManager.push("UI_Smith_upGrade",tb)
	end
end

--强化
local function clickStrength(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		local index =tonumber(string.sub(widgetName,-1,-1))
		--print("clickStrength*******************",index,widgetName)
		m_clickEquip = index
		
		if index == 5 then
			if  tonumber(LIMIT_JJC.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_JJC.copy_id) ~= "pass" then
				Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_JJC.copy_id),LIMIT_JJC.fbName))
				return
			end
			if LayerGameMedal.getMedalId() == nil then
				Toast.show(GameString.get("GAME_MEDAL_TIP_3"))
				return
			end
			LayerMain.pullPannel()
			setConententPannelJosn(LayerGameMedal, "GameMedal_1.json", "Layer_Game_Medal")
		else
			local equip = ModelEquip.getEquipInfo(mcurEquipList[tonumber(index)])
			mNextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
			if mNextStrengthenRow then
				m_moneyCost = mNextStrengthenRow.need_amount
			end
			if CommonFunc_payConsume(1, m_moneyCost) then
				return
			end
			
			BackpackLogic.requestEquipmentStrengthen(mcurEquipList[tonumber(index)])
			widget:setTouchEnabled(false)
			local function actionDone()
				widget:setTouchEnabled(true)
			end
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(0.5))
			arr:addObject(CCCallFunc:create(actionDone))
			widget:runAction(CCSequence:create(arr))
		end
	end
end

--一键强化
local function clickOneKeyStrength(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		local index =string.sub(widgetName,-1,-1)
		m_clickEquip = tonumber(index)
		--print("clickOneKeyStrength*******************",index,widgetName)
		LayerBackpack.oneKeyStrenghten(mcurEquipList[tonumber(index)])	
	end
end

local anchorPoint = ccp(0.5,0.5)
local nameStrenColor = ccc3(227,201,36)
local whiteColor = ccc3(255,255,255)
local afterColor =ccc3(154,227,11)

--创建没有装备的cell
local function createNoEquipCell(index)
	--根节点
	local rootImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(546,157), "public2_bg_22.png", "rootImg",1 )
	rootImg:setScale9Enabled(true)
	rootImg:setCapInsets(CCRectMake(15, 15, 1, 1))
	--装备图标背景
	local imgBg = CommonFunc_createUIImageView(anchorPoint, ccp(-211,0), CCSizeMake(105,123), "public2_bg_05.png", "imgBg",1 )
	imgBg:setScale9Enabled(true)
	imgBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(imgBg)
	--装备图标
	local img = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(94,94), 
			string.format("equip_none_0%d.png",index), "img",1 )
	imgBg:addChild(img)
	--未装备图片
	local noEquipBg = CommonFunc_createUIImageView(anchorPoint, ccp(46,3), CCSizeMake(188,58), "text_weizhuangbei.png", "noEquipBg",1 )
	rootImg:addChild(noEquipBg)
	--装备强化成功与失败图片
	local strenResultImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(330,90), "touming.png", "strenResultImg",25 )
	rootImg:addChild(strenResultImg)
	--获得的方式
	local getText = GameString.get("EQUIPTRAIN_GET_01")
	if tonumber(index) >= 1 and tonumber(index) <= 4 then
		getText = GameString.get("EQUIPTRAIN_GET_01")
	elseif tonumber(index) == 5 then
		getText = GameString.get("EQUIPTRAIN_GET_02")
	elseif tonumber(index) == 6 then
		getText = GameString.get("EQUIPTRAIN_GET_03")
	end
	
	local getLbl = CommonFunc_createUILabel(anchorPoint, ccp(47,-42), nil, 20,ccc3(125,119,120), getText, 1, 1)	
    rootImg:addChild(getLbl)
	return rootImg
end

--创建装备进阶cell
local function createUpgradeCell(nameText,levelNum,itemId,instId,index)
	--根节点
	local rootImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(546,157), "public2_bg_22.png", "rootImg"..index,1 )
	rootImg:setScale9Enabled(true)
	rootImg:setCapInsets(CCRectMake(15, 15, 1, 1))
	--装备图标背景
	local imgBg = CommonFunc_createUIImageView(anchorPoint, ccp(-211,0), CCSizeMake(105,123), "public2_bg_05.png", "imgBg",1 )
	imgBg:setScale9Enabled(true)
	imgBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(imgBg)
	--装备图标
	local img = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(94,94), "uibag_bg_framer.png", "img",1 )
	CommonFunc_AddGirdWidget(itemId, 1, levelNum, nil,img)		
	img:setTouchEnabled(true)
	imgBg:addChild(img)
	FactoryAnimation_showSquareParticle("skill_selected.plist", CCSizeMake(91, 91), img, true)
	--图标长按事件
	local function longClickGrid(img)
		local param = {}
		param.instId = instId				
		param.itemId = itemId				
		local position,direct = CommonFuncJudgeInfoPosition(img)
		param.position = position
		param.direct = direct
		UIManager.push("UI_EquipInfo",param)
	end
	UIManager.registerEvent(img, callBackFunc, longClickGrid, CommonFunc_longEnd_equip)
	--强化名字bg
	local nameBg = CommonFunc_createUIImageView(anchorPoint, ccp(-14,44), CCSizeMake(258,34), "public2_bg_06.png", "img",1 )
	nameBg:setScale9Enabled(true)
	nameBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(nameBg)
	--强化名字
	local  name = CommonFunc_createUILabel(anchorPoint, ccp(0,0), nil, 20,nameStrenColor, nameText, 1, 1)	
    nameBg:addChild(name)
	--强化前背景
	local curBg = CommonFunc_createUIImageView(anchorPoint, ccp(-93,-20), CCSizeMake(116,71), "public2_bg_05.png", "img",1 )
	curBg:setScale9Enabled(true)
	curBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(curBg)
	--当前等级
	local curLevel = CommonFunc_createUILabel(ccp(0,0), ccp(-54,6), nil, 20,nameStrenColor,GameString.get("Public_DJ_VAL",levelNum), 1, 1)	
	curBg:addChild(curLevel)
	--当前属性
	local  curAtt = CommonFunc_createUILabel(ccp(0,0), ccp(-54,-25), nil, 20,afterColor, "", 1, 1)	
    curAtt:setName("label_harm1")
	curBg:addChild(curAtt)
	--箭头
	local arrow = CommonFunc_createUIImageView(anchorPoint, ccp(-14,-21), CCSizeMake(29,26), "equipped_strengthen_modify07.png", "img",1 )
	rootImg:addChild(arrow)
	--强化后背景
	local nextBg = CommonFunc_createUIImageView(anchorPoint, ccp(64,-20), CCSizeMake(116,71), "public2_bg_05.png", "img",1 )
	nextBg:setScale9Enabled(true)
	nextBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(nextBg)
	--进阶后等级
	local nextLevel = CommonFunc_createUILabel(ccp(0,0), ccp(-54,6), nil, 20,nameStrenColor,GameString.get("Public_DJ_VAL",0), 1, 1)	
	nextBg:addChild(nextLevel)
	--强化后属性
	local  nextAtt = CommonFunc_createUILabel(ccp(0,0), ccp(-54,-25), nil, 20,afterColor, "", 1, 1)	
    nextAtt:setName("label_harm2")
	nextBg:addChild(nextAtt)
	--进阶btn
	local  upgradeBtn = CommonFunc_createUIButton(anchorPoint,ccp(197,0),CCSizeMake(140,58),27,
				ccc3(255,225,68),"",string.format("upgradeBtn_%d",index),"public_newbuttom_4.png","public_newbuttom_4.png",1)
	rootImg:addChild(upgradeBtn)
	upgradeBtn:registerEventScript(clickUpgrade)
	--进阶图片
	local upgradeImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(70,37), "text_jinjie.png", "upgradeImg",1 )
	upgradeBtn:addChild(upgradeImg)
	--装备强化成功与失败图片
	local strenResultImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(330,90), "touming.png", "strenResultImg",25 )
	rootImg:addChild(strenResultImg)
	return rootImg
end

--创建装备强化cell
local function createStrengthCell(nameText,levelNum,itemId,instId,coinNum,attZHIText,flag,index)
	--根节点
	local rootImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(546,157), "public2_bg_22.png", "rootImg"..index,1 )
	rootImg:setScale9Enabled(true)
	rootImg:setCapInsets(CCRectMake(15, 15, 1, 1))
	--装备图标背景
	local imgBg = CommonFunc_createUIImageView(anchorPoint, ccp(-211,0), CCSizeMake(105,123), "public2_bg_05.png", "imgBg",1 )
	imgBg:setScale9Enabled(true)
	imgBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	imgBg:setTouchEnabled(true)
	rootImg:addChild(imgBg)
	--装备图标
	local img = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(94,94), "uibag_bg_framer.png", "img",1 )
	CommonFunc_AddGirdWidget(itemId, 1, levelNum, nil, img)		
	imgBg:addChild(img)
	img:setTouchEnabled(true)
	FactoryAnimation_showSquareParticle("skill_selected.plist", CCSizeMake(91, 91), img, false)
	--图标长按事件
	local function longClickGrid(img)
		local param = {}
		param.instId = instId				
		param.itemId = itemId				
		local position,direct = CommonFuncJudgeInfoPosition(img)
		param.position = position
		param.direct = direct
		UIManager.push("UI_EquipInfo",param)
	end
	UIManager.registerEvent(img, callBackFunc, longClickGrid, CommonFunc_longEnd_equip)
	--强化名字bg
	local nameBg = CommonFunc_createUIImageView(anchorPoint, ccp(-13,53), CCSizeMake(258,34), "public2_bg_06.png", "img",1 )
	nameBg:setScale9Enabled(true)
	nameBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(nameBg)
	--强化名字
	local  name = CommonFunc_createUILabel(anchorPoint, ccp(0,0), nil, 20,nameStrenColor, nameText, 1, 1)	
    nameBg:addChild(name)
	--等级字
	local  levelZHI = CommonFunc_createUILabel(anchorPoint, ccp(-130,15), nil, 20,nameStrenColor, GameString.get("Game_Rank_Lists_t3"), 1, 1)	
    rootImg:addChild(levelZHI)
	--等级背景
	local levelBg = CommonFunc_createUIImageView(anchorPoint, ccp(10,15), CCSizeMake(210,27), "public2_bg_05.png", "img",1 )
	levelBg:setScale9Enabled(true)
	levelBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(levelBg)
	--当前等级
	local curLevel = CommonFunc_createUILabel(anchorPoint, ccp(-58,0), nil, 20,whiteColor,levelNum, 1, 1)	
    levelBg:addChild(curLevel)
	--强化后等级
	local strenLevel = 0
	if flag == false then
		strenLevel = CommonFunc_createUILabel(anchorPoint, ccp(56,0), nil, 20,whiteColor,levelNum +1, 1, 1)	
	else
		strenLevel = CommonFunc_createUILabel(anchorPoint, ccp(56,0), nil, 20,whiteColor,levelNum, 1, 1)
	end
    levelBg:addChild(strenLevel)
	--等级箭头
	local levelArrow = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(66,78), "equipped_strengthen_modify05.png", "img",1 )
	levelArrow:setScale(0.4)
	levelBg:addChild(levelArrow)
	--属性字
	local attZHI= CommonFunc_createUILabel(anchorPoint, ccp(-130,-19), nil, 20,nameStrenColor, attZHIText, 1, 1)	
    rootImg:addChild(attZHI)
	--属性背景
	local attBg = CommonFunc_createUIImageView(anchorPoint, ccp(10,-19), CCSizeMake(210,27), "public2_bg_05.png", "attBg",1 )
	attBg:setScale9Enabled(true)
	attBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(attBg)
	
	--当前属性
	local curAtt= CommonFunc_createUILabel(anchorPoint, ccp(-59,0), nil, 20,nameStrenColor, "", 1, 1)	
    curAtt:setName("Label_attr_1")
	attBg:addChild(curAtt)
	--属性箭头
	local attArrow = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(66,78), "equipped_strengthen_modify05.png", "img",1 )
	attArrow:setScale(0.4)
	attBg:addChild(attArrow)
	--强化后属性
	local afterAtt= CommonFunc_createUILabel(anchorPoint, ccp(56,0), nil, 20,nameStrenColor, "", 1, 1)	
    afterAtt:setName("Label_attr_2")
	attBg:addChild(afterAtt)
	
	if index == 5 then
		--强化按钮													--事件有待添加？？？？？？？？？？？？？
		local  strenBtn = CommonFunc_createUIButton(anchorPoint,ccp(197,0),CCSizeMake(140,58),27,
					ccc3(255,225,68),"",string.format("strenBtn_%d",index),"public_newbuttom.png","public_newbuttom.png",1)
		rootImg:addChild(strenBtn)
		--强化图片
		local strenImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(69,34), "text_qianghua.png", "strenImg",1 )
		strenBtn:addChild(strenImg)
		
		--满级图片
		local fullImg = CommonFunc_createUIImageView(anchorPoint, ccp(184,0), CCSizeMake(80,80), "herobag_manji.png", "fullImg",1 )
		rootImg:addChild(fullImg)
		fullImg:setScale(0.8)
		if flag == false then			--表示还可以强化
			strenBtn:setVisible(true)
			strenBtn:setTouchEnabled(true)
			strenBtn:registerEventScript(clickStrength)
			fullImg:setVisible(false)
		else							--表时不能强化，也不能进阶了，已经满级了
			strenBtn:setVisible(false)
			strenBtn:setTouchEnabled(false)
			fullImg:setVisible(true)
		end
		
		--装备强化成功与失败图片
		local strenResultImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(330,90), "touming.png", "strenResultImg",25 )
		rootImg:addChild(strenResultImg)
		
		return rootImg
	end
	
	--强化按钮													--事件有待添加？？？？？？？？？？？？？
	local  strenBtn = CommonFunc_createUIButton(anchorPoint,ccp(197,30),CCSizeMake(140,58),27,
				ccc3(255,225,68),"",string.format("strenBtn_%d",index),"public_newbuttom.png","public_newbuttom.png",1)
	rootImg:addChild(strenBtn)
	--强化图片
	local strenImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(69,34), "text_qianghua.png", "strenImg",1 )
	strenBtn:addChild(strenImg)
	--一键强化按钮
	local  onekeyStrenBtn = CommonFunc_createUIButton(anchorPoint,ccp(197,-33),CCSizeMake(140,58),27,
				ccc3(255,225,68),"",string.format("onekeyStrenBtn_%d",index),"public_newbuttom_4.png","public_newbuttom_4.png",1)
	rootImg:addChild(onekeyStrenBtn)
	--满级图片
	local fullImg = CommonFunc_createUIImageView(anchorPoint, ccp(184,0), CCSizeMake(80,80), "herobag_manji.png", "fullImg",1 )
	rootImg:addChild(fullImg)
	fullImg:setScale(0.8)
	if flag == false then			--表示还可以强化
		onekeyStrenBtn:setVisible(true)
		strenBtn:setVisible(true)
		onekeyStrenBtn:setTouchEnabled(true)
		strenBtn:setTouchEnabled(true)
		onekeyStrenBtn:registerEventScript(clickOneKeyStrength)
		strenBtn:registerEventScript(clickStrength)
		fullImg:setVisible(false)
	else							--表时不能强化，也不能进阶了，已经满级了
		onekeyStrenBtn:setVisible(false)
		strenBtn:setVisible(false)
		onekeyStrenBtn:setTouchEnabled(false)
		strenBtn:setTouchEnabled(false)
		fullImg:setVisible(true)
	end
	--一键强化图片
	local onekeyStrenImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(117,30), "yijianqianghua.png", "onekeystrenImg",1 )
	onekeyStrenBtn:addChild(onekeyStrenImg)
	--花费金币图片
	local costCoinImg = CommonFunc_createUIImageView(anchorPoint, ccp(-104,-56), CCSizeMake(92,20), "huafeijinbi.png", "costCoinImg",1 )
	rootImg:addChild(costCoinImg)
	--金币背景
	local coinBg = CommonFunc_createUIImageView(anchorPoint, ccp(25,-56), CCSizeMake(137,30), "public2_bg_05.png", "coinBg",1 )
	coinBg:setScale9Enabled(true)
	coinBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	rootImg:addChild(coinBg)
	--金币图片
	local coinImg = CommonFunc_createUIImageView(anchorPoint, ccp(-56,-2), CCSizeMake(36,38), "goldicon_02.png", "coinImg",1 )
	coinBg:addChild(coinImg)
	--金币lbl
	local  coinLbl = CommonFunc_createUILabel(ccp(0,0.5), ccp(-29,0), nil, 20,whiteColor, coinNum, 1, 1)	
    coinLbl:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	coinBg:addChild(coinLbl)
	--装备强化成功与失败图片
	local strenResultImg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(330,90), "touming.png", "strenResultImg",25 )
	rootImg:addChild(strenResultImg)
	return rootImg
end

---------------------------------------------------------------------------
--获得装备基础属性
local function getEquipDetailInfo(instId)
	--装备强化
	local equip, baseEquip, strenghenEquip = ModelEquip.getEquipInfo(instId) -- ItemData.instId 装备的实例id
	local itemRow = LogicTable.getItemById(equip.id)    --equip.id 装备模板id
	-- 强化属性标识
	local valueKey = CommonFunc_getEffectAttrs(equip)[1]
	-- 强化属性表
	local strengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id)
	if strengthenRow then
		valueKey = strengthenRow.attr_types
	end
	local valueString = CommonFunc_getAttrString(valueKey)
	local valNum = {baseEquip[valueKey], strenghenEquip[valueKey]}
	return equip,valueString,valNum,baseEquip,strenghenEquip,valueKey
end
----------------------------------------------------------------------
--判断该装备是否可以进阶
local function juegeYNShowUpgrade(equipData)
	-- 该装备不可晋阶
	local equipRow = ModelEquip.getEquipRow(equipData.temp_id)
	if 0 == equipRow.advance_id then 
		return 2
	end
	-- 强化等级不足
	local equip, _, _, _, _ = ModelEquip.getEquipInfo(equipData.equipment_id)
	local nextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	if nil ~= nextStrengthenRow then
		return 3
	end
	return  0
end

--初始化进阶cell数据
local function initUpgradeCellData( equip,valueString,valNum,instId,index)
	local cellBg = createUpgradeCell(equip.name,equip.strengthen_level,equip.temp_id,instId,index)
	local labelHarm1 = CommonFunc_getLabelByName(cellBg, "label_harm1")
	
	if 0 == valNum[2] then
		labelHarm1:setText(string.format("%s:%d", valueString, valNum[1]))
	else
		labelHarm1:setText(string.format("%s:%d", valueString, valNum[1] + valNum[2]))
	end
	local data3 = LogicTable.getAdvanceInfoById(equip.temp_id)
	local oldItemId = equip.temp_id
	local oldLv = equip.equip_level
	equip.temp_id = data3.advance_id
	local data4 = ModelEquip.getEquipInfo(equip.equipment_id)
	local data5 = LogicTable.getItemById(equip.temp_id)
	local equipRow = ModelEquip.getEquipRow(equip.temp_id)
	valueKey = CommonFunc_getEffectAttrs(equipRow)[1]
	local valNum2 = equipRow[valueKey]
	equip.temp_id = oldItemId
	equip.equip_level = oldLv
	local labelHarm2 = CommonFunc_getLabelByName(cellBg, "label_harm2")
	labelHarm2:setText(string.format("%s:%d", tostring(valueString), tonumber(valNum2)))
	return cellBg
end

--初始化强化cell数据
local function initStrengthCellData( equip,valueString,valNum,instId,index,baseEquip,strenghenEquip,valueKey)
	local NextStrengthenRow = nil
	NextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	cclog("=======================================>initStrengthCellData:")
	Log(equip)
	Log(NextStrengthenRow)
	
	if NextStrengthenRow then
		valueKey = NextStrengthenRow.attr_types
	end
	-- 能力数值
	local valNum = {}
	valNum[1] = {baseEquip[valueKey], strenghenEquip[valueKey]}
	valNum[2] = valNum[1]
	-- 强化等级
	local strengthenLevel = {}
	strengthenLevel[1] = equip.strengthen_level
	strengthenLevel[2] = strengthenLevel[1]
	-- 强化费用
	moneyCost = 0
	-- 强化附加属性表
	if NextStrengthenRow then
		strengthenLevel[2] = equip.strengthen_level + 1
		valNum[2] = {baseEquip[valueKey], NextStrengthenRow.attr_values}
		moneyCost = NextStrengthenRow.need_amount
	end
	local valueString = CommonFunc_getAttrString(valueKey)
	local maxFlag =  (nil == NextStrengthenRow)
	local cellBg = createStrengthCell(equip.name,strengthenLevel[1],equip.id,instId,moneyCost,valueString,maxFlag,index)
	
	for i = 1, 2 do
		-- 属性
		local attrLabel = tolua.cast(cellBg:getChildByName("Label_attr_"..i), "UILabel")
		
		if 0 == valNum[i][2] then
			attrLabel:setText(valNum[i][1])
		else
			attrLabel:setText( valNum[i][1] + valNum[i][2] )
		end
	end
	return cellBg
end
--初始化scroll数据
local function initScrollData(cellBg,instId,index)
	if nil == instId then			--没装备
		rootImg = createNoEquipCell(index)
	else
		local  equip,valueString,valNum,baseEquip,strenghenEquip,valueKey = getEquipDetailInfo(instId)
		if  0 == juegeYNShowUpgrade(equip)  then		--可进阶
			rootImg = initUpgradeCellData( equip,valueString,valNum,instId,index)
		else											--不可进阶，可强化
			rootImg = initStrengthCellData(equip,valueString,valNum,instId,index,baseEquip,strenghenEquip,valueKey)
		end
	end
	cellBg:addChild(rootImg)
end

--更新cell数据()
local function updateCell(instId,index)
	print("updateCell*******************",index,m_clickEquip,instId)
	local cellBg = tolua.cast(mLayerRoot:getChildByName("root"..m_clickEquip), "UIImageView")
	cellBg:removeAllChildren()
	initScrollData(cellBg,instId,index)
	
end
--------------------------------------------------------------
--加载列表
local function addScrollViewList()
	if mLayerRoot == nil then
		return
	end
	local scroll = tolua.cast(mLayerRoot:getChildByName("ScrollView_Strengthen"), "UIScrollView")
	
	mcurEquipList = ModelEquip.getCurrEquipList()
	local data = {}
	for i= 1,6,1 do
		local ItemData = {}
		if nil == mcurEquipList[i] then
			ItemData.icon = string.format("equip_none_0%d.png",i)
		else
			ItemData.instId = mcurEquipList[i]
		end
		ItemData.index = i
		table.insert(data,ItemData)
	end
	Log(mcurEquipList, data)
	
	--创建列表单元格
	local function createCell(cellBg, ItemData, index)
		cellBg = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(546,157), "touming.png", "root"..ItemData.index,1 )		--单元格根节点
		
		initScrollData(cellBg,ItemData.instId,ItemData.index)
		
		return cellBg
	end
	UIScrollViewEx.show(scroll, data, createCell, "V", 546, 160, 3, 1, 6, false, nil, true, true)
end
---------------------------------------------
LayerSmithStrength.init = function(rootView)
	mLayerRoot = rootView
	
	addScrollViewList()
	TipModule.onUI(rootView, "ui_smithstrength")
end
----------------------------------------------------------------------
LayerSmithStrength.destroy = function()
   mLayerRoot = nil
   mcurEquipList = nil
end 

-- 获取可以强化的控件名
LayerSmithStrength.getWidgetNameByStrength = function()
	-- return "rootImg4", "strenBtn_4"	-- 指向戒指
	for key, val in pairs(mcurEquipList) do
		local widgetName = "strenBtn_"..key
		if tolua.cast(mLayerRoot:getChildByName(widgetName), "UIButton") then
			return "rootImg"..key, widgetName
		end
	end
end

-- 获取可以晋阶的控件名
LayerSmithStrength.getWidgetNameByAdvance = function()
	return "rootImg4", "upgradeBtn_4"	-- 指向戒指
	--[[
	for key, val in pairs(mcurEquipList) do
		local widgetName = "upgradeBtn_"..key
		if tolua.cast(mLayerRoot:getChildByName(widgetName), "UIButton") then
			return "rootImg"..key, widgetName
		end
	end
	]]
end

-- 收到装备强化
local function handleEquipmentStrengthenForge(data)
	if mLayerRoot == nil then
		cclog("handleEquipmentStrengthenForge fail, root is nil")
		return
	end
	
	--local strengthenBtn = rootNode:getChildByName("Button_Strengthen")
	--strengthenBtn:setTouchEnabled(true)
	if true == data.success then
		updateCell(mcurEquipList[m_clickEquip],m_clickEquip)
	end
	playStrenAction(data.success)						
end

-- 收到装备进阶
local function handleEquipmentUpgrade()
	if mLayerRoot == nil then
		cclog("handleEquipmentStrengthenForge fail, root is nil")
		return
	end
	updateCell(mcurEquipList[m_clickEquip],m_clickEquip)			
end


--收到装备强化
EventCenter_subscribe(EventDef["ED_EQUIPMENT_STRENGTHEN"], handleEquipmentStrengthenForge)

EventCenter_subscribe(EventDef["ED_EQUIPMENT_UPGRADE"], handleEquipmentUpgrade)