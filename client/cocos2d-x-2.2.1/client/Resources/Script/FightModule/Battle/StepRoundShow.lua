--region StepRoundShow.lua
--Author : shenl
--Date   : 2015/1/6
--此文件由[BabeLua]插件自动生成

StepRoundShow = class(BattleStep)

--构造function StepRoundShow:ctor()	self.mRoundFlag		= nil    self.mName		= "round_flag"end--初始化function StepRoundShow:init(roundFlag)	self.mRoundFlag = roundFlagend--执行对应的操作 function StepRoundShow:excute()    local effect = EffectRoundflag.new()    effect:init(self.mRoundFlag)    effect:play()end
function StepRoundShow:getDuration()
    return 0.8
end 



--endregion
