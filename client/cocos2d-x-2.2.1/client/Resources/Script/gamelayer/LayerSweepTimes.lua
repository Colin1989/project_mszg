-------------------------------------
--作者：李慧琴
--说明：扫荡次数选择界面
--时间：2014-6-11
-------------------------------------
LayerSweepTimes = {}

LayerAbstract:extend(LayerSweepTimes)
local mLayerSweepTimesRoot = nil 

local id				--当前的副本id
local sweepTimes = 0	--扫荡的次数
local mSweepInfo = nil	-- 扫荡卡对象（没有就默认nil)

--根据扫荡次数，请求扫荡
local function requestSweepByCount(count)
	UIManager.pop("UI_SweepTimes")
	UIManager.pop("UI_CopyTips")
	local tb = req_clean_up_copy()
	tb.copy_id = id
	tb.count = count
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_clean_up_copy_result"])
end

--点击体力框确定时的回调函数
function power_yes()
	-- 判断是否超过购买的次数限制
	local maxBuyHpTimes = PowerConfig["buy_times"]	
	if ModelPlayer.getVipLevel() > 0 then
		maxBuyHpTimes = getVipAddValueById(8) + maxBuyHpTimes
	end
	if ModelPlayer.getHpPowerBuyTimes() == maxBuyHpTimes then
		Toast.show(GameString.get("ShopMall_LIMITS_TIPS"))
	elseif ModelPlayer.getHpPowerBuyTimes() < maxBuyHpTimes  then
		local powerHpPrice = ModelPower.getPowerHpPrice()
		if CommonFunc_payConsume(2, powerHpPrice) then
			return
		end
		if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
			UIManager.pop(UIManager.getTopLayerName())
		end
		ModelPower.requestBuyPowerHp()   -- 恢复体力
	end
end


		

LayerSweepTimes.onClick = function(widget)
	local widgetName = widget:getName()
	if "sure" == widgetName then					-- 确认键(一次扫荡)
		sweepTimes = 1
		
		local func = {
			function()
				LayerCopyTips.updateSweepInfo()
				LayerSweepTimes.updateSweepInfo()
			end,
			nil
		}
		-- 1000 为扫荡卡ID
		if CommonFunc_payConsume(3, sweepTimes, 1000, nil, func) then
			return
		end
		
		local copyInfo = LogicTable.getCopyById(id)
		if ModelPlayer.getHpPower() < (tonumber(copyInfo.need_power + copyInfo.win_need_power) * sweepTimes) then
			local price = getPowerUpPrice(ModelPlayer.getHpPowerBuyTimes())
			local structConfirm =
			{
				strText = GameString.get("BuyPp", price,PowerConfig["init_max"]),
				buttonCount = 2,
				isPop = false,
				buttonName = {GameString.get("sure"),GameString.get("cancle")},
				buttonEvent = {power_yes,nil}, --回调函数
				buttonEvent_Param = {nil,nil} --函数参数
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)
			return
		end
		
		requestSweepByCount(sweepTimes)
		
	elseif "cancle" == widgetName then				-- 取消键（扫荡五次）（最大次扫荡）
		sweepTimes = 5
		
		local func = {
			function()
				LayerCopyTips.updateSweepInfo()
				LayerSweepTimes.updateSweepInfo()
			end,
			nil
		}
		if CommonFunc_payConsume(3, sweepTimes, 1000, nil, func) then
			return
		end
		
		local copyInfo = LogicTable.getCopyById(id)
		if ModelPlayer.getHpPower() < (tonumber(copyInfo.need_power + copyInfo.win_need_power) * sweepTimes) then
			local price = getPowerUpPrice(ModelPlayer.getHpPowerBuyTimes())
			local structConfirm =
			{
				strText = GameString.get("BuyPp", price,PowerConfig["init_max"]),
				buttonCount = 2,
				isPop = false,
				buttonName = {GameString.get("sure"),GameString.get("cancle")},
				buttonEvent = {power_yes,nil}, --回调函数
				buttonEvent_Param = {nil,nil} --函数参数
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)
			return
		end
		
		local copyInfo = LogicTable.getCopyById(id)
		maxSweepTimes = math.floor(ModelPlayer.getHpPower()/ (copyInfo.need_power + copyInfo.win_need_power))		-- 当前体力可扫荡的最大次数
		if mSweepInfo == nil or tonumber(mSweepInfo.amount) < sweepTimes then
			Toast.show(GameString.get("Sweep_Card_BZ"))
		elseif maxSweepTimes < sweepTimes then
			Toast.show(GameString.get("Public_Power_BZ"))
		else
			requestSweepByCount(sweepTimes)
		end
	elseif "close" == widgetName then
		UIManager.pop("UI_SweepTimes")
    end
end

-- 刷新扫荡卡数量
LayerSweepTimes.updateSweepInfo = function()
	if mLayerSweepTimesRoot == nil then
		return
	end
	-- 1000 为扫荡卡ID
	mSweepInfo = ModelBackpack.getItemByTempId(1000)
	local labelatlas = tolua.cast(mLayerSweepTimesRoot:getWidgetByName("LabelAtlas_sweep_card"), "UILabel")
	if mSweepInfo ~= nil then
		labelatlas:setText(tostring(mSweepInfo.amount))
	else
		labelatlas:setText(string.format("%s", 0))
	end
end

--传过来的是当前副本的副本id
LayerSweepTimes.init = function(param)	

	mLayerSweepTimesRoot = UIManager.findLayerByTag("UI_SweepTimes")
	id = param
	setOnClickListenner("sure")
	setOnClickListenner("cancle")
	setOnClickListenner("close")
	local copyInfo = LogicTable.getCopyById(id)
	--副本名
	local sweepName = tolua.cast(mLayerSweepTimesRoot:getWidgetByName("sweepName"),"UILabel")
	sweepName:setText(GameString.get("Public_Sweep",copyInfo.name))
	-- 1000 为扫荡卡ID
	mSweepInfo = ModelBackpack.getItemByTempId(1000)
	local labelatlas = tolua.cast(mLayerSweepTimesRoot:getWidgetByName("LabelAtlas_sweep_card"), "UILabel")
	if mSweepInfo ~= nil then
		labelatlas:setText(tostring(mSweepInfo.amount))
	else
		labelatlas:setText(string.format("%s", 0))
	end
end 

LayerSweepTimes.destroy = function()
	mLayerSweepTimesRoot = nil		
end

--收到一次副本扫荡结束时的回调
local function handle_clean_copy(tb)
	if tb.result == 1 then 
		local param = {}
		param.id = id
		param.count = sweepTimes 		
		param.list = tb.trophy_list
		UIManager.push("UI_Sweep",param)		
	end 
end 

NetSocket_registerHandler(NetMsgType["msg_notify_clean_up_copy_result"], notify_clean_up_copy_result, handle_clean_copy)

