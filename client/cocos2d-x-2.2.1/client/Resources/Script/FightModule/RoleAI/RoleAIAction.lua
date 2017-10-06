--region RoleAIAction.lua
--Author : shenl
--Date   : 2014/12/12

require "AINodeRole"
require "AINodeAttack"
require "AINodeDeathWish"
require "AINodeSkill"
require "AINodeOpenGird"

RoleAIAction = class()

--[[
monsterRule:
1=优先主体
2=优先仆从
3=随机攻击
4=弱点攻击
]]--

--行为常数
local BehaviorConst = {
    "death_wish",
    "magic",
    "openGird",
    "attack"
}

local function AINodeFactory(BehaviorType)
    local node = nil
    if BehaviorType == "attack" then 
        node = AINodeAttack.new()
    elseif BehaviorType == "magic" then 
        node = AINodeSkill.new()
    elseif BehaviorType == "death_wish" then 
        node = AINodeDeathWish.new()
    elseif BehaviorType == "openGird" then 
        node = AINodeOpenGird.new()
    end 
    node.tag = BehaviorType
    return node
end  


function RoleAIAction:ctor()    --self.BehaviorTree = {}    self.mRole = nil    self.mRoleType = nilend

function RoleAIAction:init(role,roleType)
    self.mRole = role
    self.mRoleType = roleType
end 

function RoleAIAction:excultAIBehavior(const,timer)
    local aiNode = AINodeFactory(const)
    aiNode:init(self.mRole)
    local pRet = aiNode:CalcResult(self.mRoleType)
    if pRet then
        aiNode:excultResult(timer)
    end 
    return pRet,aiNode
end 


function RoleAIAction:calcBehaviorTree(timer)
    --self.BehaviorTree = {}
    local tempRet = true 

    for key,const in pairs(BehaviorConst) do 
        local pRet,aiNode = self:excultAIBehavior(const,timer)
        if pRet then 
           if aiNode:getConfig("interrupt")  == true then --是否打断后续AINODE
                break
           end
        end
    end 
end 







--endregion
