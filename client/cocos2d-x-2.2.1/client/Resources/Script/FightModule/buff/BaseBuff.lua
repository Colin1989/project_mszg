--region BaseBuff.lua
--Author : Administrator
--Date   : 2014/11/27

BaseBuff=class()

constBuff = {
    ["MLSY"] = 
    {
     acceptskilllist = {15,16,18},
     changeId = {34,34,36}
    },
     ["MLSY2"] = 
    {
     acceptskilllist = {15,16}
    }
}

local mInstanceId = 0

function BaseBuff:ctor()
    self.mConfigTB	= {}
    self.mConfigTB["instance_id"] = mInstanceId
    mInstanceId = mInstanceId + 1
end

function BaseBuff:init(id,quality,level,caster,talentlv)
    local BuffInfo = SkillConfig.getSkillBuffInfo(id,quality,level,talentlv)
    local instance_id = nil 
    

    self.mConfigTB["fold_times"]  =   1
    self.mConfigTB["fold_maxtimes"]  =  BuffInfo.fold_maxtimes--BuffInfo.fold_maxtimes

    self.mConfigTB["buff_id"]  =   BuffInfo.buff_id
    self.mConfigTB["buff_type"]  = BuffInfo.buff_type   --1 buff 2 deBuff 3光环 4 祝福
    self.mConfigTB["shader_name"]   =   BuffInfo.shader_name    self.mConfigTB["quality"]  =   quality    self.mConfigTB["level"]   =   level    self.mConfigTB["duration"]   =   BuffInfo.duration     self.mConfigTB["crit_ratio"]  =   0
    self.mConfigTB["buff_replace_type"]  =   BuffInfo.buff_replace_type
    self.mConfigTB["is_invalid"] = false  --是否即将无效  无效就移除
    self.mConfigTB["buff_icon"] = BuffInfo.buff_icon
    self.mConfigTB["new_flag"] = false --是否是新BUFF 用来播放动画
    self.mConfigTB["buff_name"] = BuffInfo.buff_name
    self.mConfigTB["buff_made"] = BuffInfo.buff_made or 1
    self.mConfigTB["talentlv"] = talentlv or 1
    self.mConfigTB["modifyTB"]  =   self:parseModifyAttr(BuffInfo,quality,level)


    self.mCaster = caster
    if caster~= nil then 
        instance_id = caster:getConfig("refences_id")
    end

    self.mConfigTB["caster_instance_id"] = instance_id      --上BUFF的role实例ID 第三方(陷阱)为nil
    self.mConfigTB["target"] = BuffInfo.target 
end
--buff
--signal_times 单次叠加层数
function BaseBuff:fold(_role,newbuff,signal_times)
    local duration = newbuff:getBuffConfig("duration")
    local fold_times = self.mConfigTB["fold_times"] 
    local fold_maxtimes = self.mConfigTB["fold_maxtimes"] 

    local TempFoldTime = fold_times

    local fold_times = fold_times + signal_times
    if fold_times <= fold_maxtimes then 
        self:setBuffConfig("fold_times",fold_times)   
        self:setBuffConfig("duration",duration) --时间覆盖  

        for key=1 ,signal_times do 
            self:startImpact(_role)
        end
    else 
        self:setBuffConfig("fold_times",fold_maxtimes) --时间覆盖
        self:setBuffConfig("duration",duration)

        if fold_maxtimes-TempFoldTime > 0 then 
            for key=1 ,fold_maxtimes-TempFoldTime do 
                self:startImpact(_role)
            end
        end
    end 

    

end 

function BaseBuff:parseModifyAttr(BuffInfo,quality,level)
    local modifyTable = {}
    local nameStr = BuffInfo.modify_attribute	local valueStr = BuffInfo.modify_value

    SkillMgr.parseStatusString(modifyTable, nameStr, valueStr, quality, level,self:getBuffConfig("buff_made"),self:getBuffConfig("talentlv"))
    return modifyTable
end 


--获得数据function BaseBuff:getBuffConfig(name)	return self.mConfigTB[name]end--设置数据function BaseBuff:setBuffConfig(name, value)	self.mConfigTB[name] = valueend

function BaseBuff:onStep()
    local buffDuration = self:getBuffConfig("duration")
    if buffDuration > 1 then 
        buffDuration =  buffDuration - 1
    else 
        self:setBuffConfig("is_invalid",true)
    end 
    self:setBuffConfig("duration",buffDuration)
end


--对单个buff 对生命的修改的值
function BaseBuff:modifyLifeValue(_role)	local modifylifeValue = 0    local attr = _role:getDataInfo("attr")	for key, value in pairs(self:getBuffConfig("modifyTB")) do        -- 可能是 life + life(P)		if value.modifyAttribute == "life" then			local v = attr:calcModifiedValue("life", value.modifyValue, value.isPercentage)			modifylifeValue = modifylifeValue + v		end	end	--return math.random(-100, 100)	return modifylifeValue
end 


--buff开启 修改属性function BaseBuff:startImpact(_role)	self:modifyAttribute(_role,self:getBuffConfig("modifyTB"), true)	self:modifyStatus(_role,self:getBuffConfig("modifyTB"), true)end

--buff结算 还原属性
function BaseBuff:stopImpact(_role)    for key=1,self:getBuffConfig("fold_times") do	    self:modifyAttribute(_role,self:getBuffConfig("modifyTB"), false)	    self:modifyStatus(_role,self:getBuffConfig("modifyTB"), false)
    end 
end 


--改变基础数据,不改变生命值function BaseBuff:modifyAttribute(_role,tb, bOn,buffid)    local attr = _role:getDataInfo("attr")	for key, value in pairs(tb) do		if value.modifyAttribute ~= "life" then			attr:modifiedByName(value.modifyAttribute, value.modifyValue, value.isPercentage, bOn)      		end	endend--改变状态function BaseBuff:modifyStatus(_role,tb, bOn)    local roleStatus = _role:getDataInfo("status")	for key, value in pairs(tb) do		local status = roleStatus:getStatus(value.modifyAttribute)		if status ~= nil then			if type(status) == "number" then				local data = bOn and value.modifyValue or 0				roleStatus:setStatus(value.modifyAttribute, data)            elseif type(status) == "string" then                if bOn then                     roleStatus:setStatus(value.modifyAttribute, value.modifyValue)                else                     roleStatus:setStatus(value.modifyAttribute, "")                end 			else				roleStatus:setStatus(value.modifyAttribute, bOn)			end		end	endend

--endregion
