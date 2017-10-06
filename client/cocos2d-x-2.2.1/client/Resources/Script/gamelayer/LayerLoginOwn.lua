----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-3-31
-- 描述：自有登录界面
----------------------------------------------------------------------
LayerLoginOwn = {}
LayerAbstract:extend(LayerLoginOwn)
local mEditBoxAccount = nil			-- 账号输入框
local mEditBoxPassword = nil		-- 密码输入框
local mAccount = ""					-- 账号
local mPassword = ""				-- 密码
local mRootView = nil
----------------------------------------------------------------------
-- 点击
LayerLoginOwn.onClick = function(widget)
	local widgetName = widget:getName()
	if "Button_register" == widgetName then			-- 注册按钮
		LayerLoginOwn.setEditBoxTouch()
		UIManager.push("UI_Register")
	elseif "Button_login" == widgetName then		-- 登录按钮
		mAccount = mEditBoxAccount:getText()
		mPassword = mEditBoxPassword:getText()
		if "" == mAccount or "" == mPassword then
			CommonFunc_CreateDialog(GameString.get("InputAccOrPass"))
			return	
		elseif mAccount == mPassword then
			CommonFunc_CreateDialog(GameString.get("AccAndPassNOSame"))
			return
		end	
		if false == LayerRegister.judgeAccountPassword(mAccount, mPassword) then
			return
		end
		loginDataCache.requestLogin(mAccount, mPassword)
	end
end

-- 设置账号和密码输入框点击
LayerLoginOwn.setEditBoxTouch = function(flag)
	if mRootView == nil then
		return
	end
	if flag then
		mEditBoxAccount:setTouchEnabled(true)
		mEditBoxPassword:setTouchEnabled(true)
	else
		mEditBoxAccount:setTouchEnabled(false)
		mEditBoxPassword:setTouchEnabled(false)
	end
end

----------------------------------------------------------------------
-- 初始化
LayerLoginOwn.init = function()
	local root = UIManager.findLayerByTag("UI_LoginOwn")
	mRootView = root
	setOnClickListenner("Button_register")
	setOnClickListenner("Button_login")
	--
	local loginPanel = root:getWidgetByName("LoginOwnPanel")
	loginPanel:setTouchEnabled(false)		-- 这个必须设置,否则输入框接受不到触摸事件
	-- 账号
	local accountBg = loginPanel:getChildByName("ImageView_account")
	mEditBoxAccount = CommonFunc_createCCEditBox(ccp(0.5, 0.5), ccp(120, 0), CCSizeMake(252, 36),"touming.png",
				4, 11, GameString.get("InputAccount"), kEditBoxInputModeSingleLine, kKeyboardReturnTypeDefault)
	accountBg:addRenderer(mEditBoxAccount, 10)
	-- 密码
	local passwordBg = loginPanel:getChildByName("ImageView_password")
	mEditBoxPassword = CommonFunc_createCCEditBox(ccp(0.5, 0.5), ccp(120, 0), CCSizeMake(252, 36), "touming.png",    
				5, 11, GameString.get("InputPass"), kEditBoxInputModeSingleLine, kKeyboardReturnTypeDefault)
	mEditBoxPassword:setInputFlag(kEditBoxInputFlagPassword)
	passwordBg:addRenderer(mEditBoxPassword, 10)
	-- 记住密码
	agreeCheckBox = tolua.cast(loginPanel:getChildByName("CheckBox_remember"), "UICheckBox")
	agreeCheckBox:setSelectedState(true)
	-- 版本号
	local versionLabel = CommonFunc_createUILabel(ccp(0.5, 0.5), ccp(545, 30), nil, 24, nil, "version:"..GAME_VERSION, nil, nil)
	loginPanel:addChild(versionLabel)
	-- 设置上次登录的账号和密码
	if loginDataCache.getAccount() ~= nil then
		local lastAccount = CCUserDefault:sharedUserDefault():getStringForKey("lastaccount")
		local lastPassword = CCUserDefault:sharedUserDefault():getStringForKey("password")
		if lastAccount ~= nil then
			mEditBoxAccount:setText(lastAccount)
		end
		if lastPassword ~= nil then
			mEditBoxPassword:setText(lastPassword)
		end 
	end
end

LayerLoginOwn.destroy = function()
	mRootView = nil
end

----------------------------------------------------------------------
-- 获取账号
LayerLoginOwn.getAccount = function()
	return mAccount
end
----------------------------------------------------------------------
-- 获取密码
LayerLoginOwn.getPassword = function()
	return mPassword
end
----------------------------------------------------------------------
-- 初始注册信息
local function handleRegisterInfo(data)
	if nil == mEditBoxAccount or nil == mEditBoxPassword then
		return
	end
	mEditBoxAccount:setText(data.account)
	mEditBoxPassword:setText(data.password)
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_REGISTER_SUCCESS"], handleRegisterInfo)

	

	
	
	
	
	
	