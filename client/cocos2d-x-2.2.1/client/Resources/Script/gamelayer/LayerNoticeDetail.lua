--region LayerNoticeDetail.lua
--Author : songcy
--Date   : 2014/11/13

LayerNoticeDetail = {}
LayerAbstract:extend(LayerNoticeDetail)

local mRootView = nil
local noticeDetail = nil
local detailData = {}					-- 记录详情

local chatTextWidth = 500				-- 文本框的宽度
local chatIntervalHeight = 18			-- 间隔高度
local totalHeight = 0					-- 总高度

-- 点击返回
local function onClickBack(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	LayerNotice.setJosnWidget(LayerNoticeActivity,"NoticeActivity.json")
end

-- 点击前往
local function onClickToward(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local widgetName = widget:getName()
	UIManager.pop("UI_Notice")
	if noticeDetail.toward_id == 1 then			-- 技能养成界面
		setConententPannelJosn(LayerSkillMain, "SkillMain.json", widgetName)
	elseif noticeDetail.toward_id == 2 then		-- 强化装备界面
		if  tonumber(LIMIT_FORGE.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_FORGE.copy_id) == false then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_FORGE.copy_id),LIMIT_FORGE.fbName))
			return
		end
		LayerSmithMain.setIndex(1)
		setConententPannelJosn(LayerSmithMain, "Smith_Main.json", widgetName)
	elseif noticeDetail.toward_id == 3 then		-- 镶嵌宝石界面
		if  tonumber(LIMIT_FORGE.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_FORGE.copy_id) == false then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_FORGE.copy_id),LIMIT_FORGE.fbName))
			return
		end
		LayerSmithMain.setIndex(2)
		setConententPannelJosn(LayerSmithMain, "Smith_Main.json", widgetName)
	elseif noticeDetail.toward_id == 4 then		-- 重铸界面
		if  tonumber(LIMIT_FORGE.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_FORGE.copy_id) == false then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_FORGE.copy_id),LIMIT_FORGE.fbName))
			return
		end
		LayerSmithMain.setIndex(3)
		setConententPannelJosn(LayerSmithMain, "Smith_Main.json", widgetName)
	elseif noticeDetail.toward_id == 5 then		-- 活动界面
		setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
	elseif noticeDetail.toward_id == 6 then		-- 签到奖励
		setConententPannelJosn(LayerDailyAward, "DailyAward.json", widgetName)
	elseif noticeDetail.toward_id == 7 then		-- 每日活跃
		setConententPannelJosn(LayerDailyCrazy, "DailyCrazyPanel.json", widgetName)
	elseif noticeDetail.toward_id == 8 then		-- 首充奖励
		setConententPannelJosn(LayerFirstRecharge, "FirstRecharge.json", widgetName)
	elseif noticeDetail.toward_id == 9 then		-- 冲级礼包
		setConententPannelJosn(LayerLevelGift, "levelGift.json", widgetName)
	elseif noticeDetail.toward_id == 10 then		-- 领取体力
		setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
		UIManager.push("UI_PowerPh")
	elseif noticeDetail.toward_id == 11 then		-- 充值返利
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
	elseif noticeDetail.toward_id == 12 then		-- 炼金术
		setConententPannelJosn(LayerGetCoin, "Activity_4.json", widgetName)
	elseif noticeDetail.toward_id == 13 then		-- 限量折扣
		setConententPannelJosn(LayerDiscountRestriction, "DisRes.json", widgetName)
	elseif noticeDetail.toward_id == 14 then		-- 魔塔挑战
		if CopyDateCache.getCopyStatus(LIMIT_TOWER.copy_id) ~= "pass" and tonumber(LIMIT_TOWER.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TOWER.copy_id),LIMIT_TOWER.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerTowerbg,"PowerCopyBg.json","PowerCopyBg.json")
	elseif noticeDetail.toward_id == 15 then		-- BOSS挑战
		if CopyDateCache.getCopyStatus(LIMIT_ENTER_BOSS.copy_id) ~= "pass" and tonumber(LIMIT_ENTER_BOSS.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ENTER_BOSS.copy_id),LIMIT_ENTER_BOSS.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerChenallBoss,LayerChenallBoss.josnFile,LayerChenallBoss.josnFile)
	elseif noticeDetail.toward_id == 16 then		-- 虚空之门
		if CopyDateCache.getCopyStatus(LIMIT_ACTIVITY_COPY.copy_id) ~= "pass" and tonumber(LIMIT_ACTIVITY_COPY.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ACTIVITY_COPY.copy_id),LIMIT_ACTIVITY_COPY.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerActivityCopyGroup, "ActivityCopyGroup.json", widgetName)
	elseif noticeDetail.toward_id == 17 then		-- 英雄圣殿界面
		if  tonumber(LIMIT_HERO_UP_LEVEL.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_HERO_UP_LEVEL.copy_id) == false then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_HERO_UP_LEVEL.copy_id),LIMIT_HERO_UP_LEVEL.fbName))
			return
		end
		setConententPannelJosn(LayerRoleUp, LayerRoleUp.jsonFile, widgetName)
	elseif noticeDetail.toward_id == 18 then		-- 英雄潜能
		if  tonumber(LIMIT_HERO_STREN.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_HERO_STREN.copy_id) == false then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_HERO_STREN.copy_id),LIMIT_HERO_STREN.fbName))
			return
		end
		setConententPannelJosn(LayerRoleUpPotent,LayerRoleUpPotent.jsonFile,LayerRoleUpPotent.jsonFile)
	elseif noticeDetail.toward_id == 19 then		-- 英雄天赋
		if tonumber(LIMIT_TALENT.copy_id) ~= 1 and CopyDelockLogic.judgeYNEnterById(LIMIT_TALENT.copy_id) == false then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TALENT.copy_id),LIMIT_TALENT.fbName))
			return
		end
		setConententPannelJosn(LayerRoleTalent,LayerRoleTalent.jsonFile,LayerRoleTalent.jsonFile)
	elseif noticeDetail.toward_id == 20 then		-- 竞技场界面
		if  tonumber(LIMIT_JJC.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_JJC.copy_id) ~= "pass" then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_JJC.copy_id),LIMIT_JJC.fbName))
			return
		end
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", widgetName)
	elseif noticeDetail.toward_id == 21 then		-- 训练赛
		if tonumber(LIMIT_TRAIN_GAME.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_TRAIN_GAME.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TRAIN_GAME.copy_id),LIMIT_TRAIN_GAME.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerGameTrain, "GaneTrain_1.json", widgetName)
	elseif noticeDetail.toward_id == 22 then		-- 分组赛
		if tonumber(LIMIT_LADDERMATCH.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_LADDERMATCH.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_LADDERMATCH.copy_id),LIMIT_LADDERMATCH.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		-- setConententPannelJosn(ladderMatch, "ladderMatch_1.json", widgetName)
		setConententPannelJosn(LayerGameMatch, "GameMatch_1.json", widgetName)
	elseif noticeDetail.toward_id == 23 then		-- 排位赛
		if tonumber(LIMIT_RANK_GAME.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_RANK_GAME.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_RANK_GAME.copy_id),LIMIT_RANK_GAME.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerGameRank, "GameRank_1.json", widgetName)
	elseif noticeDetail.toward_id == 24 then		-- 军衔荣誉
		if  tonumber(LIMIT_JJC.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_JJC.copy_id) ~= "pass" then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_JJC.copy_id),LIMIT_JJC.fbName))
			return
		end
		setConententPannelJosn(LayerMiltitary, "MilitaryPanel.json", widgetName)
	elseif noticeDetail.toward_id == 25 then		-- 竞技场商城
		if tonumber(LIMIT_CHAL_SHOP.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_CHAL_SHOP.copy_id) ~= "pass"  then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_CHAL_SHOP.copy_id),LIMIT_CHAL_SHOP.fbName))
			return
		end
		setConententPannelJosn(LayerScoreShopMall, "GameRankShopMall_1.json", widgetName)
	elseif noticeDetail.toward_id == 26 then		-- 竞技兑换
		if tonumber(LIMIT_CHAL_CONVERT.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_CHAL_CONVERT.copy_id) ~= "pass" then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_CHAL_CONVERT.copy_id),LIMIT_CHAL_CONVERT.fbName))
			return
		end
		setConententPannelJosn(LayerCommodityConvert, "CommodityConvert.json", widgetName)
	elseif noticeDetail.toward_id == 27 then		-- 主线副本
		setConententPannelJosn(LayerLevelSelcet,"CopyBackgournd_1.json","Panel_mission")
		LayerCopy.createCopyGroupByMode(1)
	elseif noticeDetail.toward_id == 28 then		-- 精英副本
		if tonumber(LIMIT_EQUIP_JYFB.copy_id) ~= 1 and  CopyDateCache.getCopyStatus(LIMIT_EQUIP_JYFB.copy_id) ~= "pass" then
			Toast.show(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_EQUIP_JYFB.copy_id),LIMIT_EQUIP_JYFB.fbName)) 
			return
		end
		setConententPannelJosn(LayerLevelSelcet,"CopyBackgournd_1.json","Panel_mission")
		LayerCopy.createCopyGroupByMode(2)
	elseif noticeDetail.toward_id == 29 then		-- 任务界面
		setConententPannelJosn(LayerTask, "TaskPanel.json",weightName)
	elseif noticeDetail.toward_id == 30 then		-- 召唤界面
		setConententPannelJosn(LayerRune,"Rune_1.json",weightName)
	elseif noticeDetail.toward_id == 31 then		-- 商城界面
		setConententPannelJosn(LayerShopMall,LayerShopMall.jsonFile, weightName)
	elseif noticeDetail.toward_id == 32 then		-- 社交界面
		setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json",weightName)
	elseif noticeDetail.toward_id == 33 then		-- 邀请码
		setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json",weightName)
		UIManager.push("UI_InviteCode")
	elseif noticeDetail.toward_id == 34 then		-- 友情奖励
		setConententPannelJosn(LayerFriendPoint, "FriendPoint.json", weightName)
	elseif noticeDetail.toward_id == 35 then		-- 月卡窗口
		MonthCardLogic.judgeEnterMonthCardUI()
	end
end
--文本模式 auto -> custom
local function LableAutoConverterCustom(label,textWidth)
    local AutoSize = label:getContentSize()
    print("AutoSize",AutoSize.width,AutoSize.height)
    local line = AutoSize.width / textWidth
    --取上限值 2.1 取 3.0
    line = math.ceil(line)
    print("line",line)
    label:ignoreContentAdaptWithSize(true)
    label:setTextAreaSize(CCSize(textWidth,line*AutoSize.height))
    label:setSize(CCSize(textWidth,line*AutoSize.height))
    
    local size = label:getContentSize()
    print("size",size.width,size.height)
end

--------------------------------------------------------------------------------------
-- 更新滚动层尺寸
LayerNoticeDetail.updateScrollViewSize = function(scroll) 
    local scrollSize = scroll:getSize()
	
    -- 遍历cell
    local sumheight = 0  --总高度
    local array = scroll:getChildren()
    for i=0,array:count()-1 do
        local node = array:objectAtIndex(i)
        tolua.cast(node,"UIWidget")
		local x = node:getPosition().x
		local y = node:getPosition().y
        sumheight = sumheight + node:getSize().height
    end
	
    if scrollSize.height < sumheight then
       scroll:setInnerContainerSize(CCSize(scrollSize.width,sumheight))
    end
    print("~~~~~~scroll",scrollSize.width,scrollSize.height,sumheight)
    
    -- 关联拖动条
    -- local Slider_110 = self:cast("Slider_110")
    -- CommonFunc_getSlider(Slider_110,scroll)
    
    -- if Slider_110:getPercent() >= 90 then
        -- scroll:jumpToBottom()
        -- Slider_110:setPercent(100)
    -- end
    
    scroll:doLayout()
end

-------------------------------------------------------------------------------------
-- 添加cell
LayerNoticeDetail.addScrollView = function(node)
    local scroll = tolua.cast(mRootView:getChildByName("ScrollView_list"),"UIScrollView")
    scroll:addChild(node)
    LayerNoticeDetail.updateScrollViewSize(scroll)
end

---------------------------------------------------------------------------------------------
-- 更新克隆的控件尺寸
LayerNoticeDetail.updatePanelCloneSize = function(widget, node)
	local width = chatTextWidth
	local height = widget:getContentSize().height
	totalHeight = totalHeight + height + chatIntervalHeight
	node:setSize(CCSize(width,totalHeight))
end

local function createContent()
	local labelContent = UILayoutHtml.create(noticeDetail.content, "fzzdh.TTF", 24, chatTextWidth, 2)
	return labelContent
end

-- 创建活动时间文本
local function createTimeLabel()
	if noticeDetail.start_time.year == 0 then
		return
	end
	-- local anchorPoint = ccp(0.0,0.5)
	local labelTime_1 = UILabel:create()
	labelTime_1:setAnchorPoint(ccp(0.0, 0.5))
	labelTime_1:setFontSize(24)
	labelTime_1:setFontName("fzzdh.TTF")
	labelTime_1:setPosition(ccp(0, totalHeight))
	labelTime_1:setColor(ccc3(253,255,255))
	labelTime_1:setText(GameString.get("NOTICE_ACTIVITY_TIME_1"))
	
	local timeStr = GameString.get("NOTICE_ACTIVITY_TIME_2", noticeDetail.start_time.month, noticeDetail.start_time.day, noticeDetail.start_time.hour, noticeDetail.start_time.minute,
									noticeDetail.end_time.month, noticeDetail.end_time.day, noticeDetail.end_time.hour, noticeDetail.end_time.minute)
	local labelTime_2 = UILabel:create()
	labelTime_2:setAnchorPoint(ccp(0.0, 0.5))
	labelTime_2:setFontSize(24)
	labelTime_2:setFontName("fzzdh.TTF")
	labelTime_2:setText(timeStr)
	labelTime_2:setPosition(ccp(120, 0))
	labelTime_2:setColor(ccc3(253,245,95))
	labelTime_1:addChild(labelTime_2)
	
	return labelTime_1
end

local function createSubTitleLabel()
	local labelSubTitle = UILabel:create()
	local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_list"), "UIScrollView")
	local width = scrollView:getInnerContainerSize().width
	-- labelSubTitle:setAnchorPoint(ccp(0.0, 0.5))
	labelSubTitle:setFontSize(24)
	labelSubTitle:setFontName("fzzdh.TTF")
	labelSubTitle:setPosition(ccp(width / 2, totalHeight))
	labelSubTitle:setColor(ccc3(0,255,0))
	labelSubTitle:setText(noticeDetail.sub_title)
	
	return labelSubTitle
end

-- 判断详情缓存是否存在id
LayerNoticeDetail.IsExistDetail = function(id)
	if #detailData == 0 then
		return false
	end
	for key, val in pairs(detailData) do
		if tonumber(id) == tonumber(val.id) then
			return key, val
		end
	end
	return false
end

--------------------------------------------------------------------------------------
-- 创建更新公告文本UI
LayerNoticeDetail.createNoticeDetail = function()
	local node = UILayout:create()
	if noticeDetail.form == true then
		local labelText = UILayoutHtml.create(noticeDetail.text, "fzzdh.TTF", 24, chatTextWidth, 2)
		labelText:setName("Label_text")
		node:addChild(labelText)
		LayerNoticeDetail.updatePanelCloneSize(labelText, node)
		labelText:setPosition(ccp(0, totalHeight))
	else
		local labelContent = createContent()
		labelContent:setName("Label_content")
		node:addChild(labelContent)
		LayerNoticeDetail.updatePanelCloneSize(labelContent, node)
		labelContent:setPosition(ccp(0, totalHeight))
	end
	LayerNoticeDetail.addScrollView(node)
	
	return node
end

-----------------------------------------初始化---------------------------
LayerNoticeDetail.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		return
	end
	-- 主标题
	local title = tolua.cast(mRootView:getChildByName("Label_title"), "UILabel")
	title:setText(noticeDetail.title)
	-- 返回
	local backBtn = tolua.cast(mRootView:getChildByName("Button_back"), "UIButton")
	backBtn:registerEventScript(onClickBack)
	-- 前往
	local towardBtn = tolua.cast(mRootView:getChildByName("Button_go"), "UIButton")
	if noticeDetail.toward_id ~= nil and noticeDetail.toward_id ~= 0 then
		towardBtn:registerEventScript(onClickToward)
	else
		towardBtn:setVisible(false)
		backBtn:setPosition(ccp(0, -281))
	end
	-- 滚动列表
	local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_list"), "UIScrollView")
	scrollView:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	scrollView:removeAllChildren()
	
	totalHeight = 0
	LayerNoticeDetail.createNoticeDetail()
end
-------------------------------------------销毁---------------------------
LayerNoticeDetail.destroy = function()
	mRootView = nil
end

-------------------------------------------销毁---------------------------
LayerNoticeDetail.setRootNil = function()
	mRootView = nil
end

---------------------------------------------------------------------------
local function handleNoticeItemDetail(param)
	-- quickSort(param, getMaxPriority)
	noticeDetail = param
	if param.form ~= true and LayerNoticeDetail.IsExistDetail(noticeDetail.id) == false then
		table.insert(detailData, noticeDetail)
	end
	LayerNotice.setDetailUI()
end
EventCenter_subscribe(EventDef["ED_NOTICE_ITEM_DETAIL"], handleNoticeItemDetail)		-- 获取公告详情

-- 删除活动公告
local function handleDelDetailItem(param)
	if LayerNoticeDetail.IsExistDetail(param.del_id) == false then
		return
	else
		local key = LayerNoticeDetail.IsExistDetail(param.del_id)
		table.remove(detailData, key)
	end
end
EventCenter_subscribe(EventDef["ED_DEL_NOTICE_ITEM"], handleDelDetailItem)		-- 删除公告