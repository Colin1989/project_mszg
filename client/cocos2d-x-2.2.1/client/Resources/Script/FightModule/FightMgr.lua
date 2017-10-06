----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-03-31
-- 描述：战斗模块管理
----------------------------------------------------------------------

FightMgr = {}

local function localPrint(...)
	--if true then return end
	lewisPrint("FightMgr", ...)
end

--初始化地图数据,与资源
function FightMgr.initMap()
	local mapVec = FightDateCache.getData("fd_map_data")
	local floorIdx = FightDateCache.getData("fd_floor_index")
	local map = mapVec[floorIdx]
	if map == nil then
		localPrint("invalid map data")
		return
	end
	
	FightResLoader.release()
	FightResLoader.preloadCommon()
	FightResLoader.preloadPlayerRes(ModelPlayer.getRoleType())
	local gameMode = FightDateCache.getData("fd_game_mode")
	if gameMode == 1 then		
		local tbSkill = AssistanceLogic.getDonorInfo()
		if tbSkill ~= nil then
			FightResLoader.perLoadFriendRes(tbSkill.role_type, tbSkill.sculpture.temp_id)
		end
	end
	FightDateCache.setData("fd_key_count", 0)
	FightDateCache.setData("fd_floor_total_monster", #map.monster+ #map.boss )
	FightDateCache.setData("fd_floor_killed_monster", 0)
    FightDateCache.setData("fd_boss_rule_id", map.boss_rule)
	GridMgr.parse(map)
	GridMgr.create()
	
	FightDateCache.setData("fd_map_scene_id", map.scene)
	FightResLoader.preloadMapEffectRes(map.scene)
	
	--SpecialSkill.preloadSummonMonster()
	FightResLoader.releaseRes()
end

--玩家被K.O
function FightMgr.playerKnockout()
	local gameMode = FightDateCache.getData("fd_game_mode")
	if gameMode == 3 or gameMode == 4 then	--竞技场挑战失败
		FightEnd.gameSettle(2)
    elseif  gameMode == 5  then 
        if FightMgr.IsFriendBeKillAllIn3V3() then 
            FightEnd.gameSettle(2)
        elseif RoleMgr.isDoubleLeaderBeKill()  then  
            GridMgr.forceOpenAllGrid()
        end 
        CCDirector:sharedDirector():getActionManager():setSpeed(2.0)
	else
		UIManager.push("UI_FightFailed")-- 进入战斗失败界面
	end
end

--玩家复活
function FightMgr.playerRespawn()
	FightDateCache.updateData("fd_respawn_count", 1)
	RoleMgr.playerRespawn()
	FightDateCache.setData("fd_game_over", false)
end

--竞技场场敌人被K.O
function FightMgr.enemyKnockout()
    local gameMode = FightDateCache.getData("fd_game_mode")
	if gameMode == 3 or gameMode == 4  then	
        BattleMgr.flush()
	    AIMgr.stop()
	    FightEnd.gameSettle(1)
    elseif gameMode == 5 then
        --print("杀光了？--------------------竞技场结算",FightMgr.IsKillAllIn3V3())
        if FightMgr.IsKillAllIn3V3() then 
            BattleMgr.flush()
	        AIMgr.stop()
            FightEnd.gameSettle(1)
        elseif FightMgr.IsFriendBeKillAllIn3V3() then 
            FightEnd.gameSettle(2)
        elseif RoleMgr.isDoubleLeaderBeKill()  then  
            GridMgr.forceOpenAllGrid()
        end 
    end


end


--3V3 是否所有人都被杀 
function FightMgr.IsKillAllIn3V3()
    local pRet = false 
    local kill_enemy_number =  RoleMgr.getConfig("kill_enemy_number") 
    if kill_enemy_number >= 3 then 
        pRet = true 
    end 
    return pRet
end 


--3V3 是否所有友方人都被杀 
function FightMgr.IsFriendBeKillAllIn3V3()
    local pRet = false 
    local killFriendNumber =  RoleMgr.getConfig("kill_friend_number") 
    if killFriendNumber >= 3 then 
        pRet = true 
    end 
    return pRet
end 


--下一回合
function FightMgr.nextRound()
	FightDateCache.updateData("fd_total_round", 1)
	FightDateCache.updateData("fd_rest_round", -1)
	FightDateCache.updateData("fb_round_count", 1)
	local fdGameMode = FightDateCache.getData("fd_game_mode")
	if fdGameMode == 1 then
		LayerGameUI.updateUsedRound()
	elseif fdGameMode == 2 then
		FightMgr.updatePushTower()
	elseif fdGameMode == 6 then
		LayerGameUI.updateAcivityUsedRound()
	end
end

--更新推塔数据
function FightMgr.updatePushTower()
	LayerGameUI.updateRestRound()	--更新回合数
	if FightDateCache.getData("fd_rest_round") <= 0 then--回合数用完判定
		AIMgr.reset()
		FightEnd.pushTowerRunOutOfRound()
	end
end

function FightMgr.nextFloorCleanup()
	EffectMgr.reset()
	GridMgr.reset()
	RoleMgr.reset()
	AIMgr.reset()
	FightAnimationMgr.cleanup()
	g_sceneRoot:removeAllChildrenWithCleanup(true)
	g_sceneRoot:setVisible(false)
end

--进入到下一层
function FightMgr.nextFloor()
	BattleMgr.flush()
	local floorIdx = FightDateCache.getData("fd_floor_index")
	local maxIdx = FightDateCache.getData("fd_max_floor")
	floorIdx = floorIdx + 1
	FightDateCache.setData("fd_floor_index", floorIdx)
	if floorIdx <= maxIdx then
		FightDateCache.setData("fd_game_start", false)
		FightMgr.nextFloorCleanup()
		FightLoading.start()--FIXME切场动画
		return
	end
    AIMgr.stop()

    --战斗结算对话
     if FightDateCache.getData("fd_game_mode") == 1 then 
		local indexInfo = {
		  index = 2,
		  callback = FightEnd.gameSettle,
		  param = 1,
		}
		BDcontroller:viewDidLoad(FightDateCache.getData("fd_copy_id"),indexInfo)   
		return 
    end 

	
	FightEnd.gameSettle(1)
end

--进入游戏,全局初始化
function FightMgr.enter()
	AIMgr.init()
	GameScene.init()
	SkillMgr.init()
	GridMgr.init()
	BattleMgr.init()
	EffectMgr.init()
	
	UIManager.setAllUIEnabled(false)
	FightResLoader.init()
	RoleMgr.init()
	GameScene.createGameUI()
	FightLoading.start()
	
	--计算关卡总怪物数
	local total = 0
	local mapVec = FightDateCache.getData("fd_map_data")
	for key, map in pairs(mapVec) do
		total = total + #(map.monster)
	end
	FightDateCache.setData("fd_stage_total_monster", total)
end

--开始游戏,创建视图
function FightMgr.start()
	if FightDateCache.getData("fd_init_global") == false then
		FightDateCache.setData("fd_init_global", true)
		GameScene.afterLoad()
	end
	GameScene.createMapScene()
end

--开始战斗
function FightMgr.battleStart()
	LayerGameUI.updateRealCoins()
	GuideMgr.onBattle(FightDateCache.getData("fd_copy_id"))
	
	AIMgr.recover()
	LayerGameUI.registerEvent()
	if FightDateCache.getData("fd_full_auto_play") then
		AIControllView.onTrigger()
	end
	local floorIdx = FightDateCache.getData("fd_floor_index")
	if floorIdx > 1 then
        GridMgr.run()
		return
	end
    --战斗对话
    if FightDateCache.getData("fd_game_mode") == 1 then
        local indexInfo = {
          index = 1,--开始时触发
          callback = GridMgr.run,
          param = nil,
        }        BDcontroller:viewDidLoad(FightDateCache.getData("fd_copy_id"),indexInfo) 
    else 
        GridMgr.run() 
    end 
end

--是否只能自动操作
function FightMgr.isOnlyAutoPlay()
	if FightDateCache.getData("fd_full_auto_play") then
		localPrint("untouchable with case: fd_full_auto_play")
		return true
	end
	return false
end

--战斗退出
function FightMgr.onExit()
	GridMgr.cleanup()
	AIMgr.cleanup()
	RoleMgr.cleanup()
	EffectMgr.cleanup()
	FightAnimationMgr.cleanup()
	FightLoading.onExit()
	GameScene.cleanup()
end

--清除资源
function FightMgr.cleanup()
end

--是否可以点击
function FightMgr.isOnControll()


    if FightDateCache.getData("fd_global_lockevent") then 
        cclog("isOnControll:fd_global_lockevent")
        return false
    end 

	if FightDateCache.getData("fd_player_knockout") then
        cclog("isOnControll:fd_player_knockout")
		return false
	end
	if FightDateCache.getData("fd_enemy_knockout") then
        cclog("isOnControll:fd_enemy_knockout")
		return false
	end
	if NetSendLoadLayer.isWaitMessage() == true then
        cclog("isOnControll:isWaitMessage")
		return false
	end
	if UIManager.getLayerCount() > 1 and  UIManager.isAllUIEnabled() == false then 
		return false
	end
	return true
end

--玩家是否不可操作
function FightMgr.isPlayerOnControll()
	if FightDateCache.getData("fd_full_auto_play") then
		return false
	end
	if FightMgr.isOnControll() == false then
		return false
	end
	return true
end

