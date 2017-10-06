--region AINodeRole.lua
--Author : Administrator
--Date   : 2014/12/12
-- AI行为的抽象类
AINodeRole = class()



--local mAiInfoTb  = XmlTable_load("jjcai_behavior.xml", "condition")

function getAiInfoById(contidion)
    local tb = mAiInfoTb.map[tostring(conditon)]
    
    --table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)

    return tb
end 

--retrun tb：敌方role表,mytb 我方role表
function AINodeRole:getOtherandMyCamp()
    local _role = self:getConfig("role")
    local roleCamp = _role:getConfig("role_group_id")

    local tb = {}
    local mytb = {}
    if roleCamp == 0 then
        tb = RoleMgr.getConfig("rmc_monster_table")
        mytb = RoleMgr.getConfig("rmc_player_table")
    elseif roleCamp == 1 then 
        tb = RoleMgr.getConfig("rmc_player_table")
        mytb = RoleMgr.getConfig("rmc_monster_table")
    end 
    return tb,mytb
end 


function AINodeRole:ctor()    self.mConfigTB ={}end


function AINodeRole:init(role)
    self:initConfig()
    self:setConfig("role",role)
    self:VirualInit()
end 
 
--虚函数留给子类实现
function AINodeRole:VirualInit()
    assert(nil,"implementate function VirualInit")
end 


--初始化配置数据function AINodeRole:initConfig()    self.mConfigTB["role"]                  = nil       --绑定角色    self.mConfigTB["interrupt"]             = false     --是否打断后续AINODE    self.mConfigTB["widget"]                = 0         --权值  越小越优先end

function AINodeRole:getConfig(name)	local ret = self.mConfigTB[name]	return retend--设置数据function AINodeRole:setConfig(name, value)	self.mConfigTB[name] = valueendfunction AINodeRole:CalcResult()    return falseend --h表示是合力攻击生命值最少的目标(人数占优)
--s表示是搜寻格子（有可以开的格子）
--g表示攻击生命值最少的目标--是否人数占优function AINodeRole:isDominant()    local pRet = false     local enemyTb,myFriendTb = self:getOtherandMyCamp()    local enemmyNumber = 0    local friendNumber = 0    for key,role in pairs(enemyTb) do         if role.tag ~= "RoleMonster" then             enemmyNumber = enemmyNumber + 1        end     end     for key,role in pairs(myFriendTb) do         if role.tag ~= "RoleMonster" then             friendNumber = friendNumber + 1        end     end         if friendNumber > enemmyNumber then         pRet =  true     end     return pRetend --获取生命最少的rolefunction AINodeRole:getLifeleast()    local tb = self:getOtherandMyCamp() --or {}
    if #tb <= 0 then return nil end     --table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)    local leastLife  = 99999999    local leastKey = nil    for key,role in pairs(tb) do         local  realLife =  role:getDataInfo("attr").hitPoints        if realLife <  leastLife then             leastLife =  realLife            leastKey = key        end     end     return tb[leastKey]end--随机获取一个rolefunction AINodeRole:getRandomSingalTarget()
    --先做随机攻击模式
    local tb = self:getOtherandMyCamp() --or {}
    if #tb <= 0 then 
        return nil
    end 

    local aliveTb = {}

    for key,role in pairs(tb) do 
        if role:isAlive() then 
            table.insert(aliveTb,role)
        end 
    end 

    if #aliveTb <= 0 then 
        return nil
    end 

    local randomTraget = math.random(1,#aliveTb)
    return aliveTb[randomTraget]
end 