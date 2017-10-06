----------------------------------------------------------------------
-- Author:	李慧琴
-- Date:	2014-10-10
-- Brief:	四格漫画前输入邀请码
----------------------------------------------------------------------
local mLayerRoot = nil
local mEditorBoxName		--验证码输入框
local mCheckFlag = 2		--表示验证码是否正确
local mCode					--输入的验证码

LayerInviteCodeInput = {}
LayerAbstract:extend(LayerInviteCodeInput)
----------------------------------------------------------------------
-- 点击验证按钮
local function clickCheckBtn(typeName,widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeInput")	
	--[[
		if mEditorBoxName:getText() == nil or mEditorBoxName:getText() == "" then 
			return
		end
		LayerInviteCodeNewNoFriend.requestVerfy(mEditorBoxName:getText())	
	]]--
	end
end
----------------------------------------------------------------------
-- 跳过按钮
local function clickJumpBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeInput")	
	end
end
----------------------------------------------验证码---------------------------------------------------
--设置验证的结果
LayerInviteCodeInput.setCheckFlag = function(temp)
	mCheckFlag = temp
	flag = mLayerRoot:getWidgetByName("flag")
	tolua.cast(flag,"UIImageView")
	flag:setVisible(true)
	if temp == 1 then			--成功
		flag:loadTexture("tick.png")
		mCode = mEditorBoxName:getText()
	else						--失败
		flag:loadTexture("public_xx.png")
	end
end

--获得验证的结果
LayerInviteCodeInput.getCheckFlag = function(temp)
	return mCheckFlag,mCode
end

--设置输入验证码
local function setEditBox()
	local function check(eventType)
	--print("个数",string.match(mEditorBoxName:getText(),"^[A-Za-z0-9]+$"),Calculate_Str_len(mEditorBoxName:getText()))
		if eventType == "ended" then
			if mEditorBoxName:getText() == nil or mEditorBoxName:getText() == "" then 
				return
			end
			if string.match(mEditorBoxName:getText(),"^[A-Za-z0-9]+$") == nil or Calculate_Str_len(mEditorBoxName:getText()) < 11 then
				Toast.show(GameString.get("Public_invite_verify_fail"))
				LayerInviteCodeInput.setCheckFlag(2)
				return
			end
			LayerInviteCodeNewNoFriend.requestVerfy(mEditorBoxName:getText())	
		end
	end
	local bg =mLayerRoot:getWidgetByName("codeBg")
	tolua.cast(bg,"UIImageView")
	
	local flag = mLayerRoot:getWidgetByName("flag")
	tolua.cast(flag,"UIImageView")
	flag:setVisible(false)
	--输入框
	mEditorBoxName = CommonFunc_createCCEditBox(ccp(0.5,0.5),ccp(0,0), CCSizeMake(250,39),"touming.png",
				4,11,"",kEditBoxInputModeSingleLine,kKeyboardReturnTypeDefault)
	mEditorBoxName:setTouchEnabled(true)
	mEditorBoxName:setPlaceHolder(GameString.get("Public_invite_text3"))
	bg:addRenderer(mEditorBoxName,10)
	mEditorBoxName:registerScriptEditBoxHandler(check)
end
------------------------------------------------------------------------------
-- 初始化
LayerInviteCodeInput.init = function(bundle)

	mLayerRoot = UIManager.findLayerByTag("UI_InviteCodeInput")
	-- 验证按钮
	local checkBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_check"), "UIButton")
	checkBtn:registerEventScript(clickCheckBtn)
	-- 跳过按钮
	local jumpBtn = tolua.cast(mLayerRoot:getWidgetByName("Button_jump"), "UIButton")
	jumpBtn:registerEventScript(clickJumpBtn)
	
	--增加输入框
	setEditBox()
end
----------------------------------------------------------------------
-- 销毁
LayerInviteCodeInput.destroy = function()
	mLayerRoot = nil
end
----------------------------------------------------------------------
--[[
--验证验证码是否正确
local function check(eventType)
	if eventType == "ended" then
		LayerInviteCodeNewNoFriend.requestVerfy(mEditorBoxName:getText())
	end
end
]]--
