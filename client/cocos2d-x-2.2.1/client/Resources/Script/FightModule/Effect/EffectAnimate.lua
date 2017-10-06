----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	帧动画
----------------------------------------------------

EffectAnimate = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectAnimate:ctor()
	self.mPosition = ccp(360, 540)
	self.mFrontConfig = nil
end

--初始化
function EffectAnimate:init(pos, effectId)
	self.mPosition = ccp(pos.x, pos.y)
	self.mFrontConfig = SkillConfig.getSkillEffectInfo(effectId)
end

--开始播放
function EffectAnimate:play()
	if self.mFrontConfig == nil then
		self:over()
		return
	end
	local config = self.mFrontConfig
	local sprite = EffectMgr.createSprite(1, config, self.mPosition)
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	sprite:runAction(CCSequence:create(arr))

    return sprite
end

--特效持续时间
function EffectAnimate:duration()
    local invertal = EffectMgr.getConfig("emc_frame_interval")
    return self.mFrontConfig.image_count * invertal
end












