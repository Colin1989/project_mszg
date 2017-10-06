----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-02
-- Brief:	冲级活动逻辑
----------------------------------------------------------------------
local mMaxId = 0							--保存当前冲级领过的最大id

LevelGiftLogic = {}

----------------------------------------------------------------------
-- 根据当前的等级判断并显示冲级按钮,是否有未领取的奖励
LevelGiftLogic.existAward = function()
	--根据最大的领取冲级奖励id，获得下一个等级的奖励
	if (mMaxId +1) <= LevelGiftLogic.getMaxRewardId() then
		local  tb = LogicTable.getlevelGiftInfoById(mMaxId + 1)
		if ModelPlayer.getLevel() ~= nil and (tb.level) <= ModelPlayer.getLevel() then
			return true		--冲级按钮显示（可以显示）
		else
			return false	--冲级按钮不显示（还未达到等级）
		end
	else		
		return false		--还未达到等级
	end
end
----------------------------------------------------------------------
-- 获得最大的等级
LevelGiftLogic.getMaxLevel = function()
	local  tempTb = LogicTable.getlevelGiftInfo()
	mMaxLevel = LogicTable.getlevelGiftInfoById(#tempTb).level	
	return mMaxLevel
end
----------------------------------------------------------------------
-- 获得最大的最终的id
LevelGiftLogic.getMaxRewardId = function()
	local  tempTb = LogicTable.getlevelGiftInfo()
	return #tempTb
end
----------------------------------------------------------------------
-- 获取要显示的两个列表的id
LevelGiftLogic.getRewardList = function()
	local tb ={}
	if (mMaxId) == LevelGiftLogic.getMaxRewardId() then
		tb ={}
	elseif (mMaxId + 1) >= LevelGiftLogic.getMaxRewardId() then
		tb={LevelGiftLogic.getMaxRewardId()}
	else
		tb = {mMaxId + 1, mMaxId + 2}		
	end
	return tb
end
----------------------------------------------------------------------
-- 获得解锁的最大id
LevelGiftLogic.getMaxId = function()
	return mMaxId
end
--------------------------------------------------------------------------
-- 通知已经领取过的奖励信息
local function handleNofityUpgradeRewardList(packet)
	if #packet.reward_ids == 0 then
		mMaxId = 0
	else
		mMaxId = packet.reward_ids[1]
	end
	EventCenter_post(EventDef["ED_LEVEL_GET_GIFT"])
end
--------------------------------------------------------------------------
-- 通知领取奖励信息
local function handleNofityUpgradeRewardResult(packet)
	--根据请求的id，展示获得的信息
	if packet.result == 1 then
		local tb = LogicTable.getlevelGiftInfoById(packet.task_id)
		CommonFunc_showItemGetInfo(tb.reward_ids, tb.reward_amounts)
		mMaxId = mMaxId + 1
		EventCenter_post(EventDef["ED_LEVEL_GET_GIFT"])
	end	
end
--------------------------------------------------------------------------
-- 请求领取冲级奖励
LevelGiftLogic.request_get_level_award = function(id)
	local tb = req_upgrade_task_reward()
	tb.task_id = id 
	NetHelper.sendAndWait(tb, NetMsgType["notify_upgrade_task_reward_result"])
end
----------------------------------------------------------------------
-- 监听通知系统冲级奖励消息
NetSocket_registerHandler(NetMsgType["msg_notify_upgrade_task_rewarded_list"], notify_upgrade_task_rewarded_list, handleNofityUpgradeRewardList)		-- 通知已经领取过的奖励信息
NetSocket_registerHandler(NetMsgType["msg_notify_upgrade_task_reward_result"], notify_upgrade_task_reward_result, handleNofityUpgradeRewardResult)		-- 通知领取奖励信息


