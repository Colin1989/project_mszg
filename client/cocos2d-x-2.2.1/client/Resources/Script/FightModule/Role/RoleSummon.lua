--region RoleSummon.lua
--Author : shenl
--Date   : 2014/12/11
--召唤角色

RoleSummon = class(RoleMonster)

local summonInfoTable = XmlTable_load("monster_summon.xml", "id")
function getSummonInfoById(id)
    return summonInfoTable.map[tostring(id)]
end 

function RoleSummon:ctor()
    self.summontype = 0         --召唤怪类型
    self.survivaltime = 0       --存活时间
end



function RoleSummon:init(gridId, pos, summonId,camp,skilllevel,castLevel)    local summonInfo = getSummonInfoById(summonId)	self.mPosition = pos	self:initConfig()    self:setConfig("role_group_id", camp)	self:setConfig("role_side_id", camp)	self:setConfig("grid_id", gridId)	self.mGridId	= gridId    self.mMonsterId = tonumber(summonInfo.monster_id)    self.summontype = tonumber(summonInfo.summon_type)         --召唤怪类型
    self.survivaltime = tonumber(summonInfo.survivaltime)       --存活时间	self:initData(summonInfo,skilllevel)	self:initView(pos)	self:setConfig("role_level", castLevel)	--怪物ai  --FIXME    self.mRoleAction = RoleAIAction.new()    self.mRoleAction:init(self,"RoleSummon")    --view	self.mInfoView:updateAll()end

local function spaseParam(strinfo,skilllevel)
   local valueTable =     {	    {name = "L", 	value = skilllevel},	}    local finalValue = ExpressionParse.compute(ParseExpressByLv(skilllevel,strinfo), valueTable)   --这里不要天赋
    return finalValue
end 


function RoleSummon:initData(summonInfo,skilllevel)	local monsterConfig = ModelMonster.getMonsterById(self.mMonsterId)	self:setConfig("role_config", monsterConfig)	local attribute = self.mData.mAttribute    --召唤怪生命随技能等级加成	monsterConfig.atk = monsterConfig.atk + spaseParam(summonInfo.monster_atk,skilllevel)	monsterConfig.life = monsterConfig.life +spaseParam(summonInfo.monster_life,skilllevel)	attribute:initOriginalAttr(monsterConfig)	attribute:initCurrentAttr()	attribute:restoreAttribute()		--弹道	self.mBallistic.flyId 		= monsterConfig.fly_effect_id	self.mBallistic.frontId 	= monsterConfig.front_effect_id	self.mBallistic.backId 		= monsterConfig.back_effect_id	    self:setConfig("role_nick_name", monsterConfig.name)	--self:setConfig("role_level", monsterConfig.level)	self:setConfig("attack_type", monsterConfig.attack_type)	self:setConfig("monster_type", monsterConfig.type)  	--技能	local skill = self.mData.mSkill	local tb = SkillMgr.parseSkillID(monsterConfig.skills)	for key, value in pairs(tb) do		skill:addSkill(value + 0, 1, self)	end	skill:onStep("monster_init")	self:setConfig("skill_cnt", #tb)		SpecialSkill.logic(self, monsterConfig.special_skill)	--boss	if monsterConfig.type == 2 or monsterConfig.type == 3 then		self:setConfig("is_boss", true)--金银怪	endend


function RoleSummon:initView(pos)	local layer = RoleMgr.getConfig("rmc_monster_parent_layer")	local monsterConfig = ModelMonster.getMonsterById(self.mMonsterId)	self.mRoleView = ActionSprite.new(1)       --朝左 -1 超右是1	self.mRoleView:init(layer, pos, monsterConfig.icon, self.mGridId)	self:setConfig("role_icon_id", monsterConfig.icon)    if self:getConfig("role_group_id") == 0 then 	    self.mRoleView:onDirection(-1)    end 	self.mInfoView = MonsterInfoView.new()	self.mInfoView:init(self)end


function RoleSummon:roleSummonStep()    if self.survivaltime > 0 then         self.survivaltime = self.survivaltime - 1    else         self:cleanupIllusion()        end     end 


