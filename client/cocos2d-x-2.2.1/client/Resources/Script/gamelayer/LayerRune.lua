--region LayerRune.lua
--Author : songcy
--Date   : 2014/10/21
--此文件由[BabeLua]插件自动生成

LayerRune = {}
LayerAbstract:extend(LayerRune)

local mRootView = nil  -- 根节点

local mbTouchEnable	= true

local isNormalOpen = false  -- 普通寻宝门是否开启
local isSpecialOpen = false  -- 稀有寻宝门是否开启

local normalFreeTimes = RUNE_NORMAL_COUNT  -- 普通寻宝剩余次数
local specialFreeTimes = RUNE_SPECIAL_COUNT  -- 特殊寻宝剩余次数

local normalCD = RUNE_NORMAL_CD  -- 普通寻宝CD时长
local specialCD = RUNE_SPECIAL_CD  -- 特殊寻宝CD时长

local resetNormalCD = false    -- 是否重置普通寻宝CD
local resetSpecialCD = false    -- 是否重置特殊寻宝CD

local mNormalTimer = nil			-- 普通寻宝定时器
local mSpecialTimer = nil			-- 特殊寻宝定时器

-- local tbRewardList = nil  -- 记录服务端发回的奖励数据
local tbClickButton = {}  -- 记录点击控件

local unlockSkillTb = nil	-- 已解锁的技能
local mNewDay = true		-- 新的一天
local mDailyTimerFlag = false

LayerRune.updateUnlockSkill = function()
	unlockSkillTb = SkillLogic.getUnlockSkillGroup()
end

LayerRune.insertUnclockSkill = function(bundle)
	if unlockSkillTb == nil then
		unlockSkillTb = {}
	end
	table.insert(unlockSkillTb, bundle)
end

LayerRune.getUnlockSkill = function()
	return unlockSkillTb
end

-- 六边形点坐标
local hexagonPoint = {
						[1] = {x = -73, y = 78},
						[2] = {x = -144, y = 0},
						[3] = {x = -73, y = -78},
						[4] = {x = 73, y = -78},
						[5] = {x = 144, y = 0},
						[6] = {x = 73, y = 78},
}

local TAG1 = 102801
local TAG2 = 102802
local TAG3 = 102803
local TAG4 = 102804

-- 增加圆形粒子动画
local function halfRoundParticleEffect(widget)
	local center = ccp(0, 0)
	
	local particle1 = CCParticleSystemQuad:create("make_king_effect_round.plist")
	widget:addRenderer(particle1, 100)
	particle1:setPosition(center)
    particle1:setTag(TAG1)
    
	local particle2 = CCParticleSystemQuad:create("make_king_effect_special.plist")
	widget:addRenderer(particle2, 100)
	particle2:setPosition(center)
	particle2:setTag(TAG2)
end

-- 增加六边形粒子动画
local function hexagonParticleEffect(widget)
	local center = ccp(0, 0)
	local speed = 0.6
	
	local particle4 = CCParticleSystemQuad:create("make_king_effect_normal.plist")
	widget:addRenderer(particle4, 100)
	particle4:setPosition(center)
	particle4:setTag(TAG4)
	
	local particle1 = CCParticleSystemQuad:create("make_king_effect_point.plist")
	widget:addRenderer(particle1, 100)
	particle1:setPosition(ccp(hexagonPoint[1].x, hexagonPoint[1].y))
    particle1:setTag(TAG1)
	
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[2].x, hexagonPoint[2].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[3].x, hexagonPoint[3].y)))
    arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[4].x, hexagonPoint[4].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[5].x, hexagonPoint[5].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[6].x, hexagonPoint[6].y)))
    arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[1].x, hexagonPoint[1].y)))
	particle1:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    
	local particle2 = CCParticleSystemQuad:create("make_king_effect_point.plist")
	widget:addRenderer(particle2, 100)
    particle2:setTag(TAG2)
	particle2:setPosition(ccp(hexagonPoint[3].x, hexagonPoint[3].y))
	
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[4].x, hexagonPoint[4].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[5].x, hexagonPoint[5].y)))
    arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[6].x, hexagonPoint[6].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[1].x, hexagonPoint[1].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[2].x, hexagonPoint[2].y)))
    arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[3].x, hexagonPoint[3].y)))
	particle2:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	
	local particle3 = CCParticleSystemQuad:create("make_king_effect_point.plist")
	widget:addRenderer(particle3, 100)
    particle3:setTag(TAG3)
	particle3:setPosition(ccp(hexagonPoint[5].x, hexagonPoint[5].y))
	
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[6].x, hexagonPoint[6].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[1].x, hexagonPoint[1].y)))
    arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[2].x, hexagonPoint[2].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[3].x, hexagonPoint[3].y)))
	arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[4].x, hexagonPoint[4].y)))
    arr:addObject(CCMoveTo:create(speed, ccp(hexagonPoint[5].x, hexagonPoint[5].y)))
	particle3:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

-- 寻宝介绍控制
local function controlUILabel()
	if nil == mRootView then
		return
	end
	-- 普通寻宝介绍
	local labelNormal = tolua.cast(mRootView:getChildByName("Label_normal"), "UILabel")
	labelNormal:setVisible((not isNormalOpen))
	-- 特殊寻宝介绍
	local labelSpecial = tolua.cast(mRootView:getChildByName("Label_special"), "UILabel")
	labelSpecial:setVisible((not isSpecialOpen))
end

-- 开关门点击控制
local function controlDoorClick()
	if nil == mRootView then
		return
	end
	-- 普通寻宝开启
	local normalOpen = tolua.cast(mRootView:getChildByName("ImageView_normalOpen"), "UIImageView")
	normalOpen:setTouchEnabled((not isNormalOpen))
	local normalLeft = tolua.cast(mRootView:getChildByName("ImageView_normalLeft"), "UIImageView")
	normalLeft:setTouchEnabled((not isNormalOpen))
	local normalRight = tolua.cast(mRootView:getChildByName("ImageView_normalRight"), "UIImageView")
	normalRight:setTouchEnabled((not isNormalOpen))
	-- 特殊寻宝开启
	local specialOpen = tolua.cast(mRootView:getChildByName("ImageView_specialOpen"), "UIImageView")
	specialOpen:setTouchEnabled((not isSpecialOpen))
	local specialLeft = tolua.cast(mRootView:getChildByName("ImageView_specialLeft"), "UIImageView")
	specialLeft:setTouchEnabled((not isSpecialOpen))
	local specialRight = tolua.cast(mRootView:getChildByName("ImageView_specialRight"), "UIImageView")
	specialRight:setTouchEnabled((not isSpecialOpen))
	-- 普通寻宝关闭
	local normalClose = tolua.cast(mRootView:getChildByName("Button_normalClose"), "UIButton")
	normalClose:setTouchEnabled(isNormalOpen)
	-- 特殊寻宝关闭
	local specialClose = tolua.cast(mRootView:getChildByName("Button_specialClose"), "UIButton")
	specialClose:setTouchEnabled(isSpecialOpen)
end

-- 寻宝点击控制
local function controlRuneClick()
	if nil == mRootView then
		return
	end
	--单次普通寻宝
	local normalOne = tolua.cast(mRootView:getChildByName("ImageView_normalOne"), "UIImageView")
	normalOne:setTouchEnabled(isNormalOpen)
	-- 十次普通寻宝
	local normalTen = tolua.cast(mRootView:getChildByName("ImageView_normalTen"), "UIImageView")
	normalTen:setTouchEnabled(isNormalOpen)
	-- 单次稀有寻宝
	local specialOne = tolua.cast(mRootView:getChildByName("ImageView_specialOne"), "UIImageView")
	specialOne:setTouchEnabled(isSpecialOpen)
	-- 十次稀有寻宝
	local specialTen = tolua.cast(mRootView:getChildByName("ImageView_specialTen"), "UIImageView")
	specialTen:setTouchEnabled(isSpecialOpen)
	-- timerUIInit()
end

-- 时间UI显示控制
local function controlTimerV()
	if nil == mRootView then
		return
	end
	local nLabelCD = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_normalUpTime"), "UILabel")
	nLabelCD:setVisible(normalCD ~= 0)
	local nLabelWordRight = tolua.cast(CommonFunc_getLabelByName(mRootView, "ImageView_45"), "UIImageView")
	nLabelWordRight:setVisible(normalCD ~= 0)
	-- local nLabelCount = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_normalCount"), "UILabel")
	-- nLabelCount:setVisible(normalCD == 0)
	local nLabelWordLeft = tolua.cast(CommonFunc_getLabelByName(mRootView, "ImageView_47"), "UIImageView")
	nLabelWordLeft:setVisible(normalCD == 0)
	
	local sLabelCD = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_specialUpTime"), "UILabel")
	sLabelCD:setVisible(specialCD ~= 0)
	local sLabelWordRight = tolua.cast(CommonFunc_getLabelByName(mRootView, "ImageView_49"), "UIImageView")
	sLabelWordRight:setVisible(specialCD ~= 0)
	-- local sLabelCount = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_specialCount"), "UILabel")
	-- sLabelCount:setVisible(specialCD == 0)
	local sLabelWordLeft = tolua.cast(CommonFunc_getLabelByName(mRootView, "ImageView_50"), "UIImageView")
	sLabelWordLeft:setVisible(specialCD == 0)
	
end

-- 时间UI初始化
local function timerUIInit()
	if nil == mRootView then
		return
	end
	-- 普通寻宝上层时间
	local nLabelCD = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_normalUpTime"), "UILabel")
	nLabelCD:setText(CommonFunc_secToString(normalCD))
	
	-- 普通寻宝上层次数
	local nLabelCount = tolua.cast(CommonFunc_getLabelByName(mRootView, "LabelAtlas_normalCount"), "UILabelAtlas")
	nLabelCount:setStringValue(tostring(normalFreeTimes))
	
	-- 特殊寻宝上层时间
	local sLabelCD = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_specialUpTime"), "UILabel")
	sLabelCD:setText(CommonFunc_secToString(specialCD))
	
	-- 特殊寻宝上层次数
	local sLabelCount = tolua.cast(CommonFunc_getLabelByName(mRootView, "LabelAtlas_specialCount"), "UILabelAtlas")
	sLabelCount:setStringValue(tostring(specialFreeTimes))
	
	
	-- 普通寻宝下层时间
	local oneNormalCD = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_oneNormalCD"), "UILabel")
	local oneNormalPay = tolua.cast(mRootView:getChildByName("Label_oneNormalPay"), "UILabel")
	if normalCD ~= 0 then
		local oneNormalStr = CommonFunc_secToString(normalCD)..GameString.get("RUNE_NORMAL_CD")
		oneNormalCD:setText(oneNormalStr)
		oneNormalPay:setText(RUNE_ONE_NORMAL_PAY)
	elseif normalCD == 0 and normalFreeTimes ~= 0 then
		local oneNormalStr = GameString.get("RUNE_FREE_TIMES", normalFreeTimes, RUNE_NORMAL_COUNT)
		oneNormalCD:setText(oneNormalStr)
		oneNormalPay:setText(GameString.get("RUNE_FOR_FREE"))
	elseif normalCD == 0 and normalFreeTimes == 0 then
		local oneNormalStr = GameString.get("RUNE_FREE_TIMES", normalFreeTimes, RUNE_NORMAL_COUNT)
		oneNormalCD:setText(oneNormalStr)
		oneNormalPay:setText(RUNE_ONE_NORMAL_PAY)
	end
	
	-- 特殊寻宝下层时间
	local oneSpecialCD = tolua.cast(CommonFunc_getLabelByName(mRootView, "Label_oneSpecialCD"), "UILabel")
	local oneSpecialPay = tolua.cast(mRootView:getChildByName("Label_oneSpecialPay"), "UILabel")
	if specialCD ~= 0 then
		local oneSpecialStr = CommonFunc_secToString(specialCD)..GameString.get("RUNE_NORMAL_CD")
		oneSpecialCD:setText(oneSpecialStr)
		oneSpecialPay:setText(RUNE_ONE_SPECIAL_PAY)
	elseif specialCD == 0 then
		local oneSpecialStr = GameString.get("RUNE_FREE_TIMES", specialFreeTimes, RUNE_SPECIAL_COUNT)
		oneSpecialCD:setText(oneSpecialStr)
		oneSpecialPay:setText(GameString.get("RUNE_FOR_FREE"))
	end
	
	controlTimerV()
end

-- 禁止所有点击事件
local function forbiddenUIClick()
	if nil == mRootView then
		return
	end
	-- 普通寻宝开启
	local normalOpen = tolua.cast(mRootView:getChildByName("ImageView_normalOpen"), "UIImageView")
	normalOpen:setTouchEnabled(false)
	local normalLeft = tolua.cast(mRootView:getChildByName("ImageView_normalLeft"), "UIImageView")
	normalLeft:setTouchEnabled(false)
	local normalRight = tolua.cast(mRootView:getChildByName("ImageView_normalRight"), "UIImageView")
	normalRight:setTouchEnabled(false)
	-- 特殊寻宝开启
	local specialOpen = tolua.cast(mRootView:getChildByName("ImageView_specialOpen"), "UIImageView")
	specialOpen:setTouchEnabled(false)
	local specialLeft = tolua.cast(mRootView:getChildByName("ImageView_specialLeft"), "UIImageView")
	specialLeft:setTouchEnabled(false)
	local specialRight = tolua.cast(mRootView:getChildByName("ImageView_specialRight"), "UIImageView")
	specialRight:setTouchEnabled(false)
	-- 普通寻宝关闭
	local normalClose = tolua.cast(mRootView:getChildByName("Button_normalClose"), "UIButton")
	normalClose:setTouchEnabled(false)
	-- 特殊寻宝关闭
	local specialClose = tolua.cast(mRootView:getChildByName("Button_specialClose"), "UIButton")
	specialClose:setTouchEnabled(false)
	--单次普通寻宝
	local normalOne = tolua.cast(mRootView:getChildByName("ImageView_normalOne"), "UIImageView")
	normalOne:setTouchEnabled(false)
	-- 十次普通寻宝
	local normalTen = tolua.cast(mRootView:getChildByName("ImageView_normalTen"), "UIImageView")
	normalTen:setTouchEnabled(false)
	-- 单次稀有寻宝
	local specialOne = tolua.cast(mRootView:getChildByName("ImageView_specialOne"), "UIImageView")
	specialOne:setTouchEnabled(false)
	-- 十次稀有寻宝
	local specialTen = tolua.cast(mRootView:getChildByName("ImageView_specialTen"), "UIImageView")
	specialTen:setTouchEnabled(false)
end

-- 关门
local function lockDoor(weightName)
	if nil == mRootView then
		return
	end
	local leftName = nil
	local rightName = nil
	if weightName == "Button_normalClose" then
		leftName = "ImageView_normalLeft"
		rightName = "ImageView_normalRight"
		blackName = "ImageView_normalBlack"
		nodeName = "ImageView_normalNode"
		isNormalOpen = false
	elseif weightName == "Button_specialClose" then
		leftName = "ImageView_specialLeft"
		rightName = "ImageView_specialRight"
		blackName = "ImageView_specialBlack"
		nodeName = "ImageView_specialNode"
		isSpecialOpen = false
	end
	
	local function lockActionDone()
		controlDoorClick()
		controlRuneClick()
	end
	
	local function callFuncControl()
		if nil == mRootView then
			return
		end
		
		controlUILabel()
		local leftDoor = tolua.cast(mRootView:getChildByName(nodeName), "UIImageView")
		local rightDoor = tolua.cast(mRootView:getChildByName(rightName), "UIImageView")
		
		local leftMove = CCEaseExponentialOut:create(CCMoveBy:create(1.0, CCPointMake(522, 0)))
		local rightMove = CCEaseExponentialOut:create(CCMoveBy:create(1.0, CCPointMake(-298, 0)))
		
		leftDoor:runAction(CCSequence:createWithTwoActions(leftMove, CCCallFunc:create(lockActionDone)))
		rightDoor:runAction(CCSequence:createWithTwoActions(rightMove, CCCallFunc:create(lockActionDone)))
		
		if isNormalOpen == false then
			local labelNormal = tolua.cast(mRootView:getChildByName("Label_normal"), "UILabel")
			labelNormal:runAction(CCScaleTo:create(1.0, 1.0))
		end
	end
	
	timerUIInit()
	local closeButton = tolua.cast(mRootView:getChildByName(weightName), "UIButton")
	local time_move = 0.1
	local action_move = CCMoveBy:create(time_move,ccp(65, 0))
	action_move = CCEaseBackOut:create(action_move)
	local action_call = CCCallFunc:create(callFuncControl)
	local action = CCSequence:createWithTwoActions(action_move,action_call)
	closeButton:runAction(action)
end

-- 开门
local function unlockDoor(weightName)
	if nil == mRootView then
		return
	end
	local leftName = nil
	local rightName = nil
	local closeName = nil
	if weightName == "ImageView_normalOpen" or weightName == "ImageView_normalLeft" or weightName == "ImageView_normalRight" then
		leftName = "ImageView_normalLeft"
		rightName = "ImageView_normalRight"
		closeName = "Button_normalClose"
		blackName = "ImageView_normalBlack"
		nodeName = "ImageView_normalNode"
		isNormalOpen = true
	elseif weightName == "ImageView_specialOpen" or weightName == "ImageView_specialLeft" or weightName == "ImageView_specialRight" then
		leftName = "ImageView_specialLeft"
		rightName = "ImageView_specialRight"
		closeName = "Button_specialClose"
		blackName = "ImageView_specialBlack"
		nodeName = "ImageView_specialNode"
		isSpecialOpen = true
	end
	local leftDoor = tolua.cast(mRootView:getChildByName(nodeName), "UIImageView")
	local rightDoor = tolua.cast(mRootView:getChildByName(rightName), "UIImageView")
	
	local function unlockActionDone()
		-- controlUI()
		controlDoorClick()
	end
	
	local function callFuncControl()
		if nil == mRootView then
			return
		end
		
		if GuideMgr.guideStatus() > 0 then
			unlockActionDone()
		else
			local closeButton = tolua.cast(mRootView:getChildByName(closeName), "UIButton")
			local time_move = 0.1
			local action_move = CCMoveBy:create(time_move,ccp(-65,0))
			local action_callFunc = CCCallFunc:create(unlockActionDone)
			local action = CCSequence:createWithTwoActions(action_move,action_callFunc)
			closeButton:runAction(action)
		end
	end
	
	timerUIInit()
	controlUILabel()
	controlRuneClick()
	local leftMove = CCEaseExponentialOut:create(CCMoveBy:create(1.0, CCPointMake(-522, 0)))
	local rightMove = CCEaseExponentialOut:create(CCMoveBy:create(1.0, CCPointMake(298, 0)))
	leftDoor:runAction(leftMove)
	rightDoor:runAction(CCSequence:createWithTwoActions(rightMove, CCCallFunc:create(callFuncControl)))
end

-- 发送寻宝类型
local function sendRuneMsg(widget)
	LayerRune.updateUnlockSkill()
	for key,val in pairs(tbClickButton) do
		val:setTouchEnabled(false)
	end
	local tb = req_sculpture_divine()
	tb.type = tonumber(widget:getTag())
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_divine"])
end

-- 十次稀有寻宝点击事件
local function tenSpecialClick(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	-- 魔石不足
	if CommonFunc_payConsume(2, RUNE_TEN_SPECIAL_PAY) then
		return
	end
	local function dialogSureCall()
		sendRuneMsg(widget)
	end
	local str = "RUNE_SPECIAL_PAY_TEN"
	local diaMsg = 
	{
		strText = string.format(GameString.get(str, RUNE_TEN_SPECIAL_PAY)),
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end

-- 单次稀有寻宝点击事件
local function oneSpecialClick(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	if specialCD == 0 then
		resetSpecialCD = true
		sendRuneMsg(widget)
	else
		if CommonFunc_payConsume(2, RUNE_ONE_SPECIAL_PAY) then
			return
		end
		local function dialogSureCall()
			sendRuneMsg(widget)
		end
		local str = "RUNE_SPECIAL_PAY_ONE"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RUNE_ONE_SPECIAL_PAY)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	end
end

-- 十次普通寻宝点击事件
local function tenNormalClick(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	if CommonFunc_payConsume(1, RUNE_TEN_NORMAL_PAY) then
		return
	end
	local function dialogSureCall()
		sendRuneMsg(widget)
	end
	local str = "RUNE_NORMAL_PAY_TEN"
	local diaMsg = 
	{
		strText = string.format(GameString.get(str, RUNE_TEN_NORMAL_PAY)),
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end

-- 单次普通寻宝点击事件
local function oneNormalClick(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	if normalCD == 0 and normalFreeTimes ~= 0 then
		resetNormalCD = true
		sendRuneMsg(widget)
	elseif normalCD ~= 0 or normalFreeTimes == 0 then
		-- 金币不足
		if CommonFunc_payConsume(1, RUNE_ONE_NORMAL_PAY) then
			return
		end
		local function dialogSureCall()
			sendRuneMsg(widget)
		end
		local str = "RUNE_NORMAL_PAY_ONE"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RUNE_ONE_NORMAL_PAY)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	end
end

-- 点击事件
local function clickBtn(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	TipModule.onClick(widget)
	local weightName = widget:getName()
	if weightName == "ImageView_close" then
		LayerMain.pullPannel()
	elseif weightName == "ImageView_normalOpen" or weightName == "ImageView_normalLeft" or weightName == "ImageView_normalRight" then
		forbiddenUIClick()
		unlockDoor(weightName)
	elseif weightName == "ImageView_specialOpen" or weightName == "ImageView_specialLeft" or weightName == "ImageView_specialRight" then
		forbiddenUIClick()
		unlockDoor(weightName)
	elseif weightName == "Button_normalClose" or weightName == "Button_specialClose" then
		forbiddenUIClick()
		lockDoor(weightName)
	end
end

-- 特殊寻宝CD结束回调函数
local function specialTimerOverCF(tm)
	mSpecialTimer = nil
	resetSpecialCD = true
	timerUIInit()
	LayerMain.showRuneTip()
end

-- 特殊寻宝CD每秒调用函数
local function specialTimerRunCF(tm)
	if specialCD > 0 then
		specialCD = specialCD - 1
	end
	timerUIInit()
end

-- 普通寻宝CD结束回调函数
local function normalTimerOverCF(tm)
	mNormalTimer = nil
	if normalFreeTimes ~= 0 then
		resetNormalCD = true
	end
	timerUIInit()
	LayerMain.showRuneTip()
end

-- 普通寻宝CD每秒调用函数
local function normalTimerRunCF(tm)
	if normalCD > 0 then
		normalCD = normalCD - 1
	end
	timerUIInit()
end

-- 启动特殊计时器
local function startSpecialTimer()
	if specialCD > 0 then
		mSpecialTimer = CreateTimer(1, specialCD, specialTimerRunCF, specialTimerOverCF)
		mSpecialTimer.start()
	end
end

-- 启动普通计时器
local function startNormalTimer()
	if normalCD > 0 then
		mNormalTimer = CreateTimer(1, normalCD, normalTimerRunCF, normalTimerOverCF)
		-- normalTimer.setParam(normalTimerRunCF)
		mNormalTimer.start()
	end
end

-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	normalFreeTimes = RUNE_NORMAL_COUNT
	normalCD = RUNE_NORMAL_CD
	timerUIInit()
end

-- 判断是否有免费召唤可用
LayerRune.isShowTip = function()
	local pRet = false
	if (normalCD == 0 and normalFreeTimes >= 1) or specialCD == 0 then
		pRet = true
	end
	return pRet
end

-- 接收寻宝CD和普通寻宝剩余免费次数
local function handleNotifyDivine(resp)
	TipFunction.setFuncAttr("func_rank_match", "count", resp.play_times)
	-- 缓存
	-- tbRuneTimes = resp
	
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		-- 创建每日定时器
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	
	-- 普通寻宝剩余次数
	normalFreeTimes = resp.count
	-- 稀有召唤剩余次数
	specialFreeTimes = RUNE_SPECIAL_COUNT
	-- 冷却时间
	if normalFreeTimes == 0 then
		normalCD = 0
	else
		normalCD = resp.common_remain_time
	end
	specialCD = resp.rare_remain_time
	-- 计时开始
	startNormalTimer()
	startSpecialTimer()
	LayerMain.showRuneTip()
	LayerMainEnter.setReqChallengeFlage(true)
end

-- 接收服务端发回的消息
local function handleSculptureDivine(packet)
	for key,val in pairs(tbClickButton) do
		val:setTouchEnabled(true)
	end
	if packet.result ~= 1 then
		-- controlUI()
		timerUIInit()
		return
	end
	TipModule.onNet("msg_notify_sculpture_divine")
	-- tbRewardList = packet.reward_list
	if packet.type == 1 and resetNormalCD == false then
		
	elseif packet.type == 1 and resetNormalCD == true and normalFreeTimes > 1 then
		normalFreeTimes = normalFreeTimes - 1
		normalCD = RUNE_NORMAL_CD
		resetNormalCD = false
		-- controlUI()
		timerUIInit()
		startNormalTimer()
	elseif packet.type == 1 and resetNormalCD == true and normalFreeTimes == 1 then
		normalFreeTimes = normalFreeTimes - 1
		resetNormalCD = false
		timerUIInit()
	elseif packet.type == 3 and resetSpecialCD == false then
		
	elseif packet.type == 3 and resetSpecialCD == true then
		specialCD = RUNE_SPECIAL_CD
		resetSpecialCD = false
		timerUIInit()
		startSpecialTimer()
	end
	if UIManager.getTopLayerName() ~= "UI_RuneReward" then
		if packet.type == 1 or packet.type == 3 then
			local bundle = LogicTable.getRewardItemRow(packet.reward_list[1].id)
			bundle.amount = packet.reward_list[1].amount
			bundle.runeType = packet.type
			UIManager.push("UI_RuneShow", bundle)
			-- UIManager.push("UI_RuneReward",packet)
		elseif packet.type == 2 or packet.type == 4 then
			UIManager.push("UI_RuneReward",packet)
		end
	else
		LayerRuneReward.init(packet)
	end
	LayerMain.showRuneTip()
end

-- 初始化静态UI
local function initUI()
	tbClickButton = {}
	-- 关闭按钮
	local closeBtn = tolua.cast(mRootView:getChildByName("ImageView_close"), "UIImageView")
    closeBtn:registerEventScript(clickBtn)
	table.insert(tbClickButton,closeBtn)
	-- 单次普通寻宝价格
	-- local oneNormalPay = tolua.cast(mRootView:getChildByName("Label_oneNormalPay"), "UILabel")
	-- oneNormalPay:setText(RUNE_ONE_NORMAL_PAY)
	-- 十次普通寻宝价格
	local tenNormalPay = tolua.cast(mRootView:getChildByName("Label_tenNormalPay"), "UILabel")
	tenNormalPay:setText(RUNE_TEN_NORMAL_PAY)
	-- 单次稀有寻宝价格
	-- local oneSpecialPay = tolua.cast(mRootView:getChildByName("Label_oneSpecialPay"), "UILabel")
	-- oneSpecialPay:setText(RUNE_ONE_SPECIAL_PAY)
	-- 十次稀有寻宝价格
	local tenSpecialPay = tolua.cast(mRootView:getChildByName("Label_tenSpecialPay"), "UILabel")
	tenSpecialPay:setText(RUNE_TEN_SPECIAL_PAY)
	-- 普通寻宝开启
	local normalOpen = tolua.cast(mRootView:getChildByName("ImageView_normalOpen"), "UIImageView")
	normalOpen:registerEventScript(clickBtn)
	-- table.insert(tbClickButton,normalOpen)
	local normalLeft = tolua.cast(mRootView:getChildByName("ImageView_normalLeft"), "UIImageView")
	normalLeft:registerEventScript(clickBtn)
	local normalRight = tolua.cast(mRootView:getChildByName("ImageView_normalRight"), "UIImageView")
	normalRight:registerEventScript(clickBtn)
	-- 普通寻宝关闭
	local normalClose = tolua.cast(mRootView:getChildByName("Button_normalClose"), "UIButton")
	normalClose:registerEventScript(clickBtn)
	table.insert(tbClickButton,normalClose)
	-- 特殊寻宝开启
	local specialOpen = tolua.cast(mRootView:getChildByName("ImageView_specialOpen"), "UIImageView")
	specialOpen:registerEventScript(clickBtn)
	-- table.insert(tbClickButton,specialOpen)
	local specialLeft = tolua.cast(mRootView:getChildByName("ImageView_specialLeft"), "UIImageView")
	specialLeft:registerEventScript(clickBtn)
	local specialRight = tolua.cast(mRootView:getChildByName("ImageView_specialRight"), "UIImageView")
	specialRight:registerEventScript(clickBtn)
	-- 特殊寻宝关闭
	local specialClose = tolua.cast(mRootView:getChildByName("Button_specialClose"), "UIButton")
	specialClose:registerEventScript(clickBtn)
	table.insert(tbClickButton,specialClose)
	--单次普通寻宝
	local normalOne = tolua.cast(mRootView:getChildByName("ImageView_normalOne"), "UIImageView")
	normalOne:setTag(1)
	normalOne:registerEventScript(oneNormalClick)
	table.insert(tbClickButton,normalOne)
	-- 十次普通寻宝
	local normalTen = tolua.cast(mRootView:getChildByName("ImageView_normalTen"), "UIImageView")
	normalTen:setTag(2)
	normalTen:registerEventScript(tenNormalClick)
	table.insert(tbClickButton,normalTen)
	-- 单次稀有寻宝
	local specialOne = tolua.cast(mRootView:getChildByName("ImageView_specialOne"), "UIImageView")
	specialOne:setTag(3)
	specialOne:registerEventScript(oneSpecialClick)
	table.insert(tbClickButton,specialOne)
	-- 十次稀有寻宝
	local specialTen = tolua.cast(mRootView:getChildByName("ImageView_specialTen"), "UIImageView")
	specialTen:setTag(4)
	specialTen:registerEventScript(tenSpecialClick)
	table.insert(tbClickButton,specialTen)
	-- 粒子特效
	local normalBlack = tolua.cast(mRootView:getChildByName("ImageView_normalBlack"), "UIImageView")
	hexagonParticleEffect(normalBlack)
	local specialBlack = tolua.cast(mRootView:getChildByName("ImageView_specialBlack"), "UIImageView")
	halfRoundParticleEffect(specialBlack)
	-- 单次普通召唤文本介绍
	-- local normalLabel = tolua.cast(mRootView:getChildByName("Label_82"), "UIImageView")
	local str_1 = GameString.get("RUNE_NORMAL_TEXT")
	local normalOneLayout = UILayoutHtml.create(str_1, "fzzdh.TTF", 22, 213)
	normalOneLayout:setPosition(ccp(-100, -42))
	normalOne:addChild(normalOneLayout)
	-- 十次普通召唤文本介绍
	local str_2 = GameString.get("RUNE_NORMAL_TEXT")
	local normalTenLayout = UILayoutHtml.create(str_2, "fzzdh.TTF", 22, 213)
	normalTenLayout:setPosition(ccp(-100, -42))
	normalTen:addChild(normalTenLayout)
	-- 单次稀有召唤文本介绍
	local str_3 = GameString.get("RUNE_SPECIAL_TEXT")
	local specialOneLayout = UILayoutHtml.create(str_3, "fzzdh.TTF", 22, 213)
	specialOneLayout:setPosition(ccp(-100, -42))
	specialOne:addChild(specialOneLayout)
	-- 十次稀有召唤文本介绍
	local str_4 = GameString.get("RUNE_SPECIAL_TEXT")
	local specialTenLayout = UILayoutHtml.create(str_4, "fzzdh.TTF", 22, 213)
	specialTenLayout:setPosition(ccp(-100, -42))
	specialTen:addChild(specialTenLayout)
	-- normalLabel:ignoreContentAdaptWithSize(false)
	-- normalLabel:setSize(CCSizeMake(213, 56))
	-- 控制UI点击事件
	-- controlUI()
	controlUILabel()
	controlDoorClick()
	controlRuneClick()
	-- 控制时间UI
	timerUIInit()
end

-- 初始化
LayerRune.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		cclog("mRootView == nil")
		return
	end
	
	isNormalOpen = false
	isSpecialOpen = false
	initUI()
	TipModule.onUI(rootView, "ui_rune")
end

LayerRune.purge = function()
	mRootView = nil
end

-- 
LayerRune.destroy = function()
	cclog("LayerGameRank destroy!")
    mRootView = nil
	mbTouchEnable = true
	isNormalOpen = false
	isSpecialOpen = false
	unlockSkillTb = nil
end
--endregion


NetSocket_registerHandler(NetMsgType["msg_notify_divine_info"], notify_divine_info, handleNotifyDivine)  -- 初始化冷却时间
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_divine"], notify_sculpture_divine, handleSculptureDivine)  -- 接受抽奖信息