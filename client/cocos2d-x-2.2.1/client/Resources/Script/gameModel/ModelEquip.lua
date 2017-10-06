----------------------------------------------------------------------
-- jaron.ho
-- 2014-05-23
-- 装备信息
----------------------------------------------------------------------
ModelEquip={}
local mEquipTable = XmlTable_load("equipment_tplt.xml", "id") 							-- 装备基础表
local mEquipStrengthenTable = XmlTable_load("equip_strengthen_tplt.xml", "id")			-- 装备强化表
local mEquipMFRuleTable = XmlTable_load("equipment_mf_rule_tplt.xml", "id")				-- 装备mf表
local mEquipInfos = {}		-- 装备信息
local mCurrEquip = 			-- 玩家当前穿戴的装备
{
	[equipment_type["weapon"]] = nil,			-- 武器
	[equipment_type["armor"]] = nil,			-- 护甲
	[equipment_type["necklace"]] = nil,			-- 项链
	[equipment_type["ring"]] = nil,				-- 戒指
	[equipment_type["jewelry"]] = nil,			-- 珠宝
	[equipment_type["medal"]] = nil				-- 勋章
}
----------------------------------------------------------------------
-- 根据随机属性id获取信息
ModelEquip.getRandomAttrInfo = function(attrId)
	if nil == attrId then
		return nil
	end
	local function calcCombatEffectiveness(expressId, attrValue)
		local expressRow = LogicTable.getExpressionRow(expressId)
		local valueTable = {{name = "Value", value = attrValue}}
		return ExpressionParse.compute(expressRow.expression, valueTable)
	end
	local attrIdArea = {1000000, 2000000, 3000000, 4000000, 5000000, 6000000, 7000000, 8000000}
	local attrTypeArea = {"hit_ratio", "miss_ratio", "critical_ratio", "tenacity", "speed", "life", "atk"}
	local prefixArea = {"EQUIP_HIT_RATIO", "EQUIP_MISS_RATIO", "EQUIP_CRITICAL_RATIO", "EQUIP_TENACITY", "EQUIP_SPEED", "EQUIP_LIFE", "EQUIP_ATK"}
	local expressArea = {23, 24, 25, 26, 27, 28, 29}
	for i=1, 7 do
		if attrId >= attrIdArea[i] and attrId < attrIdArea[i+1] then
			local randomInfo = {}
			randomInfo.attr_type = attrTypeArea[i]
			randomInfo.attr_value = attrId % attrIdArea[i] % 900000
			randomInfo.prefix = GameString.get(prefixArea[i])
			randomInfo.combat_effectiveness = calcCombatEffectiveness(expressArea[i], randomInfo.attr_value)
			return randomInfo
		end
	end
	return nil
end
----------------------------------------------------------------------
-- 获取装备基础信息
ModelEquip.getEquipRow = function(id)
	local row = XmlTable_getRow(mEquipTable, id, true)
	local equipRow = {}
	
	equipRow.id = row.id + 0											-- 装备id
	equipRow.type = row.type + 0		-- 类型:10.武器,11.双手斧,12.双手剑,13.法槌,14.法杖;20.护甲;30.项链;40.戒指;50.饰品;60.勋章
	equipRow.gem_trough = row.gem_trough + 0							-- 宝石孔数
	equipRow.life = row.life + 0										-- 生命(效果程序识别码)
	equipRow.atk = row.atk + 0											-- 攻击(效果程序识别码)
	equipRow.speed = row.speed + 0										-- 速度(效果程序识别码)
	equipRow.hit_ratio = row.hit_ratio + 0								-- 命中(效果程序识别码)
	equipRow.miss_ratio = row.miss_ratio + 0							-- 闪避(效果程序识别码)
	equipRow.critical_ratio = row.critical_ratio + 0					-- 暴击(效果程序识别码)
	equipRow.tenacity = row.tenacity + 0								-- 韧性(效果程序识别码)
	equipRow.mf_rule = row.mf_rule + 0									-- MF规则表内的id
	equipRow.strengthen_id = row.strengthen_id + 0						-- 强化数值表的id
	equipRow.equip_level = row.equip_level + 0							-- 等级
	equipRow.equip_use_level = row.equip_use_level + 0					-- 使用等级
	equipRow.combat_effectiveness = row.combat_effectiveness + 0		-- 当前战斗力
	equipRow.max_combat_effectiveness = row.max_combat_effectiveness + 0	-- 最大战斗力
	equipRow.advance_id = row.advance_id + 0							-- 升阶id
	equipRow.recast_id = row.recast_id + 0								-- 重铸id
	equipRow.mitigation = (row.mitigation + 0) / 100					-- 减伤百分比
	
	return equipRow
end
----------------------------------------------------------------------
-- 获取装备强化信息
ModelEquip.getEquipStrengthenRow = function(id)
	local row = XmlTable_getRow(mEquipStrengthenTable, id, false)
	if nil == row then
		return nil
	end
	
	local equipStrengthRow = {}
	equipStrengthRow.id = row.id + 0									-- 强化id
	equipStrengthRow.need_type = row.need_type + 0						-- 费用类型
	equipStrengthRow.need_amount = row.need_amount + 0					-- 强化费用
	equipStrengthRow.attr_types = row.attr_types						-- 强化对应的属性
	equipStrengthRow.attr_values = row.attr_values + 0					-- 强化效果
	equipStrengthRow.strengthen_rate = row.strengthen_rate + 0			-- 强化成功率
	equipStrengthRow.strengthen_battle_power = row.strengthen_battle_power + 0		-- 装备升级后的战力数值列:作用是每升一级,将此列填的数值增加到原战力值上
	equipStrengthRow.strengthen_addition_gold = row.strengthen_addition_gold + 0	-- 装备升级后的售价变化列:作用是每升一级，将此列填的数值增加到售价上

	return equipStrengthRow
end
----------------------------------------------------------------------
-- 获取装备mf信息
local function getEquipMfRuleRow(id)
	local row = XmlTable_getRow(mEquipMFRuleTable, id, false)
	if nil == row then
		return nil
	end
	
	local mfRuleRow = {}
	mfRuleRow.id = row.id + 0											-- mf id
	mfRuleRow.addtional_attr_max = row.addtional_attr_max + 0			-- 随机附加属性个数最大
	mfRuleRow.addtional_attr_min = row.addtional_attr_min + 0			-- 随机附加属性个数最小
	if "-1" == row.addtional_attr_ids then								-- 参与随机的附加属性id
		mfRuleRow.addtional_attr_ids = {}
	else
		mfRuleRow.addtional_attr_ids = CommonFunc_parseStringTuple(row.addtional_attr_ids, true)
	end
	mfRuleRow.special_attr_max = row.special_attr_max + 0				-- 随机特殊属性个数最大
	mfRuleRow.special_attr_min = row.special_attr_min + 0				-- 随机特殊属性个数最小
	if "-1" == row.special_attr_ids then								-- 参与随机的特殊属性id
		mfRuleRow.special_attr_ids = {}
	else
		mfRuleRow.special_attr_ids = CommonFunc_parseStringTuple(row.special_attr_ids, true)
	end
	mfRuleRow.gem_trough = row.gem_trough + 0							-- 随机出的宝石孔最大数
	
	return mfRuleRow
end
----------------------------------------------------------------------
-- 获取装备的随机mf信息
ModelEquip.getRandomMfRuleInfo = function(id)
	local randomAttrIds = {}
	local mfRuleRow = getEquipMfRuleRow(id)
	if nil == mfRuleRow then
		return randomAttrIds
	end
	local addtionalIds = CommonFunc_randomValue(mfRuleRow.addtional_attr_ids, math.random(mfRuleRow.addtional_attr_min, mfRuleRow.addtional_attr_max))
	for key, val in pairs(addtionalIds) do
		table.insert(randomAttrIds, math.random(val[1], val[#val]))
	end
	local specialIds = CommonFunc_randomValue(mfRuleRow.special_attr_ids, math.random(mfRuleRow.special_attr_min, mfRuleRow.special_attr_max))
	for key, val in pairs(specialIds) do
		table.insert(randomAttrIds, math.random(val[1], val[#val]))
	end
	return randomAttrIds
end
----------------------------------------------------------------------
-- 根据随机属性id获取随机属性的最大值和最小值
ModelEquip.getRandomMfRuleRange = function(id)
	local minRandomAttrIds = {}
	local maxRandomAttrIds = {}
	local mfRuleRow = getEquipMfRuleRow(id)
	if nil == mfRuleRow then
		return minRandomAttrIds
	end
	for key, val in pairs(mfRuleRow.addtional_attr_ids) do
		table.insert(minRandomAttrIds, val[1])
		table.insert(maxRandomAttrIds, val[#val])
	end
	for key, val in pairs(mfRuleRow.special_attr_ids) do
		table.insert(minRandomAttrIds, val[1])
		table.insert(maxRandomAttrIds, val[#val])
	end
	return minRandomAttrIds, maxRandomAttrIds
end
----------------------------------------------------------------------
-- 计算装备属性:网络原始数据,总属性,基础属性,强化属性,随机属性,宝石属性
local function calcEquipAttrs(equipInfo)
	--[[equipInfo:
			equipment_id		-- 装备实例id
			temp_id				-- 装备模板id
			strengthen_level	-- 装备强化等级
			gems				-- 装备所镶嵌的宝石列表
			attr_ids			-- 属性id列表
			gem_extra			-- 宝石孔数
	]]
	if nil == equipInfo then
		return nil
	end
	local equipRow = ModelEquip.getEquipRow(equipInfo.temp_id)
	local itemRow = LogicTable.getItemById(equipInfo.temp_id)
	if nil == equipRow or nil == itemRow then
		return nil
	end
	-- 附加额外属性
	local equip = equipRow
	CommonFunc_copyTableMembers(equip, equipInfo)
	equip.instid = equipInfo.equipment_id										-- 实例id
	equip.name = itemRow.name													-- 装备名称(前缀+基础名字)
	equip.gem_trough = equip.gem_trough + equipInfo.gem_extra					-- 宝石孔数
	equip.strengthen_id = equip.strengthen_id*1000 + equipInfo.strengthen_level	-- 强化规则
	equip.sell_price = itemRow.sell_price										-- 售价
	equip.item_row = itemRow													-- 物品表信息
	-- 基础属性拷贝
	local baseEquip = CommonFunc_table_copy_table(equip)		-- 基础属性
	local strengthenEquip = CommonFunc_table_copy_table(equip)	-- 强化属性 = 强化 + 附加
	strengthenEquip = ModelEquip.resetAttrType(strengthenEquip)
	local randomEquip = CommonFunc_table_copy_table(equip)		-- 随机属性
	randomEquip = ModelEquip.resetAttrType(randomEquip)
	local gemEquip = CommonFunc_table_copy_table(equip)			-- 宝石属性
	gemEquip = ModelEquip.resetAttrType(gemEquip)
	-- 叠加装备强化属性
	local equipStrengthenRow = ModelEquip.getEquipStrengthenRow(strengthenEquip.strengthen_id)
	if equipStrengthenRow then
		local key = equipStrengthenRow.attr_types
		strengthenEquip[key] = strengthenEquip[key] + equipStrengthenRow.attr_values
		strengthenEquip.combat_effectiveness = strengthenEquip.combat_effectiveness + equipStrengthenRow.strengthen_battle_power
		strengthenEquip.sell_price = strengthenEquip.sell_price + equipStrengthenRow.strengthen_addition_gold
		equip[key] = equip[key] + equipStrengthenRow.attr_values
		equip.combat_effectiveness = equip.combat_effectiveness + equipStrengthenRow.strengthen_battle_power
		equip.sell_price = equip.sell_price + equipStrengthenRow.strengthen_addition_gold
	end
	-- 叠加装备随机属性
	for keyAttr, valAttr in pairs(equipInfo.attr_ids) do
		if 0 == valAttr then
			break
		end
		local equipAttrRow = ModelEquip.getRandomAttrInfo(valAttr)
		if equipAttrRow then
			if itemRow.name == randomEquip.name then
				randomEquip.name = equipAttrRow.prefix..itemRow.name
			end
			local key = equipAttrRow.attr_type
			randomEquip[key] = randomEquip[key] + equipAttrRow.attr_value
			randomEquip.combat_effectiveness = randomEquip.combat_effectiveness + equipAttrRow.combat_effectiveness
			equip.name = randomEquip.name
			equip[key] = equip[key] + equipAttrRow.attr_value
			equip.combat_effectiveness = equip.combat_effectiveness + equipAttrRow.combat_effectiveness
		end
	end
	-- 叠加宝石属性
	for keyGem, valGem in pairs(equipInfo.gems) do
		local itemRow = LogicTable.getItemById(valGem)
		gemEquip.sell_price = gemEquip.sell_price + itemRow.sell_price
		local gemAttr = ModelGem.getGemAttrRow(valGem)
		gemEquip = ModelEquip.addAttrType(gemEquip, gemAttr)
		equip = ModelEquip.addAttrType(equip, gemAttr)
	end
	return {["original"]=equipInfo, ["total"]=equip, ["base"]=baseEquip, ["strengthen"]=strengthenEquip, ["random"]=randomEquip, ["gem"]=gemEquip}
end
----------------------------------------------------------------------
-- 设置当前穿戴的装备
ModelEquip.setCurrEquip = function(equipType, instID)
	if nil == equipType then
		return
	end
	if instID and "0" == string.int64_to_string(instID) then
		instID = nil
	end
	mCurrEquip[equipType] = instID
end
----------------------------------------------------------------------
-- 获取当前穿戴的装备
ModelEquip.getCurrEquip = function(equipType)
	if nil == equipType then
		return nil
	end
	return mCurrEquip[equipType]
end
----------------------------------------------------------------------
-- 获取当前穿戴的所有装备
ModelEquip.getCurrEquipList = function()
	return CommonFunc_clone(mCurrEquip)
end
----------------------------------------------------------------------
-- 获取当前穿戴的装备(根据指定装备id所对应的装备类型查找)
ModelEquip.getCurrEquipEx = function(instID)
	local equipType = ModelEquip.getEquipType(instID)
	if nil == equipType or 0 == equipType then
		return nil
	end
	return ModelEquip.getCurrEquip(equipType)
end
----------------------------------------------------------------------
-- 判断装备是否已经使用
ModelEquip.isEquipInWeared = function(instID)
	for key, val in pairs(mCurrEquip) do
		if instID == val then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 获取装备信息:总属性,基础属性,强化属性,随机属性,宝石属性(注意使用quick时一定要保证数据不能在外部改变)
ModelEquip.getEquipInfo = function(instID, quick)
	if nil == instID then
		return nil
	end
	local infos = nil
	if true == quick then
		infos = mEquipInfos[instID]
	else
		infos = CommonFunc_clone(mEquipInfos[instID])
	end
	if nil == infos then
		return nil
	end
	return infos["total"], infos["base"], infos["strengthen"], infos["random"], infos["gem"]
end
----------------------------------------------------------------------
-- 获取装备信息:总属性,基础属性,强化属性,随机属性,宝石属性
ModelEquip.getEquipInfoEx = function(originalInfo)
	if nil == originalInfo then
		return
	end
	local infos = calcEquipAttrs(originalInfo)
	return infos["total"], infos["base"], infos["strengthen"], infos["random"], infos["gem"]
end
----------------------------------------------------------------------
-- 删除装备信息
ModelEquip.delEquipDataById = function(instID)
	if true == ModelEquip.isEquipInWeared(instID) then
		return
	end
	mEquipInfos[instID] = nil
end
----------------------------------------------------------------------
-- 获取装备
ModelEquip.getEquips = function()
	local equipTable = {}
	for key, val in pairs(mEquipInfos) do
		local tb = {}
		tb.data = CommonFunc_clone(val["total"])
		tb.bIsWeared = false
		if true == ModelEquip.isEquipInWeared(key) then
			tb.bIsWeared = true
			table.insert(equipTable, tb)
		else
			if ModelBackpack.getItemByInstId(key) then
				table.insert(equipTable, tb)
			end
		end
	end
	return equipTable
end
----------------------------------------------------------------------
-- 重置效果程序识别码,战斗力
ModelEquip.resetAttrType = function(originalAttr)
	originalAttr.life = 0
	originalAttr.atk = 0
	originalAttr.speed = 0
	originalAttr.hit_ratio = 0
	originalAttr.miss_ratio = 0
	originalAttr.critical_ratio = 0
	originalAttr.tenacity = 0
	originalAttr.combat_effectiveness = 0
	return originalAttr
end
----------------------------------------------------------------------
-- 效果程序识别码,战斗力累加
ModelEquip.addAttrType = function(originalAttr, addAttr)
	originalAttr.life = (originalAttr.life or 0) + (addAttr.life or 0)
	originalAttr.atk = (originalAttr.atk or 0) + (addAttr.atk or 0)
	originalAttr.speed = (originalAttr.speed or 0) + (addAttr.speed or 0)
	originalAttr.hit_ratio = (originalAttr.hit_ratio or 0) + (addAttr.hit_ratio or 0)
	originalAttr.miss_ratio = (originalAttr.miss_ratio or 0) + (addAttr.miss_ratio or 0)
	originalAttr.critical_ratio = (originalAttr.critical_ratio or 0) + (addAttr.critical_ratio or 0)
	originalAttr.tenacity = (originalAttr.tenacity or 0) + (addAttr.tenacity or 0)
	originalAttr.combat_effectiveness = (originalAttr.combat_effectiveness or 0) + (addAttr.combat_effectiveness or 0)
	return originalAttr
end
----------------------------------------------------------------------
-- 获得装备类型
ModelEquip.getEquipType = function(instID)
	local equip = ModelEquip.getEquipInfo(instID)
	if nil == equip then
		return nil
	end
	return ModelEquip.calcEquipRoleType(equip.type)
end
----------------------------------------------------------------------
-- 计算装备类型,职业类型
ModelEquip.calcEquipRoleType = function(equipType)
	-- 装备类型
	local equipTypeCalc = math.floor(equipType / 10)
	local equipTypeStr = CommonFunc_GetEquipTypeString(equipType)
	-- 可使用该装备的职业类型
	local roleType = equipType % 10
	local roleTypeStr = CommonFunc_GetRoleTypeString(roleType)
	return equipTypeCalc, equipTypeStr, roleType, roleTypeStr
end
----------------------------------------------------------------------
-- 装备是否可穿戴
ModelEquip.canEquipPuton = function(tempID)
	local equipRow = ModelEquip.getEquipRow(tempID)
	local roleType = equipRow.type % 10
	if roleType ~= ModelPlayer.getRoleType() and roleType ~= 0 then	-- 非本职业装备
		return 2
	elseif equipRow.equip_use_level > ModelPlayer.getLevel() then		-- 等级不足
		return 1
	end
	-- 可穿戴
	return 0
end
----------------------------------------------------------------------
-- 装备信息替换
ModelEquip.replaceEquipInfo = function(newEquipInfo)
	if nil == newEquipInfo then
		return
	end
	mEquipInfos[newEquipInfo.equipment_id] = calcEquipAttrs(newEquipInfo)
end
----------------------------------------------------------------------
-- 升级装备强化等级,自动升1级
ModelEquip.upgradeEquipStrengthenLevel = function(instID)
	local infos = mEquipInfos[instID]
	if nil == infos then
		return
	end
	infos["original"].strengthen_level = infos["original"].strengthen_level + 1
	mEquipInfos[instID] = calcEquipAttrs(infos["original"])
end
----------------------------------------------------------------------
-- 装备镶嵌宝石
ModelEquip.mountEquipGem = function(instID, gemID)
	local infos = mEquipInfos[instID]
	if nil == infos then
		return
	end
	table.insert(infos["original"].gems, gemID)
	mEquipInfos[instID] = calcEquipAttrs(infos["original"])
end
----------------------------------------------------------------------
-- 装备卸下宝石
ModelEquip.unmountEquipGem = function(instID, gemID)
	local infos = mEquipInfos[instID]
	if nil == infos then
		return
	end
	for key, val in pairs(infos["original"].gems) do
		if gemID == val then
			table.remove(infos["original"].gems, key)
			mEquipInfos[instID] = calcEquipAttrs(infos["original"])
			return
		end
	end
end
----------------------------------------------------------------------
-- 处理通知装备网络消息事件
local function handleNotifyEquipmentInfos(packet)
	if data_type["init"] == packet.type then
		mEquipInfos = {}
	end
	for key, val in pairs(packet.equipment_infos) do
		mEquipInfos[val.equipment_id] = calcEquipAttrs(val)
	end
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_infos"], notify_equipment_infos, handleNotifyEquipmentInfos)

