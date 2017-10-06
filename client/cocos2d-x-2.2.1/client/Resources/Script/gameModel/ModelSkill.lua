----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-14
-- Brief:	技能数据相关
----------------------------------------------------------------------
ModelSkill = {}
local mSkillPack = {}				-- 技能背包
local mTalentPack = {}				-- 天赋背包
local mFragPack = {}				-- 碎片背包
local mSkillGroupTable = {}			-- 技能组列表
local mSkillGroupIndex = 1			-- 技能组索引值
----------------------------------------------------------------------
-- 更新背包数据
local function updatePackData(packDataList, isDelete)
	-- sculpture_info 格式
	-- tb.temp_id = 0			-- 模板id
	-- tb.value = 0				-- 类型为1,2时:等级;类型为3时:数量
	-- tb.type = 0				-- 1:符文,2:天赋,3:碎片
	for key, val in pairs(packDataList) do
		local packKey = val.temp_id
		if true == isDelete then
			mSkillPack[packKey] = nil
			mTalentPack[packKey] = nil
			mFragPack[packKey] = nil
		else
			if sculpture_item_type["item_sculpture"] == val.type then
				if 0 == val.value then
					val.value = 1
				end
				mSkillPack[packKey] = val
			elseif sculpture_item_type["item_talent"] == val.type then
				if 0 == val.value then
					val.value = 1
				end
				mTalentPack[packKey] = val
			elseif sculpture_item_type["item_frag"] == val.type then
				mFragPack[packKey] = val
			end
		end
	end
end
----------------------------------------------------------------------
-- 处理通知技能信息网络消息事件
local function handleNotifySkillInfos(resp)
	if data_type["init"] == resp.type then
		mSkillPack = {}
		mTalentPack = {}
		mFragPack = {}
		updatePackData(resp.sculpture_infos, false)
	elseif data_type["append"] == resp.type then
		updatePackData(resp.sculpture_infos, false)
	elseif data_type["delete"] == resp.type then
		updatePackData(resp.sculpture_infos, true)
	elseif data_type["modify"] == resp.type then
		updatePackData(resp.sculpture_infos, false)
	end
	local data = {}
	data.updatetype = resp.type
	data.updateitems = resp.sculpture_infos
	EventCenter_post(EventDef["ED_UPDATE_SKILLPACK"], data)
end
----------------------------------------------------------------------
-- 处理通知技能组信息网络消息事件
local function handleNotifySkillGroupInfos(resp)
	for key, val in pairs(resp.groups) do
		local skillList = {}
		table.insert(skillList, val.id1)
		table.insert(skillList, val.id2)
		table.insert(skillList, val.id3)
		table.insert(skillList, val.id4)
		local groupItem = {}
		groupItem.index = val.index			-- 技能组索引值
		groupItem.skills = skillList		-- 技能id列表
		mSkillGroupTable[val.index] = groupItem
	end
	-- 初始3个技能组
	for i=1, 3 do
		if nil == mSkillGroupTable[i] then
			mSkillGroupTable[i] = {index = i, skills = {0, 0, 0, 0}}
		end
	end
end
----------------------------------------------------------------------
-- 获取技能背包
ModelSkill.getSkillPack = function()
	return CommonFunc_clone(mSkillPack)
end
----------------------------------------------------------------------
-- 获取天赋背包
ModelSkill.getTalentPack = function()
	return CommonFunc_clone(mTalentPack)
end
----------------------------------------------------------------------
-- 获取碎片背包
ModelSkill.getFragPack = function()
	return CommonFunc_clone(mFragPack)
end
----------------------------------------------------------------------
-- 获取技能
ModelSkill.getSkill = function(skillID)
	if nil == skillID then
		return nil
	end
	return CommonFunc_clone(mSkillPack[skillID])
end
----------------------------------------------------------------------
-- 获取技能等级
ModelSkill.getSkillLevel = function(skillID)
	if nil == skillID or nil == mSkillPack[skillID] then
		return 1
	end
	return mSkillPack[skillID].value
end
----------------------------------------------------------------------
-- 获取天赋
ModelSkill.getTalent = function(talentID)
	if nil == talentID then
		return nil
	end
	return CommonFunc_clone(mTalentPack[talentID])
end
----------------------------------------------------------------------
-- 获取天赋等级
ModelSkill.getTalentLevel = function(talentID)
	if nil == talentID or nil == mTalentPack[talentID] then
		return 1
	end
	return mTalentPack[talentID].value
end
----------------------------------------------------------------------
-- 获取碎片
ModelSkill.getFrag = function(fragID)
	if nil == fragID then
		return nil
	end
	return CommonFunc_clone(mFragPack[fragID])
end
----------------------------------------------------------------------
-- 获取碎片数量
ModelSkill.getFragCount = function(fragID)
	if nil == fragID or nil == mFragPack[fragID] then
		return 0
	end
	return mFragPack[fragID].value
end
----------------------------------------------------------------------
-- 设置技能组信息
ModelSkill.setSkillGroupInfo = function(groupIndex, pos, skillID)
	mSkillGroupTable[groupIndex].skills[pos] = skillID or 0
end
----------------------------------------------------------------------
-- 获取技能组列表
ModelSkill.getSkillGroupTable = function()
	return CommonFunc_clone(mSkillGroupTable)
end
----------------------------------------------------------------------
-- 设置技能组索引值
ModelSkill.setSkillGroupIndex = function(groupIndex)
	mSkillGroupIndex = groupIndex or 1
end
----------------------------------------------------------------------
-- 获取技能组(当前激活的组)
ModelSkill.getSkillGroup = function()
    if FightDateCache.getData("fd_copy_id") == FIRSTCOPYID then
        return CommonFunc_clone(FIRSTSKILLS)
	end

	return CommonFunc_clone(mSkillGroupTable[mSkillGroupIndex])
end
----------------------------------------------------------------------
-- 获取技能组(根据指定的组索引)
ModelSkill.getSkillGroupByIndex = function(groupIndex)
	return CommonFunc_clone(mSkillGroupTable[groupIndex])
end
----------------------------------------------------------------------
-- 获取技能在当前激活组的位置(组索引,位置)
ModelSkill.getSkillPosition = function(skillID)
	for key, val in pairs(mSkillGroupTable[mSkillGroupIndex].skills) do
		if 0 ~= skillID and skillID == val then
			return mSkillGroupIndex, key
		end
	end
	return 0, 0
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_infos"], notify_sculpture_infos, handleNotifySkillInfos)
NetSocket_registerHandler(NetMsgType["msg_notify_skill_groups_info"], notify_skill_groups_info, handleNotifySkillGroupInfos)

