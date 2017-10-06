----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-27
-- 描述：网络对接模块
----------------------------------------------------------------------
require "ByteArray"
require "NetEnumDef"
require "NetMsgType"
require "NetPacket"
require "mime"
----------------------------------------------------------------------
local mSocket = require("socket")		-- 套接字
local mClient = nil						-- 客户端网络对象
local HEAD_SIZE = 4						-- 包头大小,固定4个字节
local mReceiveLen = HEAD_SIZE			-- 当前接收长度
local mGetHead = true					-- 当前是否取包头
local mNetMsgHandlers = {}				-- 网络消息处理句柄
local MIN_PACKET_COUNT = 1				-- 发送包次数标识最小值[1-255]
local MAX_PACKET_COUNT = 255			-- 发送包次数标识最大值[1-255]
local PACKET_COUNT_SIZE = 1				-- 发送包次数标识为一个字节
local mPacketCount = MIN_PACKET_COUNT	-- 当前发送包次数标识
----------------------------------------------------------------------
-- 功  能：连接服务端
-- 参  数：host(string类型)-服务器ip地址;port(number类型)-端口号
-- 返回值：boolean
----------------------------------------------------------------------
function NetSocket_connect(host, port)
	if nil == mSocket then
		print("socket is nil ...")
		return false
	end
	local err = nil
	mClient, err = mSocket.connect(host, port)		-- 这里必须用.不能用:
	if nil == mClient then
		mSocket = nil
		if err then
			err = "["..err.."]"
		else
			err = ""
		end
		print("connect to host='"..host.."', port="..port.." failed "..err.." ...")
		return false
	end
	mClient:settimeout(0)
	print("connect to host='"..host.."', port="..port.." success ...")
	return true
end
----------------------------------------------------------------------
-- 功  能：关闭连接
-- 参  数：无
-- 返回值：无返回值
----------------------------------------------------------------------
function NetSocket_close()
	if nil ~= mClient then
		mClient:shutdown()
		mClient:close()
		mClient = nil
	end
	if nil ~= mSocket then
		mSocket = nil
	end
	print("close connect ...")
end
----------------------------------------------------------------------
-- 功  能：发送消息
-- 参  数：msgStruct(table类型)-发送的网络消息结构
-- 返回值：无返回值
----------------------------------------------------------------------
function NetSocket_send(msgStruct)
	if nil == mClient then
		return
	end
	-- 数据包字节流(包体)
	local byteArr = CreateByteArray()
	byteArr = msgStruct.build(byteArr)
	-- 防止重复发送标识
	local tag = string.pack("b", mPacketCount)					-- 这里用"b"
	mPacketCount = mPacketCount + 1
	if mPacketCount > MAX_PACKET_COUNT then
		mPacketCount = MIN_PACKET_COUNT
	end
	-- 包头(包体长度)
	local bodyLength = PACKET_COUNT_SIZE + byteArr.getLength()	-- 包体长度
	local packetHead = string.swab32(bodyLength)				-- 大小端转换
	local head = string.pack("i", packetHead)					-- 包头四个字节,这里要用"i"
	mClient:send(head..tag..byteArr.getPack())
	local msgId = msgStruct.getMsgID()
	print("---------- send ["..NetSocket_getMsgName(msgId)..", "..msgId.."]")
end
----------------------------------------------------------------------
-- 功  能：监听消息
-- 参  数：dt-时间间隔
-- 返回值：无返回值
----------------------------------------------------------------------
function NetSocket_update(dt)
	if nil == mClient then
		return
	end
	local recv, status = mClient:receive(mReceiveLen)
	if nil == recv or "closed" == status then	-- 没有收到数据
		return
	end
	-- 收到服务端发送过来的数据
	if true == mGetHead then	-- 当前取出来的是包头
		mGetHead = false	-- 设置下一步取包体
		mReceiveLen = string.swab32_array(recv)	-- 解析包头(包头里面存放的是包体的长度)
	else						-- 当前取出来的是包体
		mGetHead = true		-- 设置下一步取包头
		mReceiveLen = HEAD_SIZE
		local byteArr = CreateByteArray()
		byteArr.setBytes(recv)
		local msgId = byteArr.read_uint16()	-- 读取消息id
		print("---------- recv ["..NetSocket_getMsgName(msgId)..", "..msgId.."]")
		-- 派发事件
		local event = NetSocket_getEvent(msgId)
		if nil ~= event then
			if nil ~= event.msgStruct then
				event.msgStruct.decode(byteArr)
			end
			if nil ~= event.msgHandler then
				event.msgHandler(event.msgStruct)
			end
		end
		-- 特殊事件,0为特殊消息id
		event = NetSocket_getEvent(0)
		if nil ~= event and nil ~= event.msgHandler then
			event.msgHandler(msgId)
		end
	end
end
----------------------------------------------------------------------
-- 功  能：注册网络消息事件
-- 参  数：msgId(number类型)-网络消息id;msgStruct(table类型)-接收的网络消息结构;msgHandler(function类型)-网络消息处理句柄
-- 返回值：无返回值
----------------------------------------------------------------------
function NetSocket_registerHandler(msgId, msgStruct, msgHandler)
	if "number" ~= type(msgId) then
		print("NetSocket -> registerHandler -> msgId is not number")
		return
	end
	if "function" ~= type(msgHandler) then
		print("NetSocket -> registerHandler -> msgHandler is not function",msgId)
		return
	end
	for k, v in pairs(mNetMsgHandlers) do
		if msgId == v.msgId then	-- 网络事件已注册
			print("NetSocket -> registerHandler -> msg id ["..msgId.."] is exist")
			return
		end
	end
	-- 网络事件未注册
	local event = {}		-- 构造一个网络事件
	event.msgId = msgId				-- 消息id
	event.msgStruct = msgStruct		-- 消息结构
	event.msgHandler = msgHandler	-- 消息处理句柄
	table.insert(mNetMsgHandlers, event)
end
----------------------------------------------------------------------
-- 功  能：注册网络消息事件
-- 参  数：msgId(number类型)-网络消息id
-- 返回值：无返回值
----------------------------------------------------------------------
function NetSocket_unregisterHandler(msgId)
	for k, v in pairs(mNetMsgHandlers) do
		if msgId == v.msgId then	-- 事件已注册
			table.remove(mNetMsgHandlers, k)
			return
		end
	end
end
----------------------------------------------------------------------
-- 功  能：获取网络消息事件
-- 参  数：msgId(number类型)-网络消息id
-- 返回值：网络消息事件(table类型)
----------------------------------------------------------------------
function NetSocket_getEvent(msgId)
	for k, v in pairs(mNetMsgHandlers) do
		if msgId == v.msgId then	-- 事件已注册
			return v
		end
	end
	return nil
end
----------------------------------------------------------------------
-- 功  能：获取消息名字
-- 参  数：msgId(number)-网络消息id
-- 返回值：网络消息名
----------------------------------------------------------------------
function NetSocket_getMsgName(msgId)
	for k, v in pairs(NetMsgType) do
		if msgId == v then
			return k
		end
	end
	return ""
end
----------------------------------------------------------------------
