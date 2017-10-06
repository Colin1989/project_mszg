----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-08-25
-- Brief:	提醒功能界面
----------------------------------------------------------------------
LayerTipFunction = {}
LayerAbstract:extend(LayerTipFunction)
----------------------------------------------------------------------
-- 根据提示id获取相关配置
local function getConfig(tipId)
	local tb = 
	{
		[1001] = {LayerSmithMain, "Smith_Main.json", "LayerEquipForgeUI", LIMIT_FORGE},			-- 装备强化
		[1002] = {LayerSmithMain, "Smith_Main.json", "LayerEquipForgeUI", LIMIT_FORGE_UPGRADE},	-- 装备晋阶
		[1003] = {LayerSmithMain, "Smith_Main.json", "LayerEquipForgeUI", LIMIT_FORGE},			-- 装备重铸
		[1004] = {LayerRoleUp, LayerRoleUp.jsonFile, "LayerRoleUpUI", LIMIT_HERO_STREN},						-- 潜能提升
		[1005] = {LayerSkillMain, "SkillMain.json", "LayerSkillMainUI", nil},									-- 技能提升
		[1006] = {LayerBackpack, "Backpack_Main.json", "LayerBackpackUI", nil},									-- 宝石合成
		[1007] = {LayerSmithMain, "Smith_Main.json", "LayerBackpackUI", LIMIT_GEM_INLAY},				-- 宝石镶嵌
		[1008] = {LayerGameRankChoice, "GameRankChoice_1.json", "LayerGameRankChoiceUI", LIMIT_TRAIN_GAME},		-- 训练赛
		[1009] = {LayerGameRankChoice, "GameRankChoice_1.json", "LayerGameRankChoiceUI", LIMIT_LADDERMATCH},	-- 分组赛
		[1010] = {LayerGameRankChoice, "GameRankChoice_1.json", "LayerGameRankChoiceUI", LIMIT_RANK_GAME},		-- 排位赛
		[1011] = {LayerActivity, "Activity.json", "LayerActivityUI", LIMIT_ACTIVITY},							-- 每日奖励
		[1012] = {LayerActivity, "Activity.json", "LayerActivityUI", LIMIT_ACTIVITY},							-- 活跃奖励
		[1013] = {LayerSocialContactEnter, "SocialContact.json", "LayerSocialContactEnterUI", LIMIT_ACTIVITY},	-- 友情抽奖
		[1014] = {LayerActivity, "Activity.json", "LayerActivityUI", LIMIT_ACTIVITY},							-- 炼金术
		[1015] = {LayerActivity, "Activity.json", "LayerActivityUI", LIMIT_ACTIVITY},							-- 在线奖励
		[1016] = {LayerActivity, "Activity.json", "LayerActivityUI", LIMIT_TOWER},								-- 魔塔
		[1017] = {LayerActivity, "Activity.json", "LayerActivityUI", LIMIT_ENTER_BOSS},							-- boss挑战
		[1018] = {LayerBless, "bless_1.json", "LayerBlessUI", nil},												-- 女神祝福
		[1019] = {LayerRune, "Rune_1.json", "LayerRuneUI"},														-- 召唤
		[1020] = {LayerGameRankChoice, "GameRankChoice_1.json", "LayerGameRankChoiceUI", LIMIT_CHAL_CONVERT},	-- 军衔荣誉
	}
	return tb[tipId]
end
----------------------------------------------------------------------
-- 获取提示功能模块属性
local function getTipFunctionAttr(tipId, attrName)
	local funcNameTable = 
	{
		[1008] = "func_train_match",
		[1009] = "func_ladder_match",
		[1010] = "func_rank_match",
		[1011] = "func_daily_award",
		[1014] = "func_get_coin",
		[1015] = "func_online_award",
		[1016] = "func_push_tower",
		[1017] = "func_boss_copy",
		[1020] = "func_miltitary_award",
	}
	return TipFunction.getFuncAttr(funcNameTable[tipId], attrName)
end
----------------------------------------------------------------------
-- 获取提示功能列表
local function getTipTable()
	local tempTable = {}
	local tipFunctionTable = LogicTable.getTipFunctionTable()
	for key, val in pairs(tipFunctionTable) do
		if 0 == val.type then
			val.priority = 2
			table.insert(tempTable, val)
		elseif 1 == val.type then
			local count = getTipFunctionAttr(val.id, "count") or 0
			if count < val.count then
				local waiting = getTipFunctionAttr(val.id, "waiting") or false
				if true == waiting then
					val.priority = 3
				else
					val.priority = 1
				end
				table.insert(tempTable, val)
			end
		end
	end
	table.sort(tempTable, function(a, b) return a.priority < b.priority end)
	return tempTable
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		LayerMain.pullPannel(LayerTipFunction)
	end
end
----------------------------------------------------------------------
-- 点击提示单元格
local function clickTipCell(typeName, widget)
	if "releaseUp" == typeName then
		LayerTipFunction.gotoTipFunction(widget:getTag())
	end
end
----------------------------------------------------------------------
-- 创建提示单元格
local function createTipCell(cell, data, index)
	-- 背景
	local cellBg = UIImageView:create()
	if 3 == data.priority then
		cellBg:loadTexture("public2_bg_07b.png")
	else
		cellBg:loadTexture("public2_bg_22.png")
	end
	cellBg:setScale9Enabled(true)
	cellBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	cellBg:setSize(CCSizeMake(583, 116))
	cellBg:setTag(data.id)
	cellBg:registerEventScript(clickTipCell)
	if 3 == data.priority then
		cellBg:setTouchEnabled(false)
	else
		cellBg:setTouchEnabled(true)
	end
	-- 图标
	local tipIcon = CommonFunc_getImgView(data.icon)
	tipIcon:setPosition(ccp(-230, 0))
	cellBg:addChild(tipIcon)
	-- 标题背景
	local titleBg = UIImageView:create()
	if 3 == data.priority then
		titleBg:loadTexture("public2_bg_06b.png")
	else
		titleBg:loadTexture("public2_bg_06.png")
	end
	titleBg:setScale9Enabled(true)
	titleBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	titleBg:setSize(CCSizeMake(266, 38))
	titleBg:setPosition(ccp(-30, 30))
	cellBg:addChild(titleBg)
	-- 标题
	local titleLabel = CommonFunc_getLabel(data.title, 24)
	titleLabel:setColor(ccc3(255, 190, 29))
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setPosition(ccp(-140, 28))
	cellBg:addChild(titleLabel)
	-- 数量
	if 1 == data.type then
		local count = getTipFunctionAttr(data.id, "count")
		local currCountLabel = CommonFunc_getLabel(tostring(count), 24)
		currCountLabel:setColor(ccc3(255, 0, 0))
		currCountLabel:setAnchorPoint(ccp(1, 0.5))
		currCountLabel:setPosition(ccp(10, 28))
		cellBg:addChild(currCountLabel)
		local totalCountLabel = CommonFunc_getLabel("/"..data.count, 24)
		totalCountLabel:setColor(ccc3(0, 255, 0))
		totalCountLabel:setAnchorPoint(ccp(0, 0.5))
		totalCountLabel:setPosition(ccp(15, 28))
		cellBg:addChild(totalCountLabel)
	end
	-- 描述
	local desclabel = CommonFunc_getLabel(data.desc)	
	desclabel:setTextAreaSize(CCSizeMake(430, 60))
	desclabel:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	desclabel:setTextVerticalAlignment(kCCVerticalTextAlignmentTop)
	desclabel:setPosition(ccp(60, -25))
	cellBg:addChild(desclabel)
	return cellBg
end
----------------------------------------------------------------------
-- 初始化
LayerTipFunction.init = function(rootView)
	local tipFunctionTable = getTipTable()
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 标题
	local titleImage = tolua.cast(rootView:getChildByName("ImageView_181"), "UIImageView")
	titleImage:loadTexture("text_tixing.png")
	-- 列表
	local dataTable = {}
	for key, val in pairs(tipFunctionTable) do
		local cfg = getConfig(val.id)
		if cfg and (nil == cfg[4] or true == CopyDelockLogic.judgeYNEnterById(cfg[4].copy_id)) then
			table.insert(dataTable, val)
		end
	end
	local scrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, dataTable, createTipCell, "V", 583, 116, 12, 1, 6, true, nil, true, true)
end
----------------------------------------------------------------------
-- 销毁
LayerTipFunction.destroy = function()
end
----------------------------------------------------------------------
-- 提示功能跳转
LayerTipFunction.gotoTipFunction = function(tipId)
	local cfg = getConfig(tipId)
	if cfg then
		TipFunction.setTip(tipId)
		UIManager.retrunMain()
		setConententPannelJosn(cfg[1], cfg[2], cfg[3])
	end
end
----------------------------------------------------------------------

