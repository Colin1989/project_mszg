--region talentTrigger.lua
--Author : Administrator
--Date   : 2014/10/24

local mTalentTriggerTb = XmlTable_load("talent_trigger_tplt.xml","id")

local getTalentTriggerInfo= function(id)
    return mTalentTriggerTb.map[tostring(id)]
end 

--数值解析
local function talentparseParamer(str)	local newstr = string.gsub(str, "%s+", "")	local strTB = {}	for k, v in string.gmatch(newstr, "([A-Za-z0-9_.]*)([,=]?)") do		if k ~= "" then			table.insert(strTB, k)		end	end	local paramTB = {}	local idx = 1	local total = #strTB	while true do		if idx + 1 > total then			break		end		paramTB[strTB[idx]] = tonumber(strTB[idx + 1])		idx = idx + 2	end	return paramTBend



talentTrigger= class()


function talentTrigger:ctor()
    self.id = id
    self.mConfigTB	= {}
end 

function talentTrigger:init(trigger_id)    local TriggerInfo = getTalentTriggerInfo(trigger_id)
    self.mConfigTB["trigger_param"]  = TriggerInfo.trigger_param
    self.mConfigTB["trigger_round"]  = tonumber(TriggerInfo.trigger_round)                 --触发回合
    self.mConfigTB["trigger_round_index"]  = 0                                             --触发回合计数
    self.mConfigTB["trigger_rate"]  = tonumber(TriggerInfo.trigger_rate)                   --触发概率
    self.mConfigTB["trigger_times"]  = tonumber(TriggerInfo.trigger_times)                 --触发次数
    self.mConfigTB["trigger_times_index"]  = 0                                             --触发次数计数

    self.mConfigTB["trigger_type"]  = TriggerInfo.trigger_type                             --触发类型
end

--获得数据function talentTrigger:getConfig(name)	return self.mConfigTB[name]end--设置数据function talentTrigger:setConfig(name, value)	self.mConfigTB[name] = valueendfunction talentTrigger:addConfig(name, delta)	self.mConfigTB[name] = self.mConfigTB[name] + deltaend
 --概率触发限制 
function talentTrigger:isRate()
    local  rate = math.random(0, 9999)   
    --print("talentTrigger:isRate()",rate,"REALRATE",self:getConfig("trigger_rate"))
    if rate > self:getConfig("trigger_rate") then 
        return false 
    else 
        return true
    end
end 
--次数触发限制
function talentTrigger:isLimitTime()
    if self:getConfig("trigger_times") > 0 then 
        local index = self:getConfig("trigger_times_index")  
        if  index <  self:getConfig("trigger_times")  then 
            return true
        else
            return false 
        end 
    else 
        return true
    end 
end



--特殊触发：血量低下
function talentTrigger:parseremainLife(param)
    local str = self:getConfig("trigger_param") 
    local tb = talentparseParamer(str)
    if param  <  tb.remain then 
        return true 
    end 
    return false
end 

--特殊触发：血量低下
function talentTrigger:parseRemainLife(paramTb)
    local str = self:getConfig("trigger_param") 
    local tb = talentparseParamer(str)

    if tb.remain < paramTb  then 
        return true 
    end 
    return false
end 

--特殊触发：debuff 时触发
function talentTrigger:parseRoundDebuff(role)
    if BuffMgr.isDebuff(role) then 
        return true 
    end 
    return false
end 

--特殊触发：每X个回合
function talentTrigger:parseRoundInterval(paramTb)
    local str = self:getConfig("trigger_param") 
    local tb = talentparseParamer(str)
    if paramTb%tb.round == 0 then 
        return true 
    end 
    return false
end 

--特殊触发 ：释放特殊序列技能
function talentTrigger:praseCastSpecSkillList(castSkillList)
    local str = self:getConfig("trigger_param") 
    local tb = talentparseParamer(str)
    if tonumber(tb.skills_typelist) == tonumber(castSkillList) then 
        return true
    end 
    return false
    
end 

--回合开始触发
function talentTrigger:isHappennedOnRoundBegin(remainLife,curRoundIndex,role)
    local pRet = false 
    local triggerType = self:getConfig("trigger_type")

    if self:isRate() and self:isLimitTime() then 
       if triggerType == "remain_life" then 
            pRet = self:parseremainLife(remainLife)
       elseif triggerType == "round_interval" then 
            pRet = self:parseRoundInterval(curRoundIndex)
       elseif triggerType == "abnormal_buff" then 
            pRet = self:parseRoundDebuff(role)
       end
    end
    return pRet 
end 
--翻开格子的时候触发
function talentTrigger:isHappennedOnGridOpen()
    local triggerType = self:getConfig("trigger_type")
    if triggerType == "open_grid" then 
        if self:isRate() and self:isLimitTime() then 
            return true 
        end 
    end
    return false
end 
--普通攻击的时候触发
function talentTrigger:isHappennedCommonAttack()
    local triggerType = self:getConfig("trigger_type")
    if triggerType == "common_attack" then 
        if self:isRate() and self:isLimitTime() then 
            return true
        end 
    end
    return false 
end 

--被普通攻击后的时候触发
function talentTrigger:isHappennedBeCommonAttack()
    local triggerType = self:getConfig("trigger_type")
    if triggerType == "beingcommon_attacked" then 
        if self:isRate() and self:isLimitTime() then 
            return true
        end 
    end
    return false 
end 

--被普通攻击前的时候触发
function talentTrigger:isHappennedBeCommonAttackBefore()
    local triggerType = self:getConfig("trigger_type")
    if self:isRate() and self:isLimitTime() then 
        if triggerType == "beingcommon_attacked_before" then 
            return true
        end 
    end
    return false 
end 

function talentTrigger:isHappennedOnDie()
    if self:isLimitTime() then 
    local triggerType = self:getConfig("trigger_type")
        if triggerType == "feigndeath" then 
            return true
        end 
    end 
end 

function talentTrigger:isHappennedOnBeforeCastSkill(castSkillList)
    if self:isRate() then 
        local triggerType = self:getConfig("trigger_type")
        if triggerType == "beforeCastSpecSkill" then 
            if self:praseCastSpecSkillList(castSkillList) then 
                return true
            end
        end 
    end 
end 

--endregion
