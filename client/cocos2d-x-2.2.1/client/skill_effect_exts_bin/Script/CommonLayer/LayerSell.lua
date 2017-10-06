
----------------------------------------------------------------------
-- 出售 通用界面
----------------------------------------------------------------------
local mLayerSellRoot = nil
--物品实例ID
local mID = nil 

 
LayerSell = {
}

LayerSell.destory = function()

end

local function updataSellPrice(id)
	local attr = ModelPlayer.findBagItemAttr(id)
	local widget = mLayerSellRoot:getWidgetByName("TextField_24")
	tolua.cast(widget,"UITextField")
	
	local strText = widget:getStringValue()
	local count = tonumber(strText)
	if count == nil or count > attr.amount then 
		widget:setText(tostring(attr.amount))
		count = attr.amount
		return false,count
	end
	
	return true,count
	
end


local function onClickEvent(typeName,widget)
	
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
	
		if widgetName == "Button_max" then
			updataSellPrice(mID)
		elseif widgetName == "Button_ok" then
			local bState,count = updataSellPrice(mID)
			
			if bState == true then
				BackpackUIManage.callback_seed_sale_item(mID,count)
				UIManager.pop("UI_Sell")
			end
		elseif widgetName == "Button_exit" then
			UIManager.pop("UI_Sell")
		end
		
	end
	
end

----UIManager.push("UI_Sell",id)
function LayerSell.init(id)
	string.print_int64("LayerSell.init() id:",id)
	mID = id
	mLayerSellRoot = UIManager.findLayerByTag("UI_Sell")
	
	local btn = mLayerSellRoot:getWidgetByName("Button_max")
	btn:registerEventScript(onClickEvent)	
	
	btn = mLayerSellRoot:getWidgetByName("Button_ok")
	btn:registerEventScript(onClickEvent)
	
	btn = mLayerSellRoot:getWidgetByName("Button_exit")
	btn:registerEventScript(onClickEvent)
	
	
end


