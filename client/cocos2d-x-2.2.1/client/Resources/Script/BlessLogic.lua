----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-05
-- Brief:	祝福逻辑
----------------------------------------------------------------------
local mBlessBuff = {}			-- 当前祝福buff
mBlessBuff.benison_id = 0		-- 祝福id
mBlessBuff.time_left = 0		-- 祝福剩余时间
mBlessBuff.bless_type = 0		-- 祝福类型:0-没有,1-生命,2-攻击,3-速度,4-命中,5-暴击,6-闪避,7-韧性
local mBlessProInfo = nil		-- 祝福属性
local mBlessList = {}			-- 祝福列表
local mBlessStatus = {}			-- 祝福状态
local mNewDay = true			-- 新的一天
local mBlessTimer = nil			-- 祝福定时器
local mDailyTimerFlag = false

BlessLogic = {}
----------------------------------------------------------------------
local function handleClearData()
	mBlessBuff.benison_id = 0
	mBlessBuff.time_left = 0
	mBlessBuff.bless_type = 0
	mBlessTimer = nil
end
----------------------------------------------------------------------
-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
end
----------------------------------------------------------------------
-- 定时器触发回调
local function timerRunCF(tm)
	local leftTime = tm.getParam() - 1
	tm.setParam(leftTime)
	EventCenter_post(EventDef["ED_BLESS_TIMER_RUN"], leftTime)
end
----------------------------------------------------------------------
-- 定时器结束回调
local function timerOverCF(tm)
	mBlessBuff.benison_id = 0
	mBlessBuff.time_left = 0
	mBlessBuff.bless_type = 0
	mBlessTimer = nil
	EventCenter_post(EventDef["ED_BLESS_TIMER_OVER"])
end
----------------------------------------------------------------------
-- 处理通知角色祝福buff网络消息事件
local function handleNotifyRoleBlessBuff(packet)
	-- 保存数据
	mBlessBuff.benison_id = packet.benison_id
	mBlessBuff.time_left = packet.time_left
	if 0 == packet.benison_id then
		mBlessBuff.bless_type = 0
		mBlessProInfo = nil
	else
		local blessInfo = LogicTable.getBlessInfoById(packet.benison_id)
		mBlessProInfo = LogicTable.getBlessProInfoById(blessInfo.status_ids)
		mBlessBuff.bless_type = mBlessProInfo.attr_type
		--这个是为了防止两次的祝福id一样（不能只是说一样的情况）
		if mBlessTimer ~= nil then
			mBlessTimer.stop()
			timerOverCF()
			--结束时，已被清0，需要重新赋值
			mBlessBuff.benison_id = packet.benison_id
			mBlessBuff.time_left = packet.time_left
			mBlessBuff.bless_type = mBlessProInfo.attr_type
		end
	end
	--创建祝福定时器
	if packet.benison_id > 0 then
		if nil == mBlessTimer then
			mBlessTimer = CreateTimer(1, packet.time_left, timerRunCF, timerOverCF)
			mBlessTimer.setParam(packet.time_left)
			mBlessTimer.start()
		end
	end
	EventCenter_post(EventDef["ED_BLESS_BUFF"])
end
----------------------------------------------------------------------
-- 处理通知祝福列表网络消息事件
local function handleNotifyBenisonList(packet)
	mBlessList = packet.benison_list
	mBlessStatus = packet.benison_status
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	EventCenter_post(EventDef["ED_BENISON_LIST"])
end
----------------------------------------------------------------------
-- 处理通知刷新祝福列表网络消息事件
local function handleNotifyRefreshBenisonListResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	end
end
----------------------------------------------------------------------
-- 处理通知祝福网络消息事件
local function handleNotifyBlessResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	else
		cclog("激活失败")
	end
end
----------------------------------------------------------------------
-- 请求祝福列表
BlessLogic.requestBenisonList = function()
	local req = req_benison_list()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_benison_list"])
end
----------------------------------------------------------------------
-- 请求刷新祝福列表
BlessLogic.requestRefreshBenisonList = function()
	local req = req_refresh_benison_list()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_refresh_benison_list_result"])
end
----------------------------------------------------------------------
-- 请求祝福
BlessLogic.requestBless = function(benisonId)
	local req = req_bless()
	req.benison_id = benisonId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_bless_result"])
end
----------------------------------------------------------------------
-- 获取祝福buff
BlessLogic.getBlessBuff = function()
	return mBlessBuff
end
----------------------------------------------------------------------
-- 获取祝福数值
BlessLogic.getBlessValue = function(attrValues)
	if nil == mBlessProInfo then
		return attrValues
	end
	local attrTypes = {"life", "atk", "speed", "hit_ratio", "critical_ratio", "miss_ratio", "tenacity"}
	local originalValue = attrValues[attrTypes[mBlessProInfo.attr_type]]
	
	if 1 == mBlessProInfo.value_type then			-- 百分比
		local str = string.format("%s_add",attrTypes[mBlessProInfo.attr_type])
		if mBlessProInfo.attr_type == 5 or mBlessProInfo.attr_type == 6 then		--暴击、闪避
			attrValues[str] = transform_1(originalValue) + mBlessProInfo.value
		elseif mBlessProInfo.attr_type == 4 or mBlessProInfo.attr_type == 7 then	--韧性、命中
			attrValues[str] = transform_2(originalValue) + mBlessProInfo.value
		else
			originalValue = originalValue + math.floor(originalValue*mBlessProInfo.value/100)
		end
	elseif 2 == mBlessProInfo.value_type then		-- 固定数值	
		originalValue = originalValue + mBlessProInfo.value
	end
	attrValues[attrTypes[mBlessProInfo.attr_type]] = originalValue
	return attrValues
end
----------------------------------------------------------------------
-- 获取祝福列表
BlessLogic.getBlessList = function()
	return mBlessList
end
----------------------------------------------------------------------
-- 获取祝福状态
BlessLogic.getBlessStatus = function()
	return mBlessStatus
end
----------------------------------------------------------------------
-- 新的一天
BlessLogic.isNewDay = function()
	return mNewDay
end
----------------------------------------------------------------------
-- 设置新的一天
BlessLogic.setNewDay = function(newDay)
	 mNewDay = newDay
end
----------------------------------------------------------------------
-- 网络消息事件
NetSocket_registerHandler(NetMsgType["msg_notify_role_bless_buff"], notify_role_bless_buff, handleNotifyRoleBlessBuff)
NetSocket_registerHandler(NetMsgType["msg_notify_benison_list"], notify_benison_list, handleNotifyBenisonList)
NetSocket_registerHandler(NetMsgType["msg_notify_refresh_benison_list_result"], notify_refresh_benison_list_result, handleNotifyRefreshBenisonListResult)
NetSocket_registerHandler(NetMsgType["msg_notify_bless_result"], notify_bless_result, handleNotifyBlessResult)
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)
