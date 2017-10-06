--region SpecialSkillset.lua
--Author : shenl
--Date   : 2014/12/10
--技能特殊设定

SpecialSkillset = {}
--[[
{
"slay":[{"belowRate":"20","addAtkRate":300}],
"vampire":[{"vampirePoint":500}]，
"resetCd":[{"resetType":42}]
}

]]--

local parseFuncTB = {}
parseFuncTB["slay"]	 	        = SpecialSkillset.slayparseFuncTB["vampire"]	 		= SpecialSkillset.vampireparseFuncTB["resetCd"] 	        = SpecialSkillset.resetCd

local defaultReturnValue ={}
defaultReturnValue["slay"] = 1.0
defaultReturnValue["vampire"] = 0
defaultReturnValue["resetCd"] =nil


--SkillsetTb,key,caster,denfener  key:当前需要作用的字段类型
function SpecialSkillset.excult(SkillsetTb,key,...)
    for k,v in pairs(SkillsetTb) do 
        if key == v then 
            return parseFuncTB[key](valueTb,...)
        else 
            return defaultReturnValue[key]
        end 
    end 
end 

--斩杀(提高伤害百分比) 固定数值找策划再开类型
function SpecialSkillset.slay(valueTb,...)
    local denfener = arg[1] --防御者
    local defAttr = denfener:getDataInfo("attr")
    local percentage = defAttr:getByName("life") / defAttr:getMaxAttrWithName("life")

    if percentage < valueTb.addAtkRate then 
        return valueTb.addAtkRate       --可能是个公式再改
    else 
        return 1.0
    end
end

--吸血
function SpecialSkillset.vampire(valueTb)
    return valueTb.vampirePoint
end

--重置CD
function SpecialSkillset.resetCd(valueTb)
    local caster = arg[1] --施法者
    local reset_skillkeyTb = arg[2] --释放技能
    --为触发其他指定技能触发冷却    if #reset_skillkeyTb > 0 then        for key,resetSkilltype in pairs(base.reset_skillkey) do             local skillData = caster:getDataInfo("skill")            skillData:reset(resetSkilltype)        end         self.mRole:updateInfoView("skill")    end

end



--endregion
