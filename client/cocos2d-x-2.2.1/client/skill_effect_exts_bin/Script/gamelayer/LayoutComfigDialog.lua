
-- 确认框

local mLayerComfigDialogRoot = nil		--跟节点
LayoutComfigDialog = {}

LayerAbstract:extend(LayoutComfigDialog)

LayoutComfigDialog.onClick  = function(weight)
	local weightName = weight:getName()
--		local weightName = weight:getName()
	if weightName == "button_yes" then
		local req = req_buy_power_hp()
		NetHelper.sendAndWait(req,NetMsgType["notify_buy_power_hp_result"])
		print("yes")
		UIManager.pop()
	elseif weightName == "button_no" then
		print("no")
		UIManager.pop()		--FIXME 这个BUG再解决
	end
end


local function initText(test)
	local comfigDialgo = mLayerComfigDialogRoot:getWidgetByName("txt1")
	tolua.cast(comfigDialgo, "UILabel")
	comfigDialgo:setText(test)
end

local function 	initButtonEvent()
	setOnClickListenner("button_yes")
	setOnClickListenner("button_no")	
end
-- onCreate
LayoutComfigDialog.init = function (bundle)
		local function Handle_req_buyPowerUp(resp)  --购买体力返回
			if resp.result == common_result["common_success"] then
				--当日购买次数加1
				ModelPlayer.power_hp_buy_times  = ModelPlayer.power_hp_buy_times + 1
				ModelPlayer.power_hp = POWER_UP_MAX
				EventCenter_post(EventDef["ED_UPDATE_ROLE_INFO"], ModelPlayer)
				print("购买成功")
			elseif resp.result == common_result["common_failed"] then
				print("购买失败")
			elseif resp.result == common_result["common_error"] then
				print("购买错误")
			end
		end
	

		NetSocket_registerHandler(NetMsgType["msg_notify_buy_power_hp_result"], notify_buy_power_hp_result(), Handle_req_buyPowerUp)

	mLayerComfigDialogRoot = UIManager.findLayerByTag("UI_ComfigDialog")
	initButtonEvent()
	initText(bundle)	
end
