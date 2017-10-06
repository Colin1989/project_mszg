--region EffectRebound.lua
--Author : shenl
--Date   : 2014/9/12
--此文件由[BabeLua]插件自动生成

EffectRebound = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectRebound:ctor()
	self.mPosition = ccp(360, 540)
	self.mFrontConfig = nil
end

--初始化
function EffectRebound:init(pos, effectId)
	self.mPosition = ccp(pos.x, pos.y)
	self.mFrontConfig = SkillConfig.getSkillEffectInfo(effectId)
end

--开始播放
function EffectRebound:play()
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
function EffectRebound:duration()
    local invertal = EffectMgr.getConfig("emc_frame_interval")
    return self.mFrontConfig.image_count * invertal
end


--endregion
