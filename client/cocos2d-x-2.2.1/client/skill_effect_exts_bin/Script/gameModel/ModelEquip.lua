ModelEquip={}

local m_tEquipInfo = {}

local xml_equipment = XmlTable_load("equipment_tplt.xml") 
local xml_equipment_attr = XmlTable_load("equipment_attr_tplt.xml")

--获得装备附加属性
ModelEquip.getEquipRandomXML = function(id)
	local EquipDate = XmlTable_getRow(xml_equipment_attr,"id",id)
		
	if EquipDate == nil then 
		print("ERROR 获得装备附加属性 ,id:",id)
		print("ERROR ModelEquip.getEquipRandomXML")
		
	end
	
	local equip = {}
	for k, v in pairs(EquipDate) do
		--print("k:",k,v.name,v.value)
		if "id" == v.name then
			equip.id = v.value + 0
		elseif "attr_type" == v.name then
			equip.attr_type = v.value
		elseif "attr_values" ==	v.name then
			
			if string.find(v.value,",") == nil then
				equip.attr_values = v.value
			else
				equip.attr_values = XmlTable_stringSplit(v.value,",")
			end
			
			
		elseif "prefix" == v.name then
			equip.prefix = v.value
		end	
	end
	
	
	return equip

end

ModelEquip.getEquipRandomAttr = function(id)
	local data = {}
	data.name = ""
	data.gem_trough = 0
	data.life = 0
	data.atk = 0		 
	data.speed = 0
	data.hit_ratio = 0 
	data.miss_ratio = 0
	data.critical_ratio = 0
	data.tenacity = 0
	data.strengthen_id = 0
			
			
	data.gems = {} -- 宝石ID表

	--[[
	tb.equipment_id = 0
    tb.strengthen_level = 0
    tb.gems = {}
    tb.attr_ids = {}
    tb.gem_extra = 0
	]]
	
	--local equipAttr = ModelPlayer.getPackItemArr(id)
	
	for key,val in pairs(m_tEquipInfo) do 
		if val.equipment_id == id then 
			
			--基础数值属性 
			for keyAttr,valAttr in pairs(val.attr_ids) do
				if valAttr == 0 then 
					print("该物品没有附加属性")
					break
				end
				
				local attr = ModelEquip.getEquipRandomXML(valAttr)
				
				if attr.attr_type == "life" then
					data.life = attr.attr_values + 0
				elseif attr.attr_type == "atk" then
					data.atk = attr.attr_values + 0 
				elseif attr.attr_type == "speed" then
					data.speed = attr.attr_values + 0
				elseif attr.attr_type == "hit_ratio" then
					data.hit_ratio = attr.attr_values + 0
				elseif attr.attr_type == "miss_ratio" then
					data.miss_ratio = attr.attr_values + 0
				elseif attr.attr_type == "critical_ratio" then
					data.critical_ratio = attr.attr_values + 0
				elseif attr.attr_type == "tenacity" then
					data.tenacity = attr.attr_values + 0
				end
				
				if data.name == nil then 
					data.name = attr.prefix
				end
				
			end
				
			--宝石属性
			
			--宝石孔 已加成基础宝石孔
			data.gem_trough = val.gem_extra
			--
			data.gems = val.gems
			
			data.strengthen_id = val.strengthen_level
			
			break
		end		
	end

	--[[for key,val in pairs(data) do 
		print("key:",key,val)
	end]]

	return data
end

--数值已经加上随机属性值
ModelEquip.getEquipById = function(id,only_id)
	local EquipDate = XmlTable_getRow(xml_equipment,"id",id)
	local randomAttr = ModelEquip.getEquipRandomAttr(only_id)
	
	local equip = {}
	for k, v in pairs(EquipDate) do
		if "id" == v.name then
			equip.id = v.value
		elseif "type" == v.name then
			equip.type = v.value
		elseif "quality" ==	v.name then
			equip.roletype = v.value + 0
		elseif "describe" == v.name then
			equip.describe = v.value
			
		elseif "icon" == v.name then
			equip.icon = v.value
			
		elseif "gem_trough" == v.name then
			--print("equip.gem_trough",v.value)
			--print("randomAttr.gem_trough",randomAttr.gem_trough)
			equip.gem_trough = v.value + randomAttr.gem_trough
		elseif "life" == v.name then
			equip.life = v.value + randomAttr.life	
		elseif "atk" == v.name then
			equip.atk = v.value	+ randomAttr.atk		 
		elseif "speed" == v.name then
			equip.speed = v.value + randomAttr.speed	
		elseif "hit_ratio" == v.name then
			equip.hit_ratio = v.value + randomAttr.hit_ratio
		elseif "miss_ratio" == v.name then
			equip.miss_ratio = v.value + randomAttr.miss_ratio	
		elseif "critical_ratio" == v.name then
			equip.critical_ratio = v.value + randomAttr.critical_ratio	
		elseif "tenacity" == v.name then
			equip.tenacity = v.value + randomAttr.tenacity	 
		elseif "strengthen_id" == v.name then
			equip.strengthen_id = v.value + randomAttr.strengthen_id
			
		elseif "equip_level" == v.name then
			equip.equip_level = v.value + 0			
		elseif "equip_use_level" == v.name then
			equip.equip_use_level = v.value + 0			
			
		end
		
	end
	
	--基础属性
	local ItemAttr = LogicTable.getItemById(equip.id)
	equip.name = randomAttr.name..ItemAttr.name
	
	--[[
	if randomAttr.strengthen_id == 0 then 
		equip.name = randomAttr.name.."%s" 
	else
		equip.name = randomAttr.name.."%s/n强化+"..tostring(randomAttr.strengthen_level) 
	end
	]]
	
	return equip
end

--获得物品名称
ModelEquip.functionName = function(id)
	local itemid = ModelPlayer.findBagItemIdById(id)
	local item = LogicTable.getItemById(itemid)	
	return item.name
end



--获得装备类型
ModelEquip.getEquipType = function(id)
	local arr = ModelPlayer.getPackItemArr(id)
	
	if arr == nil then
		return
	end
	
	local equipType = math.floor(arr.type/10) 
	local roletype = nil 
	local strEquip = "空"
	local strWeqpon = "空"
	
	if equipType== equipment_type["weapon"]  then 
		strEquip = "武器"
	elseif equipType == equipment_type["armor"] then 
		strEquip = "护甲"
	elseif equipType == equipment_type["necklace"] then 
		strEquip = "项链"
	elseif equipType == equipment_type["ring"] then 
		strEquip = "戒指"
	elseif equipType == equipment_type["jewelry"] then 
		strEquip = "饰品"
	elseif equipType == equipment_type["medal"] then 
		strEquip = "勋章"
	end
	
	
	roletype = arr.type%10
	strRoletype = CommonFunc_GetRoletypeString(arr.type%10)
		
	--print("equipType:",equipType,"strEquip:",strEquip,"roletype:",roletype,"strRoletype:",strRoletype)
	return equipType,strEquip,roletype,strRoletype
end



--初始化装备信息
ModelEquip.initEquipRandomAttr = function(tb)
	print("ModelEquip.initEquipRandomAttr()")
	--[[for key,val in pairs(tb.equipment_infos[1]) do 
		print("key",key,val)
	end]]
	
	for key,val in pairs(tb.equipment_infos) do
		--print("key",key,"val",val)
		table.insert(m_tEquipInfo,val)	
	end
end

--在装备表搜索 id实例ID
ModelEquip.findEquipItemIdById = function(id)
	for key,val in pairs(m_tEquipInfo) do
		if id == val.equipment_id then
			return val.temp_id
		end
	end
	
	return
end
--在装备表中搜索 返回属性
ModelEquip.findEquipItemAttr = function(id)
	for key,val in pairs(m_tEquipInfo) do
		if id == val.equipment_id then
			return val
		end
	end
	
	return
end

--修改装备宝石属性
function ModelEquip.mod_EquipRandomAttr(data)
	for key,val  in pairs(m_tEquipInfo) do 
		if val.equipment_id == data.equipment_id then 
			m_tEquipInfo[key] = data
			print("修改装备宝石属性")
			return
		end
		
	end
end



local function Handle_equipment_infos_msg(resp)
	ModelEquip.initEquipRandomAttr(resp)
end



--注册装备随机属性事件
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_infos"], notify_equipment_infos(), Handle_equipment_infos_msg)

