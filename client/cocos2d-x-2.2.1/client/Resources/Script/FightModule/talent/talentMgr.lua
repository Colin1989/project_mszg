--region talentMgr.lua
--Author : shenl
--Date   : 2014/10/27
--此文件由[BabeLua]插件自动生成

require "talentResult"require "talentTrigger"require "Datetalent"

talentMgr = {}

local ENUM_PASSIVE_PERMENT = 1

--增加硬属性 
function talentMgr.addRoleAttr(OriginAttr,roleTalentTb)
    local newAttr = CommonFunc_table_copy_table(OriginAttr)
    local tltb = roleTalentTb
   
    for key,talent in pairs(tltb) do
        local trigger = talent:getConfig("talent_trigger_Info")
        local result = talent:getConfig("talent_result_tb")[ENUM_PASSIVE_PERMENT]
        if trigger:getConfig("trigger_type") == "passive_permanent" then     --是被动永久的天赋
           newAttr = result:addAttribute(newAttr)        
        end 
    end 
    return newAttr
end 
--role:战斗时特有 修改战斗状态
function talentMgr.addFightstatus(role)
    local tltb = role:getConfig("role_talent") or {}
    for key,talent in pairs(tltb) do
        local trigger = talent:getConfig("talent_trigger_Info")
        local result = talent:getConfig("talent_result_tb")[ENUM_PASSIVE_PERMENT]
        if trigger:getConfig("trigger_type") == "passive_status" then       --是被动永久的状态
           if role ~= nil then 
              result:addReduce(role)
           end      
        end 
    end 
end 

--天赋施放技能
function talentMgr.castSkill(caster, defenser,id, level,tanlentlevel, timer)
    --MagicAttack.fight(caster, target, id, level, timer)
   return talentMgr.MagicAttackFight(caster, defenser,id, level, tanlentlevel,timer)
end 

function talentMgr.MagicAttackFight(caster, target, id, level, tanlentlevel,timer)--施法者,指向性目标,技能id,技能等级    level = level or 0    tanlentlevel = tanlentlevel or 0	local targetTB = MagicAttack.getTargets(caster, target, id)	if #targetTB == 0 then--无作用目标		return false	end	RoleMgr.useSkill(caster, id)		local attribute = caster.mData.mAttribute	local atk = attribute:getByName("atk")		local groupId = caster:getConfig("role_group_id")--组别id,0是玩家,1是怪物,2友军	local player = RoleMgr.getConfig("rmc_player_object")	local round = BattleMgr.getConfig("bmc_current_round")	local dp, hp = SkillMgr.calDamageValue(id, level, atk,tanlentlevel)	local health = Damage.new()	health:setData("damage", hp, id)	health:setData("type", "hit")	if groupId == 2 then--友军对玩军回血		health:setData("position", player:getTopPos())		player:bearDamage(health:getData("damage"))	else		--技能回血		health:setData("position", caster:getTopPos())		caster:bearDamage(health:getData("damage"))	end			--施法动作	if timer == nil then		timer = round:getLastTime()	end    --施法前摇    local step = StepBeforeCast.new()    step:init(caster:getMiddlePos())    step:setTimer(timer)    round:add(step)	timer = timer + step:getDuration()	--施法者播放动作	step = StepCaster.new()	step:init(caster, id)	step:setTimer(timer)	round:add(step)	timer = timer + step:getDuration()		--施法完毕	step = StepAfterCast.new()	if groupId == 2 then--友军对玩军回血		step:init(player, health, id, level,target,tanlentlevel)	else		step:init(caster, health, id, level,target,tanlentlevel)	end	step:setTimer(timer)	round:add(step)	timer = timer + step:getDuration()		local targetPosTB = {}	for key, value in pairs(targetTB) do		table.insert(targetPosTB, value:getMiddlePos())	end	--技能特效	local step = StepSkillEffect.new()	step:init(caster:getMiddlePos(), targetPosTB, id)	step:setTimer(timer)	round:add(step)	local durationTB = step:getDuration()	--返回的是时间表		local base = SkillConfig.getSkillBaseInfo(id)	local replaceId = 0	--对目标数值计算	for key, value in pairs(targetTB) do        if base.bestrengthenBuff ~= "0" then             if BuffMgr.isChangeSkillId(value,base.bestrengthenBuff) then                 replaceId = base.bestrengthenid                base = SkillConfig.getSkillBaseInfo(base.bestrengthenid)                dp, hp = SkillMgr.calDamageValue(replaceId, level, atk,tanlentlevel) --重新计算技能伤害            end         end 		local step = StepAfterRoleSkill.new()		step:setTimer(timer + durationTB[key])		round:add(step)		--伤害数值重新计算,算暴击与闪避等效果		local damage,health = MagicAttack.numCalOfAttack(caster, value, dp)        MagicAttack.numCalOSaly(damage,base.special_set,value,base.quality,level,tanlentlevel)        if groupId == 2 then            health:setData("damage", 0)        end		damage:setData("position", value:getTopPos())        health:setData("position", caster:getTopPos())        caster:bearDamage(health:getData("damage"))				--伤害转移		BattleMgr.defenderBearDamage(value, damage, timer)		value:bearDamage(damage:getData("damage"))		--buff计算		local bBuff = false		--几率计算		local bActiveBuff = nil         bActiveBuff = SkillMgr.isOnBuff(base.quality, level, base.target_buff_rate,value)		local config = SkillConfig.getSkillBuffInfo(base.target_buff_id,base.quality,level,tanlentlevel)		if damage:getData("type") ~= "miss" and config ~= nil and bActiveBuff then 			--local buff = value:getDataInfo("buff")			--buff:active(base.target_buff_id, base.quality, level)			--buff:afterActiveBuff()            BuffMgr.createFactory(base.target_buff_id, base.quality, level,value,caster,tanlentlevel)			bBuff = true		end		step:init(caster, health, value, damage, id, level, bBuff)				--被击者被K.O后触法技能        RoleMgr.beKOcastSkill(value,caster,timer,durationTB[key] + BattleMgr.getConfig("bmc_baneling_duration"))	end	return trueend


--执行所有结果 damageResult：伤害结果
function talentMgr.excultAllResult(resultTb,trigger,caster,damageResult,defenser,skillLevel,skillBaseInfo)
    local pResult = nil 
    for k,result in pairs(resultTb) do
        local pRet,extraParam = result:executResult(caster,defenser,damageResult,skillLevel,skillBaseInfo)
        --最终触发成功
        if pRet then 
            pResult = trigger:addConfig("trigger_times_index", 1)
            pResult = pResult or true
        end 
    end 

    return pResult
end 
--event: 事件类型
--每回合开始时触发             RoundBegin
--每次翻开格子的时候触发         OpenGrid
--每次普通攻击时触发         CommonAttack
--每次被普通攻击时触发         CommonAttack
--角色濒死                     onDying
--每次释放技能之前              onBeforeCastSkill
--damageResult ：被击打时用到（其他传nil），用于做限制闪避  --defenser 防御者 偷换技能 被用到 Skilllevel 技能等级(篡改ID时才有值)
function talentMgr.excultOnEvent(caster,event,damageResult,defenser,Skilllevel)
    Skilllevel = Skilllevel or 0

    local specialResults = nil 
    --local tltb = ModelPlayer.getPlayerTalent()

    local tltb = caster:getConfig("role_talent") or {}
    --param
    local remainlife = caster:getDataInfo("attr"):remianRate("life")    --当前生命
    local curRoundIndex = FightDateCache.getData("fb_round_count")

    for key,talent in pairs(tltb) do
         local trigger = talent:getConfig("talent_trigger_Info")
         local triggerType = trigger:getConfig("trigger_type")
         local resultTb = talent:getConfig("talent_result_tb")
         local pRet = false
         if event == "onDying" then 
            pRet = trigger:isHappennedOnDie()  
            specialResults = pRet
         elseif event == "RoundBegin" then 
            pRet = trigger:isHappennedOnRoundBegin(remainlife,curRoundIndex,caster)
            specialResults = pRet
         elseif  event == "OpenGrid" then 
            pRet = trigger:isHappennedOnGridOpen()
         elseif  event == "CommonAttack" then 
            pRet = trigger:isHappennedCommonAttack()
         elseif  event == "BeCommonAttack" then 
            pRet = trigger:isHappennedBeCommonAttack()
         elseif  event == "BeCommonAttackBefore" then 
            pRet = trigger:isHappennedBeCommonAttackBefore()
         --elseif  event ==  "onBeforeCastSkill" then --特殊处理了
           -- Log(trigger)
            --pRet = trigger:isHappennedOnBeforeCastSkill()
         end 

         if pRet then 
            talentMgr.excultAllResult(resultTb,trigger,caster,damageResult,defenser,Skilllevel,nil)
         end 
    end
    return specialResults
end 


function talentMgr.BeforeCastSkill(caster,defenser,Skilllevel,skillBaseInfo)
    local tltb = caster:getConfig("role_talent") or {}
    local pRet = false
    local pResult = nil 

    for key,talent in pairs(tltb) do
        local trigger = talent:getConfig("talent_trigger_Info")
        local resultTb = talent:getConfig("talent_result_tb")


        pRet = trigger:isHappennedOnBeforeCastSkill(skillBaseInfo.skills_typelist)

        if pRet then 
            pResult = talentMgr.excultAllResult(resultTb,trigger,caster,nil,defenser,Skilllevel,skillBaseInfo)
        end 
    end 

    return pResult
end 


--endregion
