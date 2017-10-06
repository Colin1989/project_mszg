----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-05
-- Brief:	锻造逻辑
----------------------------------------------------------------------
EquipForgeLogic = {}
----------------------------------------------------------------------
-- 处理通知援军信息网络消息事件
local function handleNotifyEquipmentExchangeResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		success = true
	end
	EventCenter_post(EventDef["ED_EQUIP_EXCHANGE"], success)
end
----------------------------------------------------------------------
-- 请求装备转换
EquipForgeLogic.requestEquipmentExchange = function(equipInstId)
	local req = req_equipment_exchange()
	req.inst_id = equipInstId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_equipment_exchange_result"]) 
end
----------------------------------------------------------------------
-- 获取装备的转化信息
EquipForgeLogic.getEquipmentExchangeInfo = function(equipTempId)
	local exchangeRow = LogicTable.getEquipExchangeRow(equipTempId)
	local exchangeEquipRow, exchangeItemRow = nil, nil
	if exchangeRow then
		for key, val in pairs(exchangeRow.exchange_ids) do
			local equipRow = ModelEquip.getEquipRow(val)
			local _, _, exchangeRoleType, _ = ModelEquip.calcEquipRoleType(equipRow.type)
			if exchangeRoleType == ModelPlayer.getRoleType() then
				exchangeEquipRow, exchangeItemRow = equipRow, LogicTable.getItemById(val)
				break
			end
		end
	end
	return exchangeRow, exchangeEquipRow, exchangeItemRow
end
----------------------------------------------------------------------
-- 判断装备是否可晋阶
EquipForgeLogic.canEquipmentUpgrade = function(equipData)
	local limitUpgradeCopyId = LIMIT_FORGE_UPGRADE.copy_id
	-- 未通关指定副本
	if CopyDateCache.getCopyStatus(limitUpgradeCopyId) ~= "pass" and tonumber(limitUpgradeCopyId) ~= 1 then
		return 1
	end
	-- 该装备不可晋阶
	local equipRow = ModelEquip.getEquipRow(equipData.temp_id)
	if 0 == equipRow.advance_id then 
		return 2
	end
	-- 强化等级不足
	local equip, _, _, _, _ = ModelEquip.getEquipInfo(equipData.equipment_id)
	local nextStrengthenRow = ModelEquip.getEquipStrengthenRow(equip.strengthen_id + 1)
	if nil ~= nextStrengthenRow then
		return 3
	end
	-- 材料不足
	local advanceNeedMaterials = LogicTable.getAdvanceNeedMaterialById(equipRow.advance_id)
	for i=1, #(advanceNeedMaterials) do
		local num = 0
		local itemInfo = ModelBackpack.getItemByTempId(advanceNeedMaterials[i].temp_id)
		if itemInfo then
			num = tonumber(itemInfo.amount)
		end
		if num < advanceNeedMaterials[i].amount then
			return 4
		end
	end
	-- 条件都满足,可进阶
	return 0
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_exchange_result"], notify_equipment_exchange_result, handleNotifyEquipmentExchangeResult)

