----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-26
-- 描述：英雄界面
----------------------------------------------------------------------
local mLayerHeroRoot = nil
LayerHero = {
}
LayerAbstract:extend(LayerHero)

LayerHero.onClick  = function(weight)
	local weightName = weight:getName()
--		local weightName = weight:getName()
	if weightName == "Button_back" then
		--UIManager.pop("UI_Hero")
		UIManager.pop()
	elseif weightName == "Button_skill1" then
		UIManager.push("UI_ComfirmDialog")
	end
	
end

local function 	initButtonEvent()
	setOnClickListenner("Button_back")
	setOnClickListenner("Button_skill1")	
end
-- onCreate
LayerHero.init = function (bundle)
	mLayerHeroRoot = UIManager.findLayerByTag("UI_Hero")
	initButtonEvent()	
end

--[[LayerHero.getLayerRoot = function()
  return mLayerHeroRoot
end--]]

