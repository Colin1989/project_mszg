-- Author: shenl
-- Date: 2014-02-20
require "FactoryAnimation"

local sceneLoading = nil 

local mUpDate = 0

local tipTable = nil --小贴士查询


local function loadContent(id)
	tipContent = XmlTable_load("text_tplt.xml")
	local res = XmlTable_getRow(tipContent, "id", id)
	local row = {}
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "content" == v.name then
			row.content = v.value	
		end
	end
	return row
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

local function Handle_closeLoading(node)
	--print("-------Handle---loadingEnd------")
	CCDirector:sharedDirector():popScene()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mUpDate)	
	createGameSceneLayer(g_Const_GameStatus.GamePlay,LayerCopyTips.getCurCopyRes_id())
end
			
local loadCount = 0		
local function createLoadingLayer()
	
	local Screen = CCDirector:sharedDirector():getVisibleSize()
	local backLayer = CCLayer:create()
	
	local layer1 = CCLayerColor:create(ccc4(2,10,14,255), Screen.width, Screen.height)
    --layer1:setCascadeColorEnabled(true)
	backLayer:addChild(layer1)
	
	
	local layer2 = CCLayerColor:create(ccc4(24,33,38,255), Screen.width, Screen.height*4/5)
    --layer1:setCascadeColorEnabled(true)
	layer2:setPosition(ccp(0,Screen.height/10))
	--layer2:setAnchorPoint(ccp(0.5,0.5))
	backLayer:addChild(layer2)		
	
		
	-- animtion 
	local aniSpr = createAnimation_forever("monster003_attack_%03d.png",12,0.1)
	aniSpr:setPosition(ccp(Screen.width/2,Screen.height/2))
	aniSpr:setAnchorPoint(ccp(0.5,0.5))
	aniSpr:setScale(1.3)
	backLayer:addChild(aniSpr)
	

	
	
	-- tips
	if tipTable == nil then 
		tipTable = loadContent(20000)
	end 
	
	local tipsFont = createLoadingFont(30,202,233,251)
    tipsFont:setString(tipTable.content)
	tipsFont:setPosition(ccp(Screen.width/2,Screen.height/2-240))
	backLayer:addChild(tipsFont)
	
	
	local LoadFont = createLoadingFont(48,127,188,223)
    LoadFont:setString("Loading".."...")
	LoadFont:setPosition(ccp(Screen.width/2-100,Screen.height/2-200))
	LoadFont:setAnchorPoint(ccp(0,0))
	backLayer:addChild(LoadFont)
	
	local function updateLoading(dt)
		loadCount = loadCount + 1
		if loadCount > 3 then 
			loadCount = 1
		end
	
		if loadCount == 1 then 
			LoadFont:setString("Loading.")
		elseif loadCount == 2 then 
			LoadFont:setString("Loading..")
		elseif loadCount == 3 then
			LoadFont:setString("Loading...")
		end		
	end
	
	mUpDate = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateLoading, 0.5, false)
	
	 local function onNodeEvent(event)
        if event == "enter" then
			print("------curNode------------")
			local curNode = CCNode:create()			
			backLayer:addChild(curNode)
			local actioN = CCSequence:createWithTwoActions(CCDelayTime:create(1.0),CCCallFuncN:create(Handle_closeLoading))
			curNode:runAction(actioN)
			LoadResouse(1)
        end
    end
    backLayer:registerScriptHandler(onNodeEvent)
	return backLayer
end

-- run
function StartLoading()
	
	if sceneLoading == nil then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("monster/monster003.plist");

	end
	sceneLoading = CCScene:create()
	local backLayer = createLoadingLayer()
	sceneLoading:addChild(backLayer)
	--CCDirector:sharedDirector():pushScene( CCTransitionShrinkGrow:create(1, sceneLoading) )
	CCDirector:sharedDirector():pushScene(CCTransitionFade:create(0.5, sceneLoading, ccc3(24,33,38)))
	--CCDirector:sharedDirector():pushScene(sceneLoading)
	
end




