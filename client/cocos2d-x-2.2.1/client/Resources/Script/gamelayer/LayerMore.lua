----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-30
-- Brief:	主页下方更多界面
----------------------------------------------------------------------
LayerMore = {}
local mRootNode = nil
local mbOnAction = false

------------------------------------进入、退出动画----------------------------------
local function enterCB(sender)
	mbOnAction = false
end

--进场动画
local function onEnter()
	
	local desktop = mRootNode:getWidgetByName("Panel_more")
	tolua.cast(desktop, "UILayout")
	desktop:setScale(0.0)
	desktop:setPosition(ccp(640,0))
	
	local duration = 0.2
	local arr = CCArray:create()
	local act1 = CCSpawn:createWithTwoActions(CCScaleTo:create(duration, 1.0), CCMoveTo:create(duration, ccp(0, 0)))
    arr:addObject(act1)
	arr:addObject(CCCallFuncN:create(enterCB))
	desktop:runAction(CCSequence:create(arr))
	mbOnAction = true
end

local function exitCB(sender)
	mbOnAction = false
	UIManager.pop("UI_More")
end

--出场动画
local function onExit()
	local desktop = mRootNode:getWidgetByName("Panel_more")
	tolua.cast(desktop, "UILayout")
	
	local duration = 0.2
	local arr = CCArray:create()
	local act1 = CCSpawn:createWithTwoActions(CCScaleTo:create(duration, 0.0), CCMoveTo:create(duration,ccp(640,0)))
    arr:addObject(act1)
	arr:addObject(CCCallFuncN:create(exitCB))
	desktop:runAction(CCSequence:create(arr))
	mbOnAction = true
end

-------------------------------------点击事件---------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		if mbOnAction == true then
			return
		end
		onExit()
	end
end

--点击各个图标的函数
local function clickScrollItem(typeName, widget)
	if mbOnAction == true then
		return
	end
	
	local str = nil
	
	if "releaseUp" == typeName then
		local widgetName = widget:getName()
		onExit()
		
		if widgetName == "social" then	--社交
			setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json",weightName)
			return
		end
		
		LayerMain.pullPannel()			--回主城
		local function pushAction()
			if widgetName == "setUp" then		--设置
				UIManager.push("UI_Setup")
			elseif widgetName == "exchangeCode" then	--兑换码
				UIManager.push("UI_activalReward")
			end
		end
		local rootNode1 = LayerMain.getLayerRoot()
		local action = CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFuncN:create(pushAction))
		rootNode1:runAction(action)	
	end
end
----------------------------------------------------------------------
-- 初始化
LayerMore.init = function(bundle)
	mRootNode = UIManager.findLayerByTag("UI_More")
	
	mBundle = bundle
	onEnter()
	--panel
	local panel = tolua.cast(mRootNode:getWidgetByName("Panel_more"),"UILayout")			
	panel:registerEventScript(clickCloseBtn)
	
	--关闭按钮
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("close"),"UIButton")			
	closeBtn:registerEventScript(clickCloseBtn)
	--为各个图标注册事件
	--设置
	local setUp = tolua.cast(mRootNode:getWidgetByName("setUp"),"UIImageView")	
	setUp:registerEventScript(clickScrollItem)
	--社交
	local social = tolua.cast(mRootNode:getWidgetByName("social"),"UIImageView")
	social:registerEventScript(clickScrollItem)
	LayerMore.showSocialContactTip()
	--兑换码
	local dhmIcon = mRootNode:getWidgetByName("exchangeCode")	
	dhmIcon:setTouchEnabled(true)
	dhmIcon:registerEventScript(clickScrollItem)
end
----------------------------------------------------------------------
-- 销毁
LayerMore.destroy = function()
	mRootNode = nil
end
---------------------------------感叹号(社交)-----------------------------
--获得社交功能提示
LayerMore.getSocialContactTip = function()
	if CopyDateCache.getCopyStatus(LIMIT_Social.copy_id) ~= "pass"  then
		return false
	end

	local falg = false
	if FriendPointLogic.existAward() then
		falg = true
	end
	if FriendDataCache.existTip() then
		falg = true
	end
	if LayerInviteCode.judgeHasTipInviteCode() then
		falg = true
	end
	--print("getSocialContactTip()***************",FriendDataCache.existTip(),FriendPointLogic.existAward(),LayerInviteCode.judgeHasTipInviteCode())
	return	falg
end

--设置社交功能提示
LayerMore.showSocialContactTip = function()
	if nil == mRootNode then
		return
	end
	local socialTipIcon = tolua.cast(mRootNode:getWidgetByName("social_tip"),"UIImageView")
	local flag = LayerMore.getSocialContactTip()
	socialTipIcon:setVisible(flag)
end

EventCenter_subscribe(EventDef["ED_FRIEND_POINT_GET"], LayerMore.showSocialContactTip)		--友情点

----------------------------感叹号（总界面）------------------------------
--获得更多界面的感叹号
LayerMore.getTip = function()
	local flag = false
	--社交
	if LayerMore.getSocialContactTip() then	
		flag = true
	end
	return flag
end
--------------------------------------------------------
