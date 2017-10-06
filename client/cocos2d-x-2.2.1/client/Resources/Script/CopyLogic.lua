----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-16
-- Brief:	副本相关逻辑
----------------------------------------------------------------------
CopyLogic = {}
----------------------------------------------------------------------
local RATE_LEVEL = {"VERY_LOW", "LOW", "MID", "HIGH"}	-- 物品掉落概率的等级
local mActiviyCopyPlayTimes = 0							-- 活动副本今日已挑战次数
----------------------------------------------------------------------
-- 处理通知活动副本信息网络消息事件
local function handleNotifyActivityCopyInfo(packet)
	mActiviyCopyPlayTimes = packet.play_times
	EventCenter_post(EventDef["ED_ACTIVITY_COPY_INFO"])
end
----------------------------------------------------------------------
-- Id是否重复存在，如果存在取掉落概率大的并返回true
local function isIdExist(tb, value)
	if type(value) == "string" then       -- tb为怪物表， value = 'id'
		if value == '-1' then
			return true
		end
		for k, v in pairs(tb) do
			if tonumber(v) == tonumber(value) then
				return true
			end
		end
		return false
	elseif type(value) == "table" then    -- tb为掉落物品表，value = {id, drop_rate}
		if value.id == '-1' then
			return true
		end
		for k, v in pairs(tb) do
			if tonumber(v.id) == tonumber(value.id) then
				if tonumber(v.drop_rate) < tonumber(value.drop_rate) then  -- 取最大掉落概率
					v.drop_rate = value.drop_rate
				end
				return true
			end
		end
		return false
	end
end
----------------------------------------------------------------------
-- id:层数表id
-- tb:不用填，为递归时记录数据，初始调用为{}
-- 查询副本里的怪物ID(去重)
function CopyLogic.searchGameMapTable(id, tb)
	tb = tb or {}
	local data = LogicTable.getGameMapItemRow(id)
	
	for k, v in pairs(data.monster) do
		if not isIdExist(tb, v) then
			table.insert(tb, v)
		end
	end
	
	if data.map_rule_id ~= -1 and data.map_rule_id ~= 0 then
		local row = LogicTable.getGameMapRuleRow(data.map_rule_id)
		for k, v in pairs(row.monster) do
			if not isIdExist(tb, v) then
				table.insert(tb, v)
			end
		end
		for k, v in pairs(row.boss) do
			if not isIdExist(tb, v[1]) then
				table.insert(tb, v[1])
			end
		end
	end
	
	if not isIdExist(tb, data.key_monster) then
		table.insert(tb, data.key_monster)
	end
	
	if data.next_map ~= 0 then
		CopyLogic.searchGameMapTable(data.next_map, tb)
	end
	
	return tb
end
----------------------------------------------------------------------
-- first_map_id:层数表id
-- dropitems:掉落物品顺序表
-- 查询怪物掉落的物品及其掉落概率(去重、取概率最大)
function CopyLogic.searchMonsterTable(first_map_id, dropitems)
	local GameMapTable = CopyLogic.searchGameMapTable(first_map_id)
	local tb = {}
	for key, value in pairs(GameMapTable) do
		local data = ModelMonster.getMonsterById(value)
		for k, v in pairs(data.item_id) do
			if not isIdExist(tb, {id = v, drop_rate = data.drop_rate[k]}) then
				for i, j in pairs(dropitems) do
					if tonumber(v) == tonumber(j) then
						tb[i] = {id = v, drop_rate = data.drop_rate[k]}
					end
				end
			end
		end
	end
	return tb
end
----------------------------------------------------------------------
-- 物品掉落概率的等级区间判定
function CopyLogic.judgeRegion(rate)
	if rate == nil then
		return
	end
	for k, v in pairs(RATE_LEVEL) do
		if rate >= Drop_Rate_Region[k] and rate <= Drop_Rate_Region[k + 1] then
			return v
		end
	end
end
----------------------------------------------------------------------
-- 活动副本挑战次数自减
function CopyLogic.reduceActivityCopyPlayTimes()
	--if mActiviyCopyPlayTimes < 0 then
		mActiviyCopyPlayTimes = mActiviyCopyPlayTimes + 1
		EventCenter_post(EventDef["ED_ACTIVITY_COPY_INFO"])
	--end
end
----------------------------------------------------------------------
-- 获取活动副本今日已挑战次数
function CopyLogic.getActivityCopyPlayTimes()
	return mActiviyCopyPlayTimes
end
----------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_activity_copy_info"], notify_activity_copy_info, handleNotifyActivityCopyInfo)


