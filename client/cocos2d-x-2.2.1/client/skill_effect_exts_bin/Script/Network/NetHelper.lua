----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-12-31
-- 描述：网络帮助模块
----------------------------------------------------------------------
require "NetSocket"
local mRecvMsgId = 0	-- 根据此消息id显示网络转圈和隐藏网络转圈
NetHelper = {}
-- 连接
function NetHelper.connect(host, port)
	return NetSocket_connect(host, port)
end
-- 关闭连接
function NetHelper.close()
	NetSocket_close()
end
-- 发送消息
function NetHelper.sendAndWait(msgStruct, recvMsgId)
	if recvMsgId and 0 ~= recvMsgId then
		mRecvMsgId = recvMsgId
		NetSendLoadLayer.show()
		-- TODO:比如显示转圈
	end
	NetSocket_send(msgStruct)
end
-- 接收特殊消息
function NetHelper.recv(recvMsgId)
	if recvMsgId == mRecvMsgId then
		mRecvMsgId = 0
		NetSendLoadLayer.dismiss()
	end
end
-- 注册消息事件
function NetHelper.registerHandler(msgId, msgStruct, msgHandler)
	NetSocket_registerHandler(msgId, msgStruct, msgHandler)
end
-- 取消注册消息事件
function NetHelper.unregisterHandler(msgId)
	NetSocket_unregisterHandler(msgId)
end
-- 注册特殊消息事件
NetHelper.registerHandler(0, nil, NetHelper.recv)


------------SL---------
function NetHelper.handleReceive()	
	--local recv, status,
end






