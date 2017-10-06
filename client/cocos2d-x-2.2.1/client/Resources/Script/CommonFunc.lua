----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-29
-- 描述：通用函数
----------------------------------------------------------------------
----------------------------------------------------------------------
-- 功  能：解码json格式
-- 参  数：str(json字符串)
-- 返回值：table(json)
----------------------------------------------------------------------
function CommonFunc_decodeJsonStr(str)
	local json = require "json"
	local data = json.decode(str)
	return data
end
----------------------------------------------------------------------
-- 功  能：编码json格式
-- 参  数：tb(table表)
-- 返回值：string(json)
----------------------------------------------------------------------
function CommonFunc_encodeJsonStr(tb)
	local json = require "json"
	local str = json.encode(tb)
	return str
end
----------------------------------------------------------------------
-- 功  能：生成枚举类型
-- 参  数：tb(table类型) - 一维表{"aaaa", "bbbb", "cccc", ...}
-- 返回值：二维表{"aaaa"=1, "bbbb"=2, "cccc"=3, ...},枚举下标从1开始
----------------------------------------------------------------------
function CommonFunc_enum(tb)
	local enum = {}
	for k, v in pairs(tb) do
		enum[v] = k
	end
	return enum
end
----------------------------------------------------------------------
-- 功  能：对象拷贝
-- 参  数：任意对象
-- 返回值：新对象
----------------------------------------------------------------------
function CommonFunc_clone(obj)
    local lookupTable = {}
    local function copyObj(obj)
        if "table" ~= type(obj) then
            return obj
        elseif lookupTable[obj] then
            return lookupTable[obj]
        end
        local newTable = {}
        lookupTable[obj] = newTable
        for key, value in pairs(obj) do
            newTable[copyObj(key)] = copyObj(value)
        end
        return setmetatable(newTable, getmetatable(obj))
    end
    return copyObj(obj)
end
----------------------------------------------------------------------
-- 功  能：备份一个table
-- 参  数：ori_tab(table)
-- 返回值：new_tab
----------------------------------------------------------------------
function CommonFunc_table_copy_table(ori_tab)  
    if (type(ori_tab) ~= "table") then  
        return nil  
    end  
    local new_tab = {}  
    for i,v in pairs(ori_tab) do  
        local vtyp = type(v)  
        if (vtyp == "table") then  
            new_tab[i] = CommonFunc_table_copy_table(v)  
        elseif (vtyp == "thread") then  
            new_tab[i] = v  
        elseif (vtyp == "userdata") then  
            new_tab[i] = v  
        else  
            new_tab[i] = v  
        end  
    end  
    return new_tab  
end
----------------------------------------------------------------------
-- 功  能：拷贝表属性
-- 参  数：srcTable(table类型) - 源表,targetTable(table类型) - 目标表
-- 返回值：无
----------------------------------------------------------------------
function CommonFunc_copyTableMembers(srcTable, targetTable)
	if "table" ~= type(srcTable) or "table" ~= type(targetTable) then
		return
	end
	for key, val in pairs(targetTable) do
		if nil == srcTable[key] then
			srcTable[key] = CommonFunc_clone(val)
		end
	end
end
----------------------------------------------------------------------
-- 功  能：获取指定概率
-- 参  数：probability(nubmer类型) - 取值范围1到100
-- 返回值：boolean
----------------------------------------------------------------------
function CommonFunc_getProbability(probability)
	if probability < 1 or probability > 100 then
		cclog("CommonFunc -> getProbability -> probability["..getProbability.."] is out of range [1, 100].")
		return false
	end
	local res = math.random(1, 100)
	return res <= probability
end
----------------------------------------------------------------------
-- 功  能：获取随机元素
-- 参  数：values:talble|string,num:随机个数
-- 返回值：随机数据
----------------------------------------------------------------------
function CommonFunc_randomValue(valueArray, num)
	if ("table" ~= type(valueArray) and "string" ~= type(valueArray)) or "number" ~= type(num) then
		return {}
	end
	if 0 == #valueArray or 0 == num then
		return {}
	end
	if num >= #valueArray then
		return valueArray
	end
	local tempValueArray = CommonFunc_clone(valueArray)
	local randomArray = {}
	for i=1, num do
		local index = math.random(1, #tempValueArray)
		table.insert(randomArray, tempValueArray[index])
		table.remove(tempValueArray, index)
	end
	return randomArray
end
----------------------------------------------------------------------
-- 功  能：四舍五入
-- 参  数：num(number类型)
-- 返回值：整数
----------------------------------------------------------------------
function CommonFunc_round(num)
	if "number" ~= type(num) then
		return 0
	end
	if num >= 0 then
		return math.floor(num + 0.5)
	end
	return math.floor(num - 0.5)
end
----------------------------------------------------------------------
-- 功  能：十进制数字转二进制字符串
-- 参  数：decimalism(number类型) - 例115
-- 返回值：二进制字符串,例"1110011"
----------------------------------------------------------------------
function CommonFunc_decimalismToBinary(decimalism)
	local binary = ""
	local function innerFunc(val)
		local divisor = math.floor(val/2)
		local mod = val % 2
		binary = mod..binary
		if 0 == divisor then
			return binary
		end
		return innerFunc(divisor)
	end
	return innerFunc(math.floor(decimalism))
end
----------------------------------------------------------------------
-- 功  能：能：二进制字符串转十进制数字
-- 参  数：binary(string类型) - 例"1110011"
-- 返回值：十进制数字,例115
----------------------------------------------------------------------
function CommonFunc_binaryToDecimalism(binary)
	local decimalism = 0
	local length = string.len(binary)
	for i=1, length do
		local b = string.byte(binary, i) - 48
		decimalism = decimalism + b*(2^(length-i))
	end
	return decimalism
end
----------------------------------------------------------------------
-- 功  能：计算字符的占位数
-- 参  数：ch - 字符
-- 返回值：占位数
----------------------------------------------------------------------
function CommonFunc_characterPlaceholder(ch)
	local charsets = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local i = #charsets
	while charsets[i] do
		if ch >= charsets[i] then
			return i
		end
		i = i - 1
	end
end
----------------------------------------------------------------------
-- 功  能：获取字符串字符个数
-- 参  数：str - 字符串
-- 返回值：总个数,单字节个数,多字节个数
----------------------------------------------------------------------
function CommonFunc_stringLength(str)
	if nil == str or '' == str or "" == str then
		return 0
	end
	local totalCount, singleCount, multiCount = 0, 0, 0
	local startPos = 1
	while startPos <= string.len(str) do
		local placeholder = CommonFunc_characterPlaceholder(string.byte(str, startPos))
		startPos = startPos + placeholder
		if 1 == placeholder then	-- single byte character
			singleCount = singleCount + 1
		else						-- multibyte character
			multiCount = multiCount + 1
		end
		totalCount = totalCount + 1
	end
	return totalCount, singleCount, multiCount
end
----------------------------------------------------------------------
-- 功  能：分割字符串
-- 参  数：str - 字符串,separator - 分隔符,isNumber - 是否是数字类型
-- 返回值：字符串数组
----------------------------------------------------------------------
function CommonFunc_split(str, separator, isNumber)
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
----------------------------------------------------------------------
-- 功  能：将秒转化为 倒计时形式
-- 参  数: seconds(number类型)
-- 返回值：剩余倒计时
----------------------------------------------------------------------
function CommonFunc_secToString(seconds)
	local t = seconds;
	local remain;
	local days = math.floor(t / (60 * 60 * 24));
	remain = t % (60 * 60 * 24);
	local hours = remain / (60 * 60);
	remain = remain % (60 * 60);
	local mins = remain / 60;
	remain = remain % 60;
	local rt =""
	if (days >= 1) then
		rt = string.format("%d天",days)
	end
	hours = math.floor(hours)
	mins = math.floor(mins)
	remain = math.floor(remain)
	
	rt = rt..string.format("%02d:%02d:%02d", hours, mins, remain)
	return rt
end
----------------------------------------------------------------------
-- 功  能：把哈希表转为数组
-- 参  数：哈希表
-- 返回值：数组
----------------------------------------------------------------------
function CommonFunc_hashToArray(hashTable)
	local arrayTable = {}
	for key, val in pairs(hashTable) do
		table.insert(arrayTable, val)
	end
	return arrayTable
end
----------------------------------------------------------------------
-- 功  能：合并两个数组
-- 参  数：数组
-- 返回值：数组
----------------------------------------------------------------------
function CommonFunc_joinArray(headTable, tailTable)
	for key, val in pairs(tailTable) do
		table.insert(headTable, val)
	end
	return headTable
end
----------------------------------------------------------------------
-- 功  能：将table反过来排序
-- 参  数: tb(table)
-- 返回值：tb
----------------------------------------------------------------------
function CommonFunc_InvertedTable(tb)
	local a = {}
		for key ,value in pairs(tb) do  
			a[#tb +1 - key] = value
		end
	return a
end
----------------------------------------------------------------------
-- 功  能：解析字符串元组
-- 参  数: 字符串格式:{{1,2,3},{4,5,6}}或{{"a","b","c"},{"d","e","f"}}
-- 返回值：数字元组
----------------------------------------------------------------------
function CommonFunc_parseStringTuple(stringTuple, isNumber)
	local numberTuple = {}
	local stringTable = CommonFunc_split(stringTuple, "},{")
	for key, val in pairs(stringTable) do
		local strVal = string.gsub(string.gsub(val, "{", ""), "}", "")
		table.insert(numberTuple, CommonFunc_split(strVal, ",", isNumber))
	end
	return numberTuple
end
function CommonFunc_parseTuple(stringTuple, isNumber)
	local function removeLRBracket(str)
		local leftB, rightB, pos, count = 0, 0, 1, 0
		while pos <= string.len(str) do
			local ch = string.sub(str, pos, pos)
			if "{" == ch then
				count = count + 1
				if 0 == leftB then
					leftB = pos
				end
			elseif "}" == ch then
				count = count - 1
			end
			if 0 == count then
				rightB = pos
				break
			end
			pos = pos + 1
		end
		if 1 == leftB and string.len(str) == rightB then
			return string.sub(str, leftB + 1, rightB - 1), true
		end
		return str, false
	end
	local function innerParse(str, tuple, index)
		index = index or 1
		local tempStr, removeFlag = removeLRBracket(str)
		local tempTuple = nil
		if true == removeFlag then
			tuple[index] = {}
			tempTuple = tuple[index]
		else
			tempTuple = tuple
		end
		if nil == string.find(tempStr, ",") then
			if true == removeFlag then
				if true == isNumber then
					table.insert(tempTuple, tonumber(tempStr))
				else
					table.insert(tempTuple, tempStr)
				end
			else
				if true == isNumber then
					tempTuple[index] = tonumber(tempStr)
				else
					tempTuple[index] = tempStr
				end
			end
		else
			local blockTable, blockStr, startPos, left, right = {}, "", 1, 0, 0
			while startPos <= string.len(tempStr) do
				local character = string.sub(tempStr, startPos, startPos)
				startPos = startPos + 1
				if "," == character and left == right then
					table.insert(blockTable, blockStr)
					character, blockStr, left, right = "", "", 0, 0
				elseif "{" == character then
					left = left + 1
				elseif "}" == character then
					right = right + 1
				end
				blockStr = blockStr..character
			end
			assert(left == right, stringTuple.." format is error")
			table.insert(blockTable, blockStr)
			for key, val in pairs(blockTable) do
				innerParse(val, tempTuple, key)
			end
		end
	end
	local tupleTable = {}
	innerParse(stringTuple, tupleTable)
	return tupleTable
end
----------------------------------------------------------------------
-- 功  能：获取节点child相对应于父节点parent的位置
-- 参  数: parent - 父节点;isParentScrollView - 父节点是否为UIScrollView;child - 子节点;pos - 初始填nil
-- 返回值：位置
function CommonFunc_getRelativePos(parent, isParentScrollView, child, pos)
	local parentNode = child:getParent()
	local childPos = child:getPosition()
	local relativePos = ccpAdd(childPos, pos or ccp(0, 0))
	if nil == parent or nil == parentNode or parent == parentNode then
		return relativePos
	end
	if isParentScrollView and tolua.cast(parent, "UIScrollView") and parent:getInnerContainer() == parentNode then
		return relativePos
	end
	return CommonFunc_getRelativePos(parent, isParentScrollView, parentNode, relativePos)
end
----------------------------------------------------------------------
-- 功  能：根据品质值获取相关信息
-- 参  数: quality - 品质值[1-6]
-- 返回值：品质框图片,星级,品质对应颜色
----------------------------------------------------------------------
function CommonFunc_getQualityInfo(quality)
	quality = tonumber(quality or 1)
	local qualityInfo = {image="frame_white.png", star=0, color=ccc3(255, 255, 255)}
	if quality_type["white"] == quality then
		qualityInfo.image = "frame_white.png"
		qualityInfo.star = 0
		qualityInfo.color = ccc3(255, 255, 255)
	elseif quality_type["green"] == quality then
		qualityInfo.image = "runekuan_2.png"
		qualityInfo.star = 1
		qualityInfo.color = ccc3(114, 255, 0)
	elseif quality_type["blue"] == quality then
		qualityInfo.image = "runekuan_3.png"
		qualityInfo.star = 2
		qualityInfo.color = ccc3(0, 187, 255)
	elseif quality_type["purple"] == quality then
		qualityInfo.image = "runekuan_4.png"
		qualityInfo.star = 3
		qualityInfo.color = ccc3(175, 20, 255)
	elseif quality_type["orange"] == quality then
		qualityInfo.image = "runekuan_5.png"
		qualityInfo.star = 4
		qualityInfo.color = ccc3(255, 144, 0)
	elseif quality_type["red"] == quality then
		qualityInfo.image = "runekuan_6.png"
		qualityInfo.star = 5
		qualityInfo.color = ccc3(255, 0, 0)
	end
	return qualityInfo
end
----------------------------------------------------------------------
-- 功  能：设置品质框
-- 参  数: quality(int)-品质,num(int)-左上角显示的数值,count(int)-右下角显示的数量
-- 返回值：空
----------------------------------------------------------------------
function CommonFunc_SetQualityFrame(node, quality, num, count)
	quality = tonumber(quality or 1)
	-- 品质框
	local qualityImage = tolua.cast(node:getChildByName("UIImageView_quality"), "UIImageView")
	if nil == qualityImage then
		qualityImage = UIImageView:create()
		qualityImage:setName("UIImageView_quality")
		node:addChild(qualityImage)
	end
	qualityImage:loadTexture(CommonFunc_getQualityInfo(quality).image)
	qualityImage:setVisible(true)
	-- 左上角数值
	num = num or 0
	num = tonumber(num)
	local showNum = quality > 1
	local numLabel = tolua.cast(qualityImage:getChildByName("UILabelAtlas_num"), "UILabelAtlas")
	if nil == numLabel and showNum then
		numLabel = UILabelAtlas:create()
		numLabel:setName("UILabelAtlas_num")
		numLabel:setProperty("01234567890", "num_black.png", 24, 32, "0")
		numLabel:setScale(0.5)
		numLabel:setPosition(ccp(-40, 33))
		qualityImage:addChild(numLabel)
	end
	if numLabel then
		numLabel:setStringValue(string.format("X%d", num))
		numLabel:setVisible(showNum)
	end
	-- 右下角数量
	count = count or 0
	count = tonumber(count)
	local showCount = count > 1
	local countLabel = tolua.cast(qualityImage:getChildByName("UILabelAtlas_count"), "UILabelAtlas")
	if nil == countLabel and showCount then
		countLabel = UILabelAtlas:create()
		countLabel:setName("UILabelAtlas_count") 
		countLabel:setProperty("01234567890", "labelatlasimg.png", 24, 32, "0")
		countLabel:setAnchorPoint(ccp(1.0, 0.5))
		countLabel:setScale(0.6)
		countLabel:setPosition(ccp(39, -31))
		qualityImage:addChild(countLabel)
	end
	if countLabel then
		countLabel:setStringValue(string.format("X%d", count))
		countLabel:setVisible(showCount)
	end
end
----------------------------------------------------------------------
-- 功  能：添加物品格子控件
-- 参  数: itemID(int)-物品模板id,amount(int)-数量,num(int)-左上角数值,callBackFunc(function)-点击回调
-- 返回值：物品格子
----------------------------------------------------------------------
function CommonFunc_AddGirdWidget(itemID, amount, num, callBackFunc, widget)
	itemID = itemID or 0
	itemID = tonumber(itemID)
	tolua.cast(widget, "UIImageView")
	if nil == widget then
		widget = UIImageView:create()
		widget:setName("UIImageView_Gird")
	end
	-- 回调
	if nil == callBackFunc then
		widget:setTouchEnabled(false)
	else
		widget:registerEventScript(callBackFunc)
		widget:setTouchEnabled(true)
	end
	-- 物品信息
	local strIcon = "frame_white.png"
	local quality = nil
	if itemID > 0 then
		local itemRow = LogicTable.getItemById(itemID)
		strIcon = itemRow.icon
		quality = itemRow.quality
	end
	widget:loadTexture(strIcon)
	-- 添加品质框
	CommonFunc_SetQualityFrame(widget, quality, num, amount)
	return widget
end
--itemPngFile : ITEM资源文件
function reward_AddGirdWidget(itemPngFile, itemID,amount, num, callBackFunc, widget)
	tolua.cast(widget, "UIImageView")
	if nil == widget then
		widget = UIImageView:create()
		widget:setName("UIImageView_Gird")
	end
	-- 回调
	if nil == callBackFunc then
		widget:setTouchEnabled(false)
	else
		widget:registerEventScript(callBackFunc)
		widget:setTouchEnabled(true)
	end
	-- 物品信息
	local strIcon = "frame_white.png"
	local quality = nil
	if itemPngFile ~= nil then 
		strIcon = itemPngFile
	end
	if itemID > 0 then
		local itemRow = LogicTable.getItemById(itemID)
		quality = itemRow.quality
	end
	widget:loadTexture(strIcon)
	-- 添加品质框
	CommonFunc_SetQualityFrame(widget, quality, num, amount)
	return widget
end
----------------------------------------------------------------------
-- 功  能：添加符文格子控件
-- 参  数: runeID(int)-符文模板id,level(int)-等级,callBackFunc(function)-点击回调
-- 返回值：符文格子
----------------------------------------------------------------------
function CommonFunc_AddGirdWidget_Rune(runeID, level, callBackFunc, widget)
	tolua.cast(widget, "UIImageView")
	if nil == widget then
		widget = UIImageView:create()
		widget:setName("UIImageView_Gird")
	end
	-- 回调
	if nil == callBackFunc then
		widget:setTouchEnabled(false)
	else
		widget:registerEventScript(callBackFunc)
		widget:setTouchEnabled(true)
	end
	-- 符文信息
	local skillBaseInfo = SkillConfig.getSkillBaseInfo(runeID)
	widget:loadTexture(skillBaseInfo.icon)
	-- 添加品质框
	CommonFunc_SetQualityFrame(widget, skillBaseInfo.quality, level, 1)
	-- 添加技能类型
	local showDetail = skillBaseInfo.special_detail > 0
	local detailImage = tolua.cast(widget:getChildByName("UIImageView_detail"), "UIImageView")
	if nil == detailImage and showDetail then
		detailImage = UIImageView:create()
		detailImage:setName("UIImageView_detail")
		detailImage:setPosition(ccp(28, -28))
		widget:addChild(detailImage)
	end
	if detailImage then
		if showDetail then
			detailImage:loadTexture(string.format("skill_special_detail%d.png", skillBaseInfo.special_detail))
		end
		detailImage:setVisible(showDetail)
	end
	return widget
end
----------------------------------------------------------------------
-- 功  能：统计表元素个数
-- 参  数: tablevalue(table)
-- 返回值：iCount(int) 图片名
----------------------------------------------------------------------
function CommonFunc_GetTableCount(tablevalue)   
	if nil == tablevalue then
		return 0
	end
	local iCount = 0
	for key, val in pairs(tablevalue) do
		iCount = iCount + 1
	end
	return iCount
end
----------------------------------------------------------------------
-- 功  能：获得职业名称
-- 参  数: roleType(int)职业类型序号
-- 返回值：str(string)职业名称
----------------------------------------------------------------------
function CommonFunc_GetRoleTypeString(roleType)
	local strRoleType = ""
	if 0 == roleType then
		strRoleType = "通用"
	elseif 1 == roleType then
		strRoleType = "战士"
	elseif 2 == roleType then
		strRoleType = "圣骑"
	elseif 3 == roleType then
		strRoleType = "萨满"
	elseif 4 == roleType then
		strRoleType = "法师"
	end
	return strRoleType
end
----------------------------------------------------------------------
-- 功  能：获得装备名称
-- 参  数: equipType(int)装备类型序号
-- 返回值：str(string),str(string)装备名称
----------------------------------------------------------------------
function CommonFunc_GetEquipTypeString(equipType)
    local equipType, subType = math.floor(equipType/10), equipType % 10
	local equipTypeStr, subTypeStr = "", ""
    if equipment_type["weapon"] == equipType then
		equipTypeStr = "武器"
		if 1 == subType then
			subTypeStr = "双手斧"
		elseif 2 == subType then
			subTypeStr = "双手剑"
		elseif 3 == subType then
			subTypeStr = "法槌"
		elseif 4 == subType then
			subTypeStr = "法杖"
		end
	elseif equipment_type["armor"] == equipType then
		equipTypeStr = "护甲"
	elseif equipment_type["necklace"] == equipType then
		equipTypeStr = "项链"
	elseif equipment_type["ring"] == equipType then
		equipTypeStr = "戒指"
	elseif equipment_type["jewelry"] == equipType then
		equipTypeStr = "饰品"
	elseif equipment_type["medal"] == equipType then
		equipTypeStr = "勋章"
	end
    return equipTypeStr, subTypeStr
end
--物品个数统计
function CommonFunc_ItemStatistics(itemTable)
	local newTable = {}
	for key,val in pairs(itemTable) do
		if newTable[val.item_id] == nil then
			newTable[val.item_id] = val
		else 
			newTable[val.item_id].count = newTable[val.item_id].count + val.count
		end
	end
	local tempTable = {}
	for key,val in pairs(newTable) do
		table.insert(tempTable,val)
	end
	
	return tempTable
end
----------------------------------------------------------------------
-- 功  能：设置按钮控件是否显示 并且激活or关闭交互
-- 参  数: node(UIWidget)控件节点  bShow true显示 false隐藏
-- 返回值：
----------------------------------------------------------------------
function CommonFunc_SetWidgetTouch(node,bShow)
	if node == nil then
		cclog("CommonFunc_SetWidgetTouch()当前节点为空")
		return
	end
	node:setVisible(bShow)
	node:setEnabled(bShow)
end
----------------------------------------------------------------------
-- 功  能：快速创建对话框
-- 参  数: strText 显示文本信息
-- 返回值：
---------------------------------------------------------------------
function CommonFunc_CreateDialog(strText)
	local structConfirm = {strText = ""}
	structConfirm.strText = strText
	UIManager.push("UI_ComfirmDialog",structConfirm)
end
----------------------------------------------------------------------
-- 功  能：判断当前金币是否满足玩家购买行为，false不足弹出提示框
-- 参  数: gold 金币  emoney代币 friend友情点
-- 返回值：
---------------------------------------------------------------------
function CommonFunc_IsConsume(gold, emoney, friend)
	gold = gold or 0
	emoney = emoney or 0
	friend = friend or 0
	
	local structConfirm = 
	{
		strText = ",是否前往充值",
		buttonCount = 2,
		buttonName = {"充值", "取消"},
		buttonEvent = {nil, nil},		-- 回调函数
		buttonEvent_Param = {nil, nil}	-- 函数参数
	}
	
	local str = nil 
	if ModelPlayer.getGold() < gold + 0 then
		str = "玩家金币不足"
	elseif ModelPlayer.getEmoney() < emoney + 0 then
		str = "玩家魔石不足"
	elseif ModelPlayer.getFriendPoint() < friend + 0 then
		str = "友情点不足"
	end
	if nil == str then
		return true
	end
	
	structConfirm.strText = str..structConfirm.strText
	UIManager.push("UI_ComfirmDialog", structConfirm)
	return false
end
----------------------------------------------------------------------
-- 装备属性中文描述
function CommonFunc_getAttrString(atrr)
	local attrString = 
	{
		["life"] = "PUBLIC_LIFE",
		["atk"] = "PUBLIC_ATTACK",
		["speed"] = "PUBLIC_SPEED",
		["hit_ratio"] = "PUBLIC_HIT",
		["critical_ratio"] = "PUBLIC_CRITICAL",
		["miss_ratio"] = "PUBLIC_MISS",
		["tenacity"] = "PUBLIC_TENACITY"
	}
	return GameString.get(attrString[atrr])
end

-- 获取有效的属性
function CommonFunc_getEffectAttrs(info)
	local effectAttrs = {}
	if nil == info then
		return effectAttrs
	end
	local attrTable = {"life", "atk", "speed", "hit_ratio", "critical_ratio", "miss_ratio", "tenacity"}
	for key, val in pairs(attrTable) do
		if "number" == type(info[val]) and 0 ~= info[val] then
			table.insert(effectAttrs, val)
		end
	end
	return effectAttrs
end

-- 获得属性描述
function CommonFunc_getAttrDescTable(info)
	local attrDescTb, attrTb, attrValueTb = {}, {}, {}
	local effectAttrs = CommonFunc_getEffectAttrs(info)
	for key, val in pairs(effectAttrs) do
		local attrStr = CommonFunc_getAttrString(val)
		table.insert(attrDescTb, string.format("%s:%d", attrStr, info[val]))
		table.insert(attrTb, val)
		table.insert(attrValueTb, info[val])
	end
	return attrDescTb, attrTb, attrValueTb
end
----------------------------------------------------------------------
-- 功  能：获取Label
-- 参  数: rootNode: 节点, name:label名, fntFile:BMF file, bIsAtlas:是否是UILabelAtlas
-- 返回值：Label
-- Created by fjut on 14-03-13
---------------------------------------------------------------------
function CommonFunc_getLabelByName(rootNode, name, fntFile, bIsAtlas)
	if rootNode == nil then
		cclog("getLabel fail, rootNode should not be nil !")
		return nil
	end
	
	if name == nil then
		cclog("getLabel fail, name should not be nil !")
		return nil
	end
	
	if type(name) ~= "string" then
		cclog("getLabel fail, name should be a type of string ! "..name)
		return nil
	end
	
	-- BMF
	if fntFile ~= nil then
		if type(fntFile) ~= "string" then
			cclog("getLabel fail, fntFile should be a type of string ! "..fntFile)
			return nil
		end
		local label = rootNode:getChildByName(name)
		if label == nil then
			cclog("getLabel fail, "..name.." don't exist on the rootNode !")
			return nil
		end
		tolua.cast(label, "UILabelBMFont")
		label:setFntFile(fntFile)
		return label
	end
	
	-- Atlas
	if bIsAtlas ~= nil then
		local label = rootNode:getChildByName(name)
		if label == nil then
			cclog("getLabel fail, "..name.." don't exist on the rootNode !")
			return nil
		end
		tolua.cast(label, "UILabelAtlas")
		return label
	end
	
	-- TTF
	local label = rootNode:getChildByName(name)
	if label == nil then
		cclog("getLabel fail, "..name.." don't exist on the rootNode !")
		return nil
	end
	tolua.cast(label, "UILabel")
	
	return label
end
	
----------------------------------------------------------------------
-- 功  能：获取UINode
-- 参  数: rootNode: 节点, name: node名, nodeType: node type
-- 返回值：UINode
-- Created by fjut on 14-03-13
---------------------------------------------------------------------
function CommonFunc_getNodeByName(rootNode, name, nodeType)
	if rootNode == nil then
		cclog("getNode fail, rootNode should not be nil !")
		return nil
	end
	
	if name == nil then
		cclog("getNode fail, name should not be nil !")
		return nil
	end
	
	if type(name) ~= "string" then
		cclog("getNode fail, name should be a type of string ! "..name)
		return nil
	end
	
	if nodeType == nil then
		local node = rootNode:getChildByName(name)
		if node == nil then
			cclog("getNode fail, "..name.." don't exist on the rootNode !")
		end
		return node
	end
	
	if type(nodeType) ~= "string" then
		cclog("getNode fail, nodeType should be a type of string ! "..nodeType)
		return nil
	end
	
	local node = rootNode:getChildByName(name)
	if node == nil then
		cclog("getNode fail, "..name.." don't exist on the rootNode !")
		return nil
	end
	tolua.cast(node, nodeType)
	
	return node
end

----------------------------------------------------------------------
-- 功  能：获取UIImageView
-- 参  数: imgName: 图片名, bIsPlist: 是否是打包图
-- 返回值：UIImageView
-- Created by fjut on 14-03-18
---------------------------------------------------------------------
function CommonFunc_getImgView(imgName, bIsPlist)
	if "string" ~= type(imgName) then
		cclog("getImgView fail, imgName should be a type of string, not "..type(imgName))
		return nil
	end
	local uiImg = UIImageView:create()
	if true == bIsPlist then
		uiImg:loadTexture(imgName, UI_TEX_TYPE_PLIST)
	else
		uiImg:loadTexture(imgName)
	end
	return uiImg
end

----------------------------------------------------------------------
-- 功  能：获取UILabel
-- 参  数: strValue: string, 
-- 返回值：UILabel
-- Created by fjut on 14-03-19
---------------------------------------------------------------------
function CommonFunc_getLabel(strValue, fontSize, fontColor, fontName)
	if strValue == nil then
		cclog("getLabel fail, strValue should not be nil !")
		return nil
	end
	
	if type(strValue) ~= "string" then
		cclog("getLabel fail, strValue should be a type of string !")
		return nil
	end
	
	-- UILabel
	local defaultLabel = 
	{
		["fontSize"] = 25,
		["fontColor"] = ccc3(255, 255, 255),
		["fontName"] = "Arial",
	}
	
	-- fontSize
	if fontSize == nil then
		fontSize = defaultLabel["fontSize"]
	end
	
	-- fontColor
	if fontColor == nil then
		fontColor = defaultLabel["fontColor"]
	end
	
	-- fontName
	if fontName == nil then
		fontName = defaultLabel["fontName"]
	end
	
	-- UIlabel
	local label = UILabel:create() 
	label:setText(strValue)
	label:setFontSize(fontSize)
	label:setColor(fontColor)
	label:setFontName(fontName)
	
	return label
end

----------------------------------------------------------------------
-- 功  能：获取UILabelAtlas
-- 参  数: strValue: string
-- 返回值：UILabelAtlas
-- Created by fjut on 14-03-19
---------------------------------------------------------------------
function CommonFunc_getAtlas(strValue, charMapFile, itemWidth, itemHeight, startCharMap)
	if strValue == nil then
		cclog("getAtlas fail, strValue should not be nil !")
		return nil
	end
	
	if type(strValue) ~= "string" then
		cclog("getAtlas fail, strValue should be a type of string !")
		return nil
	end
	
	-- UILabelAtlas
	local defaultAltas = 
	{
		["file"] = "labelatlasimg.png",
		["width"] = 24,
		["height"] = 32,
		["startChar"] = "0",
		["useSpriteFrame"] = false
	}
	
	local label = UILabelAtlas:create()
	if charMapFile == nil then
		label:setProperty(strValue, defaultAltas["file"], defaultAltas["width"], defaultAltas["height"], defaultAltas["startChar"]);
	else
		label:setProperty(strValue, charMapFile, itemWidth, itemHeight, startCharMap);
	end
	
	return label
end

----------------------------------------------------------------------
-- 功  能：获取CCSprite
-- 参  数: imgName: 图片名, plistName: plist名
-- 返回值：CCSprite Node
-- Created by fjut on 14-03-18
---------------------------------------------------------------------
function CommonFunc_getSprite(imgName, plistName)
	if imgName == nil then
		cclog("getSprite fail, imgName should not be nil !")
		return nil
	end
	
	if type(imgName) ~= "string" then
		cclog("getSprite fail, imgName should be a type of string !")
		return nil
	end
	
	if plistName == nil then
		return CCSprite:create(imgName)
	end

	local sp = nil
	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	local spFrame = frameCache:spriteFrameByName(imgName)
	if spFrame == nil then
		frameCache:addSpriteFramesWithFile(plistName)
		spFrame = frameCache:spriteFrameByName(imgName)
	end
	if spFrame ~= nil then
		sp = CCSprite:createWithSpriteFrame(spFrame)
	end

	return sp
end

----------------------------------------------------------------------
-- 功  能：full in UIScrollView
-- 参  数: rootNode: 节点, ScrollViewName：scrollview控件名, tbCellInfo: UIWidget table, 
--         direction: "H"(横向)、"V"(纵向), cellOffsetSpace:cell之间间隔, 
--		   cellOffsetPos: cell偏移位置, sliderName:slider控件名 
-- 返回值：UIScrollView
-- Created by fjut on 14-03-18
---------------------------------------------------------------------
function CommonFunc_getScrollViewFromNode(rootNode, ScrollViewName, tbCellInfo, direction, cellOffsetSpace, cellOffsetPos, sliderName)
	if rootNode == nil then
		cclog("getScrollViewFromNode fail, rootNode should not be nil !")
		return nil
	end
	
	if tbCellInfo == nil or #tbCellInfo == 0 then
		cclog("getScrollViewFromNode fail, tbCellInfo should not be nil ! ")
		return nil
	end
	
	-- scrollview
	local scrollView = rootNode:getChildByName(ScrollViewName)
	if scrollView == nil then
		cclog("getScrollViewFromNode fail, "..ScrollViewName.." don't exist on the rootNode !")
		return nil
	end
	tolua.cast(scrollView, "UIScrollView")
	scrollView:removeAllChildren()
	scrollView:setBounceEnabled(false) -- should be false
	direction = (direction == nil) and "V" or direction
	direction = (direction == "V") and LISTVIEW_DIR_VERTICAL or LISTVIEW_DIR_HORIZONTAL
	scrollView:setDirection(direction)
	
	local totalLength = 0
	-- 纵向
	if direction == LISTVIEW_DIR_VERTICAL then
		totalLength = (#tbCellInfo)*tbCellInfo[1]:getContentSize().height
		scrollView:setInnerContainerSize(CCSize(scrollView:getSize().width, totalLength))
		totalLength = scrollView:getInnerContainerSize().height
	-- 横向
	else
		totalLength = (#tbCellInfo)*tbCellInfo[1]:getContentSize().width
		scrollView:setInnerContainerSize(CCSize(totalLength, scrollView:getSize().height))
		totalLength = scrollView:getInnerContainerSize().width
	end	

	-- cell 的偏移位置
	cellOffsetPos = (cellOffsetPos == nil) and 30 or cellOffsetPos
	-- cell 之间间隔
	cellOffsetSpace = (cellOffsetSpace == nil) and 0 or cellOffsetSpace
	
	for k, value in next, (tbCellInfo) do
		local node = tbCellInfo[k]
		node:setAnchorPoint(ccp(0, 0))
		-- 纵向
		if direction == LISTVIEW_DIR_VERTICAL then
			scrollView:setInnerContainerSize(CCSize(scrollView:getSize().width, (#tbCellInfo)*tbCellInfo[1]:getContentSize().height))
			local h = totalLength - tbCellInfo[1]:getContentSize().height - tbCellInfo[1]:getContentSize().height*(k-1) -- - cellOffsetSpace*(k - 1)
			tbCellInfo[k]:setPosition(ccp(cellOffsetPos, h))
		-- 横向
		else
			scrollView:setInnerContainerSize(CCSize((#tbCellInfo)*tbCellInfo[1]:getContentSize().width, scrollView:getSize().height))
			local w = tbCellInfo[1]:getContentSize().width*(k-1)  -- totalLength - tbCellInfo[1]:getContentSize().width*0.5 - 
			tbCellInfo[k]:setPosition(ccp(w, cellOffsetPos))
		end	
		scrollView:addChild(node)
	end
	
	if (sliderName == nil) then
		return scrollView
	end
	
	-- slider
	local slider = rootNode:getChildByName(sliderName)
	if slider == nil then
		cclog("getSlider fail, "..sliderName.." don't exist on the rootNode !")
		return scrollView
	end
	tolua.cast(slider, "UISlider")
	slider:setPercent(0)
	scrollView:registerEventScript(function(typename, widget) 
						local scrollViewInnerCon = scrollView:getInnerContainer()
						local innerHei = scrollViewInnerCon:getSize().height
						local innerPosY = scrollViewInnerCon:getPosition().y
						local scrollHei = scrollView:getSize().height
						local scrollPosY = scrollView:getPosition().y
						if "scrolling" == typename then
							--cclog("scrolling")
							local per = math.abs(innerPosY)/(innerHei-scrollHei)*100
							slider:setPercent(100 - per)
						end
					end)
	
	return scrollView
end

----------------------------------------------------------------------
-- 功  能：create UIScrollView
-- 参  数: tbCellInfo: UIWidget table, size:xx
--         direction: "H"(横向)、"V"(纵向), cellOffsetSpace:cell之间间隔, cellOffsetPos: cell偏移位置 
-- 返回值：UIScrollView
-- Created by fjut on 14-04-16
---------------------------------------------------------------------
function CommonFunc_getScrollView(size, tbCellInfo, direction, cellOffsetSpace, cellOffsetPos)
	if tbCellInfo == nil or #tbCellInfo == 0 or size == nil then
		cclog("getScrollView fail, the param is bad ! ")
		return nil
	end
	
	-- scrollview
	local scrollView = UIScrollView:create()
	scrollView:setBounceEnabled(false) -- should be false
	direction = (direction == nil) and "V" or direction
	direction = (direction == "V") and LISTVIEW_DIR_VERTICAL or LISTVIEW_DIR_HORIZONTAL
	scrollView:setDirection(direction)
	scrollView:setSize(size)
	
	-- cell 的偏移位置
	cellOffsetPos = (cellOffsetPos == nil) and 0 or cellOffsetPos
	-- cell 之间间隔
	cellOffsetSpace = (cellOffsetSpace == nil) and 0 or cellOffsetSpace
	
	local totalLength = 0
	-- 纵向
	if direction == LISTVIEW_DIR_VERTICAL then
		totalLength = (#tbCellInfo)*tbCellInfo[1]:getContentSize().height
		scrollView:setInnerContainerSize(CCSize(scrollView:getSize().width, totalLength))
		totalLength = scrollView:getInnerContainerSize().height
	-- 横向
	else
		totalLength = (#tbCellInfo)*tbCellInfo[1]:getContentSize().width
		scrollView:setInnerContainerSize(CCSize(totalLength, scrollView:getSize().height))
		totalLength = scrollView:getInnerContainerSize().width
	end	
	
	for k, value in next, (tbCellInfo) do
		local node = tbCellInfo[k]
		node:setAnchorPoint(ccp(0, 0))
		-- 纵向
		if direction == LISTVIEW_DIR_VERTICAL then
			scrollView:setInnerContainerSize(CCSize(scrollView:getSize().width, (#tbCellInfo)*tbCellInfo[1]:getContentSize().height))
			local h = totalLength - tbCellInfo[1]:getContentSize().height - tbCellInfo[1]:getContentSize().height*(k-1)
			tbCellInfo[k]:setPosition(ccp(cellOffsetPos, h))
		-- 横向
		else
			scrollView:setInnerContainerSize(CCSize((#tbCellInfo)*tbCellInfo[1]:getContentSize().width, scrollView:getSize().height))
			local w = tbCellInfo[1]:getContentSize().width*(k-1)  -- totalLength - tbCellInfo[1]:getContentSize().width*0.5 - 
			tbCellInfo[k]:setPosition(ccp(w, cellOffsetPos))
		end	
		scrollView:addChild(node)
	end			
	
	return scrollView
end

----------------------------------------------------------------------
-- 功  能：create UISlider
-- 参  数: sliderSize:CCSizeMake, scrollView:UIScrollView   
-- 返回值：UISlider
-- Created by fjut on 14-04-16
---------------------------------------------------------------------
function CommonFunc_getSlider(sliderSize, scrollView)
	if sliderSize == nil or scrollView == nil then
		cclog("getSlider fail, the param is bad ! ")
		return nil
	end
	
	local slider = UISlider:create()
	--slider:setTouchEnabled(true)
	slider:setScale9Enabled(true)
	slider:setRotation(90)
	slider:loadBarTexture("slider_scale9.png")
	slider:loadSlidBallTextures("slider_Thumb.png", "slider_Thumb.png", "")
	slider:setCapInsets(CCRectMake(0, 0, 0, 0))
	slider:setSize(sliderSize)
	slider:setPercent(0)

	if ( (scrollView:getDirection() == LISTVIEW_DIR_VERTICAL) and (scrollView:getSize().height == scrollView:getInnerContainer():getSize().height) ) 
	or ( (scrollView:getDirection() == LISTVIEW_DIR_HORIZONTAL) and (scrollView:getSize().width == scrollView:getInnerContainer():getSize().width) )then
		slider:setTouchEnabled(false)
		slider:setVisible(false)
	end
	
	scrollView:registerEventScript(function(typename, widget) 
						local scrollViewInnerCon = scrollView:getInnerContainer()
						local innerHei = scrollViewInnerCon:getSize().height
						local innerPosY = scrollViewInnerCon:getPosition().y
						local scrollHei = scrollView:getSize().height
						local scrollPosY = scrollView:getPosition().y
						if "scrolling" == typename then
							local per = math.abs(innerPosY)/(innerHei-scrollHei)*100
							slider:setPercent(100 - per)
						end
					end)
					
	return slider				
end

----------------------------------------------------------------------
-- 功  能：获取 UIButton
-- 返回值：UIButton
-- Created by fjut on 14-03-28
---------------------------------------------------------------------
function CommonFunc_getButton(imgNormal, imgSelected, imgDisabled)
	if imgNormal == nil then
		cclog("getButton fail, imgNormal should not be nil !")
		return nil
	end
	
	local btn = UIButton:create()
	btn:loadTextureNormal(imgNormal, UI_TEX_TYPE_LOCAL)
	
	if imgSelected ~= nil then
		btn:loadTexturePressed(imgSelected, UI_TEX_TYPE_LOCAL)
	end
	
	if imgDisabled ~= nil then
		btn:loadTextureDisabled(imgDisabled, UI_TEX_TYPE_LOCAL)
	end
	
	btn:setTouchEnabled(true)
	btn:setTitleFontSize(25)
	btn:setTitleFontName("Arial")
	
	btn:registerEventScript(function(typename, widget) 
					if "pushDown" == typename then
						Audio.EffectNotify()
					end
				end)
	return btn
end
----------------------------------------------------------------------
-- 功  能：创建CocoStudio文本控件
-- 参  数：anchorPoint-锚点,position-位置,fontName-字体名字,fontSize-字体大小,color-字体颜色,text-文本,tag-标签,zOrder-渲染层级
-- 返回值：UILabel
-- Created by jaron.ho on 2014-03-17 11:30
----------------------------------------------------------------------
function CommonFunc_createUILabel(anchorPoint, position, fontName, fontSize, color, text, tag, zOrder)
	local label = UILabel:create()
	if nil ~= anchorPoint then
		label:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		label:setPosition(position)
	end
	if nil ~= fontName and "" ~= fontName then
		label:setFontName(fontName)
	end
	if nil ~= fontSize and fontSize > 0 then
		label:setFontSize(fontSize)
	end
	if nil ~= color then
		label:setColor(color)
	end
	if nil ~= text then
		label:setText(text)
	end
	if nil ~= tag then
		label:setTag(tag)
	end
	if nil ~= zOrder then
		label:setZOrder(zOrder)
	end
	label:setFontName("fzzdh.TTF")
	return label
end

----------------------------------------------------------------------
-- 功  能：创建CCLabelTTF
-- 参  数：anchorPoint-锚点,position-位置,fontName-字体名字,fontSize-字体大小,color-字体颜色,text-文本,tag-标签,zOrder-渲染层级
-- 返回值：CCLabelTTF
-- Created by jaron.ho on 2014-03-17 11:30
----------------------------------------------------------------------
function CommonFunc_createCCLabelTTF(anchorPoint, position, fontName, fontSize, color, text, tag, zOrder)
	local label = CCLabelTTF:new()
	label:init()
	label:autorelease()
	if nil ~= anchorPoint then
		label:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		label:setPosition(position)
	end
	if nil ~= fontName and "" ~= fontName then
		label:setFontName(fontName)
	end
	if nil ~= fontSize and fontSize > 0 then
		label:setFontSize(fontSize)
	end
	if nil ~= color then
		label:setColor(color)
	end
	if nil ~= text then
		label:setString(text)
	end
	if nil ~= tag then
		label:setTag(tag)
	end
	if nil ~= zOrder then
		label:setZOrder(zOrder)
	end
	return label
end
	
----------------------------------------------------------------------
-- 功  能：创建UIImageView
-- 参  数：anchorPoint-锚点,position-位置,size大小，texture图片，name名字，zOrder渲染层级
-- 返回值：UIImageView
-- Created by lihq on 2014-5-4 11:44
----------------------------------------------------------------------
function CommonFunc_createUIImageView(anchorPoint, position, size, texture, name, zOrder)
	local image = UIImageView:create()
	if nil ~= anchorPoint then
		image:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		image:setPosition(position)
	end
	if nil ~= size then
		image:setSize(size)
	end
	if texture ~= nil then
		image:loadTexture(texture) 
	end
	if zOrder ~= nil then
		image:setZOrder(zOrder)
	end
	if name ~= nil then
		image:setName(name)
	end
	return image
end

----------------------------------------------------------------------
-- 功  能：创建UILayout
-- 参  数：anchorPoint-锚点,position-位置,size大小，texture背景图片，zOrder渲染层级，isplist表示图片是否在plist文件中
-- 返回值：UILayout
-- Created by lihq on 2014-5-4 11:44
----------------------------------------------------------------------
function CommonFunc_createUILayout(anchorPoint,position, size, texture,zOrder)
	local panel = UILayout:create()
	if nil ~= anchorPoint then
		panel:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		panel:setPosition(position)
	end
	if nil ~= size then
		panel:setSize(size)
	end
	if texture ~= nil then
		panel:setBackGroundImage(texture) 
	end
	if zOrder ~= nil then
		panel:setZOrder(zOrder)
	end
	return panel
end
	
----------------------------------------------------------------------
-- 功  能：创建UIButton
-- 参  数：anchorPoint-锚点,position-位置,size大小，texture背景图片，name名字，zOrder渲染层级，isplist表示图片是否在plist文件中
-- 返回值：UIButton
-- Created by lihq on 2014-5-4 11:44
----------------------------------------------------------------------
function CommonFunc_createUIButton(anchorPoint,position, size,fontSize,titleColoor,titleText,name,normalTexture,clickTexture,zOrder)
	local btn = UIButton:create()
	if nil ~= anchorPoint then
		btn:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		btn:setPosition(position)
	end
	if nil ~= size then
		btn:setSize(size)
	end
	if nil ~= fontSize then
		btn:setTitleFontSize(fontSize)
	end
	if nil ~= titleColoor then
		btn:setTitleColor(titleColoor)
	end
	if nil ~= titleText then
		btn:setTitleText(titleText)
	end
	if nil ~= name then
		btn:setName(name)
	end
	if normalTexture ~= nil and clickTexture ~= nil then
		btn:loadTextures(normalTexture,clickTexture, nil)
	end
	if zOrder ~= nil then
		btn:setZOrder(zOrder)
	end
	btn:setTouchEnabled(true)
	return btn
end

-------------------------------------------------------------------
-- 功  能：创建CCEditBox
-- 参  数：锚点,位置,大小,背景图片,tag值，最大长度，隐藏的字，输入模式，返回模式
-- 返回值：CCEditBox
-- Created by lihq on 2014-5-4 11:44
----------------------------------------------------------------------
function CommonFunc_createCCEditBox(anchorPoint,position, size,backGroundImage,tag,length,holderText,inputMode,returnType)
	local edBox 
	
	if backGroundImage ~= nil then
		edBox = CCEditBox:create(size, CCScale9Sprite:create(backGroundImage))
	end
	if tag ~= nil then
		edBox:setTag(tag)
	end
	if length ~= nil then
		edBox:setMaxLength(length)
	end
	if holderText ~= nil then
		edBox:setPlaceHolder(holderText)
	end
	if inputMode ~= nil then
		edBox:setInputMode(inputMode)
	end
	if returnType ~= nil then
		edBox:setReturnType(returnType)
	end
	if nil ~= anchorPoint then
		edBox:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		edBox:setPosition(position)
	end
	edBox:setPlaceholderFontSize(24)
	return edBox
end

function CommonFunc_getSpriteFrame(fileName)
	local texture = CCTextureCache:sharedTextureCache():addImage(fileName)
	local w = texture:getContentSize().width
	local h = texture:getContentSize().height
	return CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, w, h))
end

-- 功  能：文件读写
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
-- 功能：设置进度条数值 
function CommonFunc_ProgressBbar(widget,num,bAction,callBack)
	num = num or 0
	tolua.cast(widget,"UILoadingBar")
	--widget:setPercent(num)
	
	if bAction == true then
		local iCount = 1
		
	end
end

--获得控件坐标
function CommonFunc_GetPos(widget)
	--tolua.cast(widget,"UIWidget")
	local pos = ccp(widget:getPosition().x,widget:getPosition().y)
	return pos
end

--判断是否为整型 true 整型
function CommonFunc_IsInt(num)
	if math.floor(num) == num then
		return true
	end
	return false
end

--关联 Scroll slider 暂时只能用于上下滑动
function CommonFunc_setScrollPosition(scroll,slider)
	tolua.cast(scroll,"UIScrollView")
	tolua.cast(slider,"UISlider")
	
	local scrollFunc = function(typename,widget)
		local contair = scroll:getInnerContainer()
		local height = contair:getSize().height
		local pos = contair:getPosition()
		local kuangH = scroll:getSize().height
		local Ratio = math.abs(pos.y)/(height - kuangH) * 100
		slider:setPercent(100 - Ratio)
	end
	
	local sliderFunc = function(typename,widget)
		local percent = slider:getPercent() 
		local contair = scroll:getInnerContainer()  
		local height = contair:getSize().height
		local width = contair:getSize().width
		local pos = scroll:getInnerContainer():getPosition()	
		local kuangH = scroll:getSize().height
		contair:setPosition(ccp(0,-((100-percent)/100*(height - kuangH))))
		--pos1 = scroll:getInnerContainer():getPosition()
	end
	if scroll ~= nil then
		scroll:registerEventScript(scrollFunc)
	end
	if slider ~= nil then 
		slider:registerEventScript(sliderFunc)
	end
end

--把当前widget相对坐标 转换为世界坐标
function CommonFunc_ConvertWordPosition(widget)
	--装换坐标
	local panel = UIManager.findLayerByTag("UI_Main")
	local position = widget:convertToWorldSpace(CommonFunc_GetPos(panel:getRootWidget()))
	return position
end

--计算两个控件 差值（世界坐标）
function CommonFunc_ConverWordPosition_Diff(widget_1,widget_2)
	local pos_1 = CommonFunc_ConvertWordPosition(widget_1)
	local pos_2 = CommonFunc_ConvertWordPosition(widget_2)
	return ccp(pos_1.x - pos_2.x,pos_1.y - pos_2.y)
end

--表 转换为数字为下标
function CommonFunc_TableConverNumIndex(desTable)
	local tempTable = {}
	for key,val in pairs(desTable) do
		val.key = key
		table.insert(tempTable,val)
	end
	return tempTable
end

function CommonFunc_setBtnStatus(widget, normal, press, disable, touched)
	if true == touched then
		widget:loadTextureNormal(normal)
		widget:loadTexturePressed(press)
		widget:setTouchEnabled(true)
	else
		widget:loadTextureNormal(disable)
		widget:loadTexturePressed(disable)
		widget:setTouchEnabled(false)
	end
end

--创建物品信息独立框:infoType-信息类型(0.奖励,1.物品,2.符文,3.天赋碎片);tempId-模板id;level-等级;showEquipAttr-显示装备属性;
--popUIName-(string:点击前往后需弹出的UI名称;number:1.屏蔽产出前往；2.);
function CommonFunc_showInfo(infoType, tempId, level, showEquipAttr, popUIName)
	if nil == tempId or 0 == tempId then
		return
	end
	level = level or 0
	local tempType = 0
	if 0 == infoType then			-- 奖励
		local rewardItemRow = LogicTable.getRewardItemRow(tempId)
		if 7 == rewardItemRow.type then			-- 物品
			infoType = 1
			tempType = rewardItemRow.type
			tempId = rewardItemRow.temp_id
		elseif 8 == rewardItemRow.type then		-- 符文(技能)
			infoType = 2
			tempType = rewardItemRow.type
			tempId = rewardItemRow.temp_id
		elseif 13 == rewardItemRow.type then		-- 天赋碎片
			infoType = 3
			tempType = rewardItemRow.type
			tempId = rewardItemRow.temp_id
		else
			infoType = 0
			tempType = rewardItemRow.type
			tempId = rewardItemRow.id
		end
	end
	if 0 == infoType then			-- 奖励
		local bundle = {}
		bundle.temp_id = tempId
		bundle.type = tempType
		bundle.is_item = false
		bundle.popUIName = 1
		UIManager.push("UI_ItemInfo", bundle)
	elseif 1 == infoType then		-- 物品
		local itemRow = LogicTable.getItemById(tempId)
		if item_type["equipment"] == itemRow.type then	--装备
			Toast.show("装备没有点击查看详细信息")
			return
		--[[
			local bundle = {}
			bundle.temp_id = tempId
			bundle.type = tempType
			bundle.showEquipAttr = showEquipAttr
			bundle.popUIName = popUIName
			UIManager.push("UI_EquipInfo", bundle)
			]]--
		elseif item_type["gem"] == itemRow.type then	--宝石
			local bundle = {}
			bundle.temp_id = tempId
			bundle.type = tempType
			bundle.popUIName = popUIName
			UIManager.push("UI_GemInfo", bundle)
		else											--其他
			local bundle = {}
			bundle.temp_id = tempId
			bundle.type = tempType
			bundle.is_item = true
			bundle.popUIName = popUIName
			UIManager.push("UI_ItemInfo", bundle)
		end
	elseif 2 == infoType then		-- 符文
		local bundle = {}
		bundle.skill_id = tempId
		bundle.type = tempType
		bundle.level = level
		bundle.popUIName = popUIName
		UIManager.push("UI_SkillInfo", bundle)
	elseif 3 == infoType then		-- 天赋碎片
		local bundle = {}
		bundle.temp_id = tempId
		bundle.type = tempType
		bundle.is_item = false
		bundle.popUIName = popUIName
		UIManager.push("UI_ItemInfo", bundle)
	end
end

--显示获得单个物品提示
function CommonFunc_showGetItemTip(rewardItemId, rewardItemAmount)
	local rewardItem = LogicTable.getRewardItemRow(rewardItemId)
	local rewardItemName = rewardItem.name
	local tipStr = rewardItemName.."x"..rewardItemAmount
	Toast.Textstrokeshow(GameString.get("getItem", tipStr), ccc3(255,255,255), ccc3(0,0,0), 30)
end

--显示获得物品提示
function CommonFunc_showItemGetInfo(itemIds, itemAmounts)
	for i=1, #(itemIds) do
		CommonFunc_showGetItemTip(itemIds[i], itemAmounts[i])
	end
end

--图片飞的函数
function CommonFunc_curMoveAction(duration, fromPoint, toPoint)
	--创建路径数组
	--fromPoint.y = fromPoint.y + 40
	local array=CCPointArray:create(5)
	array:addControlPoint(fromPoint)
	local middlePoint = ccpMidpoint(fromPoint,toPoint)
	
	local delta = 0
	if math.random(1, 100) < 50 then
		delta = math.random(-120, -20)
	else
		delta = math.random(20, 120)
	end
	mbNegation = not mbNegation
	
	array:addControlPoint(ccpAdd(middlePoint,ccp(delta, delta)))
	array:addControlPoint(toPoint)	
	
	return CCCardinalSplineTo:create(duration, array, 0)--0.5)
end

function FightOver_addQuaIconByRewardId(id,widget,amount,func)
	local rewardTb = LogicTable.getRewardItemRow(id)
	if rewardTb.type == 7 then			--物品
		widget = CommonFunc_AddGirdWidget(rewardTb.temp_id, amount, nil, func, widget)
	elseif rewardTb.type == 8 then		--符文
		widget = CommonFunc_AddGirdWidget_Rune(rewardTb.temp_id, 0, func, widget)
	else
		widget = LayerFightReward_AddGirdWidget(rewardTb.icon, amount, func, widget)	
	end
	return widget
end

--根据物品的位置，判断长按信息界面显示位置
function CommonFuncJudgeInfoPosition(widget)
	local leftPosition = ccp(15,480)
	local rightPosition = ccp(423,480)
	local tempPosition_x = 322
	--print("CommonFuncJudgeInfoPosition*******************",widget:getPosition().x,widget:getPosition().y,widget:getWorldPosition().x,widget:getWorldPosition().x)
	if widget:getWorldPosition().x > tempPosition_x then	--显示在左边
		return leftPosition,"left"
	else													--显示在右边
		return rightPosition,"right"
	end
end

--根据位置，加载长按界面进入动画
function CommonFunc_Add_Info_EnterAction(bundle,widget)
	if bundle.position ~= nil then
		if bundle.direct == "left" then			--从右往左滑
			widget:setPosition(ccp(bundle.position.x - 200,bundle.position.y))
			Animation_MoveTo_Rebound(widget,1.0,bundle.position)
		else								--从左往右滑
			widget:setPosition(ccp(bundle.position.x + 200,bundle.position.y))
			Animation_MoveTo_Rebound(widget,1.0,bundle.position)
		end
	end
end

--根据奖励Id，长按显示详细信息
function showLongInfoByRewardId(tempId,widget)
	local rewardItemRow = LogicTable.getRewardItemRow(tempId)
	local position,direct = CommonFuncJudgeInfoPosition(widget)
	local bundle = {}
	bundle.position = position
	bundle.direct = direct
	bundle.is_item = false						
	bundle.itemId = rewardItemRow.temp_id	
	bundle.skill_id = rewardItemRow.temp_id		--技能ID
	bundle.level = 1							--技能等级
	
	if 7 == rewardItemRow.type then			-- 物品
		local itemRow = LogicTable.getItemById(tempId)
		if item_type["equipment"] == itemRow.type then	
			UIManager.push("UI_EquipInfo",bundle)
		elseif item_type["gem"] == itemRow.type then
			UIManager.push("UI_GemInfo_Long",bundle)
		elseif 8 ==  itemRow.type then		-- 技能
			UIManager.push("UI_SkillInfo_Long", bundle)
		else	
			bundle.itemId = tempId
			UIManager.push("UI_ItemInfo_Long",bundle)
		end
	elseif RoleTalent_FragId == tonumber(tempId) then	--天赋碎片特殊处理，当物品
		bundle.itemId = tempId
		UIManager.push("UI_ItemInfo_Long",bundle)
	elseif 13 == rewardItemRow.type then		-- 碎片
		UIManager.push("UI_SkillFragInfo_Long", bundle)
	elseif 8 ==  rewardItemRow.type then		-- 技能
		UIManager.push("UI_SkillInfo_Long", bundle)
	else
		bundle.itemId = tempId
		UIManager.push("UI_ItemInfo_Long",bundle)
	end
end

--根据奖励Id，长按结束回调(tempId——奖励物品Id，widget---需要长按的控件)
function longClickCallback_reward(tempId,widget)
	local rewardItemRow = LogicTable.getRewardItemRow(tempId)
	
	if 7 == rewardItemRow.type then			-- 物品
		local itemRow = LogicTable.getItemById(tempId)
		if item_type["equipment"] == itemRow.type then	
			UIManager.pop("UI_EquipInfo")
		elseif item_type["gem"] == itemRow.type then
			UIManager.pop("UI_GemInfo_Long")
		elseif 8 ==  itemRow.type then		-- 技能
			UIManager.pop("UI_SkillInfo_Long")
		else	
			UIManager.pop("UI_ItemInfo_Long")
		end
	elseif RoleTalent_FragId == tonumber(tempId) then		-- 天赋碎片
		UIManager.pop("UI_ItemInfo_Long")
	elseif 13 == rewardItemRow.type then		-- 碎片
		UIManager.pop("UI_SkillFragInfo_Long")
	elseif 8 ==  rewardItemRow.type then		-- 技能
		UIManager.pop("UI_SkillInfo_Long")
	else
		UIManager.pop("UI_ItemInfo_Long")
	end
end

--碎片结束回调
function CommonFunc_longEnd_frag()
	UIManager.pop("UI_SkillFragInfo_Long")
end

--技能结束回调
function CommonFunc_longEnd_skill()
	UIManager.pop("UI_SkillInfo_Long")
end

--物品、天赋碎片结束回调
function CommonFunc_longEnd_item()
	UIManager.pop("UI_ItemInfo_Long")
end

--宝石结束回调
function CommonFunc_longEnd_gem()
	UIManager.pop("UI_GemInfo_Long")
end

--装备结束回调
function CommonFunc_longEnd_equip()
	UIManager.pop("UI_EquipInfo")
end

-- 长按点击回调(职业特长)
function CommonFunc_longEnd_job(widget)
	UIManager.pop("UI_JobInfo")
end

--控件左右滑入的动画
function Commonfunc_dropAnimation(widget)
	local distance = 200
	local DROPTIME = 0.6
	local pos = widget:getPosition()
	local newPos = ccp(pos.x - distance,pos.y)	
	
	--widget:setVisible(false)
	widget:setTouchEnabled(false)
	
	local function callBack()
		widget:setTouchEnabled(true)
	end
	local array = CCArray:create()
	array:addObject( CCPlace:create(newPos) )
	array:addObject( CCShow:create() )
	array:addObject(CCEaseBackInOut:create(CCMoveBy:create(DROPTIME,CCPointMake(distance,0))))
	array:addObject(CCCallFuncN:create(callBack))
	
	local action = CCSequence:create(array)
	widget:runAction(action)
	
end

----------------------------------------------------------------------
-- 功  能: 判断当前金币或魔石是否满足玩家购买行为，金币不足转换成魔石，魔石不足弹出购买框
-- 参  数: index 类型:1.金币,2.魔石,3.物品表(商城表中有的); amount 所需数量; itemId 所购买物品的id; forceNum 强制购买数量; callBackFunc = {[1]-确定, [2]-取消} 特殊需要的回调函数
-- 返回值: true 金币或魔石足够
---------------------------------------------------------------------
function CommonFunc_payConsume(index, amount, itemId, forceNum, callBackFunc)
	local tb = {}
	local num = nil
	if tonumber(index) == 3 and itemId ~= nil then
		num = ModelBackpack.getItemByTempId(itemId)
		num = (num == nil) and 0 or tonumber(num.amount)
	end
	
	-- 魔石不足，使用RMB支付
	local function rechargeByRMB()
		local mRechargeList = LogicTable.getRechargeTable(ChannelProxy.getChannelId())
		local row = {}
		for key, val in pairs(mRechargeList) do
			if val.type == 2 and tb.emoney < (val.recharge_emoney + val.reward_emoney) then
				row.id = val.id
				break
			end
			if key == #mRechargeList then
				row.id = val.id
			end
		end
		
		local function cancelCallFunc()
			if tb.type == 2 and tb.func[2] ~= nil then
				tb.func[2]()
			end
		end
		
		local function sureCallFunc()
			local rechargeRow = LogicTable.getRechargeRow(row.id)
			if tb.type == 2 and tb.func[1] ~= nil then
				tb.func[1]()
			end
			local isCloseBuy = true
			if true == isCloseBuy then
				Toast.show( GameString.get("RECHARGE_TIP_1"))
				return
			end
			local rechargeRow = LogicTable.getRechargeRow(row.id)
			ChannelProxy.pay(tostring(row.id), tostring(rechargeRow.money/100.0), GameString.get("PUBLIC_CHONG_ZHI"))
		end
		
		local str = string.format("%0.1f", LogicTable.getRechargeRow(row.id).money/100)..GameString.get("PUBLIC_RMB")
		local diaMsg = 
		{
			strText = "",
			id = nil,
			buttonCount = 2,
			buttonName = {GameString.get("GO_TO_PAY"), GameString.get("cancle")},
			buttonEvent = {sureCallFunc, cancelCallFunc},		-- 回调函数
			buttonEvent_Param = {nil, nil}	-- 函数参数
		}
		diaMsg.strText = str..diaMsg.strText
		diaMsg.id = row.id
		UIManager.push("UI_PayByRMB", diaMsg)
	end
	
	local function dialogCancelCall()
		if tb.func[2] ~= nil then
			tb.func[2]()
		end
	end
	
	-- 使用魔石支付
	local function dialogSureCall()
		if ModelPlayer.getEmoney() < tb.emoney + 0 then
			rechargeByRMB()
		elseif tb.type == 1 then
			LayerPayByEmoney.onPayForGold(tb.emoney)
		elseif tb.type == 3 then
			LayerPayByEmoney.onPayForItem(tb)
		end
	end
	local structConfirm = 
	{
		strText = "",
		item = nil,
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, dialogCancelCall},		-- 回调函数
		buttonEvent_Param = {nil, nil}	-- 函数参数
	}
	
	-- 类型判断
	local str = nil
	if tonumber(index) == 1 and ModelPlayer.getGold() < amount + 0 then
		tb.type = tonumber(index)
		tb.emoney = math.ceil((amount - ModelPlayer.getGold())/Exchange_Rate)
		tb.gold = tb.emoney * Exchange_Rate
		str = GameString.get("NEW_RECHARGE_TIP_1", tb.emoney, tb.gold)
	elseif tonumber(index) == 2 and ModelPlayer.getEmoney() < amount + 0 then
		tb.type = tonumber(index)
		tb.emoney = amount - ModelPlayer.getEmoney()
		if callBackFunc ~= nil then
			tb.func = callBackFunc
		else
			tb.func = {nil, nil}
		end
		rechargeByRMB()
		return true
	elseif tonumber(index) == 3 and num ~= nil and num < amount then
		local tmpTbProductsInfo = LogicTable.getAllProductInfo()
		for key, value in pairs(tmpTbProductsInfo) do
			if tonumber(value.item_id) == tonumber(itemId) then
				tb = value
				if forceNum == nil then
					tb.amount = math.ceil((amount - num) / tonumber(value.item_amount))
				else
					tb.amount = math.ceil((forceNum - num) / tonumber(value.item_amount))
				end
				tb.type = tonumber(index)
			end
		end
		if ModelPlayer.getVipLevel() > 0 then
			local price = (tb.vip_discount == 0) and tb.price or (tb.price * tb.vip_discount * 0.01)
			tb.emoney = price * tb.amount
		else
			local price = tonumber(tb.price)
			tb.emoney = price * tb.amount
		end
		local itemTb = LogicTable.getItemById(tb.item_id)
		str = GameString.get("NEW_RECHARGE_TIP_2", tb.emoney, LogicTable.getItemById(tb.item_id).name, tb.amount * tb.item_amount)
	end
	if nil == str then
		return false
	end
	
	if callBackFunc ~= nil then
		tb.func = callBackFunc
	else
		tb.func = {nil, nil}
	end
	
	structConfirm.strText = str..structConfirm.strText
	structConfirm.item = tb
	UIManager.push("UI_PayByEmoney", structConfirm)
	
	return true
end
