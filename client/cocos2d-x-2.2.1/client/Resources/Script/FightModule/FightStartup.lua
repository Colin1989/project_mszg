----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-03-31
-- 描述：游戏启动入口
----------------------------------------------------------------------

FightStartup = {}


local function localPrint(...)
	if true then return end
	lewisPrint("FightStartup", ...)
end

---------------------------------------------------------------------------------
--------------------------------活动模式-----------------------------------------
---------------------------------------------------------------------------------
function FightStartup.startActivity(copyId)
	--[[
    if copyId == 1 then
		FightConfig.setConfig("fc_battle_map_name", GameString.get("PUBLIC_NEW_GUIDE"))
	end
    ]]--
	FightDateCache.initData()
	FightDateCache.setData("fd_game_mode", 6)   --游戏模式,1普通关卡,2推塔,3竞技场,4训练比赛,5天梯赛 6活动副本
	FightDateCache.setData("fd_copy_id", copyId)
	FightDateCache.setData("fd_pass_mode", 2)       -- 过关模式设为拾取钥匙 先 再改！！
	FightDateCache.setData("fd_round_overlap", copyId ~= 1)

	FightConfig.setConfig("rmc_player_init_skill_status", "done")
	
	local tb = req_enter_activity_copy()
	tb.copy_id = copyId
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_enter_activity_result"])
end



--消息返回处理,进入活动副本游戏
local function handleEnterActivityCopy(tb)
	 if tb.result == common_result["common_success"] then
        UIManager.setEnterFightType("enter_Tower")		
	
	    FightDateCache.setData("fd_game_id", tb.game_id)
	    FightDateCache.setData("fd_map_data", tb.gamemaps)
	    FightDateCache.setData("fd_max_floor", #(tb.gamemaps))
	    FightMgr.enter()
		CopyLogic.reduceActivityCopyPlayTimes()
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_enter_activity_result"], notify_enter_activity_result, handleEnterActivityCopy)    

---------------------------------------------------------------------------------
--------------------------------关卡模式-----------------------------------------
---------------------------------------------------------------------------------
--开始关卡,包括普通副本,精英副本,BOSS副本
function FightStartup.startStage(copyId)
    local copyInfo  = LogicTable.getCopyById(copyId)

	--if copyId == 1 then
		--FightConfig.setConfig("fc_battle_map_name", GameString.get("PUBLIC_NEW_GUIDE"))
	--end
	FightDateCache.initData()
	FightDateCache.setData("fd_game_mode", 1)
	FightDateCache.setData("fd_copy_id", copyId)
	FightDateCache.setData("fd_pass_mode", 2)
	FightDateCache.setData("fd_round_overlap", copyId ~= 1)
	FightConfig.setConfig("rmc_player_init_skill_status", "done")


	--新怪物提醒
	if CopyDateCache.getCopyStatus(copyId) == "doing" then
		local copyInfo = LogicTable.getCopyById(copyId)
		local newMonsterTB = CommonFunc_split(copyInfo.new_monsters, ",")
		FightDateCache.setData("fd_new_monster_tb", newMonsterTB)
	end
	
	local tb = req_enter_game()
	tb.id = ModelPlayer.getId()
	tb.gametype = 1
	tb.copy_id = copyId
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_enter_game"])
end

--消息返回处理,进入副本游戏
local function handleEnterStage(tb)
	 if tb.result ~= enter_game_result["enter_game_success"] then
		return
	end
	local gameMode = FightDateCache.getData("fd_game_mode")
	local copyId = FightDateCache.getData("fd_copy_id")
	if gameMode == 1 then
		if 1 == copyId then 
			UIManager.setEnterFightType("New_Player")
        elseif CopyDateCache.isBossByCopyId(copyId) then 
            UIManager.setEnterFightType("enter_CopyBoss")
		else 
			UIManager.setEnterFightType("enter_Copy")
		end
	elseif gameMode == 2 then 
		UIManager.setEnterFightType("enter_Tower")		
	end 
	FightDateCache.setData("fd_game_id", tb.game_id)
	FightDateCache.setData("fd_map_data", tb.gamemaps)
	FightDateCache.setData("fd_max_floor", #(tb.gamemaps))
	FightMgr.enter()
end

NetSocket_registerHandler(NetMsgType["msg_notify_enter_game"], notify_enter_game, handleEnterStage)      -- 注册监听

---------------------------------------------------------------------------------
--------------------------------推塔模式-----------------------------------------
---------------------------------------------------------------------------------
function FightStartup.startPushTower()
	FightDateCache.initData()
	FightDateCache.setData("fd_push_tower_floor", 1)
	FightDateCache.setData("fd_push_tower_buy_times", 0)
	FightDateCache.setData("fd_push_tower_max_buy_times", 1)
	FightDateCache.setData("fd_rest_round", PUSH_TOTAL_ROUND)
	FightDateCache.setData("fd_game_mode", 2)
	FightDateCache.setData("fd_pass_mode", 1)
	FightConfig.setConfig("rmc_player_init_skill_status", "done")
	local tb = req_enter_game()
	tb.id = ModelPlayer.getId()
	tb.gametype = 2
	tb.copy_id = 0
	FightConfig.initPustTowerCacheData()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_enter_game"])
end

---------------------------------------------------------------------------------
--------------------------------竞技场模式---------------------------------------
---------------------------------------------------------------------------------
function FightStartup.startMatch(roleInfo)
	FightDateCache.initData()
	FightDateCache.setData("fd_game_mode", 3)
	FightDateCache.setData("fd_copy_id", 0)
	FightDateCache.setData("fd_pass_mode", 1)
	--FightDateCache.setData("fd_show_auto_play_btn", false)
	
	FightConfig.setConfig("fc_enemy_level", roleInfo.level)
	FightConfig.setConfig("fc_enemy_name", roleInfo.name)
	FightConfig.setConfig("rmc_player_init_skill_status", "max_cd")
	
	local tb 		= req_challenge_other_player()
	tb.role_id 		= roleInfo.role_id
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_challenge_other_player_result"])
end

local function handleEnterMatch(tb)
	--进入竞技场出错
	if tb.result ~= 1 then
		return
	end
	FightDateCache.setData("fd_game_id", tb.game_id)
	FightDateCache.setData("fd_map_data", tb.map)
	FightDateCache.setData("fd_max_floor", #(tb.map))
	--FightDateCache.setData("fd_full_auto_play", true)
	FightConfig.setConfig("fc_battle_map_name", "竞技场")
	FightMgr.enter()
end

NetSocket_registerHandler(NetMsgType["msg_notify_challenge_other_player_result"], notify_challenge_other_player_result, handleEnterMatch)

---------------------------------------------------------------------------------
--------------------------------训练赛模式---------------------------------------
---------------------------------------------------------------------------------
function FightStartup.startTranning(roleInfo)
	FightDateCache.initData()
	FightDateCache.setData("fd_game_mode", 4)
	FightDateCache.setData("fd_copy_id", 0)
	FightDateCache.setData("fd_pass_mode", 1)
	--FightDateCache.setData("fd_show_auto_play_btn", false)
	
    print("--------------训练赛模式--------------",roleInfo.name)
	FightConfig.setConfig("fc_enemy_level", roleInfo.level)
	FightConfig.setConfig("fc_enemy_name", roleInfo.name)
	FightConfig.setConfig("rmc_player_init_skill_status", "max_cd")
	
	local tb 			= req_start_train_match()
	tb.role_id 			= roleInfo.role_id
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_start_train_match_result"])
end

-- 进入训练比赛
local function handleEnterTranning(tb)
	--进入竞技场出错
	if tb.result ~= 1 then
		return
	end
	FightDateCache.setData("fd_game_id", tb.game_id)
	FightDateCache.setData("fd_map_data", tb.map)
	FightDateCache.setData("fd_max_floor", #(tb.map))
	--FightDateCache.setData("fd_full_auto_play", true)
	FightConfig.setConfig("fc_battle_map_name", "训练赛")
	FightMgr.enter()
end

NetSocket_registerHandler(NetMsgType["msg_notify_start_train_match_result"], notify_start_train_match_result, handleEnterTranning)

---------------------------------------------------------------------------------
--------------------------------分组模式-----------------------------------------
---------------------------------------------------------------------------------

function FightStartup.startladderMatch(friendlistInfo,enemylistInfo)
    --Log("-----------FightStartup.startladderMatch----------------")
    --Log(friendlistInfo)

	--assert(enemyInfo ~= nil,"ladderMatch->enemyInfo == nil")

	FightDateCache.initData()
	FightDateCache.setData("fd_game_mode", 5)
	FightDateCache.setData("fd_copy_id", 0)
	FightDateCache.setData("fd_pass_mode", 1)
	--FightDateCache.setData("fd_show_auto_play_btn", false)
	
	--FightConfig.setConfig("fc_enemy_level", enemyInfo.level)
	--FightConfig.setConfig("fc_enemy_name", enemyInfo.nickname)

    FightConfig.setConfig("fc_jjc_friend_list", friendlistInfo)     --多人赛敌方列表
	FightConfig.setConfig("fc_jjc_enemy_list", enemylistInfo)       --多人赛我方友军列表

	FightConfig.setConfig("rmc_player_init_skill_status", "max_cd")

    local tb = req_ladder_match_battle()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_ladder_match_battle_result"])

end

-- 进入天梯赛
local function handleEnterLadderMatch(tb)
	--进入竞技场出错
	if tb.result ~= 1 then
		--ladderMatchfenzu.resetPlayAni()
		--LayerGameMatch.resetPlayAni()
		--return
	end
	FightDateCache.setData("fd_game_id", tb.game_id)
	FightDateCache.setData("fd_map_data", tb.map)
	FightDateCache.setData("fd_max_floor", #(tb.map))
	--FightDateCache.setData("fd_full_auto_play", true)
	FightConfig.setConfig("fc_battle_map_name", "天梯")
	FightMgr.enter()
end

NetSocket_registerHandler(NetMsgType["msg_notify_ladder_match_battle_result"], notify_ladder_match_battle_result, handleEnterLadderMatch)



