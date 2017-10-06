--region AINodeDeathWish.lua
--Author : Administrator
--Date   : 2014/12/12

--死亡遗愿

AINodeDeathWish = class(AINodeRole)

function AINodeDeathWish:ctor()end
 function AINodeDeathWish:VirualInit()
   self:setConfig("widget",1)
   self.mConfigTB["interrupt"]  = true --是否打断后续AINODE

   self.mConfigTB["skill_id"]				= 0			--想使用的技能id   self.mConfigTB["skill_level"]			= 1			--想使用的技能等级
end 
function AINodeDeathWish:CalcResult()    local role = self:getConfig("role")	local stayRound = role:getConfig("stay_round")    local id = role:getConfig("skill_after_death")	if stayRound == 1 and id > 0 then  		self:setConfig("action_name", "death_wish")		self:setConfig("skill_id", id)		self:setConfig("skill_level", 1)        return true	endend 


function AINodeDeathWish:excultResult()
    local _role = self:getConfig("role")
	local round = BattleMgr.getConfig("bmc_current_round")	local timer = round:getLastTime()
    local duration = 0.015

	--死亡结算	local damage = Damage.new()    damage:setData("damage", -9999999)	damage:setData("type", "hit")	damage:setData("position", ccp(-640, -640))		--不在屏幕内显示	_role:bearDamage(damage:getData("damage"))						--自爆动画	local step = StepBaneling.new()	step:init(_role)	step:setTimer(timer + duration)	round:add(step)						--自爆技能	local id 	= self:getConfig("skill_id")	local level = self:getConfig("skill_level")    local dt = timer + BattleMgr.getConfig("bmc_baneling_duration")    local randomTraget = self:getRandomSingalTarget()    local skillInfo = SkillConfig.getSkillBaseInfo(id)    if (skillInfo.target == 2 or skillInfo.target == 4) and randomTraget == nil then --对敌方施法 如果没有施法对象        cclog("空炸")    else     	MagicAttack.fight(_role, randomTraget, id, level)       end 					    timer = timer + duration   	local step = StepRoleHurt.new()	step:init(_role, damage)	step:setTimer(dt)	round:add(step)
end 



--endregion
