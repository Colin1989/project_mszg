--region StepOpenGrid.lua
--Author : shenl
--Date   : 2015/1/14
--此文件由[BabeLua]插件自动生成

StepOpenGrid = class(BattleStep)--构造function StepOpenGrid:ctor()    self.mIdx = nilend--初始化   AI_RANDOM PLAYER_APPLYfunction StepOpenGrid:init(openModel,idx)  self.mOpenModel = openModel  self.mIdx = idxendfunction StepOpenGrid:AiRandom()
    local grid = GridMgr.getGridByIdx(self.mIdx)    grid:setConfig("is_trigger_new_round",false) --== false then    grid:onEvent()end function StepOpenGrid:PlayerApply()    local grid = GridMgr.getGridByIdx(self.mIdx)    --grid:setConfig("is_trigger_new_round",false)    grid:onEvent()    cclog("执行玩家开格子逻辑")end--执行对应的操作function StepOpenGrid:excute()    if self.mOpenModel == "AI_RANDOM" then         self:AiRandom()    else    --if "PLAYER_APPLY" == self.mOpenModel then         self:PlayerApply()    endend


--endregion
