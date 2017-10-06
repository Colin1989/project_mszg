
-------------------------------------
--作者：李慧琴
--说明：副本提示界面
--时间：2014-2-19
-------------------------------------
LayerCopyTips = {
}
local mLayerCopyTipsRoot = nil
LayerAbstract:extend(LayerCopyTips)



local id = nil          --保存当前的副本id
local mCopyRes_id = nil 	--保存当前副本资源id

--点击tips进入游戏
local function enterGame(type,widget)
  if type == "releaseUp" then
	CopyDateCache.GameType = game_type["common"] 
    local tb = req_enter_game()
    tb.id = ModelPlayer.getId()
    tb.gametype = CopyDateCache.GameType      -- 1 为进入主线副本
    tb.copy_id = id
    FightDateCache.curFB_ID = tb.copy_id
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_enter_game"])
	--LayerCopyTips_EnterGame(game_type["common"])
   end
end

--获取进入副本资源ID
LayerCopyTips.getCurCopyRes_id = function()
	return mCopyRes_id
end

LayerCopyTips.setCurCopyRes_id = function(Res_id)
	mCopyRes_id = Res_id
end
--[[
--判断体力是否充足和精英副本打通次数（需要设置在config中，有待更改？？？？？？？？？？？？？）
local function judgePowerATimes(tb)
    local power = ModelPlayer.getPower_hp()

         if tostring(power) < tb.need_power then
             Toast.show(GameString.get("TLBZ"))
         elseif tb.times_limit ~= tostring(0) and  tb[2] ~= nil  and  tb[2].pass_times > tostring(0) then
        -----------------------   每天晚上12点清零的设置？？？？？？
             Toast.show("该精英副本，每天只能打通一次")
         end


end

]]--

--判断体力和精英副本的点击次数，显示系统消息

function Handle_req_enterGamee(resp)
      if resp.result == enter_game_result["enter_game_failed"] then
             Toast.show("该关卡，尚未解锁")
          --   judgePowerATimes(tb)
      elseif resp.result == enter_game_result["enter_game_success"] then
            FightDateCache.initGameDate(resp.gamemaps,resp.game_id)     --初始化战斗数据
            UIManager.destroyAllUI()
            StartLoading()
			-- 显示援助 add by fjut 2014-03-20
			--LayerMain.switchLayer(LayerAssistance)
			-- add end
      elseif resp.result == enter_game_result["enter_game_unlogin"] then
            print("no register")
      end
end




----根据品质，设置字体的rgb值
local function setRGB(index)
    if tonumber(index) == quality_type["white"] then
         return   ccc3(255,255,255)
    elseif tonumber(index) == quality_type["green"] then
       return   ccc3(114,255,0)
    elseif tonumber(index) == quality_type["blue"] then
         return   ccc3(0,187,255)
    elseif tonumber(index) == quality_type["purple"] then
      return   ccc3(175,20,255)
    elseif index == quality_type["orange"] then
       return    ccc3(255,144,0)
    end

end

--设置掉落
local function setDrop(dropitems)

      for k,v in pairs(dropitems) do
       if v ~=  tostring(-1) then
             local row = LogicTable.getItemById(v)  ----通过id，找物品表，获取对应的物品名
             if tonumber(row.type) == 1 then             -- 判断是掉落的装备 --判定是--1-装备 2-符文 3-宝石 4-道具
                   local equip = LogicTable.getEquipById(v)
                   local  equipStr = LogicTable.getEquipTypeByType(equip.type)
                     local  dropEquipt =  mLayerCopyTipsRoot:getWidgetByName(string.format("Label_%d",k+32))
                     local  dropEquipType = mLayerCopyTipsRoot:getWidgetByName(string.format("Label_%d_0",k+32))
                     local dropPanel = mLayerCopyTipsRoot:getWidgetByName("Panel_52")    --整个的掉落panel
                     tolua.cast(dropPanel,"UILayout")
                     tolua.cast(dropEquipt,"UILabel")
                     tolua.cast(dropEquipType,"UILabel")
                     dropPanel:setVisible(true)
                     dropEquipt:setVisible(true)
                     dropEquipType:setVisible(true)
                     dropEquipt:setText(row.name)
                     dropEquipt:setColor(setRGB(row.quality))
                     dropEquipType:setText(equipStr)
                     dropEquipType:setColor(setRGB(row.quality))
             end
        end
   end


end


--初始化界面
local function  initInfo()
     local fbAll= LogicTable.getGameAllFB()                --获取副本的XML表
     for key,value in pairs(fbAll) do
        if id == value.id  then
           local  fbName = mLayerCopyTipsRoot:getWidgetByName("Label_24")--设置副本名
           tolua.cast(fbName,"UILabel")
           fbName:setText(value.name)
            local fbDesc = mLayerCopyTipsRoot:getWidgetByName("Label_25") --设置副本描述
           tolua.cast(fbDesc,"UILabel")
           fbDesc:setText(value.describe)
            local fbReward = mLayerCopyTipsRoot:getWidgetByName("Label_27")--设置奖励
           tolua.cast(fbReward,"UILabel")
           fbReward:setText(value.award)
            local fbExp = mLayerCopyTipsRoot:getWidgetByName("Label_29")--设置经验
           tolua.cast(fbExp,"UILabel")
           fbExp:setText(value.exp)
            local fbGold = mLayerCopyTipsRoot:getWidgetByName("Label_31")--设置金币
           tolua.cast(fbGold,"UILabel")
           fbGold:setText(value.gold)
           
           setDrop(value.dropitems)
			mCopyRes_id = value.icon + 0
        end
  end



end
LayerCopyTips.onClick = function(weight)

	local weightName = weight:getName()
	if weightName == "Button_53" then  --关闭按钮
		 UIManager.pop("UI_CopyTips")
		 --UIManager.pop()
	end

end



----要传入参数,当前的副本id,
LayerCopyTips.init = function(bundle)
    mLayerCopyTipsRoot=UIManager.findLayerByTag("UI_CopyTips")
    id = bundle
	FightDateCache.setcurId(id)
     initInfo()

    local  comeIn = mLayerCopyTipsRoot:getWidgetByName("Button_34")      --点击进入按钮
    tolua.cast(comeIn,"UIButton")
    comeIn:registerEventScript(enterGame)


	setOnClickListenner("Button_53")
      
end

NetSocket_registerHandler(NetMsgType["msg_notify_enter_game"], notify_enter_game(), Handle_req_enterGamee)      -- 注册监听












