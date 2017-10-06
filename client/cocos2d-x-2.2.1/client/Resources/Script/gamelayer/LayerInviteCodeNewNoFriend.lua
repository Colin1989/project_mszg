----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-13
-- Brief:	好友邀请码(我是新人，未验证界面)
----------------------------------------------------------------------
local mNewNoFriendLayerRoot = nil	-- 好友邀请码界面根节点
							
LayerInviteCodeNewNoFriend = {}
LayerAbstract:extend(LayerInviteCodeNewNoFriend)
local editorBoxName			--输入框
---------------------------------------------------------------------
local function checkClick(typeName, widget)
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		if weightName == "check" then				--验证按钮
			if editorBoxName:getText() == nil or editorBoxName:getText() == "" then 
				return
			end
			--print("********输入的值是*********",editorBoxName:getText())
			LayerInviteCodeNewNoFriend.requestCheck(editorBoxName:getText())
			LayerInviteCodeNewNoFriend.setEnterMode(1)	
		end
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
--设置邀请码验证奖励
local function setCheckgift()
	local scrollReward = tolua.cast(mNewNoFriendLayerRoot:getChildByName("ScrollView_check"), "UIScrollView")
	
	local giftInfo = LogicTable.getGiftBagRow(Invite_Code_Prentince_Gift_id)
	local tempData =giftInfo.reward_item_ids
	local data ={}
	for k,v in pairs(tempData) do
		local ItemDate = LogicTable.getRewardItemRow(v) 
		ItemDate.amounts = giftInfo.reward_item_amounts[k]
		table.insert(data,ItemDate)
	end 
	-- 创建奖励单元格
	local function createReawardCell(ItemDate)
		local cellBg = UIImageView:create()
		cellBg:loadTexture("touming.png")
		cellBg:setScale9Enabled(true)
		cellBg:setTouchEnabled(true)
		cellBg:setTag(ItemDate.id *100)
		cellBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		cellBg:setSize(CCSizeMake(133, 122))
		icon = FightOver_addQuaIconByRewardId(ItemDate.id,nil,tonumber(ItemDate.amounts))
		cellBg:addChild(icon)
		icon:setPosition(ccp(0,13))
		return cellBg
	end
	UIEasyScrollView:create(scrollReward,data,createReawardCell,4, true,0,4,true)
end
---------------------------------------------------------------------
--设置成长等级奖励
local function setLevelUI()
	local scrollReward = tolua.cast(mNewNoFriendLayerRoot:getChildByName("ScrollView_level"), "UIScrollView")
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
		cellBg:setSize(CCSizeMake(133, 128))
		icon = FightOver_addQuaIconByRewardId(ItemDate.id,nil,ItemDate.amount)
		cellBg:addChild(icon)
		icon:setPosition(ccp(0,20))
		-- 领取等级
		local lelLabel = CommonFunc_getLabel(GameString.get("Public_lel",ItemDate.lel), 20, ccc3(255, 255, 255))
		lelLabel:setPosition(ccp(-1, -40))
		cellBg:addChild(lelLabel)
		return cellBg
	end
	UIEasyScrollView:create(scrollReward,data,createReawardCell,4, true,0,4,true)	
end
----------------------------------------------------------------------
LayerInviteCodeNewNoFriend.init = function(rootView)
	
	mNewNoFriendLayerRoot = rootView
	local checkBtn = tolua.cast(rootView:getChildByName("check"), "UIButton")			-- 验证
	if ModelPlayer.getLevel() >= Invire_Code_Open_Lel then
		checkBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(checkBtn:getVirtualRenderer(), "buff_gray.fsh", true)
	else
		checkBtn:setTouchEnabled(true)
		Lewis:spriteShaderEffect(checkBtn:getVirtualRenderer(), "buff_gray.fsh", false)
		checkBtn:registerEventScript(checkClick)
	end

	local bg =  tolua.cast(mNewNoFriendLayerRoot:getChildByName("ImageView_184"), "UIImageView")	
	--输入框
	editorBoxName = CommonFunc_createCCEditBox(ccp(0.5,0.5),ccp(0,0), CCSizeMake(250,40),"touming.png",
				4,11,"",kEditBoxInputModeSingleLine,kKeyboardReturnTypeDefault)
	editorBoxName:setTouchEnabled(true)
	bg:addRenderer(editorBoxName,10)		
	
	setCheckgift()
	setLevelUI()
end
----------------------------------------------------------------------
LayerInviteCodeNewNoFriend.destroy = function()
   mNewNoFriendLayerRoot = nil
end 
---------------------------------------验证验证码------------------------------------------------
--请求验证
LayerInviteCodeNewNoFriend.requestCheck = function(str)
	local tb = req_input_invite_code()
	tb.code = str
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_input_invite_code_result"])
end 

local mTemp = 1		--(1为验证码界面进入,2为创建角色进入)

--设置进入的方式
LayerInviteCodeNewNoFriend.setEnterMode = function(temp)
	mTemp = temp
end 

-- 处理请求验证邀请码
local function handleNofityRequestCheck(packet)
	Log("处理请求验证邀请码*********",packet)
	if packet.result == common_result["common_success"] then
		LayerInviteCode.setMasterInfo(packet.master)	
		if mTemp == 1 then
			LayerInviteCode.setCheckUI()
			local structConfirm =
			{
				strText = GameString.get("Public_invite_addFriend"),
				buttonCount = 2,
				buttonName = {GameString.get("sure"),GameString.get("cancle")},
				buttonEvent = {FriendDataCache.add_search,nil}, --回调函数
				buttonEvent_Param = {packet.master.role_id,nil} 
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)	
		else
			--Toast.Textstrokeshow(GameString.get("Public_invite_success"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		end
	end
end
----------------------------------验证验证码是否正确-----------------------------------------
--请求验证
LayerInviteCodeNewNoFriend.requestVerfy = function(str)
	local tb = req_verify_invite_code()
	tb.code = str
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_verify_invite_code_result"])
end 

--处理验证验证码
local function handleNofityVerifyInviteCode(packet)
	if packet.result == common_result["common_success"] then
		Toast.Textstrokeshow(GameString.get("Public_invite_verify_success"), ccc3(255,255,255), ccc3(0,0,0), 30)
		--LayerRoleChoice.setCheckFlag(1)
		LayerInviteCodeInput.setCheckFlag(1)
		LayerInviteCodeNewNoFriend.setEnterMode(2)
	else
		Toast.Textstrokeshow(GameString.get("Public_invite_verify_fail"), ccc3(255,255,255), ccc3(0,0,0), 30)
		--LayerRoleChoice.setCheckFlag(2)
		LayerInviteCodeInput.setCheckFlag(2)
	end
end
------------------------------------------------------------------------------------
NetSocket_registerHandler(NetMsgType["msg_notify_input_invite_code_result"],notify_input_invite_code_result,handleNofityRequestCheck)
NetSocket_registerHandler(NetMsgType["msg_notify_verify_invite_code_result"],notify_verify_invite_code_result,handleNofityVerifyInviteCode)




