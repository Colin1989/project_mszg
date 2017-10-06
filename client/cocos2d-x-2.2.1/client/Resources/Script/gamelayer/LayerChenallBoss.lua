--region LayerChenallBoss.lua
--Author : shenl
--Date   : 2014/8/5


LayerChenallBoss = {}

LayerChenallBoss.josnFile = "ChallengeBoss_1.json" 
LayerChenallBoss.RootView = nil
local CopyIconPath = "copyicon/"

local getInLoad = nil

local function getbuyStonePrice(Times)
	local ReCoverExpres = LogicTable.getExpressionRow(15)	--召唤石计算公式
	local valueTable = {
		{name = "Times", value = Times}
	}
	local price = ExpressionParse.compute(ReCoverExpres.expression,valueTable)
	return tonumber(price)
end 

-- 设置进来的路径
LayerChenallBoss.setInLoad = function(name)
	getInLoad = name
end

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		if getInLoad == nil then		-- 默认从活动界面进
			TipModule.onClick(widget)
			--setConententPannelJosn(LayerActivity, "Activity.json", "Activity.json")
            setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
		elseif getInLoad == "main" then
			TipModule.onClick(widget)
			LayerMain.pullPannel()
		end
	end
end

-- 锁住事件
local function onItemLocked(type,widget)
	if type == "releaseUp" then
		TipModule.onClick(widget)
		Toast.show(GameString.get("COPY_LOCK")..widget:getTag())
	end
end


--副本点击事件
local function onItemClick_copy(type,widget)
	if type =="releaseUp" then
		TipModule.onClick(widget)
		m_iOnClickCopy = widget:getTag()
		UIManager.push("UI_CopyTips",widget:getTag())
	end
end


 --创建文本文字
local function createCopyText(text,pos,size)
	local label =UILabel:create()      --往里面添加好友说的话，   
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPosition(pos)
	label:setFontSize(size)
	label:setText(text)
	label:setFontName("fzzdh.TTF")
	label:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	
	return label
end

--createBossFB  
local function ceateFbBoosIcon(copyInfo)

	local statue,isPlayOpenDoor = CopyDateCache.getCopyStatus(copyInfo.id)
	--copyRoot
	local copyView = UIImageView:create()
	copyView:loadTexture(CopyIconPath.."fuben_boss_bg.png")
	
	ResourceManger.LoadSinglePicture("bosssmallicon")

	--copy_icon
	local smallicon = UIImageView:create()
	smallicon:loadTexture(copyInfo.small_icon,UI_TEX_TYPE_PLIST) --read xml
	smallicon:setPosition(ccp(0,15))
	copyView:addChild(smallicon)
	

	--copyStarFrame
	local copyBg = UIImageView:create()
	copyBg:loadTexture(CopyIconPath.."fuben_bossframe.png")
	copyView:addChild(copyBg)
	
	--star 
	local starNumber = CopyDateCache.getScoreById(copyInfo.id)	
	local function createStar(pos)
		local star = UIImageView:create()
		star:loadTexture(CopyIconPath.."copy_star.png")
		star:setPosition(pos)
		copyView:addChild(star)
	end
	
	--消耗体力展示
    --[[
	local label_needpp = createCopyText(copyInfo.name,ccp(0,-73),23)
	label_needpp:setText(string.format("消耗体力：%s",copyInfo.need_power))
	label_needpp:setColor(ccc3(219,238,5))
	copyView:addChild(label_needpp)

	label_needpp:setText(string.format("需要召唤石：%s",copyInfo.need_stone))
    ]]--

    local label_copyName = createCopyText(copyInfo.name,ccp(5,-54),20)
	copyView:addChild(label_copyName)
	 


	if statue == "lock" then 
		copyView:registerEventScript(onItemLocked)
		copyView:loadTexture(CopyIconPath.."fuben_bossframe_lock.png")
        copyBg:setVisible(false)
		smallicon:setVisible(false)
	else
	    if starNumber == 1 then
		   createStar(ccp(-62+4,75))
	    elseif starNumber == 2 then
		   createStar(ccp(-62+4,75))
		   createStar(ccp(2,76))
	    elseif starNumber == 3 then
		   createStar(ccp(-62+4,75))
		   createStar(ccp(2,75))
		   createStar(ccp(62,75))
	    end	

        local AngleIcon = UIImageView:create()
        AngleIcon:setPosition(ccp(-98,45))
        if statue == "pass" then 
            AngleIcon:loadTexture("fuben_yitongguan.png")
        elseif statue == "doing" then  
            AngleIcon:loadTexture("fuben_tiaozhanzhong.png")
        end 
        copyView:addChild(AngleIcon)

		local pRet,lvLimitNum = CopyDateCache.isLvLimit(copyInfo.id)
		if pRet	== true then 
			smallicon:setColor(ccc3(128,128,128))
			smallicon:setOpacity(128)
					
			local lvLimit =  createCopyText("需要"..lvLimitNum.."级开启",ccp(0,0),32)
			copyView:addChild(lvLimit)
		else
			copyView:registerEventScript(onItemClick_copy)
		end
	end
	
	
	copyView:setTouchEnabled(true)

    copyView:setTag(tonumber(copyInfo.id))
	copyView:setName("copy_btn_"..copyInfo.key)

	return copyView
end


local function setContentPannel(isAnimation)
    local a,b,BossTb =  CopyDateCache.getCurGroupLength(nil)

    local ScrollItemDate = {}

	for key,value in pairs(BossTb) do
		local copy = LogicTable.getCopyById(value)
        copy.key = key
	    table.insert(ScrollItemDate, copy)
    end

    local cboss_sroview = LayerChenallBoss.RootView:getChildByName("cboss_sroview")
	tolua.cast(cboss_sroview,"UIScrollView")

    UIEasyScrollView:create(cboss_sroview,ScrollItemDate,ceateFbBoosIcon,8, true,5,2,isAnimation)	   
end 




local mIs_award = nil --今日是否领取过召唤石
local mhas_buy_times = nil --今日购买召唤石的次数
local mNewDay = true				-- 新的一天
local mDailyTimerFlag = false

--view
local mBtnBossgetSTone = nil -- 领取石头按钮
local mShowMyStone = nil --我的剩余石头

----------------------------------------------------------------------
-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	mIs_award = 0
	mhas_buy_times = 0
	
	EventCenter_post(EventDef["ED_SUMMON_STONE"])
end

local function initBuyBossStone(tb)
	mIs_award = tb.is_award			--0:没领过 1：领过了
	mhas_buy_times = tb.has_buy_times
	
	mNewDay = false
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
	end
	
	EventCenter_post(EventDef["ED_SUMMON_STONE"])
end 


-- 领取召唤石
local function Handle_req_getStone(tb)
	if tb.result == 1 then 
		Toast.Textstrokeshow(GameString.get("getBossStone",EVERY_GET_BOSSSTONE+getVipAddValueById(1)),ccc3(255,255,255),ccc3(0,0,0),24)
		Lewis:spriteShaderEffect(mBtnBossgetSTone:getVirtualRenderer(),"buff_gray.fsh",true)
		mBtnBossgetSTone:unregisterEventScript()
	end
	--服务端会先推改变的逻辑
	mIs_award = 1 --标记为领取过

    -- getVipAddValueById(1)
	mShowMyStone:setText("*"..ModelPlayer.getSummonStone() ) 
	TipModule.onUI(LayerChenallBoss.RootView, "ui_chenallboss")
end 


local function Handle_req_buyStone(tb)

	if tb.result == 1 then
		mShowMyStone:setText("*"..ModelPlayer.getSummonStone())
		mhas_buy_times	= mhas_buy_times + 1
		Toast.show(GameString.get("Public_Boss_Buy"))	
	end
	
end


local function HandleStone(type,widget)
	if type =="releaseUp" then
		TipModule.onClick(widget)
		local name =widget:getName()  --判断是点击了那个按钮
		if name == "buy_stone" then 	--买石头
			--print("HandleStone***************",LIMIT_Buy_summon_stone - mhas_buy_times,LIMIT_Buy_summon_stone,mhas_buy_times,getbuyStonePrice(0))
			if mhas_buy_times >= LIMIT_Buy_summon_stone then
				Toast.Textstrokeshow(GameString.get("Public_BuyTimes_Not_Enough"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
			
			local structConfirm = {
				strText = GameString.get("BuyBossStone",LIMIT_Buy_summon_stone - mhas_buy_times,getbuyStonePrice(0)),
				buttonCount = 2,
				isPop = false,
				buttonName = {GameString.get("sure"),GameString.get("cancle")},
				buttonEvent = {function()
					--魔石不足
					if CommonFunc_payConsume(2, getbuyStonePrice(0)) then
						return
					end
					if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
						UIManager.pop(UIManager.getTopLayerName())
					end
					local tb = req_buy_summon_stone()
					NetHelper.sendAndWait(tb, NetMsgType["msg_notify_buy_summon_stone"])
				end,nil}, --回调函数
				buttonEvent_Param = {nil,nil} --函数参数
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)	
		elseif name == "get_stone" then --领取石头
			local tb = req_daily_summon_stone()
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_daily_summon_stone"])
		end
	end
end

local function setBottomPanenl()
	if LayerChenallBoss.RootView == nil then
		return
	end
	--mGetBossStonePannel = mContentPannel:getChildByName("ImageView_64")
	--mCurBossStonePannel = mContentPannel:getChildByName("ImageView_69")
	
	mBtnBossgetSTone = LayerChenallBoss.RootView:getChildByName("get_stone")
	
	if mIs_award == 1 then --领取召唤石
		Lewis:spriteShaderEffect(mBtnBossgetSTone:getVirtualRenderer(),"buff_gray.fsh",true)
	else 
		mBtnBossgetSTone:registerEventScript(HandleStone)
	end 
	
	local mBtnBossbuyStone = LayerChenallBoss.RootView:getChildByName("buy_stone")
	mBtnBossbuyStone:registerEventScript(HandleStone)
	
	--我剩余的石头
	mShowMyStone = LayerChenallBoss.RootView:getChildByName("left_stone") 
	tolua.cast(mShowMyStone, "UILabel")
	mShowMyStone:setText("*"..ModelPlayer.getSummonStone()) 
	--每日可以领取的石头
	mShowGetStone = LayerChenallBoss.RootView:getChildByName("everydays_getstone") 
	tolua.cast(mShowGetStone, "UILabel")
	mShowGetStone:setText("*"..(EVERY_GET_BOSSSTONE+getVipAddValueById(1))) 

end 

LayerChenallBoss.refresh = function()
    setContentPannel(false) 
end

LayerChenallBoss.existAward = function()
    local Ret = false 

    if (mIs_award == 0 or ModelPlayer.getSummonStone() > 0) and  tonumber(LIMIT_ENTER_BOSS.copy_id) ~= 1 and
		CopyDateCache.getCopyStatus(LIMIT_ENTER_BOSS.copy_id) == "pass"  then 
        Ret = true
    end 
	
    return Ret
end

LayerChenallBoss.refreshLeftStone = function()
    if mShowMyStone ~= nil then 
        mShowMyStone:setText("*"..ModelPlayer.getSummonStone()) 
    end 
end


LayerChenallBoss.init = function(rootView)
    LayerChenallBoss.RootView = rootView
    setContentPannel(true)
    setBottomPanenl()

    local cancle_cboss =  LayerChenallBoss.RootView:getChildByName("cancle_cboss") 
    cancle_cboss:registerEventScript(clickCloseBtn)
	TipModule.onUI(rootView, "ui_chenallboss")
end 


LayerChenallBoss.destroy = function()
    LayerChenallBoss.RootView = nil 
    mShowMyStone = nil

    mBtnBossgetSTone = nil -- 领取石头按钮
    mShowMyStone = nil --我的剩余石头
	
	getInLoad = nil		-- 清空路径
	
    ResourceManger.releasePlist("bosssmallicon")
end  

local function handleNotifyBossCopyFightCount(packet)
	TipFunction.setFuncAttr("func_boss_copy", "count", packet.count)
end


--购买魔石	
NetSocket_registerHandler(NetMsgType["msg_notify_buy_summon_stone"], notify_buy_summon_stone, Handle_req_buyStone)
--领取魔石
NetSocket_registerHandler(NetMsgType["msg_notify_daily_summon_stone"], notify_daily_summon_stone, Handle_req_getStone)
--初始化魔石
NetSocket_registerHandler(NetMsgType["msg_notify_summon_stone_info"], notify_summon_stone_info, initBuyBossStone)
--BOSS本挑战次数
NetSocket_registerHandler(NetMsgType["msg_notify_boss_copy_fight_count"], notify_boss_copy_fight_count, handleNotifyBossCopyFightCount)

EventCenter_subscribe(EventDef["ED_SUMMON_STONE"], setBottomPanenl)	