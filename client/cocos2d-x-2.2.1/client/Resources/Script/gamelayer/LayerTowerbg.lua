LayerTowerbg = {}

local mLayerTowerbgRoot = nil
local mLeftTimes = 0
local mHasBuyTimes = nil

local mNewDay = true				-- 新的一天
local mDailyTimerFlag = false

local function getPushTimesharePrice(Times)
	local ReCoverExpres = LogicTable.getExpressionRow(16)	--推塔次数购买计算公式
	local valueTable = {
		{name = "Times", value = Times}
	}
	local price = ExpressionParse.compute(ReCoverExpres.expression,valueTable)
	return tonumber(price)
end 

local function sureBtnEvent()
	if CommonFunc_payConsume(2, getPushTimesharePrice(mHasBuyTimes)) then
		return
	end
	if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
		UIManager.pop(UIManager.getTopLayerName())
	end
	local tb = req_push_tower_buy_playtimes()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_buy_playtimes"])	
end

--点击购买次数调用的函数
local function pushBuyUI()
	--print("pushBuyUI",mHasBuyTimes,LIMIT_Buy_tower_times)
	if mHasBuyTimes >= LIMIT_Buy_tower_times then
		Toast.Textstrokeshow(GameString.get("Public_BuyTimes_Not_Enough"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	local structConfirm = {
		strText = GameString.get("buyTime",LIMIT_Buy_tower_times - mHasBuyTimes,getPushTimesharePrice(0)),
		buttonCount = 2,
		isPop = false,
		buttonName = {GameString.get("sure"),GameString.get("cancle")},
		buttonEvent = {sureBtnEvent,nil} --回调函数
	}	
	UIManager.push("UI_ComfirmDialog",structConfirm)
end

local function enterTower()
	if CopyDateCache.getCopyStatus(LIMIT_TOWER.copy_id) ~= "pass" and tonumber(LIMIT_TOWER.copy_id) ~= 1 then
		Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TOWER.copy_id),LIMIT_TOWER.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	end
	if mLeftTimes > 0  then 
		FightStartup.startPushTower()
	elseif mHasBuyTimes >= LIMIT_Buy_tower_times then
		Toast.Textstrokeshow(GameString.get("ACTIVITY_COPY_STR_02"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return
	else
		pushBuyUI()					
	end
end

local function onTowerClick(type,widget)
	 if type =="releaseUp" then
		TipModule.onClick(widget)
		local name =widget:getName()  --判断是点击了那个按钮
		if name == "enterGame"  then 	-- 推塔
			enterTower()
		elseif name == "buytimes" then 	--购买推塔挑战次数
			pushBuyUI()		
		end
	end
end

-- 当天到达24:00:00
local function dailyTimerOver()
	EventCenter_post(EventDef["ED_PUSHTOWER_TIMES"])
end

local function Handle_req_push_tower_buyTimes(resp)
	if resp.result == 1 then 
		--cclog("购买推塔次数成功")
		mHasBuyTimes = mHasBuyTimes + 1
		local maxLeftTime = mLayerTowerbgRoot:getChildByName("Label_28_0");
		tolua.cast(maxLeftTime, "UILabel")
		mLeftTimes = mLeftTimes + 1
		maxLeftTime:setText(string.format("%02d",mLeftTimes))
		
		mNewDay = false
		if false == mDailyTimerFlag then
			mDailyTimerFlag = true
			SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
		end
	end
end

-- 刷新技能组
local function refreshSkillGroup(rootView)
	local currSkillGroup = ModelSkill.getSkillGroup()
	for i=1, 4 do
		local skillImage = tolua.cast(rootView:getChildByName("ImageView_skill"..i), "UIImageView")
		local skill = ModelSkill.getSkill(currSkillGroup.skills[i])
		if nil == skill then
			skillImage:setTouchEnabled(false)
			skillImage:removeAllChildren()
			skillImage:loadTexture("public_runeback.png")
		else
			local function clickSkillIcon(typeName, widget)
				if "releaseUp" == typeName then
					local bundle = {}
					bundle.skill_id = skill.temp_id
					bundle.level = skill.value
					UIManager.push("UI_SkillInfo", bundle)
				end
			end
			CommonFunc_AddGirdWidget_Rune(skill.temp_id, skill.value, clickSkillIcon, skillImage)
		end
	end
end

---------------------------------------------------------------------
local getInLoad = nil
-- 设置进来的路径
LayerTowerbg.setInLoad = function(name)
	getInLoad = name
end

LayerTowerbg.init = function(rootView)
	mLayerTowerbgRoot = rootView

	local cancleBtn = mLayerTowerbgRoot:getChildByName("ImageView_34");
	cancleBtn:registerEventScript(function(typeName, widget)
	if "releaseUp" == typeName then
		if getInLoad == nil then		-- 默认从活动界面进
			TipModule.onClick(widget)
			--setConententPannelJosn(LayerActivity, "Activity.json", "Activity.json")
            setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")

		elseif getInLoad == "main" then
			TipModule.onClick(widget)
			LayerMain.pullPannel()
		end
	end
	end)

	local changeBtn = tolua.cast(rootView:getChildByName("Button_change"), "UIButton")
	changeBtn:registerEventScript(function(typeName, widget)
		if "releaseUp" == typeName then
			local bundle = {}
			bundle.callback = enterTower
			UIManager.push("UI_SkillGroup", bundle)
		end
	end)
	refreshSkillGroup(rootView)

	LayerTowerbg.refresh()
	TipModule.onUI(rootView, "ui_towerbg")
end


LayerTowerbg.refresh = function ()
	local tb = req_push_tower_info()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_info"])
end

LayerTowerbg.existAward = function()
    local Ret = false 
    if mLeftTimes ~= nil and mLeftTimes > 0 and  tonumber(LIMIT_TOWER.copy_id) ~= 1 and
		CopyDateCache.getCopyStatus(LIMIT_TOWER.copy_id) == "pass"  then 
        Ret = true 
    end 
    return Ret
end 

LayerTowerbg.destroy = function()
    mLayerTowerbgRoot = nil
	getInLoad = nil
end 

function Handle_req_push_tower_info(resp)
	
	
	FightConfig.setConfig("fc_push_tower_sever_data", resp)
    		--最高记录

	local config = FightConfig.getConfig("fc_push_tower_sever_data")
	TipFunction.setFuncAttr("func_push_tower", "count", config.play_times)
    mHasBuyTimes = config.max_times - Tower_Ora_Chan_Times - getVipAddValueById(5)
    mLeftTimes = config.max_times  - config.play_times          
	--print( config.max_times,config.play_times,getVipAddValueById(5),Tower_Ora_Chan_Times,mHasBuyTimes,mLeftTimes)
	EventCenter_post(EventDef["ED_TOWER_INFO"])
	
    if mLayerTowerbgRoot == nil then return end 
	
    --local macScore = mLayerTowerbgRoot:getChildByName("Label_28");
	--tolua.cast(macScore, "UILabel")
	--macScore:setText(string.format("%03d", config.max_floor))

	--今日可挑战次数
	local maxLeftTime = mLayerTowerbgRoot:getChildByName("Label_28_0");
	tolua.cast(maxLeftTime, "UILabel")
	
	maxLeftTime:setText(string.format("%02d",mLeftTimes)) 
		
	local Btn_enterGame = mLayerTowerbgRoot:getChildByName("enterGame")
	Btn_enterGame:registerEventScript(onTowerClick)
	
	local Btn_buyTimes = mLayerTowerbgRoot:getChildByName("buytimes")
	Btn_buyTimes:registerEventScript(onTowerClick)
end

-- 技能组改变
local function handleSkillGroupChange(data)
	if nil == mLayerTowerbgRoot or false == data.success then
		return
	end
	refreshSkillGroup(mLayerTowerbgRoot)
end

-- 挑战次数信息
EventCenter_subscribe(EventDef["ED_PUSHTOWER_TIMES"], LayerTowerbg.refresh)
EventCenter_subscribe(EventDef["ED_SKILL_GROUP_CHANGE"], handleSkillGroupChange)
NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_buy_playtimes"], notify_push_tower_buy_playtimes, Handle_req_push_tower_buyTimes)
NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_info"], notify_push_tower_info, Handle_req_push_tower_info)

