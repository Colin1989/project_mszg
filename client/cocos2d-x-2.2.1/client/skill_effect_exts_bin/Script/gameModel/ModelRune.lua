
ModelRune = {}

local xml_tplt = XmlTable_load("sculpture_tplt.xml")
local xml_divine = XmlTable_load("sculpture_divine_tplt.xml") 
local xml_convert = XmlTable_load("sculpture_convert_tplt.xml")

ModelRune.Rune_BagData = nil



--符文附加属性 当前经验
function ModelRune.getRuneAppendAttr(id)
	local runeAttr = ModelRune.findRuneByid(id)
	if runeAttr == nil then
		print("找不到该符文 type(id)",type(id))
		string.print_int64("id:",id)
		return
	end
	
	local ItemAttr = LogicTable.getItemById(runeAttr.temp_id)
	local RuneAttr = ModelRune.getRune_tplt(ItemAttr.sub_id)
	
	return RuneAttr,ItemAttr

end

--获取身上符文物品ID 表
function ModelRune.getRuneIDTable()
	local _table = {}
	for key,val in pairs(ModelPlayer.sculpture) do
		local attr = ModelRune.findRuneByid(val)
		table.insert(_table,attr.temp_id)
		print("给弓箭的id:",attr.temp_id)
	end
	return _table
end

function ModelRune.findRuneByid(id)
	for key,val in pairs(ModelRune.Rune_BagData) do
		if val.sculpture_id == id then
			return val
		end
	end
	return nil
end

ModelRune.getRune_tplt = function(id)
	local res = XmlTable_getRow(xml_tplt, "id", id)
	local row = {}
	
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value
		elseif "name" == v.name then
			row.name = v.value
		elseif "role_type" == v.name then
			row.role_type = v.value	+ 0
		elseif "skill_group" == v.name then
			row.skill_group = v.value + 0
		elseif "skill_id" == v.name then
			row.skill_id = v.value + 0
		elseif "grade" == v.name then
			row.grade = v.value + 0
		elseif "icon" == v.name then
			row.icon = v.value
		elseif "upgrade_exp" == v.name then
			row.upgrade_exp = v.value + 0
		elseif "eat_exp" == v.name then
			row.eat_exp = v.value + 0
		elseif "eat_gold" == v.name then
			row.eat_gold = v.value + 0
		elseif "next_id" == v.name then
			row.next_id = v.value + 0
		elseif "level" == v.name then
			row.level = v.value + 0
		elseif "desc" == v.name then
			row.desc = v.value
		elseif "skill_cd" == v.name then
			row.skill_cd = v.value + 0
		end
	end
	
	return row
end

ModelRune.getRune_divine_tplt = function(money_type)
	local res = XmlTable_getRow(xml_divine, "money_type", money_type)
	local row = {}
	
	for k, v in pairs(res) do
		if "money_type" == v.name then
			row.money_type = v.value
		elseif "money_amounts" == v.name then
			row.money_amounts = XmlTable_stringSplit(v.value,",")
		end
	end
	
	return row
end

ModelRune.getRune_convert_table = function()
	local row = {}
	for k , v in pairs(xml_convert) do
		local rowLine = {}
		for k1, v1 in pairs(v) do
			if "id" == v1.name then
				rowLine.id = v1.value + 0
			elseif "frag_count" == v1.name then
				rowLine.frag_count = v1.value + 0
			elseif "can_show" == v1.name then
				rowLine.can_show = v1.value + 0
			end
		end
		table.insert(row,rowLine)
	end
	return row	

end

ModelRune.getRune_convert_tplt = function(id)
	local res = XmlTable_getRow(xml_convert, "id", id)
	local row = {}
	
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value
		elseif "frag_count" == v.name then
			row.frag_count = v.value
		elseif "can_show" == v.name then
			row.can_show = v.value	+ 0
		end
	end
	
	return row
end

--计算剩余总经验 Rune_itemID 符文物品ID  currentExp 当前经验
ModelRune.RuneSumExpCount = function(Rune_itemID,currentExp)
	local SumExp = 0
	
	local function NextRune(itemID)
		local runeAttr = ModelRune.getRune_tplt(itemID)
		SumExp = SumExp + runeAttr.upgrade_exp
		
		if runeAttr.next_id == 0 then
			return
		else
			NextRune(runeAttr.next_id)
		end
	end
	
	NextRune(Rune_itemID)
	
	return (SumExp-currentExp)
end

--统计符文碎片
ModelRune.RuneDebrisCount = function()
	id = 41000
	local iCount = 0
	for key,val in pairs(ModelPlayer.bag) do
		if val.itemid == id then
			iCount = iCount + val.amount
			
		end
	
	end
	return iCount
end

local function Handle_sculpture_infos_msg(resp)
	local function delete_Func(id)
		for key,val in pairs(ModelRune.Rune_BagData) do
			if val.sculpture_id == id then
				table.remove(ModelRune.Rune_BagData,key)
			end
		end
	end
	
	local function modify_Func(id)
		for key,val in pairs(ModelRune.Rune_BagData) do
			if val.sculpture_id == id then
				ModelRune.Rune_BagData[key] = val
			end
		end
	end
	
	--------------------------------------------------
	--------------------------------------------------
	
	if resp.type == data_type["init"] then	
		ModelRune.Rune_BagData = resp.sculpture_infos
		
		local attr = nil
		
		for i=1,4 do
			attr = ModelRune.findRuneByid(ModelPlayer.sculpture[i])
			if attr == nil then
				ModelPlayer.sculpture[i] = nil
			end
		end
		
	elseif resp.type == data_type["append"] then
		for key,val in pairs(resp.sculpture_infos) do
			table.insert(ModelRune.Rune_BagData,val)
		end
	elseif resp.type == data_type["delete"] then
		for key,val in pairs(resp.sculpture_infos) do
			delete_Func(val.sculpture_id)
		end
		
	elseif resp.type == data_type["modify"] then
		for key,val in pairs(resp.sculpture_infos) do
			modify_Func(val.sculpture_id)
		end
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_infos"], notify_sculpture_infos(), Handle_sculpture_infos_msg)

