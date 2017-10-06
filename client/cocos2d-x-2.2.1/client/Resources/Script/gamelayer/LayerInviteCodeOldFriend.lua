----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-13
-- Brief:	好友邀请码(我要带人有好友)
----------------------------------------------------------------------
local mOldFriendLayerRoot = nil	-- 好友邀请码界面根节点

LayerInviteCodeOldFriend = {}
LayerAbstract:extend(LayerInviteCodeOldFriend)
--local mHelpRoleId = nil 		--保存发送的帮帮他的id			--有空让服务端改
local mReqBreakRoleId = nil 	--点击的请求断绝关系的Id
local mIndex = 1				--表示默认选中的好友
local mTempIndex = 1 			--表示上一次选中的id

--设置刚刚选中和现在选中的值
LayerInviteCodeOldFriend.setIndex = function() 
	mTempIndex = mIndex
end
---------------------------------------复制-------------------------------------
--复制功能
local function copyClick(types,widget)
	if types == "releaseUp" then
		local flag = ChannelProxy.copyString(LayerInviteCode.getInviteCodeInfo().code)
		if flag == true then
			Toast.Textstrokeshow(GameString.get("Public_invite_copy_succ"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		else
			Toast.Textstrokeshow(GameString.get("Public_invite_copy_Fail"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		end
	end
end
---------------------------------断绝关系-------------------------------------
--请求断绝关系
LayerInviteCodeOldFriend.requestBreak = function(roleId) 
	local tb = req_disengage()
	tb.type = 2
	tb.role_id = roleId						
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_disengage_result"])
end

--断绝关系
local function breakFriendClick(types,widget)
	if types == "releaseUp" then
		local widgetName = widget:getName()
		local index = tonumber( string.sub(widgetName,-1,-1))
		local temp =LayerInviteCode.getInviteCodeInfo().prentice_list[index]
		local roleId = temp.role_id
		mReqBreakRoleId = roleId
		--print("breakFriendClick****old*********",widgetName,index,Log(temp),roleId)
		
		local tb = req_disengage_check()
		tb.type = 2
		tb.role_id = roleId
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_disengage_check_result"])
	end
end

--获得点击的请求断绝关系的id
LayerInviteCodeOldFriend.requestBreakId = function() 
	return mReqBreakRoleId
end

--断绝关系后，更新我要邀请界面
LayerInviteCodeOldFriend.updateAfterBreak = function() 
	if mOldFriendLayerRoot == nil then
		return
	end
	LayerInviteCodeOldFriend.setContentUIByIndex()
end
---------------------------------------帮帮他-----------------------------------
--判断帮帮他按钮是否可以点击
LayerInviteCodeOldFriend.judgeCanClickHelp= function(friendInfo)
	local status = friendInfo.status 
	local temp = LayerInviteCode.getInviteCodeLel()
	if friendInfo.level > temp[#temp] then
		return false
	elseif status == help_status["help_req"] or status == help_status["help_none"] then
		return true
	else
		return false
	end
end

--判断帮帮他按钮tip，是否显示     
LayerInviteCodeOldFriend.judgeHelpTipVON = function(friendId) 
	local friendInfo = LayerInviteCode.getInviteCodeInfo().prentice_list 
	for key,value in pairs(friendInfo) do
		if friendId == value.role_id then
			if value.status == send_hp_status["send_hp_done"] then
				return true
			else
				return false
			end
		end
	end
	return false
end

--帮帮他
local function helpFriendClick(types,widget)
	if types == "releaseUp" then
		local widgetName = widget:getName()
		local index = tonumber( string.sub(widgetName,-1,-1))
		local temp =LayerInviteCode.getInviteCodeInfo().prentice_list[index]
		local tb = {}
		tb.role_id = temp.role_id
		tb.level = temp.level
		UIManager.push("UI_InviteCodeHelpItem",tb)
	end
end
-------------------------------------------领取奖励-------------------------------------------
--判断该好友的等级奖励可否领取(第几个好友，自己的等级，点击的领取等级)
local function judgeCanGetFriendLelReward(index,ownlel,lel)
	if index < 0 or index > #LayerInviteCode.getInviteCodeInfo().prentice_list then
		return
	end
	local status = 1		--表示是不可领(1)，可以领但是没有领(2)，领过了(3)
	tempTb = LayerInviteCode.getInviteCodeInfo().prentice_list[index].rewarded_list
	local temp = LayerInviteCode.getInviteCodeLel()
	
	local flag = false
	
	for key,value in pairs(tempTb) do
		if lel == value then
			flag =  true
			status = 3
		end
	end
	
	for key,value in pairs(temp) do
		if lel == value and ownlel >= value and flag == false then
			status = 2
			return true,status
		end
	end
	return false,status
end

--判断某个好友是否有可以领取的等级奖励(好友请求帮助)   有待改变？？？？？？？(待测试**********)
local function judgeTheFriendTip(index,curLel,friendId)
	local flag = false
	
	local tb = LayerInviteCode.getInviteCodeLel() 
	for key,value in pairs(tb) do
		local lelFlag,lelStatus = judgeCanGetFriendLelReward(index,curLel,value)
		--Log("判断标记啊***judgeTheFriendTip********",lelFlag,index,curLel,value)
		if lelFlag then
			flag = true
			return true
		end
	end
	
	local friendInfo = LayerInviteCode.getInviteCodeInfo().prentice_list 
	flag = LayerInviteCodeOldFriend.judgeHelpTipVON(friendId) 
	
	return flag
end

--点击Icon，领取奖励
local function getLelReward(types,widget)
	if types == "releaseUp" then
		local temp = LayerInviteCode.getInviteCodeInfo().prentice_list
		local widgetName = widget:getName()
		local str1 = tonumber(string.sub(widgetName,1,1))
		local str2 = string.sub(widgetName,-2,-1)
		
		if string.sub(str2,1,1) == "_" then
			str2 = string.sub(str2,-1,-1)
		end
		--Log("点击的情况***getLelReward********",str1,str2,widgetName,temp[str1])
		local friendId = temp[str1].role_id
		local lelReward = tonumber(str2)
		LayerInviteCodeOldFriend.reqGetlelReward(friendId,lelReward)	
		mTempIndex = mIndex
		mIndex = str1
		
	end
end
----------------------------------------点击头像触发的函数-----------------------------------------
--根据点击的头像位置，设置相应的信息
local function iconBgClick(types,widget)
	if types == "releaseUp" then
		local widgetName = widget:getName()
		local str1 = tonumber(string.sub(widgetName,-1,-1))
		mTempIndex = mIndex
		mIndex = str1
		LayerInviteCodeOldFriend.setContentUIByIndex()
	end
end
--------------------------------------设置刚进入时的信息--------------------------------------------------------
--加载不可领取的灰色遮罩
local function loadNoMayLingPanel(kuang,key)
	local layout = UILayout:create()
	layout:setName(string.format("Gray_%d", key))
	layout:setZOrder(2)
	layout:setBackGroundImage("icon_mask.png")
	layout:setSize(CCSizeMake(94,94))
	layout:setPosition(ccp(-47,-47))
	kuang:addChild(layout)
end

--設置待邀請時的列表信息
local function setEmptyFriendInfo(index,data)
	--Log("setEmptyFriendInfo**************",index)
	--断绝关系
	local breakFriend = tolua.cast(mOldFriendLayerRoot:getChildByName("breakFriendship"), "UIButton")	
	if breakFriend == nil then
		breakFriend = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("break_%d",mTempIndex)),"UIButton")	
	end
	breakFriend:setName(string.format("break_%d",index))
	
	--帮帮他
	local helpFriend = tolua.cast(mOldFriendLayerRoot:getChildByName("help"), "UIButton")	
	local helpTip = tolua.cast(mOldFriendLayerRoot:getChildByName("help_tip"),"UIImageView")
	if helpFriend == nil then
		helpFriend = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("help_%d",mTempIndex)), "UIButton")
	end
	helpFriend:setName(string.format("help_%d",index))
	
	for key,value in pairs(data) do
		--物品iCon
		local iconItem =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("item_%d",key)),"UIImageView")
		local iconItemTip =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("item_%d_tip",key)),"UIImageView")
		local iconItemYL = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("item_%d_yl",key)),"UIImageView")
		if iconItem == nil then
			 iconItem =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("%d_%d",mTempIndex,value.lel)),"UIImageView")
		end
		iconItem:setName(string.format("%d_%d",index,value.lel))
		iconItemYL:setVisible(false)
		iconItem = FightOver_addQuaIconByRewardId(value.id,iconItem,value.amount)
		--iconItem:setColor(ccc3(140, 140, 140))
		local gray =  tolua.cast(iconItem:getChildByName(string.format("Gray_%d",key)), "UIImageView") 
		if gray ~= nil then
			gray:removeFromParent()
		end
		loadNoMayLingPanel(iconItem,key)
		iconItemTip:setZOrder(9000000)
		iconItemTip:setVisible(false)
		LayerInviteCode.showParticle(iconItem,false)
	end
	
	--头像icon
	local icon =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("icon_%d",index)),"UIImageView")
	local iconTip =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("icon_%d_tip",index)),"UIImageView")
	--名字
	local nameLbl =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("friend_name_%d",index)),"UILabel")
	--断绝与帮帮他灰掉
	breakFriend:setTouchEnabled(false)
	helpFriend:setTouchEnabled(false)
	helpTip:setVisible(false)
	Lewis:spriteShaderEffect(helpFriend:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(breakFriend:getVirtualRenderer(),"buff_gray.fsh",true)
	--头像为待邀请，名字为空
	icon:loadTexture("invitation_modify_3.png")		
	iconTip:setVisible(false)
	nameLbl:setText("")
	
	--头像背景
	local iconBg = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("IconBg_%d",index)),"UIImageView")
	iconBg:setTouchEnabled(true)
	iconBg:registerEventScript(iconBgClick)
	local loadBar =tolua.cast(mOldFriendLayerRoot:getChildByName("LoadingBar_59"),"UILoadingBar")
	--设置进度条
	loadBar:setPercent(0)
end

--设置设置帮帮他按钮及提示(断绝关系)
local function setHelpAndHelpTip(friendInfo)
	--断绝关系
	local breakFriend = tolua.cast(mOldFriendLayerRoot:getChildByName("breakFriendship"), "UIButton")	
	if breakFriend == nil then
		breakFriend = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("break_%d",mTempIndex)),"UIButton")	
	end
	
	breakFriend:setTouchEnabled(true)
	Lewis:spriteShaderEffect(breakFriend:getVirtualRenderer(),"buff_gray.fsh",false)
	breakFriend:setName(string.format("break_%d",mIndex))
	breakFriend:registerEventScript(breakFriendClick)			--有待改变？？？？？？？
	
	--帮帮他
	local helpFriend = tolua.cast(mOldFriendLayerRoot:getChildByName("help"), "UIButton")	
	local helpTip = tolua.cast(mOldFriendLayerRoot:getChildByName("help_tip"),"UIImageView")
	if helpFriend == nil then
		helpFriend = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("help_%d",mTempIndex)), "UIButton")
	end
	helpFriend:setName(string.format("help_%d",mIndex))
	if LayerInviteCodeOldFriend.judgeCanClickHelp(friendInfo) == false then
		helpFriend:setTouchEnabled(false)
		Lewis:spriteShaderEffect(helpFriend:getVirtualRenderer(), "buff_gray.fsh", true)
		helpTip:setVisible(false)
	else
		helpFriend:setTouchEnabled(true)
		Lewis:spriteShaderEffect(helpFriend:getVirtualRenderer(), "buff_gray.fsh", false)
		helpFriend:registerEventScript(helpFriendClick)
		--print("tip标记是************",LayerInviteCodeOldFriend.judgeHelpTipVON(friendInfo.role_id))
		if LayerInviteCodeOldFriend.judgeHelpTipVON(friendInfo.role_id) == true then
			helpTip:setVisible(true)
		else
			helpTip:setVisible(false)
		end	
	end
end

--设置等级奖励和进度条(加载物品icon)(index表示第几个好友，data奖励信息表，friendInfo当前好友的信息)
local function setlelRewardItem(index,friendInfo,data)
	--进度条
	local loadBar =tolua.cast(mOldFriendLayerRoot:getChildByName("LoadingBar_59"),"UILoadingBar")
	--设置进度条
	percent = friendInfo.level/Invire_Code_Max_Lel*100
	if percent >100 then
		loadBar:setPercent(100)
	else
		loadBar:setPercent(percent)
	end
	for key,value in pairs(data) do
		--物品iCon
		local iconItem =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("item_%d",key)),"UIImageView")
		local iconItemTip =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("item_%d_tip",key)),"UIImageView")
		local iconItemYL = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("item_%d_yl",key)),"UIImageView")
		if iconItem == nil then
			 iconItem =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("%d_%d",mTempIndex,value.lel)),"UIImageView")
		end
		iconItem:setName(string.format("%d_%d",index,value.lel))
		iconItemTip:setZOrder(9000000)
		--复原原始效果
		--tip不显示
		iconItemTip:setVisible(false)
		iconItemYL:setVisible(false)
		--移除旋转效果
		LayerInviteCode.showParticle(iconItem, false)
		--移除灰色遮罩
		local gray =  tolua.cast(iconItem:getChildByName(string.format("Gray_%d",key)), "UIImageView") 
		if gray ~= nil then
			gray:removeFromParent()
		end
		
		local lelFlag,lelStatus = judgeCanGetFriendLelReward(index,friendInfo.level,value.lel)
		--print("物品提醒*********************",lelFlag,lelStatus,index,friendInfo.level,value.lel)
		if  lelFlag  == false then
			--奖励感叹号
			iconItemTip:setVisible(false)
			iconItem = FightOver_addQuaIconByRewardId(value.id,iconItem,value.amount)
			if lelStatus == 3 then		--领过了
				--iconItem:setColor(ccc3(255, 255, 255))
				iconItemYL:setVisible(true)
			elseif	lelStatus == 1 then						--不可领
				loadNoMayLingPanel(iconItem,key)
				iconItemYL:setVisible(false)
			end
		else
			iconItemTip:setVisible(true)
			iconItemYL:setVisible(false)
			iconItem = FightOver_addQuaIconByRewardId(value.id,iconItem,value.amount,getLelReward)
			iconItem:setTouchEnabled(true)
			--iconItem:setColor(ccc3(255, 255, 255))
			LayerInviteCode.showParticle(iconItem, true)
		end
	end
end

--设置空的头像和名字
local function setEmptyIconName(key)
	--头像icon
	local icon =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("icon_%d",key)),"UIImageView")
	local iconTip =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("icon_%d_tip",key)),"UIImageView")
	--名字
	local nameLbl =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("friend_name_%d",key)),"UILabel")
	icon:loadTexture("invitation_modify_3.png")		
	iconTip:setVisible(false)
	nameLbl:setText("")
end

--设置头像、名字
local function setIconName(friendInfo,key)
	
	--头像icon
	local icon =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("icon_%d",key)),"UIImageView")
	local iconTip =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("icon_%d_tip",key)),"UIImageView")
	--名字
	local nameLbl =tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("friend_name_%d",key)),"UILabel")
	--设置头像和名字
	nameLbl:setText(friendInfo.name)
	local iconPng = ModelPlayer.getProfessionIconByType(friendInfo.type,friendInfo.advanced_level) 
	icon:loadTexture(iconPng)	
	--设置头像tip
	if judgeTheFriendTip(key,friendInfo.level,friendInfo.role_id) then
		iconTip:setVisible(true)
	else
		iconTip:setVisible(false)
	end
	--print("icon tip标记是************",key,friendInfo.level,judgeTheFriendTip(key,friendInfo.level,friendInfo.role_id) )
end

--设置等级
local function setBgLvLbl(key)
	--头像背景
	local iconBg = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("IconBg_%d",key)),"UIImageView")
	iconBg:setTouchEnabled(true)
	--加载选中的背景
	if key == mIndex then
		iconBg:loadTexture("invitation_modify_2.png")
	else
		iconBg:loadTexture("invitation_modify_2n.png")				
	end
	iconBg:registerEventScript(iconBgClick)
		
	local tb = LayerInviteCode.getInviteCodeLel() 
	--设置进度条等级
	local widget = tolua.cast(mOldFriendLayerRoot:getChildByName(string.format("lev_%d",key)),"UILabel")
	widget:setText(GameString.get("Public_lel",tb[key]))
end

-------------------------------------根据点击的位置，设置信息---------------------------------------------------------
--设置四个好友的角色信息
LayerInviteCodeOldFriend.setContentUIByIndex = function()
	if mOldFriendLayerRoot == nil then
		return
	end
	--每个好友的奖励信息数据
	local tempData = LogicTable.getInviteCodeReward()
	local data ={}
	for k,v in pairs(tempData) do
		local ItemDate = LogicTable.getRewardItemRow(v.master_ids)
		ItemDate.amount = v.master_amounts
		ItemDate.lel = v.id
		ItemDate.index = k
		table.insert(data,ItemDate)
	end 
	--好友信息
	local temp = LayerInviteCode.getInviteCodeInfo().prentice_list --？？？？？？？？？？？？？？？？？？

	--设置没有选中的头像，加载对应的
	for key,value in pairs(data) do
		--设置没被选中的背景  --设置选中的背景和等级以及进度条
		setBgLvLbl(key)

		if key <= #temp then
			--设置头像、名字
			setIconName(temp[key],key)	
		else
			setEmptyIconName(key)
		end
	end
	
	if mIndex <= #temp then	
		--设置帮帮他按钮及提示（断绝）
		setHelpAndHelpTip(temp[mIndex])
		--设置等级奖励(加载物品icon)(进度条)
		setlelRewardItem(mIndex,temp[mIndex],data)
	else					--此处为一个好友都没有时,设置默认选中的等级奖励和帮帮他信息
		setEmptyFriendInfo(mIndex,data)
	end
	
end
-----------------------------------------初始化---------------------------
LayerInviteCodeOldFriend.init = function(rootView)
	mOldFriendLayerRoot = rootView
	if mOldFriendLayerRoot == nil then
		return
	end
	--邀请码
	local code = tolua.cast(mOldFriendLayerRoot:getChildByName("Label_code"),"UILabel")
	code:setText(LayerInviteCode.getInviteCodeInfo().code)
	--复制按钮
	local copy = tolua.cast(mOldFriendLayerRoot:getChildByName("copy"),"UIButton")
	copy:registerEventScript(copyClick)
	--设置界面中的好友信息
	LayerInviteCodeOldFriend.setContentUIByIndex()
end
-------------------------------------------销毁---------------------------
LayerInviteCodeOldFriend.destroy = function()
   mOldFriendLayerRoot = nil
   mReqBreakRoleId = nil
   LayerMore.showSocialContactTip()
   LayerMain.showMoreTip()
   mIndex = 1
   mTempIndex =1
end 
----------------------------------------界面中的一些提醒标志------------------------------
--判断所有的好友中，是否有等级奖励可以领取
local function judgeAllFriendHasTip()
	local temp = LayerInviteCode.getInviteCodeInfo().prentice_list
	local tempLel = LayerInviteCode.getInviteCodeLel()
	for key,value in pairs(temp) do
		for k,v in pairs(tempLel) do
			if judgeCanGetFriendLelReward(key,value.level,v) then
				return true
			end	
		end	
	end
	return false
end

--判断所有的好友中，是否有人请求帮忙
local function judgeAllFriendHasHelpTip()
	local temp = LayerInviteCode.getInviteCodeInfo().prentice_list
	for key,value in pairs(temp) do
		if value.status == 2 then
			return true
		end
	end
	return false
end

--整个界面的提醒标记
LayerInviteCodeOldFriend.judgeTipVON = function() 
	local showFlag = false
	if judgeAllFriendHasHelpTip()  then		--有好友请求帮助信息					
		showFlag = true
	end
	if judgeAllFriendHasTip() then			--判断所有的好友中，是否有等级奖励可以领取
		showFlag = true
	end
	--print("LayerInviteCodeOldFriend.judgeTipVON",judgeAllFriendHasHelpTip(),judgeAllFriendHasTip())
	return showFlag	
end
----------------------------------------请求领取等级奖励--------------------------------------------------
--请求领取等级奖励
LayerInviteCodeOldFriend.reqGetlelReward = function(newId,lel)
	local tb = req_master_level_reward()
	tb.prentice_id = newId
	tb.level = lel
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_master_level_reward_result"])
end 

--处理领取所带新人的等级奖励
local function handleNofityGetMasterReward(packet)
	--Log("处理领取所带新人的等级奖励*********",packet)
	if packet.result == common_result["common_success"] then
		local temp = LayerInviteCode.getInviteCodeInfo().prentice_list
		for key,value in pairs(temp) do
			if value.role_id == packet.prentice_id then
				table.insert(value.rewarded_list,packet.level)
			end
		end
		--Log("handleNofityGetMasterReward***",LayerInviteCode.getInviteCodeInfo().prentice_list)
		local lelRewardInfo = LogicTable.getInviteCodeRewardByLevel(packet.level)
		CommonFunc_showGetItemTip(lelRewardInfo.master_ids,lelRewardInfo.master_amounts)	
		
		--刷新界面？？？？？？？？？(有待修改)
		LayerInviteCodeOldFriend.setContentUIByIndex()	
		--设置社交按钮
		LayerMore.showSocialContactTip()
		LayerMain.showMoreTip()
		LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
	end
end
-------------------------------------------------在线通知，有人让我帮助----------------------------------------
--在线通知，有人让我帮助
local function handleNofityHasHelpReq(packet)
	--Log("在线通知，有人让我帮助***************",packet)
	local temp = LayerInviteCode.getInviteCodeInfo().prentice_list
	for key,value in pairs(temp) do
		if value.role_id == packet.prentice_id then
			value.status = send_hp_status["send_hp_done"]
		end
	end
	LayerInviteCodeOldFriend.setContentUIByIndex()
	--设置社交按钮
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
end
---------------------------------------12点的状态更新--------------------------------------------
--12点时，更新帮帮我的状态
LayerInviteCodeOldFriend.setHelpStatus = function()
	local temp =LayerInviteCode.getInviteCodeInfo().prentice_list
	for key,value in pairs(temp) do
		value.status = 1
	end
end
------------------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_master_level_reward_result"],notify_master_level_reward_result,handleNofityGetMasterReward)
NetSocket_registerHandler(NetMsgType["msg_notify_req_help_from_prentice"],notify_req_help_from_prentice,handleNofityHasHelpReq)

EventCenter_subscribe(EventDef["ED_INVITE_CODE_UPDATE"],LayerInviteCodeOldFriend.setContentUIByIndex)
------------------------------------------------------------------------------
