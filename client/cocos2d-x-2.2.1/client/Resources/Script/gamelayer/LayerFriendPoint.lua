----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-03
-- Brief:	友情点奖励界面
----------------------------------------------------------------------

local mLayerFriendPointRoot = nil
local mItems = {}						--保存当前显示的物品
local m_bRefresh = false				-- 刷新列表
local mAllMovePositon = {}				--保存物品移动的所有坐标的位置
local mRounds = 5						--转圈的个数

LayerFriendPoint = {}
LayerAbstract:extend(LayerFriendPoint)

----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json",typeName)
	end
end
----------------------------------------------------------------------
-- 点击抽取奖励按钮
local function  clickGetRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		widget:setTouchEnabled(false)
		FriendPointLogic.request_get_reward()
	end
end
----------------------------------------------------------------------
-- 点击请求刷新按钮
local function  clickRefreshRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		m_bRefresh = not m_bRefresh
		local light = tolua.cast(mLayerFriendPointRoot:getChildByName("getreward_light"),"UIImageView")
		light:setRotation(214.00)
		widget:setTouchEnabled(false)
		FriendPointLogic.requestRefreshlotteryList()
	end
end
----------------------------------------------------------------------
----设置获取奖励按钮可点击
LayerFriendPoint.setGetRewardBtnTouchEnabled = function()
	if mLayerFriendPointRoot == nil then
		return
	end
	local getRewardBtn = tolua.cast(mLayerFriendPointRoot:getChildByName("getreward"), "UIButton")
	getRewardBtn:setTouchEnabled(true)
end
----------------------------------------------------------------------
-- 设置抽奖按钮可否点击，根据当前的友情点数
local function  setGetRewardBtn()
	if mLayerFriendPointRoot == nil then
		return
	end
	--抽取奖励按钮
	local getRewardBtn = tolua.cast(mLayerFriendPointRoot:getChildByName("getreward"), "UIButton")
	local needPoint = mItems.need_point
	curPoint = ModelPlayer.getFriendPoint()
	if needPoint <= curPoint and  (m_bRefresh == false ) then
		getRewardBtn:loadTextures("firpiont_btn_normal.png","firpiont_btn_normal.png",nil)
		Lewis:spriteShaderEffect(getRewardBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		getRewardBtn:registerEventScript(clickGetRewardBtn)
	elseif needPoint <= curPoint and  (m_bRefresh == true ) then
		getRewardBtn:loadTextures("firpiont_btn_refresh.png","firpiont_btn_refresh.png",nil)
		getRewardBtn:setTouchEnabled(true)
		Lewis:spriteShaderEffect(getRewardBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		getRewardBtn:registerEventScript(clickRefreshRewardBtn)
	else
		Lewis:spriteShaderEffect(getRewardBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		getRewardBtn:setTouchEnabled(false)
	end
end
----------------------------------------------------------------------
-- 根据转的圈数，设置位置坐标(rounds只支持整数)
local function setItemPositionByRounds(rounds)
	mAllMovePositon = {}
	rounds = rounds * 8			--所有位置的个数是
	for i = 1, rounds, 1 do
		local index
		if i%8 == 0 then
			index = 8
		else
			index = i % 8
		end
		table.insert(mAllMovePositon,FriendPoint_ItemPosition[index])
	end	
end
----------------------------------------------------------------------
-- 根据移动的图片所在的位置，设置他的上下左右四个图标是否显示
local function setFourStatesByIndex(index)
	if nil == mLayerFriendPointRoot then
		return
	end
	local MovePanel = tolua.cast(mLayerFriendPointRoot:getChildByName("Panel_400"),"UILayout")
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
	if nil == mLayerFriendPointRoot then
		return
	end
	local light = tolua.cast(mLayerFriendPointRoot:getChildByName("getreward_light"),"UIImageView")
	light:stopAllActions()
	light:setRotation(214.00)
	local action = CCRotateBy:create(1,360/(8.0))
	light:runAction(CCRepeatForever:create(action))
end
----------------------------------------------------------------------
-- 抽奖时，转动的图标
LayerFriendPoint.imageMove = function(idTb,amountTb)
	if nil == mLayerFriendPointRoot then
		return
	end
	local MovePanel = tolua.cast(mLayerFriendPointRoot:getChildByName("Panel_400"),"UILayout")	
	local light = tolua.cast(mLayerFriendPointRoot:getChildByName("getreward_light"),"UIImageView")
	light:setRotation(214.00)
	local curTb = FriendPointLogic.get_reward_Tb()
	local keyPosition = 8
	
	--根据获得物品的id，判断该id在那个位置
	for key,value in pairs(FriendPointLogic.getRefreshRewardId()) do
		if curTb.id == value.id and curTb.amount == value.amount then
			keyPosition = key
		end
	end	
	
	light:stopAllActions()
	
	local arr = CCArray:create()
	local arr1 = CCArray:create()
	for key,value in pairs(mAllMovePositon) do
		local ora = 0 
		if key < (keyPosition + 8*(mRounds - 1)) then
			local action1 
			local action2
			local action3
			local action4
			
			local function setVYON ()
				setFourStatesByIndex( key + 1)
			end
			local action5 = CCCallFuncN:create(setVYON)
			
			local internal = 0.05
			if key <= (mRounds - 2)* 8 then
				action1 = CCDelayTime:create(internal)
				local temp = ccp(mAllMovePositon[key +1].x,mAllMovePositon[key +1].y)
				action2 = CCPlace:create(temp)
				action3 = CCRotateBy:create(internal,360/(8.0))
			elseif key >(mRounds - 2)* 8 and key <= (mRounds - 1)*8 then
				action1 = CCDelayTime:create(internal + 0.1)
				local temp = ccp(mAllMovePositon[key +1].x,mAllMovePositon[key +1].y)
				action2 = CCPlace:create(temp)
				
				action3 = CCRotateBy:create(internal + 0.1 ,360/(8.0))
			elseif key >= #mAllMovePositon then
				action1 = CCDelayTime:create(internal + 0.3)
				action2 = CCPlace:create(ccp(mAllMovePositon[1].x,mAllMovePositon[1].y))
				action3 = CCRotateBy:create(internal + 0.3,360/(8.0))
			else
				action1 = CCDelayTime:create(internal + 0.3)
				local temp = ccp(mAllMovePositon[key +1].x,mAllMovePositon[key +1].y)
				action2 = CCPlace:create(temp)
				action3 = CCRotateBy:create(internal + 0.3,360/(8.0))
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
		CommonFunc_showItemGetInfo(idTb, amountTb)
		setGetRewardBtn()
		loadSlowAction()
	end
	local  showAction = CCCallFuncN:create(getRewards)
	arr:addObject(showAction)
	
	MovePanel:runAction(CCSequence:create(arr))	
	light:runAction(CCSequence:create(arr1))		
end
------------------------------------------------------------------
-- 展示奖励的物品
local function iconClick(sender)
	CommonFunc_showInfo(0,sender:getTag(), 0)
end
------------------------------------------------------------------
-- 展示奖励的物品
local function  showItemIcons()
	
	if mLayerFriendPointRoot == nil then
		return
	end
	
	for key,value in pairs(FriendPointLogic.getRefreshRewardId()) do
		local tempTb = LogicTable.getRewardItemRow(value.id)
		local icon = mLayerFriendPointRoot:getChildByName(string.format("icon_%d",key))
		icon:removeAllChildren()
		icon:setTag(tonumber(value.id))
		LayerFightReward_AddGirdWidget(tempTb.icon,value.amount,nil,icon)
		
		--长按功能
		local function clickSkillIcon(icon)
			showLongInfoByRewardId(value.id,icon)
		end
		
		local function clickSkillIconEnd(icon)
			longClickCallback_reward(value.id,icon)
		end
		UIManager.registerEvent(icon, iconClick, clickSkillIcon, clickSkillIconEnd)
		icon:setTouchEnabled(true)
		
	end
	setItemPositionByRounds(mRounds)
	
	local movePanel =  tolua.cast(mLayerFriendPointRoot:getChildByName("Panel_400"),"UILayout")
	local tempCCp = ccp(FriendPoint_ItemPosition[1].x,FriendPoint_ItemPosition[1].y)
	movePanel:setPosition(tempCCp)
	setFourStatesByIndex(1)
end
----------------------------------------------------------------------
-- 更新友情点进度条的数值（根据抽奖的次数）
local function  updateLoadingBar(getTimes)
	if mLayerFriendPointRoot == nil then
		return
	end
	
	local  percent = ModelPlayer.getFriendPoint()* 100 / tonumber(mItems.need_point)
	if percent >= 100 then
		percent = 100
	end
	local friendPointImage = mLayerFriendPointRoot:getChildByName("friendPointBar")
	tolua.cast(friendPointImage,"UIImageView")
	friendPointImage:setAnchorPoint(ccp(0,0.5))
	friendPointImage:setPosition(ccp(-201,-283))
	friendPointImage:setScaleX(0.0)

	local scaleAction = CCScaleTo:create(0, percent/100, 1.0)
	friendPointImage:runAction(CCEaseSineIn:create(scaleAction))

	local friendPointLbl = mLayerFriendPointRoot:getChildByName("friendPointLbl")
	tolua.cast(friendPointLbl,"UILabel")
	friendPointLbl:setText(string.format("%d/%s",ModelPlayer.getFriendPoint(),mItems.need_point))		
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
	updateLoadingBar(AssistanceLogic.getLotteryTimes() + 1)	
	showItemIcons()	
end
----------------------------------------------------------------------
-- 刷新成功后，刷新按钮与物品
local function  refreshUIAfterRewardSuccess()
	refreshBtnAndLoading()
	setGetRewardBtn()
	--loadSlowAction()
end
----------------------------------------------------------------------
-- 初始化
LayerFriendPoint.init = function(rootView)
	
	mLayerFriendPointRoot = rootView
	
	--关闭按钮
	local closeBtn = tolua.cast(mLayerFriendPointRoot:getChildByName("close_btn"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	
	if #FriendPointLogic.getRefreshRewardId() ~= 0 then
		refreshUIAfterRewardSuccess()
	else
		FriendPointLogic.requestRefreshlotteryList() 		--请求刷新列表
	end
	loadSlowAction()
	-- 游戏事件注册-- 领取友情点奖励
	EventCenter_subscribe(EventDef["ED_FRIEND_POINT_GET"], refreshUIAfterRewardSuccess) 	
	-- 到了新的一天刷新友情点
	EventCenter_subscribe(EventDef["ED_FRIEND_POINT_TIME_OVER"], refreshUIAfterRewardSuccess)
	-- 刷新友情点奖励列表
	EventCenter_subscribe(EventDef["ED_FRIEND_POINT_REFRESH"], refreshUIAfterRewardSuccess)
	TipModule.onUI(rootView, "ui_friendpoint")
end
----------------------------------------------------------------------
-- 销毁
LayerFriendPoint.destroy = function()	
	mLayerFriendPointRoot = nil
end
----------------------------------------------------------------------
