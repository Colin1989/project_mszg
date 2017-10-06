----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-06-17
-- Brief:	军衔界面
----------------------------------------------------------------------
local mMiltitaryRankDatas = nil
local mLayerMiltitaryRoot = nil
local mSelectDonorCell = nil		-- 选中的cell

local mScrollView = nil
local mMiltitaryCell = nil
local mGetRewardBtn = nil
local mCurMiltitary = nil
local mGetAwardType = 1

LayerMiltitary = {}
LayerAbstract:extend(LayerMiltitary)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", widget:getName())
	end
end
----------------------------------------------------------------------

-- 设置气泡感叹号
local function setTipIcon(str, value)
	local tipIcon = mLayerMiltitaryRoot:getChildByName("tip_icon_"..str)
	if nil == tipIcon then
		tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setName("tip_icon_"..str)
		local btn = mLayerMiltitaryRoot:getChildByName(str)
		btn:addChild(tipIcon)
	end
	
	if type(value) == "boolean" then
		tipIcon:setPosition(ccp(64, 25))
		tipIcon:setVisible(value)
	end
end

--设置当前军衔信息
local function setCurHonorInfo()
	-- 当前军衔称号
	local curName = tolua.cast(mLayerMiltitaryRoot:getChildByName("Label_name"), "UILabel")
	--当前军衔icon
	local iconImageView = tolua.cast(mLayerMiltitaryRoot:getChildByName("ImageView_icon"), "UIImageView")
	--当前荣誉值
	local curHonor = tolua.cast(mLayerMiltitaryRoot:getChildByName("Label_honor_cur"),"UILabel")
	curHonor:setText(tostring(ModelPlayer.getHonour()))
	if 0 == MiltitaryLogic.getMiltitaryLevel() then
		mCurMiltitary = {}
		curName:setText(GameString.get("PUBLIC_NONE"))
		iconImageView:loadTexture("touming.png")
		--curHonor:setText(0)
	else
		mCurMiltitary = LogicTable.getMiltitaryRankRow(MiltitaryLogic.getMiltitaryLevel())
		curName:setText(mCurMiltitary.name)
		iconImageView:loadTexture(mCurMiltitary.icon)
		--curHonor:setText(mCurMiltitary.need_honour)
	end
end
----------------------------------------------------------------------
--[[
--点击物品的方法
local function itemClik(types,widget)
	if types == "releaseUp" then
		CommonFunc_showInfo(0, widget:getTag(), 0, true)
	end
end
]]--
----------------------------------------------------------------------
--设置所选军衔的信息
local function setClickMilInfo(id)
	--下一级荣誉值
	local nextHonor = tolua.cast(mLayerMiltitaryRoot:getChildByName("Label_honor_next"), "UILabel")  
	--下一级荣誉排名
	local nextRank = tolua.cast(mLayerMiltitaryRoot:getChildByName("Label_rank_next"), "UILabel")
	--下一级Icon
	local nextIcon = tolua.cast(mLayerMiltitaryRoot:getChildByName("icon_next"), "UIImageView")
	--下一级名字
	local nextname= tolua.cast(mLayerMiltitaryRoot:getChildByName("Label_next_name"), "UILabel")
	nextMiltitary = LogicTable.getMiltitaryRankRow(id)
	nextIcon:loadTexture(nextMiltitary.icon)
	nextHonor:setText(nextMiltitary.need_honour)
	nextname:setText(nextMiltitary.name)
	local rankStr = nil
	local sRank, eRank = nextMiltitary.need_rank[1], nextMiltitary.need_rank[2]
	if "-1" == sRank then
		rankStr = GameString.get("PUBLIC_NONE")
	elseif sRank and eRank then
		if sRank == eRank then
			rankStr = sRank
		else
			rankStr = sRank.."-"..eRank
		end
	end
	nextRank:setText(rankStr)
end
----------------------------------------------------------------------

--设置军衔奖励列表
local function setMiltaryRewardListById(id)
	local itemScroll = tolua.cast(mLayerMiltitaryRoot:getChildByName("ScrollView_item"), "UIScrollView")
	local itemSlider = tolua.cast(mLayerMiltitaryRoot:getChildByName("Slider_item"), "UISlider")
	
	local militaryItem = LogicTable.getMiltitaryRankRow(id)
	if #militaryItem > 6 then
		itemSlider:setVisible(true)
	else
		itemSlider:setVisible(false)
	end
	local data = {}
	for key,value in pairs(militaryItem.reward_ids) do
		local ItemData = LogicTable.getRewardItemRow(value)
		ItemData.amount = militaryItem.reward_amounts[key]
		table.insert(data,ItemData)
	end
	
	local function createCell(ItemData)
		local widgetBack = FightOver_addQuaIconByRewardId(ItemData.id,nil,tonumber(ItemData.amount),itemClik)
		widgetBack:setTag(tonumber(ItemData.id))
		
		widgetBack:setTouchEnabled(true)
		local function clickSkillIcon(widgetBack)
			showLongInfoByRewardId(ItemData.id,widgetBack)
		end
		
		local function clickSkillIconEnd(widgetBack)
			longClickCallback_reward(ItemData.id,widgetBack)
		end
		UIManager.registerEvent(widgetBack, nil, clickSkillIcon, clickSkillIconEnd)
		
		return widgetBack
	end
	UIEasyScrollView:create(itemScroll,data,createCell,500, true,4,3,true,98)
	CommonFunc_setScrollPosition(itemScroll,itemSlider)
end
----------------------------------------------------------------------
--点击领取奖励按钮触发的函数
local function rewardClick(types,widget)
	if types == "releaseUp" then
		local miltitaryLevel = MiltitaryLogic.getMiltitaryLevel()
		id = widget:getTag()/10000
		if miltitaryLevel == id then	-- 军衔符合
			if true == MiltitaryLogic.existAward() then		-- 未领取
				MiltitaryLogic.requestMilitaryRankReward()
			else											-- 已领取
				Toast.Textstrokeshow(GameString.get("Public_Military_AlreadyGet"), ccc3(255,255,255), ccc3(0,0,0), 30)	
			end
		else										-- 军衔不符
			Toast.Textstrokeshow(GameString.get("Public_Military_NotFit"), ccc3(255,255,255), ccc3(0,0,0), 30)	
		end
	end
end
----------------------------------------------------------------------
--根据军衔，设置奖励可否领取
local function setRewardBtnByMilitary(id)
	local rewardBtn = tolua.cast(mLayerMiltitaryRoot:getChildByName("Button_getReward"), "UIImageView")
	rewardBtn:setTag(id*10000)
	rewardBtn:setTouchEnabled(true)
	rewardBtn:registerEventScript(rewardClick)
	
	local miltitaryLevel = MiltitaryLogic.getMiltitaryLevel()
	if miltitaryLevel == id and true == MiltitaryLogic.existAward() then		-- 未领取
		--rewardBtn:setTitleText(GameString.get("Public_Military_MayGet"))
		Lewis:spriteShaderEffect(rewardBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		setTipIcon("Button_getReward", true)
	elseif miltitaryLevel == id and false == MiltitaryLogic.existAward() then									-- 已领取
		--rewardBtn:setTitleText(GameString.get("Public_Military_AlreadyGet"))
		Lewis:spriteShaderEffect(rewardBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		setTipIcon("Button_getReward", false)
	else
		--rewardBtn:setTitleText(GameString.get("Public_Military_NotFit"))
		Lewis:spriteShaderEffect(rewardBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		setTipIcon("Button_getReward", false)
	end
end
----------------------------------------------------------------------
--点击军衔名字事件
local function OnItemNameClick(typeName,widget)
	if typeName == "releaseUp" then
		if mSelectDonorCell == widget then
			return
		end
		TipModule.onClick(widget)
		tolua.cast(widget, "UIImageView")
		local curLevel = MiltitaryLogic.getMiltitaryLevel()
		
		local curTag = mSelectDonorCell:getTag()/100
		if mSelectDonorCell and mGetAwardType and mGetAwardType <= curLevel then
			mSelectDonorCell:loadTexture("rank_flag_1.png")
		elseif mSelectDonorCell and mGetAwardType and mGetAwardType > curLevel then
			mSelectDonorCell:loadTexture("rank_flag_3.png")
		end
		
		mGetAwardType = widget:getTag()/100
		
		if curLevel >= mGetAwardType then
			widget:loadTexture("rank_flag_2.png")
		else
			widget:loadTexture("rank_flag_4.png")
		end
		
		mSelectDonorCell = widget
		
		setMiltaryRewardListById(widget:getTag()/100)	--设置军衔奖励列表
		setClickMilInfo(widget:getTag()/100)			--设置军衔信息
		setRewardBtnByMilitary(widget:getTag()/100)		--设置奖励可否领取
	end
end 
----------------------------------------------------------------------
--设置军衔名字列表
local function setMilitaryNameList()
	mScrollView = tolua.cast(mLayerMiltitaryRoot:getChildByName("scroll_list_name"), "UIScrollView")
	if nil == mMiltitaryRankDatas then
		mMiltitaryRankDatas = LogicTable.getMiltitaryRankTable()
	end
	
	local function createCell(ItemData)
		local nameView = UIImageView:create()
		if  ItemData.id <= MiltitaryLogic.getMiltitaryLevel() then
			if ItemData.id == MiltitaryLogic.getMiltitaryLevel() then
				nameView:loadTexture("rank_flag_2.png")
			else
				nameView:loadTexture("rank_flag_1.png")
			end
			
			mSelectDonorCell = nameView		--默认选中第一个或者当前军衔
			setMiltaryRewardListById(MiltitaryLogic.getMiltitaryLevel()) 	-- 设置初始奖励信息
			setRewardBtnByMilitary(MiltitaryLogic.getMiltitaryLevel())
			setClickMilInfo(MiltitaryLogic.getMiltitaryLevel())
			mGetAwardType = MiltitaryLogic.getMiltitaryLevel()
		else
			nameView:loadTexture("rank_flag_3.png")
		end
		nameView:registerEventScript(OnItemNameClick)
		nameView:setTouchEnabled(true)
		nameView:setTag(ItemData.id*100)
		nameView:setName(ItemData.id.."")
		
		local nameLbl =  UILabel:create()
		nameLbl:setPosition(ccp(0,0))
		nameLbl:setFontSize(20)
		nameLbl:setAnchorPoint(ccp(0.5,0.5))
		nameLbl:setText(ItemData.name)
		nameView:addChild(nameLbl)	
		nameView:setSize(CCSizeMake(400,50))
		return nameView
	end
	UIEasyScrollView:create(mScrollView,mMiltitaryRankDatas,createCell,100, true,5,1,true)
	
	--默认选中第一个或者当前军衔
	if MiltitaryLogic.getMiltitaryLevel() == 0  then
		local nameView = tolua.cast(mLayerMiltitaryRoot:getChildByName("1"), "UIImageView")
		nameView:loadTexture("rank_flag_4.png")
		mSelectDonorCell = nameView
		setMiltaryRewardListById(1) 	-- 设置初始奖励信息
		setRewardBtnByMilitary(1)
		setClickMilInfo(1)
		mGetAwardType = 1
	end
end
----------------------------------------------------------------------
-- 领取军衔排行奖励
local function getMiltitaryRankReward(success)
	if nil == mLayerMiltitaryRoot then
		return
	end
	if true == success then
		local miltitaryRankRow = LogicTable.getMiltitaryRankRow(mGetAwardType)
		CommonFunc_showItemGetInfo(miltitaryRankRow.reward_ids, miltitaryRankRow.reward_amounts)
		setRewardBtnByMilitary(mGetAwardType)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerMiltitary.init = function(rootView)
	
	mLayerMiltitaryRoot = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(mLayerMiltitaryRoot:getChildByName("close_btn"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	setMilitaryNameList()		--设置军衔名字列表
	setCurHonorInfo()			--设置当前军衔信息
	TipModule.onUI(rootView, "ui_miltitary")
end
----------------------------------------------------------------------
-- 销毁
LayerMiltitary.destroy = function()
	mLayerMiltitaryRoot = nil
	mScrollView = nil
	mGetRewardBtn = nil
	mSelectDonorCell = nil
	mGetAwardType = 1
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_MILTITARY_RANK_GET_REWARD"], getMiltitaryRankReward)



