-- item ½¨Ä£
ModelItem = {}
ModelItem.getEquipById= function(id)
	local Date = XmlTable_load("equipment_tplt.xml") 
	local EquipDate = XmlTable_getRow(Date,"id",id)
	
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
			equip.gem_trough = v.value 	
		elseif "life" == v.name then
			equip.life = v.value + 0	
		elseif "atk" == v.name then
			equip.atk = v.value	+ 0		 
		elseif "speed" == v.name then
			equip.speed = v.value + 0	
			
		elseif "hit_ratio" == v.name then
			equip.hit_ratio = v.value + 0
			
		elseif "miss_ratio" == v.name then
			equip.miss_ratio = v.value 	+ 0	
		elseif "critical_ratio" == v.name then
			equip.critical_ratio = v.value 	+ 0		
		elseif "tenacity" == v.name then
			equip.tenacity = v.value + 0	 
		elseif "strengthen_id" == v.name then
			equip.strengthen_id = v.value 
		elseif "equip_level" == v.name then
			equip.equip_level = v.value 			
		elseif "equip_use_level" == v.name then
			equip.equip_use_level = v.value 			
				
		end
	end
	return equip
end