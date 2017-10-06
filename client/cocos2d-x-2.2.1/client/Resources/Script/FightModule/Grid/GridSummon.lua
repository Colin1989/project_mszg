--region GridSummon.lua
--Author : shenl
--Date   : 2014/12/11



GridSummon = class(GridMonster)

function GridSummon:ctor()    end

function GridSummon:showMonster(caster,summonId,level)	self:setConfig("event_name", "monster")	local pos = self:getPosition()	pos.y = pos.y - 50	--self.mMonsterRole = RoleMgr.createBoss(self:getConfig("grid_id"), pos, self.mMonsterId)    self.mMonsterRole = RoleMgr.createSummon(self:getConfig("grid_id"), pos, summonId,level,caster)	--MonsterIntroduceHelper.monsterAppear(self:getConfig("grid_id"), pos, self.mMonsterId)end

--召唤怪物function GridSummon:summonMonster(caster,summonId,level)    local effect = EffectSummon.new()    effect:init(self:getPosition(),caster)    effect:play()	self:showMonster(caster,summonId,level)    --self:guardAction(true)    self.mMonsterRole.mRoleView:onTintToBright(0.5)end





--endregion
