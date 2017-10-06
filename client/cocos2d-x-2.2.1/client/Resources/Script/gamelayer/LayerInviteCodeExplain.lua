
----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-30
-- Brief:	好友邀请码(说明书界面)
----------------------------------------------------------------------
local mLayerRoot = nil	-- 好友邀请码界面根节点
							
LayerInviteCodeExplain = {}
LayerAbstract:extend(LayerInviteCodeExplain)

----------------------------------------------------------------------
LayerInviteCodeExplain.init = function(rootView)
	mLayerRoot = rootView
	
	
end
----------------------------------------------------------------------
LayerInviteCodeExplain.destroy = function()
   mLayerRoot = nil
 
end 
---------------------------------------------------------------------------------------









