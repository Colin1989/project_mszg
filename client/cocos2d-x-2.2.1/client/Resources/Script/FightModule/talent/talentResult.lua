--region talentResult.lua
--Author : Administrator
--Date   : 2014/10/24
--此文件由[BabeLua]插件自动生成

local mTalentResultTb  = XmlTable_load("talent_result_tplt.xml", "id")

local getTalentResultInfo= function(id)
    return mTalentResultTb.map[tostring(id)]
end 

--数值解析
local function talentparseParamer(str)	local newstr = string.gsub(str, "%s+", "")	local strTB = {}	for k, v in string.gmatch(newstr, "([A-Za-z0-9_.]*)([,=]?)") do		if k ~= "" then			table.insert(strTB, k)		end	end	local paramTB = {}	local idx = 1	local total = #strTB	while true do		if idx + 1 > total then			break		end		paramTB[strTB[idx]] = tonumber(strTB[idx + 1])		idx = idx + 2	end	return paramTBend

talentResult = class()


function talentResult:ctor()
    self.id = id
    self.mConfigTB	= {}
end 

--获得数据function talentResult:getConfig(name)	return self.mConfigTB[name]end--设置数据function talentResult:setConfig(name, value)	self.mConfigTB[name] = valueend

function talentResult:init(trigger_id,talentlv)
   local resultInfo = getTalentResultInfo(trigger_id)
   if resultInfo ~= nil  then 
       self.mConfigTB["result_type"] 	= resultInfo.result_type
       self.mConfigTB["result_value"] 	= resultInfo.result_value
       self.mConfigTB["result_round"] 	= resultInfo.result_round
       self.mConfigTB["result_round_index"] 	= 0
       self.mConfigTB["result_lv"] 	= tonumber(talentlv)
   end
end 

--永久增加属性
function talentResult:addAttribute(originAttr)
   if self:getConfig("result_type") == "fixed_attribute" then 
       local paramTB = talentparseParamer(self:getConfig("result_value"))
       for key,value in pairs(paramTB) do
            assert(type(originAttr[key])== "number", "Planning to the wrong!! WrongKey"..key) 
            originAttr[key] = originAttr[key] + value
       end 
   end 
   return originAttr
end 
--永久增加状态
function talentResult:addReduce(role)
    local paramTB = talentparseParamer(self:getConfig("result_value"))
     for key,value in pairs(paramTB) do        
        --if key == "status_damage_reduce_value" then 
           role.mData.mStatus:setStatus(key,value)
        --end 
     end 
end
--额外触发技能非指向性
function talentResult:triggerSkills(caster,defener,skillLevel)
    local paramTB = talentparseParamer(self:getConfig("result_value"))
    local skill_id = paramTB.skillid
    return  talentMgr.castSkill(caster,defener,skill_id,skillLevel,self:getConfig("result_lv"), nil)  
end 

--随机选一只活着的怪
local function randomAliveMonster(monsterTB)
    local aliveMonsterTb = {}
    --没怪就不触发
    if #monsterTB < 1 then 
        return nil
    end 
    local finalMonster = nil 
    for k, monster in pairs(monsterTB) do 
        if monster:isAlive() then 
            table.insert(aliveMonsterTb,monster)
        end 
    end 
    --怪都死了不触发
    if #aliveMonsterTb < 1 then 
        return nil
    else 
        local randomIndex = math.random(1, #aliveMonsterTb)
        finalMonster = aliveMonsterTb[randomIndex]
    end 
    return finalMonster
end 

--指向性 天赋 
function talentResult:triggerSkillsRandomTarget(caster,skillLevel)
    local castgroupId = caster:getConfig("role_group_id")--组别id,0是,1是怪物
    local defener = nil
    local monsterTB = nil
    if castgroupId == 0 then --玩家
       monsterTB 	= RoleMgr.getConfig("rmc_monster_table")   or {}   
    elseif castgroupId == 1 then --怪物
       monsterTB 	= RoleMgr.getConfig("rmc_player_table")   
    end 
    if randomAliveMonster(monsterTB) == nil then 
        return false
    else 
        defener = randomAliveMonster(monsterTB)
    end 
    local paramTB = talentparseParamer(self:getConfig("result_value"))
    local skill_id = paramTB.skillid
    talentMgr.castSkill(caster,defener,skill_id,skillLevel,self:getConfig("result_lv"), nil)   
    return true 
end 

--完美闪避
function talentResult:perfectMiss(defener,result)
    if result~=nil and result:getData("type")~="miss" then 
       
       result:setData("damage", 0)
       result:setData("behavior","prefect_defensive")
       return true
    end 
    return false 
end 

--技能冷却
function talentResult:skillFresh(role)
    --技能重新冷却完毕  FIXME	local skill = role.mData.mSkill	skill:onStep("done")	role.mInfoView:updateAll()	role:changeShader()
    return true 
end
-- 强制修改生命 
function talentResult:modifyLife(role)
   local lifeValue = tonumber( self:getConfig("result_value"))
   BattleMgr.fastRespawn(role, lifeValue)
   return true
end 

-- 篡改释放技能ID
function talentResult:alterSkillId(caster,defener,skillLevel,skillBaseInfo)
    local paramTB = talentparseParamer(self:getConfig("result_value"))
    --talentMgr.castSkill(caster,defener,paramTB.alter_skillid,skillLevel,self:getConfig("result_lv"), nil)
    
    for key,alterId in pairs(paramTB) do 
        local castIdMap =string.gsub(key,"alter_skillid_","")
        castIdMap = tonumber(castIdMap)
        if skillBaseInfo.id == castIdMap then 
            cclog("篡改技能成功",key,alterId,self:getConfig("result_lv"))
            talentMgr.castSkill(caster,defener,alterId,skillLevel,self:getConfig("result_lv"), nil)
            return true
        end 
    end 
       
    return false 
end 

--执行结果 caster:施法者  result：受击伤害结果
function talentResult:executResult(caster,defener,result,skillLevel,skillBaseInfo)

    
    if caster == nil then return end 
    local pRet = false
    if self:getConfig("result_type") == "modify_life" then 
       pRet = self:modifyLife(caster)
    elseif self:getConfig("result_type") == "cast_skills" then --指向性技能
       pRet =  self:triggerSkills(caster,defener,skillLevel)
    elseif self:getConfig("result_type") == "cast_skills_random_traget" then 
       pRet = self:triggerSkillsRandomTarget(caster)
    elseif self:getConfig("result_type") == "prefect_miss" then 
       pRet = self:perfectMiss(caster,result)
    elseif self:getConfig("result_type") == "skill_fresh" then 
       pRet = self:skillFresh(caster)
    elseif self:getConfig("result_type") == "alter_skillid" then 
       pRet = self:alterSkillId(caster,defener,skillLevel,skillBaseInfo)
    end 

    return pRet
end 





--endregion
