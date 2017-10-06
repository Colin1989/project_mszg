LayerTowerbg = {}

local mLayerTowerbgRoot = nil
local mLeftTimes = 0


local function  onTowerClick(type,widget)

  if type =="releaseUp" then
    local name =widget:getName()  --判断是点击了那个按钮
	if name == "enterGame"  then 	-- 推塔
		CopyDateCache.GameType = game_type["push_tower"]
		local tb = req_enter_game()
		tb.id = ModelPlayer.getId()
		tb.gametype = CopyDateCache.GameType       -- 1 为进入主线副本
		tb.copy_id = 0
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_enter_game"])
	elseif name == "buytimes" then 
		local function sureBtnEvent()
			cclog("Send------->req_push_tower_buy_playtimes")
			local tb = req_push_tower_buy_playtimes()
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_buy_playtimes"])	
		end

		local structConfirm = {
			strText = GameString.get("buyTime"),
			buttonCount = 2,
			buttonName = {GameString.get("sure"),GameString.get("cancle")},
			buttonEvent = {sureBtnEvent,nil} --回调函数
		}	
		UIManager.push("UI_ComfirmDialog",structConfirm)
	end
   end
end
local function Handle_req_push_tower_buyTimes(resp)
	if resp.result == 1 then 
		cclog("购买推塔次数成功")
		local maxLeftTime = mLayerTowerbgRoot:getChildByName("Label_28_0");
		tolua.cast(maxLeftTime, "UILabel")
		mLeftTimes = mLeftTimes + 1
		maxLeftTime:setText(string.format("%02d",mLeftTimes))
	end
end

LayerTowerbg.init = function(RootView)

		 --mLayerTowerbgRoot = GUIReader:shareReader():widgetFromJsonFile("PowerCopyBg.ExportJson")  --推塔
		mLayerTowerbgRoot =	LoadWidgetFromJsonFile("PowerCopyBg.ExportJson")
		RootView:addChild(mLayerTowerbgRoot)	
		
		--最高记录
		local macScore = mLayerTowerbgRoot:getChildByName("Label_28");
		tolua.cast(macScore, "UILabel")
		macScore:setText(string.format("%03d",FightDateCache.pushTower().resp.max_floor)) 
		
		FightDateCache.setPushMaxFloor(FightDateCache.pushTower().resp.max_floor)
		
		--今日可挑战次数
		local maxLeftTime = mLayerTowerbgRoot:getChildByName("Label_28_0");
		tolua.cast(maxLeftTime, "UILabel")
		mLeftTimes = FightDateCache.pushTower().resp.max_times - FightDateCache.pushTower().resp.play_times
		maxLeftTime:setText(string.format("%02d",mLeftTimes)) 
		
		local Btn_enterGame = mLayerTowerbgRoot:getChildByName("enterGame")
		Btn_enterGame:registerEventScript(onTowerClick)
	
		local Btn_buyTimes = mLayerTowerbgRoot:getChildByName("buytimes")
		Btn_buyTimes:registerEventScript(onTowerClick)
end
NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_buy_playtimes"], notify_push_tower_buy_playtimes(), Handle_req_push_tower_buyTimes)


