loadingDoorForOpen = {}

--"UI_DoorForOpen "
local mSpriteUp = nil
local mSpriteBottom = nil

LayerAbstract:extend(loadingDoorForOpen)

OPEN_THE_DOOR_TIME = 1.5
OPEN_DELAYTME = 1.0

local mOpenFlag = false		--表示门有没有打开
loadingDoorForOpen.getOpenFlag = function()
	return mOpenFlag
end

loadingDoorForOpen.setOpenFlag = function()
	 mOpenFlag = true
end

loadingDoorForOpen.destroy = function()
	mSpriteUp = nil
	mSpriteBottom = nil
	mOpenFlag = false	
end

loadingDoorForOpen.create =function()


	local m_iScreenSize = CCDirector:sharedDirector():getVisibleSize()

	local UI_Root = UILayout:create()
	UI_Root:setSize(CCSizeMake(m_iScreenSize.width,m_iScreenSize.height))
	
	mSpriteBottom = UIImageView:create()
	mSpriteBottom:loadTexture("loaddoordown.png")
	mSpriteBottom:setAnchorPoint(ccp(0,0))
	mSpriteBottom:setPosition(ccp(0,0))
	UI_Root:addChild(mSpriteBottom)

	mSpriteUp = UIImageView:create()
	mSpriteUp:loadTexture("loaddoorup.png")
	mSpriteUp:setAnchorPoint(ccp(0,1))
	mSpriteUp:setPosition(ccp(0,m_iScreenSize.height))
	UI_Root:addChild(mSpriteUp)

	return UI_Root
end


loadingDoorForOpen.init = function()
	
	local disUp = mSpriteUp:getContentSize().height
	local actionUp = CCEaseSineOut:create(CCMoveBy:create(OPEN_THE_DOOR_TIME - OPEN_DELAYTME,CCPointMake(0,(1)*disUp))) 
	
	local arr_0 = CCArray:create()
	arr_0:addObject(CCDelayTime:create(OPEN_DELAYTME))
    arr_0:addObject(actionUp)
	mSpriteUp:runAction(CCSequence:create(arr_0))	
	
	
	local disDown = mSpriteBottom:getContentSize().height
	local actionDown = CCEaseSineOut:create(CCMoveBy:create(OPEN_THE_DOOR_TIME - OPEN_DELAYTME,CCPointMake(0,(-1)*disDown))) 

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(OPEN_DELAYTME))
    arr:addObject(actionDown)
    arr:addObject(CCCallFunc:create(function()
		Audio.playBgMscByTag(3)--主页音乐
		UIManager.pop("UI_DoorForOpen")
		GuideMgr.onEnter()
		local mainLayerRoot = UIManager.findLayerByTag("UI_Main")
		mainLayerRoot:setTouchEnabled(false)
		TipModule.onUI(mainLayerRoot, "ui_main")
		CopyDelockLogic.loadUnLockImage()
		loadingDoorForOpen.setOpenFlag()
	end
	))
	mSpriteBottom:runAction(CCSequence:create(arr))	
end


