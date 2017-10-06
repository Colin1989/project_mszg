--------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-12-4
-- 描述：字节流(网络协议序列化)
----------------------------------------------------------------------
BA_ENDIAN_LITTLE = "ENDIAN_LITTLE"	-- 小端
BA_ENDIAN_BIG = "ENDIAN_BIG"		-- 大端
BA_RADIX = {[10]="%03u", [8]="%03o", [16]="%02X"}

function CreateByteArray(endian)
	local ba = {}
	----------------------------------------------------------------------
	-- private member variable
	----------------------------------------------------------------------
	ba.mEndian = endian	or ""	-- 大小端标识
	ba.mBuf = {}				-- 二进制字节流
	ba.mPos = 1					-- 读写位置
	----------------------------------------------------------------------
	-- public method
	----------------------------------------------------------------------
	-- 设置大小端
	ba.setEndian = function(endian)
		ba.mEndian = endian	or ""
	end
	-- 设置字节流
	ba.setBytes = function(buf)
		ba.writeBuf(buf)
		ba.mPos = 1		-- 这里必须重置读写位置为1,方能保证接下去的读操作正确
	end
	-- 获取字节流长度
	ba.getLength = function()
		return #ba.mBuf
	end
	-- Get all byte array as a lua string
	ba.getBytes = function(offset, length)
		offset = offset or 1
		length = length or #ba.mBuf
		return table.concat(ba.mBuf, "", offset, length)
	end
	-- Get pack style string by lpack, The result use ByteArray.getBytes to get is unavailable for lua socket.
	ba.getPack = function(offset, length)
		offset = offset or 1
		length = length or #ba.mBuf
		local bytes = {}
		for i=offset, length do
			bytes[#bytes+1] = string.byte(ba.mBuf[i])
		end
		local packRes = string.pack(ba.getLetterCode("b"..#bytes), unpack(bytes))
		return packRes
	end
	-- 字节流转为字符串
	ba.toString = function(radix, separator)
		radix = radix or 16 
		radix = BA_RADIX[radix] or "%02X"
		separator = separator or " "
		local bytes = {}
		for i=1, #ba.mBuf do
			bytes[i] = string.format(radix..separator, string.byte(ba.mBuf[i]))
		end
		return table.concat(bytes)
	end
	----------------------------------------------------------------------
	-- 读16位整型
	ba.read_int16 = function()
		local tmp, value = string.unpack(ba.readBuf(2), ba.getLetterCode("h"))
		return value
	end
	-- 写16位整型
	ba.write_int16 = function(value)
		local buf = string.pack(ba.getLetterCode("h"), value)
		ba.writeBuf(buf)
	end
	-- 读16位无符号整型
	ba.read_uint16 = function()
		local tmp, value = string.unpack(ba.readBuf(2), ba.getLetterCode("H"))
		return value
	end
	-- 写16位无符号整型
	ba.write_uint16 = function(value)
		local buf = string.pack(ba.getLetterCode("H"), value)
		ba.writeBuf(buf)
	end
	-- 读32位整型
	ba.read_int = function()
		local tmp, value = string.unpack(ba.readBuf(4), ba.getLetterCode("i"))
		return value
	end
	-- 写32位整型
	ba.write_int = function(value)
		local buf = string.pack(ba.getLetterCode("i"), value)
		ba.writeBuf(buf)
	end
	-- 读32位无符号整型
	ba.read_uint = function()
		local tmp, value = string.unpack(ba.readBuf(4), ba.getLetterCode("I"))
		return value
	end
	-- 写32位无符号整型
	ba.write_uint = function(value)
		local buf = string.pack(ba.getLetterCode("I"), value)
		ba.writeBuf(buf)
	end
	-- 读长整型
	ba.read_long = function()
		local tmp, value = string.unpack(ba.readBuf(4), ba.getLetterCode("l"))
		return value
	end
	-- 写长整型
	ba.write_long = function(value)
		local buf = string.pack(ba.getLetterCode("l"), value)
		ba.writeBuf(buf)
	end
	-- 读无符号长整型
	ba.read_ulong = function()
		local tmp, value = string.unpack(ba.readBuf(4), ba.getLetterCode("L"))
		return value
	end
	-- 写无符号长整型
	ba.write_ulong = function(value)
		local buf = string.pack(ba.getLetterCode("L"), value)
		ba.writeBuf(buf)
	end
	-- 读64位整型
	ba.read_int64 = function()
		-- local tmp, value = string.unpack(ba.readBuf(8), ba.getLetterCode("m"))
		-- return value
		return ba.read_string_bytes(8)
	end
	-- 写64位整型
	ba.write_int64 = function(value)
		-- local buf = string.pack(ba.getLetterCode("m"), value)
		-- ba.writeBuf(buf)
		local buf = string.pack(ba.getLetterCode("A"), value)
		ba.writeBuf(buf)
	end
	-- 读64位无符号整型
	ba.read_uint64 = function()
		-- local tmp, value = string.unpack(ba.readBuf(8), ba.getLetterCode("M"))
		-- return value
		return ba.read_string_bytes(8)
	end
	-- 写64位无符号整型
	ba.write_uint64 = function(value)
		-- local buf = string.pack(ba.getLetterCode("M"), value)
		-- ba.writeBuf(buf)
		local buf = string.pack(ba.getLetterCode("A"), value)
		ba.writeBuf(buf)
	end
	-- 读单精度浮点型
	ba.read_float = function()
		local tmp, value = string.unpack(ba.readBuf(4), ba.getLetterCode("f"))
		return value
	end
	-- 写单精度浮点型
	ba.write_float = function(value)
		local buf = string.pack(ba.getLetterCode("f"), value)
		ba.writeBuf(buf)
	end
	-- 读双精度浮点型
	ba.read_double = function()
		local tmp, value = string.unpack(ba.readBuf(8), ba.getLetterCode("d"))
		return value
	end
	-- 写双精度浮点型
	ba.write_double = function(value)
		local buf = string.pack(ba.getLetterCode("d"), value)
		ba.writeBuf(buf)
	end
	-- 读布尔型
	ba.read_bool = function()
		return 1 == ba.read_char()
	end
	-- 写布尔型
	ba.write_bool = function(value)
		if value then 
			ba.write_char(1)
		else
			ba.write_char(0)
		end
	end
	-- 读字符型
	ba.read_char = function()
		local tmp, value = string.unpack(ba.readRawByte(), "c")
		return value
	end
	-- 写字符型
	ba.write_char = function(value)
		ba.writeRawByte(string.pack("c", value))
	end
	-- 读单字节
	ba.read_uchar = function()
		-- 方法1
		-- return string.byte(ba.readRawByte())
		-- 方法2
		local tmp, value = string.unpack(ba.readRawByte(), "b")
		return value
	end
	-- 写单字节
	ba.write_uchar = function(value)
		-- 方法1
		-- ba.writeRawByte(string.char(value))
		-- 方法2
		ba.writeRawByte(string.pack("b", value))
	end
	-- 读字符串
	ba.read_string = function()
		local length = ba.read_uint16()
		return ba.read_string_bytes(length)
	end
	-- 写字符串
	ba.write_string = function(value)
		local buf = string.pack(ba.getLetterCode("A"), value)
		ba.write_uint16(#buf)
		ba.writeBuf(buf)
	end
	----------------------------------------------------------------------
	-- private method
	----------------------------------------------------------------------
	-- 验证读写位置
	ba.checkAvailable = function()
		assert(#ba.mBuf >= ba.mPos, string.format("End of file was encountered. pos: %d, length: %d.", ba.mPos, #ba.mBuf))
	end
	-- 获取字符码
	ba.getLetterCode = function(fmt)
		fmt = fmt or ""
		if BA_ENDIAN_LITTLE == ba.mEndian then
			return "<"..fmt
		elseif BA_ENDIAN_BIG == ba.mEndianthen then
			return ">"..fmt
		else
			return "="..fmt
		end
	end
	-- 读单个字节
	ba.readRawByte = function()
		ba.checkAvailable()
		local rawByte = ba.mBuf[ba.mPos]
		ba.mPos = ba.mPos + 1
		return rawByte
	end
	-- 写单个字节
	ba.writeRawByte = function(rawByte)
		if ba.mPos > #ba.mBuf + 1 then
			for i=#ba.mBuf + 1, ba.mPos - 1 do
				ba.mBuf[i] = string.char(0)
			end
		end
		ba.mBuf[ba.mPos] = rawByte
		ba.mPos = ba.mPos + 1
	end
	-- 读字节流
	ba.readBuf = function(length)
		ba.checkAvailable()
		local buf = ba.getBytes(ba.mPos, ba.mPos + length - 1)
		ba.mPos = ba.mPos + length
		return buf
	end
	-- 写字节流
	ba.writeBuf = function(buf)
		for i=1, #buf do
			ba.writeRawByte(buf:sub(i))
		end
	end
	-- 读字符串
	ba.read_string_bytes = function(length)
		if 0 == length then
			return ""
		end
		local tmp, value = string.unpack(ba.readBuf(length), ba.getLetterCode("A"..length))
		return value
	end
	-- 写字符串
	ba.write_string_bytes = function(value)
		local buf = string.pack(ba.getLetterCode("A"), value)
		ba.writeBuf(buf)
	end
	----------------------------------------------------------------------
	return ba
end

