
----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-5-5
-- 描述：登录系统的数据缓存
----------------------------------------------------------------------
loginDataCache ={}
local  	rolesInfo ={}    				--服务端返回的登陆的信息
local   noDelRoleInfo ={}				--没有被删除的角色信息   
local   emoney = 0						--保存获得的魔石
local   buyEmoney = 250				--花费的砖石购买角色						--抽象出来

--------------------------------------------------多角色界面，选择角色   开始游戏  的数据--------------------------
local function Handle_req_select_role(resp)
	if(resp.result == common_result["common_success"]) then	
		LayerRoleChoice.onExit()
		LuaAction.onExit()
		UIManager.pop("UI_LoginOwn")
		UIManager.pop("UI_Begin")
		UIManager.push("UI_Main","init")
	end
end

--根据点击的某一个， 设置发给服务器的id
loginDataCache.sendRequest =  function(id)
	local tb = req_select_role()
	tb.role_id = id
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_select_role_result"])
end

NetSocket_registerHandler(NetMsgType["msg_notify_select_role_result"], notify_select_role_result, Handle_req_select_role)

----------------------------------------------创建角色 开始游戏 的数据------------------------------------------------------
local function Handle_req_createRoll(resp)
	if resp.result == create_role_result["create_role_success"] then
	
		noDelRoleInfo ={{["role_id"] = ModelPlayer.getId(),["type"] = ModelPlayer.getRoleType(),
					["name"] = ModelPlayer.getNickName(),["lev"] = ModelPlayer.getLevel(),}}
		LuaAction.onExit()
		UIManager.pop("UI_RollChoice")
		UIManager.pop("UI_LoginOwn")
		UIManager.pop("UI_Begin")
		LayerRoleChoice.onExit()


        fourFrames.start(STORY_2,"enterMain",ccp(45,510))
		--fourFrames.start()--4格子漫画


		--[[
		local flag,code = LayerInviteCodeInput.getCheckFlag() 
		--local flag,code = LayerRoleChoice.getCheckFlag()
		if flag == 1 then
			LayerInviteCodeNewNoFriend.requestCheck(code)
		end
		]]--
	elseif resp.result == create_role_result["create_role_nologin"] then
		LayerRoleChoice.getSureButton ():setTouchEnabled(true)
	elseif resp.result == create_role_result["create_role_typeerror"] then
		LayerRoleChoice.getSureButton ():setTouchEnabled(true)
	elseif resp.result == create_role_result["create_role_failed"] then
		LayerRoleChoice.getSureButton ():setTouchEnabled(true)
	elseif resp.result == create_role_result["create_role_nameexisted"] then
		LayerRoleChoice.getSureButton ():setTouchEnabled(true)
	end
end

loginDataCache.reqCreaterole = function(types,name)
	local req = req_create_role()
    req.roletype = types		
    req.nickname = name
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_create_role_result"])
end	
		
--注册消息
NetSocket_registerHandler(NetMsgType["msg_notify_create_role_result"], notify_create_role_result, Handle_req_createRoll)
------------------------------------------登陆的数据----------------------------------------

function Handle_req_login(resp)
    

	loginDataCache.refreshTb()
	rolesInfo = resp.role_infos
	emoney =  resp.emoney
	loginDataCache.initRolesInfo ()
  
	if resp.result == 2 then	--没有角色
        --进入新手关 
        FightFirstCopy_Enter() 
		--UIManager.push("UI_RollChoice")	
	elseif resp.result == 1 then --登入成功
		if #noDelRoleInfo == 0 then						--登录成功后，判断没有被删除的角色是不是为0
			UIManager.push("UI_RollChoice")			
		else
			noDelRoleInfo = loginDataCache.getNoDelRolesInfo()
			reqId = noDelRoleInfo[1].role_id
			loginDataCache.sendRequest(reqId)
		end
		EventCenter_post(EventDef["ED_LOGIN_SUCCESS"])
	elseif resp.result == 3 then		--校验失败
		if  resp.error_code ~= 2007 then
			Toast.show(GameString.get("NETWORK_STR_06"))
		end 
	end
end
 
NetSocket_registerHandler(NetMsgType["msg_notifu_login_check_result"], notifu_login_check_result, Handle_req_login)


--根据返回的角色信息，设置发给服务器的id
loginDataCache.initRolesInfo = function()  
	for key,value in pairs(rolesInfo)	do
		if value.is_del == 2 then			--表示没有被删除
			table.insert(noDelRoleInfo,value)
		elseif	value.is_del == 1 then		--表示被删除了	
			--table.insert(deleteRolesInfo,value)
		end
	end  
end

loginDataCache.refreshTb = function()
	noDelRoleInfo={}
end

--获取没有被删除的角色信息(最后四个)
loginDataCache.getNoDelRolesInfo = function()
	return noDelRoleInfo
end

--获取魔石
loginDataCache.getEmoney = function()
	return  emoney
end

--设置魔石
loginDataCache.setEmoney = function(num)
	emoney = num
end

----------------------------------------------------------------------
-- 在设置客户端文本缓存	
loginDataCache.initAccountDB = function(account)
	local db = DB:getRoot()
	db.userInfo = db.userInfo or {}
	db.userInfo.account = account	--这个必须要设
	DB:save()
end 
 
 --请求登陆
loginDataCache.requestLogin = function(account,password)
	local loginParam = 
	{
		["app_id"] = tonumber(ChannelProxy.getAppId()),
		["app_key"] = ChannelProxy.getAppKey(),
		["channel_id"] = tonumber(ChannelProxy.getChannelId()),
		["device_id"] = "testDevice_id",	--这个值随便设
		["account"] = account,
		["password"] = password,
	}

	NetHttp.send_ByPost("login",
	loginParam,
	function(resp)
		-- 登入成功
		chooseServerDataCache.getOwnServerList(resp)
		CCUserDefault:sharedUserDefault():setStringForKey("lastaccount",LayerLoginOwn.getAccount())
		CCUserDefault:sharedUserDefault():setStringForKey("password",LayerLoginOwn.getPassword())
		CCUserDefault:sharedUserDefault():flush()
	end,
	function(resp)
		-- 登录失败
	end,
	function()
		-- 登录超时
		Toast.show(GameString.get("NETWORK_STR_01"))
	end)
end

----------------------------------------- 注册的数据------------------------------------------

--获得保存在数据库中的账号
loginDataCache.getAccount = function()
	--新版已改成UID
	return  DB:getRoot().userInfo.account
end 

--获得保存在数据库中的密码
loginDataCache.getPassword = function()
	local str =CCUserDefault:sharedUserDefault():getStringForKey("password")
	if str == nil then 
		str = LayerLoginOwn.getPassword()
	end 	
	return str
end 

local function Handle_req_regsiter(resp)
	if resp.result == register_result["register_success"] then
		if UIManager.findLayerByTag("UI_Register")~= nil then
			LayerLoginOwn.setEditBoxTouch(true)
			UIManager.pop("UI_Register")
		end
		loginDataCache.requestLogin(LayerRegister.getAccount(),LayerRegister.getPassword())
	elseif resp.result == register_result["register_failed"] then	 --此处走系统消息
	
	end
end

--请求注册
loginDataCache.requestRegister = function(account,password)
	local regisiterParam = 
	{
		["app_id"] = tonumber(ChannelProxy.getAppId()),
		["app_key"] = ChannelProxy.getAppKey(),
		["channel_id"] = tonumber(ChannelProxy.getChannelId()),
		["account"] = account,
		["password"] = password,
	}
	
	NetHttp.send_ByPost("regist",
	regisiterParam,
	function(resp)
		LayerLoginOwn.setEditBoxTouch(true)
		UIManager.pop("UI_Register")
		CommonFunc_CreateDialog(GameString.get("RegisSuc"))
		EventCenter_post(EventDef["ED_REGISTER_SUCCESS"], regisiterParam)
	end,
	function(resp)
		-- 请求失败
	end,
	function()
		-- 请求超时
		Toast.show(GameString.get("NETWORK_STR_01"))
	end)
end
