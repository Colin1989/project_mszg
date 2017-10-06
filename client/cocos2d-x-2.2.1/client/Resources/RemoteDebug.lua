----------------------------------------------------------------------
-- 作者：hongjx
-- 日期：
-- 描述：远程调试
----------------------------------------------------------------------
ConstRemoteDebugServerIP = "127.0.0.1"
ConstRemoteDebugServerPort = 11111
RemoteDebug = {}

function RemoteDebug:create(ip, port)
	local obj = {
		mSocket = nil,
		mHasInit = false, -- 是否初始化过
		mIP = ip,
		mPort = port,
		mRecvBuf = "",  -- 缓存用来拼接报文
		mSendBuf = "",  -- 正在发送的数据
 	}

	setmetatable(obj, {__index=RemoteDebug})
	return obj
end

function RemoteDebug:runScript(sCode)
	return assert(loadstring(sCode))()
end

function RemoteDebug:init()
	self.mHasInit = true
	local ip = self.mIP
	local port = self.mPort
	local sockApi = require("socket")
	self.mSocket = sockApi.connect(ip, port)

	if self.mSocket then
		print("Debug服务器连接成功!")
		self.mSocket:settimeout(0) -- 设成非阻塞
		-- 表明自己是被调试的客户端
		local sayIAmClient = {IsClient=1}
		self:sendVar(sayIAmClient)
	else
		--Toast:show("连接失败")
		print("not find debug server " .. ip .. ": " .. port)
	end
end

function RemoteDebug:sendVar(var)
	local bin = VarHelper:varToBin(var)
	self.mSendBuf = self.mSendBuf .. VarHelper:intToBin(bin:len()) .. bin
end

function RemoteDebug:onRequest(req)

	if type(req) ~= "table" then
		return
	end

	if req.DebugCode then
		print("运行调试代码: " .. req.DebugCode:sub(1, 512) .. "......")
		req.DebugCodeResult = self:runScript(req.DebugCode)
		req.ToNetPos = req.FromNetPos
		req.DebugCode = nil
		req.FroNetPos = nil
		return req
	end

end

function RemoteDebug:doSend()
	if self.mSendBuf:len() <= 0 then
		return;
	end
	local nSend = self.mSocket:send(self.mSendBuf)
	if nSend <= 0 then
		return
	end

	self.mSendBuf = self.mSendBuf:sub(nSend+1)
end

function RemoteDebug:doRecv()
	local function fnConvertData(dt)
		if not dt then
			return nil
		end

		if dt:len() == 0 then
			return nil
		end

		return dt
	end
	-- 神秘的返回值没文档，只能看源代码猜
	local fullData, err, tailData = self.mSocket:receive(10240)
	local sData = fnConvertData(fullData) or fnConvertData(tailData)

	if not sData then
		return
	end

	--print("recv RemoteDebug data len:" .. sData:len(), sData)
	self.mRecvBuf = self.mRecvBuf .. sData
	local function fnDecode()
		local packSize, bin = VarHelper:intFromBin(self.mRecvBuf)
		return VarHelper:varFromBin(bin)
	end

	local bOk, req, remainBuf = pcall(fnDecode)

	if not bOk then
		return
	end

	self.mRecvBuf = remainBuf
	local reply = self:onRequest(req)
	if not reply then
		return
	end

	self:sendVar(reply)
end

function RemoteDebug:doUpdate()
	if not self.mHasInit then
		self:init()
	end

	if not self.mSocket then
		return
	end

	self:doSend()
	self:doRecv()
end

function RemoteDebug:update()
	if not g_RemoteDebug then
		g_RemoteDebug = RemoteDebug:create(ConstRemoteDebugServerIP, ConstRemoteDebugServerPort)
	end

	g_RemoteDebug:doUpdate()
end

function RemoteDebug:changeIP(sIp)
	g_RemoteDebug = nil
	ConstRemoteDebugServerIP = sIp
end
