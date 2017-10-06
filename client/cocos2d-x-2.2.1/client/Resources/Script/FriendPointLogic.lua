----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-03
-- Brief:	友情点奖励逻辑
----------------------------------------------------------------------
FriendPointLogic = {}
local mRewardTb = {} 			-- 请求到的获得的奖励物品的信息
local mRefreshList = {}			-- 刷新列表的id
----------------------------------------------------------------------
local function handleClearData()
	mRewardTb = {}
	mRefreshList = {}
end
----------------------------------------------------------------------
-- 根据当前的等级判断并显示领取友情点提示
FriendPointLogic.existAward = function()
	local itemInfo = {}
	if AssistanceLogic.getLotteryTimes() >= #LogicTable.getFriendPointInfo() then
		itemInfo = LogicTable.getFriendPointInfoById(#LogicTable.getFriendPointInfo())
	else
		itemInfo = LogicTable.getFriendPointInfoById(AssistanceLogic.getLotteryTimes() + 1 )
	end
	if  ModelPlayer.getFriendPoint()~= nil and ModelPlayer.getFriendPoint() >= itemInfo.need_point then
		return true
	else
		return false
	end
end
----------------------------------------------------------------------
-- 请求抽取奖励
FriendPointLogic.request_get_reward = function()
	local tb = req_friend_point_lottery()
	NetHelper.sendAndWait(tb, NetMsgType["notify_friend_point_lottery_result"])
end
----------------------------------------------------------------------
-- 获得抽取到的奖励的id
FriendPointLogic.get_reward_Tb = function()
	return mRewardTb
end
----------------------------------------------------------------------
-- 通知请求领取友情点奖励信息
local function handleNofityGetRewardResult(packet)
	if packet.result == 1 then
		local idTb = {packet.id}
		local amountTb = {packet.amount}    
		mRewardTb.id = packet.id
		mRewardTb.amount = packet.amount
		LayerFriendPoint.imageMove(idTb,amountTb)
		EventCenter_post(EventDef["ED_FRIEND_POINT_GET"])
	end		
end
----------------------------------------------------------------------
-- 处理刷新奖励列表
FriendPointLogic.getRefreshRewardId = function()
	return  mRefreshList	
end
----------------------------------------------------------------------
-- 处理刷新奖励列表
local function handleNofityRefreshlotteryList(packet)
	mRefreshList = packet.lottery_items
	LayerFriendPoint.setGetRewardBtnTouchEnabled()
	EventCenter_post(EventDef["ED_FRIEND_POINT_REFRESH"])
end
----------------------------------------------------------------------
-- 请求刷新奖励列表
FriendPointLogic.requestRefreshlotteryList = function()
	local tb = req_fresh_lottery_list()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_fresh_lottery_list"])
end
----------------------------------------------------------------------
-- 监听通知系统友情点奖励消息
NetSocket_registerHandler(NetMsgType["msg_notify_friend_point_lottery_result"], notify_friend_point_lottery_result, handleNofityGetRewardResult)		-- 通知领取奖励信息
NetSocket_registerHandler(NetMsgType["msg_notify_fresh_lottery_list"], notify_fresh_lottery_list, handleNofityRefreshlotteryList)		-- 监听刷新列表

----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)

