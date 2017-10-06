----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-22
-- Brief:	技能逻辑
----------------------------------------------------------------------
SkillLogic = {}
local mSkillArray = {}		-- 技能养成数组(包括已解锁和未解锁)
----------------------------------------------------------------------
-- 更新技能养成数组
local function handleUpdateSkillpack(param)
	mSkillArray = SkillConfig.getSkillInfoArray(ModelPlayer.getRoleType())
	local skillPack = ModelSkill.getSkillPack()
	for key, val in pairs(mSkillArray) do
		mSkillArray[key].level = 1		-- 技能等级初始为1级
		for k, v in pairs(skillPack) do
			local skillInfo = SkillConfig.getSkillInfo(v.temp_id)
			-- 该组技能已解锁
			if skillInfo and val.skill_group == skillInfo.skill_group then
				mSkillArray[key] = skillInfo
				if 0 == v.value then
					mSkillArray[key].level = 1
				else
					mSkillArray[key].level = v.value
				end
				break
			end
		end
	end
end
----------------------------------------------------------------------
-- 处理通知技能解锁网络消息事件
local function handleNotifySkillUnlock(resp)
	local data = {}
	data.success = false
	data.temp_id = resp.temp_id
	if common_result["common_success"] == resp.result then
		TipModule.onNet("msg_notify_sculpture_unlock")
		data.success = true
	end
	EventCenter_post(EventDef["ED_SKILL_UNLOCK"], data)
end
----------------------------------------------------------------------
-- 处理通知技能升级网络消息事件
local function handleNotifySkillUpgrade(resp)
	local success = false
	if common_result["common_success"] == resp.result then
		success = true
	end
	EventCenter_post(EventDef["ED_SKILL_UPGRADE"], success)
end
----------------------------------------------------------------------
-- 处理通知技能晋阶网络消息事件
local function handleNotifySkillAdvance(resp)
	local data = {}
	data.success = false
	data.new_temp_id = resp.new_temp_id
	if common_result["common_success"] == resp.result then
		data.success = true
	end
	EventCenter_post(EventDef["ED_SKILL_ADVANCE"], data)
end
----------------------------------------------------------------------
-- 处理通知技能穿上网络消息事件
local function handleNotifySkillPuton(resp)
	local data = {}
	data.success = false
	data.group_index = resp.group_index
	data.position = resp.position
	data.temp_id = resp.temp_id
	if common_result["common_success"] == resp.is_success then
		TipModule.onNet("msg_notify_sculpture_puton")
		data.success = true
		ModelSkill.setSkillGroupInfo(resp.group_index, resp.position, resp.temp_id)
	end
	EventCenter_post(EventDef["ED_SKILL_PUTON"], data)
end
----------------------------------------------------------------------
-- 处理通知技能脱下网络消息事件
local function handleNotifySkillTakeoff(resp)
	local data = {}
	data.success = false
	data.group_index = resp.group_index
	data.position = resp.position
	if common_result["common_success"] == resp.is_success then
		data.success = true
		ModelSkill.setSkillGroupInfo(resp.group_index, resp.position, 0)
	end
	EventCenter_post(EventDef["ED_SKILL_TAKEOFF"], data)
end
----------------------------------------------------------------------
-- 处理通知改变技能组网络消息事件
local function handleNotifyChangeSkillGroup(resp)
	local data = {}
	data.success = false
    data.activate_group = resp.activate_group
	if common_result["common_success"] == resp.result then
		data.success = true
		ModelSkill.setSkillGroupIndex(resp.activate_group)
	end
	EventCenter_post(EventDef["ED_SKILL_GROUP_CHANGE"], data)
end
----------------------------------------------------------------------
-- 请求技能解锁
SkillLogic.requestSkillUnlock = function(skillID)
	local req = req_sculpture_unlock()
	req.temp_id = skillID
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sculpture_unlock"])
end
----------------------------------------------------------------------
-- 请求技能升级
SkillLogic.requestSkillUpgrade = function(skillID)
	local req = req_sculpture_upgrade()
	req.temp_id = skillID
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sculpture_upgrade"])
end
----------------------------------------------------------------------
-- 请求技能晋阶
SkillLogic.requestSkillAdvance = function(skillID)
	local req = req_sculpture_advnace()
	req.temp_id = skillID
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sculpture_advnace"])
end
----------------------------------------------------------------------
-- 请求技能穿上
SkillLogic.requestSkillPuton = function(groupIndex, pos, skillID)
	local req = req_sculpture_puton()
	req.group_index = groupIndex
	req.position = pos
	req.temp_id = skillID
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sculpture_puton"])
end
----------------------------------------------------------------------
-- 请求技能脱下
SkillLogic.requestSkillTakeoff = function(groupIndex, pos)
	local req = req_sculpture_takeoff()
	req.group_index = groupIndex
	req.position = pos
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sculpture_takeoff"])
end
----------------------------------------------------------------------
-- 请求选择技能组
SkillLogic.requestChangeSkillGroup = function(groupIndex)
	local req = req_change_skill_group()
	req.group_index = groupIndex
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_change_skill_group"])
end
----------------------------------------------------------------------
-- 获取技能养成数组
SkillLogic.getSkillArray = function(attributeTag)
	local skillArray = {}
	for key, val in pairs(mSkillArray) do
		if 4 == attributeTag and val.attribute_tag ~= 0 then
			table.insert(skillArray, val)
		elseif nil == attributeTag or attributeTag == val.attribute_tag then
			table.insert(skillArray, val)
		end
	end
	return skillArray
end
----------------------------------------------------------------------
-- 获取技能状态:1.可晋阶,2.可升级,3.已解锁(不可晋阶,不可升级),4.可解锁,5.不可解锁
SkillLogic.getSkillStatus = function(skillInfo)
	local skill = ModelSkill.getSkill(skillInfo.id)
	-- 未解锁
	if nil == skill then
		local fragCount = ModelSkill.getFragCount(skillInfo.unlock_need_id)
		if fragCount >= skillInfo.unlock_need_amount then
			return 4	-- 可解锁
		end
		return 5		-- 不可解锁
	end
	-- 已解锁
	local skillAdvanceInfo = SkillConfig.getSkillAdvanceInfo(skillInfo.advance_cost_id)
	if skillAdvanceInfo and skillAdvanceInfo.advanced_id > 0 then
		local fragCount = ModelSkill.getFragCount(skillAdvanceInfo.need_ids)
		if fragCount >= skillAdvanceInfo.need_amount then
			return 1	-- 可晋阶
		end
	end
	local skillLevel = skill.value
	if skillLevel < skillInfo.max_lev and skillLevel < ModelPlayer.getLevel() then
		local skillUpgradeInfo = SkillConfig.getSkillUpgradeInfo(skillInfo.upgrate_cost_id, skillLevel)
		if skillUpgradeInfo and skillUpgradeInfo.cost <= ModelPlayer.getGold() then
			return 2	-- 可升级
		end
	end
	return 3			-- 已解锁(不可晋阶,不可升级)
end
----------------------------------------------------------------------
-- 获取已解锁的技能组
SkillLogic.getUnlockSkillGroup = function()
	local unlockSkillGroup = {}
	for key, val in pairs(mSkillArray) do
		local status = SkillLogic.getSkillStatus(val)
		if 1 == status or 2 == status or 3 == status then
			table.insert(unlockSkillGroup, val.skill_group)
		end
	end
	return unlockSkillGroup
end
----------------------------------------------------------------------
-- 是否有可解锁,可晋阶的技能
SkillLogic.existUnlockAdvanceSkill = function()
	local existAttributeTag = {}
	for key, val in pairs(mSkillArray) do
		if val.attribute_tag > 0 then
			local status = SkillLogic.getSkillStatus(val)
			if 1 == status or 4 == status then
				existAttributeTag[val.attribute_tag] = true
			end
		end
	end
	return existAttributeTag
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_unlock"], notify_sculpture_unlock, handleNotifySkillUnlock)
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_upgrade"], notify_sculpture_upgrade, handleNotifySkillUpgrade)
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_advnace"], notify_sculpture_advnace, handleNotifySkillAdvance)
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_puton"], notify_sculpture_puton, handleNotifySkillPuton)
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_takeoff"], notify_sculpture_takeoff, handleNotifySkillTakeoff)
NetSocket_registerHandler(NetMsgType["msg_notify_change_skill_group"], notify_change_skill_group, handleNotifyChangeSkillGroup)
EventCenter_subscribe(EventDef["ED_UPDATE_SKILLPACK"], handleUpdateSkillpack, 100)

