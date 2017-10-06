----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-4-24
-- 描述：战斗主UI
----------------------------------------------------------------------

-- 游戏主UI 界面 

LayerGameUI = {}


local function localPrint(...)
	if true then return end
	lewisPrint("LayerGameUI", ...)
end

LayerGameUI.mRootView = nil
local mRootView = nil

local mTopLayer = nil

local mKeyIconSprite = nil						--钥匙图标
local mKeyCntLabel = nil						--钥匙个数

--local mBoxBgNode = nil			--宝箱背景
local mBoxIconSprite = nil		--宝箱图标
local mBoxCntLabel = nil		--宝箱数量

local mCoinIconSprite = nil		--金币
local mCoinCntLabel = nil		--金币数量

local mMonsterIconSprite = nil					--怪物图标
local mKilledMonsterCntLabel = nil				--当前已击杀怪物数
local mMonsterSlashLabel = nil					--怪物下划线
local mTotalMonsterCntLabel = nil				--总共怪物数

local mFloorInfoLabel = nil
local mRoundInfoLabel = nil

--local mRoundPanel = nil

local mPushTowerNode = nil

LayerGameUI.mAtkLabel = nil
LayerGameUI.mLifeLabel = nil
LayerGameUI.mSpeedLabel = nil

LayerGameUI.mJJcUIRootView = nil

local mCoinsAmount = 0	--显示的金币个数

-----------------------------------------外部接口+++++++++++++++++++++++++++++++++++++
function LayerGameUI.getMonsterIconPos()
	return mKilledMonsterCntLabel:convertToWorldSpace(ccp(0, 0))
end

function LayerGameUI.getCoinIconPos()
	return mCoinIconSprite:convertToWorldSpace(ccp(0, 0))
end

function LayerGameUI.getHeartIconPos()
	local heartIcon = mRootView:getWidgetByName("ImageView_131")
	tolua.cast(heartIcon, "UIImageView")
	return heartIcon:convertToWorldSpace(ccp(0, 0))
end


--label变化时的action
local function labelAction(label)
	local scale = 2.0
	label:stopAllActions()
	label:setScale(1.0)
	local atc1 = CCEaseBackInOut:create(CCScaleBy:create(0.10, scale))
	local atc2 = CCEaseBackInOut:create(CCScaleBy:create(0.035, 1 / scale))
	label:runAction(CCSequence:createWithTwoActions(atc1, atc2))
end

--
local function spriteAction(sprite)
	local scale = 1.4
	sprite:stopAllActions()
	sprite:setScale(1.0)
	local atc1 = CCEaseBackInOut:create(CCScaleBy:create(0.20, scale))
	local atc2 = CCEaseBackInOut:create(CCScaleBy:create(0.07, 1 / scale))
	sprite:runAction(CCSequence:createWithTwoActions(atc1, atc2))
end

---------------------------------------------更新+++++++++++++++++++++++++++++++++++++
--更新拾取宝箱数量
LayerGameUI.updateBoxNum =function()
	mBoxCntLabel:setStringValue(FightDateCache.getData("fd_drop_out_count"))
	spriteAction(mBoxIconSprite)
end

--更新金币数量
function LayerGameUI.updateCoins(inc)
	mCoinsAmount = mCoinsAmount + inc
	mCoinCntLabel:setStringValue(mCoinsAmount)
	spriteAction(mCoinIconSprite)
end

--更新真实的金币数量
function LayerGameUI.updateRealCoins()
	mCoinsAmount = FightDateCache.getData("fd_coin_count")
	mCoinCntLabel:setStringValue(mCoinsAmount)
	spriteAction(mCoinIconSprite)
end

--更新怪物数量视图
function LayerGameUI.initMonsterCnt()
	local total = FightDateCache.getData("fd_floor_total_monster")
	local count = FightDateCache.getData("fd_floor_killed_monster")
	mKilledMonsterCntLabel:setTag(0)
	mKilledMonsterCntLabel:setStringValue(string.format("%d", count))
	mTotalMonsterCntLabel:setStringValue(string.format("%d", total))
	labelAction(mKilledMonsterCntLabel)
end

function LayerGameUI.updateMonsterCnt()
	local count = mKilledMonsterCntLabel:getTag()
	count = count + 1
	mKilledMonsterCntLabel:setTag(count)
	local total = FightDateCache.getData("fd_floor_total_monster")
	mKilledMonsterCntLabel:setStringValue(string.format("%d", count))
	mTotalMonsterCntLabel:setStringValue(string.format("%d", total))
	labelAction(mKilledMonsterCntLabel)
end



--更新钥匙数量视图
function LayerGameUI.updateKeyCnt()
	mKeyCntLabel:setStringValue(string.format("%d", FightDateCache.getData("fd_key_count")))
	labelAction(mKeyCntLabel)
end

---------------------------------------按钮事件+++++++++++++++++++++++++++++++++++++
--暂停按钮所调用的方法
local function pauseGameEvent(type,widget)
	if FightMgr.isOnControll() == false then return end
	if type == "releaseUp" then
		UIManager.push("UI_PauseGame",nil)
		CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	end
end

local function showFightInfo(types,widget)
	if FightMgr.isOnControll() == false then return end
	if types == "releaseUp" then
		UIManager.push("UI_GameFightInfo",RoleMgr.getConfig("rmc_player_object"):getDataInfo("buff"))
	end
end


local function showWorldChat(types,widget)
    if FightMgr.isOnControll() == false then return end
    if types == "releaseUp" then
		local function callFunc()
			local tb = {
				rootView = mRootView,
				from = "Game",
			}
			UIManager.push("UI_WorldChat", tb)
		end
        
		local time_move = 0.5
		local action_move = CCMoveBy:create(time_move,ccp(-51, 0))
		action_move = CCEaseBackOut:create(action_move)
		local action_call = CCCallFunc:create(callFunc)
		local action = CCSequence:createWithTwoActions(action_move,action_call)
		widget:runAction(action)
	end
end 

---------------------------------------创建+++++++++++++++++++++++++++++++++++++
local function bindValue()
	mPushTowerNode = mRootView:getWidgetByName("ImageView_202")
	tolua.cast(mPushTowerNode, "UIImageView")
	
	--钥匙视图
	mKeyIconSprite = mRootView:getWidgetByName("ImageView_117")
	tolua.cast(mKeyIconSprite, "UIImageView")
	
	mKeyCntLabel = mRootView:getWidgetByName("LabelAtlas_118")
	tolua.cast(mKeyCntLabel, "UILabelAtlas")
	
	--怪物数量视图
	mMonsterIconSprite = mRootView:getWidgetByName("LabelAtlas_116")
	tolua.cast(mMonsterIconSprite, "UIImageView")
	
	mKilledMonsterCntLabel = mRootView:getWidgetByName("LabelAtlas_150")
	tolua.cast(mKilledMonsterCntLabel, "UILabelAtlas")
	
	mMonsterSlashLabel = mRootView:getWidgetByName("LabelAtlas_119")
	tolua.cast(mMonsterSlashLabel, "UILabelAtlas")
	
	mTotalMonsterCntLabel = mRootView:getWidgetByName("LabelAtlas_151")
	tolua.cast(mTotalMonsterCntLabel, "UILabelAtlas")
	
	--宝箱视图
	--mBoxBgNode = mRootView:getWidgetByName("ImageView_176")
	--tolua.cast(mBoxBgNode, "UIImageView")
	
	mBoxIconSprite = mRootView:getWidgetByName("fighticon1")
	tolua.cast(mBoxIconSprite, "UIImageView") 
	
	mBoxCntLabel = mRootView:getWidgetByName("labatlas1")	
	tolua.cast(mBoxCntLabel, "UILabelAtlas")
	
	--金币视图
	mCoinIconSprite = mRootView:getWidgetByName("fighticon2")
	tolua.cast(mCoinIconSprite, "UIImageView") 
	
	mCoinCntLabel = mRootView:getWidgetByName("labatlas2")	
	tolua.cast(mCoinCntLabel, "UILabelAtlas")
	
	--当前层数
	mFloorInfoLabel = mRootView:getWidgetByName("layernum")
	tolua.cast(mFloorInfoLabel, "UILabel") 
	
	--当前回合数
	mRoundInfoLabel = mRootView:getWidgetByName("round")
	tolua.cast(mRoundInfoLabel, "UILabelAtlas")
	
	--回合层
	--mRoundPanel = mRootView:getWidgetByName("ImageView_74")
	
	--玩家属性
	LayerGameUI.mAtkLabel = mRootView:getWidgetByName("LabelAtlas_25_0")-- 攻击值	
	tolua.cast(LayerGameUI.mAtkLabel, "UILabelAtlas") 
	
	LayerGameUI.mLifeLabel = mRootView:getWidgetByName("LabelAtlas_25_1")-- 生命值
	tolua.cast(LayerGameUI.mLifeLabel, "UILabelAtlas")
	
	LayerGameUI.mSpeedLabel = mRootView:getWidgetByName("LabelAtlas_25")-- 速度
	tolua.cast(LayerGameUI.mSpeedLabel,"UILabelAtlas") 
	
	--主要节点
	mTopLayer = mRootView:getWidgetByName("Panel_top")		--顶部UI
		
end

--初始化关卡UI
local function initStageUI()
	mTopLayer:setVisible(true)
	--mRoundPanel:setVisible(false)
	mBoxCntLabel:setVisible(true)
	mCoinCntLabel:setVisible(true)
	mKeyCntLabel:setVisible(false)
	mKeyIconSprite:setVisible(false)
	LayerGameUI.updateBoxNum()
	
	--local keyBg = mRootView:getWidgetByName("ImageView_191")
	--tolua.cast(keyBg, "UIImageView")
	--keyBg:setVisible(false)
	
	mCoinsAmount = FightDateCache.getData("fd_coin_count")
	mCoinCntLabel:setStringValue(mCoinsAmount)
	spriteAction(mCoinIconSprite)
	
	mBoxIconSprite:loadTexture("itemicon.png")

    mRoundInfoLabel:setStringValue(FightDateCache.getData("fb_round_count"))
	LayerGameUI.initMonsterCnt()
	LayerGameUI.updateUsedRound()

    --查看3星详细信息
    local sanxingdesc = mRootView:getWidgetByName("sanxingdesc")
    
	sanxingdesc:registerEventScript(function(eventType,widget)
        if "releaseUp" == eventType then
            UIManager.push("UI_threedesc")
		end
    end)

end

--初始化推塔UI
local function initPushTowerUI()
	mTopLayer:setVisible(true)
	--mBoxBgNode:setVisible(false)
	--mRoundPanel:setVisible(true)
	mBoxCntLabel:setVisible(false)
	mBoxIconSprite:setVisible(false)
	mCoinCntLabel:setVisible(true)
	mKeyCntLabel:setVisible(true)
	mKeyIconSprite:setVisible(true)
	
	--local size = mBoxBgNode:getContentSize()
	--local pos = mPushTowerNode:getPosition()
	--mPushTowerNode:setPosition(ccp(pos.x - size.width, pos.y))
	--print("push tower position", pos.x, pos.y)
	
	LayerGameUI.updateBoxNum()
	
	--local keyBg = mRootView:getWidgetByName("ImageView_191")
	--tolua.cast(keyBg, "UIImageView")
	--keyBg:setVisible(true)
	
	mCoinsAmount = FightDateCache.getData("fd_coin_count")
	mCoinCntLabel:setStringValue(mCoinsAmount)
	spriteAction(mCoinIconSprite)
	
	LayerGameUI.updateRestRound()
    
	mFloorInfoLabel:setText(tostring(FightDateCache.getData("fd_push_tower_floor")))
	LayerGameUI.initMonsterCnt()
	LayerGameUI.updateKeyCnt()
end

local function initFenZuUI()
    mTopLayer:setVisible(false)
    LayerGameUI.mJJcUIRootView:setVisible(true)

end 

--初始化竞技场UI
local function initArenaUI()
	mTopLayer:setVisible(false)
end

--初始化训练赛UI
local function initTraningUI()
	mTopLayer:setVisible(false)
end

--初始活动副本UI
local function initActivityUI()
	mTopLayer:setVisible(true)
	mBoxCntLabel:setVisible(false)
	mBoxIconSprite:setVisible(false)
	mCoinCntLabel:setVisible(true)
	mKeyCntLabel:setVisible(true)
	mKeyIconSprite:setVisible(true)
	
	mCoinsAmount = FightDateCache.getData("fd_coin_count")
	mCoinCntLabel:setStringValue(mCoinsAmount)
	mFloorInfoLabel:setText(tostring(FightDateCache.getData("fd_push_tower_floor")))
	spriteAction(mCoinIconSprite)
    
	LayerGameUI.initMonsterCnt()
	LayerGameUI.updateKeyCnt()
	LayerGameUI.updateBoxNum()
	LayerGameUI.updateAcivityUsedRound()
end

--创建UI视图
local function createUI()
	if LayerGameUI.mRootView ~= nil then
		g_sceneUIRoot:setVisible(true)
		return
	end
	localPrint("Create:LayerGameUI")
	mRootView = UILayer:create()
	mRootView:addWidget(GUIReader:shareReader():widgetFromJsonFile("mainWarUI_1.json"))	
	g_sceneUIRoot:addChild(mRootView, g_Const_GameLayer.uiLayer)	
	g_sceneUIRoot:setVisible(true)
	LayerGameUI.mRootView = mRootView
	bindValue()
	LayerGameUI.blessView()
    LayerGameUI.createjjcView()
	LayerGameUI.postView(true)
end

-- GameType 游戏模式 1：主线  2：推塔
LayerGameUI.initView = function()
	createUI()
	local gameMode = FightDateCache.getData("fd_game_mode")
	if 1 == gameMode then 
		initStageUI()
	elseif 2 == gameMode then
		initPushTowerUI()
	elseif gameMode == 3 then 
		initArenaUI()
	elseif gameMode == 4 then
		initTraningUI()
	elseif gameMode == 5 then
		initFenZuUI()
	elseif gameMode == 6 then
		initActivityUI()
	end
    AIControllView.init()
end

--注册按钮事件
function LayerGameUI.registerEvent()
	local fightInfo = mRootView:getWidgetByName("ImageView_info")
	fightInfo:registerEventScript(showFightInfo)
		
	local pauseGame = mRootView:getWidgetByName("pauseGame")		--暂停按钮
	pauseGame:registerEventScript(pauseGameEvent)

    local world_chat = mRootView:getWidgetByName("world_chat")		--世界聊天
	world_chat:registerEventScript(showWorldChat)
end



function LayerGameUI.show(bVisible)
	if mRootView == nil then
		return
	end
	mRootView:setVisible(bVisible)
end

LayerGameUI.destroy = function()
	if mRootView ~= nil then
		mRootView:removeFromParentAndCleanup(true)
		mRootView = nil
	end
	g_sceneUIRoot:removeAllChildrenWithCleanup(true)
	LayerGameUI.mRootView = nil 
end

--暂停按钮出场动作
function LayerGameUI.pauseBtnOnEnter(duration)
end

--更新战斗已经使用回合数
function LayerGameUI.updateUsedRound()
	local round = FightDateCache.getData("fb_round_count")
	mRoundInfoLabel:setStringValue(tostring(round))
	spriteAction(mRoundInfoLabel)
	local curMaxRound = tonumber(LogicTable.getCopyById(FightDateCache.getData("fd_copy_id")).min_cost_round)
	if round == curMaxRound then 
		mRoundInfoLabel:runAction(CCTintTo:create(0.5, 254, 25, 25))
	end
end

--更新推塔剩余回合数
function LayerGameUI.updateRestRound()
	local round = FightDateCache.getData("fd_rest_round")
	mRoundInfoLabel:setStringValue(tostring(round))
end

--更新活动副本战斗已经使用回合数
function LayerGameUI.updateAcivityUsedRound()
	local round = FightDateCache.getData("fb_round_count")
	mRoundInfoLabel:setStringValue(tostring(round))
	spriteAction(mRoundInfoLabel)
end

--更新层数
function LayerGameUI.updateFloorInfo()
	local floorIdx = 1
	local maxIdx = 1
	if FightDateCache.getData("fd_game_mode") == 2 then
		floorIdx = FightConfig.getConfig("fc_push_tower_cache_data").floorIdx
		maxIdx = 10--FightConfig.getConfig("fc_push_tower_sever_data").max_floor
		if floorIdx > maxIdx then
			maxIdx = floorIdx
		end
	else
		maxIdx = FightDateCache.getData("fd_max_floor")
		floorIdx = FightDateCache.getData("fd_floor_index")
	end
	mFloorInfoLabel:setText(floorIdx.."/"..maxIdx)
end

function LayerGameUI.guideReset()
	local icon = mRootView:getWidgetByName("ImageView_178")
	tolua.cast(icon, "UIImageView")
	icon:stopAllActions()
	icon:setScale(1.0)
	
	icon = LayerGameUI.mAtkLabel
	icon:stopAllActions()
	icon:setScale(1.0)
	
	icon = LayerGameUI.mLifeLabel
	icon:stopAllActions()
	icon:setScale(1.0)
	
	icon = LayerGameUI.mSpeedLabel
	icon:stopAllActions()
	icon:setScale(1.0)
end

function tipsAction(node)
	local scale = 1.4
	node:setScale(1.0)
	local atc1 = CCScaleBy:create(0.3, scale)
	local atc2 = CCScaleBy:create(0.1, 1 / scale)
	node:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(atc1, atc2)))
end

--提示怪物头像
function LayerGameUI.monsterIconTips()
	--ImageView_178
	local icon = mRootView:getWidgetByName("ImageView_178")
	tolua.cast(icon, "UIImageView")
	icon:stopAllActions()
	tipsAction(icon)
end

--自身属性值提示
function LayerGameUI.playerAttrTips()
	local icon = LayerGameUI.mAtkLabel
	icon:stopAllActions()
	tipsAction(icon)
	
	icon = LayerGameUI.mLifeLabel
	icon:stopAllActions()
	tipsAction(icon)
	
	icon = LayerGameUI.mSpeedLabel
	icon:stopAllActions()
	tipsAction(icon)
end

--创建竞技场图标
function LayerGameUI.createjjcView()
    LayerGameUI.mJJcUIRootView = UILayer:create()
    LayerGameUI.mRootView:addChild(LayerGameUI.mJJcUIRootView, 10003)

    for key=0,2 do        local widget = GUIReader:shareReader():widgetFromJsonFile("enemyInfo_1.json")        widget:setPosition(ccp(0+widget:getContentSize().width*key,960-widget:getContentSize().height))      --FIXME 
        widget:setName("jjc_uiindex"..key)
        LayerGameUI.mJJcUIRootView:addWidget(widget)
    end 
    LayerGameUI.mJJcUIRootView:setVisible(false)
end 


--创建祝福图标
function LayerGameUI.blessView()
	local curBuff = BlessLogic.getBlessBuff()
	if 0 == curBuff.benison_id then
		return
	end
	
	local blessInfo = LogicTable.getBlessInfoById(curBuff.benison_id)
	local blessProInfo = LogicTable.getBlessProInfoById(blessInfo.status_ids)
	if blessInfo.icon == "NULL" then
		return
	end
	
	local parent = LayerGameUI.mRootView:getWidgetByName("icon_bless")
	tolua.cast(parent, "UIImageView")
	
	local sprite = CCSprite:create(blessInfo.icon)
	parent:addRenderer(sprite, 0)
	sprite:setPosition(ccp(0, 0))
	sprite:setScale(71.0 / 90.0)
end

--创建公告
function LayerGameUI.postView(initFlag)
	if nil == LayerGameUI.mRootView then
		return
	end
	local post = tolua.cast(LayerGameUI.mRootView:getWidgetByName("Panel_post"), "UILayout")
	if true == initFlag then
		post:setVisible(false)
		return
	end
	local function callFunc()
		post:setVisible(false)
	end
	Toast.showNotice(post, post:getSize().width - 20, post:getSize().height - 10, ccp(5, 4), callFunc)
end

EventCenter_subscribe(EventDef["ED_POST"], LayerGameUI.postView)





