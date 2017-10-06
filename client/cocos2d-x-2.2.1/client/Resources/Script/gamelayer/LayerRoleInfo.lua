------------------------------------------------------------------------------------------------
-- ��ɫ��Ϣ
------------------------------------------------------------------------------------------------




LayerRoleInfo = {}
local mRootNode = nil
local role = nil

------------------------------------------------------------------------------------------------
-- ����رհ�ť
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_RoleInfo")
	end
end

local function onClick(typeName, widget)
	if "releaseUp" == typeName then
		local widgetName = widget:getName()
		if widgetName == "Button_close" then
			UIManager.pop("UI_RoleInfo")
		elseif widgetName == "Button_friend" then
			FriendDataCache.add_search(role.role_id)
		elseif widgetName == "Button_block" then
			local function SendReBorn()
				ChatLogic.setShield(role.role_id)
				LayerChat.updateChatView()
				UIManager.pop("UI_RoleInfo")
			end
			local structConfirm = 
			{
				strText = GameString.get("BLOCKROLE"),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {SendReBorn, nil},		--�ص�����
				buttonEvent_Param = {nil, nil}			--��������
			}
			UIManager.push("UI_ComfirmDialog", structConfirm)
		elseif widgetName == "Button_roleInfo" then
			-- UIManager.push("UI_FriendInfo",role)
		end
	end
end

-------------------------------------------------------------------------------------------------
LayerRoleInfo.init = function(roleInfo)
	mRootNode = UIManager.findLayerByTag("UI_RoleInfo")
	role = roleInfo
	
	Log(role)
	-- ͷ�� ImageView_Icon
	-- local head = CommonFunc_getImgView(ModelPlayer.getProfessionIconByType(role.type, role.advanced_level))
	local head = tolua.cast(mRootNode:getWidgetByName("ImageView_Icon"), "UIImageView")
	head:loadTexture(ModelPlayer.getProfessionIconByType(role.type, role.advanced_level))
	
	-- ���� Label_name
	local Label_name = tolua.cast(mRootNode:getWidgetByName("Label_name"), "UILabel")
	Label_name:setText(role.nickname)
	
	-- ���� Label_rank
	local Label_rank = tolua.cast(mRootNode:getWidgetByName("Label_rank"), "UILabel")
	if role.military_lev == 0 then
		Label_rank:setText(GameString.get("PUBLIC_NONE"))
	else
		Label_rank:setText(LogicTable.getMiltitaryRankRow(role.military_lev).name)
	end
	
	-- ��Ϊ���� Button_friend
	local friendBtn = tolua.cast(mRootNode:getWidgetByName("Button_friend"), "UIButton")
	-- friendBtn:registerEventScript(onClick)
	if FriendDataCache.judgeIsMyFriend(role.role_id) == false then
		Lewis:spriteShaderEffect(friendBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		local ImageView_MF = tolua.cast(mRootNode:getWidgetByName("ImageView_37"), "UIImageView")
		ImageView_MF:loadTexture("text_shenqinghaoyou.png")
		friendBtn:setTouchEnabled(true)
		friendBtn:registerEventScript(onClick)
	else
		Lewis:spriteShaderEffect(friendBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		friendBtn:setTouchEnabled(false)
		local ImageView_MF = tolua.cast(mRootNode:getWidgetByName("ImageView_37"), "UIImageView")
		ImageView_MF:loadTexture("text_yishihaoyou.png")
	end
	
	-- ���� Button_block
	local blockBtn = tolua.cast(mRootNode:getWidgetByName("Button_block"), "UIButton")
	blockBtn:registerEventScript(onClick)
	
	-- �鿴��Ϣ Button_roleInfo
	local roleInfoBtn = tolua.cast(mRootNode:getWidgetByName("Button_roleInfo"), "UIButton")
	roleInfoBtn:setVisible(false)
	-- roleInfoBtn:registerEventScript(onClick)
	
	-- �ر�
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(onClick)
	
	-- LayerRoleInfo.rootView =  UIManager.findLayerByTag("UI_WorldChat")
	-- LayerRoleInfo.rootView:setPosition(ccp(0,200))
	-- MsgTb = NoticeLogic.getHistory()
	-- LayerRoleInfo.initView()
end

LayerRoleInfo.destroy = function()
    mRootNode = nil
	role = nil
end