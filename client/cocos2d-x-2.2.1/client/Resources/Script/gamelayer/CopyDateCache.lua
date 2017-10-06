-- 副本数据缓存 

CopyDateCache = {}
CopyDateCache.GameType = game_type["common"]	--游戏模式


local mResponseInfos = nil -- 星星详细列表
local mAllFbMsg = nil -- 所有FB信息


--local mCopyDoing_id = nil	--玩家正在攻打的副本


--当前副本是否获得了星星?
function isGetReSpone(_Copyid)
	if nil == mResponseInfos then
		return false
	end
	for k,v in pairs(mResponseInfos) do
			--cclog("查询副本ID",_Copyid,v.copy_id)
		if tonumber(_Copyid) == tonumber(v.copy_id) then 
			return true
		end
	end
	return false
end

--当前副本是否前置副本都过了?
local  function IsPassAll_Precopy(Copy_id)
	local copyInfo = LogicTable.getCopyById(Copy_id)
	
	for key,pre_copy_id in pairs(copyInfo.pre_copy) do
		 if isGetReSpone(pre_copy_id) == false then 
			return false 
		 end 
	end
	return true
end 

--当前副本属于 这个副本的前置副本
local function PreCopyContainsThisCopy(pre_copyTb,curCopyId)
	for key,pre_copy_id in pairs(pre_copyTb) do
		if tonumber(pre_copy_id) == tonumber(curCopyId) then 
			return true
		end 
	end 
	return false
end

CopyDateCache.getInfo = function()
	return mResponseInfos
end

CopyDateCache.logInfos = function()
    if mResponseInfos ~= nil then 
        Log(mResponseInfos)
    end 
end 

local preIdTb = {}
local curIdTb = {}

-- 设置通关的副本IdTb
CopyDateCache.setPreCopyId = function(copyId)
	preIdTb = copyId
end

--获得之前的副本IDTb
CopyDateCache.getPrePassCopyId = function()
	return preIdTb
end

-- 获得通关的副本IdTb
CopyDateCache.getPassCopyId = function()
	return curIdTb
end

CopyDateCache.clear = function()
	mResponseInfos = nil 
	curIdTb = {}
	preIdTb = {}
end

CopyDateCache.upDate_CopyInfo = function(curCopyId,curScore)
	if nil == mResponseInfos or curCopyId == nil then
		return
	end
	curCopyId = tonumber(curCopyId)
	if isGetReSpone(curCopyId) == true then 
		for k,v in pairs(mResponseInfos) do
			if tonumber(v.copy_id) == curCopyId then 
				if mResponseInfos[k].max_score < curScore then 
					mResponseInfos[k].max_score = curScore 
				end 
				mResponseInfos[k].pass_times = mResponseInfos[k].pass_times + 1 
			end 
		end 
	else 
		local tb = {
			["copy_id"] = curCopyId,
			["max_score"] = curScore,
			["pass_times"] = 1
		}
		table.insert(mResponseInfos,tb)
		
		table.insert(curIdTb,curCopyId)
	end 
end

----------------------------------------------------------------------

-- 初始化 主线副本 得分情况 
CopyDateCache.init = function(resp)
	mResponseInfos = resp.copyinfos -- 各个关卡的星星
		
	--剔除新手引导星级
	for k,v in pairs(mResponseInfos) do
		if tonumber(v.copy_id) == 1 then -- 新手引导 关卡 （如果有2个会再改)
			table.remove(mResponseInfos,k)
		end
		table.insert(curIdTb,v.copy_id)
	end
	preIdTb = CommonFunc_table_copy_table(curIdTb) 
			
	if mAllFbMsg == nil then 
		mAllFbMsg = LogicTable.getGameAllFB()
	end
	EventCenter_post(EventDef["ED_COPY_INFOS"])
	EventCenter_post(EventDef["ED_UPDATE_ROLEUP_INFO"])
	EventCenter_post(EventDef["ED_UPDATE_ROLE_INFO"])
end
-- 获取当前副本的星星
CopyDateCache.getScoreById = function(copyId)
	if nil == mResponseInfos then
		return 0
	end
	for k,v in pairs(mResponseInfos) do
		if v.copy_id == tonumber(copyId) then 	
			return tonumber(v.max_score)
		end
	end
	return 0
end

--当前副本是否达到等级限制
CopyDateCache.isLvLimit = function(copyid)
	--copyId = tonumber(copyId)
	local copyInfo  = LogicTable.getCopyById(copyid)
	if ModelPlayer.getLevel() < tonumber(copyInfo.need_level)  then 
		return true,copyInfo.need_level
	end 
	return false
end 

--获得当前副本群状态	pass 已通关 doing 攻打中 lock 未开启
CopyDateCache.getGroupStatusById = function(group_id)
	--CopyDateCache.getCopyStatus()
	local status = nil 
	local copyGroupInfo = LogicTable.getCopyGroupById(group_id)
	
	local lastCopyStatus = CopyDateCache.getCopyStatus(copyGroupInfo.last_copy_id)	
	local firstCopyStatus = CopyDateCache.getCopyStatus(copyGroupInfo.first_copy_id)
	
	if lastCopyStatus == "pass" then 
		status =  "pass"
	else 
		if firstCopyStatus == "lock" then
			status =  "lock"
		else 
			status =  "doing"
		end
	end
	
	assert(status ~= nil,"查询不到当前副本群状态!!!")
	return status
end


--获取当前副本群已经通关多少个普通副本 copy_type:副本类型
CopyDateCache.hasPassByGroup = function(ground_id,copy_type)
	local index = 0
	if mResponseInfos then
		for k,v in pairs(mResponseInfos) do
			local copyInfo  = LogicTable.getCopyById(v.copy_id)
			if tonumber(copyInfo.copy_group_id) == tonumber(ground_id) then 
				if tonumber(copyInfo.type) == tonumber(copy_type) then 
					index = index + 1
				end
			end
		end
	end
	local pt,jy,boos = CopyDateCache.getCurGroupLength(ground_id)
	local totalIndex = nil 
	if tonumber(copy_type) == 1  then 	--普通
		totalIndex = #pt
	elseif tonumber(copy_type) == 2 then 	--精英
		totalIndex = #jy
	elseif tonumber(copy_type) == 3 then  --BOSS本
		totalIndex = #boos
	end 
	return index,totalIndex
end

--该副本是BOSS本吗？
CopyDateCache.isBossByCopyId = function(id)
    local Result = false 
    id = tostring(id)

    local copyInfo  = LogicTable.getCopyById(id)
    if copyInfo ~= nil and tonumber(copyInfo.type) == 3 then 
        Result = true 
    end 
    return Result
end 
 

--获取当前副本群长度  返回 1：ptCopyid_tb普通FB（table） 2：jyCopyid_tb精英FB(table) 参数 ground_id(副本群ID)
CopyDateCache.getCurGroupLength = function(ground_id)
	local ptCopyid_tb = {}
	local jyCopyid_tb = {}
	local bosoCopyid_tb = {}
	for k,copy in pairs(mAllFbMsg) do
		if tonumber(copy.copy_group_id) == 0 and tonumber(copy.type) == 3 then 
			table.insert(bosoCopyid_tb,copy.id)	 --BOSS本
		elseif ground_id ~= nil and tonumber(copy.copy_group_id) == tonumber(ground_id) then
			if tonumber(copy.type) == 1 then 	  --普通副本
				table.insert(ptCopyid_tb,copy.id)
			elseif tonumber(copy.type) == 2 then  --精英副本
				table.insert(jyCopyid_tb,copy.id)				
			end
		end
	end
	return ptCopyid_tb,jyCopyid_tb,bosoCopyid_tb
end
--获取所有精英FB
--[[
CopyDateCache.getAllJyFB = function()
	local jyCopyid_tb = {}
	for k,copy in pairs(mAllFbMsg) do
		if copy.times_limit ~= 0 then  
			table.insert(jyCopyid_tb,copy.id)
		end
	end
	return jyCopyid_tb
end
]]--
--mode 1 为普通本 2为精英本 return 当前正在攻打副本ID
CopyDateCache.getLastCopyIdByMode = function(mode)
	local mModeFbMsg = {}
	for k,copyInfo in pairs(mAllFbMsg) do
		if tonumber( copyInfo.type ) == mode then
			table.insert(mModeFbMsg, copyInfo)
		end
	end
    for k,copyInfo in pairs(mModeFbMsg) do
		if CopyDateCache.getCopyStatus(tonumber(copyInfo.id)) == "doing" then
			return tonumber(copyInfo.id)
		end
		if k == #mModeFbMsg and CopyDateCache.getCopyStatus(tonumber(copyInfo.id)) == "pass" then
			return tonumber(copyInfo.id)
		elseif k == #mModeFbMsg and CopyDateCache.getCopyStatus(tonumber(copyInfo.id)) == "lock" then
			return 0
		end
	end
	return nil
end

--获取当前主线副本群 各个副本旗帜展示 已解锁：pass 已通关 doing 攻打中 lock 未开启
--参数 copy 副本ID
CopyDateCache.getCopyStatus = function(copyid)
	local status = nil
	local isPlayerOpenAnimation = false
	local copyInfo  = LogicTable.getCopyById(copyid)
	
	if tonumber(copyid) == 1001 then	--第一个副本写死
		--mCopyDoing_id = copyid		--当前正在攻打的副本
        if isGetReSpone(1001) == true then 
            return "pass"
        else 
		    return "doing"
        end 
	end
	--第一次单独判断
	if nil == mResponseInfos or 0 == #mResponseInfos then
		return "lock"
	end 
	
	if isGetReSpone(copyid) == true then 
		status = "pass"
	else
		if IsPassAll_Precopy(copyid) == true then
		--if isGetReSpone(copyInfo.pre_copy) then 
			status = "doing"
		else 
			status = "lock"
		end
	end
	
	assert(status ~= nil,"查询不到当前副本!状态!!!")
	return status	
end


--获取当前副本 的 副本群ID
CopyDateCache.getGroupIdByCopyId = function(Copy_id)
	local copyInfo = LogicTable.getCopyById(Copy_id)
	return copyInfo.copy_group_id
end 


--获取当前普通副本的下一个副本
--[[
local function getNextPtCopyId(curr_copy_id)
	for k,copyInfo in pairs(mAllFbMsg) do
		if copyInfo.type == "1" then 
			assert(copyInfo.pre_copy[2] == nil,"普通副本 有2个以上前置副本？CNM策划填错了,id:"..copyInfo.id)
			if tonumber(copyInfo.pre_copy[1]) == curr_copy_id then --1 :普通副本
				return tonumber(copyInfo.id)
			end
		end
	end 
	cclog("curr_copy_id 不是普通副本 或者 当前副本已经是最后一个副本")
	return nil 
end 
]]--

 local function getNextPtCopyId(curr_copy_id)
	local curr_copy_id_Info = LogicTable.getCopyById(curr_copy_id)
    if mAllFbMsg == nil then return end
	for k,copyInfo in pairs(mAllFbMsg) do
		if copyInfo.type == curr_copy_id_Info.type then 
			--assert(copyInfo.pre_copy[2] == nil,"普通副本 有2个以上前置副本？CNM策划填错了,id:"..copyInfo.id)
			if PreCopyContainsThisCopy(copyInfo.pre_copy,curr_copy_id) then --1 :普通副本
				return tonumber(copyInfo.id)
			end
		end
	end 
	cclog("curr_copy_id 不是普通副本 或者 当前副本已经是最后一个副本")
	return nil 
end 

-- 过掉当前关卡 是否新的关卡解锁
local function isLockNewCopy(passCopy_id)
	local result = false 
	local newCopyId = getNextPtCopyId(passCopy_id)
	if newCopyId ~= nil then 
		if CopyDateCache.getCopyStatus(newCopyId) == "doing" then 
			result = true 
		end 
	end
	return result,newCopyId
end

-- 过掉的这个关卡解锁新的BOSS本么？
local function isNewMulCopyLocked(passCopy_id,CopyTpey)

	for k,copyInfo in pairs(mAllFbMsg) do  
		if copyInfo.type == tostring(CopyTpey) then 
			--如果 passCopy_id 属于 这个BOSS本前置副本
			if PreCopyContainsThisCopy(copyInfo.pre_copy,passCopy_id) == true then	
				--并且这个副本前置副本都过了
				if IsPassAll_Precopy(copyInfo.id) == true then 
					return true,copyInfo.id
				end 
			end
		end 
	end
	return false
end 


CopyDateCache.KeepPassCopyAnimationDate = function(passCopy_id)
	local result,newCopyId = isLockNewCopy(passCopy_id)
	
	local isNewJyCopyOpen = false 	--是否有新的BOSS本被解锁
	local jyCopyId = nil			--被解锁ID
	
	local isNewBossCopyOpen = false 	--是否有新的BOSS本被解锁
	local BossCopyId = nil			--被解锁ID

	if result == true then 	
		isNewJyCopyOpen,jyCopyId = isNewMulCopyLocked(passCopy_id,2) 
		isNewBossCopyOpen,BossCopyId = isNewMulCopyLocked(passCopy_id,3) --3 :BOSS本	
	end 
	
	local Date = {}
	Date.result = result	-- 是否要播放动画
	Date.newCopyId = newCopyId	--下个副本ID
	Date.isNewJyCopyOpen = isNewJyCopyOpen--是否有新的BOSS本被解锁
	Date.jyCopyId = jyCopyId
	Date.isNewBossCopyOpen = isNewBossCopyOpen--是否有新的BOSS本被解锁
	Date.BossCopyId = BossCopyId
	
	for k,v in pairs (Date) do 
		cclog("ANIMATION:kEY",k,v)
	end 
	
	return Date
end 




NetSocket_registerHandler(NetMsgType["msg_notify_last_copy"], notify_last_copy, CopyDateCache.init)