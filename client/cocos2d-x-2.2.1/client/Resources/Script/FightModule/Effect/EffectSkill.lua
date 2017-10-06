----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	技能特效,飞行动画-(前景+后景)
----------------------------------------------------

EffectSkill = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--播放音效
local function playSoundEffect(sender)
	sender:setVisible(true)
	SoundDispath.skillEffect(sender:getTag())
end

--构造
function EffectSkill:ctor()
	self.mCasterPos		= ccp(0, 0)		--飞行起始位置
	self.mTargetVec		= {}				--目标集合
	self.mSkillId		= 0				--技能id
	
	self.mFlyConfig		= nil
	self.mFrontConfig	= nil
	self.mBackConfig	= nil
	self.mMode			= "default"		--特效模式,default默认,aoe区域,chain链式,rain落雨
end

--初始化
function EffectSkill:init(casterPos, targetPosVec, id)--施法者位置, 目标位置集合,技能id
	for key, value in pairs(targetPosVec) do
		local unit = {}
		unit.pos 		= ccp(value.x, value.y)
		unit.idx 		= key
		unit.duration 	= 0		--前景动画延时时间
		unit.timer		= 0		--特效结算时间
		table.insert(self.mTargetVec, unit)
	end
	
	self.mCasterPos 	= casterPos
	self.mSkillId		= id
	
	
	
	local config = SkillConfig.getSkillBaseInfo(id)
	if config == nil then
		return
	end
	
	self.mFlyConfig		= SkillConfig.getSkillEffectInfo(config.fly_effect_id)
	self.mFrontConfig	= SkillConfig.getSkillEffectInfo(config.front_effect_id)
	self.mBackConfig	= SkillConfig.getSkillEffectInfo(config.back_effect_id)
	
	self.mMode	= config.effect_mode
end

--特效持续时间
function EffectSkill:duration()
	local tb = nil
	if self.mMode == "aoe" then
		tb = self:AOEDuration()
	else
		tb = self:defaultDuration()
	end
	return tb
end

--开始播放
function EffectSkill:play()
	if self.mMode == "aoe" then
		self:playAOE()
	else
		self:playDefault()
	end
end

---------------------------------------------------------------------------------
------------------默认特效,弹道飞行+前景动画+背景动画----------------------------
---------------------------------------------------------------------------------
function EffectSkill:playDefault()
	--开启弹道飞行
	local config = self.mFlyConfig
	if config ~= nil then
		for key, value in pairs(self.mTargetVec) do
			local sprite = EffectMgr.createSprite(1, config, self.mCasterPos)
			sprite:setScale(0.75)
			
			--播放动画
			local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
			sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
			
			--更新飞行弹道的方向
			local x, y = sprite:getPosition()
			local srcPos 	= ccp(x, y)
			local destPos 	= ccp(value.pos.x, value.pos.y)
			EffectMgr.calcRotation(sprite, srcPos, destPos)
			
			local duration = EffectMgr.calcFlyDuration(srcPos, destPos)
			sprite:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(removeSelf)))
			--飞行
			value.duration = duration
		end
		
		--播放音效
		SoundDispath.skillEffect(config.sound_effect)
	end
	
	--前景动画
	config = self.mFrontConfig
	if config ~= nil then
		for key, value in pairs(self.mTargetVec) do
			local sprite = EffectMgr.createSprite(1, config, value.pos)
			sprite:setTag(config.sound_effect)
			local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(value.duration))
			arr:addObject(CCCallFuncN:create(playSoundEffect))
			arr:addObject(CCAnimate:create(animation))
			arr:addObject(CCCallFuncN:create(removeSelf))
			sprite:runAction(CCSequence:create(arr))
			sprite:setVisible(false)
		end
	end
	
	--背景动画
	config = self.mBackConfig
	if config ~= nil then
		for key, value in pairs(self.mTargetVec) do
			local sprite = EffectMgr.createSprite(0, config, value.pos)
			sprite:setTag(config.sound_effect)
			local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(value.duration))
			arr:addObject(CCCallFuncN:create(playSoundEffect))
			arr:addObject(CCAnimate:create(animation))
			arr:addObject(CCCallFuncN:create(removeSelf))
			sprite:runAction(CCSequence:create(arr))
			sprite:setVisible(false)
		end
	end
end

function EffectSkill:defaultDuration()
	--计算弹道飞行时间
	local config = self.mFlyConfig
	if config ~= nil then
		for key, value in pairs(self.mTargetVec) do
			local srcPos 	= ccp(self.mCasterPos.x, self.mCasterPos.y)
			local destPos 	= ccp(value.pos.x, value.pos.y)
			value.timer = EffectMgr.calcFlyDuration(srcPos, destPos)
		end
	end
	
	--计算前景动画作用时间
	local interval = EffectMgr.getConfig("emc_frame_interval")
	config = self.mFrontConfig
	if config ~= nil then
		for key, value in pairs(self.mTargetVec) do	
			value.timer = value.timer + config.image_count * interval * 0.25
		end
	end
	
	local tb = {}
	for key, value in pairs(self.mTargetVec) do
		table.insert(tb, value.timer)
	end
	return tb
end

---------------------------------------------------------------------------------
---------------------------aoe特效,前景动画*背景动画-----------------------------
---------------------------------------------------------------------------------
--群体动画,作用全体目标
local function calRandomPos(scrPos)
	local x = math.random(50, 720)
	local y = math.random(180, 900)
	return ccp(x, y)
end

function EffectSkill:playAOE()
	--开启弹道飞行
	local config = self.mFlyConfig
	if config ~= nil then
		self:playDefault()
		return
	end
	
	--前景动画
	config = self.mFrontConfig
	local count = math.random(15, 29)
	local duration = 0.01
	for i = 1, count do
		local sprite = EffectMgr.createSprite(1, config, calRandomPos())
		sprite:setTag(config.sound_effect)
		local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(duration))
		arr:addObject(CCCallFuncN:create(playSoundEffect))
		arr:addObject(CCAnimate:create(animation))
		arr:addObject(CCCallFuncN:create(removeSelf))
		sprite:runAction(CCSequence:create(arr))
		sprite:setVisible(false)
		sprite:setScale(math.random(85, 100) / 100)
		duration = duration + math.random(3, 8) / 100
	end
end

function EffectSkill:AOEDuration()
	local tb = {}
	local config = self.mFrontConfig
	local interval = EffectMgr.getConfig("emc_frame_interval")
	for key, value in pairs(self.mTargetVec) do
		local timer = config.image_count * interval * 0.25
		timer = timer + math.random(15, 35) / 100
		table.insert(tb, timer)
	end
	return tb
end

--[[
---------------------------------------------------------------------------------
------------------链式特效,弹道飞行*前景动画*背景动画----------------------------
---------------------------------------------------------------------------------
--计算弹跳顺序
local function calcChainOrder(srcPos, data)
	--获得离当前结点最近的目标
	local function getNextTarget(curPos)
		local minDistance = 99999999
		local ret = nil
		for key, value in pairs(data.targetVec) do
			if value.isSearch == false then
				local distance = ccpDistanceSQ(curPos, value.pos)
				if distance < minDistance then
					minDistance = distance
					ret = value
				end
			end
		end
		return ret
	end
	
	for key, value in pairs(data.targetVec) do
		value.isSearch = false
		value.id = 0
	end
		
	local startPos = srcPos
	local target = nil
	local idx = 1
	while true do
		target = getNextTarget(startPos)
		if target == nil then
			break
		end
		target.isSearch = true
		startPos = target.pos
		target.id = idx
		idx = idx + 1
	end
	
	--重新排序
	table.sort(data.targetVec, function(a, b) return a.id < b.id end)
end

function SpecialEffect.playChain(data)
	--无弹道
	local config = data.flyConfig
	if config == nil then
		SpecialEffect.playDefault(data)
		return
	end
	
	--重新排序
	calcChainOrder(data.casterPos, data)
	local sprite = createSprite(1, config, data.casterPos)
	sprite:setScale(0.5)
	--播放动画
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	local idx = 1
	
	local function startMove(sender)
		
		local target = data.targetVec[idx]
		
		--播放前景与后景动画
		local preTarget = data.targetVec[idx - 1]
		if preTarget ~= nil then
			local config = data.frontConfig
			local sprite = createSprite(1, config, preTarget.pos)
			sprite:setTag(config.sound_effect)
			local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
			local arr = CCArray:create()
			arr:addObject(CCAnimate:create(animation))
			arr:addObject(CCCallFuncN:create(removeSelf))
			sprite:runAction(CCSequence:create(arr))
		end
		
		if target == nil then
			removeSelf(sender)
			return
		end
		
		idx = idx + 1
		
		--更新飞行弹道的方向
		local x, y = sender:getPosition()
		local srcPos = ccp(x, y)
		local destPos = target.pos
		calcRotation(sender, srcPos, destPos)
		
		local duration = calcFlyDuration(srcPos, destPos)
		sender:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(startMove)))
	end
	
	startMove(sprite)
	
end

function SpecialEffect.chainDuration(data)
	
end


---------------------------------------------------------------------------------
-------------------爆炸溅射特效,单一弹道前景动画*背景动画------------------------
---------------------------------------------------------------------------------
function SpecialEffect.playExplode(data)
	if data.flyConfig == nil or data.frontConfig == nil then
		SpecialEffect.playDefault(data)
		return
	end
	
	local config = data.flyConfig
	local sprite = createSprite(1, config, data.casterPos)
	
	--播放动画
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	--更新飞行弹道的方向
	local x, y = sprite:getPosition()
	local srcPos = ccp(x, y)
	local destPos = ccp(360, 540)
	calcRotation(sprite, srcPos, destPos)
	
	local duration = calcFlyDuration(srcPos, destPos, 800)
	sprite:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(removeSelf)))
	
	
	--开始溅射
	local function spurting(sender)
		data.casterPos = ccp(360, 540)
		mFlySpeed = mFlySpeed * 1.5
		SpecialEffect.playDefault(data)
		mFlySpeed = mConstFlySpeed
	end
	
	config = data.flyConfig
	config = data.frontConfig
	sprite = createSprite(1, config, destPos)
	sprite:setTag(config.sound_effect)
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(duration))
	arr:addObject(CCCallFuncN:create(playSoundEffect))
	arr:addObject(CCCallFuncN:create(spurting))
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	sprite:runAction(CCSequence:create(arr))
	sprite:setVisible(false)
	sprite:setScale(2.0)
end

function SpecialEffect.explodeDuration(data)
	
end

---------------------------------------------------------------------------------
-------------------火雨,单一弹道前景动画*背景动画------------------------
---------------------------------------------------------------------------------

local function calNewPos(scrPos, raduis, angle)
	local radian = angle / (180.0 / 3.14)
	local x = math.sin(radian) * raduis
	local y = math.cos(radian) * raduis
	return ccp(scrPos.x + x, scrPos.y + y)
end

function SpecialEffect.playRain(data)
	if data.flyConfig == nil or data.frontConfig == nil then
		SpecialEffect.playDefault(data)
		return
	end
	
	local function startRain(sender)
		removeSelf(sender)
		
		--下雨
		local config = data.flyConfig
		if config ~= nil then
			for key, value in pairs(data.targetVec) do
				local sprite = createSprite(1, config, data.casterPos)
				sprite:setScale(0.5)
				--播放动画
				local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
				sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
				
				--更新飞行弹道的方向
				local x, y = sprite:getPosition()
				local destPos = value.pos
				local distance = destPos.x * 1.5 + 100 + (1080 - destPos.y) * 0.6
				local srcPos = calNewPos(destPos, distance, -45)
				sprite:setPosition(srcPos)
				calcRotation(sprite, srcPos, destPos)
				
				mFlySpeed = mFlySpeed * 0.5
				local duration = calcFlyDuration(srcPos, destPos)
				mFlySpeed = mConstFlySpeed
				sprite:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(removeSelf)))
				--飞行
				value.duration = duration
			end
			
			--播放音效
			SoundDispath.skillEffect(config.sound_effect)
		end
		
		--前景动画
		config = data.frontConfig
		if config ~= nil then
			for key, value in pairs(data.targetVec) do
				local sprite = createSprite(1, config, value.pos)
				sprite:setTag(config.sound_effect)
				local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(value.duration))
				arr:addObject(CCCallFuncN:create(playSoundEffect))
				arr:addObject(CCAnimate:create(animation))
				arr:addObject(CCCallFuncN:create(removeSelf))
				sprite:runAction(CCSequence:create(arr))
				sprite:setVisible(false)
			end
		end
	end
	
	local config = data.flyConfig
	local sprite = createSprite(1, config, data.casterPos)
	
	--播放动画
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	--更新飞行弹道的方向
	local x, y = sprite:getPosition()
	local srcPos = ccp(x, y)
	local destPos = ccp(x, 1280)
	calcRotation(sprite, srcPos, destPos)
	
	local duration = calcFlyDuration(srcPos, destPos, 2800)
	sprite:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(startRain)))
end

function SpecialEffect.rainDuration(data)
	
end
]]--














		













