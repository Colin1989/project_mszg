--region EffectRespawn.lua
--Author : shenl
--Date   : 2014/9/10
EffectRespawn = class(Effect)

--特效ID 

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectRespawn:ctor()
	self.mPosition = ccp(360, 540)
	self.mName 	= nil
    self.mCallback = nil
end

--初始化
function EffectRespawn:init(pos, callback)
	self.mPosition = ccp(pos.x, pos.y)
	--self.mName = name
    self.mCallback = callback
end

--开始播放
function EffectRespawn:play()
    local layer = EffectMgr.getConfig("emc_front_layer")

    --重生特效
    local pos = self.mPosition


    local config = SkillConfig.getSkillEffectInfo(34)
	local plistName = config.plist_name
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)
    local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local effect = CCSprite:createWithSpriteFrameName(config.file_name)
    effect:setPosition(self.mPosition)

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.01))
    arr:addObject(CCShow:create())
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
    arr:addObject(CCDelayTime:create(0.5))
	effect:runAction(CCSequence:create(arr))
    effect:setVisible(false)
    layer:addChild(effect,3)
    --骷髅图片	local sprite = CCSprite:create("monsterdeath.png")
    sprite:setPosition(self.mPosition)

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.4))
    arr:addObject(CCFadeOut:create(0.2))
    arr:addObject(CCCallFunc:create(self.mCallback))
    arr:addObject(CCCallFuncN:create(removeSelf))
    sprite:runAction(CCSequence:create(arr))

    layer:addChild(sprite,1)

    --飘字
    local spwanFont = CCSprite:create("respwan_font.png")
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.1))
    arr:addObject(CCShow:create())
    arr:addObject(CCFadeIn:create(0.1))
    arr:addObject(CCMoveBy:create(0.15,ccp(0,80)))
    arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,30)),CCFadeOut:create(0.2)) )
    spwanFont:runAction(CCSequence:create(arr))
    spwanFont:setVisible(false)
    spwanFont:setPosition(self.mPosition)
    layer:addChild(spwanFont,5)
    --鬼
    local spwanFlag = CCSprite:create("respwan_flag.png")
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.35))
    arr:addObject( CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,100)),CCScaleTo:create(0.2, 1.0)))
    arr:addObject( CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,30)),CCFadeOut:create(0.2)))
    spwanFlag:runAction(CCSequence:create(arr))
    spwanFlag:setPosition(self.mPosition)
    layer:addChild(spwanFlag,2)
    spwanFlag:setScaleX(0.1)

    --[[
	local arr = CCArray:create()
	local scale = label:getScale()
	label:setScale(0)
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.15, 2.4 * scale), CCFadeIn:create(0.15)))
	arr:addObject(CCScaleTo:create(0.1, scale))
	arr:addObject(CCDelayTime:create(1.2))
	arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 50)), CCFadeOut:create(0.2)))
	arr:addObject(CCCallFuncN:create(removeSelf))
	label:runAction(CCSequence:create(arr))
    ]]--
   
end





--endregion
