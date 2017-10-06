----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-2
-- 描述：创建动画
----------------------------------------------------------------------
-- framefile  文件名 totalFrame 总帧数 	Interval 每帧数间隔
----------------------------------------------------------------------


--distance 掉下的距离 （会有回啦效果）
FightAnimation_drop = function(node,distance)
	local downIng = CCEaseBackInOut:create(CCMoveBy:create(0.3,CCPointMake(0,(-1)*distance)))
	local fadeIn = CCFadeIn:create(0.3);
	
	local action = CCSpawn:createWithTwoActions(fadeIn,downIng)
	node:runAction(action)
end


-- 道具移动
FightAnimation_moveItem = function(node)
	local action = CCSpawn:createWithTwoActions(
	CCMoveTo:create(0.5, ccp(ModelPlayer:getPlayerNode():getPosition())),
	CCScaleTo:create(0.5,0))

	
	function FucnC_DeleteThis(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	local action2 = CCSequence:createWithTwoActions(action,CCCallFuncN:create(FucnC_DeleteThis))	
	node:runAction(action2)
end

-- 全屏震动
FightAnimation_Crit = function(node)
	local moveUp  =  CCMoveBy:create(0.05, ccp(0,15))
	local moveDown = CCMoveBy:create(0.05, ccp(0,-15))
	
	local action = CCRepeat:create(CCSequence:createWithTwoActions(moveUp, moveDown), 2)
	node:runAction(action)
end

FightAnimation_openX = function(node)
	node:setScale(0.0)
	local scaleTo = CCScaleTo:create(0.1, 1.0);
	node:runAction(scaleTo)
end

FightAnimation_closeX = function(node)
	local function FucnC_return(sender)
		--变回原来样子 以便其他修饰
		sender:setVisible(false)
		sender:setScale(1.0)
	end

	local scaleTo = CCScaleTo:create(0.2, 0.0);
	local action = CCSequence:createWithTwoActions(scaleTo,CCCallFuncN:create(FucnC_return))
	node:runAction(action)
end

--解开迷雾
FightAnimation_fadeOut = function(node)
	local function FucnC_return(sender)
		--变回原来样子 以便其他修饰
		sender:setVisible(false)
		sender:setScale(1.0)
	end

	local fadeOut = CCFadeOut:create(0.2);
	--local action = CCSequence:createWithTwoActions(scaleTo,CCCallFuncN:create(FucnC_return))
	node:runAction(fadeOut)
end


function createAnimation(framefile,totalFrame,Interval)
	local animFrames = CCArray:createWithCapacity(totalFrame);
	for i = 1, totalFrame do
		-- 逐张加载	
		--texture = CCTextureCache::sharedTextureCache()->addImage(str);
		--int w =texture:getContentSize().width;
		--int h =texture:getContentSize().height;
		--frame = CCSpriteFrame:createWithTexture(texture, CCRectMake(0*0, 0*0, w, h));
		--  plist加载
		
		local str = string.format(framefile,i)
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str);
		if frame then 
			animFrames:addObject(frame);
		else
			cclog("error!!!!!_picture_Fail_!!!!!!!!",str)
		end
		
	end

	--effect = CCSprite:create();
	local animation = CCAnimation:createWithSpriteFrames(animFrames,Interval);
	return animation 
end

-- 功  能：创建帧动画 （只播放一次） 
-- 参  数：framefile 文件名(string)  totalFrame总帧数 
-- 返回值：动画精灵
function createAnimation_signal(framefile,totalFrame,Interval, callback)--,CCObject* obj,SEL_CallFuncN callback)

	local effect = CCSprite:create();
	animation = createAnimation(framefile,totalFrame,Interval)
	
	function FucnC_DeleteAnimain(sender)
		if callback ~= nil then
			callback()
		end
		sender:getParent():removeChild(sender,true)
	end
	
	local action = CCSequence:createWithTwoActions(CCAnimate:create(animation),CCCallFuncN:create(FucnC_DeleteAnimain))			
	effect:runAction(action)	
	return effect;
end

----------------------------------------------------------------------
-- 功  能：创建帧动画 (永久) 
-- 参  数：framefile 文件名(string)  totalFrame总帧数 
-- 返回值：动画精灵
----------------------------------------------------------------------
function createAnimation_forever(framefile,totalFrame,Interval)
	local effect = CCSprite:create();		
	local animation = createAnimation(framefile,totalFrame,Interval)
	effect:runAction(CCRepeatForever:create(CCAnimate:create(animation))) 
	return effect;
end

function createAnimation_forever_returnAction(framefile,totalFrame,Interval)
	local animation = createAnimation(framefile,totalFrame,Interval)
	return (CCRepeatForever:create(CCAnimate:create(animation)))
end

--数字暴击  放大 然后缩小
function Anction_Crit(node)
	local scaleby = CCScaleBy:create(0.2, 3.0);
    local actionbyback = scaleby:reverse()
	
	local action = CCSequence:createWithTwoActions(scaleby,actionbyback)
    node:runAction(action)
end

--闪避 后退一步 然后还原
function Anction_Miss(node, callback_func)
	local moveby = CCMoveBy:create(0.3, CCPointMake(30,0));
    --local movebyback = moveby:reverse()	
	--local action = CCSequence:createWithTwoActions(moveby,movebyback, CCCallFuncN:create(callback_func))	
	local arr = CCArray:create()
	arr:addObject(moveby)
	arr:addObject(moveby:reverse())
	arr:addObject(CCCallFuncN:create(callback_func))
	node:runAction( CCSequence:create(arr))
end

--要是飞行动画 node 钥匙节点 最终坐标 到位置后的回调函数
function Anction_KeyFlay(node,finalPos,callback)
	local flyTime = 0.5
	assert(node ~= nil,"Door Node is no exsit??")
	
	local action = CCSpawn:createWithTwoActions(
	CCMoveTo:create(flyTime, ccp(finalPos.x+CELLSIZE_WIDTH,finalPos.y+CELLSIZE_HEIGHT*2)),
	CCRotateBy:create(flyTime, 180))

	function FucnC_DeleteThis(sender)
		sender:getParent():removeChild(sender,true)
		FactoryGameSprite.openDoor()
	end
	
	--local action2 = CCSequence:createWithTwoActions(action,CCCallFuncN:create(FucnC_DeleteThis))
	local arr = CCArray:create()
	arr:addObject(action)
	arr:addObject(CCCallFuncN:create(FucnC_DeleteThis))
	arr:addObject(CCCallFunc:create(callback))
	node:runAction(CCSequence:create(arr))
	
end

----------------------------------------------------------------------
-- 功  能：怪物扣血
-- 参  数：dp 文件名(伤害值) x 坐标 y坐标 
-- dpTpye:伤害类型 add:加血,reduce:扣血
-- DamageType:伤害类型 "miss" 闪避  "crit"暴击  "hit" 普通攻击
-- 返回值：nil
----------------------------------------------------------------------
function monsterDotShow(dp,pos,dpTpye,DamageType)
	local delay = 0.65
	local action = CCSpawn:createWithTwoActions(
	CCMoveBy:create(delay,CCPointMake(0,20)),
	CCFadeTo:create(delay, 64))
	
	function FucnC_DeleteThis(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	local action2 = CCSequence:createWithTwoActions(action,CCCallFuncN:create(FucnC_DeleteThis))

	if DamageType == "miss" then
		local missSptite = CCSprite:create("miss.png")
		missSptite:setPosition(pos)
		missSptite:runAction(action2);
		return missSptite
	end
	local font = CCLabelTTF:new()
		 font:init()
		font:autorelease()
		font:setFontName("Marker Felt")
		font:setFontSize(96)
		font:setPosition(pos);
		font:setAnchorPoint(ccp(0.5,0.5))
	if dpTpye == "add" then
		font:setString(string.format("+%d",dp))
		font:setColor(ccc3(0,240,6))
	else 
		font:setString(string.format("-%d",dp))
		font:setColor(ccc3(227,0,0))
	end
	
	--font:setScale(1.5)
	font:runAction(action2);
	--font:runAction(CCSequence:createWithTwoActions(CCScaleBy:create(delay / 3, 1.5), CCScaleBy:create(delay / 2, 1 / 1.5)))
	
	if DamageType == "crit" then
		Anction_Crit(font)
	end
	return font
end

-- 创建粒子系统
function createParticle(plistfile)
	local particle = CCParticleSystemQuad:create(plistfile)
	return particle
end

--UI界面从上面加速掉下来
function FightAnimation_UILayerdrop(node)
	if nil == node then
		return
	end
	local m_visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local distance = m_visibleSize.height/2
	local pos = node:getPosition()
	local newPos = ccp(pos.x,pos.y + distance)	
	node:setPosition(newPos)
	
	local downIng = CCEaseBackInOut:create(CCMoveBy:create(0.8,CCPointMake(0,(-1)*distance)))
	node:runAction(downIng)
end
----------------------------------------------	ui Animation
--强设上去掉下来
function Animation_setUIUpFallDown(widget,delayTime,flyTime)
	if nil == widget then
		return
	end
	local FallDownDis = widget:getContentSize().height
	local pos = widget:getPosition()
	local newPos = ccp(pos.x,pos.y + FallDownDis)	
	widget:setPosition(newPos)
	
	local action1 = CCDelayTime:create(delayTime);	
	local action2 = CCEaseSineOut:create(CCMoveBy:create(flyTime,CCPointMake(0,(-1)*FallDownDis)))
	
	local arr = CCArray:create()
	arr:addObject(action1)
	arr:addObject(action2)
	widget:runAction(CCSequence:create(arr))
end

--强设下去滑上来
function Animation_setUIDonwFlyOut(widget,delayTime,flyTime)
	if nil == widget then
		return
	end
	local flyOutDis = widget:getContentSize().height
	local pos = widget:getPosition()
	local newPos = ccp(pos.x,pos.y - flyOutDis)	
	widget:setPosition(newPos)
	
	local action1 = CCDelayTime:create(delayTime);	
	local action2 = CCEaseSineOut:create(CCMoveBy:create(flyTime,CCPointMake(0,(1)*flyOutDis)))
	
	local arr = CCArray:create()
	arr:addObject(action1)
	arr:addObject(action2)
	widget:runAction(CCSequence:create(arr))
end

--缩小 并且淡出
function Animation_ScaleTo_FadeOut(widget,dTime)
	if nil == widget then
		return
	end
	local action_callback = CCCallFunc:create(function()
		CommonFunc_SetWidgetTouch(widget,true)
		end)
	widget:setScale(1.0)
	local node = widget:getRenderer()
	local action_scale = CCScaleTo:create(dTime,0.0)
	action_scale = CCEaseBackIn:create(action_scale)
	local action_fadeOut = CCFadeOut:create(dTime)
	local action = CCSpawn:createWithTwoActions(action_scale,action_fadeOut)
	action = CCSequence:createWithTwoActions(action,action_callback)
	node:runAction(action)
end

--放大 并且淡入
function Animation_ScaleTo_FadeIn(widget,dTime)
	if nil == widget then
		return
	end
	local action_callback = CCCallFunc:create(function()
		CommonFunc_SetWidgetTouch(widget,true)
		end)
	widget:setScale(0.0)
	local action_scale = CCScaleTo:create(dTime,1.0)
	action_scale = CCEaseBackOut:create(action_scale)
	local action_fadeIn = CCFadeIn:create(dTime)
	local action = CCSpawn:createWithTwoActions(action_scale,action_fadeIn)
	action = CCSequence:createWithTwoActions(action,action_callback)
	widget:runAction(action)
end

--移动到指定坐标 有回弹效果 desPos目标坐标 
function Animation_MoveTo_Rebound(widget,dTime,desPos)
	if nil == widget then
		return
	end
	local node = widget:getRenderer()
	--移动
	local action = CCMoveTo:create(dTime,desPos)
	--回弹
	local action_bound = CCEaseBackOut:create(action)
	node:runAction(action_bound)
end

--背包界面退出时候的动画
function Animation_UIBag_Exit(widget,dTime,callFunc)
	if nil == widget then
		if "function" == type(callFunc) then
			callFunc()
		end
		return
	end
	local array = CCArray:create()
	local flyOutDis = widget:getContentSize().height
	
	local action_move = CCMoveBy:create(dTime,CCPointMake(0,flyOutDis))
	action_move = CCEaseBackIn:create(action_move)
	array:addObject(action_move)
	
	if "function" == type(callFunc) then
		array:addObject(CCCallFuncN:create(callFunc))
	end
	widget:runAction(CCSequence:create(array))
end

--[[
--物品信息 宝石信息 符文信息界面进入动作
function Animation_UIItem_Enter(uiLayer)
	local widget = uiLayer:getRootWidget()
	local node = widget:getRenderer()
	local posBack = CommonFunc_GetPos(widget)
	widget:setPosition(ccp(posBack.x,posBack.y+800))
	
	--移动
	local action = CCMoveTo:create(0.5,posBack)
	--回弹
	local action_bound = CCEaseBackOut:create(action)
	
	node:runAction(action_bound)
end

--物品信息 宝石信息 符文信息界面退出动作
--tag = "UI_runeInfo" "UI_itemInfo" "UI_gemInfo"
function Animation_UIItem_Exit(uiLayer,tag)
	cclog("Animation_UIItem_Exit()",tag)
	function callbackFunc()
		--UIManager.pop(tag)
		uiLayer:removeFromParent()
	end
	
	local widget = uiLayer:getRootWidget()
	local node = widget:getRenderer()
	local posBack = CommonFunc_GetPos(widget)
	local desPos = ccp(posBack.x,-500)
	
	--移动
	local action = CCMoveTo:create(0.5,desPos)
	action = CCEaseBackIn:create(action)
	action = CCSequence:createWithTwoActions(
		action,
		CCCallFunc:create(callbackFunc)
		)
	
	node:runAction(action)
end
]]
function Animation_UISell_Enter(uiLayer)
	local widget = uiLayer:getRootWidget()
	widget:setScale(0.1)
	local dTime = 0.3
	local action_move = CCMoveBy:create(dTime,ccp(0,100))
	local action_scale = CCScaleTo:create(dTime,1.0)
	local action_show = CCFadeIn:create(dTime)
	
	local array = CCArray:create()
	array:addObject(action_move)
	array:addObject(action_scale)
	array:addObject(action_show)
	local action = CCSpawn:create(array)
	action = CCEaseBackOut:create(action)
	widget:getRenderer():runAction(action)
end


function Animation_UISell_Exit(uiLayer,callbackFunc)
	local widget = uiLayer:getRootWidget()
	widget:setScale(1.0)
	local dTime = 0.3
	local action_move = CCMoveBy:create(dTime,ccp(0,-100))
	local action_scale = CCScaleTo:create(dTime,0.1)
	local action_show = CCFadeOut:create(dTime)
	
	local array = CCArray:create()
	array:addObject(action_move)
	array:addObject(action_scale)
	array:addObject(action_show)
	local action = CCSpawn:create(array)
	action = CCEaseBackIn:create(action)
	
	if callbackFunc ~= nil then
		local callback_action = CCCallFunc:create(callbackFunc)
		action = CCSequence:createWithTwoActions(action,callback_action)
	end
	widget:getRenderer():runAction(action)
end

function Animation_Loading(widget,num)
end

----------------------------------------------------------------------
-- 显示正方形粒子效果
function FactoryAnimation_showSquareParticle(particle, size, parent, show)
	if false == show then
		parent:getRenderer():removeChildByTag(1000, true)
		return
	end
	local node = CCNode:create()
	node:setTag(1000)
	parent:getRenderer():addChild(node)
	-- 第一个粒子
	local particle1 = CCParticleSystemQuad:create(particle)
	particle1:setPosition(ccp(-size.width/2, size.height/2))
	node:addChild(particle1, 100)
	local arr1 = CCArray:create()
	arr1:addObject(CCMoveBy:create(0.5, ccp(size.width, 0)))
	arr1:addObject(CCMoveBy:create(0.5, ccp(0, -size.height)))
	arr1:addObject(CCMoveBy:create(0.5, ccp(-size.width, 0)))
	arr1:addObject(CCMoveBy:create(0.5, ccp(0, size.height)))
	particle1:runAction(CCRepeatForever:create(CCSequence:create(arr1)))
	-- 第二个粒子
	local particle2 = CCParticleSystemQuad:create(particle)
	node:addChild(particle2, 100)
	particle2:setPosition(ccp(size.width/2, -size.height/2))
	local arr2 = CCArray:create()
	arr2:addObject(CCMoveBy:create(0.5, ccp(-size.width, 0)))
	arr2:addObject(CCMoveBy:create(0.5, ccp(0, size.height)))
	arr2:addObject(CCMoveBy:create(0.5, ccp(size.width, 0)))
	arr2:addObject(CCMoveBy:create(0.5, ccp(0, -size.height)))
	particle2:runAction(CCRepeatForever:create(CCSequence:create(arr2)))
end
----------------------------------------------------------------------
-- 创建加锁:94x94
function Action_createLock94x94(parent, isParentWidget, pos)
	local lockPanel = nil
	if nil == parent then
		return lockPanel
	end
	if true == isParentWidget then
		lockPanel = parent:getChildByName("lock_panel")
	else
		lockPanel = parent:getWidgetByName("lock_panel")
	end
	if nil == lockPanel then
		lockPanel = CommonFunc_createUILayout(ccp(0.5, 0.5), ccp(0, 0), CCSizeMake(94, 94), "touming.png", 0)
		lockPanel:setName("lock_panel")
		lockPanel:setClippingEnabled(true)
		if true == isParentWidget then
			parent:addChild(lockPanel)
		else
			parent:addWidget(lockPanel)
		end
	end
	lockPanel:setPosition(pos or ccp(0,0))
	local upDoor = lockPanel:getChildByName("up_door")
	if nil == upDoor then
		upDoor = CommonFunc_createUIImageView(ccp(0.5, 0.5), ccp(47, 47), CCSizeMake(94, 94), "fight_lock_up.png", "up_door", 0)
		lockPanel:addChild(upDoor)
	end
	upDoor:setPosition(ccp(47, 47))
	local downDoor = lockPanel:getChildByName("down_door")
	if nil == downDoor then
		downDoor = CommonFunc_createUIImageView(ccp(0.5, 0.5), ccp(47, 47), CCSizeMake(94, 94), "fight_lock_down.png", "down_door", 0)
		lockPanel:addChild(downDoor)
	end
	downDoor:setPosition(ccp(47, 47))
	return lockPanel
end
-- 解锁动画:106x106
function Action_unlock106x106(parent, isParentWidget, callback)
	local lockPanel = nil
	if nil == parent then
		return
	end
	if true == isParentWidget then
		lockPanel = parent:getChildByName("lock_panel")
	else
		lockPanel = parent:getWidgetByName("lock_panel")
	end
	local upDoor = lockPanel:getChildByName("up_door")
	local downDoor = lockPanel:getChildByName("down_door")
	if nil == upDoor or nil == downDoor then
		return
	end
	local function unlockActionDone()
		if nil == lockPanel then
			return
		end
		lockPanel:removeFromParent()
		lockPanel = nil
		if "function" == type(callback) then
			callback()
		end
	end
	local upMove = CCEaseBackOut:create(CCMoveBy:create(1, CCPointMake(0, 76)))
	local downMove = CCEaseBackOut:create(CCMoveBy:create(1, CCPointMake(0, -46)))
	upDoor:runAction(CCSequence:createWithTwoActions(upMove, CCCallFunc:create(unlockActionDone)))
	downDoor:runAction(CCSequence:createWithTwoActions(downMove, CCCallFunc:create(unlockActionDone)))
end
----------------------------------------------------------------------

