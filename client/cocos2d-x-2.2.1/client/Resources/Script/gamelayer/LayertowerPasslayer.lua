LayertowerPasslayer = {}

--UIName = "UI_Towerpasslayer"

local mLayertowerPasslayerRoot = nil


LayerAbstract:extend(LayertowerPasslayer)

--预先加载32图
function LayertowerPasslayer.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_01.png")
end

LayertowerPasslayer.init = function(bundle)
	local awardsTb = bundle.awards
	
	for k,v in pairs(awardsTb) do
		print ("单关结算：",k,v)	
	end 

	
	mLayertowerPasslayerRoot = UIManager.findLayerByTag("UI_Towerpasslayer")
	
	--pass_layer number	
	local pass_layer = mLayertowerPasslayerRoot:getWidgetByName("pass_layer")-- 等级
	tolua.cast(pass_layer,"UILabelAtlas")
	
	FightConfig.pushTowerComplete(awardsTb.temp_id, bundle.gold, bundle.exp)
	
	local cache = FightConfig.getConfig("fc_push_tower_cache_data")
	pass_layer:setStringValue(string.format("%d", cache.hasPassFloorCnt))
	
	
	local pass_layer = mLayertowerPasslayerRoot:getWidgetByName("passlayergoldnum")-- 获得金币
	tolua.cast(pass_layer,"UILabel") 
	pass_layer:setText(string.format("%d",bundle.gold))
	
	FightDateCache.gainCoins(bundle.gold)
	LayerGameUI.updateCoins(bundle.gold)
	
	--button
	setOnClickListenner("passlayer_sure")
end


LayertowerPasslayer.onClick  = function(weight)
	local weightName = weight:getName()
	--退出按钮
	if weightName == "passlayer_sure" then
		UIManager.pop("UI_Towerpasslayer")
		FightMgr.nextFloorCleanup()
		FightLoading.start()
	end

end
