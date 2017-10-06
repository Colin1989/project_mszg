----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-03-31
-- 描述：游戏战斗结束,与服务端消息处理
----------------------------------------------------------------------

FightEnd = {}
local mGameEndHandleTB = {}

--处理游戏结果
FightEnd.gameSettle = function(result)
   --新手关结算
   if FightDateCache.getData("fd_copy_id") == FIRSTCOPYID then
       	FightMgr.onExit()
        --UIManager.push("UI_RollChoice")	
        fourFrames.start(STORY_1,"enterRoleChioce",ccp(45,560))

        FightDateCache.setData("fd_copy_id",0)
        --GuideMgr.onMessage("empty")
        return 
	end

	local gameMode = FightDateCache.getData("fd_game_mode")
	local handleFunc = mGameEndHandleTB[gameMode]
	handleFunc(result)
end


-- 获取本关详细信息
local function getCopyDetail()
	local copyId = FightDateCache.getData("fd_copy_id")
	for k,v in pairs(LogicTable.getGameAllFB()) do
		if v.id == copyId then
			return v
		end
	end
	return nil
end

---------------------------------------------------------------------------------
--------------------------------关卡模式-----------------------------------------
---------------------------------------------------------------------------------
function FightEnd.stageEnd(result)
	local life, maxlife = RoleMgr.getPlayerLife()
	local tb = req_game_settle ()
	tb.result 			= result		--- 1为正常过关
	tb.gold			 	= FightDateCache.getData("fd_coin_count")
	tb.game_id 			= FightDateCache.getData("fd_game_id")
	tb.life 			= life
	tb.maxlife 			= maxlife
	tb.cost_round  		= FightDateCache.getData("fb_round_count")
	tb.killmonsters 	= FightDateCache.getData("fd_killed_monster_tb")
	tb.pickup_items 	= FightDateCache.getData("fd_drop_out_goods")
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_game_settle"])	
end
-- 挑战副本失败
function FightEnd.stageFailEnd()
    local tb = req_game_settle ()
    tb.result 			= 2	
	tb.game_id 			= FightDateCache.getData("fd_game_id")
    NetHelper.sendAndWait(tb)
end


--处理过关网络消息
local function handleStageEnd(tb)
    --print("---------------------主线副本结算-----------------------",tb.result)  
    if tb.result~=1 then 
        --非正常过关
        return 
    end 

	local fb = getCopyDetail()
	tb.gold 			= fb.gold
	tb.exp 				= fb.exp
	tb.name 			= fb.name
	tb.Pickup_items 	= FightDateCache.getData("fd_drop_out_goods")
	
	local function openFightOver()
		TipModule.onNet("msg_notify_game_settle")
		UIManager.push("UI_FightOver",tb)
	end
	
	-- 添加援军为好友
	local donorInfo = AssistanceLogic.getDonorInfo()
	if donorInfo and false == FriendDataCache.judgeIsMyFriend(donorInfo.role_id) then
		local function okFunc()
			FriendDataCache.reqAddFriend_add(donorInfo.role_id)
			openFightOver()
		end
		local structConfirm = 
		{
			strText = GameString.get("Assistance_str_04", donorInfo.nick_name),
			buttonCount = 2,
			buttonEvent = {okFunc, openFightOver}
		}
		UIManager.push("UI_ComfirmDialog", structConfirm)
	else
		openFightOver()
	end
end

--主线副本结算
NetSocket_registerHandler(NetMsgType["msg_notify_game_settle"], notify_game_settle, handleStageEnd)

---------------------------------------------------------------------------------
--------------------------------推塔模式-----------------------------------------
---------------------------------------------------------------------------------
function FightEnd.pushTowerEnd(result)
	local life, maxlife = RoleMgr.getPlayerLife()
	local tb = req_push_tower_map_settle()
	tb.game_id 			= FightDateCache.getData("fd_game_id")
	tb.result 			= result
	tb.cost_round 		= FightDateCache.getData("fd_total_round")
	tb.life				= life
	tb.pickup_items 	= {}
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_map_settle"])
end

local function handlePushTowerEnd(tb)
	if tb.result == map_settle_result["map_settle_next_map"] then
		FightConfig.pushTowerNextFloor()
		UIManager.push("UI_Towerpasslayer", tb)
		FightDateCache.setData("fd_floor_index", 1)
		FightDateCache.setData("fd_map_data", tb.gamemap)
		FightDateCache.setData("fd_max_floor", #(tb.gamemap))
		FightDateCache.setData("fd_total_round", 0)
		FightDateCache.updateData("fd_push_tower_floor", 1)
	elseif tb.result == map_settle_result["map_settle_finish"] then
		FightDateCache.gainCoins(tb.gold)
		-- 通过最后一层魔塔
		if tb.gold > 0 and 0 == tb.gamemap[1].scene then
			FightConfig.pushTowerNextFloor()
		end
		tb.EventType = "endLayer"
		UIManager.push("UI_TowerSettle", tb)
	elseif tb.result == map_settle_result["map_settle_died"] then
		tb.EventType = "endLayer"
		UIManager.push("UI_TowerSettle", tb)
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_map_settle"], notify_push_tower_map_settle, handlePushTowerEnd)

--推塔回合数用完
function FightEnd.pushTowerRunOutOfRound()
	--确定购买回合数
	local function sureBtnEvent() 
		local tb = req_push_tower_buy_round()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_buy_round"])	
	end
	
	--取消购买回合数
	local function cancleBtnEvent()
		FightEnd.pushTowerEnd(2)
	end
	
	local buyTimes = FightDateCache.getData("fd_push_tower_buy_times")
	local maxTimes = FightDateCache.getData("fd_push_tower_max_buy_times")
	if buyTimes < maxTimes then
		local structConfirm = 
		{
			strText = GameString.get("TOWERDESC"),
			buttonCount = 2,
			buttonName = {GameString.get("sure"),GameString.get("cancle")},
			buttonEvent = {sureBtnEvent, cancleBtnEvent} --回调函数
		}	
		UIManager.push("UI_ComfirmDialog", structConfirm)
	else
		FightEnd.pushTowerEnd(2)
	end	
end

local function handlePushTowerBuyRound(tb)
    print("handlePushTowerBuyRound",tb.result,common_result["common_success"])
    if tb.result == common_result["common_success"] then
	    FightDateCache.updateData("fd_push_tower_buy_times", 1)
	    FightDateCache.updateData("fd_rest_round", 50)
	    LayerGameUI.updateRestRound()
	    AIMgr.recover()
    end 
end

NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_buy_round"], notify_push_tower_buy_round, handlePushTowerBuyRound)


---------------------------------------------------------------------------------
--------------------------------竞技场模式---------------------------------------
---------------------------------------------------------------------------------
function FightEnd.matchEnd(result)
	local tb = req_challenge_settle()
	tb.game_id 	= FightDateCache.getData("fd_game_id")
	tb.result 	= result			--1 挑战成功 2 ：挑战失败	
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_settle"])
end

local function handleMatchEnd(tb)
	if tb.result == 1 then -- 挑战成功
		UIManager.push("UI_JJCSuccess", tb)
	elseif tb.result == 2 then --挑战失败
		UIManager.push("UI_JJCFailed", tb)
	end
end
NetSocket_registerHandler(NetMsgType["msg_notify_challenge_settle"], notify_challenge_settle, handleMatchEnd)

---------------------------------------------------------------------------------
--------------------------------训练赛模式---------------------------------------
---------------------------------------------------------------------------------

function FightEnd.trainingEnd(result)
	local tb = req_train_match_settle()
	tb.game_id 	= FightDateCache.getData("fd_game_id")
	tb.result 	= result			--1 挑战成功 2 ：挑战失败	
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_train_match_settle"])
end

local function handleTrainingEnd(tb)
	if tb.result == 1 then -- 挑战成功
		UIManager.push("UI_JJCSuccess", tb)
	elseif tb.result == 2 then --挑战失败
		UIManager.push("UI_JJCFailed", tb)
	end
	EventCenter_post(EventDef["ED_TRAINGAME_TIMES"])
end

NetSocket_registerHandler(NetMsgType["msg_notify_train_match_settle"], notify_train_match_settle, handleTrainingEnd)

---------------------------------------------------------------------------------
--------------------------------天梯模式3V3-----------------------------------------
---------------------------------------------------------------------------------
function FightEnd.ladderMatchEnd(result)
	local tb = req_settle_ladder_match() 
	tb.game_id 	= FightDateCache.getData("fd_game_id")
	tb.result 	= result
    tb.life_info = RoleMgr.settleLifeInfo()

    Log(tb.life_info)

	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_settle_ladder_match"])
end

local function handleLadderMatchEnd(tb)
    CCDirector:sharedDirector():getActionManager():setSpeed(1.0)
	if tb.result == 1 then -- 挑战成功
		UIManager.push("UI_GroupMatchVictory", tb)
	elseif tb.result == 2 then --挑战失败
		UIManager.push("UI_GroupMatchFailure", tb)
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_settle_ladder_match"], notify_settle_ladder_match, handleLadderMatchEnd)

---------------------------------------------------------------------------------
--------------------------------活动副本模式-----------------------------------------
---------------------------------------------------------------------------------
function FightEnd.activityCopyEnd(result)
	local tb = req_settle_activity_copy()
	tb.game_id		= FightDateCache.getData("fd_game_id")
	tb.result		= result
	tb.pickup_items = FightDateCache.getData("fd_drop_out_goods")
	tb.gold			= FightDateCache.getData("fd_coin_count")
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_settle_activity_copy_result"])
end

local function handleActivityCopyEnd(tb)
	if tb.result ~= 1 then -- 挑战失败
		return
	end
	local activityCopyRow = LogicTable.getActivityCopyRow(FightDateCache.getData("fd_copy_id"))
	tb.gold 			= activityCopyRow.gold
	tb.exp 				= activityCopyRow.exp
	tb.name 			= activityCopyRow.name
	tb.Pickup_items 	= FightDateCache.getData("fd_drop_out_goods")
	
	local function openFightOver()
		UIManager.push("UI_FightOver", tb)
	end
	-- 添加援军为好友
	local donorInfo = AssistanceLogic.getDonorInfo()
	if donorInfo and false == FriendDataCache.judgeIsMyFriend(donorInfo.role_id) then
		local function okFunc()
			FriendDataCache.reqAddFriend_add(donorInfo.role_id)
			openFightOver()
		end
		local structConfirm = 
		{
			strText = GameString.get("Assistance_str_04", donorInfo.nick_name),
			buttonCount = 2,
			buttonEvent = {okFunc, openFightOver}
		}
		UIManager.push("UI_ComfirmDialog", structConfirm)
	else
		openFightOver()
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_settle_activity_copy_result"], notify_settle_activity_copy_result, handleActivityCopyEnd)


mGameEndHandleTB[1] = FightEnd.stageEnd
mGameEndHandleTB[2] = FightEnd.pushTowerEnd
mGameEndHandleTB[3] = FightEnd.matchEnd
mGameEndHandleTB[4] = FightEnd.trainingEnd
mGameEndHandleTB[5] = FightEnd.ladderMatchEnd
mGameEndHandleTB[6] = FightEnd.activityCopyEnd




