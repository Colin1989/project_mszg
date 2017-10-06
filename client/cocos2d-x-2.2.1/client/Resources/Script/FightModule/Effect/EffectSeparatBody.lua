--region EffecteparatBody.lua
--Author : Administrator
--Date   : 2014/10/14
--此文件由[BabeLua]插件自动生成

EffectSeparatBody = class(Effect)

--特效ID 

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectSeparatBody:ctor()
	self.mHostPos = ccp(360, 540)
	self.mSummonPosList = {}
end

--初始化
function EffectSeparatBody:init(hostPos,poslist)
	self.mHostPos = ccp(hostPos.x, hostPos.y)
    self.mSummonPosList = poslist
end

--开始播放
function EffectSeparatBody:play()
    --背景父节点
    local layer = EffectMgr.getConfig("emc_back_layer")

   local effect = EffectAnimate.new()   effect:init(self.mHostPos, 58)            --self:getMiddlePos()   effect:play()

    --树荫
    local treeshader = CCSprite:create("fenshader.png")
    treeshader:setPosition(ccp(self.mHostPos.x-8,self.mHostPos.y - 100))
    layer:addChild(treeshader)

    local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(1.6))
	arr2:addObject(CCFadeOut:create(0.3))
    arr2:addObject(CCCallFuncN:create(removeSelf))
	treeshader:runAction( CCSequence:create(arr2))
  
    --树桩
    local sprite = CCSprite:create("item6.png")
    sprite:setPosition(ccp(self.mHostPos.x,self.mHostPos.y+120))
    layer:addChild(sprite)

    local downIng = CCEaseBackIn:create(CCMoveBy:create(0.6,CCPointMake(0,(-1)*160)))
  	local arr = CCArray:create()
	arr:addObject(downIng)
	arr:addObject(CCDelayTime:create(1.0))
	arr:addObject(CCFadeOut:create(0.3))
    arr:addObject(CCCallFuncN:create(removeSelf))
	sprite:runAction( CCSequence:create(arr))

    local effect_id = 4
	local speed = EffectMgr.getConfig("emc_ballistic_speed") * 0.8

    for k,endpos in pairs(self.mSummonPosList) do 
        local fly = EffectBallistic.new()
	    fly:init(self.mHostPos, endpos, effect_id, 0, 0)
	    fly:setSpeed(speed)
        fly:play()
    end
    

end

--endregion
