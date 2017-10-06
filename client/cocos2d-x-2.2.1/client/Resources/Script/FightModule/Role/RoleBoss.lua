--region RoleBoss.lua
--Author : shenl
--Date   : 2014/10/13
RoleBoss = class(RoleMonster)



function RoleBoss:ctor()

end

function RoleBoss:initView(pos)	local layer = RoleMgr.getConfig("rmc_monster_parent_layer")	local monsterConfig = ModelMonster.getMonsterById(self.mMonsterId)	self.mRoleView = ActionSprite.new(-1)       --朝左 -1 超右是1	self.mRoleView:init(layer, pos, monsterConfig.icon, self.mGridId)    --self.mRoleView.mScaleNode:setScale(2.0)    --self.mRoleView.mMoveNode:setPosition(ccp(pos.x,pos.y - 80))	self:setConfig("role_icon_id", monsterConfig.icon)	   --BOSS出场动画 不支持多个动画   	self.mInfoView = BossInfoView.new()	self.mInfoView:init(self)    self.mInfoView:setViewVisible(false)    local effect = EffectBossappence.new()    effect:init(self,ccp(pos.x,pos.y - 80))    effect:play()end


--BOSS 回合技能 配置 触发表现 写在步奏里？先写这里

local function parseParamer(str)
	local newstr = string.gsub(str, "%s+", "")
	local strTB = {}
	for k, v in string.gmatch(newstr, "([A-Za-z0-9_.]*)([,=]?)") do
		if k ~= "" then
			table.insert(strTB, k)
		end
	end
	local paramTB = {}
	local idx = 1
	local total = #strTB
	while true do
		if idx + 1 > total then
			break
		end
		paramTB[strTB[idx]] = strTB[idx + 1]
		idx = idx + 2
	end
	return paramTB
end


local function createBuff(skillid,self)
    local roleTB = {}     if self == 1 then --对所有玩家        roleTB = RoleMgr.getConfig("rmc_player_table")    else        roleTB = RoleMgr.getConfig("rmc_monster_table")    end     local base = SkillConfig.getSkillBaseInfo(49400)
    local config = SkillConfig.getSkillBuffInfo(base.target_buff_id)	for key, role in pairs(roleTB) do
        local buff = role:getDataInfo("buff")	    buff:active(base.target_buff_id, base.frame_file_name, 1)	    buff:afterActiveBuff()

        role:updateInfoView("buff")		role:updateInfoView("skill")		role:changeShader()		role:changePortraits()
    end
end 

--当前BOSS是否死了
function isExcute(monsterid)
    local curBossid = tonumber(monsterid)
    local monsterTB 	= RoleMgr.getConfig("rmc_monster_table")	for key, monster in pairs(monsterTB) do		if monster.mMonsterId == curBossid and monster:isAlive() then			return true,monster 		end	end
    return false
end 

local function RoleBoss_roundExcuteCase(eventIdtb)
    --event
    for key,eventId in pairs(eventIdtb) do 

        local eventInfo = LogicTable.getBossRounEventdInfo(eventId)
        local paramTb = parseParamer(eventInfo.param) 
        local isBossDie,boss = isExcute(eventInfo.monsterid)
        if isBossDie then 
            if eventInfo.event == "summon" then 
                GridMgr.summonMonster(1, tonumber(paramTb.monsterid),boss)
            elseif eventInfo.event == "blood" then 
                GridMgr.summonItem(tonumber(paramTb.blood_id))
            elseif eventInfo.event == "tips" then 
                FightTips.showText1(eventInfo.param, "", 1)
            elseif eventInfo.event == "buff" then 
                createBuff(tonumber(paramTb.skill_id),tonumber(paramTb.self))
            elseif eventInfo.event == "totem" then 
                GridMgr.summonItem(tonumber(paramTb.totem_id))
            end 
        end
    end  
end



function RoleBoss_roundExcute()
    local curRound =  FightDateCache.getData("fb_round_count") 
    local boss_rule_id = FightDateCache.getData("fd_boss_rule_id") or 0
    --没有BOSS?
    if boss_rule_id <= 0 then  
        return 
    end 
  
    local bossRuleInfo =  LogicTable.getBossRoundInfo(boss_rule_id)

    local BossCountTb = CommonFunc_split(bossRuleInfo.round, ",")  --BOSS 回合 触发点
    local BossCountEventIdTb = CommonFunc_parseStringTuple(bossRuleInfo.boss_eventid, true)
    for k,roundcount in pairs(BossCountTb) do 
        if tonumber( roundcount ) == curRound then 
           RoleBoss_roundExcuteCase(BossCountEventIdTb[k])
           break;
        end 
    end 
end 





