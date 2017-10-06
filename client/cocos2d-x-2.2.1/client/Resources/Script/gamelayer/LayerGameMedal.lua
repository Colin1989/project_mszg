--region LayerGameMedal.lua
--Author : songcy
--Date   : 2015/04/20
-- 军衔系统

LayerGameMedal = {}
LayerAbstract:extend(LayerGameMedal)

local mRootView = nil
local mMedalId = nil			-- 勋章实例ID
local moneyCost = 0			-- 强化花费
local isActionFull = false			-- 是否播放满阶动画
local m_bMaterialIsEnough = true		-- 进阶材料是否足够
local nameStrenColor = ccc3(227,201,36)
local anchorPoint = ccp(0.5, 0.5)


----------------------------------------------------------------------------------------------
-- 点击进阶
local function clickUpgrade(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	local limitUpgradeCopyId = LIMIT_FORGE_UPGRADE.copy_id
	-- 未通关指定副本
	if CopyDateCache.getCopyStatus(limitUpgradeCopyId) ~= "pass" and tonumber(limitUpgradeCopyId) ~= 1 then
		Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_FORGE_UPGRADE.copy_id),LIMIT_FORGE_UPGRADE.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	-- 等级不足
	-- cclog("等级:", equip.strengthen_level)
	local equip, baseEquip, strenghenEquip = ModelEquip.getEquipInfo(mMedalId)
	local equipRow = ModelEquip.getEquipRow(equip.temp_id)
	-- 不能升介
	if 0 == equipRow.advance_id then
		Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL1_CANNOT_ADVANCE_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	local tb = LogicTable.getAdvanceNeedMaterialById(equipRow.advance_id)
	if tb == nil then
		Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL1_CANNOT_ADVANCE_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	
	-- local nextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	-- if nil ~= nextStrengthenRow then
		-- Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL_CANNOT_ADVANCE_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		-- return
	-- end
	-- 材料不足
	if not m_bMaterialIsEnough then
	Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL_NOT_MATERIAL_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	
	
	-- 金币不足
	local coinNum = LogicTable.getAdvanceInfoById(equip.temp_id)
	coinNum = (coinNum == nil) and 0 or coinNum.need_amount
	-- 战绩不足
	if coinNum > ModelPlayer.getPoint() then
		Toast.show(GameString.get("GAME_MEDAL_TIP_2"))
		return
	end
	-- if CommonFunc_payConsume(1, coinNum) then
		-- return
	-- end
	
	-- sender:setTouchEnabled(false)
	
	local tb = req_equipment_advance()
	tb.inst_id = equip.equipment_id
	
	ChannelProxy.setUmsAgentEvent("STAT_EQUIPMENT_UPGRADE")
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_equipment_advance_result"])
end

-------------------------------------------------------------------------------------------
-- 强化
local function clickStrength(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		-- local index =tonumber(string.sub(widgetName,-1,-1))
		--print("clickStrength*******************",index,widgetName)
		-- m_clickEquip = index
		
		local equip = ModelEquip.getEquipInfo(mMedalId)
		local mNextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
		local coinNum = 0
		if mNextStrengthenRow then
			coinNum = mNextStrengthenRow.need_amount
		end
		
		if equip.strengthen_level >= ModelPlayer.getLevel() then
			Toast.show(GameString.get("SKILL_STR_14"))
			return
		end
		
		if coinNum > ModelPlayer.getPoint() then
			Toast.show(GameString.get("GAME_MEDAL_TIP_2"))
			return
		end
		
		BackpackLogic.requestEquipmentStrengthen(mMedalId)
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

-----------------------------------------动画-------------------------------------------
-- 进阶成功动画
local function upgradeSuccessAction()
	-- 勋章数据获取
	mMedalId = ModelEquip.getCurrEquip(5)
	if mMedalId == nil then
		local packData = ModelBackpack.getPack()
		for key, val in pairs(packData) do
			if item_type["equipment"] == val.itemtype and ModelEquip.getEquipType(val.id) == 5 then
				mMedalId = val.id
				break
			end
		end
	end
	
	local CLayer = CCLayer:create()
	local ULayer = UILayer:create()
	
	CLayer:addChild(ULayer)
	--黑色背景
	local Bg = UIImageView:create()
	Bg:loadTexture("intensify_black.png")
	Bg:setPosition( ccp(320,480) )
	Bg:setScale(30)
	Bg:setOpacity(0)
	Bg:setTouchEnabled(true)
	ULayer:addWidget(Bg)
	
	--进阶后的装备图标
	local equipRow = ModelEquip.getEquipInfo(mMedalId)
	local itemRow = LogicTable.getItemById(equipRow.temp_id)
	local iconImageView = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(320,1000), CCSizeMake(106,106), "touming.png", "iconImageView",1000 )
	iconImageView:loadTexture(itemRow.icon)
	CommonFunc_SetQualityFrame(iconImageView, itemRow.quality, equipRow.strengthen_level)	-- 装备品质框
	ULayer:addWidget(iconImageView)
	
	--进阶成功的图标
	local successImg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(320,480), CCSizeMake(329,86), "upgrade_suc.png", "successImg",10002 )
	ULayer:addWidget(successImg)
	successImg:setScale(4)
	successImg:setVisible(false)
	
	--闪光图片
	local lightImg = CommonFunc_createUIImageView(ccp(0.5,0), ccp(320,470), CCSizeMake(720,400), "role_upgrade_light.png", "lightImg",900 )
	ULayer:addWidget(lightImg)
	lightImg:setScale(0)
	
	--移除掉图片
	local function removeActions()

		local function call_Func1(sender)
		
			ULayer:removeFromParentAndCleanup(true)
			--进入武器详细信息界面
			-- local instId = ModelEquip.getCurrEquipList()[m_Bundle.index]
			local param = {}
			param.instId = mMedalId
			UIManager.push("UI_Smith_Equip_sure",param)
		end
		
		local function call_Func(sender)
			sender:getParent():removeChild(sender,true)
		end
		
		successImg:runAction( CCSequence:createWithTwoActions( CCFadeOut:create(0.5), CCCallFuncN:create(call_Func) ) )
		iconImageView:runAction( CCSequence:createWithTwoActions( CCFadeOut:create(0.5), CCCallFuncN:create(call_Func) ) )
		Bg:runAction( CCSequence:createWithTwoActions( CCFadeOut:create(0.5), CCCallFuncN:create(call_Func1) ) )
	end
	
	--创建星星
	local function createStars(lightImg)
		--星星的坐标  -- 1delaytime,2 start point,3 end point(相对) ,4 start scale,5 end scale,6 rotate,7continue time
		local starsConf = {	{0, ccp(-100,20), ccp(-230,20), 2, 0.2, -660, 0.7}, {0.2, ccp(-90,20), ccp(-235,22), 2, 0.3, 630, 0.7},		--2
				{0, ccp(-80,30), ccp(-250,50), 2, 0.2, 630, 0.7},   {0.2, ccp(-70,40), ccp(-200,80), 2, 0.2, 630, 0.7},		--4
				{0, ccp(-65,50), ccp(-200,90), 3, 0.2, -620, 0.7},	{0.2, ccp(-63,50), ccp(-172,95), 2, 0.3, -680, 0.7},	--6
				{0, ccp(-50,40), ccp(-150,150), 3, 0.2, 670, 0.7},	{0.2, ccp(-50,45), ccp(-170,170), 2, 0.2, 670, 0.7},
				{0, ccp(-40,50), ccp(-40,200), 1, 0.3, 640, 0.7}, 	{0.2, ccp(-30,50), ccp(-20,220), 2, 0.2, -660, 0.7 },	--10
				{0.2,ccp(-10,50), ccp(-10,240), 1, 0.4, 650, 1},	{0, ccp(10,50), ccp(150,80), 1, 0.4, 660, 0.8 },
				{0, ccp(100,20), ccp(230,20), 2, 0.2, -660, 0.7 },	{0.2, ccp(90,20), ccp(235,22), 2, 0.3, 630, 0.7},		
				{0, ccp(80,30), ccp(250,50), 2, 0.2, 630, 0.7},		{0.2, ccp(70,40), ccp(200,80), 2, 0.2, 630, 0.7},		   
				{0, ccp(65,50), ccp(200,90), 3, 0.2, -620, 0.7},	{0.2, ccp(63,50), ccp(172,95), 2, 0.3, -680, 0.7},		
				{0, ccp(50,40), ccp(150,150), 3, 0.2, 670, 0.7},	{0.2, ccp(50,45), ccp(170,170), 2, 0.2, 670, 0.7},
				{0, ccp(40,50), ccp(40,200), 1, 0.3, 640, 0.7},     {0.2, ccp(30,50), ccp(20,220), 2, 0.2, -660, 0.7 }		}
				
		local times = 0
		local function call_Func(sender)
			sender:getParent():removeChild(sender,true)
			times = times + 1
			if times >= 22 then
				removeActions()
			end
		end	
		
		--创建闪光的星星
		for key, var in pairs(starsConf) do
			local star = UIImageView:create()
			star:loadTexture("role_upgrade_star.png")
			star:setPosition( var[2])
			star:setScale(var[4])
			star:setOpacity(0)
			
			local array = CCArray:create()
			array:addObject(CCRotateBy:create(var[7],var[6]) )
			array:addObject(CCScaleTo:create(var[7],var[5]) )
			array:addObject(CCFadeIn:create(0) )
			array:addObject(CCEaseSineOut:create(CCMoveBy:create(var[7],var[3]) ))
			
			local action = CCSpawn:create( array )
			local action1 = CCSequence:createWithTwoActions( CCDelayTime:create(var[1]),action)
			local action2 = CCSequence:createWithTwoActions(action1,CCCallFuncN:create(call_Func))
			star:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.25),action2))
			lightImg:addChild(star)
		end
	end
	
	--显示闪光
	local function showLightAction()
		local colArray = CCArray:create()
		colArray:addObject(CCTintTo:create(0.5,255,200,200) )
		colArray:addObject(CCTintTo:create(0.5,255,255,255) )
		colArray:addObject(CCFadeOut:create(0.2) )
		local action = CCSequence:create( colArray )
		local action1 = CCSequence:createWithTwoActions( CCScaleTo:create(0.1,1),CCFadeIn:create(0.06))
		local action2 = CCSpawn:createWithTwoActions( action,action1)
		local action3 = CCSequence:createWithTwoActions(CCDelayTime:create(0.05) ,action2)
		lightImg:runAction(action3)
		--创建星星
		createStars(lightImg)
	end
		
	local function initUIActions()
		--进阶后的图片飞出来
		iconImageView:runAction( CCEaseSineOut:create( CCMoveBy:create(0.4, ccp(0,-420))) )
		--进阶成功图片飞出来
		local array2 = CCArray:create()
		array2:addObject( CCDelayTime:create(0.6) )
		array2:addObject( CCShow:create() )
		array2:addObject( CCScaleTo:create( 0.3, 1 ) )
		array2:addObject( CCCallFunc:create(showLightAction) )
		local action3 = CCSequence:create( array2 )
		successImg:runAction( action3 )
	end
		
	local array = CCArray:create()
	array:addObject( CCFadeIn:create(0.3) )
	array:addObject( CCCallFunc:create( initUIActions ) )
	
	local action1 = CCSequence:create( array )
	Bg:runAction( action1 )
	local root,_ = LayerMain.getLayerRoot()
	root:addChild(CLayer)
end

-- 满阶动画
local function fullAdvanceAction(m_eqData, actionCB)
	if nil == mRootView then
		return
	end
	
	local advanceInfoPanel = mRootView:getChildByName("Panel_56")
	advanceInfoPanel:setVisible(false)
	
	local fullAdvanceInfoPanel = mRootView:getChildByName("Panel_69")
	fullAdvanceInfoPanel:setVisible(false)
	
	local fullImage = tolua.cast(mRootView:getChildByName("ImageView_86"), "UIImageView")
	CommonFunc_AddGirdWidget(m_eqData.temp_id, 1, m_eqData.strengthen_level, nil, fullImage)
	fullImage:setTouchEnabled(true)
	
	-- 图标长按事件
	local function longClickGrid(icon)
		local param = {}
		param.instId = m_eqData.equipment_id
		param.itemId = m_eqData.temp_id
		local position,direct = CommonFuncJudgeInfoPosition(icon)
		param.position = position
		param.direct = direct
		UIManager.push("UI_EquipInfo",param)
	end
	UIManager.registerEvent(fullImage, callBackFunc, longClickGrid, CommonFunc_longEnd_equip)
	
	-- 进阶按钮灰态
	local upgradeBtn = mRootView:getChildByName("Button_advance")
	local upgradeBtnWord = mRootView:getChildByName("ImageView_advance")
	Lewis:spriteShaderEffect(upgradeBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(upgradeBtnWord:getVirtualRenderer(),"buff_gray.fsh",true)
	upgradeBtn:setTouchEnabled(false)
	
	-- 数量隐藏
	local labelCoin = mRootView:getChildByName("Label_advance_cost")
	labelCoin:setVisible(false)
	
	if nil == actionCB then
		fullAdvanceInfoPanel:setVisible(true)
		return
	end
	local bottomBg = tolua.cast(mRootView:getChildByName("ImageView_54"), "UIImageView")
	local blinkImage = tolua.cast(mRootView:getChildByName("ImageView_full_advance_blink"), "UIImageView")
	if nil == blinkImage then
		blinkImage = UIImageView:create()
		blinkImage:loadTexture("forge_recast_blickIcon.png")
		blinkImage:setScale9Enabled(true)
		blinkImage:setCapInsets(CCRectMake(0, 0, 0, 0))
		blinkImage:setSize(CCSizeMake(540, 366))
		blinkImage:setZOrder(10)
		blinkImage:setName("ImageView_full_advance_blink")
		blinkImage:setOpacity(0)
		bottomBg:addChild(blinkImage)
	end
	local actionArr = CCArray:create()
	actionArr:addObject(CCFadeIn:create(0.5))
	actionArr:addObject(CCDelayTime:create(0.1))
	actionArr:addObject(CCCallFunc:create(function()
		blinkImage:setOpacity(0)
		fullAdvanceInfoPanel:setVisible(true)
		if actionCB then
			actionCB()
		end
	end))
	blinkImage:runAction(CCSequence:create(actionArr))
end

-- 强化成功或失败动画
local function playStrenAction(success)
	if nil == mRootView then
		return
	end
	
	-- local scroll = tolua.cast(mRootView:getChildByName("ScrollView_Strengthen"), "UIScrollView")
	-- local panel = tolua.cast(scroll:getChildByName("root"..m_clickEquip), "UIImageView")
	
	--print("playStrenAction****************",m_clickEquip,panel,"root"..m_clickEquip)
	local resultImg = tolua.cast(mRootView:getChildByName("strenResultImg"), "UIImageView")
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

-- 升介所需材料
local function showNeedMaterial(m_eqData)
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
	local tb = LogicTable.getAdvanceNeedMaterialById(equipRow.advance_id)
	for k = 1,3,1 do
		local panel = mRootView:getChildByName(string.format("materialImg_%d",k))
		panel:setVisible(false)
	end
	
	local isChange = false
	m_bMaterialIsEnough = true			-----？？？？？？？？？？？？
	for k = 1,#(tb),1 do
		local panel = mRootView:getChildByName(string.format("materialImg_%d",k))
		panel:setVisible(true)
		
		-- 图片                       --？？？？？？？？？？有待修改
		local icon = panel:getChildByName("icon")
		CommonFunc_AddGirdWidget(tb[k].temp_id, 0, 0, nil, icon)
		
		-- 为图片添加长按事件
		icon:setTouchEnabled(true)
		-- 物品详细信息
		local function showItemDetailCall(icon)
			local position,direct = CommonFuncJudgeInfoPosition(icon)
			local tempTb = {}
			tempTb.itemId = tb[k].temp_id
			tempTb.position = position
			tempTb.direct = direct
			UIManager.push("UI_ItemInfo_Long",tempTb)
		end
		UIManager.registerEvent(icon, nil, showItemDetailCall, CommonFunc_longEnd_item)
		
		
		-- 材料名字
		local name = tolua.cast( panel:getChildByName("name"),"UILabel")
		local materialInfo = LogicTable.getItemById(tb[k].temp_id)
		name:setText(materialInfo.name)
		
		-- 数量
		local numLbl = tolua.cast( panel:getChildByName("num"),"UILabel")
		local num = ModelBackpack.getItemByTempId(tb[k].temp_id)
		num = (num == nil) and 0 or tonumber(num.amount)
		if num < tb[k].amount then
			m_bMaterialIsEnough = false
			numLbl:setColor(ccc3(255, 0, 0))
		else
			numLbl:setColor(ccc3(255, 255, 255))
		end
		numLbl:setText(string.format("%d/%d", num, tb[k].amount))
		
		-- if isChange == false then
			-- local completionBtn = mRootView:getChildByName("Button_completion")
			-- local completionWord = completionBtn:getChildByName("ImageView_10550")
			-- if m_bMaterialIsEnough == true or not LayerOneKeyCompletion.isExists(getOneKeyTable()) then
				-- Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",true)
				-- Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",true)
				-- completionBtn:setTouchEnabled(false)
			-- else
				-- isChange = true
				-- Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",false)
				-- Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",false)
				-- completionBtn:setTouchEnabled(true)
			-- end
		-- end
	end
	
	-- 所需费用
	local coinNum = LogicTable.getAdvanceInfoById(m_eqData.temp_id)
	coinNum = (coinNum == nil) and 0 or coinNum.need_amount
	local labelCoin = tolua.cast(mRootView:getChildByName("Label_advance_cost"),"UILabel")
	if coinNum > ModelPlayer.getPoint() then
		labelCoin:setColor(ccc3(255, 0, 0))
	else
		labelCoin:setColor(ccc3(255, 255, 255))
	end
	labelCoin:setText(string.format("%d/%d", ModelPlayer.getPoint(), coinNum))
end

-----------------------------------------------------------------------------------------------
-- 获取属性信息
local function getProVal(instId)
	local equip, baseEquip, strenghenEquip = ModelEquip.getEquipInfo(instId)
	-- 强化属性标识
	local valueKey = CommonFunc_getEffectAttrs(equip)[1]
	-- 强化属性表
	local strengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id)
	if strengthenRow then
		valueKey = strengthenRow.attr_types
	end
	local valueString = CommonFunc_getAttrString(valueKey)
	local valNum = {baseEquip[valueKey], strenghenEquip[valueKey]}

	return valueString, valNum
end

--加载装备的信息
local function addEquipInfo(m_eqData)
	-- 升介前..
	local data1 = ModelEquip.getEquipInfo(m_eqData.equipment_id)
	
	-- 装备图标
	local img1 =  tolua.cast(mRootView:getChildByName("icon_curr"), "UIImageView")
	CommonFunc_AddGirdWidget(data1.temp_id, 1, data1.strengthen_level, nil, img1)
	
	--升阶后
	local data3 = LogicTable.getAdvanceInfoById(m_eqData.temp_id)
	if data3 == nil then
		if isActionFull == false then
			fullAdvanceAction(data1, nil)
		else
			fullAdvanceAction(data1, function()
			-- 进阶动画
			upgradeSuccessAction()
		end)
		end
		isActionFull = false
		return
	end
	
	local oldItemId = m_eqData.temp_id
	local oldLv = m_eqData.equip_level
	m_eqData.temp_id = data3.advance_id
	m_eqData.equip_level = 0
	-- 装备图标
	local img2 =  mRootView:getChildByName("icon_next")   
	CommonFunc_AddGirdWidget(m_eqData.temp_id, 1, data1.strengthen_level, nil, img2)
	
	-- 替换回
	m_eqData.temp_id = oldItemId
	m_eqData.equip_level = oldLv
	
	showNeedMaterial(m_eqData)
	
	if isActionFull == true then
		upgradeSuccessAction()
		isActionFull = false
	end
end

local function createStrengthCell(nameText,levelNum,itemId,instId,coinNum,attZHIText,flag)
	if mRootView == nil then
		return
	end
	-- 创建Icon
	local icon = tolua.cast(mRootView:getChildByName("ImageView_icon"), "UIImageView")
	CommonFunc_AddGirdWidget(itemId, 1, levelNum, nil, icon)
	icon:setTouchEnabled(true)
	-- 图标长按事件
	local function longClickGrid(icon)
		local param = {}
		param.instId = instId
		param.itemId = itemId
		local position,direct = CommonFuncJudgeInfoPosition(icon)
		param.position = position
		param.direct = direct
		UIManager.push("UI_EquipInfo",param)
	end
	UIManager.registerEvent(icon, callBackFunc, longClickGrid, CommonFunc_longEnd_equip)
	-- 强化名字
	local name = tolua.cast(mRootView:getChildByName("Label_name"), "UILabel")
	name:setText(nameText)
	-- 当前等级
	local curLevel = tolua.cast(mRootView:getChildByName("Label_level_1"), "UILabel")
	curLevel:setText(levelNum)
	-- 强化后等级
	local strenLevel = tolua.cast(mRootView:getChildByName("Label_level_2"), "UILabel")
	if flag == false then
		strenLevel:setText(levelNum + 1)
	else
		strenLevel:setText(levelNum)
	end
	-- 属性字
	local attribute = tolua.cast(mRootView:getChildByName("Label_40"), "UILabel")
	attribute:setText(attZHIText)
	-- 花费
	local labelPay = tolua.cast(mRootView:getChildByName("Label_pay"), "UILabel")
	-- labelPay:setText(coinNum)
	if coinNum > ModelPlayer.getPoint() then
		labelPay:setColor(ccc3(255, 0, 0))
	else
		labelPay:setColor(ccc3(255, 255, 255))
	end
	labelPay:setText(string.format("%d/%d", ModelPlayer.getPoint(), coinNum))
	labelPay:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	-- 强化按钮
	local strenBtn = tolua.cast(mRootView:getChildByName("Button_upgrade"), "UIButton")
	strenBtn:registerEventScript(clickStrength)
end

--初始化强化cell数据
local function initStrengthCellData(equip,valueString,valNum,instId,baseEquip,strenghenEquip,valueKey)
	local NextStrengthenRow = nil
	NextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	
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
	createStrengthCell(equip.name,strengthenLevel[1],equip.id,instId,moneyCost,valueString,maxFlag)
	for i = 1, 2 do
		-- 属性
		local attrLabel = tolua.cast(mRootView:getChildByName("Label_life_"..i), "UILabel")
		if 0 == valNum[i][2] then
			attrLabel:setText(valNum[i][1])
		else
			attrLabel:setText( valNum[i][1] + valNum[i][2] )
		end
	end
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

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	local widgetName = sender:getName()
	if widgetName == "Button_close" then	-- 关闭
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", sender:getName())
	end
end

LayerGameMedal.getMedalId = function()
	local medalId = ModelEquip.getCurrEquip(5)
	return medalId
end

-- 进阶是否显示感叹号
LayerGameMedal.isUpgradeShowTip = function()
	if LayerGameMedal.getMedalId() == nil then
		return false
	end
	local limitUpgradeCopyId = LIMIT_FORGE_UPGRADE.copy_id
	-- 未通关指定副本
	if CopyDateCache.getCopyStatus(limitUpgradeCopyId) ~= "pass" and tonumber(limitUpgradeCopyId) ~= 1 then
		return false
	end
	
	local equip = ModelEquip.getEquipInfo(LayerGameMedal.getMedalId())
	local equipRow = ModelEquip.getEquipRow(equip.temp_id)
	-- 不能升介
	if 0 == equipRow.advance_id then
		return false
	end
	local tb = LogicTable.getAdvanceNeedMaterialById(equipRow.advance_id)
	if tb == nil then
		return false
	end
	-- 材料不足
	for k = 1,#(tb),1 do
		-- 数量
		local num = ModelBackpack.getItemByTempId(tb[k].temp_id)
		num = (num == nil) and 0 or tonumber(num.amount)
		if num < tb[k].amount then
			return false
		end
	end
	
	-- 战绩不足
	local coinNum = LogicTable.getAdvanceInfoById(equip.temp_id)
	coinNum = (coinNum == nil) and 0 or coinNum.need_amount
	if coinNum > ModelPlayer.getPoint() then
		return false
	end
	
	return true
end

-- 强化是否显示感叹号
LayerGameMedal.isStrengthShowTip = function()
	if LayerGameMedal.getMedalId() == nil then
		return false
	end
	local equip = ModelEquip.getEquipInfo(LayerGameMedal.getMedalId())
	local mNextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	local coinNum = 0
	if mNextStrengthenRow then
		coinNum = mNextStrengthenRow.need_amount
		if equip.strengthen_level < ModelPlayer.getLevel() and coinNum <= ModelPlayer.getPoint() then
			return true
		end
	end
	return false
end

-- 初始化界面
LayerGameMedal.initUI = function()
	if mRootView == nil then
		return
	end
	
	-- 勋章数据获取
	mMedalId = LayerGameMedal.getMedalId()
	-- mMedalId = ModelEquip.getCurrEquip(5)
	-- if mMedalId == nil then
		-- local packData = ModelBackpack.getPack()
		-- for key, val in pairs(packData) do
			-- if item_type["equipment"] == val.itemtype and ModelEquip.getEquipType(val.id) == 5 then
				-- mMedalId = val.id
				-- break
			-- end
		-- end
	-- end
	
	if mMedalId ~= nil then
		local background = mRootView:getChildByName("background")
		local equip,valueString,valNum,baseEquip,strenghenEquip,valueKey = getEquipDetailInfo(mMedalId)
		
		-- 加载勋章强化信息
		initStrengthCellData(equip,valueString,valNum,mMedalId,baseEquip,strenghenEquip,valueKey)
		
		-- 加载勋章进阶信息
		addEquipInfo(equip)
		
		-- 强化气泡显示
		local upgradeTip = mRootView:getChildByName("upgrade_tip")
		if LayerGameMedal.isStrengthShowTip() then
			upgradeTip:setVisible(true)
		else
			upgradeTip:setVisible(false)
		end
		
		-- 进阶气泡显示
		local advanceTip = mRootView:getChildByName("advance_tip")
		if LayerGameMedal.isUpgradeShowTip() then
			advanceTip:setVisible(true)
		else
			advanceTip:setVisible(false)
		end
	end
end

--更新cell数据()
local function updateCell(instId)
	-- print("updateCell*******************",index,m_clickEquip,instId)
	-- local cellBg = tolua.cast(mRootView:getChildByName("root"..m_clickEquip), "UIImageView")
	-- cellBg:removeAllChildren()
	-- initScrollData(cellBg,instId,index)
	
	LayerGameMedal.initUI()
end

LayerGameMedal.init = function(rootView)
	mRootView = rootView
	
	-- addScrollViewList()
	-- TipModule.onUI(rootView, "ui_smithstrength")
	-- 关闭btn event
	local btnClose = mRootView:getChildByName("Button_close")
    btnClose:registerEventScript(btnCall)
	
	-- 进阶
	local upgradeBtn = mRootView:getChildByName("Button_advance")
	upgradeBtn:setTouchEnabled(true)
	upgradeBtn:registerEventScript(clickUpgrade)
	
	-- 初始化界面
	LayerGameMedal.initUI()
end

LayerGameMedal.destroy = function()
   mRootView = nil
   mMedalId = nil
   moneyCost = 0
   isActionFull = false
end

-- 收到装备强化
local function handleEquipmentStrengthenForge(data)
	if mRootView == nil then
		cclog("handleEquipmentStrengthenForge fail, root is nil")
		return
	end
	
	if true == data.success then
		updateCell()
	end
	playStrenAction(data.success)
end

-- 收到装备进阶
local function handleEquipmentUpgrade()
	if mRootView == nil then
		cclog("handleEquipmentStrengthenForge fail, root is nil")
		return
	end
	isActionFull = true
	
	updateCell()
	-- 进阶动画
	-- upgradeSuccessAction()
end

-- 收到装备强化
EventCenter_subscribe(EventDef["ED_EQUIPMENT_STRENGTHEN"], handleEquipmentStrengthenForge)
-- 收到装备进阶
EventCenter_subscribe(EventDef["ED_EQUIPMENT_UPGRADE"], handleEquipmentUpgrade)