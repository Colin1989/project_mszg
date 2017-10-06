--/**
-- *  @Brief: 训练赛
-- *  @Created by fjut on 14-05-19
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerGameTrain = {}
local rootNode = nil

-- 礼包图片
local giftBagNormalPic ={"training_reward_01.png","training_reward_02.png","training_reward_03.png","training_reward_04.png"}
local m_giftBagTotal = {1, 2, 4, 6}	-- 礼包奖励进度
local m_giftBagCur = {0, 0, 0, 0}
local m_giftBagPicTag = 10000			-- 礼包Pic tag
local m_giftBagLabelTag = 20000			-- 礼包Label tag
local m_competitorTag = 30000			-- 对手UI layout tag
local m_challengeBtnTag = 40000			-- 挑战按钮
local m_selectChallengeTag = 0

local m_compeData = {}				-- 挑战对手信息
local m_challengeTimesData = {}		-- 挑战次数信息
local m_bIsCanGet = {0, 0, 0, 0}	-- 奖励是否可领取

local m_tbOneChallengerInfo = {}	-- 挑战玩家信息
local m_listReqType = 1				-- 挑战列表请求类型, 1表示普通请求，2表示刷新
local m_freeRefLastTimes = 0		-- 今天还可以免费刷新次数

local mNewDay = true				-- 新的一天
local mDailyTimerFlag = false

----------------------------------------计算花费金币------------------------------------
-- 刷新挑战列表花费金币
local function getCoinCostWithRef(times)
	local expres = LogicTable.getExpressionRow(18)	
	local valueTable = 
	{
		{name = "Times", value = times}
	}
	local price = ExpressionParse.compute(expres.expression, valueTable)
	return tonumber(price)
end 

-- 增加挑战次数花费金币
local function getCoinCostWithPur(times)
	local expres = LogicTable.getExpressionRow(17)
	local valueTable = 
	{
		{name = "Times", value = times}
	}
	local price = ExpressionParse.compute(expres.expression, valueTable)
	return tonumber(price)
end 
-----------------------------------------发送请求------------------------------------------
-- 请求增加挑战次数
local function dialogSureAddTimes()
	--魔石不足
	local costDiaNum = getCoinCostWithPur(0)
	if CommonFunc_payConsume(2, costDiaNum) then
		return
	end
	if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
		UIManager.pop(UIManager.getTopLayerName())
	end
	local tb = req_buy_train_match_times()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_buy_train_match_times_result"]) 
end

--请求刷新挑战列表
local function dialogSureRef()
	-- 隐藏挑战按钮
	local btnChallenge = rootNode:getChildByTag(m_challengeBtnTag)
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
	-- 魔石不足
	local costDiaNum = getCoinCostWithRef(m_challengeTimesData.refresh_times)
	if tonumber(m_freeRefLastTimes) < 1 and CommonFunc_payConsume(2, costDiaNum) then
		return
	end
	if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
		UIManager.pop(UIManager.getTopLayerName())
	end
	-- req
	local tb = req_train_match_list()
	-- 1表示普通请求，2表示刷新
	m_listReqType = 2
	tb.list_type = m_listReqType
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_train_match_list"]) 
end

-- net 请求普通列表
local function netReq()
	-- 对手列表
	local tb = req_train_match_list()
	-- 1表示普通请求，2表示刷新
	m_listReqType = 1
	tb.list_type = m_listReqType
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_train_match_list"]) 
	-- 挑战次数信息
	EventCenter_post(EventDef["ED_TRAINGAME_TIMES"])
end
-------------------------------------------点击事件------------------------------------------
-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	
	if sender:getName() == "btn_close" then				-- 关闭
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", sender:getName())
	elseif sender:getName() == "btn_addNum" then 		-- 增加挑战次数
		local costDiaNum = getCoinCostWithPur(0)
		--次数不足
		if m_challengeTimesData.buy_times >= LIMIT_Buy_train_times then
			Toast.Textstrokeshow(GameString.get("Public_BuyTimes_Not_Enough"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		local diaMsg = 
		{
			strText = string.format(GameString.get("GAMETRAIN_PUR_TIMES",LIMIT_Buy_train_times - m_challengeTimesData.buy_times, costDiaNum)),
			buttonCount = 2,
			isPop = false,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureAddTimes, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	elseif sender:getName() == "btn_refresh" then 		-- 刷新挑战列表
		-- 免费刷新
		if tonumber(m_freeRefLastTimes) >= 1 then
			dialogSureRef()
			return 
		end
		
		local costDiaNum = getCoinCostWithRef(m_challengeTimesData.refresh_times)
		local diaMsg = 
		{
			strText = string.format(GameString.get("GAMETRAIN_PUR_REF", costDiaNum)),
			buttonCount = 2,
			isPop = false,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureRef, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	end
end

-- 奖励call
local function giftBagCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	local tag = sender:getTag() - m_giftBagPicTag
	-- 0没领过, 1领过
	if m_giftBagCur[tag] < m_giftBagTotal[tag] or m_bIsCanGet[tag] == 1 then  -- 提示不能领取
		return
	end
	-- 领取奖励
	local tb = req_get_train_award()
	tb.type = tonumber(tag)
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_get_train_award_type"]) 
end

-- 挑战按钮call
local function btnActionCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	-- 隐藏挑战按钮
	local btnChallenge = rootNode:getChildByTag(m_challengeBtnTag)
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
	-- 次数不足
	local lastTimes = m_challengeTimesData.buy_times + m_challengeTimesData.org_times - m_challengeTimesData.play_times
	if lastTimes <= 0 then
		Toast.Textstrokeshow(GameString.get("GAMETRAIN_PUR_LAST"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	
	m_tbOneChallengerInfo = m_compeData[m_selectChallengeTag]
	-- 进入战斗
	local roleInfo = {}
	roleInfo.role_id = 
	FightStartup.startTranning(m_tbOneChallengerInfo)
end

-- 挑战对手call
local function challengeCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onMessage("click_train_fight", sender:getTag())
	m_selectChallengeTag = sender:getTag()
	local pos1 = rootNode:getWorldPosition()
	local pos = sender:getWorldPosition()
	pos.x = pos.x - pos1.x
	pos.y = pos.y - pos1.y
	local btnChallenge = rootNode:getChildByTag(m_challengeBtnTag)
	btnChallenge:setPosition(ccp(pos.x + 50, pos.y - 20))
	btnChallenge:setVisible(true)
	btnChallenge:setTouchEnabled(true)
end
-------------------------------------------------UI初始化-------------------------------------------------------
-- 对手详细信息
local function getCompeUI(tag)
	local value = m_compeData[tag]
	-- 背景
	local bg = CommonFunc_getImgView("public2_bg_07.png") 
	bg:setScale9Enabled(true)
    bg:setSize(CCSizeMake(268, 106))
	bg:setTag(tag)
	bg:setTouchEnabled(true)
	bg:registerEventScript(challengeCall)
	-- 头像
	local imgHead = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(value.type,value.advanced_level))
	imgHead:setPosition(ccp(-85, 1))
	bg:addChild(imgHead)
	-- 昵称
	local labelNick = CommonFunc_getLabel(value.name, 20)
	labelNick:setPosition(ccp(-24, 35))
	labelNick:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelNick)
	-- 等级
	local labelLv = CommonFunc_getLabel(GameString.get("Public_DJ_VAL",  value.level), 20)
	labelLv:setPosition(ccp(-24, 4))
	labelLv:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelLv)
	-- 战力
	local labelFight = CommonFunc_getLabel(GameString.get("Public_ZL_VAL",  value.power), 20)
	labelFight:setPosition(ccp(-24, -31))
	labelFight:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelFight)
	-- 状态 1 已被击败
	if value.status == 1 then
		local status = CommonFunc_getImgView("training_beat.png")
		status:setPosition(ccp(75, 3))
		bg:addChild(status)
	end	
	
	return bg
end

-- 对手信息
local function showCompeUI()
	if nil == rootNode then
		return
	end
	local layout = rootNode:getChildByTag(m_competitorTag)
	layout:removeAllChildren()
	
	local posX = 144
	local posY = 290
	for i = 1, #(m_compeData), 1 do
		local compeUI = getCompeUI(i)
		compeUI:setName("btn_train_enemy"..i)
		compeUI:setPosition(ccp(posX, posY))
		layout:addChild(compeUI)
		posX = posX + 278
		if i%2 == 0 then
			posY = posY - 116
			posX = 144
		end	
	end
end

-- 初始化静态UI
local function initUI()
	local panel = rootNode:getChildByName("Panel_20")
	-- 关闭btn event
	local btnClose = panel:getChildByName("btn_close")
    btnClose:registerEventScript(btnCall)
	-- 挑战次数
	local labelChNum = CommonFunc_getLabelByName(panel, "labelAtlas_num", nil, true)
	labelChNum:setStringValue(string.format("%d", 0))
	-- 增加挑战次数
	local btnAddNum = panel:getChildByName("btn_addNum")
    btnAddNum:registerEventScript(btnCall)
	-- 刷新挑战列表
	local btnRef = panel:getChildByName("btn_refresh")
    btnRef:registerEventScript(btnCall)
	-- 今日还可以免费刷新次数
	local labelRefTimes = CommonFunc_getLabelByName(panel, "label_refNum")
	labelRefTimes:setText(tostring(0))
	-- 奖励礼包
	local posX = 131
	local posY = 118
	for i = 1, #(giftBagNormalPic), 1 do 
		-- bg
		local bg = CommonFunc_getImgView("training_reward_bg.png")
		bg:setPosition(ccp(posX, posY))
		panel:addChild(bg)
		-- pic
		local giftBag = CommonFunc_getImgView(giftBagNormalPic[i])
		giftBag:setTag(m_giftBagPicTag + i)
		giftBag:setPosition(ccp(posX, posY))
		panel:addChild(giftBag)
		giftBag:setTouchEnabled(true)
		giftBag:registerEventScript(giftBagCall)
		-- label
		local labelNum = CommonFunc_getLabel(string.format("%d/%d", m_giftBagCur[i], m_giftBagTotal[i]))
		labelNum:setTag(m_giftBagLabelTag + i)
		labelNum:setPosition(ccp(posX, posY - 48))
		panel:addChild(labelNum)
		posX = posX + 128
	end
	
	local layout = UILayout:create()
	layout:setTag(m_competitorTag)
	layout:setName("btn_train_parent")
	panel:addChild(layout)
	layout:setPosition(ccp(36, 288))
	layout:setSize(CCSizeMake(570, 336))
	
	-- 挑战按钮
	local btnChallenge = CommonFunc_getButton("Rank_icon_02.png", "Rank_icon_04.png", "Rank_icon_04.png") 
	btnChallenge:setTag(m_challengeBtnTag)
	btnChallenge:setZOrder(20)
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
	btnChallenge:registerEventScript(btnActionCall)
	panel:addChild(btnChallenge)
	
	-- 对手信息
	showCompeUI()
end

-- 更新奖励列表
local function updateGiftBag()
	-- num label
	local color = ccc3(0, 255, 0)
	for i = 1, #(giftBagNormalPic), 1 do 
		local label = rootNode:getChildByTag(m_giftBagLabelTag + i)
		tolua.cast(label, "UILabel")
		-- 达到
		if tonumber(m_challengeTimesData.success_times) >= m_giftBagTotal[i] then
			m_giftBagCur[i] = m_giftBagTotal[i]
			color = ccc3(0, 255, 0)
		else
			m_giftBagCur[i] = tonumber(m_challengeTimesData.success_times)
			color = ccc3(255, 0, 0)
		end
		label:setText(string.format("%d/%d", m_giftBagCur[i], m_giftBagTotal[i]))
		label:setColor(color)
	end

	-- data
	local tb = {}
	-- award_status -- 0没领过, 1领过
	local str = tostring(m_challengeTimesData.award_status)
	for j = 1, #(giftBagNormalPic), 1 do 
		table.insert(tb, tonumber(string.sub(str, j+1, j+1)))
	end
	m_bIsCanGet = tb
	
	-- img
	local flagTag = 1000
	for i = 1, #(giftBagNormalPic), 1 do 
		-- 0没领过, 1领过,
		local imgStr = (m_bIsCanGet[i] == 1) and "training_reward_05.png" or giftBagNormalPic[i]
		local giftBag = rootNode:getChildByTag(m_giftBagPicTag + i)
		tolua.cast(giftBag, "UIImageView")
		giftBag:loadTexture(imgStr)
		-- 可以领取了, 但还没领取状态(添加提示角标)
		if m_bIsCanGet[i] == 0 and m_giftBagCur[i] >= m_giftBagTotal[i] then
			local imgFlag = giftBag:getChildByTag(flagTag)
			if imgFlag == nil then
				imgFlag = CommonFunc_getImgView("uiiteminfo_kelingqu.png")
				imgFlag:setPosition(ccp(34, 34))
				imgFlag:setTag(flagTag)
				giftBag:addChild(imgFlag)
			end	
		else
			local imgFlag = giftBag:getChildByTag(flagTag)
			if imgFlag ~= nil then
				giftBag:removeChild(imgFlag)
			end
		end
	end
end

LayerGameTrain.init = function(root)
	-- add gui
	rootNode = root
	if rootNode == nil then
		cclog("LayerGameTrain init nil") 
		return nil
	end	

	initUI()
	netReq()
	TipModule.onUI(root, "ui_gametrain")
	return rootNode
end

LayerGameTrain.destroy = function()
	rootNode = nil
end

LayerGameTrain.purge = function()
	rootNode = nil
	m_giftBagTotal = {3, 6, 9, 12}
	m_giftBagCur = {0, 0, 0, 0}
	m_bIsCanGet = {0, 0, 0, 0}
end
---------------------------------------------------处理对手列表信息 -----------------------------------
-- 对手列表 rec
local function Handle_req_gameTrainList(resp)
	if resp == nil or resp.match_list == nil then
		return
	end
	
	-- 今日还可以免费刷新次数
	if rootNode ~= nil and m_listReqType == 2 then
		m_freeRefLastTimes = (m_freeRefLastTimes <= 0) and 0 or m_freeRefLastTimes - 1
		local labelRefTimes = CommonFunc_getLabelByName(rootNode, "label_refNum")
		labelRefTimes:setText(tostring(m_freeRefLastTimes))
		--cclog("今日还可以免费刷新次数(刷新): ", m_freeRefLastTimes)
		m_challengeTimesData.refresh_times = m_challengeTimesData.refresh_times + 1
	end

	m_compeData = resp.match_list
	showCompeUI()
end
-------------------------------------------------处理挑战次数信息-----------------------------------------
-- 挑战次数信息
local function reqChallengeTimes()
	-- 挑战次数信息
	local tb = req_get_train_match_times_info()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_train_match_times_info"])
	LayerMainEnter.setReqChallengeFlage(true)
end

--更新次数相关的UI
local function updateTimesUI()
	if rootNode == nil then
		return
	end
	-- 今日还可以免费刷新次数
	local times = LIMIT_Train_free_refreshtimes - m_challengeTimesData.refresh_times
	m_freeRefLastTimes = (times <= 0) and 0 or times
	local labelRefTimes = CommonFunc_getLabelByName(rootNode, "label_refNum")
	labelRefTimes:setText(tostring(m_freeRefLastTimes))
	-- 挑战次数
	local lastTimes = m_challengeTimesData.buy_times + m_challengeTimesData.org_times - m_challengeTimesData.play_times
	local labelChNum = CommonFunc_getLabelByName(rootNode, "labelAtlas_num", nil, true)
	labelChNum:setStringValue(string.format("%d", lastTimes))
	-- 更新奖励列表
	updateGiftBag()
end

-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	m_challengeTimesData.play_times = 0
	m_challengeTimesData.buy_times = 0
	m_challengeTimesData.success_times = 0
	m_challengeTimesData.refresh_times = 0
	
	updateTimesUI()
end

-- 挑战次数信息rec
local function Handle_req_gameTrainTimes(resp)
	--Log("Handle_req_gameTrainTimes*********",resp)
	if resp == nil then
		return
	end
	TipFunction.setFuncAttr("func_train_match", "count", resp.play_times)
	m_challengeTimesData = resp
	
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	
	-- 外部更新数据
	if rootNode == nil then
		for i = 1, #(giftBagNormalPic), 1 do 
			-- 达到
			if tonumber(m_challengeTimesData.success_times) >= m_giftBagTotal[i] then
				m_giftBagCur[i] = m_giftBagTotal[i]
			else
				m_giftBagCur[i] = tonumber(m_challengeTimesData.success_times)
			end
		end
		-- data
		local tb = {}
		-- award_status -- 0没领过, 1领过
		local str = tostring(m_challengeTimesData.award_status)
		for j = 1, #(giftBagNormalPic), 1 do 
			table.insert(tb, tonumber(string.sub(str, j+1, j+1)))
		end
		m_bIsCanGet = tb
		return
	end
	--更新次数相关的UI
	updateTimesUI()
end
---------------------------------------------处理购买挑战次数---------------------------------------------
-- 购买挑战次数rec
local function Handle_req_gameTrainPurTimes(resp)
	if resp.result ~= common_result["common_success"] then
		return
	end
	
	CommonFunc_CreateDialog(GameString.get("Public_MSG_PUR_SUCC"))
	-- 购买成功
	m_challengeTimesData.buy_times = m_challengeTimesData.buy_times + 1
	-- 挑战次数
	local lastTimes = m_challengeTimesData.buy_times + m_challengeTimesData.org_times - m_challengeTimesData.play_times
	local labelChNum = CommonFunc_getLabelByName(rootNode, "labelAtlas_num", nil, true)
	labelChNum:setStringValue(string.format("%d", lastTimes))
end
-------------------------------------------------处理领取奖励-------------------------------------------------
-- 领取奖励rec
local function Handle_req_gameTrainRecAwards(resp)
	if resp.result ~= common_result["common_success"] then
		return
	end

	local row = LogicTable.getRewardItemRow(resp.award_id)
	Toast.Textstrokeshow(GameString.get("ShopMall_PUR_GET", tostring(row.name), tonumber(resp.amount)), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	m_challengeTimesData.award_status = resp.new_status
	
	-- 奖励背包更新
	updateGiftBag()
end
---------------------------------------------网络消息注册----------------------------------------------------
-- 对手列表
NetSocket_registerHandler(NetMsgType["msg_notify_train_match_list"], notify_train_match_list, Handle_req_gameTrainList)
-- 挑战次数信息
NetSocket_registerHandler(NetMsgType["msg_notify_train_match_times_info"], notify_train_match_times_info, Handle_req_gameTrainTimes)
-- 购买挑战次数
NetSocket_registerHandler(NetMsgType["msg_notify_buy_train_match_times_result"], notify_buy_train_match_times_result, Handle_req_gameTrainPurTimes)
-- 领取奖励
NetSocket_registerHandler(NetMsgType["msg_notify_get_train_award_type"], notify_get_train_award_type, Handle_req_gameTrainRecAwards)

-- 挑战次数信息
EventCenter_subscribe(EventDef["ED_TRAINGAME_TIMES"], reqChallengeTimes)
--------------------------------------------供外部使用的-----------------------------------------------

LayerGameTrain.updateUI = function(bIsSuccess)
	if rootNode == nil then
		return 
	end	
	if bIsSuccess == nil or type(bIsSuccess) ~= "boolean" then
		return
	end
	m_challengeTimesData.play_times = m_challengeTimesData.play_times  --+ 1
	if bIsSuccess then
		m_challengeTimesData.success_times = m_challengeTimesData.success_times --+ 1
	end
	-- 挑战次数
	local lastTimes = m_challengeTimesData.buy_times + m_challengeTimesData.org_times - m_challengeTimesData.play_times
	local labelChNum = CommonFunc_getLabelByName(rootNode, "labelAtlas_num", nil, true)
	labelChNum:setStringValue(string.format("%d", lastTimes))
	-- 更新奖励列表
	updateGiftBag()
	-- 对手列表
	if bIsSuccess then
		m_tbOneChallengerInfo.status = 1
		showCompeUI()
	end	
end

-- 获取今日挑战胜利次数
LayerGameTrain.getSuccessTimes = function()
	local times = 0
	times = (m_challengeTimesData.success_times == nil) and 0 or tonumber(m_challengeTimesData.success_times)

	return times
end

-- 获取是否还有礼包未领取或挑战次数未用完
LayerGameTrain.getIsRewardCanGet = function()
	--Log("LayerGameTrain.getIsRewardCanGet*********",m_challengeTimesData)
	if nil == m_challengeTimesData.buy_times or nil ==  m_challengeTimesData.org_times or nil == m_challengeTimesData.play_times then
		return false
	end
	
	local lastTimes = m_challengeTimesData.buy_times + m_challengeTimesData.org_times - m_challengeTimesData.play_times
	if lastTimes > 0 then
		return true
	end
	
	for i = 1, #(giftBagNormalPic), 1 do 
		-- 0没领过, 1领过
		if m_giftBagCur[i] >= m_giftBagTotal[i] and m_bIsCanGet[i] == 0 then
			return true
		end
	end
	return false
end
---------------------------------------------------------------------------------------





