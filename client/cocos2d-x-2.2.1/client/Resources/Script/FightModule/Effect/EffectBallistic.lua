----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	普通攻击弹道特效,飞行动画-(前景+后景)
----------------------------------------------------

EffectBallistic = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--计算弹道方向
local function calcRotation(sprite, fromPos, toPos)
	local vecX = toPos.x - fromPos.x
	local vecY = toPos.y - fromPos.y
	local angle = math.atan2(vecY, vecX) * (180.0 / 3.14)
	sprite:setRotation(360.0 - angle)
end

--计算飞行动画时间
function EffectBallistic:calcFlyDuration(srcPos, destPos)
	local speed = self.mSpeed
	local distance = math.sqrt((srcPos.x - destPos.x) * (srcPos.x - destPos.x) + (srcPos.y - destPos.y) * (srcPos.y - destPos.y))
	local duration = distance / speed
	return duration
end


--构造
function EffectBallistic:ctor()
	self.mFromPos	= ccp(0, 0)		--飞行起始位置
	self.mDestPos	= ccp(0, 0)		--终点位置
	self.mFlyId		= 0				--飞行动画id
	self.mFrontId 	= 0				--前景动画id
	self.mBackId	= 0				--背景动画id
	self.mSpeed		= EffectMgr.getConfig("emc_ballistic_speed")
end

--初始化
function EffectBallistic:init(fromPos, destPos, flyId, frontId, backId)
	self.mFromPos	= fromPos
	self.mDestPos	= destPos
	self.mFlyId		= flyId
	self.mFrontId	= frontId
	self.mBackId	= backId
	self.mFlyConfig		= SkillConfig.getSkillEffectInfo(flyId)
	self.mFrontConfig	= SkillConfig.getSkillEffectInfo(frontId)
	self.mBackConfig	= SkillConfig.getSkillEffectInfo(backId)
end

--设置速度
function EffectBallistic:setSpeed(speed)
	self.mSpeed = speed
end

--特效持续时间
function EffectBallistic:duration()
	local time1 = 0
	if self.mFlyConfig ~= nil then
		time1 = self:calcFlyDuration(self.mFromPos, self.mDestPos)
	end
	
	local time2 = 0
	if self.mBackConfig ~= nil then
		local interval = EffectMgr.getConfig("emc_frame_interval")
		time2 = self.mFrontConfig.image_count / 2 * interval
	end
	return time1 + time2
end

--开始播放
function EffectBallistic:play()
	self:flyEffect()
end

--飞行动画
function EffectBallistic:flyEffect()
	if self.mFlyConfig == nil then
		self:frontEffect()
		return
	end
	
	--飞行结束回调
	local function flyDone(sender)
		removeSelf(sender)
		self:frontEffect()
	end
	
	--创建精灵
	local config = self.mFlyConfig
	SoundDispath.skillEffect(config.sound_effect)
	local sprite = EffectMgr.createSprite(1, config, self.mFromPos)
	--sprite:setScale(0.75)
	
	--播放动画
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	--更新飞行弹道的方向
	local x, y = sprite:getPosition()
	local srcPos 	= self.mFromPos
	local destPos 	= self.mDestPos
	calcRotation(sprite, srcPos, destPos)
	
	--飞行动作
	local duration = self:calcFlyDuration(srcPos, destPos)
	sprite:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(flyDone)))
end

--前景动画
function EffectBallistic:frontEffect()
	self:backEffect()
	if self.mFrontConfig == nil then
		self:over()
		return
	end
	
	local config = self.mFrontConfig
	SoundDispath.skillEffect(config.sound_effect)
	local sprite = EffectMgr.createSprite(1, config, self.mDestPos)
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	sprite:runAction(CCSequence:create(arr))
	
    sprite:setScale(2.0)

	local function effectDone()
		self:over()
	end
	
	local interval = EffectMgr.getConfig("emc_frame_interval")
	local arr1 = CCArray:create()
	arr1:addObject(CCDelayTime:create(config.image_count / 2 * interval))
	arr1:addObject(CCCallFuncN:create(effectDone))
	sprite:runAction(CCSequence:create(arr1))
end

--背景动画
function EffectBallistic:backEffect()
	if self.mBackConfig == nil then
		return
	end
	local config = self.mBackConfig
	SoundDispath.skillEffect(config.sound_effect)
	local sprite = EffectMgr.createSprite(1, config, self.mDestPos)
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	sprite:runAction(CCSequence:create(arr))

end
