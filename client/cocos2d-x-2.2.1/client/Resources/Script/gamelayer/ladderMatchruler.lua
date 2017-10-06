ladderMatchruler = setmetatable({},{__mode='k'})
--ladderMatchReward = {}

ladderMatchruler["jsonFile"] = "ladderMatchruler_1.json"

ladderMatchruler.rootView = nil


ladderMatchruler.init = function(rootView)
	ladderMatchruler.rootView = rootView
end

ladderMatchruler.destroy = function()
    ladderMatchruler.rootView = nil 
end 