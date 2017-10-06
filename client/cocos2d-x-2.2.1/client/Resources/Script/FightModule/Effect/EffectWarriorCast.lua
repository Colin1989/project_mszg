----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	战士施法全屏特效
----------------------------------------------------

EffectWarriorCast = class(EffectPlayerCast)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectWarriorCast:ctor()
end

function EffectWarriorCast:play()
    local roleFile = "warrior_cast.png"
    local roleBgLight = "warrior_cast_light.png"
    local animationid = 10


	local parent = EffectMgr.getConfig("emc_front_layer")
	local layer = CCLayer:create()
	parent:addChild(layer, 1000)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(1.5))
	arr:addObject(CCCallFuncN:create(removeSelf))
	layer:runAction(CCSequence:create(arr))
	
	--背景遮罩
	local mask = self:createMask()
	layer:addChild(mask)
	local arr = CCArray:create()
    arr:addObject(CCFadeIn:create(0.3))
    arr:addObject(CCDelayTime:create(0.3))
    arr:addObject(CCFadeOut:create(0.2))
    mask:runAction(CCSequence:create(arr))
	
	--角色1
    local role = CCSprite:create(roleFile)
	layer:addChild(role, 2)
	role:setPosition(ccp(360, 540))
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.3))
	arr:addObject(CCShow:create())
	
    local actionScale = CCScaleTo:create(0.1,1.0)
	local actionFadein = CCFadeIn:create(0.1)
    arr:addObject(CCSpawn:createWithTwoActions(actionScale,actionFadein))


    arr:addObject(CCDelayTime:create(0.3))
    arr:addObject(CCFadeOut:create(0.8))
    --arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.8),CCMoveBy:create(0.8, ccp(-300,0))))

	role:runAction(CCSequence:create(arr))
	role:setVisible(false)
    role:setScale(0.5)

    --角色2
    --[[
    local role2 = CCSprite:create(roleFile)
	layer:addChild(role2, 2)
	role2:setPosition(ccp(360, 540))
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.7))
	arr:addObject(CCShow:create())
    arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.8),CCMoveBy:create(0.8, ccp(300,0))))
	role2:runAction(CCSequence:create(arr))
    ]]--
	
	--背景光
    local light = CCSprite:create(roleBgLight)
	layer:addChild(light)
	light:setPosition(ccp(360, 740))
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.3))
	arr:addObject(CCShow:create())
	local actionScale = CCScaleTo:create(0.1,1.0)
	local actionFadein = CCFadeIn:create(0.1)

    arr:addObject(CCSpawn:createWithTwoActions(actionScale,actionFadein))

    arr:addObject(CCDelayTime:create(0.1))
    arr:addObject(CCFadeOut:create(0.6))
	light:runAction(CCSequence:create(arr))
	light:setVisible(false)
	light:setScale(0.5)

	--光圈
    local config = SkillConfig.getSkillEffectInfo(animationid)
	local plistName = config.plist_name
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)
	local effect = CCSprite:createWithSpriteFrameName(config.file_name)
    effect:setScale(2.5)
	layer:addChild(effect, 3)
	effect:setPosition(ccp(360, 440))
	local animation = FightAnimationMgr.skillEffect(config.string_format, config.image_count)
	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.4))
    arr:addObject(CCShow:create())
	arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	effect:runAction(CCSequence:create(arr))
    effect:setVisible(false)
end

--特效持续时间
function EffectWarriorCast:duration()
	return 1.2
end













