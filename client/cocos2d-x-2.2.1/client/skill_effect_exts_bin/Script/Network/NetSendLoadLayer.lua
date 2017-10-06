NetSendLoadLayer = {
}

local mSendLayer = nil 
local m_bIsFirstLoading = false 
local LAYER_TAG = 200

local function onTouchBegan(x,y)	
		return true
end
	
local function onTouchMoved(x,y)

end
	
local function onTouchEnded(x,y)

end	
local function onTouch(eventType,x,y)     
	if eventType == "began" then   
        return onTouchBegan(x, y)
    elseif eventType == "moved" then
        return onTouchMoved(x, y)
    else
        return onTouchEnded(x, y)	
	end	
		
end

NetSendLoadLayer.show = function()
	
	if (mSendLayer ~= nil) then 
		mSendLayer:setVisible(true)
		mSendLayer:registerScriptTouchHandler(onTouch,false,-1000,true)
		return 
	end
	
	local Size = CCDirector:sharedDirector():getVisibleSize()
	local sprite = CCSprite:create("loading.png")
	sprite:setPosition(ccp(Size.width/2,Size.height/2))
	
	--CCTwirl* create(float duration, const CCSize& gridSize, CCPoint position, unsigned int twirls, float amplitude);
	--CCTwirl::create(CCPointMake(size.width/2, size.height/2), 2, 2.5f, ccg(12, 8), 3);
	local rotate =  CCRotateBy:create(0.5, 360);
	sprite:runAction(CCRepeatForever:create(rotate))
	
	

	
	mSendLayer = CCLayer:create()
	mSendLayer:setTag(LAYER_TAG)
	mSendLayer:addChild(sprite)
	
	mSendLayer:registerScriptTouchHandler(onTouch,false,-1000,true)
	mSendLayer:setTouchEnabled(true)
	g_rootNode:addChild(mSendLayer,90000)			---------------test
end

NetSendLoadLayer.dismiss = function()
	if mSendLayer then 	
		mSendLayer:unregisterScriptTouchHandler()
		--mSendLayer:getParent():removeChild(mSendLayer,true)
		
		--g_rootNode:removeChildByTag(LAYER_TAG,true)
		mSendLayer:setVisible(false)
		--mSendLayer = nil
	end
end








