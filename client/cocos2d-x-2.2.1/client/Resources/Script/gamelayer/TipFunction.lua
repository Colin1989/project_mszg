----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-08-21
-- Brief:	提醒功能
----------------------------------------------------------------------
TipFunction = {}
local mCurrTip = nil
local mDailyTimerFlag = false
local mFuncInfoTable = {}
----------------------------------------------------------------------
-- 创建步骤
local function createStep(uiName, widgetNameTable, configTable, waitFlag)
	local step = {}
	-- 步骤所在界面名称
	step.uiName = uiName
	-- 关联的控件名称表
	step.widgetNameTable = widgetNameTable or {}
	-- 是否已被执行
	step.isExecute = false
	-- 是否要等待
	step.isWait = waitFlag or false
	-- 该步骤的箭头控件
	step.arrowTable = {}
	-- 执行步骤
	step.executeFunc = function(root, stepRef, preStep)
		stepRef.rootNode = root		-- 步骤所在的界面节点
		if true == stepRef.isExecute or true == stepRef.isWait then
			return
		end
		stepRef.isExecute = true
		if preStep then		-- 清除上一步
			preStep.cancelFunc(preStep)
		end
		for key, val in pairs(configTable) do
			local arrow = TipModule.showArrow(root, nil, val[1], val[2], true)
			if arrow then
				table.insert(stepRef.arrowTable, arrow)
			end
		end
	end
	-- 清除步骤
	step.cancelFunc = function(stepRef)
		for key, val in pairs(stepRef.arrowTable) do
			local arrow = tolua.cast(val, "UIImageView")
			if arrow then
				arrow:removeFromParent()
			end
		end
		stepRef.arrowTable = {}
	end
	return step
end
----------------------------------------------------------------------
-- 背包,武器装备箭头配置
local function config01_01()
	local nameTable = {}
	for i=1, 6 do
		if ModelEquip.getCurrEquip(i) then
			table.insert(nameTable, "ImageEquip_"..(i-1))
		end
	end
	return nameTable
end
local function config01_02()
	local tb = 
	{
		{"right", ccp(100, 310)}, {"right", ccp(100, 200)}, {"right", ccp(100, 90)},
		{"left", ccp(620, 310)}, {"left", ccp(620, 200)}, {"left", ccp(620, 90)}
	}
	local configTable = {}
	for i=1, 6 do
		if ModelEquip.getCurrEquip(i) then
			table.insert(configTable, tb[i])
		end
	end
	return configTable
end
----------------------------------------------------------------------
-- 锻造,武器装备箭头配置
local function config02_01()
	local nameTable = {}
	local index = 1
	for i=1, 6 do
		if ModelEquip.getCurrEquip(i) then
			table.insert(nameTable, "click_forge_grid"..index)
			index = index + 1
		end
	end
	return nameTable
end
local function config02_02()
	local tb = 
	{
		{"down", ccp(130, 300)}, {"down", ccp(240, 300)}, {"down", ccp(350, 300)},
		{"down", ccp(460, 300)}, {"down", ccp(570, 300)}, {"up", ccp(130, 100)}
	}
	local configTable = {}
	local index = 1
	for i=1, 6 do
		if ModelEquip.getCurrEquip(i) then
			table.insert(configTable, tb[index])
			index = index + 1
		end
	end
	return configTable
end
local function config04_01()
	local nameTable = {}
	for i=1, 100 do
		table.insert(nameTable, "click_bag_grid"..i)
	end
	return nameTable
end
----------------------------------------------------------------------
-- 获取当前提示
local function getCurrTip(tipId)
	if nil == tipId then
		return nil
	end
	-- key值对应提示功能表的id
	local tb = 
	{
		[1001] = -- 装备强化
		{
			-- step1:锻造界面,指向装备箭头
			createStep("ui_equipforge", config02_01(), config02_02()),
			-- step2:锻造,装备信息界面,指向强化箭头
			createStep("ui_equipforgeinfo", {"btn_equip"}, {{"right", ccp(530, 350)}}),
			-- step3:锻造,装备强化界面,指向强化装备箭头
			createStep("ui_equipforgestrengthen", {"Button_Strengthen"}, {{"up", ccp(360, 300)}}),
		},
		[1002] = -- 装备晋阶
		{
			-- step1:锻造界面,指向装备箭头
			createStep("ui_equipforge", config02_01(), config02_02()),
			-- step2:锻造,装备信息界面,指向晋阶箭头
			createStep("ui_equipforgeinfo", {"btn_advance"}, {{"right", ccp(530, 210)}}),
			-- step3:锻造,装备晋阶界面,指向强化晋阶箭头
			createStep("ui_equipforgeupgrade", {"btn_equip"}, {{"up", ccp(360, 300)}}),
		},
		[1003] = -- 装备重铸
		{
			-- step1:锻造界面,指向装备箭头
			createStep("ui_equipforge", config02_01(), config02_02()),
			-- step2:锻造,装备信息界面,指向重铸箭头
			createStep("ui_equipforgeinfo", {"btn_recast"}, {{"right", ccp(530, 280)}}),
			-- step3:锻造,重铸界面,指向开始重铸箭头
			createStep("ui_equipforgerecast", {"btn_recast"}, {{"up", ccp(210, 110)}}),
		},
		[1004] = -- 潜能提升
		{
			-- step1:英雄圣殿界面,指向英雄潜能箭头
			createStep("ui_roleup", {"rp_bt1"}, {{"down", ccp(140, 150)}}),
			-- step2:潜能提升界面,指向提升箭头
			createStep("ui_roleuppotent", {"uppentent"}, {{"up", ccp(470, 410)}}),
		},
		[1006] = -- 宝石合成
		{
			-- step1:背包,指向宝石标签箭头
			createStep("ui_backpack", {"Button_Gem"}, {{"up", ccp(490, 330)}}),
			-- step2:背包,指向格子容器箭头
			createStep("ui_baggem", config04_01(), {{"up", ccp(360, 90)}}),
			-- step3:背包,宝石信息界面,指向合成箭头
			createStep("ui_geminfo_01", {"Button_1"}, {{"right", ccp(530, 300)}}),
			-- step4:背包,宝石合成界面,指向合成箭头
			createStep("ui_gemcompound", {"Button_HC"}, {{"up", ccp(360, 350)}}),
		},
		[1007] = -- 宝石镶嵌
		{
			-- step1:背包,英雄装备界面,指向装备箭头
			createStep("ui_equipbody", config01_01(), config01_02()),
			-- step2:背包,装备信息界面,指向镶嵌箭头
			createStep("ui_equipput", {"Button_inlay"}, {{"right", ccp(600, 660)}}),
			-- step3:背包,指向格子容器箭头
			createStep("ui_baggem", config04_01(), {{"up", ccp(360, 90)}}),
			-- step4:背包,宝石信息界面,指向镶嵌箭头
			createStep("ui_geminfo_01", {"Button_3"}, {{"right", ccp(530, 150)}}),
		},
		[1008] = -- 训练赛
		{
			-- step1:竞技场界面,指向训练赛箭头
			createStep("ui_gamerankchoice", {"btn_xls"}, {{"down", ccp(150, 187)}}),
			-- step2:训练赛界面,指向排名箭头
			createStep("ui_gametrain", {"click_train_fight"}, {{"up", ccp(320, 290)}}),
		},
		[1009] = -- 分组赛
		{
			-- step1:竞技场界面,指向分组赛箭头
			createStep("ui_gamerankchoice", {"btn_fenzu"}, {{"down", ccp(320, 187)}}),
			-- step2:竞技场,分组赛界面,指向挑战箭头
			createStep("ui_laddermatch", {"ladder_atk"}, {{"up", ccp(530, 300)}}),
		},
		[1010] = -- 排位赛
		{
			-- step1:竞技场界面,指向排位赛箭头
			createStep("ui_gamerankchoice", {"btn_pws"}, {{"down", ccp(534, 187)}}),
			-- step2:排位赛界面,指向排名箭头
			createStep("ui_gamerank", {"click_rank_fight"}, {{"up", ccp(320, 290)}}),
		},
		[1011] = -- 每日奖励
		{
			-- step1:活动界面,指向签到奖励箭头
			createStep("ui_activity", {"activity_switch_bg_1"}, {{"down", ccp(300, 440)}}),
			-- step2:每日奖励界面,指向第一个领取奖励按钮箭头
			createStep("ui_dailyaward", {"daily_award_btn"}, {{"right", ccp(490, 450)}}),
		},
		[1012] = -- 活跃奖励
		{
			-- step1:活动界面,指向每日活跃箭头
			createStep("ui_activity", {"activity_switch_bg_2"}, {{"down", ccp(300, 650)}}),
			-- step2:每日活跃界面,指向奖励图标箭头
			createStep("ui_dailycrazy", {}, {{"up", ccp(360, 110)}}),
		},
		[1013] = -- 友情抽奖
		{
			-- step1:活动界面,指向友情奖励箭头
			createStep("ui_socialenter", {"cellBg_3"}, {{"down", ccp(430, 150)}}),
			-- step2:友情奖励界面,指向抽取奖励箭头
			createStep("ui_friendpoint", {"getreward"}, {{"down", ccp(360, 500)}}),
		},
		[1014] = -- 炼金术
		{
			-- step1:活动界面,指向炼金术箭头
			createStep("ui_activity", {"activity_switch_bg_7"}, {{"down", ccp(430, 470)}}),
			-- step2:炼金术界面,指向普通炼金箭头
			createStep("ui_getcoin", {"Button_pub_get"}, {{"up", ccp(186, 86)}}),
		},
		[1015] = -- 在线奖励
		{
			-- step1:活动界面,指向在线奖励箭头
			createStep("ui_activity", {"activity_switch_bg_8"}, {{"down", ccp(110, 330)}}),
			-- step2:在线奖励界面,指向领取奖励箭头
			createStep("ui_onlinereward", {"Button_reward"}, {{"down", ccp(360, 100)}}),
		},
		[1016] = -- 魔塔
		{
			-- step1:活动界面,指向魔塔箭头
			createStep("ui_activity", {"activity_switch_bg_10"}, {{"down", ccp(110, 150)}}),
			-- step2:魔塔界面,指向进入箭头
			createStep("ui_towerbg", {"enterGame"}, {{"up", ccp(595, 110)}}),
		},
		[1017] = -- boss挑战
		{
			-- step1:活动界面,指向boss挑战箭头
			createStep("ui_activity", {"activity_switch_bg_11"}, {{"down", ccp(300, 150)}}),
			-- step2:boss挑战界面,指向箭头
			createStep("ui_chenallboss", {}, {{"up", ccp(360, 120)}}),
		},
		[1018] = -- 女神祝福
		{
			-- step1:女神祝福界面,指向祝福图标箭头
			createStep("ui_bless", {"click_bless_icon"}, {{"down", ccp(360, 400)}}),
		},
		[1020] = -- 军衔荣誉
		{
			-- step1:竞技场界面,指向军衔荣誉箭头
			createStep("ui_gamerankchoice", {"btn_jx"}, {{"down", ccp(150, 110)}}),
			-- step2:指向领取奖励箭头
			createStep("ui_miltitary", {"Button_getReward"}, {{"down", ccp(440, 130)}}),
		},
	}
	return tb[tipId]
end
----------------------------------------------------------------------
-- 获取提示步骤
local function getStep()
	if nil == mCurrTip then
		return nil, nil, 0
	end
	for i=1, #(mCurrTip) do
		local preStep = mCurrTip[i-1]
		local isPreStepExecute = false
		if nil == preStep or true == preStep.isExecute then
			isPreStepExecute = true
		end
		if true == isPreStepExecute and false == mCurrTip[i].isExecute then
			return preStep, mCurrTip[i], i
		end
	end
	return nil, nil, 0
end
----------------------------------------------------------------------
-- 清除提示
local function clearTip(doCancel)
	if nil == mCurrTip then
		return
	end
	if true == doCancel then
		for i=1, #(mCurrTip) do
			local step = mCurrTip[i]
			step.cancelFunc(step)
		end
	end
	mCurrTip = nil
end
----------------------------------------------------------------------
-- 当天到达24:00:00,清空数据
local function dailyTimerOver()
	mFuncInfoTable = {}
end
----------------------------------------------------------------------
-- 初始化
TipFunction.init = function()
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
end
----------------------------------------------------------------------
-- 设置提示
TipFunction.setTip = function(tipId)
	clearTip(true)
	mCurrTip = getCurrTip(tipId)
end
----------------------------------------------------------------------
-- 显示提示
TipFunction.showTip = function(root, uiName)
	if GuideMgr.guideStatus() > 0 then
		clearTip(true)
		return
	end
	local preStep, step, stepIndex = getStep()
	if nil == step then
		return
	end
	if uiName == step.uiName then
		step.executeFunc(root, step, preStep)
	end
end
----------------------------------------------------------------------
-- 监听点击事件
TipFunction.listenClick = function(widgetName, param)
	local preStep, step, stepIndex = getStep()
	if nil == preStep then
		clearTip(true)
		return
	end
	widgetName = widgetName..(param or "")
	for key, val in pairs(preStep.widgetNameTable) do
		if widgetName == val then
			if step.isWait then
				step.isWait = false
				step.executeFunc(step.rootNode, step, preStep)
			end
			return
		end
	end
	clearTip(true)
end
----------------------------------------------------------------------
-- 设置提示功能模块的属性
TipFunction.setFuncAttr = function(funcName, attrName, attrValue)
	if nil == mFuncInfoTable[funcName] then
		mFuncInfoTable[funcName] = {}
	end
	mFuncInfoTable[funcName][attrName] = attrValue
end
----------------------------------------------------------------------
-- 获取提示功能模块的属性
TipFunction.getFuncAttr = function(funcName, attrName)
	if nil == mFuncInfoTable[funcName] then
		return nil
	end
	return mFuncInfoTable[funcName][attrName]
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], dailyTimerOver)

