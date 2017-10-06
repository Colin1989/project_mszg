----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	爆炸格子
----------------------------------------------------

EffectBombGrid = class(Effect)


--飞行结束回调
local function flyDone(sender)
	local gridId = sender:getTag()
	print(gridId)
	GridMgr.forceOpenGrid(gridId)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectBombGrid:ctor()
	self.mFromPos = ccp(0, 0)
	self.mTargets = {}
	self.mFlyConfig = nil
end

--初始化
function EffectBombGrid:init(pos, targets)
	self.mFromPos	= pos
	self.mTargets	= targets
	local effect_id = FightConfig.getConfig("fc_fire_ball_trap_effect_id")
	self.mFlyConfig = SkillConfig.getSkillEffectInfo(effect_id)
end


--开始播放
function EffectBombGrid:play()
	local angle = 0
	local unit = 360 / #self.mTargets
	local raduis = 1800
	for key, value in pairs(self.mTargets) do
		local pos = value.pos
		if value.gridId == 0 then
			pos.x = self.mFromPos.x + math.sin(angle / 180 * 3.14) * raduis
			pos.y = self.mFromPos.y + math.cos(angle / 180 * 3.14) * raduis
		end
		self:flyEffect(value.gridId, pos)
		angle = angle + unit
	end
end

--飞行动画
function EffectBombGrid:flyEffect(gridId, destPos)
	--创建精灵
	local config = self.mFlyConfig
	local sprite = EffectMgr.createSprite(1, config, self.mFromPos)
	sprite:setTag(gridId)
	sprite:setScale(0.7)
	
	--播放动画
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	--更新飞行弹道的方向
	local srcPos 	= self.mFromPos
	EffectMgr.calcRotation(sprite, srcPos, destPos)
	
	--飞行动作
	local duration = EffectMgr.calcFlyDuration(srcPos, destPos)
	duration = duration * 1.5
	sprite:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(duration, destPos), CCCallFuncN:create(flyDone)))
end













