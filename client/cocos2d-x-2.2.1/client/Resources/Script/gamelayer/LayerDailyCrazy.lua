----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-05
-- Brief:	每日活跃界面
----------------------------------------------------------------------
local mLayerDailyCrazyRoot = nil

LayerDailyCrazy = {}
LayerAbstract:extend(LayerDailyCrazy)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		-- setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
		LayerMain.pullPannel()
	end
end
----------------------------------------------------------------------
-- 点击奖励图标
local function clickAwardIcon(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		UIManager.push("UI_DailyCrazyTip", widget:getTag())
	end
end
----------------------------------------------------------------------
-- 显示进度
local function showProgress(panel, activeness)
	local maxActiveness = 1000
	local progressText = panel:getChildByName("progress_text")
	tolua.cast(progressText, "UILabel")
	progressText:setText(activeness.."/"..maxActiveness)
	local progressBar = panel:getChildByName("progress_bar")
	tolua.cast(progressBar, "UILoadingBar")
	progressBar:setPercent((activeness/maxActiveness)*100)
end
----------------------------------------------------------------------
-- 显示奖励图标
local function showAwardIcon()
	if nil == mLayerDailyCrazyRoot then
		return
	end
	for i=1, 4 do
		local status = DailyActivenessLogic.getAwardStatus(i)
		local awardIcon = mLayerDailyCrazyRoot:getChildByName("award_icon_0"..i)
		awardIcon:setTag(i)
		awardIcon:registerEventScript(clickAwardIcon)
		FactoryAnimation_showSquareParticle("skill_selected.plist", CCSizeMake(74, 74), awardIcon, false)
		if 0 == status then			-- 可领取
			awardIcon:setColor(ccc3(255, 255, 255))
			FactoryAnimation_showSquareParticle("skill_selected.plist", CCSizeMake(74, 74), awardIcon, true)
		elseif 1 == status then		-- 不可领取
			awardIcon:setColor(ccc3(140, 140, 140))
		elseif 2 == status then		-- 已领取
			awardIcon:setColor(ccc3(255, 255, 255))
			FactoryAnimation_showSquareParticle("skill_selected.plist", CCSizeMake(74, 74), awardIcon, false)
		end
		-- 显示提示角标
		local tipsPosition = nil
		if 1 == i then
			tipsPosition = ccp(155, 169)
		elseif 2 == i then
			tipsPosition = ccp(287, 169)
		elseif 3 == i then
			tipsPosition = ccp(419, 169)
		elseif 4 == i then
			tipsPosition = ccp(554, 169)
		end
		local tipIcon = mLayerDailyCrazyRoot:getChildByName("tip_icon_"..i)
		if nil == tipIcon then
			tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
			tipIcon:setName("tip_icon_"..i)
			tipIcon:setPosition(tipsPosition)
			mLayerDailyCrazyRoot:addChild(tipIcon)
		end
		tipIcon:setVisible(0 == status)
	end
end
----------------------------------------------------------------------
-- 判断前往功能是否开启
local function checkGotoOpened(taskId)
	-- if 1 == taskId then			-- 转至副本群选择界面
		-- return true, nil
	if 1 == taskId then		-- 转至普通副本
		return true, nil
	elseif 2 == taskId then		-- 转至精英副本
		return CopyDelockLogic.judgeYNEnterById(LIMIT_EQUIP_JYFB.copy_id), LIMIT_EQUIP_JYFB
	elseif 3 == taskId then		-- 转至boss挑战
		return CopyDelockLogic.judgeYNEnterById(LIMIT_ENTER_BOSS.copy_id), LIMIT_ENTER_BOSS
	elseif 4 == taskId then		-- 转至虚空之门
		return CopyDelockLogic.judgeYNEnterById(LIMIT_ACTIVITY_COPY.copy_id), LIMIT_ACTIVITY_COPY
	elseif 5 == taskId then		-- 转至魔塔界面
		return CopyDelockLogic.judgeYNEnterById(LIMIT_TOWER.copy_id), LIMIT_TOWER
	elseif 6 == taskId then		-- 转至召唤界面
		return CopyDelockLogic.judgeYNEnterById(LIMIT_SKILL.copy_id), LIMIT_SKILL
	elseif 7 == taskId then		-- 转至排位赛界面
		return CopyDelockLogic.judgeYNEnterById(LIMIT_RANK_GAME.copy_id), LIMIT_RANK_GAME
	elseif 8 == taskId then		-- 转至训练赛界面
		return CopyDelockLogic.judgeYNEnterById(LIMIT_TRAIN_GAME.copy_id), LIMIT_TRAIN_GAME
	elseif 9 == taskId then		-- 转至分组赛界面
		return CopyDelockLogic.judgeYNEnterById(LIMIT_LADDERMATCH.copy_id), LIMIT_LADDERMATCH
	elseif 10 == taskId then		-- 转至炼金术界面
		return true, nil
	elseif 11 == taskId then		-- 转至女神祝福界面
		return true, nil
	elseif 12 == taskId then		-- 转至技能强化界面
		return true, nil
	end
end
----------------------------------------------------------------------
-- 点击前往按钮
local function clickGotoBtn(typeName, widget)
	if "releaseUp" == typeName then
		local taskId = widget:getTag()
		local opened, limitLevel = checkGotoOpened(taskId)
		if false == opened then
			if limitLevel then
				if CopyDateCache.getCopyStatus(limitLevel.copy_id) ~= "pass" and tonumber(limitLevel.copy_id) ~= 1 then
					Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(limitLevel.copy_id),limitLevel.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
					return
				end
			end
			-- if 9 == taskId then
				-- Toast.show(GameString.get("Public_OpenLevel",LIMIT_PTFB_SWEEP))
			-- end
			return
		end
		local AllGroup = LogicTable.getAllCopyGroup()
		if 1 == taskId then		-- 转至普通副本
			-- setConententPannelJosn(LayerLevelSelcet,"CopyBackgournd_1.json","Panel_mission")
			-- LayerCopy.createCopyGroupByMode(1)
			for key, val in pairs(AllGroup) do
				local status = CopyDateCache.getGroupStatusById(val.id)
				if val.type == "1" and status == "doing" then
					setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
					LayerCopy.createCopyGroupByMode(1) --1:普通副本群
					LayerCopy.create_CopyByMode(val.id)
					break
				end
				
				if key == #AllGroup then
					setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
					LayerCopy.createCopyGroupByMode(1) --1:普通副本群
					LayerCopy.create_CopyByMode(118)
				end
			end
		elseif 2 == taskId then		-- 转至精英副本
			for key, val in pairs(AllGroup) do
				local status = CopyDateCache.getGroupStatusById(val.id)
				if val.type == "2" and status == "doing" then
					setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
					LayerCopy.createCopyGroupByMode(2) --1:普通副本群
					LayerCopy.create_CopyByMode(val.id)
					break
				end
				if key == #AllGroup then
					setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
					LayerCopy.createCopyGroupByMode(2) --1:普通副本群
					LayerCopy.create_CopyByMode(218)
				end
			end
		elseif 3 == taskId then		-- 转至boss挑战
			LayerChenallBoss.setInLoad("main")
			setConententPannelJosn(LayerChenallBoss,LayerChenallBoss.josnFile,LayerChenallBoss.josnFile)
		elseif 4 == taskId then		-- 转至虚空之门
			LayerActivityCopyGroup.setInLoad("main")
			setConententPannelJosn(LayerActivityCopyGroup, "ActivityCopyGroup.json", "LayerActivityCopyGroupUI")
		elseif 5 == taskId then		-- 转至魔塔界面
			LayerTowerbg.setInLoad("main")
			setConententPannelJosn(LayerTowerbg, "PowerCopyBg.json", "LayerTowerbgUI")
		elseif 6 == taskId then		-- 转至召唤界面
			setConententPannelJosn(LayerRune, "Rune_1.json", "LayerRuneUI")
		elseif 7 == taskId then		-- 转至排位赛界面
			setConententPannelJosn(LayerGameRank, "GameRank_1.json", "LayerGameRankUI")
			LayerTipFunction.gotoTipFunction(1010)
		elseif 8 == taskId then		-- 转至训练赛界面
			setConententPannelJosn(LayerGameTrain, "GaneTrain_1.json", "LayerGameTrainUI")
			LayerTipFunction.gotoTipFunction(1008)
		elseif 9 == taskId then		-- 转至分组赛界面
			-- setConententPannelJosn(ladderMatch, "ladderMatch_1.json", "ladderMatchUI")
			setConententPannelJosn(LayerGameMatch, "GameMatch_1.json", "LayerGameMatchUI")
			LayerTipFunction.gotoTipFunction(1009)
		elseif 10 == taskId then		-- 转至炼金术界面
			setConententPannelJosn(LayerGetCoin, "Activity_4.json", "LayerGetCoinUI")
			LayerTipFunction.gotoTipFunction(1014)
		elseif 11 == taskId then		-- 转至女神祝福界面
			setConententPannelJosn(LayerBless, "bless_1.json", "LayerBlessUI")
			LayerTipFunction.gotoTipFunction(1018)
		elseif 12 == taskId then		-- 转至友情抽奖界面
			setConententPannelJosn(LayerSkillMain, "SkillMain.json", "LayerSkillMain")
			LayerTipFunction.gotoTipFunction(1005)
		end
	end
end
----------------------------------------------------------------------
-- 创建任务单元格
local function createTaskCell(cell, data, index)
	local activenessTaskRow = LogicTable.getActivenessTaskRow(data.taskId)
	local complete = data.taskCount >= activenessTaskRow.max_times and true or false
	local progressColor = true == complete and ccc3(135, 255, 29) or ccc3(255, 98, 29)
	local statusColor = true == complete and ccc3(96, 255, 0) or ccc3(255, 72, 0)
	local cellSize = CCSizeMake(538, 78)
	local node = CommonFunc_createUILayout(nil, nil, cellSize)
	-- 背景
	local backgroundStr = 0 == index % 2 and "dailycrazy_bg_04.png" or "dailycrazy_bg_05.png"
	local background = CommonFunc_getImgView(backgroundStr)
	background:setAnchorPoint(ccp(0, 0.5))
	background:setPosition(ccp(0, cellSize.height*0.5))
	node:addChild(background)
	-- 名称
	local nameLabel = CommonFunc_getLabel(index..". "..activenessTaskRow.name, 20)
	nameLabel:setAnchorPoint(ccp(0, 0.5))
	nameLabel:setPosition(ccp(5, 20))
	background:addChild(nameLabel)
	-- 进度标题
	local progressTitleLabel = CommonFunc_getLabel(GameString.get("ACTIVENESS_STR_01")..GameString.get("PUBLIC_COLON"), 20, ccc3(235, 189, 112))
	progressTitleLabel:setAnchorPoint(ccp(0, 0.5))
	progressTitleLabel:setPosition(ccp(30, -18))
	background:addChild(progressTitleLabel)
	-- 进度
	local progressLabel = CommonFunc_getLabel(data.taskCount.."/"..activenessTaskRow.max_times, 20, progressColor)
	progressLabel:setAnchorPoint(ccp(0, 0.5))
	progressLabel:setPosition(ccp(115, -19))
	background:addChild(progressLabel)
	-- 活跃度标题
	local activenessTitleLabel = CommonFunc_getLabel(GameString.get("ACTIVENESS_STR_02")..GameString.get("PUBLIC_COLON"), 20, ccc3(246, 226, 101))
	activenessTitleLabel:setAnchorPoint(ccp(0, 0.5))
	activenessTitleLabel:setPosition(ccp(200, -18))
	background:addChild(activenessTitleLabel)
	-- 活跃度
	local activenessLabel = CommonFunc_getLabel(tostring(activenessTaskRow.award_pertime), 20, ccc3(255, 241, 9))
	activenessLabel:setAnchorPoint(ccp(0, 0.5))
	activenessLabel:setPosition(ccp(305, -19))
	background:addChild(activenessLabel)
	if false == complete then
		-- 前往按钮
		local gotoBtn = CommonFunc_getButton("public_newbuttom.png", "public_newbuttom.png", "public_newbuttom.png")
		gotoBtn:setPosition(ccp(472, 0))
		gotoBtn:setScale(0.9)
		gotoBtn:setTag(data.taskId)
		gotoBtn:registerEventScript(clickGotoBtn)
		background:addChild(gotoBtn)
		local opened, _ = checkGotoOpened(data.taskId)
		local gotoNameImageName = "text_qianwang.png"
		if false == opened then
			gotoNameImageName = "text_tiaojianbuzu.png"
		end
		local gotoName = CommonFunc_getImgView(gotoNameImageName)
		gotoBtn:addChild(gotoName)
	end
	return node
end
----------------------------------------------------------------------
-- 领取奖励
local function handleGetActivenessAward(success)
	if nil == mLayerDailyCrazyRoot then
		return
	end
	showAwardIcon()
	LayerMain.showDailyCrazyTip()
end
----------------------------------------------------------------------
-- 初始化
LayerDailyCrazy.init = function(rootView)
	local info = DailyActivenessLogic.getActivenessInfo()
	mLayerDailyCrazyRoot = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("close_btn"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 进度条
	showProgress(rootView, info.activeness)
	-- 奖励图标
	showAwardIcon()
	-- 列表
	local dataTable = {}
	for key, val in pairs(info.taskList) do
		local dataCell = {}
		dataCell.taskId = val.id
		dataCell.taskCount = val.count
		table.insert(dataTable, dataCell)
	end
	local scrollView = tolua.cast(rootView:getChildByName("list_view"), "UIScrollView")
	UIScrollViewEx.show(scrollView, dataTable, createTaskCell, "V", 538, 78, 0, 1, 4, true, nil, true, true)
	TipModule.onUI(rootView, "ui_dailycrazy")
end
----------------------------------------------------------------------
-- 销毁
LayerDailyCrazy.destroy = function()
	mLayerDailyCrazyRoot = nil
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_ACTIVENESS_AWARD_GET"], handleGetActivenessAward)

