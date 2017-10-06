----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：新手引导管理器
----------------------------------------------------------------------
require "RichText"
require "GuideView"
require "GuideUIEngine"
require "GuideBattleEngine"
require "GuideConfigForce"
require "GuideConfigUnforce"

-- 新手引导组
local mGuideHandleGroup = 
{
	GuideForce_ShowStory,
	GuideForce_EnterCopy_1_1,
	GuideForce_BaseBattle,
	GuideForce_EnterCopy_1_2,
	GuideForce_UseAddBloodSkill,
	GuideForce_DivineSkillFrag,
	GuideForce_DivineSkillUnlock,
	GuideForce_DivineSkillEquip,
	
	GuideForce_EnterCopy_1_3,
	GuideForce_UseGroupAttackSkill,
	GuideForce_DressEquip,
	GuideForce_EnterCopy_1_4,
	-- 指引装备强化
	GuideUnforce_ClickForgeBuild,
	GuideUnforce_ClickForgeStrengthen,
	-- 指引选择援军
	GuideUnforce_SelectAssistance,
	GuideUnforce_UseAssistanceSkill,
	-- 指引进入精英副本
	GuideUnforce_ClickMissionBuild,
	GuideUnforce_ClickJYCopyTag,
	GuideUnforce_ClickJYCopyGroup_1,
	GuideUnforce_ClickJYCopyGroup_1_1,
	GuideUnforce_ClickSureEnterJYCopy_1_1,
	-- 指引使用自动战斗
	GuideUnforce_ClickAutoFight,
	-- 指引技能升级
	GuideUnforce_ClickInscription_build,
	GuideUnforce_ClickSkill,
	GuideUnforce_ClickSkillUpGrade,
	-- 指引提升英雄潜能
	GuideUnforce_ClickPublicBuild,
	GuideUnforce_ClickRolePotent,
	GuideUnforce_ClickPotentUpgrade,
	-- 指引装备晋阶
	GuideUnforce_ClickForgeBuildAdvance,
	GuideUnforce_ClickForgeAdvance,
	GuideUnforce_ClickStartAdvance,
	-- 学会进入挑战BOSS入口
	GuideUnforce_ClickActivityBuildForBoss,
	GuideUnforce_ClickBossActivity,
	GuideUnforce_ClickGetStoneBtn,
	GuideUnforce_ClickBossCopy_1,
	GuideUnforce_ClickSureEnterBossCopy_1,
	-- 学会技能进阶
	GuideUnforce_ClickInscription_build_advance,
	GuideUnforce_ClickSkill_advance,
	GuideUnforce_ClickSkillAdvance,
	-- 指引如何进行训练赛
	GuideUnforce_ClickJJCBuildForTrain,
	GuideUnforce_ClickGameTrain,
	GuideUnforce_PointToGameTrainList,
	-- 指引宝石镶嵌
	GuideUnforce_ClickForgeBuildGemInlay,
	GuideUnforce_ClickGemTag,
	GuideUnforce_ClickGemGrid,
	GuideUnforce_ClickGemInlay,
	-- 指引如何进行排位赛
	GuideUnforce_ClickJJCBuildForRank,
	GuideUnforce_ClickGameRank,
	GuideUnforce_PointToGameRankList,
	-- 指引进入魔塔入口
	GuideUnforce_ClickActivityBuildForTower,
	GuideUnforce_ClickTowerActivity,
	GuideUnforce_ClickEnterTower,
	-- 指引提升英雄天赋
	-- GuideUnforce_ClickPublicBuildTalent,
	-- GuideUnforce_ClickRoleTalent,
	-- GuideUnforce_ChooseRoleTalent,
	-- 指引如何进行分组赛
	-- GuideUnforce_ClickJJCBuildForLadder,
	-- GuideUnforce_ClickLadderMatch,
	-- GuideUnforce_ClickLadderMatchFight,
}

---------------------------------------------------------------------------------
----------------------------------新手核心模块-----------------------------------
---------------------------------------------------------------------------------
GuideMgr = {}
local mGuideProgress = {}		-- 新手引导进度表,有对应的ID则被引导过
local mGuideEngine = nil		-- 当前的引导引擎
local mGroupId = nil			-- 当前引导组id
local mInitFlag = false			-- 初始化标识
local mUIConditionTable = {}	-- 界面触发条件数组

-- 判断引导组是否已在服务端保存
local function isGroupExecute(groupId)
	--控制新手的开启
	--if true then return true end
	for key, val in pairs(mGuideProgress) do
		if groupId == val then
			return true
		end
	end
	return false
end

-- 引导组初始化
local function initGroup(groupId, isExecuteFlag)
	local handle = mGuideHandleGroup[groupId]
	handle.id = groupId					-- 组id
	handle.isExecute = isExecuteFlag	-- 是否已被执行
	-- 设置关联组状态
	if false == isExecuteFlag and handle.relate_guide then
		handle.relate_guide.isExecute = false
	end
end

-- 触发开始执行引导组
local function onTrigger(groupId, condition)
	if mGuideEngine then
		return false
	end
	local preHandle = mGuideHandleGroup[groupId - 1]	-- 前一组
	local handle = mGuideHandleGroup[groupId]			-- 当前组
	if nil == preHandle or preHandle.isExecute then
		if false == handle.isExecute then
			handle.guideStart(condition)
			mGroupId = groupId
			TipFunction.setTip(nil)
			return true
		end
	end
	return false
end

-- 插入界面条件数组
local function insertUIConditionTable(uiCondition)
	if string.len(uiCondition) < 3 or "ui_" ~= string.sub(uiCondition, 1, 3) then
		return
	end
	for key, val in pairs(mUIConditionTable) do
		if uiCondition == val then
			return
		end
	end
	table.insert(mUIConditionTable, uiCondition)
end

-- 删除界面条件数组(从末尾开始删除)
local function removeUIConditionTable(lastIndex)
	if 0 == lastIndex then
		mUIConditionTable = {}
		return
	end
	for i=lastIndex, #mUIConditionTable do
		mUIConditionTable[i] = nil
	end
end

-- 根据界面条件数组触发
local function triggerByUICondition()
	for i=#mUIConditionTable, 1, -1 do
		if true == GuideMgr.onUI(mUIConditionTable[i]) then
			cclog("+++++ ui condition: "..mUIConditionTable[i])
			removeUIConditionTable(i)
			return
		end
	end
	removeUIConditionTable(0)
end

-- 判断引导组是否已执行
function GuideMgr.checkProgress(guideGroup)
	for key, val in pairs(mGuideProgress) do
		if guideGroup == mGuideHandleGroup[val] then
			return true
		end
	end
	return false
end

-- 保存新手流程
function GuideMgr.save(groupId)
	if 0 == groupId then
		return
	end
	mGuideHandleGroup[groupId].isExecute = true
	requestSetTutorialProgress(groupId)
end

-- 设置引导引擎
function GuideMgr.setGuideEngine(engine)
	mGuideEngine = engine
	EventCenter_post(EventDef["ED_GUIDE_GROUP"], nil ~= engine)
end

-- 获取是引导状态
function GuideMgr.guideStatus()
	if nil == mGuideEngine then
		return 0	-- 非引导状态
	end
	if "function" == type(mGuideEngine.isForce) and mGuideEngine.isForce() then
		return 1	-- 强制引导状态
	end
	return 2		-- 非强制引导状态
end

-- 进入新手引导
function GuideMgr.onEnter()
	mInitFlag = true
	for key, value in pairs(mGuideHandleGroup) do
		initGroup(key, isGroupExecute(key))
	end
end

-- 退出新手引导
function GuideMgr.onExit()
	if mGuideEngine then
		mGuideEngine.guideEnd()
		mGuideEngine = nil
	end
	mInitFlag = false
	removeUIConditionTable(0)
end

-- 参数解析
function GuideMgr.parseParamer(str)
	local newstr = string.gsub(str, "%s+", "")
	local strTB = {}
	for key, val in string.gmatch(newstr, "([A-Za-z0-9_.]*)([,=]?)") do
		if key ~= "" then
			table.insert(strTB, key)
		end
	end
	local newTB = {}
	local idx = 1
	local total = #strTB
	while true do
		if idx + 1 > total then
			break
		end
		newTB[strTB[idx]] = strTB[idx + 1]
		idx = idx + 2
	end
	return newTB
end

---------------------------------------------------------------------------------
----------------------------------新手监听模块-----------------------------------
---------------------------------------------------------------------------------

-- 监听某条消息事件
function GuideMgr.onMessage(msg, param)
	if nil == mGuideEngine then
		return
	end
	mGuideEngine.onMessage(msg, param)
	insertUIConditionTable(msg)
end

-- 监听打开某个界面,uiCondition:自定义界面名称
function GuideMgr.onUI(uiCondition)
	if false == mInitFlag then
		return false
	end
	for key, value in pairs(mGuideHandleGroup) do
		if value.ui_condition then
			for k, v in pairs(value.ui_condition) do
				if uiCondition == v and CopyDelockLogic.judgeYNEnterById(value.copy_id) and onTrigger(key, uiCondition) then
					insertUIConditionTable(uiCondition)
					return true
				end
			end
		end
	end
	return false
end

-- 监听进入某个副本,copyId:副本id
function GuideMgr.onBattle(copyId)
	if false == mInitFlag then
		return false
	end
	if copyId == GuideForce_Preview.copy_id then
		GuideForce_Preview.guideStart()
		return true
	end
	for key, value in pairs(mGuideHandleGroup) do
		local guideCopyId = value.copy_id or 1
		if nil == value.ui_condition and (copyId == guideCopyId or 1 == guideCopyId) and onTrigger(key, copyId) then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------------------
----------------------------------新手网络模块-----------------------------------
---------------------------------------------------------------------------------

-- 请求设置新手教程进度
function requestSetTutorialProgress(groupId)
	cclog("guide mgr on save group id: "..groupId)
	local req = req_set_tutorial_progress()
	req.progress = groupId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_set_tutorial_progress_result"])
end

-- 处理通知新手教程进度网络消息事件
local function handleNotifyTutorialProgress(packet)
	cclog("guide mgr on tutorial progres list: ")
	for key, value in pairs(packet.progress) do
		cclog("guide mgr on tutorial progres key: "..key..", value: "..value)
	end
	mGuideProgress = packet.progress
	GuideMgr.onEnter()
end

-- 处理设置新手教程进度网络消息事件
local function handleNotifySetTutorialProgressResult(packet)
	if common_result["common_success"] == packet.result then
		table.insert(mGuideProgress, mGroupId)
		triggerByUICondition()
	else
		removeUIConditionTable(0)
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_tutorial_progress"], notify_tutorial_progress, handleNotifyTutorialProgress)
NetSocket_registerHandler(NetMsgType["msg_notify_set_tutorial_progress_result"], notify_set_tutorial_progress_result, handleNotifySetTutorialProgressResult)








