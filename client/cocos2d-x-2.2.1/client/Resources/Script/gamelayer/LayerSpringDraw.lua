--region LayerSpringDraw.lua
--Author : songcy
--Date   : 2015/01/22

LayerSpringDraw = {}
LayerAbstract:extend(LayerSpringDraw)

local mRootView = nil

local mActLotteryInfo = nil			-- ��¼�齱����Ϣ
local mRewardId = nil					-- ��¼��ID
local mItems = {}						-- ���浱ǰ��ʾ����Ʒ
local m_bRefresh = false				-- ˢ���б�
local mAllMovePositon = {}				-- ������Ʒ�ƶ������������λ��
local mRounds = 5						-- תȦ�ĸ���

local startTime = nil					-- ��ʼʱ��
local endTime = nil					-- ����ʱ��

local whiteColor = ccc3(255,255,255)	-- ��ɫ
local anchorPoint = ccp(0,0.5)

-- ���Ŀ����
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
-- �����ȡ������ť
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
-- �������ˢ�°�ť
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
----���û�ȡ������ť�ɵ��
LayerSpringDraw.setGetRewardBtnTouchEnabled = function()
	if mRootView == nil then
		return
	end
	local getRewardBtn = tolua.cast(mRootView:getChildByName("getreward"), "UIButton")
	getRewardBtn:setBright(true)
	getRewardBtn:setTouchEnabled(true)
end
----------------------------------------------------------------------
-- ���ó齱��ť�ɷ��������ݵ�ǰ���������
local function setGetRewardBtn()
	if mRootView == nil then
		return
	end
	
	-- ��ǰ�ɳ齱����
	-- local labelRemainCount = tolua.cast(mRootView:getChildByName("remain_count"), "UILabel")
	-- labelRemainCount:setText()
	
	--��ȡ������ť
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
-- ����ת��Ȧ��������λ������(roundsֻ֧������)
local function setItemPositionByRounds(rounds)
	mAllMovePositon = {}
	rounds = rounds * 12			--����λ�õĸ�����
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
-- �����ƶ���ͼƬ���ڵ�λ�ã������������������ĸ�ͼ���Ƿ���ʾ
local function setFourStatesByIndex(index)
	if nil == mRootView then
		return
	end
	local MovePanel = tolua.cast(mRootView:getChildByName("Panel_400"),"UILayout")
	local up = tolua.cast(MovePanel:getChildByName("up"),"UIImageView")
	local down = tolua.cast(MovePanel:getChildByName("down"),"UIImageView")
	local left = tolua.cast(MovePanel:getChildByName("left"),"UIImageView")
	local right = tolua.cast(MovePanel:getChildByName("right"),"UIImageView")
	if index % 8 == 1 then  					  -- ������ʾ
		up:setVisible(false)
		down:setVisible(true)
		left:setVisible(false)
		right:setVisible(true)
	elseif index % 8 == 3 then					  -- ������ʾ 
		up:setVisible(false)
		down:setVisible(true)
		left:setVisible(true)
		right:setVisible(false)
	elseif index % 8 == 5 then		  			  -- ������ʾ
		up:setVisible(true)
		down:setVisible(false)
		left:setVisible(true)
		right:setVisible(false)
	elseif index % 8 == 7 then		   			  -- ������ʾ
		up:setVisible(true)
		down:setVisible(false)
		left:setVisible(false)
		right:setVisible(true)
	elseif index % 8 == 2 or index % 8 == 6 then  -- ������ʾ
		up:setVisible(false)
		down:setVisible(false)
		left:setVisible(true)
		right:setVisible(true)
	else										  -- ������ʾ
		up:setVisible(true)
		down:setVisible(true)
		left:setVisible(false)
		right:setVisible(false)
	end
end
----------------------------------------------------------------------
--�ս���ʱ�������⻺����ת��
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
-- �齱ʱ��ת����ͼ��
LayerSpringDraw.imageMove = function()
	if nil == mRootView then
		return
	end
	local moveLight = tolua.cast(mRootView:getChildByName("moveImage"),"UIImageView")
	local light = tolua.cast(mRootView:getChildByName("getreward_light"),"UIImageView")
	light:setRotation(214.00)
	local curTb = SpringActivityLogic.getActivityLotteryRechargeById(mRewardId)
	local keyPosition = 12
	
	--���ݻ����Ʒ��id���жϸ�id���Ǹ�λ��
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
-- չʾ��������Ʒ
local function iconClick(sender)
	CommonFunc_showInfo(0,sender:getTag(), 0)
end

------------------------------------------------------------------
-- չʾ��������Ʒ
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
		
		--��������
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
-- ������������������ֵ�����ݳ齱�Ĵ�����
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
-- ���ɻ��Ŀ
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
-- ˢ�»��չ
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
	
	-- ���ֹʱ��
	if endTime ~= nil then
		local labelTime = tolua.cast(mRootView:getChildByName("Label_date"), "UILabel")
		labelTime:setText(GameString.get("SPRING_ACTIVITY_TIP_2",endTime[1][1], endTime[1][2], endTime[1][3]))
	end
	
	-- ��ǰ�ɳ齱����
	local labelRemainCount = tolua.cast(mRootView:getChildByName("remain_count"), "UILabel")
	labelRemainCount:setText(mRemainCount)
end

---------------------------------------------------------------------
-- �齱�ɹ���ˢ�°�ť��loadingBar
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
-- ˢ�³ɹ���ˢ�°�ť����Ʒ
local function refreshUI()
	-- refreshBtnAndLoading()
	refreshProgressUI()		-- ˢ�� չʾ ��嵥
	setGetRewardBtn()		-- ˢ�� չʾ ����
	loadSlowAction()
end
EventCenter_subscribe(EventDef["ED_SPRING_PROGRESS"], refreshUI)


-----------------------------------------��ʼ��---------------------------
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
		-- FriendPointLogic.requestRefreshlotteryList() 		--����ˢ���б�
	-- end
	-- refreshProgressUI(mActLotteryInfo)		-- չʾ��嵥
	refreshUI()
	showItemIcons()							-- չʾ����Icon
	-- loadSlowAction()
	
	-- local getRewardBtn = tolua.cast(mRootView:getChildByName("getreward"), "UIButton")
	-- getRewardBtn:setBright(false)
	
	-- ��Ϸ�¼�ע��-- ��ȡ����㽱��
	-- EventCenter_subscribe(EventDef["ED_FRIEND_POINT_GET"], refreshUIAfterRewardSuccess) 	
	-- �����µ�һ��ˢ�������
	-- EventCenter_subscribe(EventDef["ED_FRIEND_POINT_TIME_OVER"], refreshUIAfterRewardSuccess)
	-- ˢ������㽱���б�
	-- EventCenter_subscribe(EventDef["ED_FRIEND_POINT_REFRESH"], refreshUIAfterRewardSuccess)
	-- TipModule.onUI(rootView, "ui_friendpoint")
end

-------------------------------------------����---------------------------
LayerSpringDraw.setRootNil = function()
	mRootView = nil
end

-- ��¼ ���� �齱��Ϣ
LayerSpringDraw.setLotteryInfo = function(bundle)
	mActLotteryInfo = bundle
end

-- ��¼ ��ID
LayerSpringDraw.setRewardId = function(id)
	mRewardId = id
end

LayerSpringDraw.setTime = function(st, et)
	startTime = st
	endTime = et
end