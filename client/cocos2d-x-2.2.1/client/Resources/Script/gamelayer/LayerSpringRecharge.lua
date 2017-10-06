--region LayerSpringRecharge.lua
--Author : songcy
--Date   : 2015/01/22

LayerSpringRecharge = {}
LayerAbstract:extend(LayerSpringRecharge)

local mRootView = nil

local startTime = nil					-- 活动开始时间
local endTime = nil					-- 活动结束时间

local curRechargeCount = nil			-- 当前已充值数
local rewardedList = nil				-- 已领取奖励表
local againRechargeId = nil			-- 下一个可领取礼包

local whiteColor = ccc3(255,255,255)	-- 白色
local anchorPoint = ccp(0, 1.0)

local function onClickEvent(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local actJudge = false
	for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
		if key == 2 then
			actJudge = SpringActivityLogic.isTimeValidById(value.id)
		end
	end
	if actJudge == false then
		Toast.show( GameString.get("SPRING_ACTIVITY_TIP_4"))
		return
	end
	local tb = req_act_recharge_reward()
	tb.id = widget:getTag()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_act_recharge_reward_result"])
end

local function createCell(cell, data, index)
	local node = CommonFunc_getImgView("public2_bg_07.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(20, 20, 1, 1))
	node:setSize(CCSizeMake(519, 120))
	
	-- 背景
	local bg = CommonFunc_getImgView("public2_bg_05.png")
	bg:setScale9Enabled(true)
	bg:setPosition(ccp(-72, 2))
	bg:setCapInsets(CCRectMake(15, 15, 1, 1))
	bg:setSize(CCSizeMake(360, 101))
	node:addChild(bg)
	
	-- 文字说明
	local str = ""
	for k, v in pairs(data.reward_ids) do
		local temp = LogicTable.getRewardItemRow(v)
		if k == #data.reward_ids then
			str = str..string.format("%s%s", temp.name, data.reward_amounts[k])
		else
			str = str..string.format("%s%s, ", temp.name, data.reward_amounts[k])
		end
	end
	local labelDescribe = CommonFunc_createUILabel(ccp(0,1.0), ccp(-70,32), nil, 20, whiteColor,GameString.get("SPRING_ACTIVITY_TIP_3", str), 1, 1)
	labelDescribe:setTextAreaSize(CCSizeMake(242, 66))
	bg:addChild(labelDescribe)
	
	-- 宝箱
	local imgBox = CommonFunc_getImgView("spring_box.png")
	imgBox:setPosition(ccp(-122, 1))
	bg:addChild(imgBox)
	
	-- 魔石文字图片
	local imgEmoney = CommonFunc_getImgView("spring_text_moshi.png")
	imgEmoney:setPosition(ccp(19, -37))
	imgBox:addChild(imgEmoney)
	
	-- 魔石数量
	local atlasEmoneyCount = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	atlasEmoneyCount:setAnchorPoint(ccp(1.0, 0.5))
	atlasEmoneyCount:setScale(0.5)
	atlasEmoneyCount:setPosition(ccp(1, -37))
	atlasEmoneyCount:setName("emoney_"..data.id)
	atlasEmoneyCount:setStringValue(tostring(data.need_emoney))
	imgBox:addChild(atlasEmoneyCount)
	
	-- 领取奖励
	local btnGetReward = CommonFunc_getButton("onlinereward_buttom_receive3.png", "onlinereward_buttom_receive3.png", "onlinereward_buttom_receive2.png")
	-- btnGetReward:setScale(0.7)
	btnGetReward:setTag(tonumber(data.id))
	btnGetReward:setName("getReward")
	btnGetReward:setPosition(ccp(183, 0))
	node:addChild(btnGetReward)
	
	btnGetReward:setBright(data.canGetReward)
	btnGetReward:setTouchEnabled(data.canGetReward)
	btnGetReward:registerEventScript(onClickEvent)
	
	return node
end

local function createRewardList()
	if mRootView == nil then
		return
	end
	local tbReward = SpringActivityLogic.getAllActivityRecharge()
	local dataTable = {}
	againRechargeId = nil
	for key, val in pairs(tbReward) do
		-- local tbRow = LogicTable.getProductInfoById(val)
		-- if tbRow.client_show == "1" then   -- 显示
			-- table.insert(dataTable, tbRow)
		-- end
		local tbRow = val
		tbRow.canGetReward = true
		
		if val.need_emoney > curRechargeCount then
			tbRow.canGetReward = false
			if againRechargeId == nil then
				againRechargeId = tonumber(val.id)
			end
		end
		
		for k, v in pairs(rewardedList) do
			if tonumber(val.id) == tonumber(v) then
				tbRow.canGetReward = false
				break
			end
		end
		table.insert(dataTable, tbRow)
	end
	local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, dataTable, createCell, "V", 519, 120, 0, 1, 4, true, nil, true, true)
	
	if endTime ~= nil then
		local labelTime = tolua.cast(mRootView:getChildByName("Label_time"), "UILabel")
		labelTime:setText(GameString.get("SPRING_ACTIVITY_TIP_2",endTime[1][1], endTime[1][2], endTime[1][3]))
	end
	
	if againRechargeId == nil then
		local label = tolua.cast(mRootView:getChildByName("Label_73"), "UILabel")
		label:setVisible(false)
	else
		local labelAgain = tolua.cast(mRootView:getChildByName("againRecharge"), "UILabel")
		local temp = SpringActivityLogic.getActivityRechargeById(againRechargeId)
		local againCount = tonumber(temp.need_emoney) - tonumber(curRechargeCount)
		labelAgain:setText(againCount)
		
		local labelDescribe = tolua.cast(mRootView:getChildByName("describe"), "UILabel")
		labelDescribe:setText(temp.describe)
	end
end

-- 刷新 展示 界面
LayerSpringRecharge.refreshUI = function()
	createRewardList()
end
-----------------------------------------初始化---------------------------
LayerSpringRecharge.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		return
	end
	
	-- 创建奖励列表
	LayerSpringRecharge.refreshUI()
	
	-- createActivityList()
	-- if activityCache == nil then
		-- local tb = req_notice_list()
		-- NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_list"])
	-- else
		-- createActivityList()
	-- end
end

-------------------------------------------销毁---------------------------
LayerSpringRecharge.setRootNil = function()
	mRootView = nil
	againRechargeId = nil
end

LayerSpringRecharge.setActRecharge = function(tb)
	rewardedList = tb.rewarded_list
	curRechargeCount = tb.cur_recharge_count
end

LayerSpringRecharge.insertActRecharge = function(id)
	if rewardedList == nil then
		rewardedList = {id}
	else
		table.insert(rewardedList, id)
	end
end

LayerSpringRecharge.setTime = function(st, et)
	startTime = st
	endTime = et
end

-- EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)