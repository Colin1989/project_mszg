--region GridBoss.lua
--Author : shenl
--Date   : 2014/10/13

GridBoss = class(GridMonster)


function GridBoss:ctor()    end


--开始运作，等待事件function GridBoss:run()	--主动怪主动出场    local tb = GridMgr.getConfig("gmc_grid_table")    for key, val in pairs(tb) do        if val:getConfig("refences_id") == self:getConfig("grid_id")  then            val:openGrid()            val:openFogMask()            val:effectRemoveBg()        end    end    tb[1]:forceOpenGrid()    tb[5]:forceOpenGrid()    tb[6]:forceOpenGrid()    tb[10]:forceOpenGrid()    tb[11]:forceOpenGrid()    tb[15]:forceOpenGrid()	self:openGrid()    self:openFogMask()    self:effectRemoveBg()    self:relativeMonster()	self:showMonster()end

--外部触发事件function GridBoss:onEvent()	--开始战斗	if self.mMonsterRole ~= nil and self.mMonsterRole:isAlive() then		BattleMgr.attackMonster(self:getConfig("grid_id"), self:getConfig("is_mask"))	endend

--显示出BOSSfunction GridBoss:showMonster()	self:setConfig("event_name", "monster")	local pos = self:getPosition()	pos.y = pos.y - 50	self.mMonsterRole = RoleMgr.createBoss(self:getConfig("grid_id"), pos, self.mMonsterId)	MonsterIntroduceHelper.monsterAppear(self:getConfig("grid_id"), pos, self.mMonsterId)end



--endregion
