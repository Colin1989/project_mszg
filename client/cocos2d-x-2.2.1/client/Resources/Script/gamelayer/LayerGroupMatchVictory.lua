--region LayerGroupMatchVictory.lua
--Author : shenl
--Date   : 2015/1/21
LayerGroupMatchVictory={}
LayerAbstract:extend(LayerGroupMatchVictory)

local mLayerFightOverRoot = nil


local function setItemIcon(reward_ids,reward_amounts)

	local scrollView = mLayerFightOverRoot:getWidgetByName("reward_content")  	--显示战斗的副本名字
    tolua.cast(scrollView,"UIScrollView")
	local delay = 0.7
	local scrollItem ={}
	for k,id in pairs(reward_ids) do
        local ItemInfo = {}
        ItemInfo.id = id 
        ItemInfo.amount = reward_amounts[k]
		local icon,effectNode,boxSprite = LayerFightOver.setOpenBoxAction (scrollItem,k,ItemInfo.id)
		LayerFightOver.openBox(delay, icon, ItemInfo,effectNode, boxSprite)	
		delay = delay + 0.25
	end
	setAdapterGridView(scrollView,scrollItem,3,0)
end


function LayerGroupMatchVictory.destroy()
	local root = UIManager.findLayerByTag("UI_GroupMatchVictory")
	if root ~= nil then
		root:removeFromParentAndCleanup(true)
		root = nil
	end
	mLayerFightOverRoot = nil
end


LayerGroupMatchVictory.onClick = function(widget)
    local widgetName = widget:getName()
    if "return_button" == widgetName then  					-- 确认键
        UIManager.pop("UI_GroupMatchVictory")
		FightMgr.onExit()
		UIManager.retrunMain(LayerGameRank, true)
		FightMgr.cleanup()
    end
end


LayerGroupMatchVictory.init = function(tb)
	mLayerFightOverRoot = UIManager.findLayerByTag("UI_GroupMatchVictory")
    setOnClickListenner("return_button")
    --tb.reward_ids = {}
    --tb.reward_amounts = {}
    setItemIcon(tb.reward_ids,tb.reward_amounts)
end 
--endregion 
