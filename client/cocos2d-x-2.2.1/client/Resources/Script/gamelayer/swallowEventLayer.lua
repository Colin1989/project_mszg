----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-23
-- 描述：游戏事件拦截层 
----------------------------------------------------------------------

local function visibleLayer(layer)		
	g_swallowTouchRoot:setVisible(false)
	layer:unregisterScriptTouchHandler()	
end

local function addMaskLayer(layer,mask_x,mask_y,mask_w,mask_h)
	local s = CCDirector:sharedDirector():getWinSize()


	
	if  s.height - (mask_y+mask_h) > 0 then
		cclog("addMaskLayer_______________________",s.height,mask_y,mask_w)
		local top = CCLayerColor:create(ccc4(0, 255, 0, 128), mask_w, s.height - (mask_y+mask_h))
		top:setAnchorPoint(ccp(0.0,0.0));
		top:setPosition(ccp(mask_x, mask_y+mask_h))  -- FIX
		layer:addChild(top)
	end
	if  mask_y > 0 then
		local bottom = CCLayerColor:create(ccc4(255, 0, 0, 128), mask_w, mask_y)
		bottom:setAnchorPoint(ccp(0.0,0.0));
		bottom:setPosition(ccp(mask_x, 0))
		layer:addChild(bottom)
	end
	
	local left = CCLayerColor:create(ccc4(0, 0, 255, 128), mask_x, s.height)
	left:setAnchorPoint(ccp(0.0,0.0));
	left:setPosition(ccp( 0, 0))
	layer:addChild(left)
	
    local right = CCLayerColor:create(ccc4(0, 0, 0, 128), s.width-(mask_x+mask_w), s.height)
	right:setAnchorPoint(ccp(0.0,0.0));
	right:setPosition(ccp(mask_x+mask_w, 0))
    layer:addChild(right)
end


--设置遮罩 
-- layer 父节点  node 焦点
local function setMaskButCurNode(layer,node,nodeType)
	cclog(type(node),nodeType)
	
	local mask_x,mask_y,mask_w,mask_h
	if nodeType == "CCNode" then 
		 mask_x = node:boundingBox().origin.x
		 mask_y = node:boundingBox().origin.y
		 mask_w = node:boundingBox().size.width
		 mask_h = node:boundingBox().size.height
	elseif nodeType == "UIWidget" then 
		local pos = node:getParent():convertToWorldSpace(node:getPosition())
		--g_swallowTouchRoot
		local size_widget = node:getVirtualRenderer():boundingBox()
		mask_x = size_widget.origin.x + pos.x
		mask_y = size_widget.origin.y + pos.y
		mask_w = size_widget.size.width
		mask_h = size_widget.size.height
	
		cclog("widget--pos-","****",pos.x,pos.y)
		cclog(x,y,"widget--node-.origin-","****",w,h)
	end
	addMaskLayer(layer,mask_x,mask_y,mask_w,mask_h)
end

local function CreateSwallowlayerDetails(focusSprite,nodeType)
	local layer = CCLayer:create()
	--测试精灵
	setMaskButCurNode(layer,focusSprite,nodeType)

	--touch event		
	local function onTouchBegan(x,y)
		cclog(x,"---------------------------touchBegin",y)		
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

	layer:registerScriptTouchHandler(onTouch,false,-2147483647 - 1,false)
	layer:setTouchEnabled(true)
	
	return layer
end
function createMaskLayer(focusSprite,nodeType)
	g_swallowTouchRoot:removeAllChildrenWithCleanup(true)
	g_swallowTouchRoot:addChild(CreateSwallowlayerDetails(focusSprite,nodeType))
end
--createSwallowLayer()  -- text

