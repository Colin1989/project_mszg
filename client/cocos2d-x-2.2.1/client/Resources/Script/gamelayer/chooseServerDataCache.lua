----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-4-3
-- 描述：选择服务器数据
----------------------------------------------------------------------
chooseServerDataCache = {}
local mIpconfigTable = XmlTable_load("ipconfig_tplt.xml", "id")
local mServerTable = {}
local mServerData = nil
local mLastServerId = nil
----------------------------------------------------------------------
-- 设置ip配置表
chooseServerDataCache.setIpconfigTable = function(data)
	mServerTable = data
end

-- 获取ip配置表
chooseServerDataCache.getIpconfigTable = function()
	local ipconfigTable = {}
	for key, val in pairs(mServerTable) do
		local ipconfigRow = {}
		ipconfigRow.id = tonumber(key)								-- 标识
		ipconfigRow.server_id = tonumber(val.server_id)			-- 服务器id
		ipconfigRow.type = tonumber(val.server_type)				-- 服务器类型(1.内网,2.外网,3.官网)
		ipconfigRow.ip = val.server_ip								-- 服务器地址
		ipconfigRow.channel_id = val.channel_id						-- 渠道ID
		ipconfigRow.last_server_id = val.last_server_id				-- 
		ipconfigRow.port = tonumber(val.server_port)				-- 服务器端口
		ipconfigRow.crypto = tonumber(val.crypto)					-- 服务器加密(0.不加密,1.加密)
		ipconfigRow.name = val.server_name							-- 服务器名称
		ipconfigRow.status = tonumber(val.server_status)			-- 状态(1.顺畅,2.拥挤,3.维护)
		ipconfigRow.corner_mark = tonumber(val.corner_mark)		-- 角标(0.普通,1.推荐,2.新服)
		ipconfigRow.describe = val.remark							-- 描述信息
		ipconfigRow.is_grounding = val.is_grounding					-- 标识(1.测试中,2.已上架)
		table.insert(ipconfigTable, ipconfigRow)
	end
	table.sort(ipconfigTable, function(a, b) return a.id < b.id end)
	return ipconfigTable
end

-- 根据ip和port读取配置数据
chooseServerDataCache.getIpconfigRow = function(ip, port)
	for key, val in pairs(chooseServerDataCache.getIpconfigTable()) do
		if ip == val.ip and tonumber(port) == tonumber(val.port) then
			local ipconfigRow = {}
			ipconfigRow.id = tonumber(val.id)
			ipconfigRow.type = tonumber(val.type)
			ipconfigRow.server_id = tonumber(val.server_id)
			ipconfigRow.ip = val.ip
			ipconfigRow.port = tonumber(val.port)
			ipconfigRow.crypto = tonumber(val.crypto)
			ipconfigRow.name = val.name
			ipconfigRow.status = tonumber(val.status)
			ipconfigRow.corner_mark = tonumber(val.corner_mark)
			ipconfigRow.describe = val.describe
			return ipconfigRow
		end
	end
	return nil
end

--[[
-- 获取ip配置表
chooseServerDataCache.getIpconfigTable = function(ipconfigType)
	local ipconfigTable = {}
	for key, val in pairs(mIpconfigTable.map) do
		if tonumber(ipconfigType) == tonumber(val.type) then
			local ipconfigRow = {}
			ipconfigRow.id = tonumber(val.id)						-- 标识
			ipconfigRow.type = tonumber(val.type)					-- 服务器类型(1.内网,2.外网,3.官网)
			ipconfigRow.server_id = tonumber(val.server_id)			-- 服务器id
			ipconfigRow.ip = val.ip									-- 服务器地址
			ipconfigRow.port = tonumber(val.port)					-- 服务器端口
			ipconfigRow.crypto = tonumber(val.crypto)				-- 服务器加密(0.不加密,1.加密)
			ipconfigRow.name = val.name								-- 服务器名称
			ipconfigRow.status = tonumber(val.status)				-- 状态(1.顺畅,2.拥挤,3.维护)
			ipconfigRow.corner_mark = tonumber(val.corner_mark)		-- 角标(0.普通,1.推荐,2.新服)
			ipconfigRow.describe = val.describe						-- 描述信息
			table.insert(ipconfigTable, ipconfigRow)
		end
	end
	table.sort(ipconfigTable, function(a, b) return a.id < b.id end)
	return ipconfigTable
end
]]--

----------------------------------------------------------------------
-- 根据ip和port读取配置数据
-- chooseServerDataCache.getIpconfigRow = function(ip, port)
	-- for key, val in pairs(mIpconfigTable.map) do
		-- if ip == val.ip and tonumber(port) == tonumber(val.port) then
			-- local ipconfigRow = {}
			-- ipconfigRow.id = tonumber(val.id)
			-- ipconfigRow.type = tonumber(val.type)
			-- ipconfigRow.server_id = tonumber(val.server_id)
			-- ipconfigRow.ip = val.ip
			-- ipconfigRow.port = tonumber(val.port)
			-- ipconfigRow.crypto = tonumber(val.crypto)
			-- ipconfigRow.name = val.name
			-- ipconfigRow.status = tonumber(val.status)
			-- ipconfigRow.corner_mark = tonumber(val.corner_mark)
			-- ipconfigRow.describe = val.describe
			-- return ipconfigRow
		-- end
	-- end
	-- return nil
-- end

-- 渠道登陆请求服务器数据
chooseServerDataCache.getChannelServerList = function()
	local loginParam = 
	{
		["app_id"] = tonumber(ChannelProxy.getAppId()),
		["app_key"] = tostring(ChannelProxy.getAppKey()),
		["uid"] = tostring(ChannelProxy.getUid()),
		["channel_id"] = tonumber(ChannelProxy.getChannelId()),
		["channel_version"] = GAME_VERSION,
		["server_type"] = tonumber(CONFIG["game_server_type"]),
		["is_grounding"] = IS_GROUNDING,
	}
	NetHttp.send_ByPost("server",
	loginParam,
	function(resp)
		local flag = true
		if tonumber(resp.code) == 101 then
			cclog("区服平台无响应")
			flag = false
		elseif tonumber(resp.code) == 102 then
			cclog("sign校验不正确")
			flag = false
		elseif tonumber(resp.code) == 103 then
			cclog("该接口的参数不完整")
			flag = false
		elseif tonumber(resp.code) == 201 then
			cclog("该应用未加入到区服平台或者不存在")
			flag = false
		elseif tonumber(resp.code) == 202 then
			cclog("渠道ID格式不对")
			flag = false
		end
		if flag == false or #resp.data.serverInfoResultList == 0 then
			Toast.show(GameString.get("NETWORK_STR_08"))
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2.0), CCCallFunc:create(function()
					ChannelProxy.switchAccount()
			end)))
			return
		end
		if #resp.data.serverInfoResultList ~= 0 then
			mLastServerId = resp.data.last_server_id
			chooseServerDataCache.setIpconfigTable(resp.data.serverInfoResultList)
			-- UIManager.pop("UI_LoginOwn")
			-- UIManager.push("UI_Begin",loginData)
			UIManager.push("UI_Begin")
		end
	end)
end

----------------------------------------------------------------------
-- 自有登陆请求服务器数据
chooseServerDataCache.getOwnServerList = function(loginData)
	local loginParam = 
	{
		["app_id"] = tonumber(ChannelProxy.getAppId()),
		["app_key"] = tostring(ChannelProxy.getAppKey()),
		["uid"] = tostring(loginData.data.uid),
		["channel_id"] = tonumber(ChannelProxy.getChannelId()),
		["channel_version"] = GAME_VERSION,
		["server_type"] = tonumber(CONFIG["game_server_type"]),
		["is_grounding"] = IS_GROUNDING,
		-- ["device_id"] = "testDevice_id",	--这个值随便设
	}
	NetHttp.send_ByPost("server",
	loginParam,
	function(resp)
		local flag = true
		if tonumber(resp.code) == 101 then
			cclog("区服平台无响应")
			flag = false
		elseif tonumber(resp.code) == 102 then
			cclog("sign校验不正确")
			flag = false
		elseif tonumber(resp.code) == 103 then
			cclog("该接口的参数不完整")
			flag = false
		elseif tonumber(resp.code) == 201 then
			cclog("该应用未加入到区服平台或者不存在")
			flag = false
		elseif tonumber(resp.code) == 202 then
			cclog("渠道ID格式不对")
			flag = false
		end
		if flag == false or #resp.data.serverInfoResultList == 0 then
			Toast.show(GameString.get("NETWORK_STR_08"))
			return
		end
		if #resp.data.serverInfoResultList ~= 0 then
			mLastServerId = resp.data.last_server_id
			chooseServerDataCache.setIpconfigTable(resp.data.serverInfoResultList)
			UIManager.pop("UI_LoginOwn")
			UIManager.push("UI_Begin",loginData)
		end
	end,
	function(resp)
		-- 请求失败
	end,
	function()
		-- 请求超时
		Toast.show(GameString.get("NETWORK_STR_01"))
	end)
end

-- 获取服务器数据
chooseServerDataCache.getServerData = function()
	-- if #mServerTable == 0 then
		-- cclog("server list error")
		-- return nil
	-- end
	local serverData = chooseServerDataCache.getIpconfigTable()
	local tempServerData = nil
	if mLastServerId == nil or mLastServerId == "" or mLastServerId == "null" then
		tempServerData = serverData[1]
	else
		for key, value in pairs(serverData) do
			if tonumber(mLastServerId) == value.server_id then
				tempServerData = value
			end
		end
	end
	
	return tempServerData
end

----------------------------------------------------------------------
-- 获取服务器数据
-- chooseServerDataCache.getServerData = function()
	-- if nil ~= mServerData then
		-- return mServerData
	-- end
	-- local cacheIp = CCUserDefault:sharedUserDefault():getStringForKey("serverAddress")
	-- local cachePort = CCUserDefault:sharedUserDefault():getStringForKey("serverPort")
	-- local cacheData = chooseServerDataCache.getIpconfigRow(cacheIp, cachePort)
	-- if nil == cacheData then
		-- local dataTb = chooseServerDataCache.getIpconfigTable(CONFIG["game_server_type"])	-- 默认选取第1个
		-- cacheData = dataTb[1]
	-- end
	-- mServerData = cacheData
	-- chooseServerDataCache.getFuckServer()
	-- return mServerData
-- end

-- 设置服务器数据
chooseServerDataCache.setServerData = function(data)
	mServerData = data
	CCUserDefault:sharedUserDefault():setStringForKey("serverAddress", data.ip)
	CCUserDefault:sharedUserDefault():setStringForKey("serverPort", data.port)
end
