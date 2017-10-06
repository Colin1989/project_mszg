
-------------------------------------
--作者：shenl
--说明：竞技场挑战失败界面
--时间：2014-3-19
-------------------------------------

LayerJJcFail = {
}


local mLayerJJCFailedRoot = nil      --当前界面的根节点

LayerAbstract:extend(LayerJJcFail)



LayerJJcFail.onClick = function (weight)
	local weightName = weight :getName()
    if weightName == "equipup" then
           print("装备强化按钮")
    elseif weightName == "gemuse" then
           print("宝石镶嵌按钮")
    elseif weightName == "skillup" then
           print("技能升级按钮")
    elseif "jjc_fail_sure" == weightName then
			UIManager.retrunMainLayer("init")
    end
end

LayerJJcFail.init = function(tb)
	
    mLayerJJCFailedRoot = UIManager.findLayerByTag("UI_JJCFailed")

	local getrongyu = mLayerJJCFailedRoot:getWidgetByName("Label_44")            --获得荣誉
    tolua.cast(getrongyu,"UILabel")
    getrongyu : setText(tostring(tb.honour ))
	
	local getscore = mLayerJJCFailedRoot:getWidgetByName("Label_44_0")            --获得积分
    tolua.cast(getscore,"UILabel")
    getscore : setText(tostring(tb.point ))

	setOnClickListenner("equipup")--装备强化按钮
	setOnClickListenner("gemuse")--宝石镶嵌按钮
    setOnClickListenner("skillup")--技能升级按钮
    setOnClickListenner("jjc_fail_sure")


end

