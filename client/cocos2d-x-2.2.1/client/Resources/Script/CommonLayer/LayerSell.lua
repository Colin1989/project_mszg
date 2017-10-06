
----------------------------------------------------------------------
-- 出售 通用界面
----------------------------------------------------------------------
local mLayerSellRoot = nil
--物品实例ID
local mID = nil 

 
LayerSell = {
}

LayerSell.destroy = function()

end

local function setMaxSellCount(id)
	local attr = ModelBackpack.getItemByInstId(id)
	local widget = mLayerSellRoot:getWidgetByName("TextField_24")
	tolua.cast(widget,"UITextField")
	cclog("attr.amount",attr.amount)
	widget:setText(tostring(attr.amount))
end

--更新出售数量
local function updataSellPrice(id)
	local attr = ModelBackpack.getItemByInstId(id)
	local widget = mLayerSellRoot:getWidgetByName("TextField_24")
	tolua.cast(widget,"UITextField")
	
	local strText = widget:getStringValue()
	cclog("widget:getStringValue()",strText)
	--[[
	string.match(strText,"^[0-9]+$")
	widget:setText(strText)
	cclog("出售:",widget:getStringValue())
	]]
	
	local count = tonumber(strText)
	if count == nil then
		cclog("1")
		CommonFunc_CreateDialog(GameString.get("Sell_eror_2"))
		return false
	end
	
	if count <= 0 then
		CommonFunc_CreateDialog(GameString.get("Sell_eror_1"))
		widget:setText("1")
		return false,count
	end
	
	--判断是否有小数点
	if CommonFunc_IsInt(count) == false then
		CommonFunc_CreateDialog(GameString.get("Sell_eror_2"))
		local num = math.floor(strText)
		widget:setText(tonumber(num))
		return false,count
	end
	
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
			setMaxSellCount(mID)
		elseif widgetName == "Button_ok" then
			local bState,count = updataSellPrice(mID)
			
			if bState == true then
				LayerBackpack.callback_seed_sale_item(mID,count)
				UIManager.pop("UI_Sell")
			end
		elseif widgetName == "Button_exit" then
			--UIManager.pop("UI_Sell")
			local callbackFunc = function()
				UIManager.pop("UI_Sell")
			end
			Animation_UISell_Exit(mLayerSellRoot,callbackFunc)
		end
	end
end

----UIManager.push("UI_Sell",id)
function LayerSell.init(param)
	mID = param.id
	
	mLayerSellRoot = UIManager.findLayerByTag("UI_Sell")
	local position = CommonFunc_ConvertWordPosition(param.widget)
	mLayerSellRoot:setPosition(position)
	
	Animation_UISell_Enter(mLayerSellRoot)
	
	local btn = mLayerSellRoot:getWidgetByName("Button_max")
	btn:registerEventScript(onClickEvent)	
	
	btn = mLayerSellRoot:getWidgetByName("Button_ok")
	btn:registerEventScript(onClickEvent)
	
	btn = mLayerSellRoot:getWidgetByName("Button_exit")
	btn:registerEventScript(onClickEvent)
end

--[[
function LayerSell.create(param)
	mID = param
	----参数
	local tb = {}
	tb.initIndex(1)
	function tb.sure_callback(count) --确认按钮 count 为当前计数
	
	tb.sure_callback = function(index)
		cclog("------------------>",index)
	end
	UIManager.push("UI_BuyInput",tb)
end
]]
