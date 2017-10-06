--region LayerSpringActivity.lua
--Author : songcy
--Date   : 2015/01/22

LayerSpringActivity = {}
LayerAbstract:extend(LayerSpringActivity)

local mRootView = nil

local mEnterNotice = nil				-- 表示进来是显示哪个界面
local IsEnterActivity = false			-- 控制更新后的公告登录

local m_selectedBtn = nil				-- 选中的界面
local mpanelContent = nil 				-- 两个小界面的根节点
local mcurUIWidget = nil 				-- 当前展示的小界面(刚进入时)
local mcurChildTb = nil				-- 刚刚展示的小界面
local mClickWidget = nil				-- 刚刚点击的按钮
local pushFlag = false					-- 表示刚进入时的立即前往界面是否push过

-- local m_BtnInfo = {
	-- ["normal"] ="public_newbuttom.png",
	-- ["current"] = "laddermatch_buttom_h.png",
-- }

--设置点击切换按钮的图片
local function setSwitchBtnImg(sender)
	-- 已经选中
	if m_selectedBtn == sender then
	    return
	end

	m_selectedBtn = sender
	for k = 1, 2, 1 do 
		local btn = nil
		if k== 1 then
			btn = tolua.cast(mRootView:getChildByName("Button_draw"), "UIButton")
		elseif k== 2 then
			btn = tolua.cast(mRootView:getChildByName("Button_recharge"),"UIButton")
		end
		if btn ~= sender then
			btn:setBright(true)
		else
			btn:setBright(false)
		end	
	end
end

----------------------------------------------------------------------
LayerSpringActivity.setJosnWidget = function(this,jsonFile)
	if mcurChildTb ~= nil then
		mcurChildTb.destroy()
		mpanelContent:removeAllChildren()
	end
	local contentView = GUIReader:shareReader():widgetFromJsonFile(jsonFile)
	contentView:setAnchorPoint(ccp(0.5,0.5))
	contentView:setPosition(ccp(0,20))
	mpanelContent:addChild(contentView)
	this.init(contentView)
	
	mcurChildTb = this
	return contentView
end

----------------------------------------------------------------------
-- 点击按钮
local function clickBtn(typeName, widget)
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		if mClickWidget == weightName then
			return
		end
		if weightName == "Button_close" then				-- 关闭
			LayerMain.pullPannel()
		elseif weightName == "Button_draw" then			-- 春节抽奖
			local actJudge = false
			for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
				if key == 1 then
					actJudge = SpringActivityLogic.isTimeValidById(value.id)
				end
			end
			if actJudge == false then
				Toast.show( GameString.get("SPRING_ACTIVITY_TIP_4"))
				return
			end
			mClickWidget = weightName
			LayerSpringRecharge.setRootNil()
			LayerSpringActivity.setDrawUI()
			setSwitchBtnImg(widget)
		elseif weightName == "Button_recharge" then		-- 充值送好礼
			local actJudge = false
			for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
				if key == 2 then
					actJudge = SpringActivityLogic.isTimeValidById(value.id)
				end
			end
			if actJudge == false then
				Toast.show( GameString.get("SPRING_ACTIVITY_TIP_4"))
				return
			end
			mClickWidget = weightName
			LayerSpringDraw.setRootNil()
			LayerSpringActivity.setRechargeUI()
			setSwitchBtnImg(widget)
		end	
	end
end

-- 加载春节抽奖UI
LayerSpringActivity.setDrawUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerSpringActivity.setJosnWidget(LayerSpringDraw,"springactivity_2.json")
end

-- 加载充值送好礼UI
LayerSpringActivity.setRechargeUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerSpringActivity.setJosnWidget(LayerSpringRecharge,"springactivity_3.json")
end

-- 加载活动详情UI
-- LayerSpringActivity.setDetailUI = function()
	-- if mRootView == nil then
		-- return
	-- end
	-- mcurUIWidget = LayerSpringActivity.setJosnWidget(LayerNoticeDetail,"NoticeBackgournd_2.json")
-- end

-- 初始化静态UI
local function initUI()
	-- 关闭按钮
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIImageView")
	closeBtn:registerEventScript(clickBtn)
	-- 页面标签
	local drawBtn = tolua.cast(mRootView:getChildByName("Button_draw"), "UIButton")
	local drawWord = drawBtn:getChildByName("textImg")
	drawBtn:registerEventScript(clickBtn)
	local rechargeBtn = tolua.cast(mRootView:getChildByName("Button_recharge"), "UIButton")
	local rechargeWord = rechargeBtn:getChildByName("textImg")
	rechargeBtn:registerEventScript(clickBtn)
	
	local actJudge = {}
	for key, value in pairs(SpringActivityLogic.getAllSpringActivity()) do
		if key == 1 then
			actJudge[key] = SpringActivityLogic.isTimeValidById(value.id)
			drawBtn:setBright(actJudge[key])
			drawBtn:setTouchEnabled(actJudge[key])
			Lewis:spriteShaderEffect(drawBtn:getVirtualRenderer(),"buff_gray.fsh",not actJudge[key])
			Lewis:spriteShaderEffect(drawWord:getVirtualRenderer(),"buff_gray.fsh",not actJudge[key])
		elseif key == 2 then
			actJudge[key] = SpringActivityLogic.isTimeValidById(value.id)
			rechargeBtn:setBright(actJudge[key])
			rechargeBtn:setTouchEnabled(actJudge[key])
			Lewis:spriteShaderEffect(rechargeBtn:getVirtualRenderer(),"buff_gray.fsh",not actJudge[key])
			Lewis:spriteShaderEffect(rechargeWord:getVirtualRenderer(),"buff_gray.fsh",not actJudge[key])
		end
	end
	
	
	--设置刚进入时，默认选中的btn
	for	k, v in pairs(actJudge) do
		if k == 1 and v == true then
			m_selectedBtn = drawBtn
			mClickWidget = "Button_draw"
			LayerSpringActivity.setDrawUI()
			break
		elseif k == 2 and v == true then
			m_selectedBtn = rechargeBtn
			mClickWidget = "Button_recharge"
			LayerSpringActivity.setRechargeUI()
			break
		end
	end
	-- local nameImage = tolua.cast(m_selectedBtn:getChildByName("textImg"),"UIImageView")
	-- nameImage:loadTexture(m_BtnInfo.current)
	
	m_selectedBtn:setBright(false)
end

-- 初始化界面
LayerSpringActivity.init = function(rootView)
	-- mRootView = UIManager.findLayerByTag("UI_Notice"):getWidgetByName("Panel_20")
	mRootView = rootView
	-- 两个小界面的根节点
	mpanelContent = tolua.cast(mRootView:getChildByName("ImageView_23"),"UILayout")
	-- 初始化静态UI
	initUI()
end

LayerSpringActivity.destroy = function()
	mRootView = nil
	LayerSpringDraw.setRootNil()
	LayerSpringRecharge.setRootNil()
end

-- local function handleEnterNotice(param)
	-- mEnterNotice = param
-- end

-- UIWidget:create()
-- UILayout:create()

-- EventCenter_subscribe(EventDef["ED_ENTER_NOTICE"], handleEnterNotice)			-- 进入公告界面




