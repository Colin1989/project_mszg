
----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-3-3
-- 描述：宝石属性建模
----------------------------------------------------------------------

ModelGem = {}

--宝石基础属性
local mGem_attributes = XmlTable_load("gem_attributes.xml") 

--宝石合成表
local mGem_compound = XmlTable_load("gem_compound.xml")


--查找宝石基础属性
ModelGem.getGemAttr = function(id)
	print("ModelGem.getGemAttr",id)
	local res = XmlTable_getRow(mGem_attributes, "id", id)
	local row = {}
	-- 
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value
		elseif "name" == v.name then
			row.name = v.value	
		elseif "type" == v.name then
			row.type = v.value + 0
		elseif "life" == v.name then
			row.life = v.value + 0
		elseif "atk" == v.name then
			row.atk = v.value + 0
		elseif "speed" == v.name then
			row.speed = v.value + 0
		elseif "hit_ratio" == v.name then
			row.hit_ratio = v.value + 0
		elseif "miss_ratio" == v.name then
			row.miss_ratio = v.value + 0
		elseif "critical_ratio" == v.name then
			row.critical_ratio = v.value + 0
		elseif "tenacity" == v.name then
			row.tenacity = v.value + 0
		elseif "unmounted_price" == v.name then
			row.unmounted_price = v.value + 0
		elseif "small_icon" == v.name then
			row.small_icon = v.value
		end
	end
	return row
end

--宝石合成表
ModelGem.getGemCompoundTable = function(id)
	local res = XmlTable_getRow(mGem_compound, "id", id)
	local row = {}
	
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "gold" == v.name then
			row.gold = v.value + 0
		elseif "related_id" == v.name then
			row.related_id = v.value
		elseif "success_rate" == v.name then
			row.success_rate = v.value
		elseif "miss_rate" == v.name then
			row.miss_rate = v.value
		end
	end
	return row

end

