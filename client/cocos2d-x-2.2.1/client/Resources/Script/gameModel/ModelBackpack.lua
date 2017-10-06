----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-14
-- Brief:	背包数据相关
----------------------------------------------------------------------
ModelBackpack = {}
local mPlayerPack = {}			-- 玩家背包
----------------------------------------------------------------------
-- 处理通知玩家背包网络消息
local function handleNotifyPlayerPackMsg(packet)
	if data_type["init"] == packet.type then
		mPlayerPack = {}
		for key, val in pairs(packet.pack_items) do
			mPlayerPack[val.id] = val
		end
	elseif data_type["append"] == packet.type then
		for key, val in pairs(packet.pack_items) do
			mPlayerPack[val.id] = val
		end
	elseif data_type["delete"] == packet.type then
		for key, val in pairs(packet.pack_items) do
			mPlayerPack[val.id] = nil
			-- 删除装备
			ModelEquip.delEquipDataById(val.id)
		end
	elseif data_type["modify"] == packet.type then
		for key, val in pairs(packet.pack_items) do
			mPlayerPack[val.id] = val
		end
	end
	local data = {}
	data.updatetype = packet.type
	data.updateitems = packet.pack_items
	EventCenter_post(EventDef["ED_UPDATE_BACKPACK"], data)
end
----------------------------------------------------------------------
-- 获取背包
ModelBackpack.getPack = function()
	return CommonFunc_clone(mPlayerPack)
end
----------------------------------------------------------------------
-- 获取背包里的所有宝石
ModelBackpack.getPackGem = function()
	local packGem = {}
	for key, val in pairs(mPlayerPack) do
		if item_type["gem"] == val.itemtype then
			table.insert(packGem, val)
		end
	end
	return CommonFunc_clone(packGem)
end
----------------------------------------------------------------------
-- 获取背包物品数量
ModelBackpack.getCount = function()
	local count = 0
	for key, val in pairs(mPlayerPack) do
		count = count + 1
	end
	return count
end
----------------------------------------------------------------------
-- 获取背包物品;instID - 实例id
ModelBackpack.getItemByInstId = function(instID)
	if nil == instID then
		return nil
	end
	-- pack_items 格式
	-- tb.id = 0			-- 实例id
	-- tb.itemid = 0		-- 模板id
	-- tb.itemtype = 0		-- 物品类型
	-- tb.amount = 0		-- 数量
	return CommonFunc_clone(mPlayerPack[instID])
end
----------------------------------------------------------------------
-- 获取背包物品(数量叠加);tempID - 模板id
ModelBackpack.getItemByTempId = function(tempID)
	local packItem = nil
	for key, val in pairs(mPlayerPack) do
		if tonumber(tempID) == tonumber(val.itemid) then
			if nil == packItem then
				packItem = CommonFunc_clone(val)
			else
				packItem.amount = packItem.amount + val.amount
			end
		end
	end
	return packItem
end
----------------------------------------------------------------------
-- 获取背包物品模板id;instID - 实例id
ModelBackpack.getItemTempId = function(instID)
	if nil == instID then
		return nil
	end
	if nil == mPlayerPack[instID] then
		return 0
	end
	return mPlayerPack[instID].itemid
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_player_pack"], notify_player_pack, handleNotifyPlayerPackMsg)

