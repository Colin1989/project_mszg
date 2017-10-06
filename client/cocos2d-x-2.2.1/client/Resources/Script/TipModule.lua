----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-08-28
-- Brief:	提醒模块
----------------------------------------------------------------------
TipModule = {}
----------------------------------------------------------------------
-- 其他消息事件
function TipModule.onMessage(msg, param)
	param = param or ""
	cclog("===== tip module on message, msg: "..msg..", param: "..tostring(param))
	TipFunction.listenClick(msg, param)
	GuideMgr.onMessage(msg, param)
end
----------------------------------------------------------------------
-- 鼠标点击事件
function TipModule.onClick(widget)
	cclog("===== tip module on click, widget name: "..widget:getName())
	TipFunction.listenClick(widget:getName())
	GuideMgr.onMessage("on_click_btn", widget)
end
----------------------------------------------------------------------
-- 界面打开事件
function TipModule.onUI(uiroot, uiname)
	cclog("===== tip module on ui, ui name: "..uiname)
	TipFunction.showTip(uiroot, uiname)
	GuideMgr.onMessage(uiname, uiroot)
	GuideMgr.onUI(uiname)
end
----------------------------------------------------------------------
-- 网络消息事件
function TipModule.onNet(netmsg)
	cclog("===== tip module on net, net msg: "..netmsg)
	GuideMgr.onMessage(netmsg)
end
----------------------------------------------------------------------
-- 显示箭头
function TipModule.showArrow(parent, arrow, direction, pos, isUI)
	local rotation, movePos1, movePos2 = nil, nil, nil
	if "left" == direction then			-- 向左
		rotation, movePos1, movePos2 = 90, ccp(10, 0), ccp(-10, 0)
	elseif "up" == direction then		-- 向上
		rotation, movePos1, movePos2 = 180, ccp(0, -10), ccp(0, 10)
	elseif "right" == direction then	-- 向右
		rotation, movePos1, movePos2 = 270, ccp(-10, 0), ccp(10, 0)
	else								-- 向下(默认),"down" == direction
		rotation, movePos1, movePos2 = 0, ccp(0, 10), ccp(0, -10)
	end
	if nil == arrow then
		if true == isUI then
			arrow= UIImageView:create()
			arrow:loadTexture("guide_finger.png")
		else
			arrow = CCSprite:create("guide_finger.png")
		end
		arrow:setAnchorPoint(ccp(0.5, 0))
		arrow:setZOrder(1000)
		if parent then
			parent:addChild(arrow)
		end
	end
	arrow:stopAllActions()
	arrow:setPosition(pos or ccp(0, 0))
    arrow:setRotation(rotation)
	arrow:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.2, movePos1), CCMoveBy:create(0.2, movePos2))))
	return arrow
end
----------------------------------------------------------------------
-- 显示高亮框
function TipModule.showFrame(parent, frame, size, pos, isUI)
	if nil == frame then
		if true == isUI then
			frame = UIImageView:create()
			frame:loadTexture("guide_clickNode.png")
			frame:setScale9Enabled(true)
			frame:setCapInsets(CCRectMake(62, 62, 1, 1))
		else
			frame = CCScale9Sprite:create("guide_clickNode.png")
		end
		frame:setAnchorPoint(ccp(0.5, 0.5))
		frame:setZOrder(1000)
		if parent then
			parent:addChild(frame)
		end
	end
	if true == isUI then
		local contentSize = frame:getContentSize()
		local currPos = frame:getPosition()
		frame:setPosition(pos or ccp(currPos.x, currPos.y))
		frame:setSize(size or CCSizeMake(contentSize.width, contentSize.height))
	else
		local preferredSize = frame:getPreferredSize()
		local xPos, yPos = frame:getPositionX(), frame:getPositionY()
		frame:setPosition(pos or ccp(xPos, yPos))
		frame:setPreferredSize(size or CCSizeMake(preferredSize.width, preferredSize.height))
	end
	frame:stopAllActions()
	frame:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(0.2, 1), CCScaleTo:create(0.225, 1.05))))
	return frame
end
----------------------------------------------------------------------

