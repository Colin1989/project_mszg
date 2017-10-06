
-------------------------------------
--作者：李慧琴
--说明：好友详细信息界面
--时间：2014-3-3
-------------------------------------

local  friendId --保存当前的好友id

FriendInfo = {}

local mFriendInfoRoot = nil      --当前界面的根节点
local info, poInfo,skillInfo
local curBundle = nil 
LayerAbstract:extend(FriendInfo)

--删除好友的函数
FriendInfo.deleteFriend = function(friendId)
	local structConfirm ={
		strText = GameString.get("DeleFriend"),		
		buttonCount = 2,
		buttonName = { GameString.get("sure"), GameString.get("cancle")},
		buttonEvent ={FriendDataCache.reqDelFriend_delete,nil},
		buttonEvent_Param = {friendId,nil}
		}
	UIManager.push("UI_ComfirmDialog",structConfirm)    --处理删除好友结果	
end

local function popLayer()
	UIManager.pop("UI_FriendInfo")
end

--点击确定后，延迟几秒，登弹框消失后，再pop当前界面	
FriendInfo.delayDelAction = function()
	local deleteFriend = mFriendInfoRoot:getWidgetByName("deleteFriend")   	 --删除好友
    tolua.cast(deleteFriend,"UIButton")
	local action = CCSequence:createWithTwoActions(CCDelayTime:create(3.0),CCCallFuncN:create(popLayer))
	deleteFriend:runAction(action)	
end		
		
local function clicks(type,widget)
    widgetName = widget:getName()
	if type == "releaseUp" then
		if widgetName == "chat" then	
			UIManager.pop("UI_FriendInfo")              --出现聊天界面
			local tb ={}
			tb.friendId = friendId
			UIManager.push("UI_FriendChat",tb)
		elseif widgetName == "deleteFriend"  then
			FriendInfo.deleteFriend(friendId)
		elseif widgetName == "close"  then
			UIManager.pop("UI_FriendInfo")
			if curBundle == nil then
				--LayerFriendList.setUI("addImage",1)
			else
				LayerFriendList.setUI("friendImage")
				FriendDataCache.setMainFlag()
				LayerFriendList.showChatNotice()
			end
		elseif widgetName == "addFriend" then
			FriendDataCache.add_search(friendId)
		end
	end
end


--设置界面的公共信息
local function setPublicInfo(info)
	for key,value in pairs(info)  do
		friendId = value.friend_id
		local name = mFriendInfoRoot:getWidgetByName("name")            --角色名
		tolua.cast(name,"UILabel")
		name:setText(value.nickname)
		local head = mFriendInfoRoot:getWidgetByName("head")            --角色头像
		tolua.cast(head,"UIImageView")
		head:loadTexture(ModelPlayer.getProfessionIconByType(value.head,value.advanced_level))
		local level = mFriendInfoRoot:getWidgetByName("level")          -- 等级
		tolua.cast(level,"UILabel")
		level:setText(value.level)
		local rowType = mFriendInfoRoot:getWidgetByName("roleType")     --职业 
		tolua.cast(rowType,"UILabel")
		rowType:setText(CommonFunc_GetRoleTypeString(tonumber(value.head)))     
		local public = mFriendInfoRoot:getWidgetByName("public")        --公会
		tolua.cast(public,"UILabel")
		public:setText(value.public)
		local athletics = mFriendInfoRoot:getWidgetByName("athletics")        --竞技？？？？？、暂时还没有
		tolua.cast(athletics,"UILabel")
		athletics:setText("暂时还没有")	
	end	
end


--设置界面的战斗力和雕纹
local function setPower(poInfo,skillInfo)
	local power = mFriendInfoRoot:getWidgetByName("power")        --战斗力
    tolua.cast(power,"UILabel")
	power:setText(poInfo)
	for key,value in pairs(skillInfo) do
		local  skill1 =  mFriendInfoRoot:getWidgetByName(string.format("skill%d",key)) 
		if skillInfo[key].temp_id ~= 0 then
			CommonFunc_AddGirdWidget_Rune(skillInfo[key].temp_id,skillInfo[key].level,nil,skill1)
		end
	end	
end

--设置是添加好友还是删除和聊天界面
local function setAddVisOrNo(bundle)
	local addFriend = mFriendInfoRoot:getWidgetByName("addFriend")   --加为好友
    tolua.cast(addFriend,"UIButton")
    addFriend:registerEventScript(clicks)
	local deleteFriend = mFriendInfoRoot:getWidgetByName("deleteFriend")   	 --删除好友
    tolua.cast(deleteFriend,"UIButton")
    deleteFriend:registerEventScript(clicks)
	local chat = mFriendInfoRoot:getWidgetByName("chat")           			 --聊天
    tolua.cast(chat,"UIButton")
    chat:registerEventScript(clicks)
	
	info, poInfo,skillInfo ={},0,{}
	if bundle ~= nil then
		local key = bundle[1]
		info, poInfo,skillInfo = FriendDataCache.getCurFriendInfo_list(key)
		addFriend:setEnabled(false)
	else
		
		local  se = FriendDataCache.info_search()
		table.insert(info,se) 
		poInfo =se.battle_prop.power
		skillInfo = se.battle_prop.sculpture
		addFriend:setEnabled(true)
		addFriend:setVisible(true)
		deleteFriend:setEnabled(false)
		chat:setEnabled(false)
	end	
end

FriendInfo.init = function(bundle)  
    mFriendInfoRoot = UIManager.findLayerByTag("UI_FriendInfo") 
	curBundle = bundle
	local closeBtn = mFriendInfoRoot:getWidgetByName("close")   				 --关闭
    tolua.cast(closeBtn,"UIButton")
    closeBtn:registerEventScript(clicks)
	
	setAddVisOrNo(bundle)
	setPower(poInfo,skillInfo)
	setPublicInfo(info)	
end



