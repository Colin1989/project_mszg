
-------------------------------------
--���ߣ�shenl
--˵������������սʧ�ܽ���
--ʱ�䣺2014-3-19
-------------------------------------

LayerJJcFail = {
}


local mLayerJJCFailedRoot = nil      --��ǰ����ĸ��ڵ�

LayerAbstract:extend(LayerJJcFail)



LayerJJcFail.onClick = function (weight)
	local weightName = weight :getName()
    if weightName == "equipup" then
           print("װ��ǿ����ť")
    elseif weightName == "gemuse" then
           print("��ʯ��Ƕ��ť")
    elseif weightName == "skillup" then
           print("����������ť")
    elseif "jjc_fail_sure" == weightName then
			UIManager.retrunMainLayer("init")
    end
end

LayerJJcFail.init = function(tb)
	
    mLayerJJCFailedRoot = UIManager.findLayerByTag("UI_JJCFailed")

	local getrongyu = mLayerJJCFailedRoot:getWidgetByName("Label_44")            --�������
    tolua.cast(getrongyu,"UILabel")
    getrongyu : setText(tostring(tb.honour ))
	
	local getscore = mLayerJJCFailedRoot:getWidgetByName("Label_44_0")            --��û���
    tolua.cast(getscore,"UILabel")
    getscore : setText(tostring(tb.point ))

	setOnClickListenner("equipup")--װ��ǿ����ť
	setOnClickListenner("gemuse")--��ʯ��Ƕ��ť
    setOnClickListenner("skillup")--����������ť
    setOnClickListenner("jjc_fail_sure")


end

