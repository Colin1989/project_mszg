----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-23
-- 描述：游戏事件拦截层 这一层事件 不做穿透  一般用于新手指引
----------------------------------------------------------------------

local function visibleLayer(layer)		
	g_swallowTouchRoot:setVisible(false)
	layer:unregisterScriptTouchHandler()	
end

--设置遮罩 
-- layer 父节点  node 焦点
local function setMaskButCurNode(layer,node)
	print(type(node))	
	local s = CCDirector:sharedDirector():getWinSize()
	
	
	local x = node:boundingBox().origin.x
	local y = node:boundingBox().origin.y
	local w = node:boundingBox().size.width
	local h = node:boundingBox().size.height
	
	print(height,"--node-.origin-",y,"****",w)
	print(s.height)
	
	local left = CCLayerColor:create(ccc4(0, 0, 255, 128), x, s.height)
	left:setAnchorPoint(ccp(0.0,0.0));
	left:setPosition(ccp( 0, 0))
	layer:addChild(left)
	
	if  s.height - (y+w) > 0 then
		local top = CCLayerColor:create(ccc4(0, 255, 0, 128), w, s.height - (y+w))
		top:setAnchorPoint(ccp(0.0,0.0));
		top:setPosition(ccp(x, y+h))  -- FIX
		layer:addChild(top)
	end
	if  y > 0 then
		local bottom = CCLayerColor:create(ccc4(255, 0, 255, 128), w, y)
		bottom:setAnchorPoint(ccp(0.0,0.0));
		bottom:setPosition(ccp(x, 0))
		layer:addChild(bottom)
	end
	
    local right = CCLayerColor:create(ccc4(255, 0, 0, 128), s.width-(x+w), s.height)
	right:setAnchorPoint(ccp(0.0,0.0));
	right:setPosition(ccp(x+w, 0))
    layer:addChild(right)
end

local function CreateSwallowlayerDetails()
	local layer = CCLayer:create()
	
	
	--测试精灵
	local testSprite = CCSprite:create("item3.png")
	testSprite:setPosition(ccp(200,500))
	testSprite:setAnchorPoint(ccp(1.5,-0.5));
	layer:addChild(testSprite)
	
	setMaskButCurNode(layer,testSprite)


	--touch event		
	local function onTouchBegan(x,y)
		print(x,"touchBegin",y)
		--print("CreateSwallowlayerDetails")
		--visibleLayer(layer)
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

	
	layer:registerScriptTouchHandler(onTouch,false,10,true)
	layer:setTouchEnabled(true)
	
	return layer
end
function createSwallowLayer()
	g_swallowTouchRoot:removeAllChildrenWithCleanup(true)
	g_swallowTouchRoot:addChild(CreateSwallowlayerDetails())
end
--createSwallowLayer()  -- text

