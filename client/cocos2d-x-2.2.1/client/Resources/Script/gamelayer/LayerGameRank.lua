--/**
-- *  @Brief: 竞技场排位赛
-- *  @Created by fjut on 14-03-12
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerGameRank = {}
local rootNode = nil

local ReWardDesc = {}  -- 奖励信息

local myRank = 0					-- 我的排名
local myLv = 0						-- 我的等级
local tbChallengeTimes = {}			-- 玩家挑战次数信息
local tbOneChallengerInfo = {}		-- 点击挑战玩家信息
local tbMsgInfo = {}				-- 推送消息
local m_dt = 20*60*60				-- 冷却时间
local m_schedule = nil
local m_competitorTag = 30000		-- 对手UI layout tag
local m_compeData = {}				-- 挑战对手信息
local m_challengeBtnTag = 40000		-- 挑战按钮

GAMERANK_SCORE_PARAM1 = 100000  	-- 竞技场领取积分计算公式参数1
GAMERANK_SCORE_PARAM2 = 20  		-- 竞技场领取积分计算公式参数2
GAMERANK_SCORE_PARAM3 = 200 		-- 竞技场前200名玩家可领取奖励
GAMERANK_SCORE_PARAM4 = 20*60*60 	-- 竞技场领取奖励冷却时间, 20小时 20*60*60

local mNewDay = true				-- 新的一天
local mDailyTimerFlag = false


-- 6个头像按钮
local tbImg = {"img_1", "img_2", "img_3", "img_4", "img_5", "img_6"}
-- 6个排位
local tbNo = {"label_1_no", "label_2_no", "label_3_no", "label_4_no", "label_5_no", "label_6_no"}
-- 6个昵称
local tbNick = {"label_1_nick", "label_2_nick", "label_3_nick", "label_4_nick", "label_5_nick", "label_6_nick"}
-- 6个等级
local tbLv = {"label_1_lv", "label_2_lv", "label_3_lv", "label_4_lv", "label_5_lv", "label_6_lv"}
-- 6个战力
local tbFight = {"label_1_fight", "label_2_fight", "label_3_fight", "label_4_fight", "label_5_fight", "label_6_fight"}

-- 是否是自己
local function getBIsSelf(info)
	if info.role_id == ModelPlayer.getId() then
		return true
	end
	
	return false
end

-- 获得战斗信息
LayerGameRank.getCombatMsg = function()
	return tbMsgInfo
end

-- 获得当前Rank
LayerGameRank.getMyRank = function()
	return myRank
end

-- 设置气泡感叹号
local function setTipIcon(str, value)
	local tipIcon = rootNode:getChildByName("tip_icon_"..str)
	if nil == tipIcon then
		tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setName("tip_icon_"..str)
		local btn = rootNode:getChildByName(str)
		btn:addChild(tipIcon)
	end
	
	if type(value) == "number" then
		local isTrue = nil
		if value > 0 then
			isTrue = false
		else
			isTrue = true
		end
		tipIcon:setPosition(ccp(64, 25))
		tipIcon:setVisible(isTrue)
	end
end

-- 图片点击响应
local function imgCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	local tag = sender:getTag()
	if m_compeData[tag].role_id == ModelPlayer.getId() then
		-- 点击自己
		CommonFunc_CreateDialog(GameString.get("GameRank_MSG_CLICK"))
	else
		TipModule.onMessage("click_rank_fight", sender:getTag())
		-- 显示挑战按钮
		local pos1 = rootNode:getWorldPosition()
		local pos = sender:getWorldPosition()
		pos.x = pos.x - pos1.x + 50
		pos.y = pos.y - pos1.y - 20
	
		local btnChallenge = rootNode:getChildByTag(m_challengeBtnTag)
		btnChallenge:setVisible(true)
		btnChallenge:setTouchEnabled(true)
		btnChallenge:setPosition(pos)
		tbOneChallengerInfo = m_compeData[tag]
	end
end

-- 购买挑战次数花费金币
local function getCoinCostWithPur()
	local expres = LogicTable.getExpressionRow(19)
	local valueTable = 
	{
		{name = "Times", value = 0 }
	}
	local price = ExpressionParse.compute(expres.expression, valueTable)
	return tonumber(price)
end

local function dialogSureCall()
	-- 购买一次花费钻石
	local costDiaNum = getCoinCostWithPur()
	--魔石不足
	if CommonFunc_payConsume(2, costDiaNum) then
		return
	end
	if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
		UIManager.pop(UIManager.getTopLayerName())
	end
	local tb = req_buy_challenge_times()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_buy_challenge_times_result"]) 
end

-- 领取奖励获得积分
local function getScoreWithReward(level, rank)
	local expres = LogicTable.getExpressionRow(13)	
	local valueTable = 
	{
		{name = "Level", value = level}, 
		{name = "Rank", value = rank}
	}
	local price = ExpressionParse.compute(expres.expression, valueTable)
	return tonumber(price)
end 

-- 购买次数
local function buyTimes()
	-- 购买一次花费钻石
	local costDiaNum = getCoinCostWithPur()
	-- 次数不足
	if tbChallengeTimes.buy_times >= LIMIT_Buy_challenge_times then
		Toast.Textstrokeshow(GameString.get("Public_BuyTimes_Not_Enough"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	local diaMsg = 
	{
		strText = string.format(GameString.get("GameRank_BUY_TIMES",LIMIT_Buy_challenge_times - tbChallengeTimes.buy_times,costDiaNum)),
		buttonCount = 2,
		isPop = false,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, nil} --回调函数
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	-- 关闭
	if sender:getName() == "btn_close" then
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", sender:getName())
	-- 购买挑战次数请求reg
	elseif sender:getName() == "btn_add" then 
		buyTimes()
	elseif sender:getName() == "btn_skill" then
		local bundle = {}
		bundle.callback = nil
		UIManager.push("UI_SkillGroup", bundle)
	elseif sender:getName() == "btn_combatlog" then
		UIManager.push("UI_CombatLog")
	-- 领取奖励请求	
	elseif sender:getName() == "btn_getReward" then 
		cclog("btn_getReward")
		if m_dt > 0 then
			CommonFunc_CreateDialog(GameString.get("GameRank_MSG_DATE"))
		else
			tb = req_get_challenge_rank_award()
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_get_challenge_rank_award_result"])
		end
	end
end

-- 挑战按钮call
local function btnActionCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	-- 隐藏挑战按钮
	local btnChallenge = rootNode:getChildByTag(m_challengeBtnTag)
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
	
	-- 挑战	
	if sender:getName() == "btn_challenge" then
		-- 可以挑战次数
		local times = tbChallengeTimes.buy_times + tbChallengeTimes.org_times - tbChallengeTimes.play_times
		if times <= 0 then
			buyTimes()
			return
		end
		-- 要挑战的玩家信息
		cclog(tbOneChallengerInfo.rank.." "..tbOneChallengerInfo.name.." "..tbOneChallengerInfo.level.." "..tbOneChallengerInfo.power.." "..tbOneChallengerInfo.role_id)
		--请求进入竞技场
		FightStartup.startMatch(tbOneChallengerInfo)
	end
end


-- 挑战别人自己创建推送消息
function LayerGameRank.setChallengeMsg(bIsSuccess)
	if bIsSuccess == nil or type(bIsSuccess) ~= "boolean" then
		cclof("setChallengeMsg fail, param is bad !")
		return
	end
	if tbMsgInfo == nil or rootNode == nil then
		cclof("tbMsgInfo or rootNode == nil!")
		return
	end
	
	-- 添加推送消息
	local tb = {}
	tb.result = bIsSuccess and game_result["game_win"] or game_result["game_lost"]
	tb.name = tbOneChallengerInfo.name
	tb.new_rank = tbOneChallengerInfo.rank
	-- 挑战的对手排名小于自己的排名, 无论输赢排名都不变
	if tbOneChallengerInfo.rank > myRank then
		tb.new_rank = myRank
		tb.up = true
	end
	tb.bIsSelf = true
	table.insert(tbMsgInfo, 1, tb)
	--cclog("挑战结果:"..tb.result.."挑战对手:"..tb.name)
end

-- 获取被挑战玩家的排名
function LayerGameRank.getRank()
	local myRank = tonumber(myRank)
	local enemyRank = tonumber(tbOneChallengerInfo.rank)
	
	if myRank < enemyRank then 
		return myRank
	else 
		return enemyRank
	end
end

-- 创建奖励单元格
local function getRewardNodeById(cell, data, index)
	local tbRow = LogicTable.getRewardItemRow (data.ids)
	local reWardInfo = {}
	reWardInfo.amount = tostring(data.amounts)
	reWardInfo.name = tbRow.name
	table.insert(ReWardDesc,reWardInfo)
	
	local node = UILayout:create()
	node:setSize(CCSizeMake(57, 76))
	node:setTag(tonumber(tbRow.id))
	local size = node:getSize()
		
	-- bg
	local bg = CommonFunc_getImgView("uibag_bg_framer.png")
	bg:setPosition(ccp(28, 46))
	bg:setScale(0.6)
	bg:setZOrder(tonumber(data.ids * 10))
	node:addChild(bg)
		
	-- 物品
	local Itemdate = LogicTable.getRewardItemRow (data.ids)
	local Itemdate = CommonFunc_getImgView(tbRow.icon)
	Itemdate:setZOrder(tonumber(data.ids))
	Itemdate:setScale(0.6)
	Itemdate:setPosition(ccp(28, 46))
	node:addChild(Itemdate)
	
	Itemdate:setTouchEnabled(true)
	local function clickSkillIcon(Itemdate)
		showLongInfoByRewardId(tbRow.id,Itemdate)
	end
	
	local function clickSkillIconEnd(Itemdate)
		longClickCallback_reward(tbRow.id,Itemdate)
	end

	UIManager.registerEvent(Itemdate, nil, clickSkillIcon, clickSkillIconEnd)
	
	
	
	-- 数量
	local ItemNum = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	ItemNum:setAnchorPoint(ccp(1, 0.5))
	ItemNum:setStringValue(string.format("%d", data.amounts))
	ItemNum:setScale(0.46)
	ItemNum:setPosition(ccp(44, 8))
	node:addChild(ItemNum)
		
	return node
end

-- 奖励信息
local function showRewardInfo(myScore, dt)
	local challengeAwardTable = LogicTable.getChallengeAward()
	local challengeReWard = {}
	
	for k, v in pairs(challengeAwardTable) do
		if myRank >= v.rank_range[1] and myRank <= v.rank_range[2] then
			for i, j in pairs(v.amounts) do
				local temp = {}
				
				temp.amounts = v.amounts[i]
				temp.ids = v.ids[i]
				
				table.insert(challengeReWard, temp)
			end
		end
	end
	
	if rootNode == nil then
		cclog("LayerGameRank init nil")
		return nil
	end
	ReWardDesc = {}
	local scrollView = tolua.cast(rootNode:getChildByName("ScrollView_470"), "UIScrollView")
	UIScrollViewEx.show(scrollView, challengeReWard, getRewardNodeById, "H", 57, 76, 5, 1, 4, true, nil, true, true)
	
	-- 当前我的挑战者硬币
	local mCoinInfo = ModelBackpack.getItemByTempId(1007) -- 1007 为挑战者硬币ID
	local labelMyHonor = CommonFunc_getLabelByName(rootNode, "labelAtlas_honor", nil, true)
	if mCoinInfo ~= nil then
		labelMyHonor:setStringValue(string.format("%d", mCoinInfo.amount))
	else
		labelMyHonor:setStringValue(string.format("%d", 0))
	end
	
	-- 当前我的战绩
	local labelMyScore = CommonFunc_getLabelByName(rootNode, "labelAtlas_score", nil, true)
	labelMyScore:setStringValue(string.format("%d", myScore or 0))
	
	-- 冷却时间
	local labelDT = CommonFunc_getLabelByName(rootNode, "label_dt")
    labelDT:setText(CommonFunc_secToString(dt))
end

-- 对手详细信息
local function getCompeUI(tag)
	local value = m_compeData[tag]
	--cclog(" "..value.name.." "..value.level.." "..value.power.." "..value.role_id)
	-- 背景 
	local bg = CommonFunc_getImgView("public2_bg_07.png")
	bg:setScale9Enabled(true)
    bg:setSize(CCSizeMake(268, 106))
	bg:setTag(tag)
	bg:setTouchEnabled(true)
	bg:registerEventScript(imgCall)
	-- 头像 
	local imgHead = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(value.type,value.advanced_level))
	imgHead:setPosition(ccp(-85, 1))
	bg:addChild(imgHead)
	-- 排位
	local labelNo = CommonFunc_getLabel(string.format("NO.%d", value.rank), 18)
	labelNo:setPosition(ccp(-24, 42))
	labelNo:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelNo)
	-- 昵称
	local labelNick = CommonFunc_getLabel(value.name, 18)
	labelNick:setPosition(ccp(-24, 14))
	labelNick:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelNick)
	-- 等级
	local labelLv = CommonFunc_getLabel(GameString.get("Public_DJ_VAL",  value.level), 18)
	labelLv:setPosition(ccp(-24, -12))
	labelLv:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelLv)
	-- 战力
	local labelFight = CommonFunc_getLabel(GameString.get("Public_ZL_VAL",  value.power), 18)
	labelFight:setPosition(ccp(-24, -38))
	labelFight:setAnchorPoint(ccp(0, 0.5))
	bg:addChild(labelFight)
	if value.role_id == ModelPlayer.getId() then
		myRank = value.rank
		myLv = value.level
	end
	
	return bg
end

-- 对手信息
local function showCompeUI()
	if rootNode == nil then
		return 
	end
	
	local layout = rootNode:getChildByTag(m_competitorTag)
	if layout == nil then
		layout = UILayout:create()
		layout:setTag(m_competitorTag)
		layout:setName("btn_rank_parent")
		rootNode:addChild(layout)
		layout:setPosition(ccp(36, 288))
		layout:setSize(CCSizeMake(570, 362))
	
	else
		layout:removeAllChildren()
	end
	
	local posX = 144
	local posY = 290
	for i = 1, #(m_compeData), 1 do
		local compeUI = getCompeUI(i)
		compeUI:setPosition(ccp(posX, posY))
		compeUI:setName("btn_ememy"..i)
		layout:addChild(compeUI)
		posX = posX + 278
		if i%2 == 0 then
			posY = posY - 116
			posX = 144
		end
	end
end


local function Handle_req_gameRankList(resp)
	-- 对手信息
	m_compeData = resp.infos
	
	showCompeUI()
	
	-- 奖励信息
	showRewardInfo(ModelPlayer.getPoint(), m_dt)
	
	-- 当前自己排名
	if rootNode == nil then
		cclog("rootNode == nil")
		return
	end
	local labelMyRank = CommonFunc_getLabelByName(rootNode, "labelAtlas_rank", nil, true)
	labelMyRank:setStringValue(string.format("%d", myRank))
end

-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	if rootNode == nil then
		return
	end
	tbChallengeTimes.play_times = 0
	tbChallengeTimes.buy_times = 0
	-- 可以挑战次数
	local times = resp.buy_times + resp.org_times - resp.play_times
	local labelAltasTimes = CommonFunc_getLabelByName(rootNode, "labelAtlas_times", nil, true)
	labelAltasTimes:setStringValue(string.format("%d", times))
end

-- 获取挑战次数信息
local function Handle_req_gameRankTimes(resp)
	--Log("Handle_req_gameRankTimes",resp)
	TipFunction.setFuncAttr("func_rank_match", "count", resp.play_times)
	-- 缓存
	tbChallengeTimes = resp
	
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	
	-- 冷却时间
	m_dt = resp.award_timeleft
	LayerMainEnter.setReqChallengeFlage(true)
	if rootNode == nil then
		return
	end

	-- 可以挑战次数
	local times = resp.buy_times + resp.org_times - resp.play_times
	local labelAltasTimes = CommonFunc_getLabelByName(rootNode, "labelAtlas_times", nil, true)
	labelAltasTimes:setStringValue(string.format("%d", times))
end

-- 购买挑战次数
local function Handle_req_gameRankBuyTimes(resp)
	if resp.result ~= common_result["common_success"] then
		--cclog("购买失败!")
		CommonFunc_CreateDialog(GameString.get("Public_MSG_PUR_FAIL"))
		return
	end
	
	CommonFunc_CreateDialog(GameString.get("Public_MSG_PUR_SUCC"))
	-- 更新挑战次数
	tbChallengeTimes.buy_times = tbChallengeTimes.buy_times + 1
	-- 更新可以挑战次数
	local times = tbChallengeTimes.buy_times + tbChallengeTimes.org_times - tbChallengeTimes.play_times
	local labelAltasTimes = CommonFunc_getLabelByName(rootNode, "labelAtlas_times", nil, true)
	labelAltasTimes:setStringValue(string.format("%d", times))
end

-- 挑战信息推送
local function Handle_req_gameRankChallengeInfo(resp)
	local tb = resp.infos
	if #(tb) <= 0 then
		return
	end
	
	for k, v in next, (tb) do
		-- 消息往前插入
		v.bIsSelf = false
		table.insert(tbMsgInfo, 1, v)
	end
	
	cclog("收到推送消息")
end

-- 领取奖励
local function Handle_req_gameRankGetReward(resp)
	if resp.result ~= common_result["common_success"] then
		--cclog("领取失败")
		return
	end
	
	local function reWardString(initStr,DateTb)
		for k,v in pairs(DateTb) do
			print()
			initStr = initStr..v.name.." "..v.amount.." "
		end
		return initStr
	end
	
	Toast.show( reWardString("领取奖励",ReWardDesc) )
	
	-- 冷却时间
	m_dt = GAMERANK_SCORE_PARAM4
	-- 奖励信息
	showRewardInfo(ModelPlayer.getPoint(), m_dt)
end

-- 挑战次数信息
NetSocket_registerHandler(NetMsgType["msg_notify_challenge_times_info"], notify_challenge_times_info, Handle_req_gameRankTimes)

-- 挑战次数信息
local function reqChallengeTimes()
	-- 挑战次数信息
	local tb = req_get_challenge_times_info()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_times_info"])
end
-- 挑战次数信息
EventCenter_subscribe(EventDef["ED_RANKGAME_TIMES"], reqChallengeTimes)
	
-- net 请求
local function netReq()
	-- 挑战次数信息
	reqChallengeTimes()
	-- 排位列表
	local tb = req_get_can_challenge_role()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_can_challenge_lists"]) 
	cclog("消息数量:"..LayerMainEnter.getMsgTipsNum())
	if LayerMainEnter.getMsgTipsNum() > 0 then
		--cclog("请求推送信息。。。")
		tb = req_get_be_challenged_info()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_info_list"])
		-- 消息数量清0
		LayerMainEnter.setMsgTipsNum(0)
	end
end

-- bIsSuccess
LayerGameRank.updateUI = function(bIsSuccess)
	if rootNode == nil then
		cclog("LayerGameRank == nil") 
		return 
	end	
	
	-- reload
	netReq()
	-- 自己发起的挑战, 更新推送消息
	cclog("更新自己的推送消息！")
end

-- 冷却时间
local function dateTimeCountdown(dt)
	if m_dt >= 1 then
		m_dt = m_dt - 1
	end
	if rootNode == nil then
		return
	end
	
	local labelDT = CommonFunc_getLabelByName(rootNode, "label_dt")
	if labelDT ~= nil then
		labelDT:setText(CommonFunc_secToString(m_dt))
	end	
	
	-- 领取奖励btn event
	local btnGetReward = rootNode:getChildByName("btn_getReward")
	tolua.cast(btnGetReward, "UIButton")
	setTipIcon("btn_getReward", m_dt)
	if m_dt > 0 then
		btnGetReward:setTouchEnabled(false)
		btnGetReward:loadTextureNormal("onlinereward_buttom_receive2.png")
	else
		btnGetReward:setTouchEnabled(true)
		btnGetReward:loadTextureNormal("onlinereward_buttom_receive3.png")
	end
end

-- 初始化静态UI
local function initUI()
	-- 关闭btn event
	local btnClose = rootNode:getChildByName("btn_close")
    btnClose:registerEventScript(btnCall)
	-- 购买挑战次数btn event
	local btnAdd = rootNode:getChildByName("btn_add")
    btnAdd:registerEventScript(btnCall)
	-- 领取奖励btn event
	local btnGetReward = rootNode:getChildByName("btn_getReward")
    btnGetReward:registerEventScript(btnCall)
	-- 查看技能
	local btnSkill = rootNode:getChildByName("btn_skill")
	btnSkill:registerEventScript(btnCall)
	-- 战斗记录btn_combatlog
	local btnCombatLog = rootNode:getChildByName("btn_combatlog")
	btnCombatLog:registerEventScript(btnCall)
	
	-- 挑战按钮
	local btnChallenge = CommonFunc_getButton("Rank_icon_02.png", "Rank_icon_04.png", "Rank_icon_04.png") 
	btnChallenge:setTag(m_challengeBtnTag)
	btnChallenge:setZOrder(20)
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
	btnChallenge:registerEventScript(btnActionCall)
	btnChallenge:setName("btn_challenge")
	rootNode:addChild(btnChallenge)
	
	-- 奖励信息
	showRewardInfo(ModelPlayer.getPoint(), m_dt)
	
	-- 领取奖励按钮
	local btnGetReward = CommonFunc_getNodeByName(rootNode, "btn_getReward", "UIButton")
	btnGetReward:registerEventScript(btnCall)
	
	-- 对手信息
	showCompeUI()
end
	
LayerGameRank.init = function(root)
	-- add gui
	m_schedule = nil
	rootNode = root
	if rootNode == nil then
		cclog("LayerGameRank init nil")
		return nil
	end
	
	initUI()
	netReq()
	
	m_schedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(dateTimeCountdown, 1.0, false)
	TipModule.onUI(root, "ui_gamerank")
	return rootNode
end

-- 获取奖励是否可以领取
LayerGameRank.getIsRewardCanGet = function()
	--Log("LayerGameRank.getIsRewardCanGet ********",tbChallengeTimes)
	if nil == tbChallengeTimes.buy_times or nil == tbChallengeTimes.org_times or nil == tbChallengeTimes.play_times then
		tbChallengeTimes.buy_times = 0
		tbChallengeTimes.org_times = 0
		tbChallengeTimes.play_times = 0
		return false
	end
	local times = tbChallengeTimes.buy_times  + tbChallengeTimes.org_times - tbChallengeTimes.play_times
	if (tonumber(m_dt) <= 0 or times > 0) and  CopyDelockLogic.judgeYNEnterById(LIMIT_RANK_GAME.copy_id)== true then
		return true
	end
	return false
end

LayerGameRank.purge = function()
	tbMsgInfo = {}
	LayerMainEnter.setMsgTipsNum(0)
	if m_schedule ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_schedule)
		m_schedule = nil
	end
	rootNode = nil
end

LayerGameRank.destroy = function()
	cclog("LayerGameRank destroy!")
	if m_schedule ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_schedule)
		m_schedule = nil
	end
	rootNode = nil
end

local function handleClearData()
	tbMsgInfo = {}
	LayerMainEnter.setMsgTipsNum(0)
	if m_schedule ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_schedule)
		m_schedule = nil
	end
	rootNode = nil
end

NetSocket_registerHandler(NetMsgType["msg_notify_can_challenge_lists"], notify_can_challenge_lists, Handle_req_gameRankList)
NetSocket_registerHandler(NetMsgType["msg_notify_buy_challenge_times_result"], notify_buy_challenge_times_result, Handle_req_gameRankBuyTimes)
NetSocket_registerHandler(NetMsgType["msg_notify_challenge_info_list"], notify_challenge_info_list, Handle_req_gameRankChallengeInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_get_challenge_rank_award_result"], notify_get_challenge_rank_award_result, Handle_req_gameRankGetReward)
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)


