----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-4-4
-- 描述：战斗入场加载界面
----------------------------------------------------------------------

FightLoading = {}

local mUpdateID = nil
local mRefCnt = 0
local mLoadLabel = nil
local mLoadCount = 0
local mRootView = nil

local mDuration		= 0.0
local mLimitDuration = 1.5--最小等待时间

--开始
function FightLoading.start()
	mRefCnt = 0
	g_sceneRoot:setVisible(false)
	FightMgr.initMap()
    FightResLoader.loadResource()
	--FightResLoader.loadResource()
	GameScene.beforLoading()
	FightLoading.view()
	mLoadCount = 0
	mDuration = 0
	mUpdateID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(FightLoading.update, 0.1, false)
end

function FightLoading.onEnter()
	mUpdateID = nil
	mRootView = nil
end

function FightLoading.onExit()
	if mUpdateID ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mUpdateID)
		mUpdateID = nil 
	end
	if mRootView ~= nil then
		mRootView:removeFromParentAndCleanup(true)
		mRootView = nil
	end
	TipModule.onMessage("exit_fight_loading")
end

--更新视图
function FightLoading.update(dt)
	--if mRefCnt <= 0 then return end
	mDuration = mDuration + dt
	if mDuration > mLimitDuration then
		if mRefCnt <= 0 then
			FightMgr.start()
			GameScene.afterLoading()
			FightLoading.onExit()
			return
		end
	end
	mLoadCount = mLoadCount + 1

    if mLoadLabel == nil or tolua.isnull(mLoadLabel) then  
        return
    end 

	if mLoadCount == 1 then 	
	    mLoadLabel:setString("Loading.")
	elseif mLoadCount == 2 then 		
	    mLoadLabel:setString("Loading..")
	elseif mLoadCount == 3 then
	    mLoadLabel:setString("Loading...")
		mLoadCount = 0
	end	

end

--更新引用计数
function FightLoading.updateRef(count)
	mRefCnt = mRefCnt + count
end

local function createLoadingFont(fontSize,r,g,b)
	local font = CCLabelTTF:new()
	font:init()
	font:autorelease()
	font:setFontName("Marker Felt")
	font:setFontSize(fontSize)
	font:setColor(ccc3(r,g,b))
	return font
end

local mTextTable = XmlTable_load("text_tplt.xml", "id")
local function loadTips(id)
	local res = XmlTable_getRow(mTextTable, id, true)	
	return res.content
end

local function removeSelf(node)
	node:removeFromParentAndCleanup(true)
end

local mOldImgIdx = 0
local function tipsImage()
	if nil == mRootView then
		return
	end
	local idx = mOldImgIdx
	while true do 
		idx = math.random(1, 12)
		if idx ~= mOldImgIdx then
			mOldImgIdx = idx
			break
		end
	end
	
	local sprite = CCSprite:create(string.format("fight_loading/loading_0%02d.png", idx))
	mRootView:addChild(sprite)
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	sprite:setPosition(ccp(winSize.width / 2, winSize.height / 2))
	
	local arr = CCArray:create()
	arr:addObject(CCFadeIn:create(0.1))
	arr:addObject(CCDelayTime:create(5.0))
	arr:addObject(CCCallFunc:create(tipsImage))
	arr:addObject(CCFadeOut:create(0.3))
	arr:addObject(CCCallFuncN:create(removeSelf))
	sprite:runAction(CCSequence:create(arr))
end

--屏蔽下层事件
local function onTouch(eventType, x, y)
	if eventType == "began" then
		return true
	end
end
	
--创建视图
function FightLoading.view()
	local Screen = CCDirector:sharedDirector():getVisibleSize()
	mRootView = CCLayer:create()
	g_sceneUIRoot:addChild(mRootView, 1000)
	mRootView:registerScriptTouchHandler(onTouch, false, -200, true)
	
	local layer2 = CCLayerColor:create(ccc4(24,33,38,255), Screen.width, Screen.height*4/5)
	layer2:setPosition(ccp(0,Screen.height/10))
	mRootView:addChild(layer2)		
	
	-- animtion 
	tipsImage()
	--[[
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("monster/monster003.plist")
	local aniSpr = createAnimation_forever("monster003_attack_%03d.png",12,0.1)
	aniSpr:setPosition(ccp(Screen.width/2,Screen.height/2))
	aniSpr:setAnchorPoint(ccp(0.5,0.5))
	aniSpr:setScale(1.3)
	mRootView:addChild(aniSpr)
	]]--
	
	-- tips
	--[[
	local tipsFont = createLoadingFont(30,202,233,251)
    tipsFont:setString(loadTips(math.random(1, 21)))
	tipsFont:setPosition(ccp(Screen.width/2,Screen.height/2-240))
	mRootView:addChild(tipsFont)
	]]--
	
	
	mLoadLabel = createLoadingFont(48,127,188,223)
    mLoadLabel:setString("Loading".."...")
	mLoadLabel:setPosition(ccp(Screen.width/2-100,Screen.height/2-400))
	mLoadLabel:setAnchorPoint(ccp(0,0))
	mRootView:addChild(mLoadLabel)
end






