ModelMonster = {}

local mMonster_date = XmlTable_load("monster_tplt.xml", "id") 
local mMonster_des = XmlTable_load("monster_description_tplt.xml", "id") 

ModelMonster.getMonsterIntroById = function(id)
	local res = XmlTable_getRow(mMonster_des, id, true)
	local monster = {}
	
	monster.id = res.id
	monster.introduction = res.introduction
	monster.atk_mode = res.atk_mode
	monster.corresponding_strategy =res.corresponding_strategy 
	
	return monster
end

ModelMonster.getMonsterById = function(id)
	local res = XmlTable_getRow(mMonster_date, id, true)
	local monster = {}

	monster.id = res.id
	monster.name = res.name
	monster.icon = res.icon + 0
	monster.level = res.level + 0
	monster.description_id =res.description_id + 0
	monster.type = res.type + 0
	monster.attack_type = res.attack_type + 0
	monster.relative_id = CommonFunc_split(res.relative_id, ",")
	monster.life = res.life + 0
	monster.atk = res.atk + 0
	monster.speed = res.speed + 0
	monster.hit_ratio = res.hit_ratio + 0
	monster.critical_ratio = res.critical_ratio + 0
	monster.miss_ratio = res.miss_ratio + 0
	monster.tenacity = res.tenacity + 0
	monster.skills = res.skills
	monster.special_skill = res.special_skill
	monster.drop_rate = CommonFunc_split(res.drop_rate, ",", true)
	monster.item_id = CommonFunc_split(res.item_id, ",")
	monster.drop_amount = CommonFunc_split(res.drop_amount, ",")
	monster.fly_effect_id = res.fly_effect_id + 0
	monster.front_effect_id = res.front_effect_id + 0
	monster.back_effect_id = res.back_effect_id + 0
	
	--monster.special_skill = "6"
	return monster
end

--描述
function ModelMonster.getMonsterDescription(id)
	local res = XmlTable_getRow(mMonster_date, id, true)
	return res.content
end

--类别
local mMonsterTypeTB = {}
mMonsterTypeTB[1]	= "普通怪"
mMonsterTypeTB[2]	= "头目怪"
mMonsterTypeTB[3]	= "首领怪"
mMonsterTypeTB[4]	= "技能怪"
mMonsterTypeTB[5]	= "主动怪"

mMonsterTypeTB[6]	= "偷钱怪"
mMonsterTypeTB[7]	= "掉钱怪"
mMonsterTypeTB[8]	= "重生怪"
mMonsterTypeTB[9]	= "嘲讽怪"
mMonsterTypeTB[10]	= "召唤怪"

mMonsterTypeTB[11]	= "潜行怪"
mMonsterTypeTB[12]	= "狂化怪"
mMonsterTypeTB[13]	= "爆炸怪"
mMonsterTypeTB[14]	= "物理伤害反弹怪"
mMonsterTypeTB[15]	= "魔法免役怪"
mMonsterTypeTB[16]	= "光环怪"
mMonsterTypeTB[17]	= "魔法伤害反弹怪"
mMonsterTypeTB[18]	= "全伤害反弹怪"


function ModelMonster.monsterType(mt)
	if mt == nil then
		mt = 1
	end
	
	if mt < 1 or mt > #mMonsterTypeTB then
		mt = 1
	end
	return mMonsterTypeTB[mt]
end

--弹道
function ModelMonster.getBallistic(id)
	local res = XmlTable_getRow(mMonster_date, id, true)
	local ballistic = {}
	ballistic.fly_effect_id 		= res.fly_effect_id + 0
	ballistic.front_effect_id		= res.front_effect_id + 0
	ballistic.back_effect_id 		= res.back_effect_id + 0
	return ballistic
end

ModelMonster.initEnemyAttr =function(_date)

	local ememy = {}
	for k,v in pairs (_date) do
		ememy[k] = v
	end
	return ememy
end
--是否是主动怪
ModelMonster.isInitiativeMonster = function(id)
	local monster = ModelMonster.getMonsterById(id)
	if monster.attack_type == 1 then
		return true
	end
	return false
end
---是否有涉及关联怪
--[[
ModelMonster.isRelaMonster = function(id)
	local monster = ModelMonster.getMonsterById(id)
	if type(monster.relative_id) == "table" then
		if monster.relative_id[1] == "0" then
			--cclog ("没有关联怪")
			return nil
		else
			--cclog ("有关联怪")
			return monster.relative_id
		end
	end
end
]]--

