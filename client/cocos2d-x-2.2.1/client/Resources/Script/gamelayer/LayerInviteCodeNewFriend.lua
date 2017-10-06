----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-13
-- Brief:	好友邀请码(我是新人，验证界面)
----------------------------------------------------------------------
local mNewFriendLayerRoot = nil	-- 好友邀请码界面根节点

--更换角色后的清楚信息
local mHelpRewardTip = false		-- 好友帮助奖励提醒
local mLelRewardTipTb = {}			--等级奖励Tip flag

LayerInviteCodeNewFriend = {}

LayerAbstract:extend(LayerInviteCodeNewFriend)
----------------------------------------------------------------------
--根据当前等级，判断领取的是哪个级别的奖励
local function judgeReqLel()
	local mFixLel = LayerInviteCode.getInviteCodeHelpLel()
	for key,value in pairs(mFixLel) do
		if ModelPlayer.getLevel() <= value then
			--print("judgeReqLel*********",value)
			return value
		end
	end
	return Invire_Code_Open_Lel
end
----------------------------------------------------------------------
--领取奖励按钮
local function getRewardClick(types,widget)
	if "releaseUp" == types then
		local weightName = widget:getName()
		if weightName == "getReward" then				--领取奖励（好友帮助）按钮	
			LayerInviteCodeNewFriend.requestGetHelpReward(judgeReqLel())
			Lewis:spriteShaderEffect(widget:getVirtualRenderer(), "buff_gray.fsh", true)
			local helpTip = tolua.cast(mNewFriendLayerRoot:getChildByName("getReward_tip"), "UIImageView")
			helpTip:setVisible(false)
		elseif weightName == "breakRelationship" then	--断绝关系
			local roleId = LayerInviteCode.getInviteCodeInfo().master.role_id
			LayerInviteCodeNewFriend.requestCheckBreak(roleId)	
		elseif weightName == "help" then				--帮帮我
			LayerInviteCodeNewFriend.requestHelp(widget:getTag()/100)						
			Lewis:spriteShaderEffect(widget:getVirtualRenderer(), "buff_gray.fsh", true)
		else											--领取等级奖励
			LayerInviteCodeNewFriend.requestGetLelReward(widget:getTag()/100)					
		end 
	end
end
----------------------------------------------------------------------
--设置绑定的好友信息
local function setFriendInfo()
	local friendInfo = LayerInviteCode.getInviteCodeInfo().master
	--根据角色的进阶等级和类型，设置头像
	local iconPng = ModelPlayer.getProfessionIconByType(friendInfo.type,friendInfo.advanced_level) 
	local Icon = tolua.cast(mNewFriendLayerRoot:getChildByName("icon"), "UIImageView")
	Icon:loadTexture(iconPng)				
	local name = tolua.cast(mNewFriendLayerRoot:getChildByName("name_lbl"), "UILabel")
	name:setText(friendInfo.name)
	local level = tolua.cast(mNewFriendLayerRoot:getChildByName("lel_lbl"), "UILabel")
	level:setText(friendInfo.level)
	local power = tolua.cast(mNewFriendLayerRoot:getChildByName("power_lbl"), "UILabel")
	power:setText(friendInfo.battle_power)
end
---------------------------------------------------------------------------------
--设置领取等级奖励视图
local function setGetRewardLevelInfo()
	local scrollReward = tolua.cast(mNewFriendLayerRoot:getChildByName("ScrollView_49"), "UIScrollView")
	
	local tempData = LogicTable.getInviteCodeReward()
	local data ={}
	for k,v in pairs(tempData) do
		local ItemDate = LogicTable.getRewardItemRow(v.pretince_ids)
		ItemDate.amount = v.prentince_amounts
		ItemDate.lel = v.id
		table.insert(data,ItemDate)
	end 
	-- 创建奖励单元格
	local function createReawardCell(ItemDate)
		-- 背景
		local cellBg = UIImageView:create()
		cellBg:loadTexture("public2_bg_05.png")
		cellBg:setScale9Enabled(true)
		cellBg:setTouchEnabled(true)
		cellBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		cellBg:setSize(CCSizeMake(133, 152))
		--[[
		-- 奖励名称
		local nameLabel = CommonFunc_getLabel(ItemDate.name, 20, ccc3(255, 255, 255))
		nameLabel:setPosition(ccp(0, 56))
		cellBg:addChild(nameLabel)
		]]--
		--奖励感叹号
		local tip = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(51,53),CCSizeMake(38, 38),"qipaogantanhao.png","tip",5)
		local YLImg = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(0,0),CCSizeMake(82, 81),"uiiteminfo_yilingqu.png","yl",20)
		YLImg:setVisible(false)
		local icon = nil
		local lelFlag,lelStatus = LayerInviteCodeNewFriend.judgeCanGetLelRewardById(ItemDate.lel)
		if lelFlag == false then
			cellBg:setTouchEnabled(false)
			icon = FightOver_addQuaIconByRewardId(ItemDate.id,nil,ItemDate.amount)
			tip:setVisible(false)
			table.insert(mLelRewardTipTb,false)
			if lelStatus == 3 then		--领过了
				icon:setColor(ccc3(255, 255, 255))
				LayerInviteCode.showParticle(icon, false)
				YLImg:setVisible(true)
			elseif	lelStatus == 1 then						--不可领
				icon:setColor(ccc3(140, 140, 140))
				YLImg:setVisible(false)
			end
		else
			cellBg:setTouchEnabled(true)
			icon = FightOver_addQuaIconByRewardId(ItemDate.id,nil,ItemDate.amount,getRewardClick)
			tip:setVisible(true)
			YLImg:setVisible(false)
			table.insert(mLelRewardTipTb,true)
			icon:setColor(ccc3(255, 255, 255))
			LayerInviteCode.showParticle(icon, true)
		end
		icon:addChild(tip)
		icon:addChild(YLImg)
		icon:setTag(ItemDate.lel *100)
		cellBg:addChild(icon)
		icon:setPosition(ccp(0,13))
		-- 领取等级
		local lelLabel = CommonFunc_getLabel(GameString.get("Public_lel",ItemDate.lel), 20, ccc3(255, 255, 255))
		lelLabel:setPosition(ccp(-1, -56))
		cellBg:addChild(lelLabel)
		return cellBg
	end
	UIEasyScrollView:create(scrollReward,data,createReawardCell,4, true,8,4,true)	
end
----------------------------------------------------------------------
--设置帮帮我按钮
LayerInviteCodeNewFriend.setHelpBtn = function()
	if mNewFriendLayerRoot == nil then
		return
	end
	--帮帮我（每日可使用一次）
	local help = tolua.cast(mNewFriendLayerRoot:getChildByName("help"), "UIButton")
	if LayerInviteCodeNewFriend.judgeCanClickHelp() == false then
		help:setTouchEnabled(false)
		Lewis:spriteShaderEffect(help:getVirtualRenderer(), "buff_gray.fsh", true)
	else
		help:setTouchEnabled(true)
		Lewis:spriteShaderEffect(help:getVirtualRenderer(), "buff_gray.fsh", false)
		help:registerEventScript(getRewardClick)
	end
end
--------------------------------------------------------
--设置领取帮助奖励
local function setHelpGetRewardBtn()
	if mNewFriendLayerRoot == nil then
		return
	end
	local helpReward = tolua.cast(mNewFriendLayerRoot:getChildByName("getReward"), "UIButton")
	helpReward:registerEventScript(getRewardClick)
	local helpTip = tolua.cast(mNewFriendLayerRoot:getChildByName("getReward_tip"), "UIImageView")
	
	if LayerInviteCodeNewFriend.judgeCanGetReceivedHelp() == true then
		mHelpRewardTip = true
		Lewis:spriteShaderEffect(helpReward:getVirtualRenderer(), "buff_gray.fsh", false)
		helpReward:setTouchEnabled(true)
		helpReward:registerEventScript(getRewardClick)
		helpTip:setVisible(true)	
	else
		Lewis:spriteShaderEffect(helpReward:getVirtualRenderer(), "buff_gray.fsh", true)
		helpReward:setTouchEnabled(false)
		helpTip:setVisible(false)
	end
end
----------------------------------------------------------------------
LayerInviteCodeNewFriend.init = function(rootView)
	mNewFriendLayerRoot = rootView
	
	mLelRewardTipTb = {}
	
	--断绝关系
	local breakRelationship = tolua.cast(mNewFriendLayerRoot:getChildByName("breakRelationship"), "UIButton")
	breakRelationship:registerEventScript(getRewardClick)
	--帮帮我
	LayerInviteCodeNewFriend.setHelpBtn()
	--领取奖励（好友帮助）按钮
	setHelpGetRewardBtn()
	
	setGetRewardLevelInfo()
	setFriendInfo()
end
----------------------------------------------------------------------
LayerInviteCodeNewFriend.destroy = function()
   mNewFriendLayerRoot = nil  
end 

LayerInviteCodeNewFriend.purge = function()
	mHelpRewardTip = false  
end 

--判断是否有等级奖励
local function judgeLelTipTb()
--[[
	for key,value in pairs(mLelRewardTipTb) do
		if value then
			return true
		end
	end
	return false
	]]--
	local tempData = LogicTable.getInviteCodeReward()
	--Log("***********",tempData)
	for key,value in pairs(tempData) do
		 if LayerInviteCodeNewFriend.judgeCanGetLelRewardById(value.id) then
			return true
		 end	
	end
	return false
end

--获得当前界面的tip标记
LayerInviteCodeNewFriend.getTipFlag = function()
	local showFlag = false
	if LayerInviteCodeNewFriend.judgeCanGetReceivedHelp() then	--此处为刚收到消息，还未进入界面时
		mHelpRewardTip = true
	end
	if mHelpRewardTip then
		showFlag = true
	end
	if judgeLelTipTb() then
		showFlag = true
	end
	--print("LayerInviteCodeNewFriend.getTipFlag",LayerInviteCodeNewFriend.judgeCanGetReceivedHelp(),mHelpRewardTip,judgeLelTipTb())
	return showFlag
end

-----------------------------------网络部分----------------------------------------
--请求领取帮帮我的奖励
LayerInviteCodeNewFriend.requestGetHelpReward = function(lel)
	local tb = req_get_help_reward()
	tb.level = lel
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_get_help_reward_result"])
end

--处理领取帮帮我奖励
local function handleNofityGetHelpReward(packet)
	Log("处理领取帮帮我奖励*********",packet)
	if packet.result == common_result["common_success"] then
		local helpRewardInfo = LogicTable.getInviteHelpRewardByLevel(packet.level)
		CommonFunc_showGetItemTip(helpRewardInfo.ids,helpRewardInfo.amounts)
		LayerInviteCode.getInviteCodeInfo().master.status = help_status["help_got"]
		mHelpRewardTip = false
		--设置社交按钮
		LayerMore.showSocialContactTip()
		LayerMain.showMoreTip()
		LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
	end
end
-------------------------------------------------------------------------------------------------
--请求帮帮我
LayerInviteCodeNewFriend.requestHelp= function(lel)
	local tb = req_master_help()
	tb.level = lel
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_master_help_result"])
end

--处理发送请求帮帮我的结果
local function handleNofityMasterHelpResult(packet)
	Log("处理发送请求帮帮我的结果*********",packet)
	if packet.result == common_result["common_success"] then
		Toast.Textstrokeshow(GameString.get("Public_invite_help_Reward_send"), ccc3(255,255,255), ccc3(0,0,0), 30)
	end

end
-----------------------------------------------------------------------------------------------------------
--请求领取等级奖励
LayerInviteCodeNewFriend.requestGetLelReward = function(lel)
	local tb = req_prentice_level_reward()
	tb.level = lel
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_prentice_level_reward_result"])
end

--处理自己的等级奖励
local function handleNofityGetPrenticeReward(packet)
	Log("处理自己的等级奖励*********",packet)
	if packet.result == common_result["common_success"] then
		local lelRewardInfo = LogicTable.getInviteCodeRewardByLevel(packet.level)
		mLelRewardTipTb = {}
		LayerInviteCode.setRewardedInfo(packet.level)
		CommonFunc_showGetItemTip(lelRewardInfo.pretince_ids,lelRewardInfo.prentince_amounts)	
		--刷新视图
		setGetRewardLevelInfo()
		--设置社交按钮
		LayerMore.showSocialContactTip()
		LayerMain.showMoreTip()
		LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
	end
end
-----------------------------------------------------------------------------------------------
--请求断绝关系
LayerInviteCodeNewFriend.requestBreak = function(roleId)
	local tb = req_disengage()
	tb.type = 1
	tb.role_id = roleId
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_disengage_result"])
end
-----------------------------------------------------------------------------------------------
--请求检查断绝关系
LayerInviteCodeNewFriend.requestCheckBreak = function(roleId)
	local tb = req_disengage_check()
	tb.type = 1
	tb.role_id = roleId
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_disengage_check_result"])
end
----------------------------------------------------------------------------
--在线收到好友的帮忙
local function handleNofityHelpFromMaster(packet)
	Log("在线收到好友的帮忙*********",packet)
	--print("在线收到好友的帮忙id*********",packet.master_id)
	mHelpRewardTip = true
	LayerInviteCode.getInviteCodeInfo().master.status = help_status["help_doing"]
	setHelpGetRewardBtn()
	--设置社交按钮
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
end

-------------------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_prentice_level_reward_result"],notify_prentice_level_reward_result,handleNofityGetPrenticeReward)
NetSocket_registerHandler(NetMsgType["msg_notify_master_help_result"],notify_master_help_result,handleNofityMasterHelpResult)
NetSocket_registerHandler(NetMsgType["msg_notify_get_help_reward_result"],notify_get_help_reward_result,handleNofityGetHelpReward)
NetSocket_registerHandler(NetMsgType["msg_notify_give_help_from_master"],notify_give_help_from_master,handleNofityHelpFromMaster)


EventCenter_subscribe(EventDef["ED_INVITE_CODE_UPDATE"],LayerInviteCodeNewFriend.setHelpBtn)





------------------------------------------------------------------------
--设置好友帮助奖励提醒
LayerInviteCodeNewFriend.setHelpTipFlag= function()
	LayerInviteCode.getInviteCodeInfo().master.status = 1
	mHelpRewardTip = false
end

--判断是否可以点击帮助
LayerInviteCodeNewFriend.judgeCanClickHelp= function()
	local status = LayerInviteCode.getInviteCodeInfo().master.status 
	 local  temp = LayerInviteCode.getInviteCodeLel()
	if ModelPlayer.getLevel() > temp[#temp] then
		return false
	elseif  status == send_hp_status["send_hp_none"]  then
		return true
	else
		return false
	end
end

--判断是否可以领取帮助奖励
LayerInviteCodeNewFriend.judgeCanGetReceivedHelp= function()
	local status = LayerInviteCode.getInviteCodeInfo().master.status 
	if status == help_status["help_doing"] then
		return true
	else
		return false
	end
end

--判断奖励id(等级)是否在已经领过的奖励表里面
local function judgeIdYNIList(id)
	local rewarded_list = LayerInviteCode.getInviteCodeInfo().rewarded_list
	for key,value in pairs(rewarded_list) do
		if tonumber(id) == tonumber(value) then
			return true
		end
	end
	return false
end

--判断奖励是否可以领取(即在等级够的情况下，是否已经领取过了)
LayerInviteCodeNewFriend.judgeCanGetLelRewardById= function(id)
	local masterInfo = LayerInviteCode.getInviteCodeInfo().master
	if masterInfo.level == 0 then
		return
	end
	local mFixLel = LayerInviteCode.getInviteCodeLel()
	for key,value in pairs(mFixLel) do
		if id == value  then
			if ModelPlayer.getLevel() >= value and judgeIdYNIList(id) == false then
				return true,2
			elseif judgeIdYNIList(id) == true then
				return false,3
			else
				return false,1
			end
		end
	end
end


