LayerSweep = {}

LayerAbstract:extend(LayerSweep)
local mLayerSweepRoot = nil 
local ratio = 0
local mParam = nil
local allDelayTime = 0		-- 确定按钮出现的延迟时间				
local getItemsScroll 		-- 滚动条
local items					-- 保存所有的物品
local specialItemScroll		-- 额外奖励滚动层
local mSpecialReward		-- 额外奖励
local mInternal = 0.5		-- 扫荡一次的时间
LayerSweep.onClick = function(widget)
	local widgetName = widget:getName()
    if "sure" == widgetName then  					-- 确认
		UIManager.pop("UI_Sweep")
		if UIManager.popBounceWindow("UI_TempPack") ~= true then 
			LayerCopy_updateCopyUI()
			LayerLvUp.setEnterLvMode(2)
			UIManager.popBounceWindow("UI_LvUp")
		end
    end
end
-----------------------------------------------------------------------------------
--获得扫荡每次的金币和经验
LayerSweep.getCoinAndExp = function()
	local tb = {}
	for key,value in pairs(mParam.list) do
		local temp = {}
		temp.gold = value.gold
		temp.exp = value.exp
		table.insert(tb,temp)
	end
	return tb
end

--获得扫荡每次的物品(每次的一个表)
LayerSweep.getItems = function()
	local tb = {}
	for key,value in pairs(mParam.list) do
		local temp = {}
		temp = value.item
		for k1,v1 in pairs(value.item) do
			table.insert(tb,v1)
		end
	end
	return tb
end

--获得扫荡每次的物品(所有的放在一起)
LayerSweep.getAllItems = function()
	local tb = {}
	for key,value in pairs(mParam.list) do
		for k,v in pairs(value.item) do
			table.insert(tb,v)
		end	
	end
	return tb
end

-- 获得扫荡的额外奖励
LayerSweep.getSpecialItems = function()
	local tb = {}
	local copyInfo = LogicTable.getCopyById(mParam.id)
	for key,value in pairs(copyInfo.clean_up_reward_ids) do
		if tonumber(value) ~= -1 then
			local temp = {}
			temp.id = value
			temp.amount = tonumber(copyInfo.clean_up_reward_amounts[key])*tonumber(mParam.count)
			
			table.insert(tb,temp)
		end
	end
	return tb
end
--------------------------------------------------------------------------------------
--设置金币
local function setCoin()
	local  coin = mLayerSweepRoot:getWidgetByName("Label_coin")      --金币
	tolua.cast(coin,"UILabel")
	coin:setText("0")
	local  expAndCoin = LayerSweep.getCoinAndExp()
	local  allCoin = 0
	--获得所有的金币
	for key,value in pairs(expAndCoin) do
		allCoin = tonumber(value.gold) + allCoin
	end
	local coinNum = 0
	local function changeCoin()
		coinNum = coinNum +  math.ceil(allCoin/ (mInternal*mParam.count))
		if mLayerSweepRoot ~= nil then
			if tonumber(coinNum) <= tonumber(allCoin) then	
				coin:setText(coinNum)
			else
				coin:setText(allCoin)
			end
		end
	end
	CreateTimer(1,mInternal*mParam.count, changeCoin,nil).start()
end

--设置经验
local function setExp()
	local  expLabel = mLayerSweepRoot:getWidgetByName("Label_exp")      --经验
	tolua.cast(expLabel,"UILabel")
	expLabel:setText("0")		
	local  expAndCoin = LayerSweep.getCoinAndExp()
	local  allExp = 0
	--获得所有的经验
	for key,value in pairs(expAndCoin) do
		allExp = tonumber(value.exp) + allExp
	end
	local exp = 0
	local function changeExp()
		exp = exp + math.ceil(allExp / (mInternal*mParam.count))
		if mLayerSweepRoot ~= nil then
			if tonumber(exp) <= tonumber(allExp) then	
				expLabel:setText(exp)
			else
				expLabel:setText(allExp)
			end
		end
	end
	CreateTimer(1, mInternal*mParam.count, changeExp,nil).start()
end
------------------------------------------------------------------------------------------------------------
--宝箱开完后，显示确定按钮
local function overUpdateLoadingBar(delayTime)
	local  sureBtn = mLayerSweepRoot:getWidgetByName("sure")      --确定按钮
	tolua.cast(sureBtn,"UIButton")	
	
	local function callVisible()
		if mLayerSweepRoot ~= nil then
			sureBtn:setTouchEnabled(true)
			sureBtn:setVisible(true)
		end
	end
	
	local action = CCSequence:createWithTwoActions(CCDelayTime:create(delayTime),CCCallFuncN:create(callVisible))
	sureBtn:runAction(action)
end

local function setItems()
	local internal = mInternal*mParam.count/#items
	overUpdateLoadingBar(mInternal*mParam.count)
	local scrollItem ={}
	for k1,v1 in pairs(items) do
		local icon,effectNode,boxSprite = LayerFightOver.setOpenBoxAction(scrollItem, k1, v1.id)
		local delay = internal*k1
		LayerFightOver.openBox(delay, icon, v1, effectNode, boxSprite)
	end
	setAdapterGridView(getItemsScroll,scrollItem,4,0)		--0.002
	
	if #mSpecialReward ~= 0 then
		-- 额外奖励
		local scrollSpecialItem = {}
		for k1,v1 in pairs(mSpecialReward) do
			local icon,effectNode,boxSprite = LayerFightOver.setOpenBoxAction(scrollSpecialItem, k1, v1.id)
			local delay = internal*k1
			LayerFightOver.openBox(delay, icon, v1, effectNode, boxSprite)
		end
		setAdapterGridView(specialItemScroll,scrollSpecialItem,4,0)
	end
end
------------------------------------------------------------------------------------------
--扫荡的次数统计
LayerSweep.setSweepTimes = function()
	local  times = 0
	local  sweepTimes = mLayerSweepRoot:getWidgetByName("times")      		
	tolua.cast(sweepTimes,"UILabel")
	local strText = string.format("0/%d",mParam.count)
	sweepTimes:setText(strText)
	
	local function changeText()
		times = times + 1
		local strText = string.format("%d/%d",times,mParam.count)
		if mLayerSweepRoot ~= nil then
			sweepTimes:setText(strText)
		end
	end
	
	CreateTimer(mInternal, tonumber(mParam.count), changeText,nil).start()
end
------------------------------------------------------------------------------------------
-- 设置进度条并执行动作
local function updateSweepAdvance()
	local loadingPercent = tonumber(mParam.count)
	local widget = mLayerSweepRoot:getWidgetByName("ImageView_advance")
	widget:setScaleX(0.0)
	local function actionFunc()
		local function actionCallback()
			if loadingPercent >= 1.0 then
				widget:setScaleX(0.0)	
				actionFunc()
			end	
		end
		local scaleAction = nil
		if loadingPercent >= 1.0 then	
			loadingPercent = loadingPercent - 1.0	
			scaleAction = CCScaleTo:create(mInternal,1.0, 1.0)
		end
		
		widget:runAction(CCSequence:createWithTwoActions(scaleAction, CCCallFunc:create(actionCallback)))
	end
	
	actionFunc()
end

-------------------------------------------------------------------------------------------------
LayerSweep.init = function(param)
	ratio = 0
	mParam = param
	mLayerSweepRoot=UIManager.findLayerByTag("UI_Sweep")
	updateSweepAdvance()
	
	setOnClickListenner("sure")
	--副本名
	local copyName = mLayerSweepRoot:getWidgetByName("sweep_copy_name")
	tolua.cast(copyName,"UILabel")
	local copyInfo = LogicTable.getCopyById(mParam.id)
	copyName:setText(copyInfo.name)
	--确定按钮,不可点击
	local  sureBtn = mLayerSweepRoot:getWidgetByName("sure")
	tolua.cast(sureBtn,"UIButton")
	--sureBtn:setBright(false)
	sureBtn:setTouchEnabled(false)
	sureBtn:setVisible(false)
		
	--[[
	--精英副本，隐藏掉经验
	if  tonumber(copyInfo.type) == 2 then
		local  expLabel = mLayerSweepRoot:getWidgetByName("Panel_exp")		-- 经验
		expLabel:setVisible(false)
	end
	]]--
	getItemsScroll = mLayerSweepRoot:getWidgetByName("ScrollView_50")		-- 滚动
	specialItemScroll = mLayerSweepRoot:getWidgetByName("ScrollView_special")		-- 额外奖励滚动层
	tolua.cast(getItems,"UIScrollView")
	items = LayerFightOver.splitUnOverlayItem(LayerSweep.getItems())
	mSpecialReward = LayerSweep.getSpecialItems()
	setItems()
	setCoin()
	setExp()
	--LayerSweep.setLoadingBarBySweepTimes()
	LayerSweep.setSweepTimes()
end 

LayerSweep.destroy = function()
	mLayerSweepRoot = nil
end



