--region Effectskillfont.lua
--Author : shenl
--Date   : 2015/3/13


Effectskillfont = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function Effectskillfont:ctor()

end

--初始化
function Effectskillfont:init()

end

--开始播放
function Effectskillfont:play()

    local parent = EffectMgr.getConfig("emc_front_layer")

    local fontSprite = CCSprite:create("jinenglengque.png")
    fontSprite:setPosition(ccp(320,100))
    parent:addChild(fontSprite)

	local arr = CCArray:create()
    arr:addObject(     CCSpawn:createWithTwoActions(CCMoveBy:create(1, ccp(0, 100)) ,CCFadeOut:create(1))  )
	arr:addObject(CCCallFuncN:create(removeSelf))
	fontSprite:runAction(CCSequence:create(arr))

    return sprite

end






--endregion
