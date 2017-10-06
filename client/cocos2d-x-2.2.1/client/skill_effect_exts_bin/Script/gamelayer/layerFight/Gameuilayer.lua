
require "GameSkillConfig"
require "GameSkillBarLayer"
require "GameSkillEffectLayer"
require "GameSkillMgr"

-- 游戏主UI 界面 
BUY_PUSH_TIMES = 1

local loginLayer = nil;  --登入界面
local mRootView = nil

local mAtkValue = nil   --攻击值
local mLifeValue = nil	--生命值
local mSpeedValue = nil	--速度值


local mGoldValue = nil	 --金币值
local mHonorValue = nil  --荣誉值

GameUiLayer = {}




GameUiLayer.updateBoxNum =function()
	if mRootView then 
		local icon1num = mRootView:getWidgetByName("labatlas1")	
		tolua.cast(icon1num,"UILabelAtlas")
		icon1num:setStringValue(FightDateCache.common().BoxNumber)
	end
end


GameUiLayer.updateGoldNum =function()
	if mRootView then 
		local icon2num = mRootView:getWidgetByName("labatlas2")	
		tolua.cast(icon2num,"UILabelAtlas")
		icon2num:setStringValue(FightDateCache.common().GoldNumber)
	end
end

-- GameType 游戏模式 1：主线  2：推塔
GameUiLayer.initView = function(GameType)
	local function initTopView (GameType)
	
		local topView = mRootView:getWidgetByName("Panel_top")		--顶部UI
	
		local rooundPanel = mRootView:getWidgetByName("ImageView_74")--回合数
		
		local icon1 = mRootView:getWidgetByName("fighticon1")
		tolua.cast(icon1,"UIImageView") 
		
		local icon1num = mRootView:getWidgetByName("labatlas1")	
		tolua.cast(icon1num,"UILabelAtlas")
		
		local icon2 = mRootView:getWidgetByName("fighticon2")
		tolua.cast(icon2,"UIImageView") 
		
		local icon2num = mRootView:getWidgetByName("labatlas2")	
		tolua.cast(icon2num,"UILabelAtlas")
			
		--当前层数
		local layernum = mRootView:getWidgetByName("layernum")
		tolua.cast(layernum,"UILabel") 
		--当前回合数
		local round = mRootView:getWidgetByName("round")
		tolua.cast(round,"UILabelAtlas") 
			
		if game_type["common"] == GameType then 
			topView:setVisible(true)
			GameUiLayer.updateBoxNum()
			GameUiLayer.updateGoldNum()
			icon1:loadTexture("itemicon.png",UI_TEX_TYPE_PLIST)  
			layernum:setText( tostring(FightDateCache.common().curFBid % 1000).."->"..tostring(g_CurLevelIndex))
			

			rooundPanel:setVisible(false)
		elseif game_type["push_tower"] == GameType then
			topView:setVisible(true)
			

			
			icon1num:setStringValue(  tostring( FightDateCache.pushTower().awardsNumber  ))
			icon1:loadTexture("gemicon.png",UI_TEX_TYPE_PLIST) 

			round:setStringValue( tostring(FightDateCache.pushTower().LeftRound) )

			layernum:setText( tostring(FightDateCache.pushTower().pushLayer) )
	
			icon2num:setVisible(false)
			
			rooundPanel:setVisible(true)
		elseif GameType == "jjc" then 
			topView:setVisible(false)
			
		end
			

		
		
	end
	
	--玩家属性 
	local function initPlayerArr()
	mAtkValue = mRootView:getWidgetByName("LabelAtlas_25_0")-- 攻击值	
	tolua.cast(mAtkValue,"UILabelAtlas") 
	mAtkValue:setStringValue(ModelPlayer.getPlayerAllAttr().atk)
	
	mLifeValue = mRootView:getWidgetByName("LabelAtlas_25_1")-- 生命值
	tolua.cast(mLifeValue,"UILabelAtlas") 
	mLifeValue:setStringValue(ModelPlayer.life)
		
	mSpeedValue = mRootView:getWidgetByName("LabelAtlas_25")-- 速度
	tolua.cast(mSpeedValue,"UILabelAtlas") 
	mSpeedValue:setStringValue(ModelPlayer.getPlayerAllAttr().speed)
	

end
	if mRootView == nil then 
		cclog("Create:GameUILayer")
		mRootView = UILayer:create()
		mRootView:addWidget(GUIReader:shareReader():widgetFromJsonFile("mainWarUI_1.ExportJson"))	
		ModelPlayer.initRender()		--渲染玩家
		g_sceneUIRoot:addChild(mRootView,g_Const_GameLayer.uiLayer)
		
		g_sceneUIRoot:setVisible(true)
			--++lewis skill
		local layer = CCLayer:create()
		g_sceneUIRoot:addChild(layer, 1000)
		GameSceneHandleFight.initSkill(layer)
		
		-- add by fjut on 2014-03-21
		-- 援助技能
		local tbSkill = LayerAssistance.getDonorInfo()
		if tbSkill ~= nil then
			local node = GUIReader:shareReader():widgetFromJsonFile("AssistanceSkill_1.ExportJson")
			mRootView:addWidget(node)
			cclog("add 援助技能")
			-- 回合次数
			local atlasRound = CommonFunc_getLabelByName(node, "labelAltas_round", nil, true)
			atlasRound:setStringValue(string.format("%d", 0))
			-- 背景
			local imgBg = CommonFunc_getNodeByName(node, "imgView_bg", "UIImageView")
			-- 按钮
			local btnCall = CommonFunc_getNodeByName(node, "btn_tips", "UIButton")
			btnCall:setTitleText("出来啊") -- test
			local bIsIn = true
			local dt = 0.3
			local offsetX = -130
			btnCall:registerEventScript(function(clickType, widget) 
							if clickType ~= "releaseUp" then
								return
							end	
							-- 移动
							local action = CCMoveBy:create(dt, ccp(offsetX, node:getPosition().y))
							btnCall:setTitleText("出来啊") -- test
							if bIsIn then
								action = CCMoveBy:create(dt, ccp(offsetX, node:getPosition().y))
								btnCall:setTitleText("进来啊") -- test
							end
							bIsIn = not bIsIn
							offsetX = -offsetX
							node:runAction(action)	
			end)
			-- 技能头像
			local imgSkill = CommonFunc_getNodeByName(node, "img_skill", "UIImageView")
			imgSkill:loadTexture(tbSkill.icon)
			cclog("技能头像:"..tbSkill.icon)
			imgSkill:registerEventScript(function(clickType, widget) 
							if clickType ~= "releaseUp" then
								return
							end
							cclog("选中技能Id:"..tbSkill.sub_id)
							-- 选中技能表现
							-- todo
							-- ....
			end)
		end
		-- add end
	else
		g_sceneUIRoot:setVisible(true)
		GameSkillMgr.reset()
	end
	
	initPlayerArr()
	initTopView(GameType)

end

function Update_GameUILayer(paramDate)
	
	if  FightDateCache.pushTower().LeftRound == 0 then
		   local function sureBtnEvent() 
				cclog("发送购买回合请求")
				local tb = req_push_tower_buy_round()
				NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_buy_round"])	
		    end
			
			local function cancleBtnEvent()
				cclog("结算界面")
				FightDateCache.HandleGameSettle(2)
			end
			
		
		--通关结算 
		if FightDateCache.pushTower().IsBuyPushRound < BUY_PUSH_TIMES then --如果没买过
			local structConfirm = {
			strText = "是否购买50回合？",
			buttonCount = 2,
			buttonName = {GameString.get("sure"),GameString.get("cancle")},
			buttonEvent = {sureBtnEvent,cancleBtnEvent} --回调函数
			}	
			UIManager.push("UI_ComfirmDialog",structConfirm)
		else 
			FightDateCache.HandleGameSettle(2)
		end
		

	end
	
	local round = mRootView:getWidgetByName("round")
	tolua.cast(round,"UILabelAtlas") 
	round:setStringValue( tostring(FightDateCache.pushTower().LeftRound) )
	

end

GameUiLayer.refreshPlayerStatus = function(atk, life, speed)
	if type(life) == "number" then
		life = string.format("%d",life)
		mLifeValue:setStringValue(life)
	end
	if ModelPlayer.life <=  0 then 
		mLifeValue:setStringValue("0")
	end
	
	local atkStr = string.format("%d", atk)
	mAtkValue:setStringValue(atkStr)
	
	local speedStr = string.format("%d", speed)
	mSpeedValue:setStringValue(speedStr)
end

local function Handle_req_push_tower_buyRound(resp)
	
	FightDateCache.buyRound()		--写死买50回合
	local round = mRootView:getWidgetByName("round")
	tolua.cast(round,"UILabelAtlas") 
	round:setStringValue("50")
end

EventCenter_subscribe("ED_UPDATE_FIGHT_SHOW", Update_GameUILayer)


NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_buy_round"], notify_push_tower_buy_round(), Handle_req_push_tower_buyRound)











