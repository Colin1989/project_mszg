----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-3-31
-- 描述：注册界面
----------------------------------------------------------------------
LayerRegister = {}
LayerAbstract:extend(LayerRegister)
local mRootView = nil
local mEditBoxAccount = nil				-- 账号输入框
local mEditBoxPassword = nil			-- 密码输入框
local mEditBoxAgainPassword = nil		-- 确认密码输入框
local mCheckBoxAgree = nil				-- 同意协议选择框
local mAccount = ""						-- 账号
local mPassword = ""					-- 密码
local rootNode = nil
----------------------------------------------------------------------
-- 判断账号和密码的格式:账号支持5-11位;密码支持5-11位,只支持数字或字母;账号首字符为字母
LayerRegister.judgeAccountPassword = function(account, password)
	-- 检测账号首字符是否为字母
    local charHead = account:sub(1, 1)
    if not ((charHead >= "A" and charHead <= "Z") or (charHead >= "a" and charHead <= "z")) then
        Toast.show(GameString.get("AccountFormat"))
        return false
    end
	local leng = string.len(account)
    -- 检测是否包含中文字(或特殊字符),账号长度限制
    if leng < 5 or leng > 11 or nil == string.match(account,"^[A-Za-z0-9]+$") then
        Toast.show(GameString.get("AccountFormat"))
		return false
    end
	-- 密码长度限制,不能有中文字(或特殊字符)
	local leng = string.len(password)
	if leng < 5 or leng > 11 or nil == string.match(account,"^[A-Za-z0-9]+$") then
		Toast.show(GameString.get("PasswordFormat"))
		return false
	end
	return true
end

----------------------------------------------------------------------
-- 移除加载中
LayerRegister.removeLoading = function()
	if rootNode == nil then
		return
	end
	rootNode:removeAllChildrenWithCleanup(true)
	rootNode = nil
end

----------------------------------------------------------------------
-- 显示加载中
local function runLoading()
	if rootNode == nil then
		return
	end
	local winSize = CCDirector:sharedDirector():getWinSize()
	-- 背景
	local backgroundSprite = CCSprite:create("touming.png")
	backgroundSprite:setAnchorPoint(ccp(0.5, 0.5))
	backgroundSprite:setPosition(ccp(winSize.width/2, winSize.height/2))
	rootNode:addChild(backgroundSprite)
	-- 图片
	local tipSprite = CCSprite:create("text_jiazai.png")
	tipSprite:setPosition(ccp(winSize.width/2 - 40, winSize.height/2))
	rootNode:addChild(tipSprite)
	-- 点
	for i=1, 3 do
		local pointSpite = CCSprite:create("text_dian.png")
		pointSpite:setPosition(ccp(winSize.width/2 + 80 + (i-1)*25, winSize.height/2))
		rootNode:addChild(pointSpite)
	end
end

----------------------------------------------------------------------
-- 点击
LayerRegister.onClick = function(widget)
	local widgetName = widget:getName()
	if "Button_close" == widgetName then			-- 关闭按钮
		LayerLoginOwn.setEditBoxTouch(true)
		UIManager.pop("UI_Register")
	elseif "Button_register" == widgetName then 	-- 注册按钮
		mAccount = mEditBoxAccount:getText()
		mPassword = mEditBoxPassword:getText()
		local againPassword = mEditBoxAgainPassword:getText()
		if "" == mAccount or "" == mPassword then
			CommonFunc_CreateDialog(GameString.get("InputAccOrPass"))
			return
		elseif "" == againPassword then
			CommonFunc_CreateDialog(GameString.get("InputPassAgain"))
			return
		elseif false == mCheckBoxAgree:getSelectedState() then
			CommonFunc_CreateDialog(GameString.get("SelectPro"))
			return
		elseif againPassword ~= mPassword then
			CommonFunc_CreateDialog(GameString.get("PassNoSame"))
			return
		elseif mAccount == mPassword then
			CommonFunc_CreateDialog(GameString.get("AccAndPassNOSame"))
			return
		end
		if false == LayerRegister.judgeAccountPassword(mAccount,mPassword) then
			return
		end
		loginDataCache.requestRegister(mAccount, mPassword)
	elseif "Button_protocol" == widgetName then		-- 协议按钮
		rootNode = CCLayer:create()
		mRootView:addChild(rootNode)
		runLoading()
		-- local node = CCNode:create()
		-- mRootView:addChild(node)
		rootNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.6),CCCallFuncN:create(function(sender)
			-- rootNode:removeFromParentAndCleanup(true)
			UIManager.push("UI_RegisterProtocal")
		end)))
	end
end
----------------------------------------------------------------------
LayerRegister.init = function()
	mRootView = UIManager.findLayerByTag("UI_Register")
	setOnClickListenner("Button_close")
	setOnClickListenner("Button_register")
	setOnClickListenner("Button_protocol")
	--
	local registerPanel = mRootView:getWidgetByName("RegisterPanel")
	registerPanel:setTouchEnabled(false)		-- 这个必须设置,否则输入框接受不到触摸事件
	-- 账号
	local accountBg = tolua.cast(mRootView:getWidgetByName("ImageView_account"), "UIImageView")
	mEditBoxAccount = CommonFunc_createCCEditBox(ccp(0.5, 0.5), ccp(120, 0), CCSizeMake(252, 36), "touming.png",
				1, 11, GameString.get("InputAccount"), kEditBoxInputModeSingleLine, kKeyboardReturnTypeDefault)
	accountBg:addRenderer(mEditBoxAccount, 50)
	-- 密码
	local passwordBg = tolua.cast(mRootView:getWidgetByName("ImageView_password"), "UIImageView")
	mEditBoxPassword = CommonFunc_createCCEditBox(ccp(0.5, 0.5), ccp(120, 0), CCSizeMake(252, 36), "touming.png",
				2, 11, GameString.get("InputPass"), kEditBoxInputModeSingleLine, kKeyboardReturnTypeDefault)
	mEditBoxPassword:setInputFlag(kEditBoxInputFlagPassword)
	passwordBg:addRenderer(mEditBoxPassword, 50)
	-- 确认密码
	local againPasswordBg = tolua.cast(mRootView:getWidgetByName("ImageView_again_password"), "UIImageView")
	mEditBoxAgainPassword = CommonFunc_createCCEditBox(ccp(0.5, 0.5), ccp(120, 0), CCSizeMake(252, 36), "touming.png",
				3, 11, GameString.get("InputPassAgain"), kEditBoxInputModeSingleLine, kKeyboardReturnTypeDefault)
	mEditBoxAgainPassword:setInputFlag(kEditBoxInputFlagPassword)
	againPasswordBg:addRenderer(mEditBoxAgainPassword, 50)
	-- 同意协议
	mCheckBoxAgree = tolua.cast(mRootView:getWidgetByName("CheckBox_agree"), "UICheckBox")
	mCheckBoxAgree:setSelectedState(true)
end
----------------------------------------------------------------------
-- 销毁
LayerRegister.destroy = function()
	mRootView = nil
end
-- 获取账号
LayerRegister.getAccount = function()
	return mAccount
end
----------------------------------------------------------------------
-- 获取密码
LayerRegister.getPassword = function()
	return mPassword
end
----------------------------------------------------------------------


