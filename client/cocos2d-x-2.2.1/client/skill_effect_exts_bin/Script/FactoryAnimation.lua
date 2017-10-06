----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-2
-- 描述：创建动画
----------------------------------------------------------------------
-- framefile  文件名 totalFrame 总帧数 	Interval 每帧数间隔
----------------------------------------------------------------------


--distance 掉下的距离
FightAnimation_drop = function(node,distance)
	--CCEaseBackInOut
	local downIng = CCEaseBackInOut:create(CCMoveBy:create(0.3,CCPointMake(0,(-1)*distance)))
	local fadeIn = CCFadeIn:create(0.3);
	
	local action = CCSpawn:createWithTwoActions(fadeIn,downIng)
	node:runAction(action)
end
-- 道具移动
FightAnimation_moveItem = function (node)
	local action = CCSpawn:createWithTwoActions(
	CCMoveTo:create(0.5,CCPointMake(100,1000)),
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
	local scaleTo = CCScaleTo:create(0.2, 1.0);
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
function createAnimation_signal(framefile,totalFrame,Interval)--,CCObject* obj,SEL_CallFuncN callback)

	local effect = CCSprite:create();
	animation = createAnimation(framefile,totalFrame,Interval)
	
	function FucnC_DeleteAnimain(sender)
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
	node:runAction( CCSequence:create(arr));
 
end



----------------------------------------------------------------------
-- 功  能：怪物扣血
-- 参  数：dp 文件名(伤害值) x 坐标 y坐标 
-- dpTpye:伤害类型 add:加血,reduce:扣血
-- DamageType:伤害类型 "miss" 闪避  "crit"暴击  "hit" 普通攻击
-- 返回值：nil
----------------------------------------------------------------------
function monsterDotShow(dp,pos,dpTpye,DamageType)

	local action = CCSpawn:createWithTwoActions(
	CCMoveBy:create(1.5,CCPointMake(0,100)),
	CCFadeOut:create(1.5))


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
    font:setFontSize(36)
	font:setPosition(pos);
	font:setAnchorPoint(ccp(0.5,0.5))
	if dpTpye == "add" then
		font:setString(string.format("+%d",dp))
		font:setColor(ccc3(0,240,6))
	else 
		font:setString(string.format("-%d",dp))
		font:setColor(ccc3(227,0,0))
	end
	
	
	font:runAction(action2);
	
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














