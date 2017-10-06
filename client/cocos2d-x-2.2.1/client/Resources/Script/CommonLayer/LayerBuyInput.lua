
LayerBuyInput = {}

local LONG_PUSHDONW_TIME = 1
local LONG_FTP = 0.1

local mLayerBuyInput = nil 
local mLayerBuyInputView = nil  --当前数字展示
local mSure_callback = nil
local miCount = 0
local MINCOUNT = 1	--最小值
			
local mMax = nil 
local function setInputView(detla)
	if mLayerBuyInputView ~= nil then 
		miCount = miCount  + detla
		if miCount < MINCOUNT then miCount = MINCOUNT end
		
		cclog("mMax---------------------->",mMax)
		if mMax ~= nil and miCount > mMax then 
			miCount = mMax 
		end

		mLayerBuyInputView:setText(tostring(miCount))
	end 
end 

local AddTimer = nil
local RecTimer = nil
local delayTimer = nil

local function createClickTimer()
	if nil == AddTimer then
		AddTimer = CreateTimer(LONG_FTP, -1, function()
			setInputView(1)
		end, nil)
	end
	if nil == RecTimer then
		RecTimer = CreateTimer(LONG_FTP, -1, function()
			setInputView(-1)
		end, nil)
	end
	if nil == delayTimer then
		delayTimer = CreateTimer(LONG_PUSHDONW_TIME, 1, function(tm)
			if tm.getParam() ==  "addbtn" then 
				AddTimer.start()
			elseif tm.getParam() == "Reducebtn" then 
				RecTimer.start()
			end 
		end, nil)
	end
end

local function handleClearData()
	AddTimer = nil
	RecTimer = nil
	delayTimer = nil
end

LayerBuyInput.onClick =function(widget)
	local name = widget:getName()
	if name == "buyinput_sure" then 
		mSure_callback(miCount)
		UIManager.pop("UI_BuyInput")
	elseif name == "buyinput_cancle" then 
		UIManager.pop("UI_BuyInput")
	elseif name == "com_input_max" then 
		if mMax == nil then 
			cclog("mMax:nil 请传入最大值")
			return 
		end 
		miCount = mMax
		mLayerBuyInputView:setText(tostring(mMax))
	end
end


local function onClickEvent(type,widget)
	local name = widget:getName()
	if type == "pushDown" then 	
		if "addbtn" == name then 
			setInputView(1)	
			--AddTimer.start()
			delayTimer.start()
			delayTimer.setParam(name)
		elseif "Reducebtn" == name then 
			setInputView(-1)		
			--RecTimer.start()
			delayTimer.start()
			delayTimer.setParam(name)
		end
	elseif type == "releaseUp" then  
		if "addbtn" == name then 
			AddTimer.stop()	
		elseif "Reducebtn" == name then 
			RecTimer.stop()
		end
		delayTimer.stop()
	end
end

----参数 
--[[
	tb.maxValue(nil 就为无穷大)
	tb.initIndex(nil 就为1）
	tb.sure_callback(count) 确认按钮 count 为当前计数
]]--

function LayerBuyInput.init(tb)
	createClickTimer()
	assert(type(tb.sure_callback) == "function","传入的参数必须为函数")
	mMax = tb.maxValue
	
	mSure_callback = tb.sure_callback
	
	if tb.initIndex ~= nil then 
		miCount = tb.initIndex
	else 
		miCount = MINCOUNT
	end 
	
	mLayerBuyInput = UIManager.findLayerByTag("UI_BuyInput")
	

	
	mLayerBuyInputView = mLayerBuyInput:getWidgetByName("buyinput_index")
	tolua.cast(mLayerBuyInputView, "UILabel")
	mLayerBuyInputView:setText(tostring(miCount))
	
	setOnClickListenner("buyinput_sure")
	setOnClickListenner("buyinput_cancle")
	setOnClickListenner("com_input_max")
	
	
	local btn = mLayerBuyInput:getWidgetByName("addbtn")
	btn:registerEventScript(onClickEvent)
	
	btn = mLayerBuyInput:getWidgetByName("Reducebtn")
	btn:registerEventScript(onClickEvent)
	--[[]]--
end

function LayerBuyInput.destroy()
	mLayerBuyInput = nil
end

EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)


