--region BuffMgr.lua
--Author : Administrator
--Date   : 2014/11/28
--此文件由[BabeLua]插件自动生成

require "BaseBuff"
require "AuraBuff"
--require "DeBuff"
--require "GainBuff"

BuffMgr = {}

--设计思路 BUFF 改变状态（DataStatus） 状态改变数值 

--创建BUFF
--target（目标）
--caster（buff施法者）
function BuffMgr.createFactory(id,quality,level,target,caster,tanlentlevel)
    local BuffInfo = SkillConfig.getSkillBuffInfo(id)

    print(BuffInfo.buff_type,"创建BUFF_________________实例",id,quality,level)
    local instance_id = nil 
    if caster ~= nil then 
        instance_id = caster:getConfig("refences_id")
    end 

    local buff = nil
    local BuffType = BuffInfo.buff_type

    --if BuffType == 1 then   -- 增益
        --buff = GainBuff.new()
    --elseif  BuffType == 2 then  --减益
        --buff = DeBuff.new()
    if  BuffType == 4 then  --光环    --3祝福
        buff = AuraBuff.new()
        buff:init(id,quality,level,caster,tanlentlevel)
    else --if BuffType == 5 then  --驱散
        buff = BaseBuff.new()
        buff:init(id,quality,level,caster,tanlentlevel)
    end
    
    assert(buff ~=nil ,"buffMgr.lua :line37 LOGIC ERROR")
    BuffMgr.addBuff(buff,target)
end 

function BuffMgr.onStep(Role)
    local RoleBuffTB = Role:getDataInfo("buff")
    local invalidBuffKeyTb = {}

    for key,buff in pairs(RoleBuffTB) do 
        buff:onStep()
        if buff:getBuffConfig("is_invalid") == true then 
            buff:stopImpact(Role)
            table.insert(invalidBuffKeyTb,key)
        end 
    end 
     table.sort(invalidBuffKeyTb, function(x, y) 
        return  y < x
     end)

    --清除失效的 BUFF
    for key,invalidKey in pairs(invalidBuffKeyTb) do 
        table.remove(RoleBuffTB, invalidKey)
    end
end

--特殊BUFF 立即生效 
--cleaned 免疫负面状态
--max_cd 沉默
local function afterActiveBuff(_Role)
    --local RoleBuffTB = _Role:getDataInfo("buff")
    local status = _Role:getDataInfo("status")
    local skillData = _Role:getDataInfo("skill")

    if status:getStatus("cleaned") == true then 
        BuffMgr.clearBuff(_Role,"debuff")  
    end 
	if status:getStatus("max_cd") == true then
        skillData:onStep("max_cd")        --FIXMEBUFF
    end
end 


--产生新BUFF
function BuffMgr.addBuff(newBuff,_Role)
    local  RoleBuffTB = _Role:getDataInfo("buff")
    local replaceType =  newBuff:getBuffConfig("buff_replace_type")

    newBuff:setBuffConfig("new_flag",true)

    --相同类型 buff顶替
    for key,buff in pairs(RoleBuffTB) do 
        if buff:getBuffConfig("buff_replace_type") == replaceType then
            if buff:getBuffConfig("fold_maxtimes") > 1 and buff:getBuffConfig("buff_id") == newBuff:getBuffConfig("buff_id") then 
                buff:fold(_Role,newBuff,1)      --默认叠加一层
    
            else 
                RoleBuffTB[key]:stopImpact(_Role) 
                RoleBuffTB[key] = newBuff                newBuff:startImpact(_Role)  --修改玩家属性
            end 
            return
        end 
    end  

    newBuff:startImpact(_Role)  --修改玩家属性
    afterActiveBuff(_Role)
    table.insert(RoleBuffTB,newBuff)
end 

--有debuff 
function BuffMgr.isDebuff(_Role)
    local  RoleBuffTB = _Role:getDataInfo("buff")
    for key,buff in pairs(RoleBuffTB) do 
        if buff:getBuffConfig("buff_type") == 2 then 
            return true 
        end 
    end 
    return false
end 


local function buffConditions(bufftype,buff)
    local buff_type = buff:getBuffConfig("buff_type")
    if "buff" == bufftype then 
        if buff_type == 1 then 
            return true
        end 
    elseif "debuff" == bufftype then 
        if buff_type == 2 then 
            return true
        end 
    elseif "allbuff" == bufftype then 
        if buff_type == 2 or buff_type == 1 then 
            return true
        end 
    end 
    return false
end 

function BuffMgr.clearBuff(_Role,bufftype)
    local  RoleBuffTB = _Role:getDataInfo("buff")
    --即将失效BUFF队列
    local invalidBuffKeyTb = {}
    for key ,buff in pairs(RoleBuffTB) do 
        if buffConditions(bufftype,buff) == true then 
            buff:stopImpact(_Role) 
            table.insert(invalidBuffKeyTb,key)
        end
    end           
    --清除失效的 BUFF
    for key,invalidKey in pairs(invalidBuffKeyTb) do 
        table.remove(RoleBuffTB, invalidKey)
    end 
end 
-- 获取BUFF  or deBuff的数量
function BuffMgr.getBuffAmonutByType(_Role,bufftype)
    local amount = 0
    local  RoleBuffTB = _Role:getDataInfo("buff")
    for key,buff in pairs(RoleBuffTB) do 
        if buffConditions(bufftype,buff) then 
            amount = amount + 1
        end 
    end 
    return amount
end 



--获取当前SHADER    --FIXME
function BuffMgr.getShader(_Role)
     local  RoleBuffTB = _Role:getDataInfo("buff")
     local shaderName = nil 
     for key,buff in pairs(RoleBuffTB) do 
        if buff:getBuffConfig("shader_name") ~= nil then 
           shaderName =  buff:getBuffConfig("shader_name")
        end 
     end 
     return shaderName
end 


function BuffMgr.isChangeSkillId(_Role,searchKey)
    local  _RoleStatus = _Role:getDataInfo("status")
    print("isChangeSkillId------------------->",searchKey,_RoleStatus.status[searchKey])
    if  _RoleStatus.status[searchKey] == true then 
        return true 
    end 
    return false
end 


--endregion
