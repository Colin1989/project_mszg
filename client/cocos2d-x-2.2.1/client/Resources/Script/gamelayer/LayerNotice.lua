--region LayerNotice.lua
--Author : songcy
--Date   : 2014/11/07

LayerNotice = {}
LayerAbstract:extend(LayerNotice)

local mRootView = nil
local BtnList = {}

local mEnterNotice = nil				-- 表示进来是显示哪个界面
local IsEnterActivity = false			-- 控制更新后的公告登录

local m_radioBtnTagAdd = 10000			-- 按钮 tag 增量
local m_selectedRadioBtn = nil			-- 选中的radio
local mpanelContent = nil 				-- 三个小界面的根节点
local mcurUIWidget = nil 				-- 当前展示的小界面(刚进入时)
local mcurChildTb = nil				-- 刚刚展示的小界面
local mClickWidget = nil				-- 刚刚点击的按钮
local pushFlag = false					-- 表示刚进入时的立即前往界面是否push过

local m_tbRadioBtnInfo =
{
	{["normal"] ="text_notice_huodong_n.png",["current"] = "text_notice_huodong_h.png"},
	{["normal"] ="text_notice_xitong_n.png",["current"] ="text_notice_xitong_h.png"},
	{["normal"] = "text_notice_gengxin_n.png",["current"] = "text_notice_gengxin_h.png"},
}

----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" ~= typeName then
		return
	end
	UIManager.pop("UI_Notice")
	if LayerInviteCode.getPushFlag() == false then
		LayerInviteCode.setPushFlag()
		LayerInviteCode.pushEnterInviteCodeUI()			--出现邀请码立即前往，加好友界面
	end
end

--设置点击切换按钮的图片
local function setSwitchBtnImg(sender)
	-- 已经选中
	if m_selectedRadioBtn == sender then
	    return
	end

	m_selectedRadioBtn = sender
	for k = 1, 3, 1 do 
		local btn = nil
		if k== 1 then
			btn = tolua.cast(mRootView:getChildByName("Button_Activity"), "UIButton")
		elseif k== 2 then
			btn = tolua.cast(mRootView:getChildByName("Button_System"),"UIButton")
		elseif k == 3 then
			btn = tolua.cast(mRootView:getChildByName("Button_Update"),"UIButton")
		end
		local nameImage = tolua.cast(btn:getChildByName("textImg"),"UIImageView")
		local pos = btn:getPosition()
		if btn ~= sender then
			btn:setBright(true)
			nameImage:loadTexture(m_tbRadioBtnInfo[k].normal)
			nameImage:setPosition(ccp(0,0 ))
		else
			btn:setBright(false)
			nameImage:loadTexture(m_tbRadioBtnInfo[k].current)
			nameImage:setPosition(ccp(0,-4))
		end	
	end
end

----------------------------------------------------------------------
LayerNotice.setJosnWidget = function(this,jsonFile)
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
		if mClickWidget == widget then
			return
		end
		if weightName == "Button_close" then				-- 关闭
			UIManager.pop("UI_Notice")
			if LayerInviteCode.getPushFlag() == false then
				LayerInviteCode.setPushFlag()
				LayerInviteCode.pushEnterInviteCodeUI()		--出现邀请码立即前往，加好友界面
			end
		elseif weightName == "Button_Activity" then		-- 活动公告
			mClickWidget = widget
			LayerNotice.setActivityUI()
			setSwitchBtnImg(widget)
		elseif weightName == "Button_System" then			-- 系统公告
			-- local mEmail = MailLogic.getEmail()
			if nil == MailLogic.getEmail() then
				Toast.show(GameString.get("NOTICE_SYSTEM_TIP_1"))
				return
			else
				mClickWidget = widget
				LayerNotice.setSystemUI()
				setSwitchBtnImg(widget)
			end
		elseif weightName == "Button_Update" then		-- 更新公告
			mClickWidget = widget
			LayerNotice.setUpdateUI()
			setSwitchBtnImg(widget)
		end	
	end
end

-- 加载更新公告UI
LayerNotice.setUpdateUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerNotice.setJosnWidget(LayerNoticeUpdate,"NoticeBackgournd_2.json")
end

-- 加载系统公告UI
LayerNotice.setSystemUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerNotice.setJosnWidget(LayerMail,"mail.json")
end

-- 加载活动公告UI
LayerNotice.setActivityUI = function()
	if mRootView == nil then
		return
	end
	-- local tb = req_notice_list()
	-- NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_list"])
	mcurUIWidget = LayerNotice.setJosnWidget(LayerNoticeActivity,"NoticeActivity.json")
end

-- 加载活动详情UI
LayerNotice.setDetailUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerNotice.setJosnWidget(LayerNoticeDetail,"NoticeBackgournd_2.json")
end

-- 初始化静态UI
local function initUI()
	-- 关闭按钮
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickBtn)
	-- 
	local activityBtn = tolua.cast(mRootView:getChildByName("Button_Activity"), "UIButton")
	activityBtn:registerEventScript(clickBtn)
	local systemBtn = tolua.cast(mRootView:getChildByName("Button_System"), "UIButton")
	systemBtn:registerEventScript(clickBtn)
	local updateBtn = tolua.cast(mRootView:getChildByName("Button_Update"), "UIButton")
	updateBtn:registerEventScript(clickBtn)
	--设置刚进入时，默认选中的btn
	if nil ~= MailLogic.getEmail() then
		m_selectedRadioBtn = systemBtn
		LayerNotice.setSystemUI()
		local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
		nameImage:loadTexture(m_tbRadioBtnInfo[2].current)
	elseif VERSION_UPDATE == false or IsEnterActivity == true then
		m_selectedRadioBtn = activityBtn
		LayerNotice.setActivityUI()
		local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
		nameImage:loadTexture(m_tbRadioBtnInfo[1].current)
	else
		IsEnterActivity = true
		m_selectedRadioBtn = updateBtn
		LayerNotice.setUpdateUI()
		local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
		nameImage:loadTexture(m_tbRadioBtnInfo[3].current)
	end
	m_selectedRadioBtn:setBright(false)
end

LayerNotice.isPush = function()
	if nil ~= MailLogic.getEmail() or LayerNoticeActivity.activityCacheIsNil() == false or VERSION_UPDATE == true then
		return true
	end
	return false
end
-- 
LayerNotice.init = function(bundle)
	mRootView = UIManager.findLayerByTag("UI_Notice"):getWidgetByName("Panel_20")
	-- mRootView = rootView
	mpanelContent = tolua.cast(mRootView:getChildByName("ImageView_26"),"UILayout")
	
	initUI()
end

LayerNotice.destroy = function()
	mRootView = nil
	LayerNoticeActivity.setRootNil()
	LayerNoticeDetail.setRootNil()
	LayerMail.setRootNil()
	LayerNoticeUpdate.setRootNil()
end

local function handleEnterNotice(param)
	mEnterNotice = param
end

-- UIWidget:create()
-- UILayout:create()

EventCenter_subscribe(EventDef["ED_ENTER_NOTICE"], handleEnterNotice)			-- 进入公告界面



