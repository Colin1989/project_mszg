--region Effectdevor.lua
--Author : shenl
--Date   : 2014/10/15


Effectdevor = class(Effect)

--特效ID 

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function Effectdevor:ctor()
	self.mHostPos = ccp(360, 540)
	self.mSummonPosList = {}
end

--初始化
function Effectdevor:init(hostPos,poslist)
	self.mHostPos = ccp(hostPos.x, hostPos.y)
    self.mPosList = poslist
end

--开始播放
function Effectdevor:play()
    --背景父节点
   local layer = EffectMgr.getConfig("emc_back_layer")

   local effect = EffectAnimate.new()   effect:init(self.mHostPos, 53)            --self:getMiddlePos()   effect:play()

   local effect_id = FightConfig.getConfig("fc_soul_effect_id")
   local speed = EffectMgr.getConfig("emc_ballistic_speed") * 0.5

   for k,startpos in pairs(self.mPosList) do 
       local fly = EffectBallistic.new()
	   fly:init(startpos,self.mHostPos, effect_id, 0, 0)
	   fly:setSpeed(speed)
       fly:play()
   end
    

end

--endregion


--endregion
