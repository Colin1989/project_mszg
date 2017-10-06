--region SpringActivityLogic.lua
--Author : songcy
--Date   : 2015/01/23

SpringActivityLogic = {}

local mRewardTb = {} 			-- ���󵽵Ļ�õĽ�����Ʒ����Ϣ
local mRefreshList = {}			-- ˢ���б��id

local mSpringActivity = XmlTable_load("activity_tplt.xml", "id")					-- ���ڻ ��Ŀ ʱ�� ��
local mActivityLotteryRecharge = XmlTable_load("act_lottery_reward_tplt.xml", "id")		-- ���ڻ�齱����
local mActivityLottery = XmlTable_load("act_lottery_tplt.xml", "id")		-- ���ڻ�齱����
local mActivityRecharge = XmlTable_load("act_recharge_tplt.xml", "id")		-- ���ڳ�ֵ�ͺ���

-- {year, month, day, hour, min|minute, sec|second}

--��ȡ���д��ڻ
SpringActivityLogic.getAllSpringActivity = function()
	local tb = {}
	for k, v in pairs(mSpringActivity.map) do
		local row = {}

		row.id = v.id
		row.icon = v.icon
		row.begin_time_array = CommonFunc_parseTuple(v.begin_time_array, true)
		row.end_time_array = CommonFunc_parseTuple(v.end_time_array, true)
		
		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

-- ��ȡ���ڻ
SpringActivityLogic.getSpringActivityById = function(id)
	local res = XmlTable_getRow(mSpringActivity, id, true)
	local row = {}

	row.id = res.id
	row.icon = res.icon
	row.begin_time_array = CommonFunc_parseTuple(res.begin_time_array, true)
	row.end_time_array = CommonFunc_parseTuple(res.end_time_array, true)
	
	return row
end

-- ��ȡ���г齱����
SpringActivityLogic.getAllActivityLotteryRecharge = function()
	local tb = {}
	for k, v in pairs(mActivityLotteryRecharge.map) do
		local row = {}

		row.id = v.id
		row.ids = v.ids
		row.amounts = v.amounts + 0
		row.rate = v.rate + 0

		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

-- ��ȡ�齱����
SpringActivityLogic.getActivityLotteryRechargeById = function(id)
	local res = XmlTable_getRow(mActivityLotteryRecharge, id, true)
	local row = {}

	row.id = res.id
	row.ids = res.ids
	row.amounts = res.amounts + 0
	row.rate = res.rate + 0
	
	return row
end

-- ��ȡ����齱�����л
SpringActivityLogic.getAllActivityLottery = function()
	local tb = {}
	for k, v in pairs(mActivityLottery.map) do
		local row = {}

		row.id = v.id
		row.name = v.name
		row.need_times = v.need_times + 0
		row.repeat_type = v.repeat_type + 0

		table.insert(tb, row)
	end
	return tb
end

-- ��ȡ����齱�Ļ
SpringActivityLogic.getActivityLotteryById = function(id)
	local res = XmlTable_getRow(mActivityLottery, id, true)
	local row = {}

	row.id = res.id
	row.name = res.name
	row.need_times = res.need_times + 0
	row.repeat_type = res.repeat_type + 0
	
	return row
end

-- ��ȡ���г�ֵ�ͺ���
SpringActivityLogic.getAllActivityRecharge = function()
	local tb = {}
	for k, v in pairs(mActivityRecharge.map) do
		local row = {}

		row.id = v.id
		row.describe = v.describe
		row.need_emoney = v.need_emoney + 0
		row.reward_ids = CommonFunc_split(v.reward_ids, ",")
		row.reward_amounts = CommonFunc_split(v.reward_amounts, ",")

		table.insert(tb, row)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end

-- ��ȡ��ֵ�ͺ���
SpringActivityLogic.getActivityRechargeById = function(id)
	local res = XmlTable_getRow(mActivityRecharge, id, true)
	local row = {}
	
	row.id = res.id
	row.describe = res.describe
	row.need_emoney = res.need_emoney + 0
	row.reward_ids = CommonFunc_split(res.reward_ids, ",")
	row.reward_amounts = CommonFunc_split(res.reward_amounts, ",")
	
	return row
end




----------------------------------------------------------------------
-- ��б�
local function handle_activity_list(resp)
	-- cclog("---------------------------------->handle_activity_list")
	-- Log(resp)		-- resp.list	-- list.id list.remain_secondsʣ��ʱ��
end
NetSocket_registerHandler(NetMsgType["msg_notify_activity_list"], notify_activity_list, handle_activity_list)

----------------------------------------------------------------------
-- ֪ͨ�齱��Ϣ
local function handle_act_lottery_info(resp)
	local tb = {}
	tb.progress_list = resp.progress_list
	tb.remain_count = resp.remain_count
	
	LayerSpringDraw.setLotteryInfo(tb)
	EventCenter_post(EventDef["ED_SPRING_PROGRESS"])		-- ˢ��չʾ
end
NetSocket_registerHandler(NetMsgType["msg_notify_act_lottery_info"], notify_act_lottery_info, handle_act_lottery_info)

----------------------------------------------------------------------
-- ��ó�ȡ���Ľ�����id
SpringActivityLogic.getRewardId = function()
	return mRewardTb
end

-- ֪ͨ��ȡ������Ϣ
local function handle_act_lottery_result(packet)
	if packet.result == 1 then
		LayerSpringDraw.setRewardId(packet.reward_id)
		LayerSpringDraw.imageMove()
	end
end

-- �����ȡ����
SpringActivityLogic.reqGetReward = function()
	local tb = req_act_lottery()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_act_lottery_result"])
end
NetSocket_registerHandler(NetMsgType["msg_notify_act_lottery_result"], notify_act_lottery_result, handle_act_lottery_result)		-- ֪ͨ��ȡ������Ϣ

-- ֪ͨ��ֵ����������Ϣ
local function handle_act_recharge_info(packet)
	local tb = {}
	tb.rewarded_list = packet.rewarded_list
	tb.cur_recharge_count = packet.cur_recharge_count
	LayerSpringRecharge.setActRecharge(tb)
	LayerSpringRecharge.refreshUI()
end
NetSocket_registerHandler(NetMsgType["msg_notify_act_recharge_info"], notify_act_recharge_info, handle_act_recharge_info)		-- ֪ͨ��ֵ����������Ϣ

local function handle_act_recharge_reward_result(packet)
	if packet.result == 1 then
		LayerSpringRecharge.insertActRecharge(packet.id)
		LayerSpringRecharge.refreshUI()
		local actRecharge = SpringActivityLogic.getActivityRechargeById(packet.id)
		CommonFunc_showItemGetInfo(actRecharge.reward_ids, actRecharge.reward_amounts)
	end
end
NetSocket_registerHandler(NetMsgType["msg_notify_act_recharge_reward_result"], notify_act_recharge_reward_result, handle_act_recharge_reward_result)		-- ֪ͨ��ȡ������

------------------------------------------------------------------------------------------------------
-- ɾ�����ڹ���
-- local function deleteOverdueNotice(array)
	-- local currTime = system_gettime()
	-- for key, val in pairs(array) do
		-- if array.form ~= true then
			-- local endTime = SystemTime.dateToTime(val.end_time)
			-- if endTime ~= nil and endTime <= currTime then
				-- table.remove(array, key)
			-- end
		-- end
	-- end
-- end


----------------------------------------------------------------------
-- �ж�ʱ�� �Ƿ�ʼ�����
local function checkYearDay(sTime, eTime, cDate)

	local ct = SystemTime.dateToTime(cDate)
	local st = SystemTime.dateToTime({year=sTime[1], month=sTime[2], day=sTime[3], hour=sTime[4], minute=sTime[5], second=sTime[6]})
	local et = SystemTime.dateToTime({year=eTime[1], month=eTime[2], day=eTime[3], hour=eTime[4], minute=eTime[5], second=eTime[6]})
	return ct >= st and ct <= et
end
----------------------------------------------------------------------
-- ����ʱ����ʽ
local function tableToTime(TimeTb)
	local tb = {}
	for k, v in pairs(TimeTb) do
		for x, y in pairs(v) do
			table.insert(tb, y)
		end
	end
	return tb
end

----------------------------------------------------------------------
-- ��ѯ�ʱ���Ƿ���Ч
SpringActivityLogic.isTimeValidById = function(id)
	-- �꣬�£��գ�Сʱ�����ӣ���
	local tempActivity = SpringActivityLogic.getSpringActivityById(id)
	local curDate = SystemTime.getServerDate()
	local mStartTime = tableToTime(tempActivity.begin_time_array)
	local mEndTime = tableToTime(tempActivity.end_time_array)
	
	if checkYearDay(mStartTime, mEndTime, curDate) then
		return true
	end
	return false
end
