-- 网络转圈界面
NetSendLoadLayer = {}
local mSendLayer = nil 
local mIsWaitting = false

local function createLoadingLayer()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local loadingLayer = CCLayer:create()
	local sprite = CCSprite:create("loading.png")
	sprite:setPosition(ccp(winSize.width/2, winSize.height/2))
	sprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.15, 36)))
	loadingLayer:addChild(sprite)
	return loadingLayer
end

-- 显示转圈
NetSendLoadLayer.show = function()
	if true == mIsWaitting then
		return
	end
	mIsWaitting = true
	if nil == mSendLayer then
		mSendLayer = createLoadingLayer()
		g_rootNode:addChild(mSendLayer, 1992)
	end
	mSendLayer:registerScriptTouchHandler(function() return true end, false, -10000 - 2, true)
	mSendLayer:setVisible(true)
	mSendLayer:setTouchEnabled(true)
	g_sceneRoot:setTouchEnabled(false)
end

-- 隐藏转圈
NetSendLoadLayer.dismiss = function()
	if false == mIsWaitting then
		return
	end
	mIsWaitting = false
	if mSendLayer and true == mSendLayer:isVisible() then
		mSendLayer:unregisterScriptTouchHandler()
		mSendLayer:setVisible(false)
	end
	g_sceneRoot:setTouchEnabled(true)
end

-- 是否在转圈
NetSendLoadLayer.isWaitMessage = function()
	return mIsWaitting
end


