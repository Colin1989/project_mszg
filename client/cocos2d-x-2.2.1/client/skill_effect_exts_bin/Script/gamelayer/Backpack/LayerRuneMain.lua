
--符文主界面

LayerRuneMain = {}
local mLayerRoot = nil

local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		print("LayerRuneMain typeName:",typeName)
		local widgetName = widget:getName()
		
		if widgetName == "Button_1" then -- 金币占卜
			BackpackUIManage.addLayer("UI_runeGamble",1)
		elseif widgetName == "Button_2" then -- 符文更换
			BackpackUIManage.addLayer("UI_runePut")
		elseif widgetName == "Button_3" then -- 魔石占卜
			BackpackUIManage.addLayer("UI_runeGamble",2)
		elseif widgetName == "Button_4" then -- 兑换符文
			BackpackUIManage.addLayer("UI_runeConvert")
		elseif widgetName == "Button_5" then -- 友情占卜
			BackpackUIManage.addLayer("UI_runeGamble",3)
		elseif widgetName == "Button_close" then -- 离开
			BackpackUIManage.closeLayer("UI_runeMain")
			UIManager.retrunMainLayer("init")
		end
		
	end
	
end


function LayerRuneMain.init(layer,param)
	mLayerRoot = layer
	local btn = nil
	
	for i=1,5 do
		btn = mLayerRoot:getChildByName("Button_"..i)--出售
		btn:registerEventScript(onClickEvent)
	end
	
	btn = mLayerRoot:getChildByName("Button_close")--出售
	btn:registerEventScript(onClickEvent)

end
