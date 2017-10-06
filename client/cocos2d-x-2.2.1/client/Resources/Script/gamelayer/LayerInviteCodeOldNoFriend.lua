----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-13
-- Brief:	好友邀请码(我要带人，没有好友)
----------------------------------------------------------------------
local mOldNoLayerRoot = nil		-- 好友邀请码界面根节点
local mCodeTipFlag = false		-- 获取邀请码后的tip				

LayerInviteCodeOldNoFriend = {}
LayerAbstract:extend(LayerInviteCodeOldNoFriend)
----------------------------------------------------------------------
--设置邀请者邀请好友后的等级奖励
LayerInviteCodeOldNoFriend.showInviteFriendLelGift = function()
	local scrollReward = tolua.cast(mOldNoLayerRoot:getChildByName("ScrollView_reward"), "UIScrollView")
	local tempData = LogicTable.getInviteCodeReward()
	local data ={}
	for k,v in pairs(tempData) do
		local ItemDate = LogicTable.getRewardItemRow(v.master_ids)
		ItemDate.amount = v.master_amounts
		ItemDate.lel = v.id
		table.insert(data,ItemDate)
	end 
	-- 创建奖励单元格
	local function createReawardCell(ItemDate)
		-- 背景
		local cellBg = UIImageView:create()
		cellBg:loadTexture("touming.png")
		cellBg:setScale9Enabled(true)
		cellBg:setTouchEnabled(true)
		cellBg:setTag(ItemDate.id *100)
		cellBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		cellBg:setSize(CCSizeMake(133, 136))
		icon = FightOver_addQuaIconByRewardId(ItemDate.id,nil,ItemDate.amount)
		cellBg:addChild(icon)
		icon:setPosition(ccp(0,13))
		-- 领取等级
		local lelLabel = CommonFunc_getLabel(GameString.get("Public_lel",ItemDate.lel), 20, ccc3(255, 255, 255))
		lelLabel:setPosition(ccp(-1, -56))
		cellBg:addChild(lelLabel)
		return cellBg
	end
	UIEasyScrollView:create(scrollReward,data,createReawardCell,4, true,0,4,true)	
end

local function getInviteCodeClick(typeName, widget)
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		if weightName == "getInviteCode" then				--验证按钮
			LayerInviteCodeOldNoFriend.requestGetInviteCode()	
		end
	end
end
----------------------------------------------------------------------
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
-------------------------------------------------------------------------
--根据有没有邀请码，设置btn
local function setInviteBtn()
	local mFixLel = LayerInviteCode.getInviteCodeLel()
	--邀请按钮
	local inviteBtn = tolua.cast(mOldNoLayerRoot:getChildByName("getInviteCode"),"UIButton")
	--显示邀请码
	local lbl = tolua.cast(inviteBtn:getChildByName("Label_503"), "UILabel")
	--点击获取邀请码图片
	local img = tolua.cast(inviteBtn:getChildByName("ImageView_267"), "UIImageView")
	--等级
	local atlas = tolua.cast(inviteBtn:getChildByName("LabelAtlas_403"),"UILabelAtlas")
	--感叹号提示
	local codeTip = tolua.cast(mOldNoLayerRoot:getChildByName("codeTip"), "UIImageView")
	--复制按钮
	--local copyReward = tolua.cast(mOldNoLayerRoot:getChildByName("Button_copy"), "UIButton")
	--copyReward:registerEventScript(copyClick)
	--邀请码文字提示
	local text = tolua.cast(mOldNoLayerRoot:getChildByName("Label_text"),"UILabel")
	codeTip:setVisible(mCodeTipFlag)
	if LayerInviteCode.getInviteCodeInfo().code == "" then
		text:setText(GameString.get("Public_invite_text1"))
		if ModelPlayer.getLevel() >= mFixLel[1] then
			inviteBtn:setTouchEnabled(true)
			Lewis:spriteShaderEffect(inviteBtn:getVirtualRenderer(), "buff_gray.fsh", false)
			inviteBtn:registerEventScript(getInviteCodeClick)
		else
			inviteBtn:setTouchEnabled(false)
			Lewis:spriteShaderEffect(inviteBtn:getVirtualRenderer(), "buff_gray.fsh", true)
		end
		lbl:setVisible(false)
		img:setVisible(true)
		atlas:setVisible(true)
		atlas:setProperty(Invire_Code_Open_Lel,"labelatlasimg.png", 24, 32, "0")
		--copyReward:setTouchEnabled(false)
		--copyReward:setVisible(false)
	else
		text:setText(GameString.get("Public_invite_text2"))
		--inviteBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(inviteBtn:getVirtualRenderer(), "buff_gray.fsh", false)
		lbl:setVisible(true)
		lbl:setText(LayerInviteCode.getInviteCodeInfo().code)
		img:setVisible(false)
		atlas:setVisible(false)	
		
		inviteBtn:setTouchEnabled(true)
		inviteBtn:registerEventScript(copyClick)
		--copyReward:setTouchEnabled(true)
		--copyReward:setVisible(true)
	end
end
---------------------------------------------------------------------
--点击礼包的方法
local function giftBagClick(typeName, widget)
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		UIManager.push("UI_InviteCodeGift",widget:getTag())
	end
end
---------------------------------------------------------------------
--设置邀请成功奖励
local function setCheckgift()
	local scrollReward = tolua.cast(mOldNoLayerRoot:getChildByName("ScrollView_gift"), "UIScrollView")
	local tempData ={LogicTable.getGiftBagRow(Invite_Code_Master_Gift_id)}
	local data ={}
	for k,v in pairs(tempData) do
		local ItemDate = v
		table.insert(data,ItemDate)
	end 
	-- 创建奖励单元格
	local function createReawardCell(ItemDate)
		-- 背景
		local cellBg = UIImageView:create()
		cellBg:loadTexture(ItemDate.icon)
		cellBg:setTouchEnabled(true)
		cellBg:setTag(ItemDate.id)
		cellBg:registerEventScript(giftBagClick)
		return cellBg
	end
	UIEasyScrollView:create(scrollReward,data,createReawardCell,1, true,0,1,true)
end
----------------------------------------------------------------------
LayerInviteCodeOldNoFriend.init = function(rootView)

	mOldNoLayerRoot = rootView
	
	setInviteBtn()
	setCheckgift()
	LayerInviteCodeOldNoFriend.showInviteFriendLelGift()
end
----------------------------------------------------------------------
LayerInviteCodeOldNoFriend.destroy = function()
   mOldNoLayerRoot = nil
   mCodeTipFlag = false	
   LayerInviteCodeOldFriend.setNewInviteCodeFalse()
end 
----------------------------------------------------------------------
--获取感叹号标志
LayerInviteCodeOldNoFriend.getTipFlag = function()
	 return mCodeTipFlag 	
end 
----------------------------------------------------------------------
--获取感叹号标志
LayerInviteCodeOldNoFriend.setTipFlag = function()
	 mCodeTipFlag = true	
end 
----------------------------------------网络部分---------------------------------------
--请求获取邀请码
LayerInviteCodeOldNoFriend.requestGetInviteCode = function()
	local tb = req_invitation_code()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_req_invitation_code_result"])
end

-- 处理获取邀请码的结果
local function handleNofityRequestInviteCode(packet)
	Log("处理获取邀请码的结果*********",packet)
	if packet.result == common_result["common_success"] then
		mInviteCode = packet.code
		
		local structConfirm =
		{
			strText = GameString.get("Public_invite_get_code",mInviteCode),
			buttonCount = 1,
			buttonName = {GameString.get("sure")},
			buttonEvent = {nil}, --回调函数
			buttonEvent_Param = {nil} 
		}
		UIManager.push("UI_ComfirmDialog",structConfirm)
		
		LayerInviteCode.setInviteCode(packet.code)
		mCodeTipFlag = true
		setInviteBtn()	
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_req_invitation_code_result"],notify_req_invitation_code_result,handleNofityRequestInviteCode)

EventCenter_subscribe(EventDef["ED_LVUP_INVITE_CODE_NEW"],LayerInviteCodeOldNoFriend.setTipFlag)


	--[[
		-- 奖励名称
		local nameLabel = CommonFunc_getLabel(ItemDate.name, 20, ccc3(255, 255, 255))
		nameLabel:setPosition(ccp(0, 56))
		cellBg:addChild(nameLabel)
		]]--







