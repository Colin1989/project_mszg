----三星奖励

layerthreedesc = {}


local function setView()
   local copyInfo = LogicTable.getCopyById(FightDateCache.getData("fd_copy_id"))

   local three_need_life = mLayerthreedescRoot:getWidgetByName("three_need_life")
   tolua.cast(three_need_life, "UILabel")
   three_need_life:setText(copyInfo.min_life_percent)


   local three_need_round = mLayerthreedescRoot:getWidgetByName("three_need_round")
   tolua.cast(three_need_round, "UILabel")
   three_need_round:setText(copyInfo.min_cost_round)


   local Label_life = mLayerthreedescRoot:getWidgetByName("Label_life")
   tolua.cast(Label_life, "UILabel")

   local curLife,maxLife = RoleMgr.getPlayerLife()

   local lifePrecent =  curLife/maxLife

   local final = math.floor(lifePrecent*100)
   Label_life:setText( string.format("生命：%d%%",final) )

   local Label_monster = mLayerthreedescRoot:getWidgetByName("Label_monster")
   tolua.cast(Label_monster, "UILabel")
   Label_monster:setText(string.format("怪物：%d/%d",FightDateCache.getData("fd_killed_monster_count"),FightDateCache.getData("fd_stage_total_monster")))

   local Label_leftround = mLayerthreedescRoot:getWidgetByName("Label_leftround")   --剩余回合
   tolua.cast(Label_leftround, "UILabel")
   local leftRound =  tonumber(copyInfo.min_cost_round) - FightDateCache.getData("fb_round_count")

   if leftRound < 0 then leftRound = 0 end 
   Label_leftround:setText(string.format("剩余回合：%d",leftRound))



end 

function layerthreedesc.init ()
    mLayerthreedescRoot = UIManager.findLayerByTag("UI_threedesc")
    setView()
    setOnClickListenner("canclebtn")
end 


function layerthreedesc.destroy()

    mLayerthreedescRoot = nil
end 


layerthreedesc.onClick = function (weight)
	local weightName = weight :getName()
    if weightName == "canclebtn" then
		UIManager.pop("UI_threedesc")
	end 
end 



--strr=string.format("生命：%d%%",99)

