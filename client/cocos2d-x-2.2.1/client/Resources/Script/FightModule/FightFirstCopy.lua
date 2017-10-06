--region FightFirstCopy.lua
--Author : shenl
--Date   : 2015/3/3

--新手副本ID
FIRSTCOPYID = 1  

--初始职业 
FIRSTTYPE = 4

--初始进阶等级
FIRSTADADVANCEDLEVEL = 5

--初始玩家等级--在role_upgrad_tplt内
FIRSTLEVEL = 121

--新手副本初始技能
FIRSTSKILLS ={
    skills=
    {
        [1]=1351,
        [2]=1352,
        [3]=1353,
        [4]=1354
    },
    level=
    {
        [1]=1,
        [2]=1,
        [3]=1,
        [4]=1
    },
    index =1
}


--新手副本地图数据,对话在LocationData内
local MapDate = {result = 1, game_id = 72057594037962944, 
	 gamemaps = {{monster={}, 
				key = 1, start = 28,
				award = {{pos = 22,awardid = 1211}}, 
				trap = {}, 
				barrier = {}, 
				friend = {}, 
				scene = 1036, 
				enemy = {}, 
				boss = {{pos = 8, monsterid = 60, dropout = {}}}, 
				boss_rule = 0}
                }
}


function FightFirstCopy_Enter()
	--if FightDateCache.getData("fd_copy_id") == FIRSTCOPYID then
	--end

	--进入引导关
	FightDateCache.initData()
	FightDateCache.setData("fd_game_mode", 1)
	FightDateCache.setData("fd_copy_id", FIRSTCOPYID)    
	FightDateCache.setData("fd_pass_mode", 2)
	--FightDateCache.setData("fd_round_overlap", copyId ~= 1)
	FightConfig.setConfig("rmc_player_init_skill_status", "done")


	--新怪物提醒
    --[[
	if CopyDateCache.getCopyStatus(copyId) == "doing" then
		local copyInfo = LogicTable.getCopyById(copyId)
		local newMonsterTB = CommonFunc_split(copyInfo.new_monsters, ",")
		FightDateCache.setData("fd_new_monster_tb", newMonsterTB)
	end
    ]]--

    local tb = MapDate
	FightDateCache.setData("fd_game_id", tb.game_id)
	FightDateCache.setData("fd_map_data", tb.gamemaps)
	FightDateCache.setData("fd_max_floor", #(tb.gamemaps))
	FightConfig.setConfig("fc_battle_map_name", "新的阴谋")
	FightMgr.enter()
end


--endregion
