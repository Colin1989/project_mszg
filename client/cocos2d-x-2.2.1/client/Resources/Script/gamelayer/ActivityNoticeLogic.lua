--region ActivityNoticeLogic.lua
--Author : songcy
--Date   : 2014/11/11

ActivityNoticeLogic = {}

-- ��û�����б�
local function handleNoticeList(packet)
	cclog("----------------------------------------->handleNoticeList:")
	EventCenter_post(EventDef["ED_NOTICE_LIST"], packet.list)
end

-- ��û������ϸ��Ϣ
local function handleNoticeItemDetail(packet)
	cclog("----------------------------------------->handleNoticeItemDetail:")
	if packet.result ~= 1 then
		Toast.show(GameString.get("NOTICE_SYSTEM_TIP_2"))
		return
	end
	EventCenter_post(EventDef["ED_NOTICE_ITEM_DETAIL"], packet.item_info)
end

-- ���ӻ����
local function handleNoticeItemAdd(packet)
	cclog("----------------------------------------->handleNoticeItemAdd:")
	EventCenter_post(EventDef["ED_ADD_NOTICE_ITEM"], packet.item_info)
end

-- ɾ�������
local function handleNoticeItemDel(packet)
	cclog("----------------------------------------->handleNoticeItemDel:")
	EventCenter_post(EventDef["ED_DEL_NOTICE_ITEM"], packet)
end

NetSocket_registerHandler(NetMsgType["msg_notify_notice_list"], notify_notice_list, handleNoticeList)						-- ������б�
NetSocket_registerHandler(NetMsgType["msg_notify_notice_item_detail"], notify_notice_item_detail, handleNoticeItemDetail)		-- ��û��ϸ��Ϣ
NetSocket_registerHandler(NetMsgType["msg_notify_notice_item_add"], notify_notice_item_add, handleNoticeItemAdd)			-- ��б���Ŀ����
NetSocket_registerHandler(NetMsgType["msg_notify_notice_item_del"], notify_notice_item_del, handleNoticeItemDel)			-- ��б���Ŀɾ��