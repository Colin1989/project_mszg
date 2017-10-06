----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面（装备进阶）
----------------------------------------------------------------------
local mLayerRoot = nil	-- 界面根节点
local m_eqData = nil		--当前界面的装备信息
local m_Bundle = nil		--保存传过来的信息
local m_bMaterialIsEnough = true		-- 材料是否足够

LayerSmithUpgrade = {}
LayerAbstract:extend(LayerSmithUpgrade)
-----------------------------------------界面动画-------------------------------------------------------------
--箭头的永久动画
local function arrowForeverAction()
	--箭头
	local  arrow = tolua.cast(mLayerRoot:getWidgetByName("img_arrow"),"UIImageView")
	local x = arrow:getPosition().x
	local y = arrow:getPosition().y
	
	-- 执行动作
	local function actionDone()
		arrow:setPosition(ccp(x - 15,y))
	end
	
    local arr = CCArray:create()
	local action1 = CCMoveTo:create(0.6,ccp(x + 15,y))
	arr:addObject(action1)
	--重复
	local action3 = CCRepeatForever:create(CCSequence:createWithTwoActions(CCSequence:create(arr), CCCallFunc:create(actionDone)))
	arrow:runAction(action3)
end
------------------------------------------------------------------
--进阶成功动画
local function upgradeSuccessAction()
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
	local instId = ModelEquip.getCurrEquipList()[m_Bundle.index]
	local equipRow = ModelEquip.getEquipInfo(instId)
	local itemRow = LogicTable.getItemById(equipRow.temp_id)
	local iconImageView = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(320,1000), CCSizeMake(106,106), "touming.png", "iconImageView",1000 )
	iconImageView:loadTexture(itemRow.icon)
	CommonFunc_SetQualityFrame(iconImageView, itemRow.quality)	-- 装备品质框
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
			local instId = ModelEquip.getCurrEquipList()[m_Bundle.index]
			local param = {}
			param.instId = instId
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
-------------------------------------------------------------
-- 点击关闭按钮
LayerSmithUpgrade.onClick = function(widget)
	TipModule.onClick(widget)
	local widgetName = widget:getName()
	if "close" == widgetName then
		UIManager.pop("UI_Smith_upGrade")
	end
end
-------------------------------------------补齐材料------------------------
-- 获取一键补齐表
local function getOneKeyTable()
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
	local upgrageRow = LogicTable.getAdvanceNeedMaterialById(equipRow.advance_id)
	local tb = {}
	for k, v in pairs(upgrageRow) do
		local row = {}
		row.id = v.temp_id
		row.amount = tonumber(v.amount)
		
		table.insert(tb, row)
	end
	return tb
end

-- 点击补齐材料按钮
local function clickCompletionBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local tb = getOneKeyTable()
		UIManager.push("UI_OneKeyCompletion", tb)
	end
end

-- 升介所需材料
local function showNeedMaterial()
	
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
	local tb = LogicTable.getAdvanceNeedMaterialById(equipRow.advance_id)
	for k = 1,3,1 do
		local panel = mLayerRoot:getWidgetByName(string.format("materialImg_%d",k))
		panel:setVisible(false)
	end
	
	local isChange = false
	m_bMaterialIsEnough = true			-----？？？？？？？？？？？？
	for k = 1,#(tb),1 do
		local panel = mLayerRoot:getWidgetByName(string.format("materialImg_%d",k))
		panel:setVisible(true)
		
		--图片                       --？？？？？？？？？？有待修改
		local icon = panel:getChildByName("icon")
		CommonFunc_AddGirdWidget(tb[k].temp_id, 0, 0, nil, icon)
		
		--为图片添加长按事件
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
			
		
		--材料名字
		local name = tolua.cast( panel:getChildByName("name"),"UILabel")
		local materialInfo = LogicTable.getItemById(tb[k].temp_id)
		name:setText(materialInfo.name)
		
		--数量
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
		
		if isChange == false then
			local completionBtn = mLayerRoot:getWidgetByName("Button_completion")
			local completionWord = completionBtn:getChildByName("ImageView_10550")
			if m_bMaterialIsEnough == true or not LayerOneKeyCompletion.isExists(getOneKeyTable()) then
				Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",true)
				Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",true)
				completionBtn:setTouchEnabled(false)
			else
				isChange = true
				Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",false)
				Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",false)
				completionBtn:setTouchEnabled(true)
			end
		end
	end
	
	-- 所需费用
	local coinNum = LogicTable.getAdvanceInfoById(m_eqData.temp_id)
	coinNum = (coinNum == nil) and 0 or coinNum.need_amount
	local labelCoin = tolua.cast(mLayerRoot:getWidgetByName("label_coin"),"UILabel" )
	labelCoin:setText(tostring(coinNum))
end

-- 一键补齐后刷新材料显示
local function handle_req_oneKeyForUpgrade(success)
	if nil == mLayerRoot then
		return
	end
	if false == success then
		return
	end
	showNeedMaterial()
end

EventCenter_subscribe(EventDef["ED_UPDATE_FOR_ONE_KEY"], handle_req_oneKeyForUpgrade)
--------------------------------------------开始进阶---------------------------------------------------
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
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
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
	-- 等级不足
	cclog("等级:", m_eqData.strengthen_level)
	local equip, baseEquip, strenghenEquip = ModelEquip.getEquipInfo(m_eqData.equipment_id)
	local nextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	if nil ~= nextStrengthenRow then
		Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL_CANNOT_ADVANCE_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	-- 材料不足
	if not m_bMaterialIsEnough then
	Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL_NOT_MATERIAL_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	-- 金币不足
	local coinNum = LogicTable.getAdvanceInfoById(m_eqData.temp_id)
	Log(coinNum)
	coinNum = (coinNum == nil) and 0 or coinNum.need_amount
	if CommonFunc_payConsume(1, coinNum) then
		return
	end
	
	sender:setTouchEnabled(false)
	
	local tb = req_equipment_advance()
	tb.inst_id = m_eqData.equipment_id
	
	ChannelProxy.setUmsAgentEvent("STAT_EQUIPMENT_UPGRADE")
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_equipment_advance_result"])
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
local function addEquipInfo()
	-- 升介前..
	local data1 = ModelEquip.getEquipInfo(m_eqData.equipment_id)
	-- 装备图标
	local img1 =  mLayerRoot:getWidgetByName("img_head1")   
	CommonFunc_AddGirdWidget(m_eqData.temp_id, 1, data1.strengthen_level, nil, img1)
	
	--[[
	--图标的长按信息
	img1:setTouchEnabled(true)
	--图标长按事件
	local function longClickGrid(img1)
		local param = {}
		param.instId = m_eqData.equipment_id				
		param.itemId = m_eqData.temp_id				
		local position,direct = CommonFuncJudgeInfoPosition(img1)
		param.position = position
		param.direct = direct
		UIManager.push("UI_EquipInfo",param)
	end
	UIManager.registerEvent(img1, callBackFunc, longClickGrid, CommonFunc_longEnd_equip)
	]]--
	
	-- 属性 todo
	local valueString1, valNum = getProVal(m_eqData.equipment_id)
	local labelHarm1 = tolua.cast( mLayerRoot:getWidgetByName("label_harm1"),"UILabel")
	if 0 == valNum[2] then
		labelHarm1:setText(string.format("%s:%d", valueString1, valNum[1]))
	else
		labelHarm1:setText(string.format("%s:%d+%d", valueString1, valNum[1], valNum[2]))
	end
	
	--升阶后
	local data3 = LogicTable.getAdvanceInfoById(m_eqData.temp_id)
	Log(m_eqData, data1)
	cclog("===========================>data3:")
	Log(data3)
	if data3 == nil then
		cclog("不能升介")
		return
	end
	
	local oldItemId = m_eqData.temp_id
	local oldLv = m_eqData.equip_level
	m_eqData.temp_id = data3.advance_id
	m_eqData.equip_level = 0
	-- 装备图标
	local img2 =  mLayerRoot:getWidgetByName("img_head2")   
	CommonFunc_AddGirdWidget(m_eqData.temp_id, 1, 0, nil, img2)

	--[[
	img2:setTouchEnabled(true)
	--图标长按事件
	local function longClickGrid(img2)
		local param = {}
		param.instId = m_eqData.equipment_id				
		param.itemId = m_eqData.temp_id				
		local position,direct = CommonFuncJudgeInfoPosition(img2)
		param.position = position
		param.direct = direct
		UIManager.push("UI_EquipInfo",param)
	end
	UIManager.registerEvent(img2, callBackFunc, longClickGrid, CommonFunc_longEnd_equip)
	]]--
	
	-- 属性 todo
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
	local valueKey = CommonFunc_getEffectAttrs(equipRow)[1]
	local valNum2 = equipRow[valueKey]
	local labelHarm1 =tolua.cast( mLayerRoot:getWidgetByName("label_harm2"),"UILabel")    
	labelHarm1:setText(string.format("%s:%d", tostring(valueString1), tonumber(valNum2)))
	-- 替换回
	m_eqData.temp_id = oldItemId
	m_eqData.equip_level = oldLv
	
	showNeedMaterial()
	
end

----------------------------------------------------------------------
LayerSmithUpgrade.init = function(rootView)
	mLayerRoot  = UIManager.findLayerByTag("UI_Smith_upGrade")
	m_Bundle = rootView
	
	setOnClickListenner("close")
	
	m_eqData,baseEquip, strenghenEquip = ModelEquip.getEquipInfo(rootView.instId)
	--补齐材料
	local completionBtn = mLayerRoot:getWidgetByName("Button_completion")
	completionBtn:registerEventScript(clickCompletionBtn)
	
	-- 开始进阶
	local upgradeBtn = mLayerRoot:getWidgetByName("btn_upgrade")
	upgradeBtn:registerEventScript(clickUpgrade)
	
	--箭头的永久动画
	arrowForeverAction()
	
	addEquipInfo()
	
	TipModule.onUI(root, "ui_equipforgeupgrade")
end


LayerSmithUpgrade.destroy = function()
   mLayerRoot = nil
end 
----------------------------------------------------进阶网络事件------------------------------------------------------
-- 升介rec
local function handle_req_equipAdvance(resp)
	if resp.result ~= common_result["common_success"] then
		cclog("升介失败!")
		return
	end
	if resp.result == common_result["common_failed"] then
		--local upgradeBtn = CommonFunc_getNodeByName(rootNode, "btn_equip", "UIButton")
		--upgradeBtn:setTouchEnabled(true)
		return
	end
	
	EventCenter_post(EventDef["ED_EQUIPMENT_UPGRADE"])
	
	if mLayerRoot == nil then
		return
	end
	
	UIManager.pop("UI_Smith_upGrade")
	
	--进阶动画
	upgradeSuccessAction()
	
	--[[
	local instId = ModelEquip.getCurrEquipList()[m_Bundle.index]
	local param = {}
	param.instId = instId
	
	UIManager.push("UI_Smith_Upgrade_Info",param)
	]]--
	
end
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_advance_result"], notify_equipment_advance_result, handle_req_equipAdvance)

