----------------------------------------------------------------------
-- ������ؽӿ�
----------------------------------------------------------------------
GAME_VERSION = "1.0.7"
IS_GROUNDING = 2		-- 1.��ȡ�����еķ������б�2.��ȡ��ʽ�ϼܵķ������б�
ChannelProxy = {}
local mTargetPlatform = CCApplication:sharedApplication():getTargetPlatform()
local mAppId = "30001"
local mAppKey = "8a808023468dd22001468dd220270000"
local mChannelId = "30001"		-- ��1λ������ʶƽ̨:1.android,2.ios,3.windows;��2-4λ������ʶ����;��5λ������ʶ��������
local mUid = ""
local mToken = ""
----------------------------------------------------------------------
-- ����java��̬����
local function callJavaStaticFunc(_className, _funcName, args, sig)
	local ok, ret = require("Script/luaj").callStaticMethod(_className, _funcName, args, sig)
	return ret, ok
end
----------------------------------------------------------------------
-- ����oc��̬����
local function callOCStaticFunc(_className, _funcName, args)
	local ok, ret = require("Script/luaoc").callStaticMethod(_className, _funcName, args)
	return ret, ok
end
----------------------------------------------------------------------
-- ��ȡ���ط�����У��appid
ChannelProxy.getAppId = function()
	if kTargetAndroid == mTargetPlatform then
		-- mAppId = callJavaStaticFunc("org.cocos2dx.client.Client", "getAppId", {}, "()Ljava/lang/String;")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		-- mAppId = callOCStaticFunc("Channel", "getAppId")
	end
	return mAppId
end
----------------------------------------------------------------------
-- ���ط�����У��appKey
ChannelProxy.getAppKey = function()
	if kTargetAndroid == mTargetPlatform then
		-- mAppKey = callJavaStaticFunc("org.cocos2dx.client.Client", "getAppKey", {}, "()Ljava/lang/String;")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		-- mAppKey = callOCStaticFunc("Channel", "getAppKey")
	end
	return mAppKey
end
----------------------------------------------------------------------
-- ��ȡ����id
ChannelProxy.getChannelId = function()
	if kTargetAndroid == mTargetPlatform then
		mChannelId = callJavaStaticFunc("org.cocos2dx.client.Client", "getChannelId", {}, "()Ljava/lang/String;")
	elseif kTargetMacOS == mTargetPlatform or kTargetIpad == mTargetPlatform or kTargetIphone == mTargetPlatform then
		print("mChannelId_________1",mChannelId)
		mChannelId = callOCStaticFunc("Channel", "getChannelId")

        print("mChannelId_________2",mChannelId)
	end

	return mChannelId
end
----------------------------------------------------------------------
-- ��url
ChannelProxy.openURL = function(url, exitApp)
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "openURL", {url, exitApp}, "(Ljava/lang/String;Z)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "openURL", {url_str = url, exit_app = exitApp})
	end
end
----------------------------------------------------------------------
-- ����uid
ChannelProxy.setUid = function(uid)
	mUid = uid
end
----------------------------------------------------------------------
-- ��ȡuid
ChannelProxy.getUid = function()
	if true == CONFIG["own_login_flow"] then
		return mUid
	end
	if kTargetAndroid == mTargetPlatform then
		mUid = callJavaStaticFunc("org.cocos2dx.client.Client", "getUid", {}, "()Ljava/lang/String;")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		mUid = callOCStaticFunc("Channel", "getUid")
	end
	return mUid
end
----------------------------------------------------------------------
-- ����token
ChannelProxy.setToken = function(token)
	 mToken = token
end
----------------------------------------------------------------------
-- ��ȡtoken
ChannelProxy.getToken = function()
	if true == CONFIG["own_login_flow"] then 
		return mToken
	end
	if kTargetAndroid == mTargetPlatform then
		mToken = callJavaStaticFunc("org.cocos2dx.client.Client", "getToken", {}, "()Ljava/lang/String;")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		mToken = callOCStaticFunc("Channel", "getToken")
	end
	return mToken
end
----------------------------------------------------------------------
-- �Ƿ�Ϊ���е�¼����
ChannelProxy.isOwnLogin = function()
	return CONFIG["own_login_flow"]
end
----------------------------------------------------------------------
-- ��ʼ
ChannelProxy.init = function()
	if true == CONFIG["own_login_flow"] then
		return
	end
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "init", {""}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "init", {msg_str = ""})
    end
end
----------------------------------------------------------------------
-- ��¼
ChannelProxy.login = function()
	if true == CONFIG["own_login_flow"] then
		return
	end
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "login", {""}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "login", {msg_str = ""})
    end
end
----------------------------------------------------------------------
-- �л��˺�
ChannelProxy.switchAccount = function()
	if true == CONFIG["own_login_flow"] then
		return
	end
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "switchAccount", {""}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "switchAccount", {msg_str = ""})
    end
end
----------------------------------------------------------------------
-- ֧��
ChannelProxy.pay = function(goodsId, goodsPrice, goodsName)
	local serverData = chooseServerDataCache.getServerData()
	local data = chooseServerDataCache.getIpconfigRow(serverData.ip, tostring(serverData.port))
	local payTb = 
	{
		["uid"] = tostring(ChannelProxy.getUid()),
		["server_id"] = tostring(data.server_id),
		["role_id"] = string.int64_to_string(ModelPlayer.getId()),
		["role_name"] = ModelPlayer.getNickName(),
		["goods_id"] = tostring(goodsId),
		["goods_price"] = tostring(goodsPrice),
		["goods_count"] = "1",
		["goods_name"] = goodsName,
		["channel_id"] = tostring(ChannelProxy.getChannelId()),
	}
	local payMsg = CommonFunc_encodeJsonStr(payTb)
	cclog(payMsg)
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "pay", {payMsg}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "pay", payTb)
    end
end
----------------------------------------------------------------------
-- ��ͣ
ChannelProxy.pause = function()
	if true == CONFIG["own_login_flow"] then
		return
	end
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "pause", {""}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "pause", {msg_str = ""})
    end
end
----------------------------------------------------------------------
-- ��¼�����Ϸ��Ϣ
ChannelProxy.setUmsAgentEvent = function(str)
    if kTargetAndroid == mTargetPlatform then
        callJavaStaticFunc("org.cocos2dx.client.Client", "onUmsAgentEvent", {str}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "onUmsAgentEvent", {ums_str = str})
    end
end
----------------------------------------------------------------------
-- ����˽����Ϣ
ChannelProxy.sendPrivateMessage = function()
	local serverData = chooseServerDataCache.getServerData()
	local msgTb = 
	{
		["role_id"] = string.int64_to_string(ModelPlayer.getId()),
		["role_name"] = ModelPlayer.getNickName(),
		["role_level"] = tostring(ModelPlayer.getLevel()),
		["zone_id"] = "1",
		["zone_name"] = serverData.name
	}
	local msgStr = CommonFunc_encodeJsonStr(msgTb)
	cclog(msgStr)
	if kTargetAndroid == mTargetPlatform then
		callJavaStaticFunc("org.cocos2dx.client.Client", "sendMessage", {1, msgStr}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		callOCStaticFunc("Channel", "sendMessage", {msg_type = 1, msg_str = msgStr})
	end
end
----------------------------------------------------------------------
-- �����ַ�����ϵͳ������
ChannelProxy.copyString = function(str)
	local ok = false
	if kTargetAndroid == mTargetPlatform then
        _, ok = callJavaStaticFunc("org.cocos2dx.client.Client", "copyString", {str}, "(Ljava/lang/String;)V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		_, ok = callOCStaticFunc("Channel", "copyString", {copy_str = str})
    end
	if not ok then
		return false
	end
	return true
end
----------------------------------------------------------------------
-- ֪ͨjava��oc�Ѿ�lua�Ѿ���ʼִ��
ChannelProxy.notifyLuaExecuted = function()
	if kTargetAndroid == mTargetPlatform then
        callJavaStaticFunc("org.cocos2dx.client.Client", "handleLuaExecuted", {}, "()V")
	elseif kTargetMacOS == mTargetPlatform or kTargetIphone == mTargetPlatform or kTargetIpad == mTargetPlatform then
		-- callOCStaticFunc("Channel", "handleLuaExecuted")
    end
end
----------------------------------------------------------------------


