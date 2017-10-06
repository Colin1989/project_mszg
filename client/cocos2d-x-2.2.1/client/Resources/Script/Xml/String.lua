
function string.beginWith(s, tail)
	return s:sub(1, tail:len()) == tail
end

function string.endWith(s, tail)
	return s:sub(-tail:len()) == tail
end

-- 第一个字节
function string.head(s)
	return s:sub(1, 1)
end

function string.popHead(s)
	return s:sub(2)
end

-- 是否所有char都满足fn
function string.allIs(s, fn)
	if s:len() == 0 then
		return false
	end

	while s:len() > 0 do
		if not fn(s) then
			return false
		end

		s = s:popHead()
	end
	return true
end

-- 转成文本
function string.toText(s)
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

-- 转成16进制
function string.toHex(s)
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
