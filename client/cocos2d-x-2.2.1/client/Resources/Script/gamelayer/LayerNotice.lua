--region LayerNotice.lua
--Author : songcy
--Date   : 2014/11/07

LayerNotice = {}
LayerAbstract:extend(LayerNotice)

local mRootView = nil
local BtnList = {}

local mEnterNotice = nil				-- ��ʾ��������ʾ�ĸ�����
local IsEnterActivity = false			-- ���Ƹ��º�Ĺ����¼

local m_radioBtnTagAdd = 10000			-- ��ť tag ����
local m_selectedRadioBtn = nil			-- ѡ�е�radio
local mpanelContent = nil 				-- ����С����ĸ��ڵ�
local mcurUIWidget = nil 				-- ��ǰչʾ��С����(�ս���ʱ)
local mcurChildTb = nil				-- �ո�չʾ��С����
local mClickWidget = nil				-- �ոյ���İ�ť
local pushFlag = false					-- ��ʾ�ս���ʱ������ǰ�������Ƿ�push��

local m_tbRadioBtnInfo =
{
	{["normal"] ="text_notice_huodong_n.png",["current"] = "text_notice_huodong_h.png"},
	{["normal"] ="text_notice_xitong_n.png",["current"] ="text_notice_xitong_h.png"},
	{["normal"] = "text_notice_gengxin_n.png",["current"] = "text_notice_gengxin_h.png"},
}

----------------------------------------------------------------------
-- ����رհ�ť
local function clickCloseBtn(typeName, widget)
	if "releaseUp" ~= typeName then
		return
	end
	UIManager.pop("UI_Notice")
	if LayerInviteCode.getPushFlag() == false then
		LayerInviteCode.setPushFlag()
		LayerInviteCode.pushEnterInviteCodeUI()			--��������������ǰ�����Ӻ��ѽ���
	end
end

--���õ���л���ť��ͼƬ
local function setSwitchBtnImg(sender)
	-- �Ѿ�ѡ��
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
-- �����ť
local function clickBtn(typeName, widget)
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		if mClickWidget == widget then
			return
		end
		if weightName == "Button_close" then				-- �ر�
			UIManager.pop("UI_Notice")
			if LayerInviteCode.getPushFlag() == false then
				LayerInviteCode.setPushFlag()
				LayerInviteCode.pushEnterInviteCodeUI()		--��������������ǰ�����Ӻ��ѽ���
			end
		elseif weightName == "Button_Activity" then		-- �����
			mClickWidget = widget
			LayerNotice.setActivityUI()
			setSwitchBtnImg(widget)
		elseif weightName == "Button_System" then			-- ϵͳ����
			-- local mEmail = MailLogic.getEmail()
			if nil == MailLogic.getEmail() then
				Toast.show(GameString.get("NOTICE_SYSTEM_TIP_1"))
				return
			else
				mClickWidget = widget
				LayerNotice.setSystemUI()
				setSwitchBtnImg(widget)
			end
		elseif weightName == "Button_Update" then		-- ���¹���
			mClickWidget = widget
			LayerNotice.setUpdateUI()
			setSwitchBtnImg(widget)
		end	
	end
end

-- ���ظ��¹���UI
LayerNotice.setUpdateUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerNotice.setJosnWidget(LayerNoticeUpdate,"NoticeBackgournd_2.json")
end

-- ����ϵͳ����UI
LayerNotice.setSystemUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerNotice.setJosnWidget(LayerMail,"mail.json")
end

-- ���ػ����UI
LayerNotice.setActivityUI = function()
	if mRootView == nil then
		return
	end
	-- local tb = req_notice_list()
	-- NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_list"])
	mcurUIWidget = LayerNotice.setJosnWidget(LayerNoticeActivity,"NoticeActivity.json")
end

-- ���ػ����UI
LayerNotice.setDetailUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerNotice.setJosnWidget(LayerNoticeDetail,"NoticeBackgournd_2.json")
end

-- ��ʼ����̬UI
local function initUI()
	-- �رհ�ť
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickBtn)
	-- 
	local activityBtn = tolua.cast(mRootView:getChildByName("Button_Activity"), "UIButton")
	activityBtn:registerEventScript(clickBtn)
	local systemBtn = tolua.cast(mRootView:getChildByName("Button_System"), "UIButton")
	systemBtn:registerEventScript(clickBtn)
	local updateBtn = tolua.cast(mRootView:getChildByName("Button_Update"), "UIButton")
	updateBtn:registerEventScript(clickBtn)
	--���øս���ʱ��Ĭ��ѡ�е�btn
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

EventCenter_subscribe(EventDef["ED_ENTER_NOTICE"], handleEnterNotice)			-- ���빫�����



