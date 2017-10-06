----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-12-31
-- 描述：网络帮助模块
----------------------------------------------------------------------
require "NetSocket"
local MIN_STEP_NUM = 1							-- 最小步进值
local MAX_STEP_NUM = 255						-- 最大步进值
local mClientStep = MIN_STEP_NUM				-- 客户端步进值
local mServerStep = MIN_STEP_NUM				-- 服务端步进值
local mLastRecvServerStep = MIN_STEP_NUM		-- 断线前收到的最后一条服务端步进值
local mKeepConnect = false						-- 当前是否保持和服务端连接
local mHeartbeatTimer = nil						-- 心跳定时器
local mDisconnectTimer = nil					-- 断线定时器
local mRecvMsgId = 0							-- 根据此消息id显示网络转圈和隐藏网络转圈
local mMsgQueue = {}							-- 消息队列
local mMsgQueueBackup = {}						-- 消息队列备份
local mConnectFlag = false						-- 连接标识
local mCheckVersion = false						-- 是否已经版本验证
NetHelper = {}
----------------------------------------------------------------------
-- 计算客户端步进值
local function calcClientStep()
	local step = mClientStep
	mClientStep = mClientStep + 1
	if mClientStep > MAX_STEP_NUM then
		mClientStep = MIN_STEP_NUM
	end
	return step
end
----------------------------------------------------------------------
-- 移除已接收消息
local function removeMsg(msgQueue, clientStep)
	local removeCount = 0
	local findFlag = false
	for key, val in pairs(msgQueue) do
		removeCount = removeCount + 1
		if clientStep == val.clientStep then
			findFlag = true
			break
		end
	end
	if true == findFlag then
		for i=1, removeCount do
			table.remove(msgQueue, 1)
		end
	end
end
----------------------------------------------------------------------
-- 插入消息队列
local function insertMsgQueue(clientStep, msgStruct, recvMsgId)
	local msg = {}
	msg.clientStep = clientStep
	msg.msgStruct = msgStruct
	msg.recvMsgId = recvMsgId
	msg.sendTime = system_gettime()
	table.insert(mMsgQueue, msg)
end
----------------------------------------------------------------------
-- 移除消息队列
local function removeMsgQueue(clientStep)
	if nil == clientStep then
		mMsgQueue = {}
		return
	end
	removeMsg(mMsgQueue, clientStep)
end
----------------------------------------------------------------------
-- 获取消息队列头
local function getMsgQueueHead()
	if 0 == #mMsgQueue then
		return nil
	end
	return mMsgQueue[1]
end
----------------------------------------------------------------------
-- 备份消息队列
local function backupMsgQueue()
	mMsgQueueBackup = mMsgQueue
	mMsgQueue = {}
end
----------------------------------------------------------------------
-- 发送消息队列
local function sendMsgQueue(clientStep)
	removeMsg(mMsgQueueBackup, clientStep)
	for key, val in pairs(mMsgQueueBackup) do
		NetHelper.sendAndWait(val.msgStruct, val.recvMsgId)
	end
end
----------------------------------------------------------------------
-- 断线提示
local function showDisconnectTip()
	if true == mCheckVersion then
		NetReConnectLayer.show()
	else
		Toast.show(GameString.get("NETWORK_STR_01"))
	end
end
----------------------------------------------------------------------
-- 强制返回开始界面
function NetHelper.returnStartUI(showStr)
	NetHelper.close()
	UIManager.destroyAllUI()
	UIManager.begin(false)
    UIManager.setAllUIEnabled(true)
	Toast.show(showStr)
end
----------------------------------------------------------------------
-- 断开服务器
function NetHelper.close()
	mClientStep = MIN_STEP_NUM
	mServerStep = MIN_STEP_NUM
	mLastRecvServerStep = MIN_STEP_NUM
	mKeepConnect = false
	if mHeartbeatTimer then
		mHeartbeatTimer.stop(false)
		mHeartbeatTimer = nil
	end
	if mDisconnectTimer then
		mDisconnectTimer.stop(false)
	end
	mRecvMsgId = 0
	mMsgQueue = {}
	mMsgQueueBackup = {}
	mConnectFlag = false
	mCheckVersion = false
	NetSocket_close()
	NetSendLoadLayer.dismiss()
	ClearTimer()
	-- 清除本地缓存服务端数据
	LuaAction.onExit()
	GuideMgr.onExit()
	FightMgr.onExit()
	FightLoading.onExit()
	FightResLoader.cleanupRes()
	ModelPlayer.resetPlayerInfos()				-- 清除玩家数据
	CopyDelockLogic.clearData()					-- 清除副本解锁数据
	CopyDateCache.clear()						-- 清除副本数据
	AssistanceLogic.setDonorInfo(nil)			-- 清除援军数据
	LayerGameRank.purge()						-- 清除竞技场推送消息数据
	LayerRankLists.purge()						-- 清除排行榜数据
	LayerBless.purge()							-- 清除祝福列表
	LayerFriendList.purge()						-- 清除好友界面信息
	FriendDataCache.purgeInfo()					-- 清除好友列表信息
	NoticeLogic.reset()							-- 清除公告信息
	LayerInviteCodeNewFriend.purge()			-- 清除邀请码界面信息
	TalentLogic.clearData()						-- 清除天赋数据
	DisResLogic.destroy()						-- 清除打折限购数据
	MailLogic.clearData()						-- 清除邮件数据
	LayerMainEnter.setReqChallengeFlage(false)	-- 清除竞技场提示气泡
	--
	EventCenter_post(EventDef["ED_CLEAR_DATA"])
end
----------------------------------------------------------------------
-- 连接服务器
function NetHelper.connect(host, port, crypto)
	if true == mConnectFlag then
		return
	end
	mConnectFlag = true
	mLastRecvServerStep = mServerStep
	local function connectCF(tm)
		mConnectFlag = false
		if true == mKeepConnect then
			backupMsgQueue()
			mClientStep = MIN_STEP_NUM
			-- 心跳定时器
			if mHeartbeatTimer then
				mHeartbeatTimer.stop(false)
				mHeartbeatTimer = nil
			end
			mHeartbeatTimer = CreateTimer(1, 3005, nil, function(tm) showDisconnectTip() end)
			-- 断线定时器
			if mDisconnectTimer then
				mDisconnectTimer.stop(false)
				mDisconnectTimer = nil
			end
			mDisconnectTimer = CreateTimer(0.01, 0, 
				function(tm)
					local msgHead = getMsgQueueHead()
					if nil == msgHead then
						return
					end
					if system_gettime() - msgHead.sendTime >= 10 then
						showDisconnectTip()
					end
				end,
			nil).start()
			--
			NetReConnectLayer.hide()
			NetHelper.checkVersion()
		else
			showDisconnectTip()
		end
	end
	-- 连接定时器
	CreateTimer(0.3, 3, 
		function(tm)
			NetSocket_close()
			mKeepConnect = NetSocket_connect(host, port, 0, function() showDisconnectTip() end, 1 == tonumber(crypto) and true or false)
			if true == mKeepConnect then
				tm.stop()
				connectCF(tm)
			end
		end,
		connectCF
	).start(true)
end
----------------------------------------------------------------------
-- 发送消息
function NetHelper.sendAndWait(msgStruct, recvMsgId)
	if false == mKeepConnect then
		if mDisconnectTimer then
			mDisconnectTimer.stop(false)
			mDisconnectTimer = nil
		end
		showDisconnectTip()
		return
	end
	if recvMsgId and 0 ~= recvMsgId then
		mRecvMsgId = recvMsgId
		NetSendLoadLayer.show()
	end
	local clientStep = calcClientStep()
	insertMsgQueue(clientStep, msgStruct, recvMsgId)
	if false == NetSocket_send(msgStruct, mServerStep, clientStep) then
		if mDisconnectTimer then
			mDisconnectTimer.stop(false)
			mDisconnectTimer = nil
		end
		showDisconnectTip()
	end
end
----------------------------------------------------------------------
-- 版本验证
function NetHelper.checkVersion()
	local req = req_check_version()
	req.version = get_proto_version()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_check_version_result"])
end
----------------------------------------------------------------------
-- 登录检查
function NetHelper.loginCheck()
	local req = req_login_check()
	req.uid = ChannelProxy.getUid()
	req.token = ChannelProxy.getToken()
	NetHelper.sendAndWait(req, NetMsgType["msg_notifu_login_check_result"])
end
----------------------------------------------------------------------
-- 发送重连
function NetHelper.sendReconnect()
	local req = req_game_reconnect()
	req.uid = ChannelProxy.getUid()
	req.token = ChannelProxy.getToken()
	req.role_id = ModelPlayer.getId()
	req.last_recv_stepnum = mLastRecvServerStep
	cclog("send game reconnect, last recv stepnum: "..req.last_recv_stepnum)
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_reconnect_result"])
end 
----------------------------------------------------------------------
-- 处理接收消息
local function handleReceive(msgId, serverStep, clientStep)
	if msgId == mRecvMsgId then
		mRecvMsgId = 0
		NetSendLoadLayer.dismiss()
	end
	mServerStep = serverStep
	removeMsgQueue(clientStep)
end
----------------------------------------------------------------------
-- 处理网络心跳
local function handleNotifyHeartbeat(packet)
	if mHeartbeatTimer then
		mHeartbeatTimer.stop(false)
		if true == mKeepConnect then
			mHeartbeatTimer.start()
		end
	end
end
----------------------------------------------------------------------
-- 处理网络关闭
TOAST_FLAG = false
local function handleNotifySocketClose(packet)
	removeMsgQueue(nil)
	local str = GameString.get("NETWORK_STR_03")
	if TOAST_FLAG then
		TOAST_FLAG = false
		str = ""
	end
	NetHelper.returnStartUI(str)
end
----------------------------------------------------------------------
-- 处理重复登录
local function handleNotifyRepeatLogin(packet)
	removeMsgQueue(nil)
	NetHelper.returnStartUI(GameString.get("NETWORK_STR_04"))
end
----------------------------------------------------------------------
-- 处理版本验证
local function handleNotifyCheckVersionResult(packet)
	mCheckVersion = true
	if common_result["common_success"] == packet.result then
		EventCenter_post(EventDef["ED_CHECK_VERSION"], true)
	else
		removeMsgQueue(nil)
		NetHelper.returnStartUI(GameString.get("NETWORK_STR_05"))
	end
end
----------------------------------------------------------------------
-- 处理重连结果
local function handleNotifyReconnectResult(packet)
	if register_result["register_success"] == packet.result then
		cclog("game reconnect result, last recv stepnum: "..packet.last_recv_stepnum)
		sendMsgQueue(packet.last_recv_stepnum)
		Toast.show(GameString.get("NETWORK_STR_02"))
		EventCenter_post(EventDef["ED_RECONNECT"])
	else
		showDisconnectTip()
	end
end
----------------------------------------------------------------------
-- 注册网络消息事件
NetSocket_registerHandler(0, nil, handleReceive)
NetSocket_registerHandler(NetMsgType["msg_notify_heartbeat"], notify_heartbeat, handleNotifyHeartbeat)
NetSocket_registerHandler(NetMsgType["msg_notify_socket_close"], notify_socket_close, handleNotifySocketClose)
NetSocket_registerHandler(NetMsgType["msg_notify_repeat_login"], notify_repeat_login, handleNotifyRepeatLogin)
NetSocket_registerHandler(NetMsgType["msg_notify_check_version_result"], notify_check_version_result, handleNotifyCheckVersionResult)
NetSocket_registerHandler(NetMsgType["msg_notify_reconnect_result"], notify_reconnect_result, handleNotifyReconnectResult)

