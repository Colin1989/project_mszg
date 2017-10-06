

-- 是否以某个字符串开头
-- 例子: local s = 'this is a test'
--       Log(s:beginWith('this')) -- 返回true
--       Log(s:beginWith('is')) -- 返回false
function string:beginWith(s)
	return self:sub(1, s:len()) == s
end

-- 是否以某个字符串结尾
-- 例子: local s = 'this is a test'
--       Log(s:endWith('this')) -- 返回false
--       Log(s:endWith('test')) -- 返回true
function string:endWith(tail)
	return self:sub(-tail:len()) == tail
end

-- 第一个字节
-- 例子: local s = 'xyz'
--       Log(s:head()) -- 返回'x'
function string:head()
	return self:sub(1, 1)
end

-- 返回去掉第一个字符后的字符串
-- 例子: local s = 'xyz'
--       Log(s:popHead()) -- 返回'yz'
function string:popHead()
	return self:sub(2)
end

-- 逐个char判断是否都满足fn
-- 例子: local s = '132930'
--       Log(s:allIs(function(v) return '0' <= v and v <= '9' end)) -- 返回true
-- 例子: local s = '1329Abc'
--       Log(s:allIs(function(v) return '0' <= v and v <= '9' end)) -- 返回false
function string:allIs(fn)
	local s = self
	if s:len() == 0 then
		return false
	end

	while s:len() > 0 do
		if not fn(s:head()) then
			return false
		end

		s = s:popHead()
	end
	return true
end

-- 转成文本, 主要用来显示服务端的64位int字符串
function string:toText()
	local s = self
	if s:len() ~= 8 then -- 判断是否64位int
		return s
	end

	local sTmp = s
	while sTmp:len() > 0 do
		local ch = sTmp:head()
		local iVal = string.byte(ch)
		if (32 <= iVal) and (iVal < 127) then
			sTmp = sTmp:popHead()
		else
			break
		end
	end

	-- 不用转成\123\2\9之类的形式
	if sTmp:len() == 0 then
		return s
	end

	local sOut = ""
	while s:len() > 0 do
		local ch = s:head()
		local iVal = string.byte(ch)
		sOut = sOut .. "\\" .. iVal
		s = s:popHead()
	end

	return sOut
end

-- 转成16进制文本
-- 例子: local s = 'ok\n'
--       Log(s:toHex()) -- 返回'6F6B0A'
function string:toHex()
	local s = self
	local function fnGetHex(iVal)
		if iVal < 10 then
			return string.char(iVal + string.byte('0'))
		else
			return string.char(iVal - 10 + string.byte('A'))
		end
	end

	local sOut = ""
	while s:len() > 0 do
		local ch = s:head()
		local iVal = string.byte(ch)
		sOut = sOut .. fnGetHex(math.floor(iVal/16))
		sOut = sOut .. fnGetHex(math.mod(iVal, 16))

		s = s:popHead()
	end
	return sOut
end

-- 合并
-- 返回列表
-- 例子: local arr = List({'ab', 'cde', 'gh'})
--       Log(string:join(arr, ',')) -- 返回'ab,cde,gh'
function string:join(...)
	return table.concat(...)
end

-- 切割
-- 返回列表
-- 例子: local s = "ab,cde,gh"
--       Log(s:split(',')) -- 返回{'ab', 'cde', 'gh'}
function string:split(sDiv)
    local retList = List()
    self:gsub('[^'..sDiv..']+', function(sRet) retList:insert(sRet) end)
    return retList
end

-- 切割成unicode
-- 返回列表
-- 例子: local s = "a到b中文ok"
--       Log(s:unicodeChars()) -- 返回{'a', '到', 'b', '中', '文', 'o', 'k'}
function string:unicodeChars()
	local retList = List()

	for uchar in self:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
		retList:insert(uchar)
	end
	return retList
end

-- 按指定长度插入分隔符
-- 返回列表
-- 例子: local s = "abc123ABC"
--       Log(s:insertPerLen(3, ",")) -- "abc,123,ABC,"
function string:insertPerLen(len, insertStr)
	local s = self
	local arr = List()
	while s:len() >= len do
		arr:insert(s:sub(1, len))
		s = s:sub(len + 1)
	end
	arr:insert(s)
	return string:join(arr, insertStr)
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
			print("{   -- is List class")
		else
			print("{")
		end
		for k, v in pairs(obj) do
			DoLogTableKV(k, v, tabCount, parentDic)
		end
		print("}")
	elseif 'string' == sType then
		print("\'" .. obj:toText() .. "\'")
	elseif 'number' == sType then
		print(obj)
	elseif 'boolean' == sType then
		print(obj)
	else
		print(sType)
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
		print(sOut)
		return
	end

	-- 判断是否存在父节点死循环
	if parentDic[obj] then
		sOut = sOut .. fnKeyToText(k) .. " = " .. "nil" .. "," .. " -- can not cclog parent table!"
		print(sOut)
		return
	end

	parentDic[obj] = true -- 记录父节点
	tabCount = tabCount + 1   -- 缩进数 + 1
	print(sOut .. fnKeyToText(k) .. " = ")
	local mt = getmetatable(obj)
	if mt and mt.__index == IList then
		print(sOut .. "{   -- is List class ")
	else
		print(sOut .. "{")
	end

	for k, v in pairs(obj) do
		DoLogTableKV(k, v, tabCount, parentDic)
	end
	print(sOut .. "},")
	parentDic[obj] = nil -- 解除记录
end

----------------------------------------------------------------------
-- 功  能：分割字符串
-- 参  数：str - 字符串,separator - 分隔符,isNumber - 是否是数字类型
-- 返回值：字符串数组
----------------------------------------------------------------------
function stringSplit(str, separator, isNumber)
	if "string" ~= type(str) or "string" ~= type(separator) then
		return {}
	end
	local findStartIndex = 1
	local splitIndex = 1
	local splitArray = {}
	while true do
		local findLastIndex = string.find(str, separator, findStartIndex)
		if not findLastIndex then
			if true == isNumber then
				splitArray[splitIndex] = tonumber(string.sub(str, findStartIndex, string.len(str)))
			else
				splitArray[splitIndex] = string.sub(str, findStartIndex, string.len(str))
			end
			break
		end
		if true == isNumber then
			splitArray[splitIndex] = tonumber(string.sub(str, findStartIndex, findLastIndex - 1))
		else
			splitArray[splitIndex] = string.sub(str, findStartIndex, findLastIndex - 1)
		end
	   findStartIndex = findLastIndex + string.len(separator)
	   splitIndex = splitIndex + 1
	end
	return splitArray
end

