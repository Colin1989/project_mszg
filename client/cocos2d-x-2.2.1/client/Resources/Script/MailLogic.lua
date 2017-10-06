----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-09
-- Brief:	网络逻辑
----------------------------------------------------------------------
local mEmailList = {}		-- 邮件列表
local mEmailId = nil		-- 上次领取的邮件
MailLogic = {}
----------------------------------------------------------------------
-- 删除邮件
local function removeEmail(emailId)
	if nil == emailId then
		return
	end
	for key, val in pairs(mEmailList) do
		if emailId == val.id then
			table.remove(mEmailList, key)
			break
		end
	end
	EventCenter_post(EventDef["ED_EMAIL_LIST"], false)
end
----------------------------------------------------------------------
-- 插入邮件
local function insertMail(emailInfo)
	if nil == emailInfo then
		return
	end
	local endTime = emailInfo.end_time
	if true == SystemTime.isEnd(endTime) then
		return
	end
	for key, val in pairs(mEmailList) do
		if emailInfo.id == val.id then
			return
		end
	end
	table.insert(mEmailList, emailInfo)
	local function emailEndCF()
		removeEmail(emailInfo.id)
	end
	SystemTime.createDateTimer(endTime.year, endTime.month, endTime.day, endTime.hour, endTime.minute, endTime.second, emailEndCF)
end
----------------------------------------------------------------------
-- 处理通知邮件列表网络消息事件
local function handleNotifyEmailList(packet)
	mEmailList = {}
	for key, val in pairs(packet.emails) do
		insertMail(val)
	end
	EventCenter_post(EventDef["ED_EMAIL_LIST"], false)
end
----------------------------------------------------------------------
-- 处理通知添加邮件网络消息事件
local function handleNotifyEmailAdd(packet)
	insertMail(packet.new_email)
	EventCenter_post(EventDef["ED_EMAIL_LIST"], false)
end
----------------------------------------------------------------------
-- 处理通知领取邮件网络消息事件
local function handleNotifyGetEmailAttachmentsResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		removeEmail(mEmailId)
		success = true
	end
	mEmailId = nil
	EventCenter_post(EventDef["ED_EMAIL_LIST"], success)
end
----------------------------------------------------------------------
-- 请求领取邮件
MailLogic.requestGetEmailAttachments = function(emailId)
	mEmailId = emailId
	local req = req_get_email_attachments()
	req.email_id = emailId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_get_email_attachments_result"])
end
----------------------------------------------------------------------
-- 清除邮件数据
MailLogic.clearData = function()
	mEmailList = {}
	mEmailId = nil
end
----------------------------------------------------------------------
-- 获取邮件
MailLogic.getEmail = function()
	return mEmailList[1]
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_email_list"], notify_email_list, handleNotifyEmailList)
NetSocket_registerHandler(NetMsgType["msg_notify_email_add"], notify_email_add, handleNotifyEmailAdd)
NetSocket_registerHandler(NetMsgType["msg_notify_get_email_attachments_result"], notify_get_email_attachments_result, handleNotifyGetEmailAttachmentsResult)

