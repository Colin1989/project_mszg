
-------------------------------------
--���ߣ�shenl
--˵������������սʤ������
--ʱ�䣺2014-3-19
-------------------------------------

LayerJJcSuccess = {
}

LayerAbstract:extend(LayerJJcSuccess)
local mLayerJJCSuccessdRoot = nil      --��ǰ����ĸ��ڵ�

LayerAbstract:extend(LayerJJcFail)

LayerJJcSuccess.onClick = function (weight)
   local weightName = weight:getName()
    if weightName == "cancle_btn" then
		UIManager.retrunMainLayer("init")
     end

end

LayerJJcSuccess.init = function(tb)
    mLayerJJCSuccessdRoot = UIManager.findLayerByTag("UI_JJCSuccess")

	local moneyTest = mLayerJJCSuccessdRoot:getWidgetByName("realrank")--  ����
	tolua.cast(moneyTest,"UILabelAtlas") 
	moneyTest:setStringValue(tonumber(LayerGameRank.getRank()))
	
	local getrongyu = mLayerJJCSuccessdRoot:getWidgetByName("getrongyu")            --�������
    tolua.cast(getrongyu,"UILabel")
	getrongyu : setText(tostring(tb.honour ))
	
	local getscore = mLayerJJCSuccessdRoot:getWidgetByName("getscore")            --��û���
    tolua.cast(getscore,"UILabel")
	getscore : setText(tostring(tb.point ))
	
    setOnClickListenner("cancle_btn")
end