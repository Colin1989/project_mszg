--region EffectSummon.lua
--Author : Administrator
--Date   : 2014/9/11
EffectSummon = class(Effect)

--特效ID 

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectSummon:ctor()
	self.mHostPos = ccp(360, 540)
	--self.mSummonPos = ccp()
    self.mCallback = nil
end

--初始化
function EffectSummon:init(hostPos,caseter)

    self.mCaster = caseter
	self.mHostPos = ccp(hostPos.x, hostPos.y)
	--self.mName = name
    --self.mSummonPos = ccp(summonPos.x, summonPos.y)
end

--开始播放
function EffectSummon:play()
    --背景父节点
    local layer = EffectMgr.getConfig("emc_back_layer")

 
    self.mCaster:changeAnimateState("attack")

    local Block_ball = EffectBallistic.new()
	Block_ball:init(self.mCaster:getPosition(), self.mHostPos, 117, 0, 0)
	Block_ball:setSpeed(550)
	Block_ball:play()

  
    local sprite = FightAnimationMgr.gridEffectOnce("openmask_%02d.png", 10, 0.3)    sprite:setScale(1.4)	layer:addChild(sprite)	sprite:setPosition(self.mHostPos)	sprite:setAnchorPoint(ccp(0.5,0.5))
   
end

--endregion
