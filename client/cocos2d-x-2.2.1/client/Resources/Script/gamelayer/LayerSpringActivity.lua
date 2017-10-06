--region LayerSpringActivity.lua
--Author : songcy
--Date   : 2015/01/22

LayerSpringActivity = {}
LayerAbstract:extend(LayerSpringActivity)

local mRootView = nil

local mEnterNotice = nil				-- ��ʾ��������ʾ�ĸ�����
local IsEnterActivity = false			-- ���Ƹ��º�Ĺ����¼

local m_selectedBtn = nil				-- ѡ�еĽ���
local mpanelContent = nil 				-- ����С����ĸ��ڵ�
local mcurUIWidget = nil 				-- ��ǰչʾ��С����(�ս���ʱ)
local mcurChildTb = nil				-- �ո�չʾ��С����
local mClickWidget = nil				-- �ոյ���İ�ť
local pushFlag = false					-- ��ʾ�ս���ʱ������ǰ�������Ƿ�push��

-- local m_BtnInfo = {
	-- ["normal"] ="public_newbuttom.png",
	-- ["current"] = "laddermatch_buttom_h.png",
-- }

--���õ���л���ť��ͼƬ
local function setSwitchBtnImg(sender)
	-- �Ѿ�ѡ��
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
-- �����ť
local function clickBtn(typeName, widget)
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		if mClickWidget == weightName then
			return
		end
		if weightName == "Button_close" then				-- �ر�
			LayerMain.pullPannel()
		elseif weightName == "Button_draw" then			-- ���ڳ齱
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
		elseif weightName == "Button_recharge" then		-- ��ֵ�ͺ���
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

-- ���ش��ڳ齱UI
LayerSpringActivity.setDrawUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerSpringActivity.setJosnWidget(LayerSpringDraw,"springactivity_2.json")
end

-- ���س�ֵ�ͺ���UI
LayerSpringActivity.setRechargeUI = function()
	if mRootView == nil then
		return
	end
	mcurUIWidget = LayerSpringActivity.setJosnWidget(LayerSpringRecharge,"springactivity_3.json")
end

-- ���ػ����UI
-- LayerSpringActivity.setDetailUI = function()
	-- if mRootView == nil then
		-- return
	-- end
	-- mcurUIWidget = LayerSpringActivity.setJosnWidget(LayerNoticeDetail,"NoticeBackgournd_2.json")
-- end

-- ��ʼ����̬UI
local function initUI()
	-- �رհ�ť
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIImageView")
	closeBtn:registerEventScript(clickBtn)
	-- ҳ���ǩ
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
	
	
	--���øս���ʱ��Ĭ��ѡ�е�btn
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

-- ��ʼ������
LayerSpringActivity.init = function(rootView)
	-- mRootView = UIManager.findLayerByTag("UI_Notice"):getWidgetByName("Panel_20")
	mRootView = rootView
	-- ����С����ĸ��ڵ�
	mpanelContent = tolua.cast(mRootView:getChildByName("ImageView_23"),"UILayout")
	-- ��ʼ����̬UI
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

-- EventCenter_subscribe(EventDef["ED_ENTER_NOTICE"], handleEnterNotice)			-- ���빫�����




