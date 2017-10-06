-------------------------------------
--作者：李慧琴
--说明：祝福界面
--时间：2014-5-22
-------------------------------------
LayerBless = {}
--local ACTIVITY_MONEY = 20		--激活每个祝福需要消耗的砖石
--local REFRESH_COIN = 2000		--刷新祝福需要消耗的金币
local mCurBenisonId = 0			--当前的祝福信息
local mLayerBlessRoot = nil		--当前界面的根节点
local mNameLabel = nil
local mTypeLabel = nil
local mLeftTimeLabel = nil		--当前祝福的剩余时间
local mIconImageView = nil

local function getBlessStr(id)
	if 1 == id then
		return GameString.get("PUBLIC_LIFE")
	elseif 2 == id then
		return GameString.get("PUBLIC_ATTACK")
	elseif 3 == id then
		return GameString.get("PUBLIC_SPEED")
	elseif 4 == id then
		return GameString.get("PUBLIC_HIT")
	elseif 5 == id then
		return GameString.get("PUBLIC_CRITICAL")
	elseif 6 == id then
		return GameString.get("PUBLIC_MISS")
	elseif 7 == id then
		return GameString.get("PUBLIC_TENACITY")
	end
end

local function onClick(typeName, weight)
	if "releaseUp" == typeName then
		TipModule.onClick(weight)
		local weightName = weight:getName()
		if "close_bless" == weightName then		-- 关闭按钮
			LayerMain.pullPannel(LayerBless)
		elseif "refresh" == weightName then		-- 刷新按钮
			if CommonFunc_payConsume(1, BLESS_REFRESH_COIN) then
				return
			end
			BlessLogic.requestRefreshBenisonList()
		end
	end
end

-- 点击激活按钮，触发的方法
local function activeClick(typeName,widget)
	if "releaseUp" == typeName then
		TipModule.onMessage("click_bless_icon", widget:getTag())
		local blessList = BlessLogic.getBlessList()
		local blessStatus = BlessLogic.getBlessStatus()
		for key, value in pairs(blessList) do
			if widget:getTag()/100 == key then
				local blessInfo = LogicTable.getBlessInfoById(value)
				if blessStatus[key] == 1 then     -- 1为未激活
					if CommonFunc_payConsume(2, blessInfo.need_emoney) then
						return
					end
					if 0 == mCurBenisonId then
						-- BlessLogic.requestBless(value)
						local structConfirm = {
							strText = GameString.get("BLESS_TIP_1",blessInfo.need_emoney),
							buttonCount = 2,
							buttonName = {GameString.get("sure"), GameString.get("cancle")},
							buttonEvent ={BlessLogic.requestBless, nil},
							buttonEvent_Param = {value, nil}
						}
						UIManager.push("UI_ComfirmDialog", structConfirm)
					else
						local structConfirm = {
							strText = GameString.get("BLESS_Cover",blessInfo.need_emoney),
							buttonCount = 2,
							buttonName = {GameString.get("sure"), GameString.get("cancle")},
							buttonEvent ={BlessLogic.requestBless, nil},
							buttonEvent_Param = {value, nil}
						}
						UIManager.push("UI_ComfirmDialog", structConfirm)    -- 处理删除好友结果	
					end
				else 							  -- 2为激活
					CommonFunc_CreateDialog(GameString.get("BLESS_Already_Active"))	
				end
			end	
		end
	end
end

-- 刷新祝福列表
local function updateBlessList()
	if nil == mLayerBlessRoot then
		return
	end
	local blessList = BlessLogic.getBlessList()
	local blessStatus = BlessLogic.getBlessStatus()
	for key, value in pairs(blessList) do
		local blessInfo = LogicTable.getBlessInfoById(value)
		local blessProInfo = LogicTable.getBlessProInfoById(blessInfo.status_ids)
		local attr = getBlessStr(blessProInfo.attr_type)
		local panel = mLayerBlessRoot:getChildByName(string.format("bless_%d", key))
		-- 设置图标
		local icon = panel:getChildByName(string.format("icon_%d", key))
		tolua.cast(icon, "UIImageView")
		icon:loadTexture(blessInfo.icon)
		-- 设置名字
		local name = panel:getChildByName(string.format("name_%d", key))
		tolua.cast(name, "UILabel")	
		name:setText(blessInfo.name)		
		-- 设置花费金币
		local money = panel:getChildByName(string.format("money_%d", key))
		tolua.cast(money, "UILabel")	
		money:setText(tostring(blessInfo.need_emoney))
		-- 设置祝福类型
		local blessType = panel:getChildByName(string.format("blessType_%d", key))
		tolua.cast(blessType, "UILabel")	
		if blessProInfo.value_type == 1 then
			blessType:setText(string.format("%s+%d%%", attr, blessProInfo.value))
		else
			blessType:setText(string.format("%s+%d", attr, blessProInfo.value))
		end
		-- 设置剩余时间
		local leftTime = panel:getChildByName(string.format("leftTime_%d", key))
		tolua.cast(leftTime,"UILabel")	
		leftTime:setText(GameString.get("BLESS_STR_01", blessInfo.duration/(60*60)))
		-- 设置激活按钮
		local active = panel:getChildByName(string.format("active_%d", key))
		active:setTag(key*100)
		tolua.cast(active, "UIButton")
		if blessStatus[key] == 2 then	-- 激活
			active:setTouchEnabled(false)
			active:setBright(false)
			--active:setTitleText(GameString.get("BLESS_No_Active"))
		else							-- 未激活
			active:setTouchEnabled(true)
			active:setBright(true)
			--active:setTitleText(GameString.get("BLESS_Active"))
			active:registerEventScript(activeClick)
		end				
	end
end

-- 加载空白的当前祝福信息
local function loadEmptyBless()
	if nil == mLayerBlessRoot then
		return
	end
	mNameLabel:setText("")
	mTypeLabel:setText("")
	mLeftTimeLabel:setText("")
	mIconImageView:loadTexture("touming.png")
end

-- 设置当前的祝福信息
local function setCurBuff(benisonId)
	if nil == mLayerBlessRoot then
		return
	end
	if 0 == benisonId then
		loadEmptyBless()
	else
		local blessInfo = LogicTable.getBlessInfoById(mCurBenisonId)
		local blessProInfo = LogicTable.getBlessProInfoById(blessInfo.status_ids)
		local attr = getBlessStr(blessProInfo.attr_type)
		-- 设置名字
		mNameLabel:setText(blessInfo.name)
		-- 设置属性
		if 1 == blessProInfo.value_type then
			mTypeLabel:setText(string.format("%s+%d%%", attr, blessProInfo.value))
		else
			mTypeLabel:setText(string.format("%s+%d", attr, blessProInfo.value))
		end
		--设置图片
		mIconImageView:loadTexture(blessInfo.icon)
		LayerMain.setMainBlessIcon(blessInfo.icon)
	end
end

-- 初始化
LayerBless.init = function(rootView)
    mLayerBlessRoot = rootView	
	local costCoinLabel = rootView:getChildByName("Label_63")
	tolua.cast(costCoinLabel, "UILabel")
	costCoinLabel:setText(tostring(BLESS_REFRESH_COIN))
	local closeBtn = rootView:getChildByName("close_bless")
	closeBtn:registerEventScript(onClick)
	local refreshBtn = rootView:getChildByName("refresh")
	refreshBtn:registerEventScript(onClick)
	local curPanel = rootView:getChildByName("Panel_curBle")
	mNameLabel = tolua.cast(curPanel:getChildByName("blessName"), "UILabel")
	mTypeLabel = tolua.cast(curPanel:getChildByName("blessType"), "UILabel")
	mLeftTimeLabel = tolua.cast(curPanel:getChildByName("leftTime"), "UILabel")
	mIconImageView = tolua.cast(curPanel:getChildByName("ImageView_27"), "UIImageView")
	if true == BlessLogic.isNewDay() then
		BlessLogic.requestBenisonList()
	else
		updateBlessList()
	end
	setCurBuff(mCurBenisonId)
	TipModule.onUI(rootView, "ui_bless")
end

-- 销毁
LayerBless.destroy = function()
	
	mLayerBlessRoot = nil
	mNameLabel = nil
	mTypeLabel = nil
	mLeftTimeLabel = nil
	mIconImageView = nil
end

LayerBless.purge = function()
	BlessLogic.setNewDay(true)
	mLayerBlessRoot = nil
	mNameLabel = nil
	mTypeLabel = nil
	mLeftTimeLabel = nil
	mIconImageView = nil
end
-- 定时器触发回调
local function timerRunCF(leftTime)
	if mLayerBlessRoot then
		mLeftTimeLabel:setText(GameString.get("BLESS_STR_02", CommonFunc_secToString(tonumber(leftTime))))
	end
end

-- 定时器结束回调
local function timerOverCF()
	mCurBenisonId = 0
	loadEmptyBless()
	LayerMain.setMainBlessIcon(nil)
end

--当前的祝福信息
local function handleBlessBuff()
	local blessBuff = BlessLogic.getBlessBuff()
	mCurBenisonId = blessBuff.benison_id
	print("***********handleBlessBuff*********",mCurBenisonId)
	if 0 ~= mCurBenisonId then
		local blessInfo = LogicTable.getBlessInfoById(mCurBenisonId)	
		LayerMain.setMainBlessIcon(blessInfo.icon)
	end
	setCurBuff(mCurBenisonId)
end

EventCenter_subscribe(EventDef["ED_BLESS_BUFF"], handleBlessBuff)
EventCenter_subscribe(EventDef["ED_BENISON_LIST"], updateBlessList)
EventCenter_subscribe(EventDef["ED_BLESS_TIMER_RUN"], timerRunCF)
EventCenter_subscribe(EventDef["ED_BLESS_TIMER_OVER"], timerOverCF)
