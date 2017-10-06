----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-27
-- Brief:	活动界面
----------------------------------------------------------------------
local mActivitySwitchDatas = nil
local mScrollView = nil

LayerActivity = {}
LayerAbstract:extend(LayerActivity)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		LayerMain.pullPannel(LayerActivity)
	end
end
----------------------------------------------------------------------
-- 点击活动图标
local function clickActivitySwitchIcon(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		local activityType = widget:getTag()
		if 0 == activityType then			-- 0.等待开启
			Toast.Textstrokeshow(GameString.get("ACTIVITY_STR_01"), ccc3(255,255,255), ccc3(0,0,0), 30)
		elseif 1 == activityType then		-- 1.每日奖励
			setConententPannelJosn(LayerDailyAward, "DailyAward.json", widgetName)
		elseif 2 == activityType then		-- 2.每日活跃
			setConententPannelJosn(LayerDailyCrazy, "DailyCrazyPanel.json", widgetName)
		elseif 3 == activityType then		-- 3.首充奖励
			setConententPannelJosn(LayerFirstRecharge, "FirstRecharge.json", widgetName)
		elseif 4 == activityType then		-- 4.冲级活动
			setConententPannelJosn(LayerLevelGift, "levelGift.json", widgetName)
		elseif 5 == activityType then		-- 5.领取体力
			UIManager.push("UI_PowerPh")
		elseif 6 == activityType then		-- 6.充值返利
			setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
		elseif 7 == activityType then		-- 7.炼金术
			setConententPannelJosn(LayerGetCoin, "Activity_4.json", widgetName)
		elseif 8 == activityType then		-- 8.在线奖励
			setConententPannelJosn(LayerOnlineReward, "OnlineReward.json", widgetName)
		elseif 9 == activityType then		-- 9.打折限购
			setConententPannelJosn(LayerDiscountRestriction, "DisRes.json", widgetName)
		elseif 10 == activityType then		-- 10.魔塔
			if CopyDateCache.getCopyStatus(LIMIT_TOWER.copy_id) ~= "pass" and tonumber(LIMIT_TOWER.copy_id) ~= 1 then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TOWER.copy_id),LIMIT_TOWER.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
            setConententPannelJosn(LayerTowerbg,"PowerCopyBg.json","PowerCopyBg.json")
		elseif 11 == activityType then		-- 11.BOSS挑战
			if CopyDateCache.getCopyStatus(LIMIT_ENTER_BOSS.copy_id) ~= "pass" and tonumber(LIMIT_ENTER_BOSS.copy_id) ~= 1 then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ENTER_BOSS.copy_id),LIMIT_ENTER_BOSS.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
            setConententPannelJosn(LayerChenallBoss,LayerChenallBoss.josnFile,LayerChenallBoss.josnFile)
		elseif 12 == activityType then		-- 12.空虚之门
			if CopyDateCache.getCopyStatus(LIMIT_ACTIVITY_COPY.copy_id) ~= "pass" and tonumber(LIMIT_ACTIVITY_COPY.copy_id) ~= 1 then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ACTIVITY_COPY.copy_id),LIMIT_ACTIVITY_COPY.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
			setConententPannelJosn(LayerActivityCopyGroup, "ActivityCopyGroup.json", widgetName)
		end
	end
end
----------------------------------------------------------------------
-- 显示活动开关角标
local function showActivitySwitchTip(node, activityType)
	local tipIcon = node:getChildByName("tip_icon_"..activityType)
	if nil == tipIcon then
		tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setName("tip_icon_"..activityType)
		tipIcon:setPosition(ccp(71, 68))
		node:addChild(tipIcon)
	end
	local showFlag = false
	if 0 == activityType then			-- 0.等待开启
		showFlag = false
	elseif 1 == activityType then		-- 1.签到奖励
		showFlag = DailyAwardLogic.existAward()
	elseif 2 == activityType then		-- 2.每日活跃
		showFlag = DailyActivenessLogic.existAward()
	elseif 3 == activityType then		-- 3.首充奖励
		showFlag = FirstRechargeLogic.existAward()
	elseif 4 == activityType then		-- 4.冲级活动
		showFlag = LevelGiftLogic.existAward()
	elseif 5 == activityType then		-- 5.领取体力
		showFlag = LayerPowerHp.existAward()
	elseif 6 == activityType then		-- 6.充值返利
		showFlag = FirstRechargeLogic.existAward()
	elseif 7 == activityType then		-- 7.炼金术
		showFlag = GetCoinLogic.existAward()
	elseif 8 == activityType then		-- 8.在线奖励
		showFlag = OnlineRewardLogic.existAward()
	elseif 9 == activityType then		-- 9.打折限购
		showFlag = DisResLogic.existAward()
	elseif 10 == activityType then		-- 10.魔塔
        showFlag = LayerTowerbg.existAward()
	elseif 11 == activityType then		-- 11.BOSS挑战
        showFlag = LayerChenallBoss.existAward()
	elseif 12 == activityType then		-- 12.空虚之门
	end
	tipIcon:setVisible(showFlag)
end
----------------------------------------------------------------------
-- 创建活动开关
local function createActivitySwitchCell(cell, activitySwitchRow, index)
	local activityType = activitySwitchRow.type
	-- 创建根节点
	local node = CommonFunc_getImgView("activity_iconbg.png")
	node:setTouchEnabled(true)
	node:registerEventScript(clickActivitySwitchIcon)
	node:setName("activity_switch_bg_"..activityType)
	node:setTag(activityType)
	-- 图标
	local iconImageView = CommonFunc_getImgView(activitySwitchRow.icon)
	node:addChild(iconImageView)
	-- 显示角标
	showActivitySwitchTip(node, activityType)
	return node
end
----------------------------------------------------------------------
-- 检查活动是否有效
local function checkActivityValid(activitySwitchRow)
	-- 开始时间
	local sYear = activitySwitchRow.start_date.year
	local sMonth = activitySwitchRow.start_date.month
	local sDay = activitySwitchRow.start_date.day
	local sHour = activitySwitchRow.start_date.hour
	local sMinute = activitySwitchRow.start_date.minute
	local sSeconds = activitySwitchRow.start_date.seconds
	local startTime = os.time{year=sYear, month=sMonth, day=sDay, hour=sHour, min=sMinute, sec=sSeconds}
	-- 结束时间
	local eYear = activitySwitchRow.end_date.year
	local eMonth = activitySwitchRow.end_date.month
	local eDay = activitySwitchRow.end_date.day
	local eHour = activitySwitchRow.end_date.hour
	local eMinute = activitySwitchRow.end_date.minute
	local eSeconds = activitySwitchRow.end_date.seconds
	local endTime = os.time{year=eYear, month=eMonth, day=eDay, hour=eHour, min=eMinute, sec=eSeconds}
	-- 当前时间
	local curTime = SystemTime.getServerTime()
	if startTime or endTime then
		if (startTime and curTime < startTime) or (endTime and curTime > endTime) then
			return false
		end
	end
	return true
end
----------------------------------------------------------------------
-- 初始化
LayerActivity.init = function(rootView)
	if nil == mActivitySwitchDatas then
		mActivitySwitchDatas = LogicTable.getActivitySwitchTable()
	end
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("close_btn"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 活动列表
	local dataTable = {}
	for key, val in pairs(mActivitySwitchDatas) do
		if true == checkActivityValid(val) then
			table.insert(dataTable, val)
		end
	end
	mScrollView = tolua.cast(rootView:getChildByName("scroll_list"), "UIScrollView")
	UIScrollViewEx.show(mScrollView, dataTable, createActivitySwitchCell, "V", 150, 143, 20, 3, 4, true, nil, false, true)
	TipModule.onUI(mScrollView, "ui_activity")
end
----------------------------------------------------------------------
-- 销毁
LayerActivity.destroy = function()
	mScrollView = nil
end
----------------------------------------------------------------------
-- 刷新角标
LayerActivity.refreshTip = function()
	if nil == mScrollView then
		return
	end
	for key, val in pairs(mActivitySwitchDatas) do
		if true == checkActivityValid(val) then
			local node = tolua.cast(mScrollView:getChildByName("activity_switch_bg_"..val.type), "UIImageView")
			showActivitySwitchTip(node, val.type)
		end
	end
end
----------------------------------------------------------------------

