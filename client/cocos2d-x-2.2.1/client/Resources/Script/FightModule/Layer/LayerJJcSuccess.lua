
-------------------------------------
--作者：shenl
--说明：竞技场挑战胜利界面
--时间：2014-3-19
-------------------------------------

LayerJJcSuccess = {
}

LayerAbstract:extend(LayerJJcSuccess)
local mLayerJJCSuccessdRoot = nil      --当前界面的根节点
local zone_nameView = nil

--预先加载32图
function LayerJJcSuccess.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_01.png")
end

LayerJJcSuccess.setZoneName = function(name)
	if zone_nameView ~= nil then 
		zone_nameView:setText(string.format("当前组别为：%s",name))
	end
end 

LayerJJcSuccess.onClick = function (weight)
   local weightName = weight:getName()
    if weightName == "cancle_btn" then
		UIManager.pop("UI_JJCSuccess")
		FightMgr.onExit()
		UIManager.retrunMain(LayerGameRank, true)
		FightMgr.cleanup()
     end
end

function LayerJJcSuccess.destroy()
	local root = UIManager.findLayerByTag("UI_FightReward")
	if root ~= nil then
		root:removeFromParentAndCleanup(true)
		root = nil
	end
	mLayerJJCSuccessdRoot = nil
	zone_nameView = nil
end




LayerJJcSuccess.init = function(tb)
    mLayerJJCSuccessdRoot = UIManager.findLayerByTag("UI_JJCSuccess")
	
	local honorImage = mLayerJJCSuccessdRoot:getWidgetByName("flag1")	--  荣誉或分组积分图标
	tolua.cast(honorImage,"UIImageView") 
	
	local zhanjiImage = mLayerJJCSuccessdRoot:getWidgetByName("flag2")	--  战绩图标
	tolua.cast(zhanjiImage,"UIImageView")
	
	local moneyTest = mLayerJJCSuccessdRoot:getWidgetByName("realrank")--  排名
	tolua.cast(moneyTest,"UILabelAtlas") 

	local getrongyu = mLayerJJCSuccessdRoot:getWidgetByName("getrongyu")            --获得荣誉
    tolua.cast(getrongyu,"UILabel")
	getrongyu : setText(tostring(tb.coins))
	
	local getscore = mLayerJJCSuccessdRoot:getWidgetByName("getscore")            --获得积分
    tolua.cast(getscore,"UILabel")
	getscore : setText(tostring(tb.point))
	
	local test3 = mLayerJJCSuccessdRoot:getWidgetByName("zone_name")
	local moneyTest2 = mLayerJJCSuccessdRoot:getWidgetByName("ImageView_34")--  连胜次数
	--游戏模式,1普通关卡,2推塔,3竞技场排位赛,4训练比赛,5天梯赛
	local gameMode = FightDateCache.getData("fd_game_mode")
	
	print("--游戏模式",gameMode,type(gameMode))
	
	if  gameMode == 3 then  	
        moneyTest2:setVisible(true)		moneyTest:setStringValue(tonumber(LayerGameRank.getRank()))
		LayerGameRank.setChallengeMsg(true)
		test3:setVisible(false)

		honorImage:setVisible(true)
		zhanjiImage:setVisible(true)
	elseif gameMode == 4 then 
		test3:setVisible(false)
		local moneyTest1 = mLayerJJCSuccessdRoot:getWidgetByName("ImageView_29")
		moneyTest1:setVisible(false)
		
		tolua.cast(moneyTest2,"UIImageView") 
		moneyTest2:loadTexture("Text_xunliansai.png")
		moneyTest2:setVisible(true)
		moneyTest:setStringValue(tonumber(LayerGameTrain.getSuccessTimes() + 1))
		
		honorImage:setVisible(true)
		zhanjiImage:setVisible(true)
	elseif gameMode == 5 then 
        --[[
		local moneyTest2 = mLayerJJCSuccessdRoot:getWidgetByName("ImageView_34")
		moneyTest2:setVisible(false)

		test3:setVisible(true)
		tolua.cast(test3,"UILabel") 
		zone_nameView = test3 
			
		local data1 = LogicTable.getRewardItemRow(tb.awards[1].temp_id)
		local data2 = LogicTable.getRewardItemRow(tb.awards[2].temp_id)

		local data1Name = LogicTable.getRewardTypeDate(data1.type).name
		local data2Name = LogicTable.getRewardTypeDate(data2.type).name

		print("data1.type--------------------->",data1.type,data2.type)
		local reWardDesp1 = mLayerJJCSuccessdRoot:getWidgetByName("Label_30")
		tolua.cast(reWardDesp1,"UILabel")
		reWardDesp1:setText("获得"..data1Name)
		
		local reWardDesp2 = mLayerJJCSuccessdRoot:getWidgetByName("Label_31")
		tolua.cast(reWardDesp2,"UILabel")
		reWardDesp2:setText("获得"..data2Name)
		
		getrongyu : setText(tostring(tb.awards[1].amount ))
		getscore : setText(tostring(tb.awards[2].amount ))
		
		honorImage:setVisible(false)
		zhanjiImage:setVisible(true)
        ]]--
	end 
	

	
    setOnClickListenner("cancle_btn")

end