----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-21
-- 描述：xml数据表解析
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 功  能：加载xml数据表
-- 参  数：fileName(string类型) - xml文件名
-- 返回值：二维数组(table类型)
----------------------------------------------------------------------
function XmlTable_load(fileName)
	local xmlTB = loadXmlFile(fileName)
	if nil == xmlTB then
		print("XmlTable -> load() -> load file["..fileName.."] failed...")
		return nil
	end
	local dataTB = {}
	for k, v in pairs(xmlTB) do				-- 行
		local row = {}
		for name, value in pairs(v) do		-- 列
			local cell = {}
			cell.name = name		-- 字段名
			cell.value = value		-- 字段值
			table.insert(row, cell)
		end
		table.insert(dataTB, row)
	end
	return dataTB
end
----------------------------------------------------------------------
-- 功  能：获取指定行数据
-- 参  数：tb(table类型) - XmlTable_load返回的二维数组；colName(string类型) - 列名（字段名）；val(number或string类型) - 字段对应的值
-- 返回值：一维数组(table类型)
----------------------------------------------------------------------
function XmlTable_getRow(tb, colName, val)
	if "table" ~= type(tb) then
		print("XmlTable -> getRow() -> tb is not table")
		return nil
	end
	if "string" ~= type(colName) then
		print("XmlTable -> getRow() -> colName is not string")
		return nil
	end
	if "number" ~= type(val) and "string" ~= type(val) then
		print("XmlTable -> getRow() -> val is not number or string")
		return nil
	end
	for k1, v1 in pairs(tb) do	-- 遍历行
		for k2, v2 in pairs(v1) do	-- 遍历列
			if colName == v2.name and tostring(val) == v2.value then	-- 找到指定字段
				return v1	-- 返回该行
			end
		end
	end
	print("XmlTable -> getRow() -> can't find colName = "..colName..", val = "..val)
	return nil
end
----------------------------------------------------------------------
-- 作  者：叶江涛
-- 时  间：2013-1-7
-- 功  能：获取指定行数据组成一张表
-- 参  数：tb(table类型) - XmlTable_load返回的二维数组；colName(string类型) - 列名（字段名）；val(number或string类型) - 字段对应的值
-- 返回值：二维数组(table类型)
----------------------------------------------------------------------
function XmlTable_getRowTab(tb, colName, val)
	local resTab = {}
	if "table" ~= type(tb) then
		print("XmlTable -> getRow() -> tb is not table")
		return nil
	end
	if "string" ~= type(colName) then
		print("XmlTable -> getRow() -> colName is not string")
		return nil
	end
	if "number" ~= type(val) and "string" ~= type(val) then
		print("XmlTable -> getRow() -> val is not number or string")
		return nil
	end
	for k1, v1 in pairs(tb) do	-- 遍历行
		for k2, v2 in pairs(v1) do	-- 遍历列
			if colName == v2.name and tostring(val) == v2.value then	-- 找到指定字段
				-- return v1	-- 返回该行
				table.insert(resTab,v1)
			end
		end
	end
	return resTab
	-- print("XmlTable -> getRow() -> can't find colName = "..colName..", val = "..val)
	-- return nil
end
----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-26
-- 参数:str待分割的字符串(string),spilit_char分割字符(string)
-- 返回:子串表.(含有空串)
----------------------------------------------------------------------
function XmlTable_stringSplit(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end