-- 断线重连界面
local mLayerRoot = nil 
local mConnectFlag = false
NetReConnectLayer = {}

local function onTouch(eventType, x, y)
	if "began" == eventType then 
		return true
	end
end

-- 点击重新连接按钮
local function onClickReconnectButton(typeName, widget)
	if "releaseUp" == typeName then
		widget:setTouchEnabled(false)
		NetReConnectLayer.hide()
		NetSendLoadLayer.show()
		local function delayDone()
			mConnectFlag = true
			local data = chooseServerDataCache.getServerData()
			NetHelper.connect(data.ip, data.port, data.crypto)
		end
		CreateTimer(0.07, 1, nil, delayDone).start()
	end
end

-- 点击退出游戏按钮
local function onClickExitgameButton(typeName, widget)
	if "releaseUp" == typeName then
		local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
		if kTargetMacOS == targetPlatform or kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
			Toast.show(GameString.get("NETWORK_STR_07"))
		else
			widget:setTouchEnabled(false)
			CCDirector:sharedDirector():endToLua()
		end
	end
end

-- 显示断线重连界面
NetReConnectLayer.show = function()
	NetSendLoadLayer.dismiss()
	if mLayerRoot then
		return
	end
	mLayerRoot = UILayer:create()
	mLayerRoot:setTouchEnabled(true)
	mLayerRoot:registerScriptTouchHandler(onTouch, false, -2147483647 - 1, true)
	local jsonRoot = GUIReader:shareReader():widgetFromJsonFile("reconnect.json")
	-- 重新连接按钮
	local reconnectBtn = jsonRoot:getChildByName("Button_reconnect")
	reconnectBtn:registerEventScript(onClickReconnectButton)
	-- 提示文本
	local tipLabel = tolua.cast(jsonRoot:getChildByName("Label_tip"), "UILabel")
	tipLabel:ignoreContentAdaptWithSize(true)
	tipLabel:setText(GameString.get("NETWORK_STR_01"))
	FightAnimation_openX(jsonRoot:getChildByName("panel"))
	mLayerRoot:addWidget(jsonRoot)
	g_rootNode:addChild(mLayerRoot, 1991)
	--
	EventCenter_post(EventDef["ED_BROKEN_LINE"])
end

-- 隐藏断线提示
NetReConnectLayer.hide = function()
	if mLayerRoot then
		mLayerRoot:unregisterScriptTouchHandler()
		mLayerRoot:removeFromParentAndCleanup(true)
		mLayerRoot = nil
	end
end

-- 处理版本验证
local function handleCheckVersion(success)
	if false == mConnectFlag then
		return
	end
	mConnectFlag = false
	if true == success then
		if 0 == ModelPlayer.getId() then
			NetHelper.loginCheck()
		else
			NetHelper.sendReconnect()
		end
	end
end

EventCenter_subscribe(EventDef["ED_CHECK_VERSION"], handleCheckVersion)
