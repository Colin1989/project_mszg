----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-10-27
-- Brief:	技能解锁界面
----------------------------------------------------------------------
LayerPowerHp = {}
LayerAbstract:extend(LayerPowerHp)
local mRootNode = nil
local mRewardList = {}
local mTimerList = {}
local mRewardId = 0
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_PowerPh")
    end
end
----------------------------------------------------------------------
-- 点击领取按钮
local function clickGetBtn(typeName, widget)
	if "releaseUp" == typeName then
		mRewardId = widget:getTag()
		TimeLimitRewardLogic.requestTimeLimitReward(mRewardId)
    end
end
----------------------------------------------------------------------
-- 刷新界面
local function refreshUI(rootNode)
	if nil == rootNode then
		return
	end
	for i=1, 2 do
		local status, row = TimeLimitRewardLogic.rewardInfo(i)
		local startTimeStr = row.start_time[1][1]..":"..row.start_time[1][2]..row.start_time[1][3]
		local endTimeStr = row.end_time[1][1]..":"..row.end_time[1][2]..row.end_time[1][3]
		local rewardItemRow = LogicTable.getRewardItemRow(row.ids[1])
		-- 领取按钮
		local getImage = tolua.cast(rootNode:getChildByName("ImageView_get"..i), "UIImageView")
		local getBtn = tolua.cast(rootNode:getChildByName("Button_get"..i), "UIButton")
		getBtn:setTag(i)
		getBtn:registerEventScript(clickGetBtn)
		-- 时间未到
		local timeLabel = tolua.cast(rootNode:getChildByName("Label_time"..i), "UILabel")
		-- 说明
		local describeLabel = tolua.cast(rootNode:getChildByName("Label_desc"..i), "UILabel")
		describeLabel:setText(GameString.get("POWER_PH_STR_01", startTimeStr, endTimeStr, row.amounts))
		-- 图标
		local iconImage = tolua.cast(rootNode:getChildByName("ImageView_icon"..i), "UIImageView")
		iconImage:loadTexture(rewardItemRow.icon)
		FightOver_addQuaIconByRewardId(rewardItemRow.id, iconImage, row.amounts, nil)
		--
		if 1 == status or 2 == status then	-- 可领取
			timeLabel:setVisible(false)
			getBtn:setVisible(true)
			getBtn:setTouchEnabled(true)
			getBtn:loadTextureNormal("public_newbuttom.png")
			getBtn:loadTexturePressed("public_newbuttom.png")
			getImage:loadTexture("text_lingqu.png")
			getImage:setVisible(true)
		elseif 3 == status then				-- 不可领取
			timeLabel:setVisible(false)
			getBtn:setVisible(true)
			getBtn:setTouchEnabled(false)
			getBtn:loadTextureNormal("tili_button_receive.png")
			getBtn:loadTexturePressed("tili_button_receive.png")
			getImage:setVisible(false)
		elseif 4 == status then				-- 时间未到
			timeLabel:setVisible(true)
			getBtn:setVisible(false)
			getBtn:setTouchEnabled(false)
		end
	end
end
----------------------------------------------------------------------
-- 初始化
LayerPowerHp.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_PowerPh")
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	mRootNode = framePanel
	-- 关闭按钮
	local closeBtn = tolua.cast(framePanel:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 数据
	local function timerCB(tm)
		refreshUI(framePanel)
	end
	mRewardList = {}
	mTimerList = {}
	for i=1, 2 do
		local row = LogicTable.getTimeLimitRewardRow(i)
		table.insert(mRewardList, row)
		table.insert(mTimerList, SystemTime.createDailyTimer(row.start_time[1][1], row.start_time[1][2], row.start_time[1][3], timerCB))
		table.insert(mTimerList, SystemTime.createDailyTimer(row.end_time[1][1], row.end_time[1][2], row.end_time[1][3], timerCB))
	end
	-- 刷新界面
	refreshUI(framePanel)
end
----------------------------------------------------------------------
-- 销毁
LayerPowerHp.destroy = function()
	mRootNode = nil
	mRewardList = {}
	for key, val in pairs(mTimerList) do
		val.stop()
	end
	mTimerList = {}
end
----------------------------------------------------------------------
-- 有奖励可领取
LayerPowerHp.existAward = function()
	for i=1, 2 do
		local status, _ = TimeLimitRewardLogic.rewardInfo(i)
		if 1 == status or 2 == status then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 领取限时奖励
local function handleTimeLimitRewardGet(data)
	if nil == mRootNode or false == data.success then
		return
	end
	local row = LogicTable.getTimeLimitRewardRow(mRewardId)
	Toast.show(GameString.get("POWER_PH_STR_02", row.amounts))
	refreshUI(mRootNode)
	LayerActivity.refreshTip()
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_TIME_LIMIT_REWARD_GET"], handleTimeLimitRewardGet)
