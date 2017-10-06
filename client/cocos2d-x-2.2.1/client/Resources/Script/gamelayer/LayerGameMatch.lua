--region LayerGameMatch.lua
--Author : songcy
--Date   : 2015/01/08
-- 新分组赛

LayerGameMatch = {}
local mRootView = nil

local buyTime = 0
local LeftTimes = 0
local btnDayStatus = 0
local btnWeekStatus = 0
local getAwardType = 0 --当前领取的礼包类型 1:每日 2：每周

local EVERYDAYSFREE = 4 --分组赛免费挑战次数


-- local mIsGetDialyReWard = false
-- local mIsGetWeeklyReWard = false

-- local m_enemyTag = 3000		-- 对手UI layout tag
-- local m_teammateTag = 1000		-- 队友UI layout tag

local ladderMatchInfo = nil		-- 分组赛信息
local teammateInfoTable = nil		-- 队友信息
local enemyInfoTable = nil			-- 敌人信息

local lastPassLevel = nil			-- 上一次通关信息
-- local enemyInfoTemp = nil

local tempTeammateTag = nil		-- 获取队友标签

local playerWidget = nil			-- 获取玩家UI
local enemyWidget = {}				-- 获取敌人UI
local teammateWidget = {}			-- 获取对友UI
local passPointUIWidget = {}		-- 获取关卡UI
local passLevelUIWidget = {}
local lightPointUIWidget = {}		-- 光点UI
local lineUIWidget = {}			-- 线UI

local isDropLife = false			-- 是否已掉血

local DialyreWardDesc = {}
local WeekyReWardDesc = {}


local isPlayAning = false
-- local mEnemySprite = nil

local positionTb = {
	[1] = {ccp(47, 33), ccp(47, 6)},
	[2] = {ccp(47, 20), ccp(47, -20)},
}

local passPointTb = {
	[1] = ccp(-223, 17),
	[2] = ccp(-187, -17),
	[3] = ccp(-143, 17),
	[4] = ccp(-101, -17),
	[5] = ccp(-58, 17),
	[6] = ccp(-17, -17),
	[7] = ccp(25, 17),
	[8] = ccp(69, -17),
	[9] = ccp(110, 17),
	[10] = ccp(183, 17),
	[11] = ccp(223, -17),
	[12] = ccp(145, -17),
}

-- 判断 是否可以改变队友 及昵称与战斗力当前坐标
local function canChangeTeammate()
	if tonumber(ladderMatchInfo.pass_level) + tonumber(ladderMatchInfo.is_failed) == 0 then
		return true, positionTb[1]
	else
		return false, positionTb[2]
	end
end

-- 进度条动画
local function actionLoadingBar(ratio, mTime)
	local tempTime = mTime or 1.0
	local scaleAction = CCScaleTo:create(tempTime, ratio, 1.0)
	return scaleAction
end

-- 冒号提示
LayerGameMatch.isShowTip = function()
	local pRet = false
	if CopyDelockLogic.judgeYNEnterById(LIMIT_LADDERMATCH.copy_id)== true then
		-- print("mIsGetDialyReWard-0----------------------------",mIsGetDialyReWard,mIsGetWeeklyReWard,LeftTimes)
		if mIsGetDialyReWard == true or true == mIsGetWeeklyReWard or LeftTimes > 0 then 
			pRet = true
		end
	end
	return pRet
end

--------------------------------------------------------------------------------------------------
-- 通关之后动画
local function updateLineUI()
	if nil == mRootView then
		cclog("mRootView = nil")
		return
	elseif ladderMatchInfo.pass_level < 1 then
		cclog("ladderMatchInfo.pass_level < 1")
		return
	elseif ladderMatchInfo.pass_level == 12 then
		-- 通关最后一个关卡的特殊处理
		local lightPoint = lightPointUIWidget[ladderMatchInfo.pass_level]
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(1.0))
		arr:addObject(CCFadeIn:create(0.5))
		arr:addObject(CCCallFuncN:create(
			function(sender)
				lightPoint:runAction(CCFadeOut:create(0.5))
				local imgOrange = passPointUIWidget[ladderMatchInfo.pass_level]:getChildByName("orange_"..ladderMatchInfo.pass_level)
				imgOrange:setVisible(false)
				-- sender:getParent():removeChild(sender, true)
				lastPassLevel = ladderMatchInfo.pass_level
			end
		))
		lightPoint:runAction(CCSequence:create(arr))
		return
	elseif ladderMatchInfo.pass_level > 12 then
		cclog("ladderMatchInfo.pass_level > 12")
		return
	end
	
	local distanceX = passPointTb[ladderMatchInfo.pass_level + 1].x - passPointTb[lastPassLevel + 1].x
	local distanceY = passPointTb[ladderMatchInfo.pass_level + 1].y - passPointTb[lastPassLevel + 1].y
	local distance = math.sqrt(math.pow(distanceX, 2) + math.pow(distanceY, 2))		-- 两点间的距离
	local rotation = -1 * math.deg(math.atan2(distanceY, distanceX))					-- 旋转的角度
	
	-- 挑战关卡示意图
	local stageNode = mRootView:getChildByName("ChallengeStage")
	
	local function lineCallBack(sender)
		local lightPoint = lightPointUIWidget[ladderMatchInfo.pass_level + 1]
		local arr = CCArray:create()
		-- arr:addObject(CCDelayTime:create(1.0))
		arr:addObject(CCFadeIn:create(0.5))
		arr:addObject(CCCallFuncN:create(
			function(sender)
				-- sender:getParent():removeChild(sender, true)
				lightPoint:runAction(CCFadeOut:create(0.5))
				-- 当前关卡的点
				local pointNode = passPointUIWidget[ladderMatchInfo.pass_level + 1]
				pointNode:setVisible(true)
				lastPassLevel = ladderMatchInfo.pass_level
			end
		))
		lightPoint:runAction(CCSequence:create(arr))
	end
	
	local function lightCallBack(sender)
		-- 通关的点
		local lightPoint = lightPointUIWidget[lastPassLevel + 1]
		lightPoint:runAction(CCFadeOut:create(0.5))
		
		local imgOrange = passPointUIWidget[lastPassLevel + 1]:getChildByName("orange_"..lastPassLevel + 1)
		imgOrange:setVisible(false)
		-- sender:removeFromParentAndCleanup(true)
		
		-- 通关的线
		local lightNode = CommonFunc_getImgView("gamematch_guanqia_1.png")
		local lightContentSize = lightNode:getContentSize()
		local ratioLight = distance / lightContentSize.width
		lightNode:setAnchorPoint(ccp(0, 0.5))
		lightNode:setRotation(rotation)
		lightNode:setPosition(passPointTb[lastPassLevel + 1])
		lineUIWidget[lastPassLevel + 1] = lightNode
		stageNode:addChild(lightNode)
		
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(0.5))
		arr:addObject(actionLoadingBar(ratioLight, 0.5))
		arr:addObject(CCCallFuncN:create(lineCallBack))
		lightNode:runAction(CCSequence:create(arr))
		
		-- if key == 1 then
			-- local rewardBg= tolua.cast( mRootView:getWidgetByName("background"),"UIImageView")	-- 任务完成背景
			-- rewardBg:runAction(CCFadeOut:create(0.7))
		-- end
		-- crush(pos, value)
	end
	
	local lightPoint = lightPointUIWidget[lastPassLevel + 1]
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(1.0))
	arr:addObject(CCFadeIn:create(1.0))
	arr:addObject(CCCallFuncN:create(lightCallBack))
	lightPoint:runAction(CCSequence:create(arr))
end

-- 获取线UI
local function getLineUI(tag)
	-- 总共11条线
	local distanceX = passPointTb[tag + 1].x - passPointTb[tag].x
	local distanceY = passPointTb[tag + 1].y - passPointTb[tag].y
	local distance = math.sqrt(math.pow(distanceX, 2) + math.pow(distanceY, 2))		-- 两点间的距离
	local rotation = -1 * math.deg(math.atan2(distanceY, distanceX))					-- 旋转的角度
	-- local lightBg = CommonFunc_getImgView("gamematch_guanqia_2.png")
	-- local bgContentSize = lightBg:getContentSize()
	-- local ratioBg = distance / bgContentSize.width				-- 缩放的比例
	-- lightBg:setAnchorPoint(ccp(0, 0.5))
	-- lightBg:setScaleX(ratioBg)
	-- lightBg:setRotation(rotation)
	-- lightBg:setPosition(passPointTb[tag])
	
	local lightNode = CommonFunc_getImgView("gamematch_guanqia_1.png")
	local lightContentSize = lightNode:getContentSize()
	local ratioLight = distance / lightContentSize.width
	lightNode:setAnchorPoint(ccp(0, 0.5))
	lightNode:setRotation(rotation)
	lightNode:setScaleX(ratioLight)
	lightNode:setPosition(passPointTb[tag])
	
	return lightNode
end

-- 初始化线UI
local function initLine()
	if nil == mRootView then
		cclog("mRootView = nil")
		return
	elseif ladderMatchInfo.pass_level < 1 or ladderMatchInfo.pass_level > 11 then
		cclog("ladderMatchInfo.pass_level < 1 or ladderMatchInfo.pass_level > 11")
		return
	end
	
	-- 挑战关卡示意图
	local stageNode = mRootView:getChildByName("ChallengeStage")
	for i = 1, #lineUIWidget, 1 do
		stageNode:removeChild(lineUIWidget[i])
	end
	
	for i = 1, ladderMatchInfo.pass_level, 1 do
		local lineUI = getLineUI(i)
		lineUIWidget[i] = lineUI
		stageNode:addChild(lineUI)
	end
	
end

-- 获取点UI
local function getPassPointUI(tag)
	local passLevel = ladderMatchInfo.pass_level
	local passPointNode = CommonFunc_getImgView("gamematch_modify_01.png")
	passPointNode:setPosition(passPointTb[tag])
	passPointNode:setZOrder(5)
	passPointNode:setName("green_"..tag)
	
	local imgOrange = CommonFunc_getImgView("gamematch_modify_02.png")
	imgOrange:setVisible(true)
	imgOrange:setName("orange_"..tag)
	passPointNode:addChild(imgOrange)
	if tag == passLevel + 1 then
		passPointNode:setVisible(true)
		imgOrange:setVisible(true)
	elseif tag < passLevel + 1 then
		passPointNode:setVisible(true)
		imgOrange:setVisible(false)
	elseif tag > passLevel + 1 then
		passPointNode:setVisible(false)
	end
	
	local lightPoint = CommonFunc_getImgView("role_upgrade_star.png")
	lightPoint:setPosition(passPointTb[tag])
	lightPoint:setZOrder(20)
	lightPoint:setOpacity(0)
	lightPoint:setName("light_point_"..tag)
	
	local passLevelNode = CommonFunc_getAtlas("01234567890", "num_black.png", 24, 32, 0)
	passLevelNode:setScale(0.6)
	passLevelNode:setZOrder(10)
	passLevelNode:setPosition(passPointTb[tag])
	passLevelNode:setName("pass_level_"..tag)
	passLevelNode:setStringValue(tostring(tag))
	
	return passPointNode, passLevelNode, lightPoint
end
-- 初始化关卡进度
local function initChallengeStage()
	if nil == mRootView then
		cclog("mRootView = nil")
		return
	end
	-- 挑战关卡示意图
	local stageNode = mRootView:getChildByName("ChallengeStage")
	for i = 1, #passPointUIWidget, 1 do
		stageNode:removeChild(passPointUIWidget[i])
	end
	for i = 1, #passLevelUIWidget, 1 do
		stageNode:removeChild(passLevelUIWidget[i])
	end
	for i = 1, #lightPointUIWidget, 1 do
		stageNode:removeChild(lightPointUIWidget[i])
	end
	-- setRotation
	for i = 1, #passPointTb, 1 do
		local passPointUI, passLevelUI, lightPointUI = getPassPointUI(i)
		passPointUIWidget[i] = passPointUI
		passLevelUIWidget[i] = passLevelUI
		lightPointUIWidget[i] = lightPointUI
		stageNode:addChild(passPointUI)
		stageNode:addChild(passLevelUI)
		stageNode:addChild(lightPointUI)
	end
	
end

--------------------------------------------------------------------------------------------------
-- 工程按键
local function initButtonEvent()
	if nil == mRootView then
		return
	end
	
	-- 进入战斗
	local btnBattle = mRootView:getChildByName("ladder_atk")
	btnBattle:setTouchEnabled(true)
	btnBattle:registerEventScript(Match_OnClick)
	
	-- 回复生命
	local btnRecLife = mRootView:getChildByName("recover_life")
	btnRecLife:setTouchEnabled(true)
	btnRecLife:registerEventScript(Match_OnClick)
	-- 回复生命 剩余次数 花费
	local imgLifePay = mRootView:getChildByName("ImageView_70")
	local labelFreeCount = tolua.cast(mRootView:getChildByName("Label_free_count"), "UILabel")
	if RECOVER_FREE_COUNT > ladderMatchInfo.recover_count then
		imgLifePay:setVisible(false)
		labelFreeCount:setVisible(true)
		labelFreeCount:setText(string.format(GameString.get("GAME_MATCH_TIP_5", RECOVER_FREE_COUNT - tonumber(ladderMatchInfo.recover_count))))
	else
		imgLifePay:setVisible(true)
		labelFreeCount:setVisible(false)
		local labelLifePay = tolua.cast(mRootView:getChildByName("recover_life_price"), "UILabel")
		labelLifePay:setText(RECOVER_NEED_EMONEY)
	end
	
	-- 重置按钮
	local btnResCount = mRootView:getChildByName("res_challenge")
	local imgResCount = btnResCount:getChildByName("ImageView_79")
	btnResCount:setTouchEnabled(true)
	btnResCount:registerEventScript(Match_OnClick)
	
	-- Lewis:spriteShaderEffect(rewardBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	
	-- 重置 剩余次数 花费
	local labelResCount = tolua.cast(mRootView:getChildByName("Label_res_count"), "UILabel")
	local resCount = RESET_FREE_COUNT - tonumber(ladderMatchInfo.reset_count) + getVipAddValueById(3)
	-- if ModelPlayer.getVipLevel() > 0 then
		-- resCount = VIP_RESET_COUNT - tonumber(ladderMatchInfo.reset_count)
	-- end
	-- VIP_RESET_COUNT = 2 第二次要花魔石
	
	if resCount <= 0 then
		resCount = 0
		btnResCount:setTouchEnabled(false)
		Lewis:spriteShaderEffect(btnResCount:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(imgResCount:getVirtualRenderer(),"buff_gray.fsh",true)
	end
	labelResCount:setText(resCount)
end

--------------------------------------------------------------------------------------------------------
-- 对手详细信息
local function getEnemyUI(tag)
	local value = enemyInfoTable[tag]
	local node = CommonFunc_getImgView("public2_bg_07.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(10, 10, 1, 1))
	node:setSize(CCSizeMake(270, 106))
	
	-- 头像
	local imgHead = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(value.type,value.advanced_level))
	imgHead:setPosition(ccp(-82, 0))
	imgHead:setTag(tag)
	node:addChild(imgHead)
	-- 等级
	local labelAtlasLv = CommonFunc_getAtlas("01234567890", "num_black.png", 24, 32, 0)
	labelAtlasLv:setScale(0.5)
	labelAtlasLv:setAnchorPoint(ccp(0, 0.5))
	labelAtlasLv:setPosition(ccp(-39, 28))
	labelAtlasLv:setStringValue(tostring(value.level))
	imgHead:addChild(labelAtlasLv)
	-- 昵称背景
	local labelNickBg = CommonFunc_getImgView("public2_bg_05.png")
	labelNickBg:setScale9Enabled(true)
	labelNickBg:setCapInsets(CCRectMake(14, 14, 1, 1))
	labelNickBg:setSize(CCSizeMake(144, 24))
	labelNickBg:setPosition(ccp(47, 20))
	node:addChild(labelNickBg)
	-- 昵称
	local labelNick = CommonFunc_getLabel(value.nickname, 19)
	labelNick:setPosition(ccp(0, 0))
	labelNick:setAnchorPoint(ccp(0.5, 0.5))
	labelNickBg:addChild(labelNick)
	-- 战斗力背景
	local labelFightBg = CommonFunc_getImgView("public2_bg_05.png")
	labelFightBg:setScale9Enabled(true)
	labelFightBg:setCapInsets(CCRectMake(14, 14, 1, 1))
	labelFightBg:setSize(CCSizeMake(144, 24))
	labelFightBg:setPosition(ccp(47, -20))
	node:addChild(labelFightBg)
	-- 战斗力
	local labelFight = CommonFunc_getLabel(tostring(value.battle_power), 19)
	labelFight:setPosition(ccp(0, 0))
	labelFight:setAnchorPoint(ccp(0.5, 0.5))
	labelFightBg:addChild(labelFight)
	
	return node
end

-- 对手信息
local function showEnemyUI()
	if mRootView == nil then
		return 
	end
	
	local layout = mRootView:getChildByName("ImageView_68")
	for i = 1, #enemyWidget, 1 do
		layout:removeChild(enemyWidget[i])
	end
	
	local posX = 142
	local posY = 124
	for i = 1, 3, 1 do
		local enemyUI = getEnemyUI(i)
		enemyUI:setPosition(ccp(posX, posY))
		enemyUI:setName("ememy_"..i)
		-- enemyUI:setTag(m_enemyTag + i)
		enemyWidget[i] = enemyUI
		layout:addChild(enemyUI)
		-- layout:addChild(enemyUI)
		posY = posY - 108
		-- if i%2 == 0 then
			-- posY = posY - 116
			-- posX = 144
		-- end
		-- getEnemyUI(i)
	end
end

--------------------------------------------------------------------------------------------------
-- 对友详细信息
local function getTeammateUI(tag)
	local value = teammateInfoTable[tag]
	local node = CommonFunc_getImgView("public2_bg_07.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(10, 10, 1, 1))
	node:setSize(CCSizeMake(270, 106))
	
	local nullNode = CommonFunc_getImgView("touming.png")
	node:addChild(nullNode)
	local existNode = CommonFunc_getImgView("touming.png")
	node:addChild(existNode)
	
	
	if value == nil then
		nullNode:setVisible(true)
		existNode:setVisible(false)
		-- 头像
		local imgHead = CommonFunc_getImgView("gamematch_frame.png")
		imgHead:setPosition(ccp(-82, 0))
		imgHead:setScale(1.1)
		imgHead:setTag(tag)
		nullNode:addChild(imgHead)
		-- 获取队友
		local btnGetTeammate = CommonFunc_getImgView("public_newbuttom_11.png")
		btnGetTeammate:setTouchEnabled(true)
		btnGetTeammate:registerEventScript(Match_OnClick)
		btnGetTeammate:setPosition(ccp(45, 0))
		btnGetTeammate:setTag(tag)
		btnGetTeammate:setName("getTeammate")
		nullNode:addChild(btnGetTeammate)
		-- 获取队友文字图片
		local getTeammateWord = CommonFunc_getImgView("text_huoquduiyou.png")
		getTeammateWord:setAnchorPoint(ccp(0.5, 0.5))
		btnGetTeammate:addChild(getTeammateWord)
	else
		nullNode:setVisible(false)
		existNode:setVisible(true)
		-- 获取 是否可以改变队友 昵称及战斗力当前坐标
		local changeTm, curPosition = canChangeTeammate()
		-- 头像
		local imgHead = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(value.type,value.advanced_level))
		imgHead:setPosition(ccp(-82, 0))
		imgHead:setTag(tag)
		existNode:addChild(imgHead)
		-- 等级
		local labelAtlasLv = CommonFunc_getAtlas("01234567890", "num_black.png", 24, 32, 0)
		labelAtlasLv:setScale(0.5)
		labelAtlasLv:setAnchorPoint(ccp(0, 0.5))
		labelAtlasLv:setPosition(ccp(-39, 28))
		labelAtlasLv:setStringValue(tostring(value.level))
		imgHead:addChild(labelAtlasLv)
		-- 红心背景
		local redHeartBg = CommonFunc_getImgView("warmap_modify.png")
		redHeartBg:setPosition(ccp(-30, -39))
		redHeartBg:setScale(0.6)
		redHeartBg:setZOrder(10)
		imgHead:addChild(redHeartBg)
		-- 红心
		local redHeartImg = CommonFunc_getImgView("warmap_heart.png")
		redHeartImg:setScale(0.5)
		redHeartBg:addChild(redHeartImg)
		-- 血条背景
		local lifebarBg = CommonFunc_getImgView("shuxing_1.png")
		lifebarBg:setPosition(ccp(-21, -40))
		lifebarBg:setAnchorPoint(ccp(0, 0.5))
		lifebarBg:setScaleX(0.3)
		lifebarBg:setScaleY(0.4)
		imgHead:addChild(lifebarBg)
		-- 血条
		local lifebarImg = CommonFunc_getImgView("newshuxing_1.png")
		lifebarImg:setAnchorPoint(ccp(0, 0.5))
		lifebarBg:addChild(lifebarImg)
		local maxLife = value.battle_prop.life
		local ratio = value.curHp / maxLife
		if ratio >= 1 then
			ratio = 1
		else
			isDropLife = true
		end
		lifebarImg:runAction(actionLoadingBar(ratio))
		-- 血条数值
		local atlasLife = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
		atlasLife:setPosition(ccp(90, 0))
		atlasLife:setScale(0.9)
		atlasLife:setStringValue(tostring(value.curHp))
		lifebarBg:addChild(atlasLife)
		-- 昵称背景
		local labelNickBg = CommonFunc_getImgView("public2_bg_05.png")
		labelNickBg:setScale9Enabled(true)
		labelNickBg:setCapInsets(CCRectMake(14, 14, 1, 1))
		labelNickBg:setSize(CCSizeMake(144, 24))
		labelNickBg:setPosition(curPosition[1])
		existNode:addChild(labelNickBg)
		-- 昵称
		local labelNick = CommonFunc_getLabel(value.nickname, 19)
		labelNick:setPosition(ccp(0, 0))
		labelNick:setAnchorPoint(ccp(0.5, 0.5))
		labelNickBg:addChild(labelNick)
		-- 战斗力背景
		local labelFightBg = CommonFunc_getImgView("public2_bg_05.png")
		labelFightBg:setScale9Enabled(true)
		labelFightBg:setCapInsets(CCRectMake(14, 14, 1, 1))
		labelFightBg:setSize(CCSizeMake(144, 24))
		labelFightBg:setPosition(curPosition[2])
		existNode:addChild(labelFightBg)
		-- 战斗力
		local labelFight = CommonFunc_getLabel(tostring(value.battle_power), 19)
		labelFight:setPosition(ccp(0, 0))
		labelFight:setAnchorPoint(ccp(0.5, 0.5))
		labelFightBg:addChild(labelFight)
		-- 更换队友
		local btnResTeammate = CommonFunc_getImgView("public_newbuttom_2.png")
		btnResTeammate:setScale(0.7)
		btnResTeammate:setTag(tag)
		btnResTeammate:setName("resTeammate")
		btnResTeammate:setPosition(ccp(50, -28))
		existNode:addChild(btnResTeammate)
		btnResTeammate:setVisible(changeTm)
		btnResTeammate:setTouchEnabled(changeTm)
		btnResTeammate:registerEventScript(Match_OnClick)
		-- 更换队友文字
		local resTeammateWord = CommonFunc_getImgView("text_genghuanduiyou.png")
		btnResTeammate:addChild(resTeammateWord)
	end
	return node
end

-- 队友 玩家 信息
local function showTeammateUI()
	if mRootView == nil then
		return 
	end
	local layout = mRootView:getChildByName("ImageView_68")
	for i = 1, #teammateWidget, 1 do
		layout:removeChild(teammateWidget[i])
	end
	
	local posX = -142
	local posY = 124
	for i = 1, 2, 1 do
		local teammateUI = getTeammateUI(i)
		teammateUI:setPosition(ccp(posX, posY))
		teammateUI:setName("teammate_"..i)
		teammateWidget[i] = teammateUI
		layout:addChild(teammateUI)
		posY = posY - 108
	end
end

-------------------------------------------------------------------------------------------------------------
-- 获取玩家信息
local function getPlayerUI()
	local node = CommonFunc_getImgView("public2_bg_07.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(10, 10, 1, 1))
	node:setSize(CCSizeMake(270, 106))
	
	-- 头像
	local imgHead = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel()))
	imgHead:setPosition(ccp(-82, 0))
	node:addChild(imgHead)
	-- 等级
	local labelAtlasLv = CommonFunc_getAtlas("01234567890", "num_black.png", 24, 32, 0)
	labelAtlasLv:setScale(0.5)
	labelAtlasLv:setAnchorPoint(ccp(0, 0.5))
	labelAtlasLv:setPosition(ccp(-39, 28))
	local curLv,_ = ModelPlayer.getLevel()
	labelAtlasLv:setStringValue(tostring(curLv))
	imgHead:addChild(labelAtlasLv)
	-- 红心背景
	local redHeartBg = CommonFunc_getImgView("warmap_modify.png")
	redHeartBg:setPosition(ccp(-30, -39))
	redHeartBg:setScale(0.6)
	redHeartBg:setZOrder(10)
	imgHead:addChild(redHeartBg)
	-- 红心
	local redHeartImg = CommonFunc_getImgView("warmap_heart.png")
	redHeartImg:setScale(0.5)
	redHeartBg:addChild(redHeartImg)
	-- 血条背景
	local lifebarBg = CommonFunc_getImgView("shuxing_1.png")
	lifebarBg:setPosition(ccp(-21, -40))
	lifebarBg:setAnchorPoint(ccp(0, 0.5))
	lifebarBg:setScaleX(0.3)
	lifebarBg:setScaleY(0.4)
	imgHead:addChild(lifebarBg)
	-- 血条
	local lifebarImg = CommonFunc_getImgView("newshuxing_1.png")
	lifebarImg:setAnchorPoint(ccp(0, 0.5))
	lifebarBg:addChild(lifebarImg)
	local roleConfig = ModelPlayer.getPlayerAttr()		-- 玩家数据
	local maxLife = roleConfig.life					-- 玩家最大生命
	local curLife = ladderMatchInfo.cur_life		-- 玩家当前生命
	local ratio = curLife / maxLife
	if ratio >= 1 then
		ratio = 1
	else
		isDropLife = true
	end
	lifebarImg:runAction(actionLoadingBar(ratio))
	-- 血条数值
	local atlasLife = CommonFunc_getAtlas("01234567890", "num_gold.png", 24, 32, 0)
	atlasLife:setPosition(ccp(90, 0))
	atlasLife:setScale(0.9)
	atlasLife:setStringValue(tostring(curLife))
	lifebarBg:addChild(atlasLife)
	-- 昵称背景
	local labelNickBg = CommonFunc_getImgView("public2_bg_05.png")
	labelNickBg:setScale9Enabled(true)
	labelNickBg:setCapInsets(CCRectMake(14, 14, 1, 1))
	labelNickBg:setSize(CCSizeMake(144, 24))
	labelNickBg:setPosition(ccp(47, 20))
	node:addChild(labelNickBg)
	-- 昵称
	local labelNick = CommonFunc_getLabel(ModelPlayer.getNickName(), 19)
	labelNick:setPosition(ccp(0, 0))
	labelNick:setAnchorPoint(ccp(0.5, 0.5))
	labelNickBg:addChild(labelNick)
	-- 战斗力背景
	local labelFightBg = CommonFunc_getImgView("public2_bg_05.png")
	labelFightBg:setScale9Enabled(true)
	labelFightBg:setCapInsets(CCRectMake(14, 14, 1, 1))
	labelFightBg:setSize(CCSizeMake(144, 24))
	labelFightBg:setPosition(ccp(47, -20))
	node:addChild(labelFightBg)
	-- 战斗力
	local newBattlePower, oldBattlePower = ModelPlayer.getBattlePower()
	local labelFight = CommonFunc_getLabel(tostring(newBattlePower), 19)
	labelFight:setPosition(ccp(0, 0))
	labelFight:setAnchorPoint(ccp(0.5, 0.5))
	labelFightBg:addChild(labelFight)
	
	return node
end

-- 展示玩家信息
local function initPlayerUI()
	if mRootView == nil then
		return 
	end
	
	local layout = mRootView:getChildByName("ImageView_68")
	layout:removeChild(playerWidget)
	
	local posX = -142
	local posY = -92
	local playerUI = getPlayerUI()
	playerUI:setPosition(ccp(posX, posY))
	playerUI:setName("player")
	playerWidget = playerUI
	layout:addChild(playerUI)
end

-------------------------------------------------------------------------------------------------------------
-- 请求重置关卡返回结果
local function handle_reset_ladder_match_result(resp)
	if resp.result == 1 then
		lastPassLevel = nil
		if mRootView == nil then
			return 
		end
		local stageNode = mRootView:getChildByName("ChallengeStage")
		stageNode:removeAllChildren()
		initLine()
		initChallengeStage()
	end
end
-- 请求重置关卡
local function resLadderMatch()
	local function dialogSureCall()
		local tb = req_reset_ladder_match()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_reset_ladder_match_result"])
	end
	local str = "GAME_MATCH_TIP_3"
	local diaMsg = 
	{
		strText = string.format(GameString.get(str)),
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end

-------------------------------------------------------------------------------------------------------------
-- 更换队友返回结果
local function handle_reselect_ladder_teammate_result(resp)
	teammateInfoTable[tempTeammateTag] = resp.teammate_info
	local layout = mRootView:getChildByName("ImageView_68")
	for i = 1, #teammateWidget, 1 do
		layout:removeChild(teammateWidget[i])
	end
	teammateWidget[tempTeammateTag] = nil
	initButtonEvent()	-- 工程按键
	showTeammateUI()	-- 展示 刷新 对友
end

-- 更换队友
local function resTeammate()
	local function dialogSureCall()
		if CommonFunc_payConsume(2, RESET_TEAMMATE_EMONEY) then
			return
		end
		if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
			UIManager.pop(UIManager.getTopLayerName())
		end
		local tb = req_reselect_ladder_teammate()
		tb.role_id = teammateInfoTable[tempTeammateTag].role_id
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_reselect_ladder_teammate_result"])
	end
	local str = "GAME_MATCH_TIP_2"
	local diaMsg = 
	{
		strText = string.format(GameString.get(str, RESET_TEAMMATE_EMONEY)),
		buttonCount = 2,
		isPop = false,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {dialogSureCall, nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end

--------------------------------------------------------------------------------------------------------------
-- 获取队友返回结果
local function handle_req_ladder_teammate_result(resp)
	teammateInfoTable[tempTeammateTag] = resp.teammate_info
	local layout = mRootView:getChildByName("ImageView_68")
	for i = 1, #teammateWidget, 1 do
		layout:removeChild(teammateWidget[i])
	end
	initButtonEvent()	-- 工程按键
	showTeammateUI()	-- 展示 刷新 对友
end

-- 获取队友
local function getTeammate()
	local tb = req_ladder_teammate()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_req_ladder_teammate_result"])
end

---------------------------------------------------------------------------------------------------------------
-- 请求回血返回结果
local function handle_recover_teammate_life_result(resp)
	if resp.result == 1 then
		isDropLife = false
	end
end

-- 请求回复生命
local function comfirmRecoverLife()
	
	if ladderMatchInfo.is_failed == 1 then		-- 挑战失败
		Toast.show(GameString.get("GAME_MATCH_TIP_9"))
		return
	elseif #teammateInfoTable < 2 then					-- 队友不足
		Toast.show(GameString.get("GAME_MATCH_TIP_8"))
		return
	elseif ladderMatchInfo.pass_level == 12 then		-- 全部通关
		Toast.show(GameString.get("GAME_MATCH_TIP_10"))
		return
	elseif isDropLife == false then					-- 没人掉血
		Toast.show(GameString.get("GAME_MATCH_TIP_6"))
		return
	end
	if RECOVER_FREE_COUNT > ladderMatchInfo.recover_count then
		local function dialogSureCall()
			local tb = req_recover_teammate_life()
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_recover_teammate_life_result"])
		end
		local str = "GAME_MATCH_TIP_11"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str)),
			buttonCount = 2,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
		return
	else
		local function dialogSureCall()
			if CommonFunc_payConsume(2, RECOVER_NEED_EMONEY) then		-- 魔石不足
				return
			end
			if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
				UIManager.pop(UIManager.getTopLayerName())
			end
			local tb = req_recover_teammate_life()
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_recover_teammate_life_result"])
		end
		local str = "GAME_MATCH_TIP_1"
		local diaMsg = 
		{
			strText = string.format(GameString.get(str, RECOVER_NEED_EMONEY)),
			buttonCount = 2,
			isPop = false,
			buttonName = {GameString.get("sure"), GameString.get("cancle")},
			buttonEvent = {dialogSureCall, nil}
		}
		UIManager.push("UI_ComfirmDialog", diaMsg)
	end
end

---------------------------------------------------------------------------------------------------------------
-- 获取队友 对手 信息返回结果
local function handle_ladder_role_list(resp)
	enemyInfoTable = resp.opponent
	teammateInfoTable = resp.teammate
	if nil == mRootView then
		return
	end
	if enemyInfoTable == nil or #enemyInfoTable == 0 then
		cclog("enemyInfoTable is nil")
		return
	end
	local layout = mRootView:getChildByName("ImageView_68")
	for i = 1, #teammateWidget, 1 do
		layout:removeChild(teammateWidget[i])
	end
	
	for i = 1, #enemyWidget, 1 do
		layout:removeChild(enemyWidget[i])
	end
	
	
	initButtonEvent()	-- 工程按键
	showTeammateUI()	-- 展示 刷新 对友
	showEnemyUI()		-- 展示 刷新 对手
end

-- 获取对友 队手 信息
local function freshEnemyMessage()
	local tb = req_ladder_match_info()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_ladder_match_info"])
	local tb = req_ladder_role_list()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_ladder_role_list"])
end

---------------------------------------------------------------------------------------------------------------
-- 进入战斗
local function EnterLadderMatch()
	if #teammateInfoTable < 2 then						-- 队友不足
		Toast.show(GameString.get("GAME_MATCH_TIP_7"))
		return
	elseif ladderMatchInfo.is_failed == 1 then			-- 挑战失败
		Toast.show(GameString.get("GAME_MATCH_TIP_9"))
		return
	elseif ladderMatchInfo.pass_level == 12 then		-- 全部通关
		Toast.show(GameString.get("GAME_MATCH_TIP_10"))
		return
	end
	
	lastPassLevel = ladderMatchInfo.pass_level
	FightStartup.startladderMatch(teammateInfoTable, enemyInfoTable)
end

function Match_OnClick(type,widget)
	if type =="releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		if widgetName == "recover_life" then			-- 回复生命
			comfirmRecoverLife()
		elseif widgetName == "ladder_atk" then			-- 挑战玩家
			EnterLadderMatch()
		elseif widgetName == "getTeammate" then		-- 获取队友
			tempTeammateTag = widget:getTag()
			getTeammate()
		elseif widgetName == "resTeammate" then		-- 更换队友
			tempTeammateTag = widget:getTag()
			resTeammate()
		elseif widgetName == "res_challenge" then		-- 重置关卡
			resLadderMatch()
		end
	end
end

LayerGameMatch.resetPlayAni = function ()
    isPlayAning = false
end 

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	local widgetName = sender:getName()
	if widgetName == "Button_close" then	-- 关闭
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", sender:getName())
	end
end

-- 初始化静态UI
local function initUI()
	-- 关闭btn event
	local btnClose = mRootView:getChildByName("Button_close")
    btnClose:registerEventScript(btnCall)
end

-- 获取玩家当前血量
LayerGameMatch.getCurLife = function()
	return ladderMatchInfo.cur_life or 0
end

LayerGameMatch.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		cclog("LayerGameMatch init nil")
		return nil
	end
	-- 初始化静态UI
	initUI()
	
	-- 刷新/展示 玩家 对手 队友
	freshEnemyMessage()
	
	-- setTipIcon("addreward_day", mIsGetDialyReWard)
	-- setTipIcon("addreward_week", mIsGetWeeklyReWard)
	-- setTipIcon("ladder_atk", LeftTimes)
	
end

LayerGameMatch.destroy = function()
	mRootView = nil
	tempTeammateTag = nil
end

NetSocket_registerHandler(NetMsgType["msg_notify_ladder_role_list"], notify_ladder_role_list, handle_ladder_role_list)
NetSocket_registerHandler(NetMsgType["msg_notify_recover_teammate_life_result"], notify_recover_teammate_life_result, handle_recover_teammate_life_result)
NetSocket_registerHandler(NetMsgType["msg_notify_req_ladder_teammate_result"], notify_req_ladder_teammate_result, handle_req_ladder_teammate_result)
NetSocket_registerHandler(NetMsgType["msg_notify_reselect_ladder_teammate_result"], notify_reselect_ladder_teammate_result, handle_reselect_ladder_teammate_result)
NetSocket_registerHandler(NetMsgType["msg_notify_reset_ladder_match_result"], notify_reset_ladder_match_result, handle_reset_ladder_match_result)


-- 分组赛基本信息
local function handle_ladder_match_info(resp)
	ladderMatchInfo = resp
	-- 刷新玩家
	initPlayerUI()
	if teammateInfoTable ~= nil then
		initButtonEvent()	-- 工程按键
		showTeammateUI()	-- 展示 刷新 对友
	end
	
	if lastPassLevel == nil or lastPassLevel == ladderMatchInfo.pass_level then
		initLine()
		initChallengeStage()
	elseif lastPassLevel ~= nil and lastPassLevel < ladderMatchInfo.pass_level then
		updateLineUI()
	end
end
NetSocket_registerHandler(NetMsgType["msg_notify_ladder_match_info"], notify_ladder_match_info, handle_ladder_match_info)

-- 下线 清空信息
local function handleClearData()
	lastPassLevel = nil
end
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)


