----------------------------------------------------------------------
--作者：李慧琴
--说明：副本信息界面
--时间：2014-2-19
----------------------------------------------------------------------
LayerCopyTips = {}
LayerAbstract:extend(LayerCopyTips)

local mRootView = nil
local mCopyId = nil			-- 保存当前副本id
local mSweepInfo = nil			-- 扫荡卡对象（没有就默认nil)
----------------------------------------------------------------------
-- 进入游戏
local function enterGame()
	UIManager.pop("UI_CopyTips")
	if "pass" == CopyDateCache.getCopyStatus(LIMIT_ASSISTANCE.copy_id) and 1 ~= tonumber(LIMIT_ASSISTANCE.copy_id) then
		AssistanceLogic.setEnterType(0)
		UIManager.push("UI_Assistance")
	else 
		FightStartup.startStage(LayerCopyTips.getId())
	end
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		UIManager.pop("UI_CopyTips")
	end
end
----------------------------------------------------------------------
local mNeedPp = 0
-- 点击确认按钮
local function clickSureBtn(typeName, widget)
	if "releaseUp" == typeName then
        if ModelPlayer.getHpPower() < mNeedPp then 
            local price = getPowerUpPrice(ModelPlayer.getHpPowerBuyTimes())
			local structConfirm =
			{
				strText = GameString.get("BuyPp2", price),
				buttonCount = 2,
				buttonName = {GameString.get("sure"),GameString.get("cancle")},
				buttonEvent = {power_yes,nil}, --回调函数
				buttonEvent_Param = {nil,nil} --函数参数
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)	
        else 
        	TipModule.onClick(widget)
		    enterGame()
        end
	end
end
----------------------------------------------------------------------
-- 点击扫荡按钮
local function clickSweepBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local tag = widget:getTag()
		if 1 == tag then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_SWEEP.copy_id),LIMIT_SWEEP.fbName))
		-- elseif 2 == tag then
			-- Toast.show(GameString.get("Public_Power_BZ"))
		elseif 3 == tag then
			Toast.show(GameString.get("ThreeStar_Sweep"))
		-- elseif 4 == tag then
			-- Toast.show(GameString.get("Sweep_Card_BZ"))
		else	-- 0 == tag
			UIManager.push("UI_SweepTimes", mCopyId)
		end
	end
end
----------------------------------------------------------------------
-- 点击更换按钮
local function clickChangeBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local bundle = {}
		bundle.callback = enterGame
		UIManager.push("UI_SkillGroup", bundle)
	end
end
----------------------------------------------------------------------
-- 根据副本信息,获得展示的体力或召唤石
local function getCostInfo(info)
	if 1 == tonumber(info.type) or 2 == tonumber(info.type) then	-- 普通副本,精英副本
		return "public_tili.png", tonumber(info.need_power) + tonumber(info.win_need_power)
	elseif 3 == tonumber(info.type) then	-- BOSS副本
		return "public_summon_stone.png", info.need_stone
	end
end
----------------------------------------------------------------------
-- 设置掉落物品
local function setDropList(rootView, dropItems)
	local scrollView = tolua.cast(rootView:getWidgetByName("ScrollView_list"), "UIScrollView")

    local ArrayDate = {}
    -- 图片
    for key, data in pairs(dropItems) do

     
  		local iconImage = CommonFunc_createUIImageView(nil, ccp(0,0), CCSizeMake(94, 94), "touming.png", string.format("headbackground_%d", key), 1)    
        table.insert(ArrayDate,FightOver_addQuaIconByRewardId(data.id, iconImage, 1,nil))

        local function clickIcon(node)
            local ReWardInfo = LogicTable.getRewardItemRow(data.id) 
            --local itemInfo = LogicTable.getItemById(ReWardInfo.temp_id)
			if 7 == ReWardInfo.type then
				-- CommonFunc_showInfo(1, tonumber(ReWardInfo.temp_id), 0, nil ,"UI_CopyTips")
			else
				-- CommonFunc_showInfo(0, tonumber(ReWardInfo.temp_id), 0, nil ,"UI_CopyTips")
			end
		end
		
		local function clickSkillIcon(iconImage)
			showLongInfoByRewardId(data.id,iconImage)
		end
		
		local function clickSkillIconEnd(iconImage)
			longClickCallback_reward(data.id,iconImage)
		end


		UIManager.registerEvent(iconImage, clickIcon, clickSkillIcon, clickSkillIconEnd)
        iconImage:setTouchEnabled(true)
    end
    setListViewAdapter(nil,scrollView,ArrayDate,"H") 
	--UIEasyScrollView:create(scrollView, dataTable, createCell, 100, false, 10, 2, false)	
end

----------------------------------------------------------------------
-- 初始化界面
local function initInfo(rootView)
	local copyInfo = nil
    local gameAllFB = LogicTable.getGameAllFB()
    for key, value in pairs(gameAllFB) do
        if mCopyId == value.id then
			copyInfo = value
			break
        end
	end
	if nil == rootView or nil == copyInfo then
		return
	end
	-- 副本名
	local namtLabel = tolua.cast(rootView:getWidgetByName("Label_name"), "UILabel")
	namtLabel:setText(copyInfo.name)
	FightConfig.setConfig("fc_battle_map_name", copyInfo.name)
	-- 副本描述
	local descLabel = tolua.cast(rootView:getWidgetByName("Label_describe"), "UILabel")
	descLabel:setText(copyInfo.describe)
	descLabel:ignoreContentAdaptWithSize(true)
	-- 花费信息
	local costIcon, costNum = getCostInfo(copyInfo)
	local costIconImage = tolua.cast(rootView:getWidgetByName("ImageView_cost_icon"), "UIImageView")
	costIconImage:loadTexture(costIcon)
	local costLabel = tolua.cast(rootView:getWidgetByName("Label_cost"), "UILabel")
	costLabel:setText(costNum)
	-- 金币
	local coinLabel = tolua.cast(rootView:getWidgetByName("Label_reward_coin"), "UILabel")
	coinLabel:setText(copyInfo.gold)
	-- 经验
	local expLabel = tolua.cast(rootView:getWidgetByName("Label_reward_exp"), "UILabel")
	expLabel:setText(copyInfo.exp)
	-- 战斗力
	local combatLabel = tolua.cast(rootView:getWidgetByName("Label_combat"), "UILabel")
	combatLabel:setText(copyInfo.recommended_battle_power)
	-- 掉落物品
	local dropItems = CopyLogic.searchMonsterTable(copyInfo.first_map_id, copyInfo.dropitems)
	setDropList(rootView, dropItems)
end
----------------------------------------------------------------------
-- 刷新技能组
local function refreshSkillGroup(rootView)
	local currSkillGroup = ModelSkill.getSkillGroup()
	for i=1, 4 do
		local skillImage = tolua.cast(rootView:getWidgetByName("ImageView_skill"..i), "UIImageView")
		local skill = ModelSkill.getSkill(currSkillGroup.skills[i])
		if nil == skill then
			skillImage:setTouchEnabled(false)
			skillImage:removeAllChildren()
			skillImage:loadTexture("public_runeback.png")
		else
			CommonFunc_AddGirdWidget_Rune(skill.temp_id, skill.value, nil, skillImage)
			skillImage:setTouchEnabled(true)
			
			local function clickSkillIcon(skillImage)
				local position,direct = CommonFuncJudgeInfoPosition(skillImage)
				local bundle = {}
				bundle.skill_id = skill.temp_id
				bundle.level = skill.value
				bundle.position = position
				bundle.direct =direct
				UIManager.push("UI_SkillInfo_Long", bundle)
			end
			UIManager.registerEvent(skillImage, nil, clickSkillIcon, CommonFunc_longEnd_skill)	
		end
	end
end
----------------------------------------------------------------------
-- 新手技能图标特殊处理
local function skillShowForGuide(rootView)
	-- 新手处理
	if 0 == GuideMgr.guideStatus() then
		return
	end
	local lockTb = {}
	if false == GuideMgr.checkProgress(GuideForce_UseAddBloodSkill) then
		if "pass" ~= CopyDateCache.getCopyStatus(GuideForce_UseAddBloodSkill.copy_id) then
			table.insert(lockTb, 2)
			table.insert(lockTb, 3)
			table.insert(lockTb, 4)
		end
	elseif false == GuideMgr.checkProgress(GuideForce_UseGroupAttackSkill) then
		if "pass" ~= CopyDateCache.getCopyStatus(GuideForce_UseGroupAttackSkill.copy_id) then
			table.insert(lockTb, 4)
		end
	end
	for key, val in pairs(lockTb) do
		local skillImage = tolua.cast(rootView:getWidgetByName("ImageView_skill"..val), "UIImageView")
		Action_createLock94x94(skillImage, true, ccp(0, 0))
	end
end

----------------------------------------------------------------------
-- 刷新扫荡卡数量
LayerCopyTips.updateSweepInfo = function()
	if mRootView == nil then
		return
	end
	-- 1000 为扫荡卡ID
	mSweepInfo = ModelBackpack.getItemByTempId(1000)
	local labelatlas = tolua.cast(mRootView:getWidgetByName("LabelAtlas_sweep_card"), "UILabel")
	if mSweepInfo ~= nil then
		labelatlas:setText(tostring(mSweepInfo.amount))
	else
		labelatlas:setText(string.format("%s", 0))
	end
end

----------------------------------------------------------------------
-- 初始化:要传入参数,当前的副本id,
LayerCopyTips.init = function(copyID)
    local rootView = UIManager.findLayerByTag("UI_CopyTips")
	mRootView = rootView
    mCopyId = copyID
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 确认按钮
	local sureBtn = tolua.cast(rootView:getWidgetByName("Button_sure"), "UIButton")
	sureBtn:registerEventScript(clickSureBtn)
	-- 扫荡按钮
	local sweepBtn = tolua.cast(rootView:getWidgetByName("Button_sweep"), "UIButton")
	sweepBtn:registerEventScript(clickSweepBtn)
	-- 扫荡文字
	local imgSweep = tolua.cast(rootView:getWidgetByName("ImageView_sweep"), "UIImageView")
	-- 更换按钮
	local changeBtn = tolua.cast(rootView:getWidgetByName("Button_change"), "UIButton")
	changeBtn:registerEventScript(clickChangeBtn)
	-- 
	local copyInfo = LogicTable.getCopyById(copyID)
    mNeedPp = tonumber(copyInfo.need_power + copyInfo.win_need_power)
	-- 1000 为扫荡卡ID
	mSweepInfo = ModelBackpack.getItemByTempId(1000)
	local labelatlas = tolua.cast(rootView:getWidgetByName("LabelAtlas_sweep_card"), "UILabel")
	if mSweepInfo ~= nil then
		labelatlas:setText(tostring(mSweepInfo.amount))
	else
		labelatlas:setText(string.format("%s", 0))
	end
	
	if 3 == CopyDateCache.getScoreById(copyID) and (1 == tonumber(copyInfo.type) or 2 == tonumber(copyInfo.type)) then
		if tonumber(LIMIT_SWEEP.copy_id) ~= 1 and  CopyDateCache.getCopyStatus(LIMIT_SWEEP.copy_id) ~= "pass" then
			sweepBtn:setTag(1)
		-- elseif ModelPlayer.getHpPower() < tonumber(copyInfo.need_power + copyInfo.win_need_power) then
			-- sweepBtn:setTag(2)
		-- elseif mSweepInfo == nil then
			-- sweepBtn:setTag(4)
		else
			sweepBtn:setTag(0)
		end
	else 
		if 1 == tonumber(copyInfo.type) or 2 == tonumber(copyInfo.type) then
			sweepBtn:setTag(3)
			sweepBtn:loadTextureNormal("shortbutton_gray.png")
			sweepBtn:loadTexturePressed("shortbutton_gray.png")
			Lewis:spriteShaderEffect(imgSweep:getVirtualRenderer(), "buff_gray.fsh",true)
		else
			sweepBtn:setEnabled(false)
			setWidget_Horizontal_Center(sureBtn)
		end
	end
	initInfo(rootView)
	refreshSkillGroup(rootView)
	TipModule.onUI(rootView, "ui_copytips")
	skillShowForGuide(rootView)
end
----------------------------------------------------------------------
-- 销毁
LayerCopyTips.destroy = function()
	mRootView = nil
end
----------------------------------------------------------------------
-- 获取当前副本id
LayerCopyTips.getId = function()
	return mCopyId
end
----------------------------------------------------------------------
-- 技能组改变
local function handleSkillGroupChange(data)
	local root = UIManager.findLayerByTag("UI_CopyTips")
	if nil == root or false == data.success then
		return
	end
	refreshSkillGroup(root)
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_SKILL_GROUP_CHANGE"], handleSkillGroupChange)






