--region LayerSpringDraw.lua
--Author : songcy
--Date   : 2015/01/22

LayerSpringDraw = {}
LayerAbstract:extend(LayerSpringDraw)

local mRootView = nil

local mActLotteryInfo = nil			-- 记录抽奖总信息
local mRewardId = nil					-- 记录获奖ID
local mItems = {}						-- 保存当前显示的物品
local m_bRefresh = false				-- 刷新列表
local mAllMovePositon = {}				-- 保存物品移动的所有坐标的位置
local mRounds = 5						-- 转圈的个数

local startTime = nil					-- 开始时间
local endTime = nil					-- 结束时间

local whiteColor = ccc3(255,255,255)	-- 白色
local anchorPoint = ccp(0,0.5)

-- 活动项目坐标
local progressPosition = {
	[1] = ccp(-227, 43),
	[2] = ccp(-227, 22),
	[3] = ccp(-227, 1),
	[4] = ccp(-227, -20),
	[5] = ccp(-227, -41),
	[6] = ccp(41, 43),
	[7] = ccp(41, 22),
	[8] = ccp(41, 1),
	[9] = ccp(41, -20),
	[10] = ccp(41, -41),
	
}
----------------------------------------------------------------------
-- 点击抽取奖励按钮
local function clickGetRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		local actJudge = false
		for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
			if key == 1 then
				actJudge = SpringActivityLogic.isTimeValidById(value.id)
			end
		end
		if actJudge == false then
			Toast.show( GameString.get("SPRING_ACTIVITY_TIP_4"))
			return
		end
		TipModule.onClick(widget)
		widget:setBright(false)
		widget:setTouchEnabled(false)
		SpringActivityLogic.reqGetReward()
	end
end
----------------------------------------------------------------------
-- 点击请求刷新按钮
local function clickRefreshRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		m_bRefresh = not m_bRefresh
		local light = tolua.cast(mRootView:getChildByName("getreward_light"),"UIImageView")
		light:setRotation(214.00)
		widget:setTouchEnabled(false)
		FriendPointLogic.requestRefreshlotteryList()
	end
end
----------------------------------------------------------------------
----设置获取奖励按钮可点击
LayerSpringDraw.setGetRewardBtnTouchEnabled = function()
	if mRootView == nil then
		return
	end
	local getRewardBtn = tolua.cast(mRootView:getChildByName("getreward"), "UIButton")
	getRewardBtn:setBright(true)
	getRewardBtn:setTouchEnabled(true)
end
----------------------------------------------------------------------
-- 设置抽奖按钮可否点击，根据当前的友情点数
local function setGetRewardBtn()
	if mRootView == nil then
		return
	end
	
	-- 当前可抽奖次数
	-- local labelRemainCount = tolua.cast(mRootView:getChildByName("remain_count"), "UILabel")
	-- labelRemainCount:setText()
	
	--抽取奖励按钮
	local getRewardBtn = tolua.cast(mRootView:getChildByName("getreward"), "UIButton")
	getRewardBtn:registerEventScript(clickGetRewardBtn)
	local remainCount = mActLotteryInfo.remain_count
	if tonumber(remainCount) > 0 then
		getRewardBtn:setBright(true)
		getRewardBtn:setTouchEnabled(true)
	else
		getRewardBtn:setBright(false)
		getRewardBtn:setTouchEnabled(false)
	end
end

----------------------------------------------------------------------
-- 根据转的圈数，设置位置坐标(rounds只支持整数)
local function setItemPositionByRounds(rounds)
	mAllMovePositon = {}
	rounds = rounds * 12			--所有位置的个数是
	for i = 1, rounds, 1 do
		local index
		if i%12 == 0 then
			index = 12
		else
			index = i % 12
		end
		table.insert(mAllMovePositon,ActivityRecharge_ItemPosition[index])
	end	
end

----------------------------------------------------------------------
-- 根据移动的图片所在的位置，设置他的上下左右四个图标是否显示
local function setFourStatesByIndex(index)
	if nil == mRootView then
		return
	end
	local MovePanel = tolua.cast(mRootView:getChildByName("Panel_400"),"UILayout")
	local up = tolua.cast(MovePanel:getChildByName("up"),"UIImageView")
	local down = tolua.cast(MovePanel:getChildByName("down"),"UIImageView")
	local left = tolua.cast(MovePanel:getChildByName("left"),"UIImageView")
	local right = tolua.cast(MovePanel:getChildByName("right"),"UIImageView")
	if index % 8 == 1 then  					  -- 右下显示
		up:setVisible(false)
		down:setVisible(true)
		left:setVisible(false)
		right:setVisible(true)
	elseif index % 8 == 3 then					  -- 左下显示 
		up:setVisible(false)
		down:setVisible(true)
		left:setVisible(true)
		right:setVisible(false)
	elseif index % 8 == 5 then		  			  -- 左上显示
		up:setVisible(true)
		down:setVisible(false)
		left:setVisible(true)
		right:setVisible(false)
	elseif index % 8 == 7 then		   			  -- 右上显示
		up:setVisible(true)
		down:setVisible(false)
		left:setVisible(false)
		right:setVisible(true)
	elseif index % 8 == 2 or index % 8 == 6 then  -- 左右显示
		up:setVisible(false)
		down:setVisible(false)
		left:setVisible(true)
		right:setVisible(true)
	else										  -- 上下显示
		up:setVisible(true)
		down:setVisible(true)
		left:setVisible(false)
		right:setVisible(false)
	end
end
----------------------------------------------------------------------
--刚进入时，让蓝光缓慢的转动
local function loadSlowAction()
	if nil == mRootView then
		return
	end
	local light = tolua.cast(mRootView:getChildByName("getreward_light"),"UIImageView")
	light:stopAllActions()
	light:setRotation(214.00)
	local action = CCRotateBy:create(1,360/(8.0))
	light:runAction(CCRepeatForever:create(action))
end

----------------------------------------------------------------------
-- 抽奖时，转动的图标
LayerSpringDraw.imageMove = function()
	if nil == mRootView then
		return
	end
	local moveLight = tolua.cast(mRootView:getChildByName("moveImage"),"UIImageView")
	local light = tolua.cast(mRootView:getChildByName("getreward_light"),"UIImageView")
	light:setRotation(214.00)
	local curTb = SpringActivityLogic.getActivityLotteryRechargeById(mRewardId)
	local keyPosition = 12
	
	--根据获得物品的id，判断该id在那个位置
	for key,value in pairs(SpringActivityLogic.getAllActivityLotteryRecharge()) do
		if curTb.id == value.id then
			keyPosition = key
		end
	end	
	
	light:stopAllActions()
	
	local arr = CCArray:create()
	local arr1 = CCArray:create()
	for key,value in pairs(mAllMovePositon) do
		local ora = 0 
		if key < (keyPosition + 12*(mRounds - 1)) then
			local action1 
			local action2
			local action3
			local action4
			
			local function setVYON ()
				-- setFourStatesByIndex( key + 1)
			end
			local action5 = CCCallFuncN:create(setVYON)
			
			local internal = 0.05
			if key <= (mRounds - 2)* 12 then
				action1 = CCDelayTime:create(internal)
				local temp = ccp(mAllMovePositon[key +1].x,mAllMovePositon[key +1].y)
				action2 = CCPlace:create(temp)
				action3 = CCRotateBy:create(internal,360/(12.0))
			elseif key >(mRounds - 2)* 12 and key <= (mRounds - 1)*12 then
				action1 = CCDelayTime:create(internal + 0.1)
				local temp = ccp(mAllMovePositon[key +1].x,mAllMovePositon[key +1].y)
				action2 = CCPlace:create(temp)
				
				action3 = CCRotateBy:create(internal + 0.1 ,360/(12.0))
			elseif key >= #mAllMovePositon then
				action1 = CCDelayTime:create(internal + 0.3)
				action2 = CCPlace:create(ccp(mAllMovePositon[1].x,mAllMovePositon[1].y))
				action3 = CCRotateBy:create(internal + 0.3,360/(12.0))
			else
				action1 = CCDelayTime:create(internal + 0.3)
				local temp = ccp(mAllMovePositon[key +1].x,mAllMovePositon[key +1].y)
				action2 = CCPlace:create(temp)
				action3 = CCRotateBy:create(internal + 0.3,360/(12.0))
			end	
			action4 = CCSpawn:createWithTwoActions(action2,action5)
			
			arr:addObject(action1)
			arr:addObject(action4)	
			--arr1:addObject(action)
			arr1:addObject(action3)
		end
	end
	
	local function getRewards()
		m_bRefresh = not m_bRefresh
		local idTb = {curTb.ids}
		local amountTb = {curTb.amounts}
		CommonFunc_showItemGetInfo(idTb, amountTb)
		setGetRewardBtn()
		loadSlowAction()
		if UIManager.popBounceWindow("UI_TempPack") ~= true then
			LayerLvUp.setEnterLvMode(2)
			UIManager.popBounceWindow("UI_LvUp")
		end
	end
	local  showAction = CCCallFuncN:create(getRewards)
	arr:addObject(showAction)
	
	local getRewardBtn = tolua.cast(mRootView:getChildByName("getreward"), "UIButton")
	getRewardBtn:setBright(false)
	getRewardBtn:setTouchEnabled(false)
	
	moveLight:runAction(CCSequence:create(arr))	
	light:runAction(CCSequence:create(arr1))		
end

------------------------------------------------------------------
-- 展示奖励的物品
local function iconClick(sender)
	CommonFunc_showInfo(0,sender:getTag(), 0)
end

------------------------------------------------------------------
-- 展示奖励的物品
local function showItemIcons()
	if mRootView == nil then
		return
	end
	
	for key,value in pairs(SpringActivityLogic.getAllActivityLotteryRecharge()) do
		local tempTb = LogicTable.getRewardItemRow(value.ids)
		local icon = mRootView:getChildByName(string.format("icon_%d",key))
		icon:removeAllChildren()
		icon:setTag(tonumber(value.ids))
		LayerFightReward_AddGirdWidget(tempTb.icon,value.amounts,nil,icon)
		
		--长按功能
		local function clickSkillIcon(icon)
			showLongInfoByRewardId(value.ids,icon)
		end
		
		local function clickSkillIconEnd(icon)
			longClickCallback_reward(value.ids,icon)
		end
		UIManager.registerEvent(icon, iconClick, clickSkillIcon, clickSkillIconEnd)
		icon:setTouchEnabled(true)
		
	end
	setItemPositionByRounds(mRounds)
	
	-- local movePanel =  tolua.cast(mRootView:getChildByName("Panel_400"),"UILayout")
	local moveLight = tolua.cast(mRootView:getChildByName("moveImage"),"UIImageView")
	local tempCCp = ccp(ActivityRecharge_ItemPosition[1].x,ActivityRecharge_ItemPosition[1].y)
	moveLight:setPosition(tempCCp)
	-- setFourStatesByIndex(1)
end

----------------------------------------------------------------------
-- 更新友情点进度条的数值（根据抽奖的次数）
-- local function  updateLoadingBar(getTimes)
	-- if mRootView == nil then
		-- return
	-- end
	
	-- local  percent = ModelPlayer.getFriendPoint()* 100 / tonumber(mItems.need_point)
	-- if percent >= 100 then
		-- percent = 100
	-- end
	-- local friendPointImage = mRootView:getChildByName("friendPointBar")
	-- tolua.cast(friendPointImage,"UIImageView")
	-- friendPointImage:setAnchorPoint(ccp(0,0.5))
	-- friendPointImage:setPosition(ccp(-201,-283))
	-- friendPointImage:setScaleX(0.0)

	-- local scaleAction = CCScaleTo:create(0, percent/100, 1.0)
	-- friendPointImage:runAction(CCEaseSineIn:create(scaleAction))

	-- local friendPointLbl = mRootView:getChildByName("friendPointLbl")
	-- tolua.cast(friendPointLbl,"UILabel")
	-- friendPointLbl:setText(string.format("%d/%s",ModelPlayer.getFriendPoint(),mItems.need_point))		
-- end
-- 生成活动项目
local function createProgressUI(data, curCount, pos)
	if data == nil then
		local panel = UILayout:create()
		return panel
	end
	local labelDescribe = CommonFunc_createUILabel(anchorPoint, pos, nil, 17, whiteColor, data.name, data.id, 1)
	local labelCurCount = CommonFunc_createUILabel(anchorPoint, ccp(150, 0), nil, 17, whiteColor, GameString.get("SPRING_ACTIVITY_TIP_1",curCount), data.id, 1)
	if data.repeat_type == 0 or data.need_times == 1 then
		labelCurCount:setVisible(false)
	end
	labelDescribe:addChild(labelCurCount)
	
	return labelDescribe
end


----------------------------------------------------------------------
-- 刷新活动进展
local function refreshProgressUI()
	if mRootView == nil then
		return
	end
	
	local progressNode = mRootView:getChildByName("ImageView_88")
	progressNode:removeAllChildren()
	
	local mProgressList = mActLotteryInfo.progress_list
	local mRemainCount = mActLotteryInfo.remain_count
	for key,value in pairs(mProgressList) do
		local data = SpringActivityLogic.getActivityLotteryById(value.id)
		local progressUI = createProgressUI(data, value.cur_count, progressPosition[key])
		progressNode:addChild(progressUI)
	end
	
	-- 活动截止时间
	if endTime ~= nil then
		local labelTime = tolua.cast(mRootView:getChildByName("Label_date"), "UILabel")
		labelTime:setText(GameString.get("SPRING_ACTIVITY_TIP_2",endTime[1][1], endTime[1][2], endTime[1][3]))
	end
	
	-- 当前可抽奖次数
	local labelRemainCount = tolua.cast(mRootView:getChildByName("remain_count"), "UILabel")
	labelRemainCount:setText(mRemainCount)
end

---------------------------------------------------------------------
-- 抽奖成功后，刷新按钮与loadingBar
local function refreshBtnAndLoading()
	if AssistanceLogic.getLotteryTimes() >= #LogicTable.getFriendPointInfo() then
		curId = #LogicTable.getFriendPointInfo()
	else	
		curId = AssistanceLogic.getLotteryTimes() + 1
	end
	mItems = LogicTable.getFriendPointInfoById(curId)
	-- updateLoadingBar(AssistanceLogic.getLotteryTimes() + 1)	
	showItemIcons()	
end

----------------------------------------------------------------------
-- 刷新成功后，刷新按钮与物品
local function refreshUI()
	-- refreshBtnAndLoading()
	refreshProgressUI()		-- 刷新 展示 活动清单
	setGetRewardBtn()		-- 刷新 展示 按键
	loadSlowAction()
end
EventCenter_subscribe(EventDef["ED_SPRING_PROGRESS"], refreshUI)


-----------------------------------------初始化---------------------------
LayerSpringDraw.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		return
	end
	-- createActivityList()
	-- if activityCache == nil then
		-- local tb = req_notice_list()
		-- NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_list"])
	-- else
		-- createActivityList()
	-- end
	
	-- if #SpringActivityLogic.getAllActivityLotteryRecharge ~= 0 then
		-- refreshUIAfterRewardSuccess()
	-- else
		-- FriendPointLogic.requestRefreshlotteryList() 		--请求刷新列表
	-- end
	-- refreshProgressUI(mActLotteryInfo)		-- 展示活动清单
	refreshUI()
	showItemIcons()							-- 展示奖励Icon
	-- loadSlowAction()
	
	-- local getRewardBtn = tolua.cast(mRootView:getChildByName("getreward"), "UIButton")
	-- getRewardBtn:setBright(false)
	
	-- 游戏事件注册-- 领取友情点奖励
	-- EventCenter_subscribe(EventDef["ED_FRIEND_POINT_GET"], refreshUIAfterRewardSuccess) 	
	-- 到了新的一天刷新友情点
	-- EventCenter_subscribe(EventDef["ED_FRIEND_POINT_TIME_OVER"], refreshUIAfterRewardSuccess)
	-- 刷新友情点奖励列表
	-- EventCenter_subscribe(EventDef["ED_FRIEND_POINT_REFRESH"], refreshUIAfterRewardSuccess)
	-- TipModule.onUI(rootView, "ui_friendpoint")
end

-------------------------------------------销毁---------------------------
LayerSpringDraw.setRootNil = function()
	mRootView = nil
end

-- 记录 更新 抽奖信息
LayerSpringDraw.setLotteryInfo = function(bundle)
	mActLotteryInfo = bundle
end

-- 记录 获奖ID
LayerSpringDraw.setRewardId = function(id)
	mRewardId = id
end

LayerSpringDraw.setTime = function(st, et)
	startTime = st
	endTime = et
end