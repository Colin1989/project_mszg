-------------------------------------
--作者：lewis
--说明：新怪物出场逻辑处理部分
--时间：2014-5-22
-------------------------------------
MonsterIntroduceHelper = {}
MonsterIntroduceHelper.isEnable = true


local function alloc()
	local data = {}
	data.id = 0
	data.isNewMonster = true
	data.pos = nil
	data.gridID = 0
	return data
end

--当前列表是否已存在已认识的怪物
local function isExistMonster(id)
	local cache = FightDateCache.getData("fd_new_monster_cache")
	for key, value in pairs(cache) do
		if value.id == id then
			return true
		end
	end
	return false
end

--判定是否是新怪物
function MonsterIntroduceHelper.isNewMonster(id)
	--if true then return true end
	local newMonsterTB = FightDateCache.getData("fd_new_monster_tb")
	for key, value in pairs(newMonsterTB) do
		if tonumber(value) == id then
			return true
		end
	end
	return false
end

--出现怪物
function MonsterIntroduceHelper.monsterAppear(gridID, pos, monsterId)
	if MonsterIntroduceHelper.isNewMonster(monsterId) == false then
		return
	end
	if isExistMonster(monsterId) then
		return
	end
    --自动战斗不弹出新怪物
    if AIMgr.getConfig("update_id") ~= nil then 
        return
    end 

	local data = alloc()
	data.id = monsterId
	data.pos = pos
	data.gridID = gridID
	local cache = FightDateCache.getData("fd_new_monster_cache")
	table.insert(cache, data)
	MonsterIntroduceHelper.flush()
end

--显示未介绍的新怪物
function MonsterIntroduceHelper.flush()
	if MonsterIntroduceHelper.isEnable == false then
		return
	end
	local cache = FightDateCache.getData("fd_new_monster_cache")
	if #cache <= 0 then
		return
	end
	if UIMonsterIntroduce.isVisible() == false then
		local tb = MonsterIntroduceHelper.getNextMonsterInfo()
		if tb.isEnd == false then
			UIManager.push("UI_MonsterIntroduce", tb)
		end
	end
end

--生成要展示的数据
function MonsterIntroduceHelper.logicData(tb, id)
	local monsterInfo = ModelMonster.getMonsterById(id)
	local monsterIntro = ModelMonster.getMonsterIntroById(monsterInfo.description_id)
	tb.icon = monsterInfo.icon
	tb.name = monsterInfo.name
	tb.description = monsterIntro.introduction
	tb.atk_mode = monsterIntro.atk_mode
	tb.corresponding_strategy =  monsterIntro.corresponding_strategy
	
	if monsterInfo.attack_type == 1 then
		tb.attackType = GameString.get("PUBLIC_ATTACK_ACTIVE")
	else
		tb.attackType = GameString.get("PUBLIC_ATTACK_NOACTIVE")
	end
	
	tb.skillDescription = {}
    --[[
	local skillTB = CommonFunc_split(monsterInfo.skills, ",")
	for key, value in pairs(skillTB) do
		local skillID = value + 0
		if SkillMgr.getSkillCD(skillID) > 0 then
			local str = SkillMgr.getDescription(skillID, 1)
			table.insert(tb.skillDescription, str)
		end
	end
	]]--
end

--获取下一个怪物信息
function MonsterIntroduceHelper.getNextMonsterInfo()
	local tb = {}
	tb.isEnd = true
	local cache = FightDateCache.getData("fd_new_monster_cache")
	for key, value in pairs(cache) do
		if value.isNewMonster then
			tb.isEnd = false
			tb.pos = value.pos
			tb.id = value.id
			value.isNewMonster = false
			tb.gridID = value.gridID
			MonsterIntroduceHelper.logicData(tb, value.id)
			return tb
		end
	end
	return tb
end





