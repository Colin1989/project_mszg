require "String"
require "List"
require "ClientDatabase"
require "VarHelper"


function Must(val, msg)
	msg = msg or "function Must not pass"
	if not val then
		error(msg, 2) -- 2表示显示上层调用
	end
	return val
end


-- 有序显示对象key
function LogKeys(obj)
	local arr = List()
	for k, _v in pairs(obj) do
		arr:insert(k)
	end
	Log(arr:sort())
end

-- Log 支持多参数
function Log(...)
	local args = {...}
	if #args == 0 then
		return DoLogOne(nil)
	end

	for _k, v in pairs(args) do
		DoLogOne(v)
	end
end

function DoLogOne(obj)
	local sType = type(obj)
	if 'table' == sType then
		local parentDic = {} -- 记录父节点
		parentDic[obj] = true
		local tabCount = 1       -- 缩进数
		local mt = getmetatable(obj)
		if mt and mt.__index == IList then
			cclog("{   -- is List class")
		else
			cclog("{")
		end
		for k, v in pairs(obj) do
			DoLogTableKV(k, v, tabCount, parentDic)
		end
		cclog("}")
	elseif 'string' == sType then
		cclog("\'" .. obj:toText() .. "\'")
	elseif 'number' == sType then
		cclog(obj)
	elseif 'boolean' == sType then
		cclog(obj)
	else
		cclog(sType)
	end
end

function DoLogTableKV(k, obj, tabCount, parentDic)
	local sOut = string.rep(' ', tabCount * 4)

	local function fnValToText(val)
		local sType = type(val)
		if sType == 'string' then
			return "\'" .. val:toText() .. "\'"
		elseif sType == 'number' then
			return "" .. val
		elseif val == true then
			return "true"
		elseif val == false then
			return "false"
		else
			return "nil, -- not support value type " .. sType
		end
	end

	local function fnIsAZ_az(val)
		if (val:head() == '_') or
			("a" <= val and val <= "z") or
			("A" <= val and val <= "Z") then
			return true
		else
			return false
		end
	end

	local function fnKeyToText(val)
		-- key只能是string, number类型
		local sType = type(val)
		if sType == 'string' then
			if val:len() == 8 then -- 可能是64位int
				return "['" .. val:toText() .. "']"
			elseif val:allIs(fnIsAZ_az) then
				return val:toText()
			else
				return "['" .. val:toText() .. "']"
			end
		elseif sType == 'number' then
			return "[" .. val .. "]"
		else
			return "-- not support key type " .. sType
		end
	end

	-- 判断是否table
	local sType = type(obj)
	if 'table' ~= sType then
		sOut = sOut .. fnKeyToText(k) .. " = " .. fnValToText(obj) .. ","
		cclog(sOut)
		return
	end

	-- 判断是否存在父节点死循环
	if parentDic[obj] then
		sOut = sOut .. fnKeyToText(k) .. " = " .. "nil" .. "," .. " -- can not cclog parent table!"
		cclog(sOut)
		return
	end

	parentDic[obj] = true -- 记录父节点
	tabCount = tabCount + 1   -- 缩进数 + 1
	cclog(sOut .. fnKeyToText(k) .. " = ")
	local mt = getmetatable(obj)
	if mt and mt.__index == IList then
		cclog(sOut .. "{   -- is List class ")
	else
		cclog(sOut .. "{")
	end

	for k, v in pairs(obj) do
		DoLogTableKV(k, v, tabCount, parentDic)
	end
	cclog(sOut .. "},")
	parentDic[obj] = nil -- 解除记录
end
----------------------------------------------------------------------
-- 功  能：文件读写
----------------------------------------------------------------------
function FileRead(fileName)
	local f, moreInfo = io.open(fileName, "rb")

	local ret
	if f then
		ret = f:read("*all")
		io.close(f)
	end
	return ret, moreInfo
end

function FileWrite(fileName, str)
	local f = assert(io.open(fileName, "wb"))

	if f then
		f:write(str)
		io.close(f)
	end
end

























