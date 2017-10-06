----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-21
-- 描述：游戏逻辑数据表
----------------------------------------------------------------------
require "XmlTable"

-- 各数据表
--local mDailyLoginRewardTable = XmlTable_load("daily_login_reward_tplt.xml")		-- 每日登陆奖励表
local mRandomNameTable = XmlTable_load("random_name_tplt.xml")					-- 随机姓字库
local mRandomSecondNameTable = XmlTable_load("random_secondname_tplt.xml")		-- 随机名字库
local mGame_discrete_date = XmlTable_load("game_discrete_date.xml")
local mTaskTable = XmlTable_load("task_tplt.xml")								-- 任务数据表

local mError_Code = XmlTable_load("error_code_tplt.xml") 
local mItem_Pack = XmlTable_load("item_tplt.xml")
local mEquipment = XmlTable_load("equipment_tplt.xml")

local mExtendPack = XmlTable_load("extend_pack_price.xml") --拓展背包价格表


LogicTable = {
}


---  背包转到各种 类型 的中转表（通过物品id，获得物品信息）
LogicTable.getItemById = function(id)
	local res = XmlTable_getRow(mItem_Pack, "id", id)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "type" == v.name then
			row.type = v.value	
		elseif "name" == v.name then
			row.name = v.value
		elseif "overlay_count" == v.name then
			row.overlay_count = v.value
		elseif "sell_price" == v.name then
			row.sell_price = v.value
		elseif "sub_id" == v.name then
			row.sub_id = v.value
		elseif "icon" == v.name then
			row.icon = v.value
		elseif "describe" == v.name then
			row.describe = v.value
		elseif "quality" == v.name then
			row.quality = v.value + 0
		elseif "bind_type" == v.name then
			row.bind_type = v.value
		end
	end
	return row
end



--通过装备id，获得装备的信息
LogicTable.getEquipById = function(id)
     local EquipData = XmlTable_getRow(mEquipment,"id",id)
     local equip = {}
	for k, v in pairs(EquipData) do
		if "id" == v.name then
			equip.id = v.value
		elseif "type" == v.name then
			equip.type = v.value
		elseif "gem_trough" == v.name then
			equip.gem_trough = v.value 	
		elseif "life" == v.name then
			equip.life = v.value
		elseif "atk" == v.name then
			equip.atk = v.value
		elseif "speed" == v.name then
			equip.speed = v.value
		elseif "hit_ratio" == v.name then
			equip.hit_ratio = v.value
		elseif "miss_ratio" == v.name then
			equip.miss_ratio = v.value
		elseif "critical_ratio" == v.name then
			equip.critical_ratio = v.value
		elseif "tenacity" == v.name then
			equip.tenacity = v.value
        elseif "mf_rule"  == v.name then
            equip.mf_rule = v.value
        elseif "attr_ids"  == v.name then
            equip.attr_ids = XmlTable_stringSplit(v.value,",")
		elseif "strengthen_id" == v.name then
			equip.strengthen_id = v.value
		elseif "equip_level" == v.name then
			equip.equip_level = v.value + 0			
		elseif "equip_use_level" == v.name then
			equip.equip_use_level = v.value + 0
		end
	end
	return equip
end

--通过装备数字类型，获得装备名字
LogicTable.getEquipTypeByType = function(index)
    local equipType = math.floor(index/10)
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
        return strEquip
end
    


----------------------------------------------------------------------
-- 获取每日登陆奖励表
--[[function LogicTable_getDailyLoginRewardTable()
	return mDailyLoginRewardTable
end--]]
----------------------------------------------------------------------
-- 根据登陆天数获取每日登陆奖励信息
--[[function LogicTable_getDailyLoginRewardRow(days)
	local res = XmlTable_getRow(mDailyLoginRewardTable, "days", days)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "days" == v.name then
			row.days = v.value	
		elseif "reward" == v.name then
			row.reward = v.value	
		end
	end
	return row
end--]]
-- 错误代码
LogicTable.getErrorById = function(id)
	local res = XmlTable_getRow(mError_Code, "id", id)
	if res == nil then 
		return nil
	end
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "type" == v.name then
			row.type = v.value	
		elseif "text" == v.name then
			row.text = v.value
		end
	end
	return row
end


--获得扩展背包费用
LogicTable.getExpandPrice = function(the_time)
	print("LogicTable.getExpandPrice the_time",the_time)
	local res = XmlTable_getRow(mExtendPack, "the_time", the_time)
	
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "the_time" == v.name then
			print("获得扩展背包费用the_time:",v.value)
			row.the_time = v.value	
		elseif "price" == v.name then
			print("获得扩展背包费用price:",v.value)
			row.price = v.value	+ 0
		end
	end
	return row.price
end

-- 获取姓
LogicTable.getRadomNameTable = function(id)
	local res = XmlTable_getRow(mRandomNameTable, "id", id)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "relate_id" == v.name then
			row.relate_id = v.value	
		elseif "probability" == v.name then
			row.probability = v.value
		elseif "content" == v.name then
			row.content = XmlTable_stringSplit(v.value,",")
		end
	end
	return row
end
-- 获取名
LogicTable.getRadomSecondNameTable = function(id)
	local res = XmlTable_getRow(mRandomSecondNameTable, "id", id)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value
		elseif "content" == v.name then
			row.content = XmlTable_stringSplit(v.value,",")
		end
	end
	return row
end

-- 游戏离散数据
LogicTable.getGameDateTable = function()
	local res = XmlTable_getRow(mGame_discrete_date, "gamedate", "gamedate")
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "speed" == v.name then
			row.speed = v.value
		elseif "attack" == v.name then
			row.attack = v.value
		end
	end
	return row
end

local mGame_Instance = XmlTable_load("copy_group_tplt.xml")  -- 副本群
local mGame_InstanceSelect = XmlTable_load("copy_tplt.xml")  -- 副本

LogicTable.getGameInstance = function()
	local row = {}
	for k , v in pairs(mGame_Instance) do
		local rowLine = {}
		for k1, v1 in pairs(v) do
			if "id" == v1.name then
				rowLine.id = v1.value
			elseif "name"== v.name then
				rowLine.name = v1.value
			elseif "next_group_id" == v.name then
				rowLine.next_group_id = v1.value
			elseif "icon" == v.name then
				rowLine.icon = v1.value
			elseif "first_copy_id" == v.name then
				rowLine.first_copy_id = v1.value
			end
		end
		table.insert(row,rowLine)
	end
	return row
end

LogicTable.getGameAllFB = function()
	local row = {}
	for k , v in pairs(mGame_InstanceSelect) do
		local rowLine = {}
		for k1, v1 in pairs(v) do
			if "id" == v1.name then
				rowLine.id = v1.value + 0
			elseif "name" == v1.name then
				rowLine.name = v1.value
			elseif "icon" == v1.name then
				rowLine.icon = v1.value
			elseif "copy_group_id" == v1.name then
				rowLine.copy_group_id = v1.value + 0
			elseif "need_power" == v1.name then
				rowLine.need_power = v1.value
			elseif "next_copy" == v1.name then
				rowLine.next_copy = v1.value + 0
			elseif "gold" == v1.name then
				rowLine.gold = v1.value
			elseif "exp" == v1.name then
				rowLine.exp = v1.value
			elseif "award" == v1.name then
				rowLine.award = v1.value
			elseif "describe" == v1.name then
				rowLine.describe = v1.value
			elseif "first_copy_id" == v1.name then
				rowLine.first_map_id = v1.value
			elseif "pre_copy" == v1.name then
				rowLine.pre_copy = v1.value
			elseif "times_limit" == v1.name then
				rowLine.times_limit = v1.value + 0
			elseif "dropitems" == v1.name then
				rowLine.dropitems = XmlTable_stringSplit(v1.value,",")
			end
		end
		table.insert(row,rowLine)
	end
	return row
end

LogicTable.getInstanceSelect = function(id)
	--local res = XmlTable_getRow(mGame_InstanceSelect, "id", id)
	local res = XmlTable_getRow(mGame_InstanceSelect, "id", id)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "name" == v.name then
			row.name = v.value	
		elseif "copy_group_id" == v.name then
			row.copy_group_id = v.value
		elseif "need_power" == v.name then
			row.need_power = v.value
		elseif "next_copy" == v.name then
			row.next_copy = v.value + 0
		elseif "gold" == v.name then
			row.gold = v.value
		elseif "exp" == v.name then
			row.exp = v.value
		elseif "award" == v.name then
			row.award = v.value			
		elseif "describe" == v.name then
			row.describe = v.value			
		elseif "first_map_id" == v.name then
			row.first_map_id = v.value
        elseif "pre_copy" == v.name then
			row.pre_copy = v.value
        elseif "times_limit" == v.name then
			row.times_limit = v.value
        elseif "dropitems" == v.name then
			row.dropitems = XmlTable_stringSplit(v.value,",")
		end
	end
	return row
end


LogicTable.getAllItems = function()
	local row = {}
	for k , v in pairs(mItem_Pack) do
		local rowLine = {}
		for k1, v1 in pairs(v) do
			if "id" == v1.name then
				rowLine.id = v1.value + 0
			elseif "type" == v1.name then
				rowLine.type = v1.value + 0
			elseif "name" == v1.name then
				rowLine.name = v1.value
			elseif "overlay_count" == v1.name then
				rowLine.overlay_count = v1.value + 0
			elseif "sell_price" == v1.name then
				rowLine.sell_price = v1.value + 0
			elseif "sub_id" == v1.name then
				rowLine.sub_id = v1.value + 0
			elseif "icon" == v1.name then
				rowLine.icon = v1.value
			elseif "describe" == v1.name then
				rowLine.describe = v1.value
			elseif "bind_type" == v1.name then
				rowLine.bind_type = v1.value + 0
			elseif "quality" == v1.name then
				rowLine.quality = v1.value  + 0
			end
		end
        table.insert(row,rowLine)
	end
	return row
end

-- 根据任务id获取任务信息
LogicTable.getTaskRow = function(task_id)
	local res = XmlTable_getRow(mTaskTable, "id", task_id)
	local row = {}
	for k, v in pairs(res) do
		if "id" == v.name then					-- 任务id
			row.id = v.value	
		elseif "title" == v.name then			-- 任务标题
			row.title = v.value	
		elseif "main_type" == v.name then		-- 任务主类型,1-主线,2-支线
			row.main_type = v.value
		elseif "need_level" == v.name then		-- 任务等级要求
			row.need_level = v.value
		elseif "next_ids" == v.name then		-- 后置任务id
			row.next_ids = v.value
		elseif "sub_type" == v.name then		-- 任务子类型,1-击杀怪物,2-通关副本,3-收集物品
			row.sub_type = v.value
		elseif "monster_id" == v.name then		-- 怪物id
			row.monster_id = v.value
		elseif "clear_type" == v.name then		-- 通关类型
			row.clear_type = v.value
		elseif "collect_id" == v.name then		-- 收集物品id
			row.collect_id = v.value
		elseif "location" == v.name then		-- 任务地点
			row.location = v.value
		elseif "number" == v.name then			-- 任务要求数量
			row.number = v.value
		elseif "text" == v.name then			-- 任务描述
			row.text = v.value
		elseif "exp_reward" == v.name then		-- 经验奖励
			row.exp_reward = v.value
		elseif "money_reward" == v.name then	-- 金钱奖励
			row.money_reward = v.value
		elseif "item_reward" == v.name then		-- 物品奖励
			row.item_reward = v.value
		end
	end
	return row
end

