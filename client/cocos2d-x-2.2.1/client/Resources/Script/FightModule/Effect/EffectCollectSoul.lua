----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	怪物死亡后灵魂被收集
----------------------------------------------------

EffectCollectSoul = class(Effect)


--构造
function EffectCollectSoul:ctor()
	self.mBallistic			= nil			--弹道飞行特效
end


--初始化
function EffectCollectSoul:init(pos)
	local function collectSoul()
		LayerGameUI.updateMonsterCnt()
		self:openDoor()
	end
	local effect_id = FightConfig.getConfig("fc_soul_effect_id")
	local destPos = LayerGameUI.getMonsterIconPos()
	local speed = EffectMgr.getConfig("emc_ballistic_speed") * 0.5
	self.mBallistic = EffectBallistic.new()
	self.mBallistic:init(pos, destPos, effect_id, 0, 0)
	self.mBallistic:setSpeed(speed)
	self.mBallistic:setCallback(collectSoul, nil)
end

--开始播放
function EffectCollectSoul:play()
	self.mBallistic:play()
end

local function openDoorCB()
	GridMgr.openDoor()
end

--灵魂收集满了,开门
function EffectCollectSoul:openDoor()
	FightDateCache.updateData("fd_floor_killed_monster", 1)
	local total = FightDateCache.getData("fd_floor_total_monster")
	local count = FightDateCache.getData("fd_floor_killed_monster")
	if count < total then
		return
	end
	local effect_id = 4
	local pos = LayerGameUI.getMonsterIconPos()
	local destPos = GridMgr.getDoorPos()
	local speed = EffectMgr.getConfig("emc_ballistic_speed") * 0.5
	self.mBallistic = EffectBallistic.new()
	self.mBallistic:init(pos, destPos, effect_id, 0, 0)
	self.mBallistic:setSpeed(speed)
	self.mBallistic:setCallback(openDoorCB, nil)
	self.mBallistic:play()
end













