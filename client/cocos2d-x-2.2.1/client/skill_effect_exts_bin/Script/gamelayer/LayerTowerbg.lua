LayerTowerbg = {}

local mLayerTowerbgRoot = nil
local mLeftTimes = 0


local function  onTowerClick(type,widget)

  if type =="releaseUp" then
    local name =widget:getName()  --�ж��ǵ�����Ǹ���ť
	if name == "enterGame"  then 	-- ����
		CopyDateCache.GameType = game_type["push_tower"]
		local tb = req_enter_game()
		tb.id = ModelPlayer.getId()
		tb.gametype = CopyDateCache.GameType       -- 1 Ϊ�������߸���
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
			buttonEvent = {sureBtnEvent,nil} --�ص�����
		}	
		UIManager.push("UI_ComfirmDialog",structConfirm)
	end
   end
end
local function Handle_req_push_tower_buyTimes(resp)
	if resp.result == 1 then 
		cclog("�������������ɹ�")
		local maxLeftTime = mLayerTowerbgRoot:getChildByName("Label_28_0");
		tolua.cast(maxLeftTime, "UILabel")
		mLeftTimes = mLeftTimes + 1
		maxLeftTime:setText(string.format("%02d",mLeftTimes))
	end
end

LayerTowerbg.init = function(RootView)

		 --mLayerTowerbgRoot = GUIReader:shareReader():widgetFromJsonFile("PowerCopyBg.ExportJson")  --����
		mLayerTowerbgRoot =	LoadWidgetFromJsonFile("PowerCopyBg.ExportJson")
		RootView:addChild(mLayerTowerbgRoot)	
		
		--��߼�¼
		local macScore = mLayerTowerbgRoot:getChildByName("Label_28");
		tolua.cast(macScore, "UILabel")
		macScore:setText(string.format("%03d",FightDateCache.pushTower().resp.max_floor)) 
		
		FightDateCache.setPushMaxFloor(FightDateCache.pushTower().resp.max_floor)
		
		--���տ���ս����
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


