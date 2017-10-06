----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-3-3
-- 描述：宝石属性建模
----------------------------------------------------------------------

ModelGem = {}
local mGemAttributesTable = XmlTable_load("gem_attributes.xml", "id")	-- 宝石基础属性表
local mGemCompoundTable = XmlTable_load("gem_compound.xml", "id")		-- 宝石合成表
----------------------------------------------------------------------
-- 获取宝石基础属性信息
ModelGem.getGemAttrRow = function(id)
	local row = XmlTable_getRow(mGemAttributesTable, id, true)
	local gemAttrRow = {}
	
	gemAttrRow.id = row.id + 0										-- 宝石id
	gemAttrRow.name = row.name										-- 名称
	gemAttrRow.type = row.type + 0									-- 增加类型:1.生命,2.攻击,3.暴击,4.命中,5.闪避,6.韧性
	gemAttrRow.life = row.life + 0									-- 生命
	gemAttrRow.atk = row.atk + 0									-- 攻击
	gemAttrRow.speed = row.speed + 0								-- 速度
	gemAttrRow.hit_ratio = row.hit_ratio + 0						-- 命中
	gemAttrRow.miss_ratio = row.miss_ratio + 0						-- 闪避
	gemAttrRow.critical_ratio = row.critical_ratio + 0				-- 暴击
	gemAttrRow.tenacity = row.tenacity + 0							-- 韧性
	gemAttrRow.unmounted_price = row.unmounted_price + 0			-- 卸下价格
	gemAttrRow.combat_effectiveness = row.combat_effectiveness + 0	-- 战斗力
	gemAttrRow.small_icon = row.small_icon							-- 图标
	
	return gemAttrRow
end
----------------------------------------------------------------------
-- 获取宝石合成信息
ModelGem.getGemCompoundRow = function(id)
	local row = XmlTable_getRow(mGemCompoundTable, id, true)
	local gemCompoundRow = {}
	
	gemCompoundRow.id = row.id	+ 0									-- 合成id
	gemCompoundRow.gold = row.gold + 0								-- 合成消耗的金币数量
	gemCompoundRow.related_id = row.related_id + 0					-- 关联id,合成成功后的id
	gemCompoundRow.success_rate = row.success_rate + 0				-- 成功率
	gemCompoundRow.miss_rate = CommonFunc_split(row.miss_rate, ",")	-- 消失数量概率
	
	return gemCompoundRow
end
----------------------------------------------------------------------
