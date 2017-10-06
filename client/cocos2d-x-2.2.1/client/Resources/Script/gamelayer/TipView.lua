----------------------------------------------------------------------
-- 作者: jaron
-- 日期: 2013-3-31
-- 描述: 点击反馈视图
----------------------------------------------------------------------
TipView = {}
local mRootView = nil		-- 触摸层
local mBeginPos = ccp(0, 0)

-- 加载资源
local function loadResource()
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dianjixiaoguo_01.png")
	if nil == frame then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("dianjixiaoguo.plist")
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("dianjixiaoguo.plist")
	end
end

-- 显示点击提示
local function showClickTip(pos)
	if nil == mRootView then
		return
	end
	-- 判断当前是否有有效显示的界面
	local function validShow()
		if true == UIManager.isAllUIEnabled() then
			return true
		end
		local topUI = UIManager.getTopLayer()
		if nil == topUI then
			return false
		end
		local root = topUI:getRootWidget()
		if nil == root then
			return false
		end
		return root:isEnabled()
	end
	if false == validShow() then
		return
	end
	loadResource()
	--local tipSprite = CCParticleSystemQuad:create("click_screen.plist")
	local tipSprite = createAnimation_signal("dianjixiaoguo_%02d.png", 18, 0.03)
	tipSprite:setPosition(pos)
	mRootView:addChild(tipSprite)
end

-- 触摸层事件回调
local function onTouch(eventType, x, y)
	if "began" == eventType then
		mBeginPos = ccp(x, y)
		return true
	elseif "moved" == eventType then
	elseif "ended" == eventType then
		local pos = ccp(x, y)
		if ccpDistance(pos, mBeginPos) <= 10 then
			showClickTip(pos)
		end
	else
	end
end

-- 创建点击反馈视图
function TipView.create()
	if nil ~= mRootView then
		return
	end
	loadResource()
	mRootView = CCLayer:create()
	mRootView:setTouchEnabled(true)
	mRootView:registerScriptTouchHandler(onTouch, false, -2147483650, false)
	g_rootNode:addChild(mRootView, 1999, 1999)
end

-- 清除点击反馈视图
function TipView.cleanup()
	if nil == mRootView then
		return
	end
	mRootView:removeFromParentAndCleanup(true)
	mRootView = nil
end

