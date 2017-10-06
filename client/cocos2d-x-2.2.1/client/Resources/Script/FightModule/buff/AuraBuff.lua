--region AuraBuff.lua
--Author : Administrator
--Date   : 2014/11/27
--此文件由[BabeLua]插件自动生成

--光环

AuraBuff=class(BaseBuff)

function AuraBuff:ctor(id)

end


function AuraBuff:onStep()
   --光环不受回合机制影响 只受施法者影响
end


--[[
function AuraBuff:init(id,quality,level,caster)
    local BuffInfo = SkillConfig.getSkillBuffInfo(id)
    local instance_id = nil 
    assert(caster ~= nil,"光环没有施法者？？？")
    instance_id = caster:getConfig("refences_id")

    self.mConfigTB["buff_id"]  =   BuffInfo.buff_id
    self.mConfigTB["buff_type"]  = BuffInfo.buff_type   --1 buff 2 deBuff 3光环 4 祝福
    self.mConfigTB["shader_name"]   =   BuffInfo.shader_name    self.mConfigTB["quality"]  =   quality    self.mConfigTB["level"]   =   level    self.mConfigTB["duration"]   =   BuffInfo.duration    self.mConfigTB["modifyTB"]  =   self:parseModifyAttr(BuffInfo,quality,level)    self.mConfigTB["crit_ratio"]  =   0
    self.mConfigTB["buff_replace_type"]  =   BuffInfo.buff_replace_type
    self.mConfigTB["is_invalid"] = false  --是否即将无效  无效就移除
    self.mConfigTB["buff_icon"] = BuffInfo.buff_icon
    self.mConfigTB["new_flag"] = false --是否是新BUFF 用来播放动画
    self.mConfigTB["buff_name"] = BuffInfo.buff_name

    self.mCaster = caster

    self.mConfigTB["caster_instance_id"] = instance_id      --上BUFF的role实例ID 第三方(陷阱)为nil
    self.mConfigTB["target"] = BuffInfo.target 
end
]]--

--groupid：组别id,0是玩家方,1是怪物方,2是援军
--target：作用类型 3-我方所有目标 4-敌方所有目标
 function chooseImpactRoles(groupid,target)
  
   local roleTb = nil 
   if groupid == 0 and target == 3 then 
      roleTb = RoleMgr.getConfig("rmc_player_table")
   elseif groupid == 1 and target == 4 then 
      roleTb = RoleMgr.getConfig("rmc_player_table")
   elseif groupid == 0 and target == 4 then 
      roleTb = RoleMgr.getConfig("rmc_monster_table")
   elseif groupid == 1 and target == 3 then 
      roleTb = RoleMgr.getConfig("rmc_monster_table")
   else 
       assert(nil,"第三方光环buff?"..groupid.."  "..target)
   end 
   return roleTb
end


--光环修改所有阵营相同的角色
function AuraBuff:startImpact()	
   local role_group_id = self.mCaster:getConfig("role_group_id") 
   local targetGroup = self:getBuffConfig("target") 

   local roleTb = chooseImpactRoles(role_group_id,targetGroup) 
   for key,role in pairs(roleTb) do 
       if role:isAlive() then
   	        self:modifyAttribute(role,self:getBuffConfig("modifyTB"), true)	        self:modifyStatus(role,self:getBuffConfig("modifyTB"), true)
       end
   end 
end 

--buff结算 还原属性
function AuraBuff:stopImpact(_role)   local role_group_id = self.mCaster:getConfig("role_group_id") --组别id,0是玩家方,1是怪物,2是援军
   local targetGroup = self:getBuffConfig("target") 

   local roleTb = chooseImpactRoles(role_group_id,targetGroup) 

   for key,role in pairs(roleTb) do 
       	if role:isAlive() then
   	        self:modifyAttribute(role,self:getBuffConfig("modifyTB"), false)	        self:modifyStatus(role,self:getBuffConfig("modifyTB"), false)
        end 
   end 
end 
--endregion
