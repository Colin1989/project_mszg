local FF_LAYER_TAG = 2201
local mTTLayer = nil
local mScreenSize = CCDirector:sharedDirector():getWinSize()

local mStep = 1
local mStartPos = nil
local mIsPlayFont = false
local mIsFadeOut = false
local misPlaying = false	


local totalFont = {}  --总文字列表
local endEvent = ""   --结束事件    


local TextFont = {}


local function createNext()
	local NextItem = CCMenuItemFont:create("Next")
	NextItem:setPosition(ccp(mScreenSize.width - 100,30))
	
	
	local scaleby = CCScaleBy:create(0.2, 1.2);
    local actionbyback = scaleby:reverse()
	local action = CCSequence:createWithTwoActions(scaleby,actionbyback)
    NextItem:runAction(CCRepeatForever:create(action))
	
	mTTLayer:addChild(NextItem)
end 

local function onTouchBegan(x,y)
	return true
end
	
local function onTouchMoved(x,y)
	
end
	
local function onTouchEnded(x,y)
	
	if mIsFadeOut == true  then -- mStep == 3
		return
	end 

	if mIsPlayFont == true then 
		for k,v in pairs(TextFont) do
			v:stopAllActions()
			v:setOpacity(255)
		end 
		createNext()
		mIsPlayFont = false
	else
		TextUi.next()
	end 

end

local function CreateStroyLayer()
	local layer = CCLayer:create()

	
	local function onTouch(eventType,x,y)
		if eventType == "began" then 
			return onTouchBegan(x, y)
		elseif eventType == "moved" then
			return onTouchMoved(x, y)
		else
			return onTouchEnded(x, y)	
		end	
	end

	layer:registerScriptTouchHandler(onTouch)
	layer:setTouchEnabled(true)
	
	return layer
end

local function createStroyLine(s_Text)
	local textTTf = CCLabelTTF:create(s_Text, "mnse.ttf", 25)

	local uiPro = CCProgressTimer:create(textTTf)
	uiPro:setType(kCCProgressTimerTypeBar)
    uiPro:setBarChangeRate(ccp(1, 0))
	uiPro:setMidpoint(ccp(0,0))
	--uiPro:setAnchorPoint(ccp(0.5,0.5))
	return uiPro
end



local function CreateStroyBySingleFont(fontSize )
	local col  = 0		--列
	local line = 0		--行
	local delay = 0		--延迟
	local x,y,scale
	local textTB = nil 
	local color = nil


    x = mStartPos.x    --45
	y = mStartPos.y    --270
	scale = 1.2
    textTB = totalFont[mStep]
    color = ccc3(255,255,255)
	
    Log(textTB)
	local function ttfAnction(node,K_delay,isLastFont)
		--local delay = CCDelayTime:create(0.15*K_delay);
		--local fadeIn = CCFadeIn:create(0.75)
		--local action = CCSequence:createWithTwoActions(delay,fadeIn)
		
		local arr2 = CCArray:create()
		arr2:addObject(CCDelayTime:create(0.15*K_delay))
		arr2:addObject(CCFadeIn:create(0.75))
		if isLastFont == true then 
			arr2:addObject(CCCallFuncN:create(function(sender)
				mIsPlayFont = false
				createNext()
			end))
		end
		node:runAction(CCSequence:create(arr2))
	
	end
	
	for key,value in pairs(textTB) do
		local fontTb = CommonFunc_split(value, "|")
		for k,v in pairs(fontTb) do

			local textTTf = CCLabelTTF:create(v, "mnse.ttf", fontSize)
			textTTf:setColor(color)
			textTTf:setScale(scale)
			textTTf:setPosition(ccp(x + col *fontSize*scale,y - line * fontSize*scale))
			textTTf:setOpacity(0);
			if key == #textTB and k == #fontTb then 
				ttfAnction(textTTf,delay,true)
			else
				ttfAnction(textTTf,delay,false)
			end 
			mTTLayer:addChild(textTTf,10086)
			
			table.insert(TextFont,textTTf)
			col = col + 1
			delay = delay + 1
		end
		col = 0
		line = line + 1
	end
end 



local function createSprite(filename, x, y)
	local sprite = CCSprite:create(filename)
	mTTLayer:addChild(sprite)
	sprite:setAnchorPoint(ccp(0.5,0.5))
	sprite:setPosition(ccp(x, y))
	return sprite
end



TextUi = {}

TextUi.next = function()
	mStep = mStep + 1 
	if mStep > #totalFont then
		if mTTLayer ~= nil then
			mTTLayer:removeFromParentAndCleanup(true)
			mTTLayer = nil
		end
        misPlaying = false

        if endEvent ==  "enterMain" then 
            UIManager.push("UI_Main","init")
        elseif endEvent == "enterRoleChioce" then  
            UIManager.push("UI_RollChoice")
        end 
        return
	end 



	for k,v in pairs(TextFont) do
		if v then
			if k == #TextFont then 
				local arr2 = CCArray:create()
				arr2:addObject(CCFadeOut:create(1.0))
				arr2:addObject(CCCallFuncN:create(function(sender)
					mIsFadeOut = false
					TextUi.startStoryByStep()
				end))
				v:runAction(CCSequence:create(arr2))
			else 
				v:runAction(CCFadeOut:create(1.0))
			end 
		end
	end 
	mIsFadeOut = true
end 

TextUi.start = function(fontList,_endEvent,_startPos)
    totalFont = {}
    totalFont = fontList
    endEvent = _endEvent
    mStartPos = _startPos

	mStep = 1
	mIsFadeOut = false
	misPlaying = true
	mTTLayer = CreateStroyLayer()
	g_rootNode:addChild(mTTLayer,10086)
	TextUi.startStoryByStep()
end 

TextUi.startStoryByStep =  function()
	mTTLayer:removeAllChildrenWithCleanup(true)
	TextFont = {}
	createSprite("cartoonup.png",mScreenSize.width/2,600)
	createSprite("cartoondown.png",mScreenSize.width/2,400)
	mIsPlayFont = true
	CreateStroyBySingleFont(23)
end

---------------外部接口
fourFrames = {}

-- 是否正在新手引导
fourFrames.isPlaying = function()
	return misPlaying 
end 

fourFrames.stop =function()
	--FIXME 直接进新手引导关
	mStep = mStep + 1
	TextUi.startStoryByStep()
end

fourFrames.start = function(fontList,_endEvent,startPos)
	TextUi.start(fontList,_endEvent,startPos)
	--Audio.playBgMscByTag(73)
end

fourFrames.release = function()
	TextFont = {}
	if  mTTLayer~= nil then 
		mTTLayer:removeFromParentAndCleanup(true)
		mTTLayer = nil 
	end 
end 







