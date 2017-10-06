--region EffectDamageRebound.lua
--Author : Administrator
--Date   : 2014/9/11
--伤害反弹特效

EffectDamageRebound = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectDamageRebound:ctor()
	self.mPos = ccp(360, 540)
	self.mAttackPos = ccp(0,0)
end

--初始化
function EffectDamageRebound:init(pos,attackPos)
	self.mPos = ccp(pos.x, pos.y-67)
	self.mAttackPos = ccp(attackPos.x, attackPos.y)
    --self.mSummonPos = ccp(summonPos.x, summonPos.y)
end

--开始播放
function EffectDamageRebound:play()
 
    local layer = EffectMgr.getConfig("emc_front_layer")

    --反弹怪背景框
    --damage_rebound_frame.png
    local reboundShell = CCSprite:create("damage_rebound_frame.png")
    reboundShell:setPosition(self.mPos)
    layer:addChild(reboundShell,1)
    reboundShell:setScale(0.05)
    reboundShell:setAnchorPoint(ccp(0.5,0.0))

    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.15, 1.2))
    arr:addObject(CCScaleTo:create(0.1, 0.9))

    arr:addObject( CCDelayTime:create(0.3) )
    arr:addObject(CCScaleTo:create(0.1, 0.8))
    arr:addObject( CCFadeOut:create(0.2) )
    arr:addObject(CCCallFuncN:create(removeSelf))

    reboundShell:runAction(CCSequence:create(arr))

    --球面动画
    local config = SkillConfig.getSkillEffectInfo(116)
	local plistName = config.plist_name
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)
	local effect = CCSprite:createWithSpriteFrameName(config.file_name)
    --effect:setScale(2.5)
	layer:addChild(effect, 2)
    effect:setAnchorPoint(ccp(0.5,0.0))
	effect:setPosition(ccp(self.mPos.x, self.mPos.y + 8))
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.25))
    arr:addObject(CCShow:create())
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	effect:runAction(CCSequence:create(arr))
    effect:setVisible(false)

     --刺痛我菊
    local config = SkillConfig.getSkillEffectInfo(115)
	local plistName = config.plist_name
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)
	local effect = CCSprite:createWithSpriteFrameName(config.file_name)
    --effect:setScale(2.5)
	layer:addChild(effect, 2)
    effect:setAnchorPoint(ccp(0.5,0.5))
	effect:setPosition(ccp(self.mAttackPos.x, self.mAttackPos .y))
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
    --arr:addObject(CCDelayTime:create(0.02))
    arr:addObject(CCShow:create())
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	effect:runAction(CCSequence:create(arr))
    effect:setVisible(false)

    --local sprite = FightAnimationMgr.gridEffectOnce("openmask_%02d.png", 10, 0.1)    --sprite:setScale(1.4)	--layer:addChild(sprite)	--sprite:setPosition(self.mHostPos)	--sprite:setAnchorPoint(ccp(0.5,0.5))
end
