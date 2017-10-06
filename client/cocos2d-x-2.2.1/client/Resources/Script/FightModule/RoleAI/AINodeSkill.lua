--region AINodeSkill.lua
--Author : Administrator
--Date   : 2014/12/12
--此文件由[BabeLua]插件自动生成



AINodeSkill = class(AINodeRole)

function AINodeSkill:ctor()    self.mCastSkillQuene = {}end
 function AINodeSkill:VirualInit()
   self:setConfig("widget",4)
end 
function AINodeSkill:addCastSkill(value)   local tb= {}   tb.id = value.id   tb.level = value.level   table.insert(self.mCastSkillQuene, tb)endfunction AINodeSkill:CalcResult(_roleType)    --被眩晕了，不再使用技能与攻击    local pRet =false	if self:getConfig("role"):isCommonAttackValid() == false then		return false	end	    self.mCastSkillQuene = {}	--使用技能	local skill = self:getConfig("role").mData.mSkill	local tb = skill:getTB()	for key, value in pairs(tb) do		if value.isValid then			if value.maxCD > 0 then--只创建主动技能				if value.count >= value.maxCD then					if self:calcSkill(value.id, value.level,_roleType) then						--self:setConfig("action_name", "magic")						--self:setConfig("skill_id", value.id)						--self:setConfig("skill_level", value.level)                        self:addCastSkill(value)                        pRet = true                        --return true					end									end			--一出现就释放的技能			elseif value.maxCD < 0 then				value.isValid = false				--self:setConfig("action_name", "magic")				--self:setConfig("skill_id", value.id)				--self:setConfig("skill_level", value.level)                    self:addCastSkill(value)				pRet = true			end		end	end    return pRetend 

--技能使用判定,暂只做对自身使用技能判定function AINodeSkill:calcSkill(id, level,_roleType)    if _roleType == "RoleMonster" or "RoleSummon" == _roleType then         return true    end 	local config = SkillConfig.getSkillBaseInfo(id)    --对敌方单体 和 地方全体 FIXME	if config.target == 2 or  config.target == 4 then           local target = self:getRandomSingalTarget()         if target == nil then             return false        end 		return true	end	local role = self:getConfig("role")	local attribute = role.mData.mAttribute	local atk = attribute:getByName("atk")	local life = attribute:getByName("life")	local maxlife = attribute:getMaxAttrWithName("life")	local dp, hp = SkillMgr.calDamageValue(id, level, atk)	local health = dp + hp	local lost = maxlife - life	buff = SkillConfig.getSkillBuffInfo(config.target_buff_id)	local buffStr = nil	if buff then		buffStr = buff.modify_attribute	end	if buffStr ~= nil then		local buff = role:getDataInfo("buff")		local total = 0		--本身没有buff状态		--if buff.units[1].id == 0 then			--清洁buff	    if AIMgr.isExsitField(buffStr, "cleaned") then				--身上有debuff			if BuffMgr.isDebuff(role)then					return true			else				return false			end		end		--end        return true 	end	if health > 0 then		if lost >= health then			return true		else			return false		end	end	return trueend
function AINodeSkill:excultResult()
    local _role = self:getConfig("role")
    local player = RoleMgr.getConfig("rmc_player_object")	--local monsterTB 	= RoleMgr.getConfig("rmc_monster_table")	local round = BattleMgr.getConfig("bmc_current_round")	local timer = round:getLastTime()	local duration = 0.5

    for key,skill in pairs(self.mCastSkillQuene) do 
        local target = self:getRandomSingalTarget()	    local id 	= skill.id--ainode:getConfig("skill_id")	    local level = skill.level--ainode:getConfig("skill_level")        if _role:isAlive() then             MagicAttack.fight(_role, target, id, level, timer)        else            break        end 	    timer = timer + duration    end	--end
end 


--endregion
