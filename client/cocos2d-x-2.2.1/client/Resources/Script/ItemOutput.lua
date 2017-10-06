--region ItemOutput.lua
--Author : songcy
--Date   : 2014/10/26

ItemOutput = {}

local tbDropNormalCopy = {}		-- 普通副本
local tbDropSpecialCopy = {}		-- 精英副本
local tbDropBossCopy = {}			-- BOSS副本
-- local tbDropCopy = nil			-- 最终选定副本
local popUIName = nil				-- 要弹出的UI名称
local popUIType = nil				-- 要弹出的UI类型
local isLock = false				-- 是否未解锁
-- local isVisibleGo = true

----------------------------------------------------------------------
-- 点击立即前往按钮
ItemOutput.gotoCopy = function(typeName, widget)
	if "releaseUp" == typeName then
		if isLock == true then
			Toast.show(GameString.get("OUTPUT_TIP_03"))
			return
		end
		TipModule.onClick(widget)
		local copy_id = widget:getTag()
		-- local task = LogicTable.getTaskRow(task_id)
		local copy = LogicTable.getCopyById(copy_id)
		local copy_type = tonumber(copy.type)
		local ui_name = widget:getName()
		if 1 == copy_type or 2 == copy_type or 3 == copy_type then
			EventCenter_post(EventDef["ED_TaskToCopy"], copy_id)
			if popUIType ~= 1 then
				UIManager.pop(string.format("%s", ui_name))
			end
			if popUIName ~= nil then
				UIManager.pop(string.format("%s", popUIName))
			end
			UIManager.push("UI_CopyTips", copy_id)
		-- else
			-- LayerMain.pullPannel(LayerTask)
		end
	end
end

-- 获得当前正在攻打副本所在区间
local function getDropCopy()
	local str = nil
	local tbDropCopy = nil
	local index = 0
	local AllGroup = LogicTable.getAllCopyGroup()
	-- table.sort(AllGroup, function(x, y) return tonumber(x.id) < tonumber(y.id) end)
	if #tbDropNormalCopy ~= 0 then
		local normalCopyId = CopyDateCache.getLastCopyIdByMode(1)
		if normalCopyId == 0 then
			isLock = true
		end
		for nIndex, copy in pairs(tbDropNormalCopy) do
			if tonumber(normalCopyId) > tonumber(copy.id) then
				tbDropCopy = copy
				-- tbDropCopy.isPlay = true		-- 该副本是否可以刷
			elseif normalCopyId ~= 0 then
				if CopyDateCache.getCopyStatus(tonumber(normalCopyId)) == "pass" then
					tbDropCopy = copy
				end
			end
		end
		if tbDropCopy == nil then
			isLock = true
			tbDropCopy = tbDropNormalCopy[1]
		end
		for key,copyGroup in pairs(AllGroup) do
			if 1 == tonumber(copyGroup.type) then
				index = index + 1
				if tonumber(tbDropCopy.copy_group_id) == tonumber(copyGroup.id) then
					break
				end
			end
		end
		str = GameString.get("OUTPUT_COPY_NORMAL", index, tbDropCopy.name)
	elseif #tbDropSpecialCopy ~= 0 then
		local specialCopyId = CopyDateCache.getLastCopyIdByMode(2)
		if specialCopyId == 0 then
			isLock = true
		end
		for nIndex, copy in pairs(tbDropSpecialCopy) do
			if tonumber(specialCopyId) > tonumber(copy.id) then
				tbDropCopy = copy
			elseif specialCopyId ~= 0 then
				if CopyDateCache.getCopyStatus(tonumber(specialCopyId)) == "pass" then
					tbDropCopy = copy
				end
			end
		end
		if tbDropCopy == nil then
			isLock = true
			tbDropCopy = tbDropSpecialCopy[1]
		end
		for key,copyGroup in pairs(AllGroup) do
			if 2 == tonumber(copyGroup.type) then
				index = index + 1
				if tonumber(tbDropCopy.copy_group_id) == tonumber(copyGroup.id) then
					break
				end
			end
		end
		str = GameString.get("OUTPUT_COPY_SPECIAL", index, tbDropCopy.name)
	elseif #tbDropBossCopy ~= 0 then
		local bossCopyId = nil
		local a,b,BossTb = CopyDateCache.getCurGroupLength(nil)
		for key, value in pairs(BossTb) do
			local tempCopy = LogicTable.getCopyById(value)
			local statue,isPlayOpenDoor = CopyDateCache.getCopyStatus(tempCopy.id)
			if statue == "pass" then
				bossCopyId = tempCopy.id
			-- elseif statue == "doing" then
				-- bossCopyId = tempCopy.id
			elseif key == #BossTb and bossCopyId == nil and statue == "lock" then
				isLock = true
				bossCopyId = LogicTable.getCopyById(BossTb[1]).id
			end
		end
		for  nIndex, copy in pairs(tbDropBossCopy) do
			if tonumber(bossCopyId) >= tonumber(copy.id) then
				tbDropCopy = copy
			end
		end
		if tbDropCopy == nil then
			isLock = true
			tbDropCopy = tbDropBossCopy[1]
		end
		str = GameString.get("OUTPUT_COPY_BOSS", tbDropCopy.name)
	end
	return tbDropCopy, str
end


-- bundle: temp_id: 物品ID; popUIName: (string:点击前往后需弹出的UI名称 number:1.屏蔽产出前往；2.）
ItemOutput.getRoads = function(bundle)
	-- 屏蔽产出前往
	if bundle.popUIName == 1 then
		return nil, nil
	else
		popUIName = bundle.popUIName
	end
	popUIType = bundle.popUIType
	
	-- 不显示的物品类型
	local itemRow = {}
	if tonumber(bundle.type) == 13 then
		itemRow = SkillConfig.getSkillFragInfo(bundle.temp_id)
	elseif tonumber(bundle.type) == 7 then
		itemRow = LogicTable.getItemById(bundle.temp_id)		-- 1装备, 2符文, 3宝石, 4杂物, 5道具，6材料，7，8，9，
		if tonumber(itemRow.type) == 1 or tonumber(itemRow.type) == 2 or tonumber(itemRow.type) == 4 or tonumber(itemRow.type) == 5 or tonumber(itemRow.type) == 7 then
			return nil, nil
		end
	else
		itemRow = LogicTable.getRewardItemRow(bundle.temp_id)
	end
	isLock = false
	local fbAll= LogicTable.getGameAllFB()					-- 获取副本的XML表，type = 1 普通本，type = 2 精英本，type = 3 Boss本
	tbDropNormalCopy = {}
	tbDropSpecialCopy = {}
	tbDropBossCopy = {}
	-- table.sort(fbAll, function(x, y) return tonumber(x.id) < tonumber(y.id) end)		-- 从小到大排序
	for nIndex, copy in pairs(fbAll) do
		local dropitems = copy.dropitems
		for key, val in pairs(dropitems) do
			if tonumber(val) == -1 then
				break
			end
			local ItemDate = LogicTable.getRewardItemRow(val)
			if tonumber(bundle.temp_id) == tonumber(ItemDate.temp_id) then
				if tonumber(copy.type) == 1 then
					table.insert(tbDropNormalCopy, copy)
					break
				elseif tonumber(copy.type) == 2 then
					table.insert(tbDropSpecialCopy, copy)
					break
				elseif tonumber(copy.type) == 3 then
					table.insert(tbDropBossCopy, copy)
					break
				end
			end
		end
	end
	if tonumber(itemRow.type) == 3 and #tbDropNormalCopy == 0 and #tbDropSpecialCopy == 0 and #tbDropBossCopy == 0 then
		local str = GameString.get("OUTPUT_TIP_01")
		return nil, str
	elseif tonumber(itemRow.type) == 6 and #tbDropNormalCopy == 0 and #tbDropSpecialCopy == 0 and #tbDropBossCopy == 0 then
		local str = GameString.get("OUTPUT_TIP_02")
		return nil, str
	elseif #tbDropNormalCopy == 0 and #tbDropSpecialCopy == 0 and #tbDropBossCopy == 0 then
		return nil, nil
	end
	local tb, str = getDropCopy()
	return tb, str
end





