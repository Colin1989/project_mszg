----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	战斗中动画管理器
----------------------------------------------------

FightAnimationMgr = {}

local function localPrint(...)
	if true then return end
	lewisPrint("FightAnimationMgr", ...)
end

local mAnimationTB = {}

function FightAnimationMgr.onEnter()
	mAnimationTB = {}
end

function FightAnimationMgr.cleanup()
	local cache = CCAnimationCache:sharedAnimationCache()
	for key, value in pairs(mAnimationTB) do
		--localPrint("----------remove animation by name", key, value)
		cache:removeAnimationByName(key)
	end
	mAnimationTB = {}
end


function FightAnimationMgr.addName(name)
	mAnimationTB[name] = 1
	--localPrint("++++++++++++add animation by name", name)
end

function FightAnimationMgr.getAnimation(stringFormat, totalFrame, interval)
	local cache = CCAnimationCache:sharedAnimationCache()
	local animation = cache:animationByName(stringFormat)
	if animation == nil then
		local animFrames = CCArray:createWithCapacity(totalFrame)
		for i=1, totalFrame do
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format(stringFormat, i))
			if frame ~= nil then
				animFrames:addObject(frame)
			end
		end
		animation = CCAnimation:createWithSpriteFrames(animFrames, interval)
		cache:addAnimation(animation, stringFormat)
		FightAnimationMgr.addName(stringFormat)
		--localPrint("++++++++++++add skill animation in cache", stringFormat)
	else
		--localPrint("------------find skill animation in cache", stringFormat)
	end
	return animation 
end


-- 技能特效
function FightAnimationMgr.skillEffect(stringFormat, totalFrame,interval)
    if interval == nil then 
	    interval = 1.0 / 14.0
    end 
	return FightAnimationMgr.getAnimation(stringFormat, totalFrame, interval)
end

-- 角色动画
function FightAnimationMgr.roleAnimate(stringFormat, totalFrame)
	local interval = 1.0 / 16.0
	return FightAnimationMgr.getAnimation(stringFormat, totalFrame, interval)
end

local function effectOnceCB(sender)
	sender:getParent():removeChild(sender,true)
end

-- 格子动画
function FightAnimationMgr.gridEffectOnce(stringFormat, totalFrame, interval)
	local animation = FightAnimationMgr.getAnimation(stringFormat, totalFrame, interval)
	local effect = CCSprite:create()
	local action = CCSequence:createWithTwoActions(CCAnimate:create(animation), CCCallFuncN:create(effectOnceCB))			
	effect:runAction(action)
	return effect
end






