----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-07
-- Brief:	炼金术逻辑
----------------------------------------------------------------------
GetCoinLogic = {}
local mAlchemyInfo 		--保存获取到的炼金的信息

local mNewDay = true				-- 新的一天
local mDailyTimerFlag = false

----------------------------------------------------------------------
-- 判断是达到领取炼金奖励的条件
GetCoinLogic.existAward = function()
	--返回的是是否有炼金奖励，和（可以领奖，但没有领奖的位置）
	if mAlchemyInfo == nil then
		return
	end
	local tempTb = {}	--保存可以领奖，但是还没有领的index
	local tempRewardInfo = LogicTable.getCoinInfoById(mAlchemyInfo.level)
	--没有领取过任何奖励的情况
	if #mAlchemyInfo.rewarded_list == 0 then
		for i=1 ,#tempRewardInfo.reward_ids,1 do
			if  #mAlchemyInfo.rewarded_list == 0 and  ModelPlayer.getAlchemy() >= Alchemy_ExpQua[i] then
				table.insert(tempTb,i)
			end
		end
	else
		--判断该奖励是否已经领取过了，根据奖励位置
		local function judgeReceivedYONByIndex(index)
			for key,value in pairs(mAlchemyInfo.rewarded_list) do
				if value == index then
					return true
				end
			end
			return false
		end
		
		--从两个表中找出不同的数值
		for i=1 ,#tempRewardInfo.reward_ids,1 do
			if judgeReceivedYONByIndex(i) == false and ModelPlayer.getAlchemy() >= Alchemy_ExpQua[i] then 
				table.insert(tempTb,i)
			end
		end
	end
	
	-- local mPubLeftTimes = Alchemy_Pub_Times + getVipAddValueById(6) - mAlchemyInfo.nomrmal_count
	local mPubLeftTimes = Alchemy_Pub_Times - mAlchemyInfo.nomrmal_count
	--local mSpeLeftTimes = Alchemy_Spe_Times + getVipAddValueById(7) - mAlchemyInfo.advanced_count
	if #tempTb > 0 or (mAlchemyInfo.remain_normal_second == 0 and mPubLeftTimes > 0) then
		return true,tempTb
	else
		return false,tempTb
	end
end
----------------------------------------------------------------------
-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	EventCenter_post(EventDef["ED_ALCHEMY_GET"])
end
----------------------------------------------------------------------
-- 获得炼金的信息
GetCoinLogic.getAlchemyInfo = function()
	return mAlchemyInfo
end
----------------------------------------------------------------------
-- 处理炼金术信息
local function handleNofityAlchemyInfo(packet)
	mAlchemyInfo = packet	
	EventCenter_post(EventDef["ED_ALCHEMY_GET"])
	EventCenter_post(EventDef["ED_ALCHEMY"])
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	TipFunction.setFuncAttr("func_get_coin", "count", packet.nomrmal_count)
end
----------------------------------------------------------------------
-- 处理炼金
local function handleNofityMetallurgy(packet)
	
	if packet.result == 1 then
		local typeAlchemy = LayerGetCoin.getAlchemyType()
		AlchemyInfo = LogicTable.getCoinInfoById(mAlchemyInfo.level)
		if typeAlchemy == 1 then
			Toast.Textstrokeshow(GameString.get("getCoin",AlchemyInfo.normal_reward_gold),ccc3(255,255,255),ccc3(0,0,0),30)
		else
			Toast.Textstrokeshow(GameString.get("getCoin",AlchemyInfo.advanced_reward_gold),ccc3(255,255,255),ccc3(0,0,0),30)
		end
		
	end	
end
----------------------------------------------------------------------
-- 处理领取炼奖励
local function handleNofityAlchemyReward(packet)
	
	if packet.result == 1 then	
		local id ,amount = LayerGetCoin.getIdAmount()
		CommonFunc_showItemGetInfo(id, amount)
	end
end
----------------------------------------------------------------------
-- 请求炼金术信息
GetCoinLogic.requestAlchemyInfo = function()
	local tb = req_alchemy_info()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_alchemy_info"])
end
----------------------------------------------------------------------
-- 请求炼金
GetCoinLogic.requestAlchemy = function(types)
	local tb = req_metallurgy()
	tb.type = types
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_metallurgy_reuslt"])	
end
----------------------------------------------------------------------
-- 请求领取炼奖励
GetCoinLogic.requestAlchemyReward = function(id)
	local tb = req_alchemy_reward()
	tb.type = id
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_alchemy_reward_reuslt"])
end
----------------------------------------------------------------------

-- 监听通知系统炼金术信息
NetSocket_registerHandler(NetMsgType["msg_notify_alchemy_info"], notify_alchemy_info, handleNofityAlchemyInfo)		-- 监听炼金术信息
NetSocket_registerHandler(NetMsgType["msg_notify_metallurgy_reuslt"], notify_metallurgy_reuslt, handleNofityMetallurgy)		-- 监听炼金
NetSocket_registerHandler(NetMsgType["msg_notify_alchemy_reward_reuslt"], notify_alchemy_reward_reuslt, handleNofityAlchemyReward)	-- 监听领取炼奖励
