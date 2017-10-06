
-------------------------------------
--作者：shenl
--说明：竞技场挑战胜利界面
--时间：2014-3-19
-------------------------------------

LayerJJcSuccess = {
}

LayerAbstract:extend(LayerJJcSuccess)
local mLayerJJCSuccessdRoot = nil      --当前界面的根节点

LayerAbstract:extend(LayerJJcFail)

LayerJJcSuccess.onClick = function (weight)
   local weightName = weight:getName()
    if weightName == "cancle_btn" then
		UIManager.retrunMainLayer("init")
     end

end

LayerJJcSuccess.init = function(tb)
    mLayerJJCSuccessdRoot = UIManager.findLayerByTag("UI_JJCSuccess")

	local moneyTest = mLayerJJCSuccessdRoot:getWidgetByName("realrank")--  排名
	tolua.cast(moneyTest,"UILabelAtlas") 
	moneyTest:setStringValue(tonumber(LayerGameRank.getRank()))
	
	local getrongyu = mLayerJJCSuccessdRoot:getWidgetByName("getrongyu")            --获得荣誉
    tolua.cast(getrongyu,"UILabel")
	getrongyu : setText(tostring(tb.honour ))
	
	local getscore = mLayerJJCSuccessdRoot:getWidgetByName("getscore")            --获得积分
    tolua.cast(getscore,"UILabel")
	getscore : setText(tostring(tb.point ))
	
    setOnClickListenner("cancle_btn")
end