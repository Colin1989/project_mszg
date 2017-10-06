
-------------------------------------
--作者：李慧琴
--说明：战斗失败界面
--时间：2014-2-28
-------------------------------------

LayerFightFailed = {
}


local mLayerFightFailedRoot = nil      --当前界面的根节点

LayerAbstract:extend(LayerFightFailed)


--[[
LayerFightFailed.onClick = function(widget)
    local widgetName = widget:getName()
    if "sureBtn" == widgetName then
            --有待更改？？？？？？？？？？？ 弹出金币购买界面
             UIManager.retrunMainLayer("fightOver")
   elseif "cancalBtn" ==  widgetName then
           
           --返回副本群界面（有待更改）
            UIManager.retrunMainLayer("fightOver")
   end
end

]]--



local function btnClicks(type,weight)
   weightName = weight :getName()
   if type == "releaseUp" then
   
      if weightName == "equipStrong" then
           print("装备强化按钮")
              UIManager.retrunMainLayer("fightOver")
      elseif  weightName == "jewelInset" then
               print("宝石镶嵌按钮")
               UIManager.retrunMainLayer("fightOver")

      elseif  weightName == "skillUpgrate" then
                print("技能升级按钮")
               UIManager.retrunMainLayer("fightOver")
      elseif "sureBtn" == weightName then
           print(" 弹出金币购买界面")

             UIManager.retrunMainLayer("fightOver")
      elseif "cancalBtn" ==  weightName then
           
           print("返回副本群界面（有待更改）")
			if CopyDateCache.GameType ==  game_type["common"] then
				UIManager.retrunMainLayer("fightOver")
			elseif CopyDateCache.GameType ==  game_type["push_tower"]  then
				UIManager.pop("UI_FightFailed")		
			FightDateCache.HandleGameSettle (map_settle_result["map_settle_died"])	--推塔死亡 结算方式
				
				--[[
				local tb = {}
				tb.EventType = "endLayer"	--结算类型 推塔结束
				UIManager.push("UI_TowerSettle",tb)]]--
				--UIManager.retrunMainLayer("fightOver")
			end
       end

   end

end

LayerFightFailed.init = function(bundle)

    mLayerFightFailedRoot = UIManager.findLayerByTag("UI_FightFailed")

    local equipStrong = mLayerFightFailedRoot:getWidgetByName("equipStrong")        --装备强化按钮
    tolua.cast(equipStrong,"UIButton")
    equipStrong : registerEventScript(btnClicks)
    local jewelInset = mLayerFightFailedRoot:getWidgetByName("jewelInset")          --宝石镶嵌按钮
    tolua.cast(jewelInset,"UIButton")
    jewelInset : registerEventScript(btnClicks)
    local skillUpgrate = mLayerFightFailedRoot:getWidgetByName("skillUpgrate")      --技能升级按钮
    tolua.cast(skillUpgrate,"UIButton")
    skillUpgrate : registerEventScript(btnClicks)
    

    local coinLabel = mLayerFightFailedRoot:getWidgetByName("coinLabel")            --需要花费金币label
    tolua.cast(coinLabel,"UILabel")
    coinLabel : setText("55555")


    local  sureBtn= mLayerFightFailedRoot:getWidgetByName("sureBtn")   --是按钮（花费金币购买）
    tolua.cast(sureBtn,"UIButton")
    sureBtn : registerEventScript(btnClicks)
    local cancalBtn = mLayerFightFailedRoot:getWidgetByName("cancalBtn")   --否按钮，不花费金币
    tolua.cast(cancalBtn,"UIButton")
    cancalBtn : registerEventScript(btnClicks)

   
   --[[
    setOnClickListenner("sureBtn")
    setOnClickListenner("cancalBtn")
    ]]--

end

