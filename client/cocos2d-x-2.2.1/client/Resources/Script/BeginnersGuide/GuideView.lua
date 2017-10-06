----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：新手引导视图
----------------------------------------------------------------------
GuideView = {}

local mRootView 		= nil		-- 新手触摸层
local mClipLayer		= nil		-- 灰色背景
local mHighLight		= nil		-- 高亮框
local mFinger 			= nil		-- 手指
local mHelper 			= nil		-- 助手头像
local mDialogBg			= nil		-- 对话框
local mIsTalking		= false		-- 是否正在播放对话框动画
local mLockState		= 0 		-- 强制引导(1.区域内按钮判定;2.全屏点击);非强制引导(3.全屏点击;4不做屏蔽层,事件直接穿透)

local mBattleDialogBg         = nil       -- 战斗对话

-- 对话框里面的小图标
local mDialogImageVec = 
{
	"guide_img_01.png",
	"guide_img_02.png",
	"guide_img_03.png",
	"guide_img_04.png",
	"guide_img_05.png",
	"guide_img_06.png",
	"guide_img_07.png",
}

-- 触摸层事件回调
local function onTouch(eventType, x, y)
	if "began" == eventType then
		if mIsTalking or NetSendLoadLayer.isWaitMessage() then	-- 正在播放对话框动画或转圈,则不处理事件
			return true
		end
		GuideMgr.onMessage("on_touch")
		if 1 == mLockState then
			local rect = mHighLight:boundingBox()
			local clickRect = CCRectMake(rect.origin.x+(rect.size.width*0.2)/2, rect.origin.y+(rect.size.height*0.2)/2, rect.size.width*0.8, rect.size.height*0.8)
			if clickRect:containsPoint(ccp(x, y)) then	-- 点击高亮框区域,事件透给下一层
				return false
			end
			return true
		elseif 2 == mLockState then
			return true
		elseif 3 == mLockState then
			return true
		elseif 4 == mLockState then
			return false
		end
		return true
	end
end

-- 创建新手引导视图
function GuideView.create(isMaskLayer)
	if nil ~= mRootView then
		return
	end
	-- 触摸层
	mRootView = CCLayer:create()
	mRootView:setTouchEnabled(true)
	mRootView:registerScriptTouchHandler(onTouch, false, -2147483647, true)
	g_rootNode:addChild(mRootView, 1990)
    --战斗对话
    mBattleDialogBg = CCLayer:create()
    mRootView:addChild(mBattleDialogBg)
	-- 高亮框
	mHighLight = TipModule.showFrame(mRootView, nil, CCSizeMake(100, 100), ccp(320, 480), false)
	-- 灰色背景
	local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 100))
	mClipLayer = CCClippingNode:create()
	mClipLayer:addChild(colorLayer)
	mClipLayer:setStencil(mHighLight)
	mClipLayer:setInverted(true)
	mRootView:addChild(mClipLayer)
    if isMaskLayer== nil then 
        colorLayer:setVisible(true)
    else 
        colorLayer:setVisible(false)
    end 
	-- 手指
	mFinger = TipModule.showArrow(mRootView, nil, "down", ccp(320, 420), false)
	-- 小助手
	mHelper = CCSprite:create("guide_assistant.png")
	mHelper:setAnchorPoint(ccp(0.5, 0.0))
	mRootView:addChild(mHelper, 1, 1)
	mHelper:setPosition(ccp(320, 480))
	-- 对话框
	mDialogBg = CCSprite:create("guide_text.png")
	mRootView:addChild(mDialogBg)
	mDialogBg:setAnchorPoint(ccp(0.5, 0.0))
	mDialogBg:setPosition(ccp(400, 280))
end

-- 清除新手引导视图
function GuideView.cleanup()
	if nil == mRootView then
		return
	end
	mRootView:removeFromParentAndCleanup(true)
	mRootView = nil
	BattleMgr.setConfig("bmc_overlapped_round", true)
	FightConfig.setConfig("enable_long_press", true)
end

-- 隐藏新手引导视图
function GuideView.reset()
	if nil == mRootView then
		return
	end
	mLockState = 0
	mClipLayer:setVisible(false)
	mHighLight:setVisible(false)
	mFinger:setVisible(false)
	mHelper:setVisible(false)
	mDialogBg:setVisible(false)

    mBattleDialogBg:setVisible(false)

	BattleMgr.setConfig("bmc_overlapped_round", true)
	FightConfig.setConfig("enable_long_press", true)
end

-- 更新点击区域锁定状态
function GuideView.updateLock(state)
	if nil == mRootView then
		return
	end
	mLockState = state or 3
	if 1 == state or 2 == state then
		mClipLayer:setVisible(true)
	else
		mClipLayer:setVisible(false)
	end
	BattleMgr.setConfig("bmc_overlapped_round", 1 ~= state)
	FightConfig.setConfig("enable_long_press", 1 ~= state)
end

-- 更新位置
function GuideView.updatePos(pos, fingerDirection)
	if nil == mRootView then
		return
	end
    --mHelper:setVisible(true)
    --mFinger:setVisible(true)
    --mDialogBg:setVisible(true)
	-- 高亮框
	TipModule.showFrame(mRootView, mHighLight, nil, pos, false)
	local maxY = pos.y + mHighLight:getContentSize().height/2
	local minY = pos.y - mHighLight:getContentSize().height/2
	-- 手指
	fingerDirection = fingerDirection or "down"
	local fingerPos = ccp(pos.x, pos.y + mHighLight:getContentSize().height/2)
	if mFinger:isVisible() then
		if "left" == fingerDirection then
			fingerPos = ccp(pos.x + mHighLight:getContentSize().width/2, pos.y)
		elseif "up" == fingerDirection then
			fingerPos = ccp(pos.x, pos.y - mHighLight:getContentSize().height/2)
			minY = minY - mFinger:getContentSize().height
		elseif "right" == fingerDirection then
			fingerPos = ccp(pos.x - mHighLight:getContentSize().width/2, pos.y)
		elseif "down" == fingerDirection then
			maxY = maxY + mFinger:getContentSize().height
		end
	end
	mFinger = TipModule.showArrow(mRootView, mFinger, fingerDirection, fingerPos, false)
	-- 小助手
	local assistHeight = mHelper:getContentSize().height
	local dialogHeight = mDialogBg:getContentSize().height
	local y = maxY + dialogHeight/4
	if maxY + assistHeight > 900 then
		y = minY - assistHeight/2 - dialogHeight
	end
	if false == mHighLight:isVisible() then
		y = 380
	end

	mHelper:setPosition(ccp(110, y))
	-- 对话框
	mDialogBg:setPosition(ccp(390, y))
end

-- 更新高亮框大小
function GuideView.updateSize(w, h, showFinger)
	if nil == mRootView then
		return
	end
	mHighLight:setVisible(true)
	TipModule.showFrame(mRootView, mHighLight, CCSizeMake(w, h), nil, false)
	if true == showFinger then
		mFinger:setVisible(true)
	end
end


-- 更新对话内容
function GuideView.updateText(textId)
	if nil == mRootView then
		return
	end

    print(mRootView,"GuideView.updateText",textId)
	local param = LogicTable.getLocInfoById(textId) 
    Log(param)  

	if nil == param or "null" == param.desc then
		return
	end
	mIsTalking = true
	local function talkDone()
		mIsTalking = false
	end
	-- 小助手
	mHelper:setRotation(0)
	mHelper:setVisible(true)
	mHelper:stopAllActions()

	local arr = CCArray:create()
	arr:addObject(CCRotateBy:create(0.2, -4))
	arr:addObject(CCRotateBy:create(0.1, 4))
	arr:addObject(CCCallFunc:create(talkDone))
	mHelper:runAction(CCSequence:create(arr))
    

	-- 对话框
	mDialogBg:setVisible(true)
	mDialogBg:removeAllChildrenWithCleanup(true)


	local layer = RichText.create(param.desc, CCSizeMake(382, 167), 22, mDialogImageVec)
	layer:setPosition(ccp(80, 125))
	mDialogBg:addChild(layer)
end


function GuideView.getIntance()
    return mBattleDialogBg
end 


