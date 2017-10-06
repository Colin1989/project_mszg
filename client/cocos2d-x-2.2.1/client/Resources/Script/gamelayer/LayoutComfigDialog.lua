-- 确认框

LayoutComfigDialog = {}
LayerAbstract:extend(LayoutComfigDialog)

local mLayerComfigDialogRoot = nil		--跟节点

LayoutComfigDialog.onClick = function(weight)
	local weightName = weight:getName()
	if weightName == "button_yes" then
		local powerHpPriceRow = ModelPower.getPowerHpPriceRow(ModelPlayer.getHpPowerBuyTimes() + 1)
		if powerHpPriceRow.price <= ModelPlayer.getEmoney() then   -- 恢复体力
			ModelPower.requestBuyPowerHp()
			UIManager.pop("UI_ComfirmDialog")
			mLayerComfigDialogRoot = nil
		else         --钻石不够，跳转到充值界面
			local structConfirm ={
				strText ="钻石不足，是否前去充值？",		
				buttonCount = 2,
				buttonName = {"是","否"},
				buttonEvent ={nil,nil},
				buttonEvent_Param = {friendId,nil}
			}
			--UIManager.push("UI_ComfirmDialog",structConfirm)    跳转到充值界面															
		end
	elseif weightName == "button_no" then
		UIManager.pop("UI_ComfirmDialog")		--FIXME 这个BUG再解决
		mLayerComfigDialogRoot = nil
	end
end

local function initText(test)
	local comfigDialgo = mLayerComfigDialogRoot:getWidgetByName("txt1")
	tolua.cast(comfigDialgo, "UILabel")
	comfigDialgo:setText(test)
end

local function initButtonEvent()
	setOnClickListenner("button_yes")
	setOnClickListenner("button_no")	
end

-- onCreate
LayoutComfigDialog.init = function (bundle)
	mLayerComfigDialogRoot = UIManager.findLayerByTag("UI_ComfigDialog")
	initButtonEvent()
	initText(bundle)	
end
