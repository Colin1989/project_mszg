----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-13
-- Brief:	好友邀请码界面
----------------------------------------------------------------------

local mInviteCodeLayerRoot = nil	-- 好友邀请码界面根节点
							
local m_selectedRadioBtn = nil		-- 选中的radio
local mpanelContent = nil 			-- 两个小界面的根节点
local mcurUIWidget = nil 			-- 当前展示的小界面(刚进入时)
local mcurChildTb = nil				-- 刚刚展示的小界面
local mClickWidget = nil			-- 刚刚点击的按钮
local pushFlag = false				-- 表示刚进入时的立即前往界面是否push过

LayerInviteCode = {}
LayerAbstract:extend(LayerInviteCode)

local m_tbRadioBtnInfo =
{
	{["normal"] ="text_woshixinren_n.png",["current"] = "text_woshixinren_h.png"},
	{["normal"] ="text_woyaoyaoqing_n.png",["current"] ="text_woyaoyaoqing_h.png"},
}

--设置点击切换按钮的图片
local function setSwitchBtnImg(sender)
	-- 已经选中
	if m_selectedRadioBtn == sender then
	    return
	end

	m_selectedRadioBtn = sender
	for k = 1, 2, 1 do 
		local btn = nil
		if k== 1 then
			btn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_new"), "UIButton")			--我是新人
		elseif k== 2 then
			btn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_invite"),"UIButton")
		end
		local nameImage = tolua.cast(btn:getChildByName("textImg"),"UIImageView")
		local pos = btn:getPosition()
		if btn ~= sender then
			btn:setBright(true)
			nameImage:loadTexture(m_tbRadioBtnInfo[k].normal)
			nameImage:setPosition(ccp(0,0 ))
		else
			btn:setBright(false)
			nameImage:loadTexture(m_tbRadioBtnInfo[k].current)
			nameImage:setPosition(ccp(0,-4))
		end	
	end
end
----------------------------------------------------------------------
LayerInviteCode.setJosnWidget = function(this,jsonFile)
	if mcurChildTb ~= nil then
		mcurChildTb.destroy()
		mpanelContent:removeAllChildren()
	end
	local contentView = GUIReader:shareReader():widgetFromJsonFile(jsonFile)
	contentView:setAnchorPoint(ccp(0.0,0.0))
	contentView:setPosition(ccp(0,0))
	mpanelContent:addChild(contentView)
	this.init(contentView)
	
	mcurChildTb = this
	return contentView
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickBtn(typeName, widget)
	
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		if mClickWidget == widget then
			return
		end
		-- mClickWidget = widget
		if weightName == "close" then				--关闭按钮
		
			UIManager.pop("UI_InviteCode")
		elseif weightName == "click_new" then		--我是新人
			mClickWidget = widget
			LayerInviteCode.setNewUI()
			setSwitchBtnImg(widget)
		elseif weightName == "click_invite" then	--我要带人
			if ModelPlayer.getLevel() < Invire_Code_Open_Lel then
				Toast.Textstrokeshow(GameString.get("Public_invite_open",Invire_Code_Open_Lel), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			else
				mClickWidget = widget
				setSwitchBtnImg(widget)
				LayerInviteCode.setOldUI()
			end
		end	
	end
end
----------------------------------------------------------------------
--加载我是新人UI
LayerInviteCode.setNewUI = function()
	if LayerInviteCode.judgeHasFriendInNew() == true then
		mcurUIWidget = LayerInviteCode.setJosnWidget(LayerInviteCodeNewFriend,"new_friend.json")
	else
		mcurUIWidget = LayerInviteCode.setJosnWidget(LayerInviteCodeNewNoFriend,"new_noFriend.json")
	end		
end
----------------------------------------------------------------------
--验证好友后，加载对应的UI
LayerInviteCode.setCheckUI = function()
	if mInviteCodeLayerRoot == nil then
		return
	end
	mcurUIWidget = LayerInviteCode.setJosnWidget(LayerInviteCodeNewFriend,"new_friend.json")
end 
----------------------------------------------------------------------
--加载邀请UI
LayerInviteCode.setOldUI = function()
	LayerInviteCode.setJosnWidget(LayerInviteCodeOldFriend,"old_friend.json")
end
----------------------------------------------------------------------
LayerInviteCode.init = function(rootView)
	mInviteCodeLayerRoot=UIManager.findLayerByTag("UI_InviteCode")
	mpanelContent = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("inviteCodeContent"),"UILayout")
	local closeBtn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("close"), "UIButton")			-- 关闭按钮
	closeBtn:registerEventScript(clickBtn)
	local newBtn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_new"), "UIButton")			--我是新人
	newBtn:registerEventScript(clickBtn)
	local inviteBtn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_invite"), "UIButton")	--我要带人
	inviteBtn:registerEventScript(clickBtn)
	-- local explainBtn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_explain"), "UIButton")	--我要带人
	-- explainBtn:registerEventScript(clickBtn)
	--设置刚进入时，默认选中的btn
	if ModelPlayer.getLevel()>= Invire_Code_Open_Lel or LayerInviteCode.getInviteCodeInfo().is_new_prentice_got > 0 then
		m_selectedRadioBtn = inviteBtn
		LayerInviteCode.setOldUI()
		local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
		nameImage:loadTexture(m_tbRadioBtnInfo[2].current)
	else
		m_selectedRadioBtn = newBtn
		LayerInviteCode.setNewUI()
		local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
		nameImage:loadTexture(m_tbRadioBtnInfo[1].current)
	end
	m_selectedRadioBtn:setBright(false)
end
----------------------------------------------------------------------
LayerInviteCode.destroy = function()
	mInviteCodeLayerRoot = nil
	if mcurChildTb == LayerInviteCodeNewNoFriend then
		LayerInviteCodeNewNoFriend.destroy()
	elseif mcurChildTb == LayerInviteCodeNewFriend then
		LayerInviteCodeNewFriend.destroy()
	elseif mcurChildTb == LayerInviteCodeOldFriend then
		LayerInviteCodeOldFriend.destroy()
	end  
	pushFlag = false
end 
----------------------------------------------------------
--判断我是新人标签页，有没有绑定好友
LayerInviteCode.judgeHasFriendInNew = function()
	--Log("LayerInviteCode.judgeHasFriendInNew*********",LayerInviteCode.getInviteCodeInfo().master.level)
	if LayerInviteCode.getInviteCodeInfo().master.level == 0 then
		return false
	else
		return true
	end
end
----------------------------------------------------------------------
--设置我是新人标签页，没有绑定好友
LayerInviteCode.setHasFriendInNew = function()
	LayerInviteCode.getInviteCodeInfo().master.level = 0
end
----------------------------------------------------------------------
--设置获取到邀请码后的邀请码
LayerInviteCode.setInviteCode = function(codes)
	LayerInviteCode.getInviteCodeInfo().code = codes
end
----------------------------------------------------------------------
--设置验证后的绑定好友信息
LayerInviteCode.setMasterInfo = function(info)
	LayerInviteCode.getInviteCodeInfo().master = info	
end
----------------------------------------------------------------------
--设置领取奖励后的奖励列表
LayerInviteCode.setRewardedInfo = function(id)
	local tb = LayerInviteCode.getInviteCodeInfo().rewarded_list 
	table.insert(tb,id)
end
----------------------------------------------------------------------
--判断邀请码Icon要不要显示提醒感叹号
LayerInviteCode.judgeHasTipInviteCode = function()
	local showFlag = false
	if LayerInviteCodeNewFriend.getTipFlag() then		-- 有好友帮我，或我有等级奖励时
		showFlag = true
	end
	if LayerInviteCodeOldFriend.judgeTipVON() then
		showFlag = true
	end
	--print("判断邀请码Icon要不要显示提醒感叹号",LayerInviteCodeNewFriend.getTipFlag(),LayerInviteCodeOldFriend.judgeTipVON())
	return showFlag
end
--------------------------------网络部分---------------------------------------------------
local mInviteCodeInfo = nil		--保存所有的当前角色的邀请码信息

--获取当前角色的邀请码信息
LayerInviteCode.getInviteCodeInfo = function()
	return mInviteCodeInfo
end

local mNewDay = true				-- 新的一天
local mDailyTimerFlag = false
-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	--12点到了之后，设置帮帮我和帮帮他的按钮
	--更新数据
	if LayerInviteCode.getInviteCodeInfo().master.level ~= 0 then
		LayerInviteCode.getInviteCodeInfo().master.status = 1
	end
	local temp = LayerInviteCode.getInviteCodeInfo()
	for key,value in pairs(temp.prentice_list) do
		value.status = 1
	end
	LayerInviteCodeNewFriend.setHelpTipFlag()
	LayerInviteCodeOldFriend.setHelpStatus()
	
	Log("12点，很重要啊**********好友邀请码定时器触发",LayerInviteCode.getInviteCodeInfo())
	EventCenter_post(EventDef["ED_INVITE_CODE_UPDATE"])
end

--刚进入时，通知邀请码的信息
local function handleNofityInviteCodeInfo(packet)
	--Log("刚进入时，通知邀请码的信息*********",packet)
	mInviteCodeInfo = packet
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end	

	if LayerInviteCode.getPushFlag() == false and loadingDoorForOpen.getOpenFlag() == true then
		LayerInviteCode.setPushFlag()
		LayerInviteCode.pushEnterInviteCodeUI()			--出现邀请码立即前往，加好友界面
	end
end

-- 处理请求断绝关系
local function handleNofityBreak(packet)
	--Log("处理请求断绝关系*********",packet)
	if packet.result == common_result["common_success"] then
		--要判断类型
		if packet.type == 2 then	--师傅与徒弟断
			local temp =LayerInviteCode.getInviteCodeInfo().prentice_list
			for key,value in pairs(temp) do
				if value.role_id == packet.role_id then
					table.remove(temp,key)
				end
			end
			LayerInviteCodeOldFriend.updateAfterBreak()
		else						--徒弟与师傅断
			LayerInviteCode.getInviteCodeInfo().master.level = 0
			
			local newBtn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_new"), "UIButton")			--我是新人
			local inviteBtn = tolua.cast(mInviteCodeLayerRoot:getWidgetByName("click_invite"), "UIButton")	--我要带人
			if m_selectedRadioBtn == newBtn then
				LayerInviteCode.setNewUI()
			end
		end
	end
end

--在线收到师傅与我断绝关系(通知我)
local function handleNofityLostMaster()
	--Log("在线收到我与师傅断绝关系*********",packet)
	LayerInviteCode.getInviteCodeInfo().master.level = 0
	if mInviteCodeLayerRoot == nil then
		return
	end
	if m_selectedRadioBtn == newBtn then
		LayerInviteCode.setNewUI()
	end
end

--在线收到我与师傅断绝关系（通知师傅）
local function handleNofityLostPrentice(packet)
	--Log("在线收到我与师傅断绝关系*********",packet)
	local temp =LayerInviteCode.getInviteCodeInfo().prentice_list
	for key,value in pairs(temp) do
		if value.role_id == packet.role_id then
			table.remove(temp,key)
		end
	end
	LayerInviteCodeOldFriend.updateAfterBreak()
end

--处理检查断绝关系
local function handleNotifyCheckBreak(packet)
	--Log("处理检查断绝关系*********",packet)
	if packet.result == common_result["common_success"] then
		local tempFun,roleId
		if packet.type == 1 then
			tempFun = LayerInviteCodeNewFriend.requestBreak
			roleId = LayerInviteCode.getInviteCodeInfo().master.role_id
		else
			tempFun = LayerInviteCodeOldFriend.requestBreak
			roleId = LayerInviteCodeOldFriend.requestBreakId()
		end
		local structConfirm =
		{
			strText = GameString.get("Public_invite_break_tip"),
			buttonCount = 2,
			buttonName = {GameString.get("sure"),GameString.get("cancle")},
			buttonEvent = {tempFun,nil}, --回调函数
			buttonEvent_Param = {roleId,nil} 
		}
		UIManager.push("UI_ComfirmDialog",structConfirm)
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_invite_code_info"],notify_invite_code_info,handleNofityInviteCodeInfo)
NetSocket_registerHandler(NetMsgType["msg_notify_disengage_result"],notify_disengage_result,handleNofityBreak)
NetSocket_registerHandler(NetMsgType["msg_notify_lost_master"],notify_lost_master,handleNofityLostMaster)
NetSocket_registerHandler(NetMsgType["msg_notify_lost_prentice"],notify_lost_prentice,handleNofityLostPrentice)
NetSocket_registerHandler(NetMsgType["msg_notify_disengage_check_result"],notify_disengage_check_result,handleNotifyCheckBreak)

-- 显示粒子
LayerInviteCode.showParticle = function(parent, show)
	if false == show then
		parent:getRenderer():removeChildByTag(1000, true)
		return
	end
	local node = CCNode:create()
	node:setTag(1000)
	parent:getRenderer():addChild(node)
	--
	local size = CCSizeMake(91, 91)
	local particle1 = CCParticleSystemQuad:create("skill_selected.plist")
	particle1:setPosition(ccp(-size.width/2, size.height/2))
	node:addChild(particle1, 100)
	
	local arr1 = CCArray:create()
	arr1:addObject(CCMoveBy:create(0.5, ccp(size.width, 0)))
	arr1:addObject(CCMoveBy:create(0.5, ccp(0, -size.height)))
	arr1:addObject(CCMoveBy:create(0.5, ccp(-size.width, 0)))
	arr1:addObject(CCMoveBy:create(0.5, ccp(0, size.height)))
	particle1:runAction(CCRepeatForever:create(CCSequence:create(arr1)))
	
	local particle2 = CCParticleSystemQuad:create("skill_selected.plist")
	node:addChild(particle2, 100)
	particle2:setPosition(ccp(size.width/2, -size.height/2))
	
	local arr2 = CCArray:create()
	arr2:addObject(CCMoveBy:create(0.5, ccp(-size.width, 0)))
	arr2:addObject(CCMoveBy:create(0.5, ccp(0, size.height)))
	arr2:addObject(CCMoveBy:create(0.5, ccp(size.width, 0)))
	arr2:addObject(CCMoveBy:create(0.5, ccp(0, -size.height)))
	particle2:runAction(CCRepeatForever:create(CCSequence:create(arr2)))
end

--获得各个等级{5,15,30,40}（成长礼包）
LayerInviteCode.getInviteCodeLel = function()
	local mFixLel = {}
	local temp = LogicTable.getInviteCodeReward()
	
	for key,value in pairs(temp) do
		table.insert(mFixLel,value.id)
	end
	return mFixLel
end

--获得各个等级{10,20,30,40}  （帮助奖励）
LayerInviteCode.getInviteCodeHelpLel = function()
	local mFixLel = {}
	local temp = LogicTable.getInviteHelpReward()
	for key,value in pairs(temp) do
		table.insert(mFixLel,value.id)
	end
	return mFixLel
end
------------------------------------------------------------
--为刚进入时，设置方法
local function setEnterInviteCode()
	--收到有人通过验证码后
	local function setTipsUI()
		setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json","mainbtn_rune")
		UIManager.push("UI_InviteCode")
	end
	local mainLayerRoot = UIManager.findLayerByTag("UI_Main")
	local function pushAction()	
		UIManager.push("UI_InviteCodeTip")
	end
	local action = CCSequence:createWithTwoActions(CCDelayTime:create(1.5),CCCallFuncN:create(pushAction))
	mainLayerRoot:runAction(action)
end

--出现离线收到加邀请码好友
LayerInviteCode.pushEnterInviteCodeUI = function()
	if LayerInviteCode.getInviteCodeInfo() ~= nil then 
		if LayerInviteCode.getInviteCodeInfo().is_new_prentice_got > 0 then
			setEnterInviteCode()
		end
	end
end

--判断有没有进入过（刚进入页面时的立即前往，加好友界面）
LayerInviteCode.getPushFlag = function()
	return pushFlag
end

LayerInviteCode.setPushFlag = function()
	pushFlag = true
end
