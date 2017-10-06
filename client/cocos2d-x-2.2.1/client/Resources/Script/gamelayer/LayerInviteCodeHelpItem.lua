----------------------------------------------------------------------
-- Author:	李慧琴
-- Date:	2014-10-10
-- Brief:	邀请码帮帮奖励展示
----------------------------------------------------------------------
local mLayerRoot = nil
local mRoleTb 

LayerInviteCodeHelpItem = {}
LayerAbstract:extend(LayerInviteCodeHelpItem)
----------------------------------------------------------------------
-- 点击取消按钮
local function clickCancleBtn(typeName,widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeHelpItem")
		LayerInviteCodeOldFriend.setIndex()
		--设置界面中的好友信息
		LayerInviteCodeOldFriend.setContentUIByIndex()	
	end
end
----------------------------------------------------------------------
-- 点击确认按钮
local function clickSureBtn(typeName,widget)
	if "releaseUp" == typeName then
		widget:setTouchEnabled(false)
		Lewis:spriteShaderEffect(widget:getVirtualRenderer(), "buff_gray.fsh", true)
		LayerInviteCodeHelpItem.requestHelpPre(mRoleTb.role_id)
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- 根据等级，判断应该帮助的等级
local function judgeHelpLel()
	local mFixLel = LayerInviteCode.getInviteCodeHelpLel()
	for key,value in pairs(mFixLel) do
		if mRoleTb.level <= value then
			print("judgeHelpLel*********",value)
			return value
		end
	end
	return Invire_Code_Open_Lel
end
------------------------------------------------
-- 设置帮助他的奖励
local function setHelpItem()
	--local item = tolua.cast(mLayerRoot:getWidgetByName("item"), "UIImageView")
	--item:loadTexture("touming.png")
	--根据等级，获得要帮助的奖励信息
	local tb = LogicTable.getInviteHelpRewardByLevel(judgeHelpLel())
	local item = FightOver_addQuaIconByRewardId(tb.ids,nil,tb.amounts)
	mLayerRoot:addWidget(item)
	item:setPosition(ccp(320,507))
	
end
----------------------------------------------------------------------
-- 初始化
LayerInviteCodeHelpItem.init = function(bundle)
	mRoleTb = bundle
	mLayerRoot = UIManager.findLayerByTag("UI_InviteCodeHelpItem")
	-- 确认按钮
	local sureBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_sure"), "UIButton")
	sureBtn:registerEventScript(clickSureBtn)
	-- 取消按钮
	local cancleBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_cancle"), "UIButton")
	cancleBtn:registerEventScript(clickCancleBtn)
	
	setHelpItem()
end
----------------------------------------------------------------------
-- 销毁
LayerInviteCodeHelpItem.destroy = function()
	mLayerRoot = nil
end
-------------------------------------------------请求帮帮新人-----------------------------------------
--请求帮帮新人
LayerInviteCodeHelpItem.requestHelpPre = function(id)
	local tb = req_give_help()
	tb.prentice_id = id
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_give_help_result"])
end

-- 处理给予帮助的结果
local function handleNofityGiveHelp(packet)
	Log("处理给予帮助的结果*********",packet)
	if packet.result == common_result["common_success"] then
	
		for key,value in pairs(LayerInviteCode.getInviteCodeInfo().prentice_list) do
			if value.role_id == mRoleTb.role_id then
				value.status = send_hp_status["send_hp_got"]
			end
		end	
		Toast.Textstrokeshow(GameString.get("Public_invite_help_send"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		
		LayerInviteCodeOldFriend.setIndex()
		--设置界面中的好友信息
		LayerInviteCodeOldFriend.setContentUIByIndex()	
		
		--设置社交按钮
		LayerMore.showSocialContactTip()
		LayerMain.showMoreTip()
		LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
		
		UIManager.pop("UI_InviteCodeHelpItem")
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_give_help_result"],notify_give_help_result,handleNofityGiveHelp)