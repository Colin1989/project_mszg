----------------------------------------------------------------------
-- Author:	李慧琴
-- Date:	2014-10-10
-- Brief:	进入主页时，邀请码帮帮加好友提醒
----------------------------------------------------------------------
local mLayerRoot = nil

LayerInviteCodeTip= {}
LayerAbstract:extend(LayerInviteCodeTip)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeTip")
	end
end
----------------------------------------------------------------------
-- 点击前往按钮
local function clickGoBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeTip")
		setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json","mainbtn_rune")
		UIManager.push("UI_InviteCode")
	end
end
----------------------------------------------------------------------
-- 点击加为好友按钮
local function clickAddBtn(typeName, widget)
	if "releaseUp" == typeName then
		local friend_id  --如果徒弟已经请求为加好友，发送同意请求   --如果徒弟没请求加为好友，发送加好友请求
		local tempList =  LayerInviteCode.getInviteCodeInfo().prentice_list
		if #tempList > 0 then
			friend_id = tempList[1].role_id
		end
		FriendDataCache.add_search(friend_id)
		
		UIManager.pop("UI_InviteCodeTip")		--?????		
	end
end
----------------------------------------------------------------------
-- 初始化
LayerInviteCodeTip.init = function(bundle)
	mLayerRoot = UIManager.findLayerByTag("UI_InviteCodeTip")
	-- 关闭按钮
	local closeBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 前往按钮
	local goBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_go"), "UIButton")
	goBtn:registerEventScript(clickGoBtn)
	-- 点击加为好友按钮
	local addBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_add"), "UIButton")
	addBtn:registerEventScript(clickAddBtn)
end
----------------------------------------------------------------------
-- 销毁
LayerInviteCodeTip.destroy = function()
	mLayerRoot = nil
end
----------------------------------------------------------------------
