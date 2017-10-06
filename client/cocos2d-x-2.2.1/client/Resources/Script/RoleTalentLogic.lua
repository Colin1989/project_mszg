----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-21
-- Brief:	英雄天赋的逻辑
TalentLogic ={}

local mActiveTb = {}		--保存所有的已经激活过的Id
local mLeftTime = 0			--冷却时间
local mScrollData = nil		--把层数相同的表按位置放在一起
local mMaxPubCopyId = nil	--获得最大的副本Id

-----------------------------------请求升级天赋-----------------------------------
--请求升级天赋
TalentLogic.requestlelUpTalent = function(id)
	local req = req_level_up_talent()
	req.talent_id = id
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_level_up_talent"])
end

--处理升级天赋的信息
local function handleNotifyLelUpTalent(packet)
	--Log(packet)
	if packet.is_success == 1 then			--成功
		--Toast.Textstrokeshow(GameString.get("Public_talent_lelup"),ccc3(255,255,255),ccc3(0,0,0),30)
		
		EventCenter_post(EventDef["ED_ROLETALENT_LEVELUP"])			--升级后，角色信息会推吗？会推
	end
end
------------------------------------请求重置天赋-------------------------
-- 定时器触发回调
local function timerRunCF(tm)
	local leftTime = tm.getParam() - 3600
	tm.setParam(leftTime)
	EventCenter_post(EventDef["ED_ROLETALENT_Time"], leftTime)
end

-- 定时器结束回调
local function timerOverCF(tm)
	
	
end

--请求重置天赋
TalentLogic.requestResetTalent = function()
	local req = req_reset_talent()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_reset_talent"])
end

--处理重置天赋的信息
local function handleNotifyResetTalent(packet)
	--Log(packet)
	if packet.is_success == 1 then
		Toast.show(GameString.get("Public_talent_reset_success"))
		--mLeftTime = RoleTalent_Reset_Time
		mActiveTb = {}
		
		if mLeftTime == 0 then
			mLeftTime = RoleTalent_Reset_Time
			local timer = CreateTimer(3600, mLeftTime, timerRunCF, timerOverCF)
			timer.setParam(mLeftTime)
			timer.start()
			EventCenter_post(EventDef["ED_ROLETALENT_Time"], mLeftTime)	
		end
		
		
		EventCenter_post(EventDef["ED_ROLETALENT_LEVELUP"])	
		EventCenter_post(EventDef["ED_ROLETALENT"])
	end
end
------------------------------------请求激活某天赋-------------------------
--请求激活某天赋
TalentLogic.requestActiveTalent = function(id)
	local req = req_actived_talent()
	req.talent_id = id
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_actived_talent"])
end

--处理激活某天赋的信息
local function handleNotifyActiveTalent(packet)
	--Log("handleNotifyActiveTalent",packet)
	if packet.is_success == 1 then
		table.insert(mActiveTb,packet.talent_id)
		Toast.Textstrokeshow(GameString.get("Public_talent_active_success"), ccc3(255,255,255), ccc3(0,0,0), 30)
		EventCenter_post(EventDef["ED_ROLETALENT_LEVELUP"])	
		EventCenter_post(EventDef["ED_ROLETALENT"])
	end
end
-------------------------------------已经激活过的天赋的id-----------------------------------
--获得冷却时间
TalentLogic.getLeftTime = function()
	return mLeftTime
end

--处理收到的天赋信息
local function handleNotifyTalentInfo(packet)
	--Log("处理收到的天赋信息************",packet)
	mActiveTb = packet.active_talent_ids
	mLeftTime = packet.reset_active_hours
	if mLeftTime > 0 then
		local timer = CreateTimer(3600, mLeftTime, timerRunCF, timerOverCF)
		timer.setParam(packet.reset_active_hours)
		timer.start()
	end
	EventCenter_post(EventDef["ED_ROLETALENT"])
end

--获得己经激活过的id
TalentLogic.getActiveTalentIds = function()
	return  mActiveTb
end

--获得已经激活过的天赋的id和等级(给战斗的接口)
TalentLogic.getActiveTalentInfo = function()
	local talentTb = {}
	local  data =  TalentLogic.getActiveTalentIds()
	for key,value in pairs(data) do
		local tempTb = LogicTable.getTalentTableRow(value)
		tempTb.level = ModelSkill.getTalentLevel(value)		--当前天赋的等级
		
		local curLevel = tempTb.level
		if  string.len(curLevel) == 1 then
			curLevel = tostring(0)..curLevel
		end
		curLevel = tonumber(tempTb.level_up_id..curLevel)
	 
		local levelUpInfo = LogicTable.getTalentlelUpTableRow(curLevel)
		tempTb.skill_piece_id = levelUpInfo.skill_piece_id	--天赋升到下一级所需的碎片id
		tempTb.describe = levelUpInfo.describe				--天赋描述
		tempTb.skill_piece_num = levelUpInfo.skill_piece_num--天赋升到下一级所需的碎片数量
		table.insert(talentTb,tempTb)
	end
	return talentTb
end
----------------------------表中数据处理-------------------------------
--把层数相同的表按位置放在一起
local function getData()
	local tempData = LogicTable.getTalentTable()
	--Log("11111******",tempData)
	local data = {}			--按层数和位置存放好的数据表
		--获得同一层的三个数据
		local function getEveryFloorData(layer,val)
			local layerData = {}
			if #data >= layer then
				for key,value in pairs(data[layer]) do
					if  value.layer == layer then
						table.insert(data[layer],val.position,val)
						return 
					end
				end
			end
			table.insert(layerData,val.position,val)
			table.insert(data,layer,layerData)	
		end
	for key,value in pairs(tempData) do
		getEveryFloorData(value.layer,value)
	end
	mScrollData = data
	--Log("getData******",mScrollData)
end

--清楚数据
TalentLogic.clearData = function()
	mScrollData = nil
end


--获得scroll数据
TalentLogic.getScrollData = function()
	if mScrollData == nil then
		getData()
	end
	return  mScrollData
end

------------------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_get_talent_active_info"],notify_get_talent_active_info, handleNotifyTalentInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_actived_talent"], notify_actived_talent, handleNotifyActiveTalent)
NetSocket_registerHandler(NetMsgType["msg_notify_reset_talent"], notify_reset_talent, handleNotifyResetTalent)
NetSocket_registerHandler(NetMsgType["msg_notify_level_up_talent"], notify_level_up_talent, handleNotifyLelUpTalent)

---------------------------------------------------------------------

