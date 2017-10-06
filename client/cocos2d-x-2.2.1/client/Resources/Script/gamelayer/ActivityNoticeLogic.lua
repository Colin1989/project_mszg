--region ActivityNoticeLogic.lua
--Author : songcy
--Date   : 2014/11/11

ActivityNoticeLogic = {}

-- 获得活动公告列表
local function handleNoticeList(packet)
	cclog("----------------------------------------->handleNoticeList:")
	EventCenter_post(EventDef["ED_NOTICE_LIST"], packet.list)
end

-- 获得活动公告详细信息
local function handleNoticeItemDetail(packet)
	cclog("----------------------------------------->handleNoticeItemDetail:")
	if packet.result ~= 1 then
		Toast.show(GameString.get("NOTICE_SYSTEM_TIP_2"))
		return
	end
	EventCenter_post(EventDef["ED_NOTICE_ITEM_DETAIL"], packet.item_info)
end

-- 增加活动公告
local function handleNoticeItemAdd(packet)
	cclog("----------------------------------------->handleNoticeItemAdd:")
	EventCenter_post(EventDef["ED_ADD_NOTICE_ITEM"], packet.item_info)
end

-- 删除活动公告
local function handleNoticeItemDel(packet)
	cclog("----------------------------------------->handleNoticeItemDel:")
	EventCenter_post(EventDef["ED_DEL_NOTICE_ITEM"], packet)
end

NetSocket_registerHandler(NetMsgType["msg_notify_notice_list"], notify_notice_list, handleNoticeList)						-- 活动公告列表
NetSocket_registerHandler(NetMsgType["msg_notify_notice_item_detail"], notify_notice_item_detail, handleNoticeItemDetail)		-- 获得活动详细信息
NetSocket_registerHandler(NetMsgType["msg_notify_notice_item_add"], notify_notice_item_add, handleNoticeItemAdd)			-- 活动列表项目增加
NetSocket_registerHandler(NetMsgType["msg_notify_notice_item_del"], notify_notice_item_del, handleNoticeItemDel)			-- 活动列表项目删除