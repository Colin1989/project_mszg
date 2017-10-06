----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-07
-- Brief:	炼金术界面
----------------------------------------------------------------------

local mLayerGetCoinRoot = nil
local mCoolTimer =nil			    --炼金冷却定时器
local mCurItemInfo = {}				--保存获取到的炼金的信息
local mAlchemyInfo = {}				--保存通过等级得到的信息
local mIndex = 1					--表示点击的炼金的位置
local mPubLeftTimes = 0				--普通炼金剩余次数
local mSpeLeftTimes = 0				--魔石炼金剩余次数
local mClickType = 1				--判断点击的是普通还是魔石炼金（1是普通，2 是魔石）
local mSpeCostEmony = 0			--魔石炼金所需金额

LayerGetCoin = {}
LayerAbstract:extend(mLayerGetCoinRoot)
----------------------------------------------------------------------
local function handleClearData()
	mCoolTimer = nil
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
	end
end
----------------------------------------------------------------------
-- 获得点击的炼金类型
LayerGetCoin.getAlchemyType = function()
	return mClickType
end
----------------------------------------------------------------------
-- 点击普通炼金按钮
local function clickPubAlchemyBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		if Alchemy_CoolTime > 0 then 		
			--Toast.Textstrokeshow(GameString.get("GameRank_MSG_DATE"),ccc3(255,255,255),ccc3(0,0,0),30)
			return
		elseif mPubLeftTimes > 0 and Alchemy_CoolTime <= 0 then
			GetCoinLogic.requestAlchemy(1)
			mClickType = 1
			Lewis:spriteShaderEffect(widget:getVirtualRenderer(),"buff_gray.fsh",true)
		end	
	end
end
----------------------------------------------------------------------
-- 点击高级炼金按钮
local function clickSpeAlchemyBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		if CommonFunc_payConsume(2, mSpeCostEmony) then
			return
		end
		
		local structConfirm =
		{
			strText = GameString.get("Public_buy_getSpeCoin", mSpeCostEmony),
			buttonCount = 2,
			buttonName = {GameString.get("sure"),GameString.get("cancle")},
			buttonEvent = {GetCoinLogic.requestAlchemy,nil}, --回调函数
			buttonEvent_Param = {2,nil} --函数参数
		}
		UIManager.push("UI_ComfirmDialog",structConfirm)
		
		mClickType = 2
	end
end
----------------------------------------------------------------------
-- 获取高级炼金所需金额
local function getAdvancePrice(Times)
	local ReCoverExpres = LogicTable.getExpressionRow(31)	--购买计算公式
	local valueTable = {
		{name = "Times", value = Times}
	}
	local price = ExpressionParse.compute(ReCoverExpres.expression,valueTable)
	return tonumber(price)
end 

----------------------------------------------------------------------
--判断该奖励是否已经领取过了，根据奖励位置
local function judgeReceivedYONByIndex(index)
	for key,value in pairs(mCurItemInfo.rewarded_list) do
		if value == index then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 点击奖励物品触发的函数
local function iconClickAction(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		for key,value in pairs(mAlchemyInfo.reward_ids) do
			if widget:getTag()%100000 == key then
				mIndex = key
				if ModelPlayer.getAlchemy() < Alchemy_ExpQua[key] then
					Toast.Textstrokeshow(GameString.get("Public_Alchemoy_Exp_Not_Enough"),ccc3(255,255,255),ccc3(0,0,0),30)
				elseif judgeReceivedYONByIndex(key) == true then
					Toast.Textstrokeshow(GameString.get("Public_Alchemoy_Received"),ccc3(255,255,255),ccc3(0,0,0),30)
				else
					GetCoinLogic.requestAlchemyReward(key)	
				end	
			end	
		end
	end
end
----------------------------------------------------------------------
--根据经验，设置经验进度条
local function setBarExpByExp(expr)
	local bar_exp =  tolua.cast(mLayerGetCoinRoot:getChildByName("LoadingBar_exp"), "UILoadingBar")
	if 100*expr/1000 >= 100 then
		bar_exp:setPercent(100)
	else
		bar_exp:setPercent(100*expr/1000)
	end
end
----------------------------------------------------------------------
--保存请求的领取奖励id与数量
LayerGetCoin.getIdAmount = function()
	local id = {mAlchemyInfo.reward_ids[mIndex]}
	local amount = {mAlchemyInfo.reward_amounts[mIndex]}
	return id,amount
end
----------------------------------------------------------------------
--可领取动画
local function  loadMayLingAnima(key)
	local _,lingTb = GetCoinLogic.existAward()
	if  #lingTb ~= 0  then
		--for key,value in pairs(lingTb) do
			local panel = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("Panel_%d",key)), "UILayout") 
			local sanImg = CommonFunc_getImgView("firpiont_bg2_hover.png", false)
			sanImg:setPosition(ccp(58,78))
			panel:addChild(sanImg)
			sanImg:setName(string.format("sanImg_%d",key))
			panel:setZOrder(0)
			sanImg:setZOrder(0)
			local arr = CCArray:create()
			--缩小
			local action1 = CCScaleTo:create(0.3,0.5)
			arr:addObject(action1)
			--放大
			local action2 = CCScaleTo:create(0.3,1.0)
			arr:addObject(action2)
			--重复
			local action3 = CCRepeatForever:create(CCSequence:create(arr))
			sanImg:runAction(action3)
		--end			
	end
end
----------------------------------------------------------------------

--加载不可领取的灰色遮罩
local function loadNoMayLingPanel(key)
	local panel = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("Panel_%d",key)), "UILayout") 
	local kuang = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("ImageView_%d",813 + key)), "UIImageView") 
	local layout = UILayout:create()
	layout:setName(string.format("Gray_%d", key))
	layout:setZOrder(2)
	layout:setBackGroundImage("icon_mask.png")
	layout:setSize(CCSizeMake(106,106))
	layout:setPosition(ccp(-53,-53))
	kuang:addChild(layout)	
end

----------------------------------------------------------------------
--加载已领取过的图片
local function loadHasGet(key)
	local flagTag = 1000		--是否被领取过的标志
	local icon = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("item_%d",key)), "UIImageView")
	--加载对应的是否领过的图标
	if judgeReceivedYONByIndex(key) == true then
		local imgFlag = icon:getChildByTag(flagTag)
		if imgFlag == nil then
			local imgFlag = CommonFunc_getImgView("uiiteminfo_yilingqu.png")
			imgFlag:setPosition(ccp(0, 0))
			imgFlag:setTag(flagTag)
			icon:addChild(imgFlag)
		end
	else
		local imgFlag = icon:getChildByTag(flagTag)
		if imgFlag ~= nil then
			icon:removeChild(imgFlag)
		end	
	end		
end
----------------------------------------------------------------------------------------------------------------------
--加载可领取的动画和灰色遮罩
local function loadMayLingAnimaAndGrayKuang()

	--把领取过的或不可领取的发光图片删掉
		for i= 1,5 do
			local panel = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("Panel_%d",i)), "UILayout") 
			local kuang = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("ImageView_%d",813 + i)), "UIImageView") 
			local icon = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("item_%d",i)), "UIImageView")
			kuang:setZOrder(2)
			icon:setColor(ccc3(255, 255, 255))
			
			local light =  tolua.cast(panel:getChildByName(string.format("sanImg_%d",i)), "UIImageView") 
			if light ~= nil then
				light:stopAllActions()
				light:removeFromParent()
			end
			
			local gray =  tolua.cast(panel:getChildByName(string.format("Gray_%d",i)), "UIImageView") 
			if gray ~= nil then
				gray:removeFromParent()
			end
		end
		
		local _,lingTb = GetCoinLogic.existAward()
		
		--判断是不是不可领取--false是不用加灰色，true是需要加灰色
		local function judgeNoGet(index)
			if #lingTb ~= 0 then
				--判断是不是可领取的
				for key,value in pairs(lingTb) do
					if value == index then
						return false
					end
				end
			end
			if judgeReceivedYONByIndex(index) == true then    --已经领过的情况
				return false
			end
			return true
		end
		
		for i =1,5 do 	
			local icon = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("item_%d",i)), "UIImageView")
			local color = icon:getColor()
			--cclog("=================== i: "..i.." == color("..color.r..", "..color.g..", "..color.b..")")
			if judgeNoGet(i) == true then
				loadNoMayLingPanel(i)
			elseif judgeNoGet(i) == false then
				icon:setColor(ccc3(255, 255, 255))
				if judgeReceivedYONByIndex(i) == true then    --已经领过的情况
					loadHasGet(i)
				else   --加载可领取的发光动画（没有领过的情况）	
					loadMayLingAnima(i)
				end	
			end
		end
		
end

-----------------------------------------------------------------------------------------------------------
--加载对应的获得的物品
local function setGetItemByExp()
	
	for key,value in pairs(mAlchemyInfo.reward_ids) do
		local lbl =  tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("num_%d",key)), "UILabel")
		lbl:setText("*"..mAlchemyInfo.reward_amounts[key])
		lbl:setZOrder(1)
		
		local iconInfo = LogicTable.getRewardItemRow(value)
		local icon = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("item_%d",key)), "UIImageView")
		icon:loadTexture(iconInfo.icon)	
		icon:setColor(ccc3(255, 255, 255))
		icon:setTag(100000 + key)
		icon:setZOrder(1)
		icon:setEnabled(true)
		icon:setTouchEnabled(true)
		icon:registerEventScript(iconClickAction)
		
		local expLbl = tolua.cast(mLayerGetCoinRoot:getChildByName(string.format("Label_%d",776+key)), "UILabel")
		expLbl:setText(GameString.get("Public_Alchemoy_Need_Exp",Alchemy_ExpQua[key]))
	end
	
	loadMayLingAnimaAndGrayKuang()
					
end
----------------------------------------------------------------------
--显示高级炼金，消耗的魔石，获得的金币和经验
local function setSpeGetCoinPanelInfo()	
	local speCost =  tolua.cast(mLayerGetCoinRoot:getChildByName("spe_cost"), "UILabel")
	speCost:setText(mSpeCostEmony)
	local getCoinLbl =  tolua.cast(mLayerGetCoinRoot:getChildByName("spe_get"), "UILabel")
	getCoinLbl:setText(mAlchemyInfo.advanced_reward_gold)
	local getExpLbl =  tolua.cast(mLayerGetCoinRoot:getChildByName("spe_exp"), "UILabel")
	getExpLbl:setText(Alchemy_Spe_Get_Exp)
	--剩余次数
	-- local timesLeft =  tolua.cast(mLayerGetCoinRoot:getChildByName("spe_times"), "UILabel")
	-- mSpeLeftTimes = Alchemy_Spe_Times + getVipAddValueById(7) - mCurItemInfo.advanced_count
	-- timesLeft:setText(mSpeLeftTimes)
end
----------------------------------------------------------------------
LayerGetCoin.setPubTime = function()	
	-- 定时器触发回调
	local function timerRunCF(tm)		
		if Alchemy_CoolTime > 0 then
			Alchemy_CoolTime = Alchemy_CoolTime - 1
			mCurItemInfo.remain_normal_second = Alchemy_CoolTime
		end
		
		if mLayerGetCoinRoot == nil then
			return
		end
		local coolTimeLbl =  tolua.cast(mLayerGetCoinRoot:getChildByName("coolTime"), "UILabel")	
		local pubBtn = tolua.cast(mLayerGetCoinRoot:getChildByName("Button_pub_get"), "UIButton")
		if Alchemy_CoolTime <= 0 then
			coolTimeLbl:setText(GameString.get("PUBLIC_NONE"))
			pubBtn:setTouchEnabled(true)
			pubBtn:registerEventScript(clickPubAlchemyBtn)
			Lewis:spriteShaderEffect(pubBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		else
			pubBtn:setTouchEnabled(false)
			coolTimeLbl:setText(CommonFunc_secToString(Alchemy_CoolTime))
			Lewis:spriteShaderEffect(pubBtn:getVirtualRenderer(),"buff_gray.fsh",true)
			
		end	
	end
	-- 定时器结束回调
	local function timerOverCF(tm)
		mCoolTimer = nil
		TipFunction.setFuncAttr("func_get_coin", "waiting", false)
	end
	if nil == mCoolTimer then	
		mCoolTimer = CreateTimer(1, Alchemy_CoolTime, timerRunCF, timerOverCF)
		mCoolTimer.start()
		TipFunction.setFuncAttr("func_get_coin", "waiting", true)
	end
end
----------------------------------------------------------------------
--显示普通炼金，获得的冷却时间、金币、经验和剩余次数
local function setPubGetCoinPanelInfo()	
	local getCoinLbl =  tolua.cast(mLayerGetCoinRoot:getChildByName("pub_get"), "UILabel")
	getCoinLbl:setText(mAlchemyInfo.normal_reward_gold)
	local getExpLbl =  tolua.cast(mLayerGetCoinRoot:getChildByName("pub_exp"), "UILabel")
	getExpLbl:setText(Alchemy_Pub_Get_Exp)
	--剩余次数
	-- local timesLeft =  tolua.cast(mLayerGetCoinRoot:getChildByName("pub_leftTimes"), "UILabel")
	-- mPubLeftTimes = Alchemy_Pub_Times + getVipAddValueById(6) - mCurItemInfo.nomrmal_count
	mPubLeftTimes = Alchemy_Pub_Times - mCurItemInfo.nomrmal_count
	-- Log(mPubLeftTimes)
	-- timesLeft:setText(mPubLeftTimes)
	
	Alchemy_CoolTime = mCurItemInfo.remain_normal_second
	local coolTimeLbl =  tolua.cast(mLayerGetCoinRoot:getChildByName("coolTime"), "UILabel")
	if mCurItemInfo.remain_normal_second == 0 then
		coolTimeLbl:setText(GameString.get("PUBLIC_NONE"))
	else
		coolTimeLbl:setText(CommonFunc_secToString(mCurItemInfo.remain_normal_second))	
		LayerGetCoin.setPubTime()
	end	
end
----------------------------------------------------------------------
--设置普通炼金按钮
local function setPubGetCoinButton()	
	--普通炼金按钮
	local pubBtn = tolua.cast(mLayerGetCoinRoot:getChildByName("Button_pub_get"), "UIButton")
	if mPubLeftTimes <= 0 then
		pubBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(pubBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	else
		if Alchemy_CoolTime > 0 then
			Lewis:spriteShaderEffect(pubBtn:getVirtualRenderer(),"buff_gray.fsh",true)
			pubBtn:setTouchEnabled(false)
		else
			pubBtn:setTouchEnabled(true)
			Lewis:spriteShaderEffect(pubBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		end
		pubBtn:registerEventScript(clickPubAlchemyBtn)
	end
	
	--高级炼金按钮
	local speBtn = tolua.cast(mLayerGetCoinRoot:getChildByName("Button_spe_get"), "UIButton")
	-- if mSpeLeftTimes <= 0 then
		-- speBtn:setTouchEnabled(false)
		-- Lewis:spriteShaderEffect(speBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	-- else
		speBtn:setTouchEnabled(true)
		Lewis:spriteShaderEffect(speBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		speBtn:registerEventScript(clickSpeAlchemyBtn)
	-- end	
end
----------------------------------------------------------------------
--初始化整个UI界面
local function initUI()
	if mLayerGetCoinRoot == nil then
		return
	end
	
	mCurItemInfo = GetCoinLogic.getAlchemyInfo()
	mAlchemyInfo = LogicTable.getCoinInfoById(mCurItemInfo.level)
	
	mSpeCostEmony = getAdvancePrice(mCurItemInfo.advanced_count + 1)
	
	setGetItemByExp()
	setPubGetCoinPanelInfo()
	setSpeGetCoinPanelInfo()
	setPubGetCoinButton()
	setBarExpByExp(ModelPlayer.getAlchemy())			
end
----------------------------------------------------------------------
-- 初始化
LayerGetCoin.init = function(rootView)
	
	mLayerGetCoinRoot = rootView
	
	--关闭按钮
	local closeBtn = tolua.cast(mLayerGetCoinRoot:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	
	initUI()
	-- 游戏事件注册-- 炼金信息获得
	EventCenter_subscribe(EventDef["ED_ALCHEMY_GET"],initUI) 	
	TipModule.onUI(rootView, "ui_getcoin")
end
----------------------------------------------------------------------
-- 销毁
LayerGetCoin.destroy = function()	
	mLayerGetCoinRoot = nil
	mClickType = 1
	mSpeCostEmony = 0
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)
