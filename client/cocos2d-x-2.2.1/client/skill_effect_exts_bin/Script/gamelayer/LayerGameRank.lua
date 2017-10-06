--/**
-- *  @Brief: 竞技场
-- *  @Created by fjut on 14-03-12
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerGameRank = {}
local rootNode = nil

-- 我的排名
local myRank = 0
-- 玩家挑战次数信息
local tbChallengeTimes = {}
-- 挑战玩家信息
local tbChallengerInfo = {}
-- 点击挑战玩家信息
local tbOneChallengerInfo = {}
-- 推送消息
local tbMsgInfo = {}

-- json file
local guiJsonFile = "GameRank_1.ExportJson"
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
 
 -- 动态UI
local function loadDynamicUI()
	--
end

local function getBIsSelf(info)
	if info.role_id == ModelPlayer.id then
		return true
	end
	
	return false
end

-- 图片点击响应
local function imgCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	cclog("LayerGameRankChoice imgcall: "..sender:getName())
	
	local name = sender:getName()
	for k, value in next, (tbChallengerInfo) do
		--cclog(name..k..tbImg[k])
		if name == tbImg[k] and value.role_id ~= ModelPlayer.id then
			-- 显示挑战按钮
			local btnChallenge = CommonFunc_getNodeByName(rootNode, "btn_challenge", "UIButton")
			btnChallenge:setVisible(true)
			btnChallenge:setTouchEnabled(true)
			btnChallenge:setPosition(ccp(sender:getParent():getPosition().x+130, sender:getParent():getPosition().y))
			tbOneChallengerInfo = value
			break
		end
	end
end

local function dialogSureCall()
	local tb = req_buy_challenge_times()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_buy_challenge_times_result"]) 
end

-- 购买次数
local function buyTimes()
	-- 购买一次花费钻石
	local costDiaNum = math.pow(2, (tbChallengeTimes.buy_times + 1))
	local diaMsg = 
	{
		strText = string.format(GameString.get("GameRank_BUY_TIMES",  costDiaNum, 1)),
		buttonCount = 2,
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
	-- 关闭
	if sender:getName() == "btn_close" then
		LayerMain.switchPannel(LayerGameRankChoice)
		
	-- 购买挑战次数请求reg
	elseif sender:getName() == "btn_add" then 
		buyTimes()
	-- 领取奖励请求	
	elseif sender:getName() == "btn_getReward" then 
		cclog("btn_getReward")
	end
end

--- 请求进去竞技场返回
local function Handle_EnterJJc(resp)
	cclog("进入竞技场消息返回", resp.result)
	if resp.result == 1 then 
		FightDateCache.initGameDate(resp.map, resp.game_id)	--初始化战斗数据
		UIManager.destroyAllUI()
		StartLoading()
		CopyDateCache.GameType = "jjc"	--竞技场类型战斗
	end
end

-- 挑战按钮call
local function btnchallengeCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	-- 可以挑战次数
	local times = tbChallengeTimes.buy_times + tbChallengeTimes.org_times - tbChallengeTimes.play_times
	if times <= 0 then
		buyTimes()
		return
	end
	-- 要挑战的玩家信息
	cclog(tbOneChallengerInfo.rank.." "..tbOneChallengerInfo.name.." "..tbOneChallengerInfo.level.." "..tbOneChallengerInfo.power)
				
	--请求进入竞技场
	NetSocket_registerHandler(NetMsgType["msg_notify_challenge_other_player_result"], notify_challenge_other_player_result(), Handle_EnterJJc)
	local tb = req_challenge_other_player()
	tb.role_id = tbOneChallengerInfo.role_id	 
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_other_player_result"])
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

local function onTouchBegin(clickType, sender)
	-- 挑战按钮
	local btnChallenge = CommonFunc_getNodeByName(rootNode, "btn_challenge", "UIButton")
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
end

-- show 消息推送scrollview
local function showMsgScrollView(tb)
	if tb == nil or #tb <= 0 then
		return
	end

	local cellOffsetPosX = 30
	local scrollViewMsg = CommonFunc_getNodeByName(rootNode, "scrollView_msg", "UIScrollView")
	scrollViewMsg:removeAllChildren()
	
	for k, value in next, (tb) do
		local strText = GameString.get("GameRank_MSG_FAIL") 
		local color = ccc3(255, 0, 0)
		if value.result == game_result["game_win"] then 
			color = ccc3(255, 255, 255)
			strText = GameString.get("GameRank_MSG_SUCESS")
		end
		local label = CommonFunc_getLabel(GameString.get("GameRank_MSG_TIPS", value.name, strText), nil, color)
		label:setAnchorPoint(ccp(0, 0.5))
		scrollViewMsg:setInnerContainerSize(CCSize(scrollViewMsg:getSize().width, (#tb)*label:getContentSize().height))
		local h = label:getContentSize().height*0.5 + label:getContentSize().height*(k-1)
		label:setPosition(ccp(cellOffsetPosX, h))
		scrollViewMsg:addChild(label)
	end
end

-- 初始化静态UI
local function initUI()
	-- 图片点击Event
	for i = 1, #tbImg, 1 do
		local img = rootNode:getChildByName(tbImg[i])
		img:registerEventScript(imgCall)
	end
	-- 关闭btn event
	local btnClose = rootNode:getChildByName("btn_close")
    btnClose:registerEventScript(btnCall)
	-- 购买挑战次数btn event
	local btnAdd = rootNode:getChildByName("btn_add")
    btnAdd:registerEventScript(btnCall)
	-- 领取奖励btn event
	local btnGetReward = rootNode:getChildByName("btn_getReward")
    btnGetReward:registerEventScript(btnCall)
	-- 推送消息
	local sliderMsg = CommonFunc_getNodeByName(rootNode, "slider_msg", "UISlider")
	sliderMsg:setPercent(0)
	local scrollViewMsg = CommonFunc_getNodeByName(rootNode, "scrollView_msg", "UIScrollView")
	scrollViewMsg:registerEventScript(function(typename, widget) 
						local scrollViewInnerCon = scrollViewMsg:getInnerContainer()
						local InnerHei = scrollViewInnerCon:getSize().height
						local InnerPosY = scrollViewInnerCon:getPosition().y
						local scrollHei = scrollViewMsg:getSize().height
						local scrollPosY = scrollViewMsg:getPosition().y
						-- cclog
						--cclog("InnerHei="..InnerHei.." InnerPosY="..InnerPosY.." scrollHei="..scrollHei.." scrollPosY="..scrollPosY)
						
						
						if "scrolling" == typename then
							cclog("scrolling")
							local Ratio = math.abs(InnerPosY)/(InnerHei-scrollHei)*100
							sliderMsg:setPercent(100 - Ratio)
						end
					end)
	--scrollViewMsg:setBounceEnabled(true)
	-- show 消息推送scrollview
	showMsgScrollView(tbMsgInfo)
	
	-- 挑战按钮
	local btnChallenge = CommonFunc_getNodeByName(rootNode, "btn_challenge", "UIButton")
	--btnChallenge:loadTextureNormal("sureback.png")
	btnChallenge:setVisible(false)
	btnChallenge:setTouchEnabled(false)
	btnChallenge:registerEventScript(btnchallengeCall)
	-- 
	rootNode:registerEventScript(onTouchBegin)
end

local function Handle_req_gameRankList(resp)
	-- 当前自己排名
	
	-- 排位列表
	for k, value in next, (resp.infos) do
		cclog(k.." "..value.rank.." "..value.name.." "..value.level.." "..value.power)
		-- 头像
		local ImgHead = CommonFunc_getNodeByName(rootNode, tbImg[k], "UIImageView")
		ImgHead:loadTexture(ModelPlayer.getRoleInitDetailMessageById(value.type).heroicon)
		-- 排位
		local labelNo = CommonFunc_getLabelByName(rootNode, tbNo[k])
		labelNo:setText(string.format("NO.%d", value.rank))
		-- 昵称
		local labelNick = CommonFunc_getLabelByName(rootNode, tbNick[k])
		labelNick:setText(value.name)
		-- 等级
		local labelLv = CommonFunc_getLabelByName(rootNode, tbLv[k])
		labelLv:setText(string.format("%d", value.level))
		-- 战力
		local labelFight = CommonFunc_getLabelByName(rootNode, tbFight[k])
		labelFight:setText(string.format("%d", value.power))
		if value.role_id == ModelPlayer.id then
			myRank = value.rank
		end
	end
	
	tbChallengerInfo = resp.infos
	
	-- 当前自己排名
	local labelAltasTimes = CommonFunc_getLabelByName(rootNode, "labelAtlas_rank", nil, true)
	labelAltasTimes:setStringValue(string.format("%d", myRank))
end

-- 获取挑战次数信息
local function Handle_req_gameRankTimes(resp)
	cclog("获取挑战次数信息:"..resp.buy_times.." "..resp.org_times.." "..resp.play_times)
	-- 可以挑战次数
	local times = resp.buy_times + resp.org_times - resp.play_times
	local labelAltasTimes = CommonFunc_getLabelByName(rootNode, "labelAtlas_times", nil, true)
	labelAltasTimes:setStringValue(string.format("%d", times))
	-- 缓存
	tbChallengeTimes = resp
end

-- 购买挑战次数
local function Handle_req_gameRankBuyTimes(resp)
	if resp.result ~= common_result["common_success"] then
		return
	end

	-- 更新挑战次数
	tbChallengeTimes.buy_times = tbChallengeTimes.buy_times + 1
	-- 更新可以挑战次数
	local times = tbChallengeTimes.buy_times + tbChallengeTimes.org_times - tbChallengeTimes.play_times
	local labelAltasTimes = CommonFunc_getLabelByName(rootNode, "labelAtlas_times", nil, true)
	labelAltasTimes:setStringValue(string.format("%d", times))
end

-- 挑战信息推送
local function Handle_req_gameRankChallengeInfo(resp)
	local tbMsg = resp.infos
	if #tbMsg <= 0 then
		return
	end

	showMsgScrollView(tbMsg)
end

-- net 请求
local function netReq()
	-- 排位列表
	NetSocket_registerHandler(NetMsgType["msg_notify_can_challenge_lists"], notify_can_challenge_lists(), Handle_req_gameRankList)
	local tb = req_get_can_challenge_role()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_can_challenge_lists"]) 
	-- 挑战次数信息
	NetSocket_registerHandler(NetMsgType["msg_notify_challenge_times_info"], notify_challenge_times_info(), Handle_req_gameRankTimes)
	tb = req_get_challenge_times_info()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_times_info"])
	-- 购买挑战次数请求reg
	NetSocket_registerHandler(NetMsgType["msg_notify_buy_challenge_times_result"], notify_buy_challenge_times_result(), Handle_req_gameRankBuyTimes)
	-- 推送挑战信息reg
	NetSocket_registerHandler(NetMsgType["msg_notify_challenge_info_list"], notify_challenge_info_list(), Handle_req_gameRankChallengeInfo)
	if LayerMain.getMsgNum() > 0 then
		cclog("请求推送信息。。。")
		-- 消息数量清0
		LayerMain.setMsgNum(0)
		tb = req_get_be_challenged_info()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_info_list"])
	end
end
	
LayerGameRank.init = function()
	-- add gui
	rootNode = GUIReader:shareReader():widgetFromJsonFile(guiJsonFile)
	if rootNode == nil then
		cclog("LayerGameRank init nil") 
		return nil
	end	

	initUI()
	netReq()
	
	return rootNode
end











