-- 系统邮件
LayerMail = {}
-- local mRootNode = nil
local mRootView = nil
local mEmail = nil
----------------------------------------------------------------------
-- 点击关闭按钮
-- local function clickCloseBtn(typeName, widget)
	-- if "releaseUp" == typeName then
		-- UIManager.pop("UI_mail")
	-- end
-- end
----------------------------------------------------------------------
-- 点击领取按钮
local function clickGetBtn(typeName, widget)
	if "releaseUp" == typeName then
		if nil == mEmail then
			return
		end
		if true == SystemTime.isEnd(mEmail.end_time) then
			Toast.Textstrokeshow(GameString.get("EMAIL_STR_01"), ccc3(255,255,255), ccc3(0,0,0), 30)
			return
		end
		MailLogic.requestGetEmailAttachments(mEmail.id)
	end
end
----------------------------------------------------------------------
-- 创建奖励
local function createRewardItem(rewardId, count)
	local rewardItemRow = LogicTable.getRewardItemRow(rewardId)
	local node = UILayout:create()
	node:setSize(CCSizeMake(120, 150))
	-- 图标
	local rewardIconImage = CommonFunc_getImgView(rewardItemRow.icon)
	CommonFunc_SetQualityFrame(rewardIconImage)
	rewardIconImage:setPosition(ccp(60, 95))
	node:addChild(rewardIconImage)
	-- 数量背景
	local rewardCountImage = CommonFunc_getImgView("public2_bg_05.png")
	rewardCountImage:setScale9Enabled(true)
	rewardCountImage:setCapInsets(CCRectMake(5, 5, 1, 1))
	rewardCountImage:setSize(CCSizeMake(80, 30))
	rewardCountImage:setPosition(ccp(60, 20))
	node:addChild(rewardCountImage)
	-- 数量
	local rewardCountLabel = CommonFunc_getLabel(tostring(count), 20)
	rewardCountLabel:setPosition(ccp(60, 20))
	node:addChild(rewardCountLabel)
	return node
end

-- 按键 刷新
local function initGetMail()
	if nil == mRootView then
		return
	end
	local getBtn = tolua.cast(mRootView:getChildByName("Button_get"), "UIButton")
	getBtn:registerEventScript(clickGetBtn)
	local imgGetBtn = tolua.cast(mRootView:getChildByName("ImageView_get_image"), "UIImageView")
	
	if nil == MailLogic.getEmail() then
		getBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(getBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(imgGetBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	else
		getBtn:setTouchEnabled(true)
		Lewis:spriteShaderEffect(getBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		Lewis:spriteShaderEffect(imgGetBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	end
end

----------------------------------------------------------------------
-- 初始化
LayerMail.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		return
	end
	-- mRootNode = UIManager.findLayerByTag("UI_mail")
	-- local closeBtn = tolua.cast(mRootNode:getWidgetByName("Button_close"), "UIButton")
	-- local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIButton")
	-- closeBtn:registerEventScript(clickCloseBtn)
	-- local getBtn = tolua.cast(mRootNode:getWidgetByName("Button_get"), "UIButton")
	
	local getBtn = tolua.cast(mRootView:getChildByName("Button_get"), "UIButton")
	getBtn:setTouchEnabled(true)
	getBtn:registerEventScript(clickGetBtn)
	-- initGetMail()
	
	-- local scrollView = tolua.cast(mRootNode:getWidgetByName("ScrollView_reward"), "UIScrollView")
	local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_reward"), "UIScrollView")
	--
	mEmail = MailLogic.getEmail()
	if nil == mEmail then
		return
	end
	local cellArray = {}
	for key, val in pairs(mEmail.attachments) do
		table.insert(cellArray, createRewardItem(val.temp_id, val.amount))
	end
	setAdapterGridView(scrollView, cellArray, 3, 0)
	-- local descLabel = tolua.cast(mRootNode:getWidgetByName("Label_desc"), "UILabel")
	local descLabel = tolua.cast(mRootView:getChildByName("Label_desc"), "UILabel")
	descLabel:setText(mEmail.content)
end
----------------------------------------------------------------------
-- 销毁
LayerMail.destroy = function()
	-- mRootNode = nil
	mRootView = nil
	mEmail = nil
end

-------------------------------------------销毁---------------------------
LayerMail.setRootNil = function()
	mRootView = nil
	mEmail = nil
end

----------------------------------------------------------------------
-- 邮件列表
local function handleEmailList(success)
	LayerMain.showNoticeTip()
	if nil == mRootView then
		return
	end
	if true == success then
		for key, val in pairs(mEmail.attachments) do
			CommonFunc_showGetItemTip(val.temp_id, val.amount)
		end
		-- initGetMail()
		local getBtn = tolua.cast(mRootView:getChildByName("Button_get"), "UIButton")
		local imgGetBtn = tolua.cast(mRootView:getChildByName("ImageView_get_image"), "UIImageView")
		getBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(getBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(imgGetBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		LayerMain.showNoticeTip()
		-- UIManager.pop("UI_mail")
		UIManager.popBounceWindow("UI_TempPack")
	end
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_EMAIL_LIST"], handleEmailList)
