----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-26
-- 描述：主界面
----------------------------------------------------------------------
local mLayerRoot = nil						-- 主界面根节点
local mLayerThis = nil						-- 保存上一个this
local mSingleChooseBtnActionDone = false	-- 单选按钮动作是否完成
local mBtnList = {}							-- 底部按钮
local mStatus = "mainbtn_main"				-- 主界面展示状态

LayerMain = {}
LayerAbstract:extend(LayerMain)

-- 设置当前主界面展示状态
LayerMain.setCurStatus = function(status)
	mStatus = status
end 

-- 获取当前主界面展示状态
LayerMain.getCurStatus = function()
	return mStatus
	-- 对应的值
	-- "mainbtn_main"	--主页
	-- "mainbtn_hero"	--英雄
	-- "mainbtn_task"	--任务
	-- "mainbtn_rune"	--召唤
	-- "mainbtn_shop"	--商店
	-- "mainbtn_sys"		--设置
	-- "Panel_mission_build"	--战斗
	-- "Panel_jjc"		--竞技场
end

--获得当前界面的根节点
LayerMain.getLayerRoot = function()
	return mLayerRoot, "mLayerRoot"
end

-- 购买体力返回
local function handleBuyPowerHp(success)
end

--改变战斗力
local function getDetla(delta)
	local x = math.abs(delta)
	if x > 100 then 
		return math.floor(x/20)
	elseif x > 10 then 
		return math.floor(x/5)
	else
		return 1
	end
end 

local mUpdateBattleTimer = nil
local function createUpdateBattleTimer()
	if nil == mUpdateBattleTimer then
		mUpdateBattleTimer = CreateTimer(0.05, -1, function(ct)
			if nil == mLayerRoot then
				return
			end
			local battlePowerView = mLayerRoot:getWidgetByName("LabelAtlas_atk")
			tolua.cast(battlePowerView, "UILabelAtlas")
			if nil == battlePowerView then
				return
			end
			local newBattle = ct.getParam().newBattle
			local delta = ct.getParam().delta
			if newBattle > ModelPlayer.getBattlePower() then 
				ModelPlayer.setBattlePower(ModelPlayer.getBattlePower() + getDetla(delta))
				if ModelPlayer.getBattlePower() > newBattle then 
					ModelPlayer.setBattlePower(newBattle)
					battlePowerView:setStringValue(tostring(ModelPlayer.getBattlePower()))
					ct.stop()
				end 
			else 
				ModelPlayer.setBattlePower(ModelPlayer.getBattlePower() - getDetla(delta))
				if ModelPlayer.getBattlePower() < newBattle then 
					ModelPlayer.setBattlePower(newBattle)
					battlePowerView:setStringValue(tostring(ModelPlayer.getBattlePower()))
					ct.stop()
				end 
			end
			battlePowerView:setStringValue(tostring(ModelPlayer.getBattlePower()))
		end, nil)
	end
end

local function handleClearData()
	mUpdateBattleTimer = nil
end

--点击体力框确定时的回调函数
function power_yes()
	-- local powerHpPriceRow = ModelPower.getPowerHpPriceRow(ModelPlayer.getHpPowerBuyTimes() + 1)
	local powerHpPrice = ModelPower.getPowerHpPrice()
	if CommonFunc_payConsume(2, powerHpPrice) then
		return
	end
	if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
		UIManager.pop(UIManager.getTopLayerName())
	end
	ModelPower.requestBuyPowerHp()   -- 恢复体力
end

function getPowerUpPrice(Times)
	local ReCoverExpres = LogicTable.getExpressionRow(20)	--购买计算公式
	local valueTable = {
		{name = "Times", value = Times}
	}
	local price = ExpressionParse.compute(ReCoverExpres.expression,valueTable)
	return tonumber(price)
end 

LayerMain.onClick =function (weight)
	TipModule.onClick(weight)
	local weightName = weight:getName()
	if weightName == "Button_81" then		--购买体力
		local maxBuyHpTimes = PowerConfig["buy_times"]	
		if ModelPlayer.getVipLevel() > 0 then
			maxBuyHpTimes = getVipAddValueById(8) + maxBuyHpTimes
		end
		if PowerConfig["init_max"] <= ModelPlayer.getHpPower() then
			Toast.show( GameString.get("Ppfull"))
		elseif ModelPlayer.getHpPowerBuyTimes() == maxBuyHpTimes then   --传入的vip等级需要改变（进入vip升级界面）
			CommonFunc_CreateDialog(GameString.get("ShopMall_LIMITS_TIPS"))	
		elseif ModelPlayer.getHpPowerBuyTimes() < maxBuyHpTimes  then   --传入的vip等级需要改变(进入购买界面)
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
		end
	elseif weightName == "ImageView_44" then --祝福
		setConententPannelJosn(LayerBless, "bless_1.json", "LayerBless")
		--UIManager.push("UI_CopyDelock",{LIMIT_FORGE}) 	
		--UIManager.push("UI_CopyDelock",{LIMIT_FRIEND,LIMIT_HERO_UP_LEVEL,LIMIT_HERO_STREN}) --
	elseif weightName == "ImageView_45" then --vip
		setConententPannelJosn(LayerVip, LayerVip.jsonFile, "LayerVip")
	elseif weightName == "Button_82" or weightName == "actival_recharge" then		--购买魔石
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
		EventCenter_post(EventDef["ED_ENTER_RECHARGE"], "Main")
	
	elseif weightName == "ImageView_month_card" then		--月卡
		MonthCardLogic.judgeEnterMonthCardUI()
	elseif weightName == "world_chat" then
		local tb = {
			rootView = mLayerRoot,
			from = "Main",
		}
		UIManager.push("UI_WorldChat",tb)
	elseif weightName == "ImageView_clock" then
		setConententPannelJosn(LayerTipFunction, "TipFunction.json", "LayerTipFunctionUI")
	elseif weightName == "ImageView_notice" then			-- 公告
		-- setConententPannelJosn(LayerNotice, "NoticeBackgournd_1.json", "LayerNotice")
		UIManager.push("UI_Notice")
	elseif weightName == "daily_crazy" then		  -- 每日活跃
		setConententPannelJosn(LayerDailyCrazy, "DailyCrazyPanel.json", "LayerDailyCrazyUI")
	elseif weightName == "ImageView_invite_friend" then		  -- 邀请
		-- setConententPannelJosn(LayerSocialContactEnter, "SocialContact.json", "LayerSocialContactEnterUI")
		UIManager.push("UI_InviteCode")
	elseif weightName == "ImageView_spring_activity" then		-- 春节活动
		local actJudge = false
		for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
			if key <= 2 and actJudge ~= true then
				actJudge = SpringActivityLogic.isTimeValidById(value.id)
			end
		end
		if actJudge == false then
			Toast.show( GameString.get("SPRING_ACTIVITY_TIP_4"))
			return
		end
		setConententPannelJosn(LayerSpringActivity, "springactivity_1.json", "LayerSpringActivityUI")
	--[[
	elseif weightName == "ImageView_mail" then
		if nil ~= MailLogic.getEmail() then
			UIManager.push("UI_mail")
	end	
	]]--
	end
end

--根据当前的祝福信息，设置主界面祝福的图标
LayerMain.setMainBlessIcon = function(curBuffIcon)
	if nil == mLayerRoot then
		return
	end
	local blessIcon = mLayerRoot:getWidgetByName("ImageView_44")
	tolua.cast(blessIcon,"UIImageView")
	if curBuffIcon ~= nil then
		blessIcon:loadTexture(curBuffIcon)
	else	
		blessIcon:loadTexture("touming.png")
	end
end

function LayerMain_onClick(widget)
	TipModule.onClick(widget)
	local weightName = widget:getName()
	CopyDelockLogic.setTipShow(mLayerRoot,weightName,"mLayerRoot")
	if weightName == "mainbtn_main" then	--主页
		LayerMain.pullPannel()
	elseif weightName == "mainbtn_hero" then		--英雄
		setConententPannelJosn(LayerBackpack,"Backpack_Main.json",weightName)		
	elseif weightName == "mainbtn_task" then		-----任务
		setConententPannelJosn(LayerTask, "TaskPanel.json",weightName)
    elseif weightName == "mainbtn_rune" then   --召唤
		setConententPannelJosn(LayerRune,"Rune_1.json",weightName)
	elseif weightName == "mainbtn_shop" then
		-- setConententPannelJosn(LayerShopMall,LayerShopMall.jsonFile, weightName)
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
		EventCenter_post(EventDef["ED_ENTER_RECHARGE"], "Main")
	elseif weightName == "mainbtn_sys" then    --设置 
		UIManager.push("UI_More")
	end
end

function LayerMain.getContendPanel()
	if nil == mLayerRoot then
		return nil
	end
	return tolua.cast(mLayerRoot:getWidgetByName("sencond_contend"), "UILayout")
end

function LayerMain.pullPannel(this)
	TipModule.onUI(mLayerRoot, "ui_main")
	if "mainbtn_main" == LayerMain.getCurStatus() then
		return
	end
	if mLayerThis and "function" == type(mLayerThis.destroy) then
		mLayerThis.destroy()
	end
	mLayerThis = nil
	local Panel_act_contend =  mLayerRoot:getWidgetByName("sencond_contend")
	mLayerRoot:setTouchEnabled(false)
	local downIng = CCEaseBackInOut:create(CCMoveBy:create(0.3,CCPointMake(0,(1)*800)))
	local arr = CCArray:create()
    arr:addObject(downIng)
    arr:addObject(CCCallFunc:create(function ()
		mLayerRoot:setTouchEnabled(true)
		if this ~= nil then 
			Panel_act_contend:removeAllChildren()
			this.destroy()		--这里调用一次	FIXME
		end 
	end))
	Panel_act_contend:runAction(CCSequence:create(arr))
	
	LayerMain.setCurStatus("mainbtn_main")
	LayerMain.choiceBtnListValueByName("mainbtn_main")
	Audio.playEffectByTag(6)
	
	-- 更新竞技场推送消息气泡数量
	LayerMainEnter.showGameRankMsgTips()
	-- 更新每日活跃
	LayerMain.showDailyCrazyTip()
	-- 更新公告提示
	LayerMain.showNoticeTip()
end

function setConententPannelJosn(layer, josnfile, status)
	local oldStatus = LayerMain.getCurStatus()
	if status == oldStatus then
		return
	end
	LayerMain.setCurStatus(status)
	if mLayerThis and "function" == type(mLayerThis.destroy) then
		mLayerThis.destroy()
	end
	mLayerThis = layer
	if nil == mLayerRoot then
		return
	end
	local secondContendPanel = tolua.cast(mLayerRoot:getWidgetByName("sencond_contend"), "UILayout")
	secondContendPanel:removeAllChildren()
	secondContendPanel:setEnabled(true)
	if nil == josnfile then
		return
	end
	local jsonWidget = LoadWidgetFromJsonFile(josnfile)
	jsonWidget:setAnchorPoint(ccp(0.0, 0.0))
	secondContendPanel:addChild(jsonWidget)
	-- 
	if "mainbtn_main" == oldStatus then
		FightAnimation_drop(secondContendPanel, 800)
	end
	
	if "mainbtn_main" == status  then
		LayerLvUp.setEnterLvMode(1)
		CopyDelockLogic.enterCopyDelockLayer()
	elseif "mainbtn_sys" == status then
		secondContendPanel:setBackGroundImage("touming.png")
	else
		secondContendPanel:setBackGroundImage("public2_Decoration_0.png")
	end
	LayerMain.choiceBtnListValueByName(status)
	layer.init(secondContendPanel, {content=jsonWidget})
	Audio.playEffectByTag(6)
end

local tempRatio = 0
--设置经验进度条，值变化时的动画(百分比 )
local function setExpMoveAction(ratio)
	if tempRatio == ratio then
		return
	end
	tempRatio = ratio
	local loadingBar = mLayerRoot:getWidgetByName("ExpImg")	-- power_bar
	tolua.cast(loadingBar,"UIImageView")
	local function actionFunc()
		local scaleAction = nil
		if ratio <= 1.0 then
			scaleAction = CCScaleTo:create(2.0, ratio, 1.0)
		else
			scaleAction = CCScaleTo:create(2.0, 1, 1.0)
		end
		loadingBar:runAction(scaleAction)
	end
	
	actionFunc()
end

local function setPowUpLoadingBar(value)
	local num = PowerConfig["init_max"]  --体力恢复上限值 --ModelPower.getMaxPowerHp(ModelPlayer.getLevel())	
	if num ~= nil then
		local power_hp = value
		local ratio = power_hp/num 
		
		setExpMoveAction(ratio)
		
		local powerCurText = mLayerRoot:getWidgetByName("Label_46")		--体力当前数值
		tolua.cast(powerCurText, "UILabel")
		local pp = string.format("/%d",num)
		powerCurText:setText(power_hp..pp)
	end
end

LayerMain.updateHeroIcon = function()
	if mLayerRoot == nil then 
		return
	end 
	local playerIcon = tolua.cast(mLayerRoot:getWidgetByName("hero_imageview"), "UIImageView")
	
	if playerIcon == nil then 
		return 
	end 
	playerIcon:loadTexture(ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel()).heroicon)

end 

-- 事件机制派发
local function updateRoleInfo(infoType)
	if nil == mLayerRoot or 0 == ModelPlayer.getId() then
		return
	end
	if 0 == ModelPlayer.getId() then
		return
	end
	local newLevel, oldLevel = ModelPlayer.getLevel()
	-- 设置体力进度条
	setPowUpLoadingBar(ModelPlayer.getHpPower())
	-- 经验条
	local playerExp = tolua.cast(mLayerRoot:getWidgetByName("main_player_exp"), "UILoadingBar")
	local ratio = ModelPlayer.getRoleExpPercent(newLevel, ModelPlayer.getExp())
	playerExp:setPercent(ratio)
	-- 经验百分比
	local exp_precent = tolua.cast(mLayerRoot:getWidgetByName("exp_precent"), "UILabel")
	exp_precent:setText(string.format("%d%%",math.floor(ratio)))
	-- 头像
	local playerIcon = tolua.cast(mLayerRoot:getWidgetByName("hero_imageview"), "UIImageView")
	playerIcon:loadTexture(ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel()).heroicon)
	playerIcon:setTouchEnabled(true)
	if true == CONFIG["debug"] then
		playerIcon:registerEventScript(function(typeName, widget)
			if "releaseUp" == typeName then
				UIManager.push("UI_GM")
			end
		end)
	else
		playerIcon:registerEventScript(function(typeName, widget)
			if "releaseUp" == typeName then
				if  tonumber(LIMIT_HERO_UP_LEVEL.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_HERO_UP_LEVEL.copy_id) == false then
					Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_HERO_UP_LEVEL.copy_id),LIMIT_HERO_UP_LEVEL.fbName))
					return
				end
				setConententPannelJosn(LayerRoleUp, LayerRoleUp.jsonFile, widgetName)
			end
		end)
	end
	-- 名字
	local nameText = tolua.cast(mLayerRoot:getWidgetByName("Player_Name"), "UILabel")
	nameText:setText(ModelPlayer.getNickName())
	-- 等级
	local Lv = tolua.cast(mLayerRoot:getWidgetByName("LabelAtlas_42"), "UILabelAtlas")
	Lv:setStringValue(tostring(newLevel))
	-- 等级升级弹框
	if "all" == infoType or "level" == infoType then
		if newLevel > oldLevel then
			local tb = {}
			tb.targetName = "UI_LvUp"
			tb.param = {}
			tb.param.lastNum = oldLevel
			tb.param.curNum = newLevel
			-- 升级了要弹框
			UIManager.addBouncedWindow(tb)
			
			EventCenter_post(EventDef["ED_LV_UP"])
		end
	end 
	-- 金币
	local moneyTest = tolua.cast(mLayerRoot:getWidgetByName("LabelAtlas_gold"), "UILabelAtlas")
	moneyTest:setStringValue(tostring(ModelPlayer.getGold()))
	-- 人民币
	local eMoneyTest = tolua.cast(mLayerRoot:getWidgetByName("LabelAtlas_rmb"), "UILabelAtlas")
	eMoneyTest:setStringValue(tostring(ModelPlayer.getEmoney()))
	
	-- VIP等级
	local lvLabAas = tolua.cast(mLayerRoot:getWidgetByName("vip_lv"),"UILabelAtlas")
	lvLabAas:setStringValue(tostring(ModelPlayer.getVipLevel()))
	
	-- 剩余体力
	local playerPowerUpTest = tolua.cast(mLayerRoot:getWidgetByName("power_time"), "UILabel")
	playerPowerUpTest:setText(CommonFunc_secToString(ModelPlayer.getRecoverTimeLeft())) 
	-- 战斗力
	local newBattlePower, oldBattlePower = ModelPlayer.getBattlePower()
	local attack = tolua.cast(mLayerRoot:getWidgetByName("LabelAtlas_atk"), "UILabelAtlas")
	attack:setStringValue(tostring(newBattlePower))
	-- 战斗力动画
	if "all" == infoType or "battle_power" == infoType then
		local battlePowerDelta = newBattlePower - oldBattlePower
		if battlePowerDelta > 0 then
			local battlePowerParam = {}
			battlePowerParam.newBattle = newBattlePower
			battlePowerParam.delta = battlePowerDelta
			createUpdateBattleTimer()
			mUpdateBattleTimer.setParam(battlePowerParam)
			mUpdateBattleTimer.start()
		end
	end
end

function initMiddleContentBackground()
	local WinSize = CCDirector:sharedDirector():getWinSize()
	local CLOUD_SIZE = 864		--云层的像素宽度
	
	local function createCloud(point,fileName,fly_time)
		local cloud =  UIImageView:create()
		cloud:loadTexture(fileName)
		cloud:setPosition(point)	
		
		local action = CCSequence:createWithTwoActions(
			CCMoveBy:create(fly_time,ccp(CLOUD_SIZE,0)),
			CCCallFunc:create(function()
				local pos = cloud:getPosition()
				local newPos = ccp(pos.x - CLOUD_SIZE,pos.y)
				cloud:setPosition(newPos)
			end)
			)
		
		cloud:runAction(CCRepeatForever:create(action))
		return cloud
	end

	-- set 二级底框
	local uiPannel =  mLayerRoot:getWidgetByName("sencond_contend")
	tolua.cast(uiPannel,"UILayout")
	uiPannel:setBackGroundImage("public2_Decoration_0.png")
	uiPannel:setEnabled(false)
	-- 主页背景
	local Panel_contend =  mLayerRoot:getWidgetByName("Panel_contend")	--主页跟节点
	tolua.cast(Panel_contend,"UILayout")
	
	local dragPanel = UIScrollView:create()
	dragPanel:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	dragPanel:setTouchEnabled(true)
	dragPanel:setSize(WinSize)
	dragPanel:setBounceEnabled(true)
	
	--add cloud
	Panel_contend:addChild(dragPanel)
	
	local ContentView = GUIReader:shareReader():widgetFromJsonFile("MainEnter.json")
	local reduce = 223-5
	local RealSize = CCSizeMake(ContentView:getSize().width - reduce*2,
	ContentView:getSize().height)
	--local detalX = RealSize.width/2 - WinSize.width/2
	ContentView:setPosition(ccp(-reduce,0))
	dragPanel:setInnerContainerSize(RealSize)
	dragPanel:addChild(ContentView);	
	dragPanel:addChild(createCloud(ccp(0,639),"main_cloud1.png",12))
	dragPanel:addChild(createCloud(ccp(-30,447),"main_cloud2.png",14))
	dragPanel:addChild(createCloud(ccp(0,850),"main_cloud3.png",15))
	dragPanel:addChild(createCloud(ccp(-50,182),"main_cloud4.png",16))
	
	LayerMainEnter.init(Panel_contend)
end

--获得底部的各个的位置
LayerMain.getBtnPosition = function()
	local tb ={}
	for key,value in pairs(mBtnList) do
		table.insert(tb,value.position)
	end
	return tb
end

local mflag =true	--表示第一次进入，底部需要加载动画
local formalSize ={CCSizeMake(83,83),CCSizeMake(77,82),CCSizeMake(81,83),CCSizeMake(85,80),CCSizeMake(85,82),CCSizeMake(80,79)}
local lightSize = {CCSizeMake(100,102),CCSizeMake(95,102),CCSizeMake(99,99),CCSizeMake(108,101),CCSizeMake(98,100),CCSizeMake(95,100)}

local function initButtonAndEvent(mflag)
	if mLayerRoot == nil then
		return
	end
	mBtnList = {}
	local function ceateBtnList(widgetName,N_ImageName,H_ImageName,N_ImageName_Text,H_ImageName_Text,isBright,isLock,key) 
		local widgetSingle = {}
		widgetSingle.isBright = isBright		--是否高亮
		widgetSingle.name = widgetName
		widgetSingle.N_image = N_ImageName
		widgetSingle.H_image = H_ImageName
		widgetSingle.N_ImageName_Text = N_ImageName_Text
		widgetSingle.H_ImageName_Text = H_ImageName_Text
		widgetSingle.isLock = isLock			--是否解锁（true表示解锁了，false表示还没有）
		widgetSingle.text_widget = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_text",widgetName)), "UIImageView")
		widgetSingle.lock_widget = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_lock",widgetName)), "UIImageView")
		widgetSingle.widget = tolua.cast(mLayerRoot:getWidgetByName(widgetName), "UIImageView")
		 
		local widget = tolua.cast(mLayerRoot:getWidgetByName(widgetName), "UIImageView")
		widgetSingle.position = tolua.cast(mLayerRoot:getWidgetByName(widgetName), "UIImageView"):getPosition()
		local text_widget = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_text",widgetName)), "UIImageView")
		local lock_widget = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_lock",widgetName)), "UIImageView")
		if isLock == true then		--已经解锁
			lock_widget:setVisible(false)
			if isBright == true then
				widgetSingle.widget:loadTexture(widgetSingle.H_image)
				widgetSingle.widget:setSize(lightSize[key])
			else
				widgetSingle.widget:loadTexture(widgetSingle.N_image)
				widgetSingle.widget:setSize(formalSize[key])
			end
		else						--还未解锁
			lock_widget:setVisible(true)
			widgetSingle.widget:loadTexture("touming.png")	
			widgetSingle.widget:setSize(formalSize[key])
		end
		if isBright == true then
			if text_widget ~= nil then
				text_widget:loadTexture(widgetSingle.H_ImageName_Text)	
			end
		end
		
		table.insert(mBtnList,widgetSingle)
	end	

	local flagTb = CopyDelockLogic.getAllDownFlag()
	ceateBtnList("mainbtn_main","mainui_btn_mainui_n.png","mainui_btn_mainui_h.png","mainui_btn_mainui_n_text.png",
				"mainui_btn_mainui_h_text.png",true,flagTb[1],1)
	
	ceateBtnList("mainbtn_hero",	"mainui_btn_hero_n.png","mainui_btn_hero_h.png","mainui_btn_hero_n_text.png",
				"mainui_btn_hero_h_text.png",false,flagTb[2],2)
	
	ceateBtnList("mainbtn_task", "mainui_btn_task_n.png","mainui_btn_task_h.png","mainui_btn_task_n_text.png",
				"mainui_btn_task_h_text.png",false,flagTb[3],3)
	
	ceateBtnList("mainbtn_rune",	"mainui_btn_friend_n.png","mainui_btn_friend_h.png","mainui_btn_friend_n_text.png",
				"mainui_btn_friend_h_text.png",false, flagTb[4],4)
				
	ceateBtnList("mainbtn_shop",	"mainui_btn_busniss_n.png","mainui_btn_busniss_h.png","mainui_btn_busniss_n_text.png",
				"mainui_btn_busniss_h_text.png",false,flagTb[5],5)
				
	ceateBtnList("mainbtn_sys",	"mainui_btn_setup_n.png","mainui_btn_setup_h.png","mainui_btn_setup_n_text.png",
				"mainui_btn_setup_h_text.png",false,flagTb[6],6)
	
	SetSingleChooseBtn(mflag)

end

--设置底部未解锁的底部按钮灰态(有待改变*************************)
function LayerMain.bottomBtnListGrey()
	initButtonAndEvent(false)
end

-- 强设底部按钮视图(如果为当前视图则不予处理直接return)
LayerMain.choiceBtnListValueByName = function(curName)
	if curName == nil then 
		return
	end 
	local widget = tolua.cast(mLayerRoot:getWidgetByName(curName), "UIImageView")
	local widget_text = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_text",curName)), "UIImageView")
	local widget_lock = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_lock",curName)), "UIImageView")
	
	if nil == widget  or  nil == widget_text or nil == widget_lock then 
		return
	end
	
	local curValue = nil
	local index = 1
	for key,value in pairs(mBtnList) do	
		local widget_text = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_text",value.name)), "UIImageView")
		local widget_lock = tolua.cast(mLayerRoot:getWidgetByName(string.format("%s_lock",curName)), "UIImageView")
		if value.isLock == true then	--已经解锁
			if value.isBright == true then
				if curName == value.name then 
					return
				end
				value.widget:loadTexture(value.N_image)
				value.widget:setSize(formalSize[key])
				widget_text:loadTexture(value.N_ImageName_Text)	
				value.isBright = false
			end 
		else							--还未解锁
			if value.isBright == true then
				if curName == value.name then 
					return
				end
				value.widget:loadTexture("touming.png")
				value.widget:setSize(formalSize[key])
				widget_text:loadTexture(value.N_ImageName_Text)	
				value.isBright = false
			end 
		end
		if curName == value.name then 		--当前点击的按钮tb
			curValue = value
			index = key
		end	
	end
	
	if curValue ~= nil then
		if curValue.isLock == true then
			widget:loadTexture(curValue.H_image)
			widget:setSize(lightSize[index])
			widget_lock:setVisible(false)
		else
			widget:loadTexture("touming.png")
			widget:setSize(formalSize[index])
			widget_lock:setVisible(true)
		end
		widget_text:loadTexture(curValue.H_ImageName_Text)
		curValue.isBright = true
	end
end 
-- 强设底部按钮视图 + 点击
LayerMain.switchLayer = function(widgetName) 
	if mLayerRoot == nil then
		return
	end
	local widget = mLayerRoot:getWidgetByName(widgetName)
	LayerMain.choiceBtnListValueByName(widgetName)
	LayerMain_onClick(widget)
end

function SetSingleChooseBtn(vflag)	
	mSingleChooseBtnActionDone = false
	local function handle_onClick(typeName,widget) 
		if typeName == "releaseUp" then
			TipModule.onClick(widget)
			local curName = widget:getName()
			LayerMain.switchLayer(curName)
		end
	end
	-- btn animation
	local function btnEnterAnimation(widget,delayTime,index,flag)
		if flag ==false then
			return
		end
		
		local _FLYTIME = 0.3	--
	
		local m_iScreenSize = CCDirector:sharedDirector():getVisibleSize()
		local pos = widget:getPosition()
		local widgetWidth = widget:getContentSize().width
		
		local flyPathDis = pos.x - widgetWidth/2
		flyPathDis = m_iScreenSize.width - flyPathDis

		local newPos = ccp(m_iScreenSize.width + widgetWidth/2 ,pos.y)	
		widget:setPosition(newPos)
		
		widget:setScale(0.2)
	
		local action1 = CCDelayTime:create(delayTime);			--延迟
		local action2_1 = CCScaleTo:create(_FLYTIME, 1.2);	--变大
		local action2_2 = CCEaseSineOut:create(CCMoveBy:create(_FLYTIME,CCPointMake((-1)*flyPathDis,0))) --加速移动
		local action2 = CCSpawn:createWithTwoActions(action2_1,action2_2)
		local action3 = CCScaleTo:create(0.1, 1.0);
				
		local arr = CCArray:create()
		arr:addObject(action1)
		arr:addObject(action2)
		arr:addObject(action3)
		if index ==  #mBtnList then
			arr:addObject(CCCallFunc:create(function()
				mLayerRoot:setTouchEnabled(true)
				mSingleChooseBtnActionDone = true
				LayerMain.AcitonDone_CallBack()
				if GuideMgr.guideStatus() == 0 and LayerNotice.isPush() == true then
					UIManager.push("UI_Notice")
				end
			end))
		end
		widget:runAction(CCSequence:create(arr))
	end
	
	for k,v in pairs(mBtnList) do
		local name,flag,group = CopyDelockLogic.getNameAndFlagByWidgetName(v.name)
		if v.isLock == true then
			v.widget:registerEventScript(handle_onClick)
		else
			v.widget:registerEventScript(function(typeName,widget) 
					TipModule.onClick(widget)
					if typeName == "releaseUp" then
						Toast.show(GameString.get("Public_Pass_Copy",group,name))
					end
					LayerMain.choiceBtnListValueByName(v.name)
				end)
		end
		if vflag == false then
			mSingleChooseBtnActionDone = true
			LayerMain.AcitonDone_CallBack()
		end
		if mflag ~= false then
			btnEnterAnimation(v.widget,0.15+k*0.15+OPEN_THE_DOOR_TIME,k,vflag)
		end
		
		
	end
	mflag = false
end


--主界面 起始动画
local function LayerMainInitAnimation()
	local FLYTIME = 0.2
	local  topView = mLayerRoot:getWidgetByName("topView")
	Animation_setUIUpFallDown(topView,OPEN_THE_DOOR_TIME,FLYTIME)
	
	local  bottomView = mLayerRoot:getWidgetByName("buttomview")
	Animation_setUIDonwFlyOut(bottomView,OPEN_THE_DOOR_TIME,FLYTIME)
end

-- 任务数量提示
LayerMain.showTaskTip = function(taskInfos)
	if nil == mLayerRoot or false == mSingleChooseBtnActionDone then
		return
	end
	local taskTipIcon = mLayerRoot:getWidgetByName("mainbtn_task_tip")
	if CopyDateCache.getCopyStatus(LIMIT_MISSION.copy_id) ~= "pass" and tonumber(LIMIT_MISSION.copy_id) ~= 1 then
		taskTipIcon:setVisible(false)
		return false
	end

	local num = #(TaskLogic.getFinishedTaskList())
	local flag
	if num > 0 then
		flag = true
		taskTipIcon:setVisible(true)
	else
		flag = false
		taskTipIcon:setVisible(false)
	end
	return flag
end

-- 背包新增装备提示
LayerMain.showNewAppenEquipTip = function()
	if nil == mLayerRoot or false == mSingleChooseBtnActionDone then
		return
	end
	
	local newAppendEquipTipIcon = mLayerRoot:getWidgetByName("mainbtn_hero_tip")
	if CopyDateCache.getCopyStatus(LIMIT_HERO.copy_id) ~= "pass" and  tonumber(LIMIT_HERO.copy_id) ~= 1 then
		newAppendEquipTipIcon:setVisible(false)
		return false
	end
	
	local falg = LayerBackpack.existNewAppendEquip()
	
	if true == falg then
		newAppendEquipTipIcon:setVisible(true)
	else
		newAppendEquipTipIcon:setVisible(false)
	end
	return	falg
end

-- 可召唤提示
LayerMain.showRuneTip = function()
	if nil == mLayerRoot then
		return
	end
	
	local socialTipIcon = mLayerRoot:getWidgetByName("mainbtn_rune_tip")
	if CopyDateCache.getCopyStatus(LIMIT_Social.copy_id) ~= "pass"  then
		socialTipIcon:setVisible(false)
		return false
	end
	
	local flag = LayerRune.isShowTip()
	socialTipIcon:setVisible(flag)
	return	flag
end

-- 每日活跃提示
LayerMain.showDailyCrazyTip = function()
	if nil == mLayerRoot then
		return
	end
	local dailyCrazyTipIcon = mLayerRoot:getWidgetByName("daily_crazy_tip")
	local flag = DailyActivenessLogic.existAward()
	dailyCrazyTipIcon:setVisible(flag)
	return	flag
end

-- 公告提示
LayerMain.showNoticeTip = function()
	if nil == mLayerRoot then
		return
	end
	local noticeTipIcon = mLayerRoot:getWidgetByName("notice_tip")
	local flag = (nil ~= MailLogic.getEmail())
	noticeTipIcon:setVisible(flag)
	return	flag
end

--更多功能提示
LayerMain.showMoreTip = function()
	if nil == mLayerRoot then
		return
	end
	
	local moreIcon = mLayerRoot:getWidgetByName("mainbtn_sys_tip")
	local falg = false
	--print("LayerMain.showMoreTip*********************",LayerMore.getSocialContactTip())
	if LayerMore.getSocialContactTip() then
		falg = true
	end
	moreIcon:setVisible(falg)
	return	falg
end

-- 提示时钟震动
local mTipClockPos = nil
local function initTipClockShake()
	local tipClock = mLayerRoot:getWidgetByName("ImageView_clock")
	if nil == mTipClockPos then
		mTipClockPos = {x = tipClock:getPosition().x, y = tipClock:getPosition().y}
	end
	CreateTimer(5, 0, 
		function(tm)
			if nil == mLayerRoot then
				return
			end
			local shake = CCSequence:createWithTwoActions(CCMoveBy:create(0.05, ccp(-5, 0)), CCMoveBy:create(0.05, ccp(5, 0)))
			local callFunc = CCCallFunc:create(
				function()
					tipClock:setPosition(ccp(mTipClockPos.x, mTipClockPos.y))
				end
			)
			tipClock:runAction(CCSequence:createWithTwoActions(CCRepeat:create(shake, 5), callFunc))
		end
		,nil
	).start()
end

-- 每日任务震动 daily_crazy
local mTipDailyCrazyPos = nil
local function initDailyCrazy()
	local tipClock = mLayerRoot:getWidgetByName("daily_crazy")
	if nil == mTipDailyCrazyPos then
		mTipDailyCrazyPos = {x = tipClock:getPosition().x, y = tipClock:getPosition().y}
	end
	CreateTimer(3, 0, 
		function(tm)
			if nil == mLayerRoot then
				return
			end
			local shake = CCSequence:createWithTwoActions(CCMoveBy:create(0.05, ccp(-5, 0)), CCMoveBy:create(0.05, ccp(5, 0)))
			local callFunc = CCCallFunc:create(
				function()
					tipClock:setPosition(ccp(mTipDailyCrazyPos.x, mTipDailyCrazyPos.y))
				end
			)
			tipClock:runAction(CCSequence:createWithTwoActions(CCRepeat:create(shake, 5), callFunc))
		end
		,nil
	).start()
end

-- 体力计数计时
local mResTimer = nil
local function resTimerRunCF(tm)
	local flagTimer = nil
	local playerPowerUp = nil
	if (ModelPlayer.getHpPower() < PowerConfig["init_max"]) then
		ModelPlayer.setRecoverTimeLeft(ModelPlayer.getRecoverTimeLeft() - 1)
		if(ModelPlayer.getRecoverTimeLeft() <= 0 ) then
			ModelPlayer.setRecoverTimeLeft(ModelPower.getRecoverSeconds())     --300秒回复一次体力
			ModelPlayer.setHpPower(ModelPlayer.getHpPower() + ModelPower.getRecoverPowerHp())    --(每次恢复几点体力)
			playerPowerUp = ModelPlayer.getHpPower()
		end
	else
		flagTimer = "full"
	end
	
	if tolua.isnull(mLayerRoot) then
		return
	end

    if tolua.isnull(mLayerRoot) then 
        return
    end 
	
	if ModelPlayer.getHpPower() ~= nil then
		if (playerPowerUp ~= nil) then
			setPowUpLoadingBar(playerPowerUp)
		end
		local playerPowerUpTest = mLayerRoot:getWidgetByName("power_time")	-- 剩余体力
		tolua.cast(playerPowerUpTest, "UILabel")
		if flagTimer == "full" then
			playerPowerUpTest:setVisible(false)
		else
			playerPowerUpTest:setVisible(true)
			playerPowerUpTest:setText(CommonFunc_secToString(ModelPlayer.getRecoverTimeLeft()))
		end
	end
end

-- 更新体力值
local function updatePowerUp(dt)
	local playerPowerUp = nil
	if ModelPlayer.getHpPower() ~= nil then
		if (ModelPlayer.getHpPower() < PowerConfig["init_max"]) then
			ModelPlayer.setRecoverTimeLeft(ModelPlayer.getRecoverTimeLeft() - dt)
			if(ModelPlayer.getRecoverTimeLeft() <= 0 ) then
				ModelPlayer.setRecoverTimeLeft(ModelPower.getRecoverSeconds())     --300秒回复一次体力
				ModelPlayer.setHpPower(ModelPlayer.getHpPower() + ModelPower.getRecoverPowerHp())    --(每次恢复几点体力)
				playerPowerUp = ModelPlayer.getHpPower()
			end
			return CommonFunc_secToString(ModelPlayer.getRecoverTimeLeft()),playerPowerUp
		else
			return "full"
		end
	end
end

LayerMain.update = function(dt)
	if nil == mLayerRoot then
		return
	end
	-- local leftTime, powerUp = updatePowerUp(dt)
	-- cclog("====================================================>")
	-- Log(leftTime, powerUp)
	-- if (leftTime)then
		-- if (powerUp ~= nil)then
			-- setPowUpLoadingBar(powerUp)
		-- end
		-- local playerPowerUpTest = mLayerRoot:getWidgetByName("power_time")	-- 剩余体力
		-- tolua.cast(playerPowerUpTest, "UILabel")
		-- if leftTime == "full" then
			-- playerPowerUpTest:setVisible(false)
		-- else
			-- playerPowerUpTest:setVisible(true)
			-- playerPowerUpTest:setText(leftTime)
		-- end
	-- end
	
	-- cclog("--------------------------------------------------->")
	-- Log(ModelPlayer.getRecoverTimeLeft())
	-- if mResTimer == nil then
		-- mResTimer = CreateTimer(1, 0, resTimerRunCF, resTimerOverCF)
		-- mResTimer.start()
	-- end
end

-- 月卡信息
local function handleMonthCardInfo()
	if nil == mLayerRoot then
		--print("handleMonthCardInfo*********************我为空*******************")
		return
	end
	local monthCardDaysImg = tolua.cast(mLayerRoot:getWidgetByName("ImageView_month_card"), "UIImageView")
	
	local monthCardDaysLabel = tolua.cast(mLayerRoot:getWidgetByName("LabelAtlas_month_card_days"), "UILabelAtlas")
	local remainDays = MonthCardLogic.getRemainDays()
	
	--print("handleMonthCardInfo*****************",remainDays)
	if 0 == remainDays then
		monthCardDaysLabel:setVisible(false)
		monthCardDaysImg:loadTexture("mainui_yueka_no.png")
	else
		monthCardDaysImg:loadTexture("mainui_yueka.png")
		monthCardDaysLabel:setVisible(true)
		--monthCardDaysLabel:setText(tostring(remainDays)..GameString.get("PUBLIC_TIAN"))
		monthCardDaysLabel:setStringValue(tostring(remainDays))
	end
end

LayerMain.init = function(bound)	
	--print("LayerMain.init*****************init******************************")
	LayerMain.setCurStatus("mainbtn_main")
	LayerMain.Timer = true		--开启定时器
	mLayerRoot = UIManager.findLayerByTag("UI_Main")
	
	setOnClickListenner("Button_81")	--购买体力
	setOnClickListenner("ImageView_44")	--祝福
	setOnClickListenner("ImageView_45")	--vip
	setOnClickListenner("Button_82")	--购买魔石
	setOnClickListenner("actival_recharge")  -- 充值返利
	--setOnClickListenner("actival_reward")--激活码领取奖励
	--setOnClickListenner("ImageView_mail")--邮件
	--setOnClickListenner("ImageView_clock")							--提示时钟(	暂时注释掉)
	setOnClickListenner("ImageView_month_card")--月卡奖励
	setOnClickListenner("world_chat")  --世界聊天
	setOnClickListenner("ImageView_notice")  -- 公告
	setOnClickListenner("daily_crazy")  -- 每日活跃
	setOnClickListenner("ImageView_invite_friend")  -- 邀请
	
	---------------------------------------------------------------------------------------------------------------------------------------
	-- 春节活动按键
	local actJudge = false
	for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
		if key <= 2 and actJudge ~= true then
			actJudge = SpringActivityLogic.isTimeValidById(value.id)
		end
		if tonumber(value.id) == 1 then
			LayerSpringDraw.setTime(value.begin_time_array, value.end_time_array)
		elseif tonumber(value.id) == 2 then
			LayerSpringRecharge.setTime(value.begin_time_array, value.end_time_array)
		end
	end
	setOnClickListenner("ImageView_spring_activity")	-- 春节活动
	local btn_spring_activity = mLayerRoot:getWidgetByName("ImageView_spring_activity")	-- 春节活动按钮
	btn_spring_activity:setVisible(actJudge)
	btn_spring_activity:setTouchEnabled(actJudge)
	----------------------------------------------------------------------------------------------------------------------------------------
	
	local loadingBar = mLayerRoot:getWidgetByName("ExpImg")	-- power_bar
	tolua.cast(loadingBar,"UIImageView")
	loadingBar:setScaleX(0)
	
	
	local monthCardDaysLabel = tolua.cast(mLayerRoot:getWidgetByName("LabelAtlas_month_card_days"), "UILabelAtlas")
	local monthCardDaysImg = tolua.cast(mLayerRoot:getWidgetByName("ImageView_month_card"), "UIImageView")
	
	monthCardDaysLabel:setVisible(false)
	monthCardDaysImg:loadTexture("mainui_yueka_no.png")
	
	LayerMainInitAnimation()
	initButtonAndEvent(bound)
	updateRoleInfo("all")
	--LayerMain.showMailAndDHM()
	initMiddleContentBackground()
	initTipClockShake()
	initDailyCrazy()
	UIManager.push("UI_DoorForOpen")
	
	-- 体力定时器
	if mResTimer == nil then
		mResTimer = CreateTimer(1, 0, resTimerRunCF, resTimerOverCF)
		mResTimer.start()
	end
end

-- 更新pannel
LayerMain.updatePannel = function(pannelNode, ...)
	-- 竞技场
	local args = {...} 
	LayerGameRank.updateUI(args[1])
	-- 训练赛	
	LayerGameTrain.updateUI(args[1])
end

-- 返回主菜单要处理的事件类型 EventType：事件类型 ,param 额外参数,战斗请求码
--EventType: 回主菜单  事件   --EnterCode 进入战斗之前
LayerMain.onEventForResult = function(EventType, param, EnterCode)
	if EventType == "bag" then -- 背包已满 
		setConententPannelJosn(LayerBackpack,"Backpack_Main.json","mainbtn_hero")		
	elseif 	EnterCode == "New_Player" then 
		--
	elseif EnterCode == "enter_Copy" then 
		LayerCopy.refresh(EventType)
    elseif EnterCode == "enter_CopyBoss" then 
        LayerChenallBoss.refresh()
	elseif EnterCode == "enter_Tower" then
		LayerTowerbg.refresh()
	else
		if EventType then
			LayerMain.updatePannel(EventType, param)
			TipModule.onUI(mLayerRoot, "ui_main")
		end
	end
	--LayerMain.showMailAndDHM()
end

--任务立即前往
local function handler_TaskToCopy(param)
    if  CopyDateCache.isBossByCopyId (param) == true then 
        setConententPannelJosn(LayerChenallBoss,LayerChenallBoss.josnFile,LayerChenallBoss.josnFile)
        --LayerChenallBoss.refresh("ED_TaskToCopy",param)
    else 
	    setConententPannelJosn(LayerLevelSelcet,"CopyBackgournd_1.json","Panel_mission")
	    LayerCopy.refresh("ED_TaskToCopy",param)
    end 
end

LayerMain.hideHeroTip =function()
	local newAppendEquipTipIcon = mLayerRoot:getWidgetByName("mainbtn_hero_tip")
	newAppendEquipTipIcon:setVisible(false)
end

LayerMain.AcitonDone_CallBack =function()
	LayerMain.showTaskTip()
	LayerMain.showNewAppenEquipTip()
	LayerMain.showRuneTip()
	LayerMain.showMoreTip()
	LayerMain.showDailyCrazyTip()
	LayerMain.showNoticeTip()
	LayerMainEnter.showGameRankMsgTips()
end

LayerMain.destroy = function()
	if mLayerThis and "function" == type(mLayerThis.destroy) then
		mLayerThis.destroy()
	end
	mLayerRoot = nil
	mflag =true
	tempRatio = 0
	if mResTimer ~= nil then
		mResTimer.stop()
		mResTimer = nil
	end
end 

-- 游戏事件注册
EventCenter_subscribe(EventDef["ED_UPDATE_ROLE_INFO"], updateRoleInfo)
EventCenter_subscribe(EventDef["ED_TaskToCopy"], handler_TaskToCopy)
EventCenter_subscribe(EventDef["ED_UPDATE_TASK_LIST"], LayerMain.showTaskTip)
EventCenter_subscribe(EventDef["ED_BUY_POWER_HP"], handleBuyPowerHp)
--EventCenter_subscribe(EventDef["ED_EMAIL_LIST"], LayerMain.showMailAndDHM)
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)
EventCenter_subscribe(EventDef["ED_COPY_INFOS"], initButtonAndEvent)
EventCenter_subscribe(EventDef["ED_MONTH_CARD_INFO"], handleMonthCardInfo)
EventCenter_subscribe(EventDef["ED_FRIEND_POINT_GET"],LayerMain.showMoreTip)		--友情点


