----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	玩家全屏特效基类
----------------------------------------------------

EffectPlayerCast = class(Effect)

local m_priority = -200

--构造
function EffectPlayerCast:ctor()
end

local function onTouch(eventType, x, y)
	if eventType == "began" then
		return true
	end
end

function EffectPlayerCast:createMask(customerColor)
	--背景遮罩
    if customerColor == nil then 
        customerColor = ccc4(0, 0, 0, 64)
    end 

	local mask = CCLayerColor:create(customerColor)
	--mask:setColor(ccc3(0, 0, 0))
	mask:registerScriptTouchHandler(onTouch, false, m_priority, true)
	mask:setTouchEnabled(true)
	return mask
end














