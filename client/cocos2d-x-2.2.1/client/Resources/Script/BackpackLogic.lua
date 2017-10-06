----------------------------------------------------------------------
-- jaron.ho
-- 2014-04-29
-- 背包相关逻辑，与表现逻辑无关
----------------------------------------------------------------------
local mPutonEquipmentInstId = nil			-- 请求穿上的装备实例id
local mTakeoffEquipmentPosition = nil		-- 请求脱下的装备位置
local mMountGemEquipmentInstId = nil		-- 请求镶嵌宝石的装备实例id
local mMountGemTempId = nil					-- 请求镶嵌宝石的宝石模板id
local mUnmountGemEquipmentInstId = nil		-- 请求卸下宝石的装备实例id
local mUnmountGemTempId = nil				-- 请求卸下宝石的宝石模板id
local mStrengthenEquipmentInstId = nil		-- 请求强化的装备实例id
local mResolveEquipmentInfos = {}			-- 请求分解的装备信息
BackpackLogic = {}
----------------------------------------------------------------------
-- 处理通知装备穿上网络消息事件
local function handleNotifyEquipmentPutonResult(packet)
	local success = false
	if common_result["common_success"] == packet.puton_result then
		local equipType = ModelEquip.getEquipType(mPutonEquipmentInstId)
		ModelEquip.setCurrEquip(equipType, mPutonEquipmentInstId)
		success = true
		Audio.playEffectByTag(14)
	end
	EventCenter_post(EventDef["ED_EQUIPMENT_PUTON"], success)
end
----------------------------------------------------------------------
-- 处理通知装备脱下网络消息事件
local function handleNotifyEquipmentTakeoffResult(packet)
	local success = false
	if common_result["common_success"] == packet.takeoff_result then
		ModelEquip.setCurrEquip(mTakeoffEquipmentPosition, nil)
		success = true
		Audio.playEffectByTag(14)
		
	end
	EventCenter_post(EventDef["ED_EQUIPMENT_TAKEOFF"], success)
end
----------------------------------------------------------------------
-- 处理通知宝石合成网络消息事件
local function handleNotifyGemCompoundResult(packet)
	local data = {}
	data.success = false
	data.gem_count = 0
	if common_result["common_success"] == packet.result then
		data.success = true
		data.gem_count = 1
		Audio.playEffectByTag(61)
	end
	data.lost_gem_amount = packet.lost_gem_amount
	EventCenter_post(EventDef["ED_GEM_COMPOUND"], data)
end
----------------------------------------------------------------------
-- 处理通知宝石一键合成网络消息事件
local function handleNotifyOneTouchGemCompoundResult(packet)
	local data = {}
	data.success = false
	data.gem_count = 0
	data.lost_gem_amount = 0
	for key, val in pairs(packet.result_list) do
		if common_result["common_success"] == val.result then
			data.success = true
			data.gem_count = data.gem_count + 1
		else
			data.lost_gem_amount = data.lost_gem_amount + val.lost_gem_amount
		end
	end
	if true == data.success then
		Audio.playEffectByTag(61)
	end
	EventCenter_post(EventDef["ED_GEM_COMPOUND"], data)
end
----------------------------------------------------------------------
-- 处理通知镶嵌宝石网络消息事件
local function handleNotifyEquipmentMountgemResult(packet)
	local success = false
	if common_result["common_success"] == packet.mountgem_result then
		ModelEquip.mountEquipGem(mMountGemEquipmentInstId, mMountGemTempId)
		success = true
		
		LayerSmithGemInlay.initUI()
	end
	EventCenter_post(EventDef["ED_GEM_MOUNT"], success)
end
----------------------------------------------------------------------
-- 处理通知卸下宝石网络消息事件
local function handleNotifyGemUnmountedResult(packet)
	local success = false
	if common_result["common_success"] == packet.result then
		ModelEquip.unmountEquipGem(mUnmountGemEquipmentInstId, mUnmountGemTempId)
		success = true
		LayerSmithGemInlay.initUI()
	end
	EventCenter_post(EventDef["ED_GEM_UNMOUNT"], success)
end
----------------------------------------------------------------------
-- 处理通知单个物品出售网络消息事件
local function handleNotifySaleItemResult(packet)
	local data = {}
	data.success = false
	if common_result["common_success"] == packet.result then
		data.success = true
	end
	data.gold = packet.gold
	EventCenter_post(EventDef["ED_ITEM_SALE"], data)
end
----------------------------------------------------------------------
-- 处理通知多个物品出售网络消息事件
local function handleNotifySaleItemsResult(packet)
	local data = {}
	data.success = false
	if common_result["common_success"] == packet.result then
		data.success = true
	end
	data.gold = packet.gold
	data.err_id = packet.err_id
	EventCenter_post(EventDef["ED_ITEMS_SALE"], data)
end
----------------------------------------------------------------------
-- 处理通知使用道具网络消息事件
local function handleNotifyUsePropsResult(packet)
	local data = {}
	data.success = false
	if common_result["common_success"] == packet.result then
		data.success = true
	end
	data.reward_id = packet.reward_id
	EventCenter_post(EventDef["ED_USE_PROPS"], data)
end
----------------------------------------------------------------------
-- 处理通知装备强化网络消息事件
local function handleNotifyEquipmentStrengthenResult(packet)
	local data = {}
	data.isBatch = false				-- 是否是一键强化
	data.success = false				-- 强化是否成功
	data.successCount = 0				-- 成功次数
	data.failedCount = 1				-- 失败次数
	data.coinCost = packet.gold			-- 金币花费
	if common_result["common_success"] == packet.strengthen_result then
		ModelEquip.upgradeEquipStrengthenLevel(mStrengthenEquipmentInstId)
		data.success = true
		data.successCount = 1
		data.failedCount = 0
	end
	EventCenter_post(EventDef["ED_EQUIPMENT_STRENGTHEN"], data)
end
----------------------------------------------------------------------
-- 处理通知装备一键强化网络消息事件
local function handleNotifyOneTouchEquipmentStrengthenResult(packet)
	local data = {}
	data.isBatch = true			-- 是否是一键强化
	data.success = false		-- 强化是否成功
	data.successCount = 0		-- 成功次数
	data.failedCount = 0		-- 失败次数
	data.coinCost = 0			-- 金币花费
	for key, val in pairs(packet.result_list) do
		data.coinCost = data.coinCost + val.gold
		if common_result["common_success"] == val.strengthen_result then
			ModelEquip.upgradeEquipStrengthenLevel(mStrengthenEquipmentInstId)
			data.success = true
			data.successCount = data.successCount + 1
		else
			data.failedCount = data.failedCount + 1
		end
	end
	EventCenter_post(EventDef["ED_EQUIPMENT_STRENGTHEN"], data)
end
----------------------------------------------------------------------
-- 处理通知装备分解网络消息事件
local function handleNotifyEquipmentResolveResult(packet)
	local data = {}
	data.success = false
	if common_result["common_success"] == packet.result then
		data.success = true
	end
	data.equip_infos = mResolveEquipmentInfos
	data.errid = packet.errid
	data.infos = packet.infos
	EventCenter_post(EventDef["ED_EQUIPMENT_RESLOVE"], data)
end
----------------------------------------------------------------------
-- 初始化
BackpackLogic.init = function()
	-- 注册网络消息事件
	NetSocket_registerHandler(NetMsgType["msg_notify_equipment_puton_result"], notify_equipment_puton_result, handleNotifyEquipmentPutonResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_equipment_takeoff_result"], notify_equipment_takeoff_result, handleNotifyEquipmentTakeoffResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_gem_compound_result"], notify_gem_compound_result, handleNotifyGemCompoundResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_one_touch_gem_compound_result"], notify_one_touch_gem_compound_result, handleNotifyOneTouchGemCompoundResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_equipment_mountgem_result"], notify_equipment_mountgem_result, handleNotifyEquipmentMountgemResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_gem_unmounted_result"], notify_gem_unmounted_result, handleNotifyGemUnmountedResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_sale_item_result"], notify_sale_item_result, handleNotifySaleItemResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_sale_items_result"], notify_sale_items_result, handleNotifySaleItemsResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_use_props_result"], notify_use_props_result, handleNotifyUsePropsResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_equipment_strengthen_result"], notify_equipment_strengthen_result, handleNotifyEquipmentStrengthenResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_one_touch_equipment_strengthen_result"], notify_one_touch_equipment_strengthen_result, handleNotifyOneTouchEquipmentStrengthenResult)
	NetSocket_registerHandler(NetMsgType["msg_notify_equipment_resolve_result"], notify_equipment_resolve_result, handleNotifyEquipmentResolveResult)
end
----------------------------------------------------------------------
-- 请求穿上装备
BackpackLogic.requestEquipmentPuton = function(equipInstId)
	mPutonEquipmentInstId = equipInstId
	local req = req_equipment_puton()
	req.equipment_id = equipInstId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_equipment_puton_result"])
end
----------------------------------------------------------------------
-- 请求脱下装备
BackpackLogic.requestEquipmentTakeoff = function(position)
	mTakeoffEquipmentPosition = position
	local req = req_equipment_takeoff()
	req.position = position
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_equipment_takeoff_result"])
end
----------------------------------------------------------------------
-- 请求宝石合成
BackpackLogic.requestGemCompund = function(gemTempId, protectionUse)
	local req = req_gem_compound()
	req.temp_id = gemTempId
	if true == protectionUse then 
		req.is_protect = 1
	else
		req.is_protect = 0
	end
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_gem_compound_result"])
end
----------------------------------------------------------------------
-- 请求宝石一键合成
BackpackLogic.requestOneTouchGemCompound = function(gemTempId, protectionUse)
	local req = req_one_touch_gem_compound()
	req.temp_id = gemTempId
	if true == protectionUse then
		req.is_protect = 1
	else
		req.is_protect = 0
	end
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_one_touch_gem_compound_result"])
end
----------------------------------------------------------------------
-- 请求镶嵌宝石
BackpackLogic.requestEquipmentMountgem = function(equipInstId, gemInstId)
	mMountGemEquipmentInstId = equipInstId
	mMountGemTempId = ModelBackpack.getItemTempId(gemInstId)
	local req = req_equipment_mountgem()
	req.equipment_id = equipInstId
	req.gem_id = gemInstId
	cclog("ChannelProxy.setUmsAgentEvent-------->STAT_GEM_INLAY")
	ChannelProxy.setUmsAgentEvent("STAT_GEM_INLAY")
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_equipment_mountgem_result"])
end
----------------------------------------------------------------------
-- 请求卸下宝石
BackpackLogic.requestGemUnmounted = function(equipInstId, gemTempId)
	mUnmountGemEquipmentInstId = equipInstId
	mUnmountGemTempId = gemTempId
	local req = req_gem_unmounted()
	req.equipment_id = equipInstId
	req.gem_temp_id = gemTempId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_gem_unmounted_result"])
end
----------------------------------------------------------------------
-- 请求出售单个物品
BackpackLogic.requestSaleItem = function(instId, amount)
	local req = req_sale_item()
	req.inst_id = instId
	req.amount = amount
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sale_item_result"])
end
----------------------------------------------------------------------
-- 请求出售多个物品
BackpackLogic.requestSaleItems = function(instIds)
	local req = req_sale_items()
	for key, val in pairs(instIds) do
		table.insert(req.inst_id, val)
	end
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_sale_items_result"])
end
----------------------------------------------------------------------
-- 请求使用道具
BackpackLogic.requestUseProps = function(instId)
	local req = req_use_props()
	req.inst_id = instId
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_use_props_result"])
end
----------------------------------------------------------------------
-- 请求装备强化
BackpackLogic.requestEquipmentStrengthen = function(equipInstId)
	mStrengthenEquipmentInstId = equipInstId
	local req = req_equipment_strengthen()
	req.equipment_id = equipInstId
	cclog("ChannelProxy.setUmsAgentEvent-------->STAT_STRENGHTEN_ONCE")
	ChannelProxy.setUmsAgentEvent("STAT_STRENGHTEN_ONCE")
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_equipment_strengthen_result"])
end
----------------------------------------------------------------------
-- 请求装备一键强化
BackpackLogic.requestOneTouchEquipmentStrengthen = function(equipInstId)
	mStrengthenEquipmentInstId = equipInstId
	local req = req_one_touch_equipment_strengthen()
	req.equipment_id = equipInstId
	cclog("ChannelProxy.setUmsAgentEvent-------->STAT_STRENGHTEN_BATCH")
	ChannelProxy.setUmsAgentEvent("STAT_STRENGHTEN_BATCH")
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_one_touch_equipment_strengthen_result"])
end
----------------------------------------------------------------------
-- 请求装备分解
BackpackLogic.requestEquipmentResolve = function(equipInstIds)
	mResolveEquipmentInfos = {}
	local req = req_equipment_resolve()
	for key, val in pairs(equipInstIds) do
		local equip, _, _, _, _ = ModelEquip.getEquipInfo(val, true)
		table.insert(mResolveEquipmentInfos, equip)
		table.insert(req.inst_id, val)
	end
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_equipment_resolve_result"])
end
----------------------------------------------------------------------
-- 判断宝石是否可以合成,gemTempId-宝石模板id,checkMoney-是否检验金币
BackpackLogic.gemCompoundStatus = function(gemTempId, checkMoney)
	local gemItem = ModelBackpack.getItemByTempId(gemTempId)
	-- 合成宝石数量为空
	if nil == gemItem then
		return 1
	end
	-- 合成宝石数量不足5
	if gemItem.amount < 5 then 
		return 2
	end
	-- 当前宝石已经是最高级
	local gemCompoundRow = ModelGem.getGemCompoundRow(gemItem.itemid)
	if 0 == gemCompoundRow.related_id then
		return 3
	end
	-- 金币不足
	if true == checkMoney then
		-- if false == CommonFunc_IsConsume(gemCompoundRow.gold) then
		if ModelPlayer.getGold() < gemCompoundRow.gold then
			return 4
		end
	end
	-- 可以合成
	return 0
end
----------------------------------------------------------------------
-- 根据传入信息获取字体颜色,key-关键字,value-值
BackpackLogic.getColour = function(key, value)
	if "quality" == key then		-- 品质判断
		return CommonFunc_getQualityInfo(value).color
	elseif "level" == key then		-- 等级
		if value <= ModelPlayer.getLevel() then
			return ccc3(255, 255, 255)
		else 
			return ccc3(219, 38, 5)
		end
	elseif "roletype" == key then	-- 职业
		if 0 == value or value == ModelPlayer.getRoleType() then
			return ccc3(255, 255, 255)
		else
			return ccc3(219, 38, 5)
		end
	end
	return ccc3(255, 255, 255)
end
----------------------------------------------------------------------
BackpackLogic.init()

