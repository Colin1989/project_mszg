--region StepBeforeCast.lua
--Author : Administrator
--Date   : 2014/9/10
--此文件由[BabeLua]插件自动生成
----------------------------------------------------------------------StepBeforeCast = class(BattleStep)--构造function StepBeforeCast:ctor()    self.mEffect   = nilend--初始化function StepBeforeCast:init(pos)	self.mEffect = EffectAnimate.new()    self.mEffect:init(pos, 114)    self.mDuration = self.mEffect:duration() *0.7end--执行对应的操作function StepBeforeCast:excute()    self.mEffect:play()end
--endregion
