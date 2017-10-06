---作者shenl
--- 领取兑换码

layerActivalReward = setmetatable({},{__mode='k'})
layerActivalReward.rootView = nil

local inputText = nil
layerActivalReward["jsonFile"] = "ActivatalReward_1.json"


local SendParam = {
	
}

LayerAbstract:extend(layerActivalReward)

 --请求领取
local function sendRewardReq(cdKey)
		--cclog("server_id:",chooseServerDataCache.getServerData().ip)
		--cclog("uid:",ChannelProxy.getUid())
		--cclog("role_id:", string.int64_to_string(ModelPlayer.getId()))
		
		local info = chooseServerDataCache.getServerData()
		local serverData = chooseServerDataCache.getIpconfigRow(info.ip,tostring(info.port))
		
		SendParam["uid"] = ChannelProxy.getUid()
		SendParam["role_id"] = string.int64_to_string(ModelPlayer.getId())
		SendParam["cd_key"] = cdKey
		SendParam["server_id"] = tostring(serverData.server_id)
		SendParam["app_id"] = ChannelProxy.getAppId()
	
	
		NetHttp.send_ByPost("cdkey",
		SendParam,
		nil,
		function (resp)
			local error_show	= layerActivalReward.rootView:getWidgetByName("error_show")
			tolua.cast(error_show,"UILabel")
			error_show:setVisible(true)
			error_show:setText(GameString.get("INPUTERRORTIME",LIMIT_JIHUOMA_ERRORTIME - resp.request_count))
		end 
		)
end



layerActivalReward.onClick = function (weight)
   local weightName = weight:getName()
    if weightName == "close_btn" then
		UIManager.pop("UI_activalReward")
	elseif weightName == "getReward" then
		

		if inputText:getText() == nil or inputText:getText() == "" then 
			Toast.show(GameString.get("ACTIVAL_REWARD_ERROR_1"))
			return
		end 
		sendRewardReq(inputText:getText())
    end
end

layerActivalReward.init = function()
	SendParam = {}
	layerActivalReward.rootView = UIManager.findLayerByTag("UI_activalReward")
	setOnClickListenner("close_btn")
	setOnClickListenner("getReward")
	
	local editorBox	= layerActivalReward.rootView:getWidgetByName("ImageView_26")
	editorBox:setTouchEnabled(false)
	--tolua.cast(editorBox,"UITextField")
	--editorBox:setPlaceHolder("点击这里输入兑换码")
	inputText = CommonFunc_createCCEditBox(ccp(0.0,0.5),ccp(-202,0), CCSizeMake(404,52),"touming.png",
				10,13,"",kEditBoxInputModeAny,kKeyboardReturnTypeDefault)
	inputText:setTouchEnabled(true)
	editorBox:addRenderer(inputText,30) 
end

layerActivalReward.destroy = function()
	layerActivalReward.rootView = nil
end 

local function Handle_getRewards(resp)
	UIManager.pop("UI_activalReward")

	--[[
	local function reWardString(initStr,DateTb)
		for k,v in pairs(DateTb) do
			print()
			initStr = initStr..v.name.."*"..v.amount.." "
		end
		return initStr
	end 
	]]--
	for k,v in pairs(resp.awards) do 
		local Itemdate = LogicTable.getRewardItemRow (v.temp_id)
		local reWardInfo = {}
		reWardInfo.amount = v.amount
		if tonumber(Itemdate.temp_id ) == 0 then 
			reWardInfo.name = LogicTable.getRewardTypeDate(Itemdate.type).name
		else 
			reWardInfo.name = Itemdate.name
		end 
		--table.insert(DialyreWardDesc,reWardInfo)
		Toast.show(reWardInfo.name.."*"..reWardInfo.amount)
	end 
end

NetSocket_registerHandler(NetMsgType["msg_notify_redeem_cdoe_result"], notify_redeem_cdoe_result, Handle_getRewards)

