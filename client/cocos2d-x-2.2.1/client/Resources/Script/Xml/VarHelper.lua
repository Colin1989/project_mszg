----------------------------------------------------------------------
-- 作者：hongjx
-- 日期：
-- 描述：变体系列化协议
----------------------------------------------------------------------





VarHelper = {}

function VarHelper:_tableToBin(val)
	local arr = {}
	for k, v in pairs(val) do
		table.insert(arr, {VarHelper:_getType(k), k, v})
	end

	-- 排序
--~ 	table.sort(arr,
--~ 				function(a, b)
--~ 					for i = 1, 3 do
--~ 						if a[i] < b[i] then
--~ 							return true
--~ 						elseif a[i] > b[i] then
--~ 							return false
--~ 						end
--~ 					end
--~ 					return true
--~ 				end)

	local out = ""
	out = out .. self:_intToBin(#arr)
	for k, v in pairs(arr) do
		out = out .. self:varToBin(v[2]) .. self:varToBin(v[3])
	end
	return out
end

function VarHelper:_stringToBin(val)
	return self:_intToBin(val:len()) .. val
end

function VarHelper:_uintToBin(val, bNeg)
	local out = ""
	local ch = bit.band(val, 63)
	if bNeg then
		ch = bit.bor(ch, 64)
	end

	val = bit.rshift(val, 6)
	if val == 0 then
		out = out .. string.char(ch)
		return out
	else
		ch = bit.bor(ch, 128)
		out = out .. string.char(ch)
	end

	while true do
		ch = bit.band(val, 127)
		val = bit.rshift(val, 7)
		Must(val >= 0)
		if val == 0 then
			out = out .. string.char(ch)
			return out
		else
			ch = bit.bor(ch, 128)
			out = out .. string.char(ch)
		end
	end

	return out
end

function VarHelper:intToBin(val)
	Must(self:_isInt(val))
	return self:_intToBin(val)
end

function VarHelper:_intToBin(val)
	local bNeg = (val < 0)
	if bNeg then
		return self:_uintToBin(-val, bNeg)
	else
		return self:_uintToBin(val, bNeg)
	end
end

function VarHelper:_isInt(val)
	local s = "" .. val
	if s:find(".", 1, true) then
		return false
	end

	if val < -2147483648 then
		return false
	end

	if val > 2147483647 then
		return false
	end

	return true
end

function VarHelper:_getType(val)
	local sType = type(val)
	if "number" == sType then
		return 6
	elseif "string" == sType then
		return 4
	elseif "table" == sType then
		return 3
	elseif "nil" == sType then
		return 5
	else
		Must(nil, "VarHelper:_getType not support type " .. sType)
	end
end

function VarHelper:varToBin(val)
	-- 支持布尔值存储
	if val == true then
		val = 1
	elseif val == false then
		val = nil
	end

	local sHeader = string.char(self:_getType(val))
	local sType = type(val)
	if "number" == sType then
		Must(self:_isInt(val), "" .. val)
		return sHeader .. self:_intToBin(val)
	elseif "string" == sType then
		return sHeader .. self:_stringToBin(val)
	elseif "table" == sType then
		return sHeader .. self:_tableToBin(val)
	elseif "nil" == sType then
		return sHeader
	else
		Must(nil, "VarHelper:varToBin not support type " .. sType)
	end
end

function VarHelper:varFromBin(bin)
	local iType = string.byte(bin:sub(1, 1))
	bin = self:binNext(bin)

	if 6 == iType then
		return self:_intFromBin(bin)
	elseif 4 == iType then
		return self:_stringFromBin(bin)
	elseif 3 == iType then
		return self:_tableFromBin(bin)
	elseif 5 == iType then
		return nil, bin
	else
		Must(nil, "VarHelper:_getType not support type " .. iType)
	end
end

function VarHelper:isIntEndChar(ch)
	return bit.band(ch, 128) == 0
end

function VarHelper:binHasNext(bin)
	return (bin:len() > 0)
end

function VarHelper:binNext(bin)
	return bin:sub(2)
end

function VarHelper:intFromBin(bin)
	return self:_intFromBin(bin)
end

function VarHelper:_intFromBin(bin)

	local obj = 0
	local val = 0
	local bNeg = false
	val, bNeg, bin = self:_uintFromBin(bin)

	local k = 2147483648

	if bNeg then
		Must(val <= k);
		obj = val
		obj = -obj
	else
		Must(val < k)
		obj = val
	end
	return obj, bin
end

function VarHelper:_stringFromBin(bin)
	local iSize = 0
	iSize, bin = self:_intFromBin(bin)
	local obj = bin:sub(1, iSize)
	bin = bin:sub(iSize + 1)
	return obj, bin
end

function VarHelper:_tableFromBin(bin)
	local iSize = 0
	iSize, bin = self:_intFromBin(bin)
	local obj = List()
	for i = 1, iSize do
		local k
		local v
		k, bin = self:varFromBin(bin)
		v, bin = self:varFromBin(bin)
		obj[k] = v
	end
	return obj, bin
end

function VarHelper:_uintFromBin(bin)
	local obj = 0
	Must(self:binHasNext(bin))
	local ch = string.byte(bin:sub(1, 1))
	bin = self:binNext(bin)
	local bNeg = (bit.band(ch, 64) > 0)
	obj = bit.bor(obj, bit.band(ch, 63))
	if (self:isIntEndChar(ch)) then
		return obj, bNeg, bin
	else
		Must(self:binHasNext(bin))
		ch = string.byte(bin:sub(1, 1))
		bin = self:binNext(bin)
		obj = bit.bor(obj, (bit.lshift(bit.band(ch, 127), 6)))
	end

	if (self:isIntEndChar(ch)) then
		return obj, bNeg, bin
	else
		Must(self:binHasNext(bin))
		ch = string.byte(bin:sub(1, 1))
		bin = self:binNext(bin)
		obj = bit.bor(obj, (bit.lshift(bit.band(ch, 127), 6 + 7 * 1)))
	end

	if (self:isIntEndChar(ch)) then
		return obj, bNeg, bin
	else
		Must(self:binHasNext(bin))
		ch = string.byte(bin:sub(1, 1))
		bin = self:binNext(bin)
		obj = bit.bor(obj, (bit.lshift(bit.band(ch, 127), 6 + 7 * 2)))
	end

	if (self:isIntEndChar(ch)) then
		return obj, bNeg, bin
	else
		Must(self:binHasNext(bin))
		ch = string.byte(bin:sub(1, 1))
		bin = self:binNext(bin)
		obj = bit.bor(obj, (bit.lshift(bit.band(ch, 127), 6 + 7 * 3)))
	end

	return obj, bNeg, bin
end






