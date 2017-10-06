-- 副本数据缓存 

CopyDateCache = {}
CopyDateCache.GameType = game_type["common"]	--游戏模式


local mResponseInfos = nil -- 星星详细列表
local mAllFbMsg = nil -- 所有FB信息


-- 初始化 主线副本 得分情况 
CopyDateCache.init = function(resp)
	mResponseInfos = resp.copyinfos -- 各个关卡的星星
		
	if mAllFbMsg == nil then 
		mAllFbMsg = LogicTable.getGameAllFB()
	end
	--CommonFunc_TableLog(mResponseInfos)
end

CopyDateCache.getScoreById = function(copyId)
	for k,v in pairs(mResponseInfos) do
		if v.copy_id == copyId then 	
			return tonumber(v.max_score)
		end
	end
end

-- 进入加一个副本吗？
CopyDateCache.NextAble =function (curId,maxGroud_id)
	cclog("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1",curId,maxGroud_id)
	curId = curId + 1
	if curId <= maxGroud_id then 
		cclog("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3",curId,maxGroud_id)
		return true
	end
	
	for k,v in pairs( LogicTable.getGameAllFB() ) do
		if curId == tonumber(v.id) and v.times_limit == "0" then 
			return true
		end
	end
	return false
end

-- 有上一个副本吗？
CopyDateCache.lastAble =function (curId)
	curId = curId - 1	
	for k,v in pairs( LogicTable.getGameInstance() ) do
		if curId == tonumber(v.id) then 
			return true
		end
	end
	return false
end

--初始化渲染的是哪个主线副本群
CopyDateCache.getCurShowGroup = function()
	if #mResponseInfos < 1 then 
		return mAllFbMsg[1].copy_group_id
	end
	
	
	local ResponseInfos = {}
	
	for k1,copy in pairs(mResponseInfos) do
		local copyTb  = LogicTable.getInstanceSelect(copy.copy_id)
		-- 当前副本群 且 次数没有限制
		if  copyTb.times_limit == "0"  then 

			table.insert(ResponseInfos,copy.copy_id)
		end
	end
	
	for k,v in pairs(mResponseInfos) do
		if(#mResponseInfos == k)  then  --最后一个字段
			local findCopy = LogicTable.getInstanceSelect(v.copy_id) 
			local next_copyId = findCopy.next_copy 
			if next_copyId == 0 then 		-- 是最后一个副本吗？
				return findCopy.copy_group_id
			else
				local copy = LogicTable.getInstanceSelect(next_copyId) 
				return copy.copy_group_id
			end
		end
	end
end

--获取当前副本群长度  返回 1：普通FB（table） 2：精英FB(table)  ground_id(副本群ID)
CopyDateCache.getCurGroupLength = function(ground_id)
	local ptCopyid_tb = {}
	local jyCopyid_tb = {}
	for k,copy in pairs(mAllFbMsg) do
			
		if copy.copy_group_id == ground_id then
			if copy.times_limit == 0 then  -- 是普通副本吗？
				--ptCopy = ptCopy + 1
				cclog("INSERT_pt_fb--------------->ID ",copy.id)
				table.insert(ptCopyid_tb,copy.id)
			else 
				cclog("INSERT_jy_fb--------------->ID ",copy.id)
				table.insert(jyCopyid_tb,copy.id)
			end
		end
	end
	return ptCopyid_tb,jyCopyid_tb
end


--获取当前主线副本群 各个副本旗帜展示 已解锁：white_flag插白旗、red_flag当前插红旗、未解锁：不插旗 visiable
--参数 copy 副本ID
CopyDateCache.showFlag = function(copyId,Group_id)
	--第一次单独判断
	cclog("传入副本ID",copyId,"副本群ID",Group_id)
	if #mResponseInfos == 0 then 
		if copyId == mAllFbMsg[1].id then 
			return "red_flag"
		end 
	end 
	
	-- 剔掉是精英副本的表的元素，但原来的表不能被改
	local ResponseInfos = {}
	
	for k1,copy in pairs(mResponseInfos) do
		local copyTb  = LogicTable.getInstanceSelect(copy.copy_id)
		-- 当前副本群 且 次数没有限制
		if  tonumber( copyTb.copy_group_id) == Group_id and  copyTb.times_limit == "0"  then 
			cclog("insert cur_groupFB  -!!!!!!!!!!!!!!-->",copy.copy_id,k1)
			--table.remove(ResponseInfos,k1)
			table.insert(ResponseInfos,copy.copy_id)
		end
	end
	
	if #ResponseInfos <= 0 then 	--如果是当前副本群的第一个副本
		if copyId%100 == 1 then 
			return "red_flag"
		else
			return "white_flag"
		end
	end
	
	for k,v_copy_id in pairs(ResponseInfos) do
		if copyId == v_copy_id then 
			return "visiable"
		end
		if(#ResponseInfos == k) then 
			local Copy = LogicTable.getInstanceSelect(v_copy_id)
			 	
			if Copy.next_copy == copyId then 
				return "red_flag"
			end
		end
	end
	return "white_flag"
		
	
end

--当前精英副本是否解锁
CopyDateCache.IsLockCurJy = function(jyCopy_id,group_id)
	local copy = LogicTable.getInstanceSelect(jyCopy_id)
	local pre_copy =LogicTable.getInstanceSelect( tonumber( copy.pre_copy) )
	if( CopyDateCache.showFlag( tonumber(pre_copy.id),group_id ) == "visiable") then 	
		return true
	end
	return false
end
-- 当前精英副本是否次数用尽 
CopyDateCache.Hitable =function (jyCopy_id) 
	local copy = LogicTable.getInstanceSelect(jyCopy_id)
	for k,v in pairs(mResponseInfos) do
		if jyCopy_id == v.copy_id then
			local hitTime = tonumber ( copy.times_limit ) --可打次数
			if hitTime <= v.pass_times then 
				return false
			end
		end
	end
	return true
end




NetSocket_registerHandler(NetMsgType["msg_notify_last_copy"], notify_last_copy (), CopyDateCache.init)