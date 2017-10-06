--region AINodeAttack.lua
--Author : Administrator
--Date   : 2014/12/12

--主动攻击行为

AINodeAttack = class(AINodeRole)

function AINodeAttack:ctor()end
function AINodeAttack:VirualInit()
   self:setConfig("widget",3)
end 
function AINodeAttack:CalcResult()    --被眩晕了，不再使用技能与攻击	if self:getConfig("role"):isCommonAttackValid() == false then		return false	end	--主动怪攻击         --PVE	local attackType = self:getConfig("role"):getConfig("attack_type")	if attackType == 1 then       local target = self:getRandomSingalTarget()        if target == nil then 
            return false
       end 	   self:setConfig("action_name", "attack")	   self:setConfig("skill_id", 0)	   self:setConfig("skill_level", 0)       return true 	endend 


function AINodeAttack:excultResult(curTimer)	--local round = BattleMgr.getConfig("bmc_current_round")	--local timer = round:getLastTime()

    local _role = self:getConfig("role")
    local target = self:getRandomSingalTarget() 

    if target:isAlive() then		--不被玩家攻击的怪物才可以回击		if _role:getConfig("under_attack") == false then			CommonAttack.attack(_role, target, curTimer)		end		_role:setConfig("under_attack", false)	end
end 

