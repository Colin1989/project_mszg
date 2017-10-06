----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-23
-- Brief:	公告逻辑
----------------------------------------------------------------------
NoticeLogic = {}
local mIsBroading = false			-- 是否正在播放
----------------------------------------------------------------------
-- 重设
NoticeLogic.reset = function()
	MessageMgr.init(30)
	mIsBroading = false
end
----------------------------------------------------------------------
-- 设置正在播放
NoticeLogic.setBroading = function(broading)
	mIsBroading = broading or false
end
----------------------------------------------------------------------
-- 是否正在播放
NoticeLogic.isBroading = function()
	return mIsBroading
end
----------------------------------------------------------------------
-- 获取历史记录
NoticeLogic.getHistory = function()
	local historyTable = {}
	for key, val in pairs(MessageMgr.getHistoryMsg()) do
		if "mt_chat_notice_other" == NoticeLogic.checkType(val) then
			if false == ChatLogic.isShield(val.data.speaker_id) then
				table.insert(historyTable, val)
			end
		else
			table.insert(historyTable, val)
		end
	end
	return historyTable
end
----------------------------------------------------------------------
-- 获取公告
NoticeLogic.popNotice = function()
	return MessageMgr.popMsg()
end
----------------------------------------------------------------------
-- 插入系统公告
NoticeLogic.pushSystemNotice = function(priority, msgData, repeatTimes)
	local msgPriority = tonumber(priority) or 2
	local msgType = 3
	if msgPriority >= 2 then
		msgPriority = 2
		msgType = (tonumber(priority) or 2) - 1
	end
	MessageMgr.insertMsg(msgPriority, msgType, tonumber(repeatTimes) or 1, msgData)
	EventCenter_post(EventDef["ED_POST"])
end
----------------------------------------------------------------------
-- 插入普通公告
NoticeLogic.pushNormalNotice = function(msgData, repeatTimes)
	MessageMgr.insertMsg(1, 3, tonumber(repeatTimes) or 1, msgData)
	EventCenter_post(EventDef["ED_POST"])
end
----------------------------------------------------------------------
-- 插入游戏公告
NoticeLogic.pushGameNotice = function(msgData)
	MessageMgr.insertMsg(1, 2, 1, msgData, 1)
	EventCenter_post(EventDef["ED_POST"])
end
----------------------------------------------------------------------
-- 插入聊天公告
NoticeLogic.pushChatNotice = function(msgData)
	MessageMgr.insertMsg(1, 1, 1, msgData)
	EventCenter_post(EventDef["ED_POST"])
end
----------------------------------------------------------------------
-- 判断消息类型
NoticeLogic.checkType = function(msg)
	local priority, msgtype, data = msg.priority, msg.msgtype, msg.data
	if 2 == priority then					-- 系统公告
		return "mt_sys_notice"
	elseif 1 == priority then
		if 3 == msgtype then				-- 普通公告
			return "mt_normal_notice"
		elseif 2 == msgtype then			-- 游戏公告
			return "mt_game_notice"
		elseif 1 == msgtype then			-- 聊天信息
			if ModelPlayer.getId() == data.speaker_id then		-- 自己说的话
				return "mt_chat_notice_self"
			else												-- 别人说的话
				return "mt_chat_notice_other"
			end
		end
	end
	return "mt_normal_notice"
end
----------------------------------------------------------------------
-- 获取消息内容
NoticeLogic.getContent = function(msg)
	local noticeType = NoticeLogic.checkType(msg)
	-- 聊天内容
	if "mt_chat_notice_self" == noticeType or "mt_chat_notice_other" == noticeType then
		return GameString.get("PUBLIC_LM_BRACKET")..msg.data.speaker..GameString.get("PUBLIC_RM_BRACKET")..msg.data.msg
	end
	-- 公告内容
	if "mt_sys_notice" == noticeType then
		return GameString.get("CHAT_SYSTEM")..msg.data
	end
	return GameString.get("CHAT_NOTICE")..msg.data
end
----------------------------------------------------------------------

