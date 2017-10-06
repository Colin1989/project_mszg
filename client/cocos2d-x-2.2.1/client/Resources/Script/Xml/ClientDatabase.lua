----------------------------------------------------------------------
-- 作者：hongjx
-- 描述：客户端本地数据库
----------------------------------------------------------------------

DB =
{
	--lookedCards = 已看过的卡 key=64位card_id, value = 1表示看过
}

----------------------------------------------------------------------
-- 功能：当前Account的数据库 初始化，只会执行一次, 主要用来设置一些默认值
----------------------------------------------------------------------
function DB:initAccount()
	-- 取当前用户的数据库
	local db = DB:get()
	--[[
	db.lookedCards = db.lookedCards or List()
	db.groups = db.groups or List()
	db.emails = db.emails or List()
	]]--
end


----------------------------------------------------------------------
-- 功能：取当前Account的数据库
----------------------------------------------------------------------
function DB:get()
	local root = DB:getRoot()
	local account = root.userInfo.account
	assert(account, "you are not login!")
	if not root[account] then
		root[account] = {}
		DB:initAccount()
	end

	return root[account]
end

----------------------------------------------------------------------
-- 功能：修改当前Account的数据库
-- 例子1: DB:save({Name="abc", playerLevel=5})
-- 例子2: local db = DB:get()
--        db.something = 'xxxxx'
--        DB:save()
----------------------------------------------------------------------
function DB:save(kvList)
	local db = DB:get()

	kvList = kvList or {}
	assert(type(kvList) == 'table')
	for k, v in pairs(kvList) do
		db[k] = v
	end

	local bin = VarHelper:varToBin(DB:getRoot())

	-- 目前VarHelper有个bug, 此行是debug代码
	--VarHelper:varFromBin(bin)

	FileWrite(DB:_getFileName(), bin)
end

function DB:getByKey(key)
	return self:get()[key]
end

function DB:save_single(key,value)
	 local db = self:get()
	 db[key] = value
	 self:save()
end


----------------------------------------------------------------------
-- 数据库名
----------------------------------------------------------------------
function DB:_getFileName()
	-- 先实例化
	CCUserDefault:sharedUserDefault()
	-- 再取cocos xml路径
	local xmlName = CCUserDefault:getXMLFilePath()

	-- 换成我们自己的
	return xmlName .. ".dbs"
end


----------------------------------------------------------------------
-- 功能：取数据库 包含多个账户
----------------------------------------------------------------------
function DB:getRoot()
	if g_db then
		return g_db
	else
		local bin, err = FileRead(DB:_getFileName())
		local db = {}
		if not err then
			local bOk, v, _remainBuf = pcall(function() return VarHelper:varFromBin(bin) end)
			if bOk then
				db = v
			else
				cclog("bad client db file ", DB:_getFileName())
			end
		end

		g_db = db
		self:initRoot()
		return g_db
	end
end

----------------------------------------------------------------------
-- 功能：当前Account的数据库 初始化，只会执行一次, 主要用来设置一些默认值
----------------------------------------------------------------------
function DB:initRoot()
	local root = g_db
	root.userInfo = root.userInfo or List() -- 用户登录信息
end
