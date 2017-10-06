----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-23
-- Brief:	聊天逻辑
----------------------------------------------------------------------
ChatLogic = {}
local mSpeakTimes = 0			-- 今日已发送的信息数
local mExtraTimes = 0			-- 玩家购买的信息数
local mChatFlag = false			-- 聊天标识
local mDailyTimerFlag = false
local mChatTimeTable = {}		-- 聊天时间表
local mShieldTable = {}			-- 屏蔽表
----------------------------------------------------------------------
-- 清除数据
local function handleClearData()
	mChatFlag = false
	mDailyTimerFlag = false
	mChatTimeTable = {}
	mShieldTable = {}
end
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	mSpeakTimes = 0
end
----------------------------------------------------------------------
-- 处理通知世界频道聊天信息网络消息事件
local function handleNotifyWorldChannelMsg(packet)
	if true == ChatLogic.isShield(packet.speaker_id) then
		return
	end
	local msgData = {}
	msgData.speaker_id = packet.speaker_id			-- 说话者id
	msgData.speaker = packet.speaker				-- 说话者昵称
	msgData.msg = packet.msg						-- 说话内容
	NoticeLogic.pushChatNotice(msgData)
end
----------------------------------------------------------------------
-- 处理通知我的世界聊天信息网络消息事件
local function handleNotifyMyWorldChatInfo(packet)
	mSpeakTimes = packet.speek_times
	mExtraTimes = packet.extra_times
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	-- 当上一条网络请求消息时聊天时,购买的信息数要加1
	if true == mChatFlag then
		mExtraTimes = mExtraTimes + 1
		EventCenter_post(EventDef["ED_MY_WORLD_CHAT_INFO"], mExtraTimes)
	end
end
----------------------------------------------------------------------
-- 处理通知在世界频道聊天结果网络消息事件
local function handleNotifyChatInWorldChannelResult(packet)
	mChatFlag = false
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
		-- 聊天次数逻辑
		if mSpeakTimes > CHAT_FREE_COUNT then
			mExtraTimes = mExtraTimes - 1
		end
		mSpeakTimes = mSpeakTimes + 1
		-- 保存聊天时间,上线30条
		if #mChatTimeTable >= 30 then
			table.remove(mChatTimeTable, 1)
		end
		table.insert(mChatTimeTable, system_gettime())
	end
	EventCenter_post(EventDef["ED_CHAT_IN_WORLD"], success)
end
----------------------------------------------------------------------
-- 处理通知角色详细信息网络消息事件
local function handleNotifyRoleDetailInfoResult(packet)
	local roleInfo = {}
	roleInfo.role_id = packet.role_id					-- 角色id
    roleInfo.nickname = packet.nickname					-- 角色昵称
    roleInfo.status = packet.status						-- 是否在线
    roleInfo.level = packet.level						-- 角色等级
    roleInfo.type = packet.type							-- 角色职业
    roleInfo.public = packet.public						-- 角色所在公会
    roleInfo.potence_level = packet.potence_level		-- 角色潜能等级
    roleInfo.advanced_level = packet.advanced_level		-- 角色晋阶等级
    roleInfo.sculptures = packet.sculptures				-- 角色技能
    roleInfo.equipments = packet.equipments				-- 角色装备
    roleInfo.battle_power = packet.battle_power			-- 角色战斗力
    roleInfo.military_lev = packet.military_lev			-- 角色军衔等级
    roleInfo.challenge_rank = packet.challenge_rank		-- 角色挑战排名
	EventCenter_post(EventDef["ED_ROLE_DETAIL_INFO"], roleInfo)
end
----------------------------------------------------------------------
-- 请求在世界频道中聊天
ChatLogic.requestChatInWorldChannel = function(msg)
	mChatFlag = true
	local req = req_chat_in_world_channel()
	req.msg = KeywordShield(msg)
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_chat_in_world_channel_result"])
end
----------------------------------------------------------------------
-- 请求获取角色详细信息
ChatLogic.requestGetRoleDetailInfo = function(roleId)
	local req = req_get_role_detail_info()
	req.role_id = roleId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_role_detail_info_result"])
end
----------------------------------------------------------------------
-- 获取玩家今日已发送的信息数
ChatLogic.getSpeakTimes = function()
	return mSpeakTimes
end
----------------------------------------------------------------------
-- 获取玩家已购买的信息数
ChatLogic.getExtraTimes = function()
	return mExtraTimes
end
----------------------------------------------------------------------
-- 获取玩家今日剩余的信息数
ChatLogic.getLeftTimes = function()
	local minNum = CHAT_FREE_COUNT
	if minNum > mSpeakTimes then
		minNum = mSpeakTimes
	end
	return CHAT_FREE_COUNT - minNum + mExtraTimes
end
----------------------------------------------------------------------
-- 发言频率限制
ChatLogic.limitChatRate = function()
	local totalCount = #mChatTimeTable
	if 0 == totalCount then
		return 0
	end
	-- 条件1.每次发言的时间间隔
	if system_gettime() - mChatTimeTable[totalCount] < CHAT_MIN_INTERVALS then
		return 1
	end
	-- 条件2.一段时间内可发言的次数
	local count = 0
	for key, val in pairs(mChatTimeTable) do
		if system_gettime() - val < CHAT_HOW_LONG_TIME then
			count = count + 1
		end
	end
	if count > CHAT_TIMES_LIMIT then
		return 2
	end
	return 0
end
----------------------------------------------------------------------
-- 是否被禁言
ChatLogic.isShutup = function()
	local roleStatus = ModelPlayer.getRoleStatus()
	if string.len(roleStatus) < 2 then
		return false
	end
	return "1" == string.sub(roleStatus, -2, -2)
end
----------------------------------------------------------------------
-- 角色id是否被屏蔽
ChatLogic.isShield = function(roleId)
	for key, val in pairs(mShieldTable) do
		if roleId == val then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 设置屏蔽角色id
ChatLogic.setShield = function(roleId)
	if true == ChatLogic.isShield(roleId) then
		return
	end
	table.insert(mShieldTable, roleId)
end
----------------------------------------------------------------------
-- 网络消息事件
NetSocket_registerHandler(NetMsgType["msg_notify_world_channel_msg"], notify_world_channel_msg, handleNotifyWorldChannelMsg)
NetSocket_registerHandler(NetMsgType["msg_notify_my_world_chat_info"], notify_my_world_chat_info, handleNotifyMyWorldChatInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_chat_in_world_channel_result"], notify_chat_in_world_channel_result, handleNotifyChatInWorldChannelResult)
NetSocket_registerHandler(NetMsgType["msg_notify_role_detail_info_result"], notify_role_detail_info_result, handleNotifyRoleDetailInfoResult)
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)

