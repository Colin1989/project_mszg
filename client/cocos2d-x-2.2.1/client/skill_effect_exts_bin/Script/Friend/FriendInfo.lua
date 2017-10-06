
-------------------------------------
--作者：李慧琴
--说明：好友详细信息界面
--时间：2014-3-3
-------------------------------------

local  friendId --保存当前的好友id

FriendInfo = {}

local mFriendInfoRoot = nil      --当前界面的根节点

LayerAbstract:extend(FriendInfo)

local function clicks(type,widget)
    widgetName = widget:getName()
if type == "releaseUp" then
    if widgetName == "chat" then
		
	    UIManager.pop("UI_FriendInfo")              --出现聊天界面
	    UIManager.push("UI_FriendChat",friendId)

    elseif widgetName == "deleteFriend"  then
	
		local structConfirm ={
          strText ="确定删除该好友？",		
		  buttonCount = 2,
		  buttonName = {"确定","取消"},
		  buttonEvent ={FriendDataCache.reqDelFriend_delete,nil},
		  buttonEvent_Param = {friendId,nil}
		}
        UIManager.push("UI_ComfirmDialog",structConfirm)    --处理删除好友结果
		
    elseif widgetName == "close"  then
        UIManager.pop("UI_FriendInfo")
		LayerFriendList.setUI( "friendImage",1)
    end

   end
end


FriendInfo.init = function(bundle)
      
    mFriendInfoRoot = UIManager.findLayerByTag("UI_FriendInfo")
   -- value =  bundle  
     local page = bundle[2]
	local key = bundle[1]
	
	print(key,page, bundle[1], bundle[2])
      local info, poInfo,skillInfo = FriendDataCache.getFriendInfo_list(key,page)
	
     local power = mFriendInfoRoot:getWidgetByName("power")        --战斗力
    tolua.cast(power,"UILabel")
	power:setText(poInfo)
	
	for key,value in pairs(skillInfo) do
		local skill1 =  mFriendInfoRoot:getWidgetByName(string.format("skill%d",key))
		  ---根据id找到技能的图标
		 local  skillAllInfo = GameSkillConfig.getSkillBaseInfo( value)
		 if  skillAllInfo ~= nil then
		     print("技能的id：",key,value,skillAllInfo.icon_file_name)
		    tolua.cast(skill1,"UIImageView")
		    skill1:loadTexture(skillAllInfo.icon_file_name)
		 end
	end
	
	
for key,value in pairs(info)  do
	
   friendId = value.friend_id
   print("好友id：",friendId)
    local name = mFriendInfoRoot:getWidgetByName("name")            --角色名
    tolua.cast(name,"UILabel")
    name:setText(value.nickname)
    local head = mFriendInfoRoot:getWidgetByName("head")            --角色头像
    tolua.cast(head,"UIImageView")
    head:loadTexture( ModelPlayer.getRoleInitDetailMessageById( value.head).heroicon)
    local level = mFriendInfoRoot:getWidgetByName("level")          -- 等级
    tolua.cast(level,"UILabel")
    level:setText(value.level)
    local rowType = mFriendInfoRoot:getWidgetByName("roleType")     --职业 
    tolua.cast(rowType,"UILabel")
    rowType:setText(CommonFunc_GetRoletypeString(tonumber(value.head)))     
    local public = mFriendInfoRoot:getWidgetByName("public")        --公会
    tolua.cast(public,"UILabel")
    public:setText(value.public)
	local athletics = mFriendInfoRoot:getWidgetByName("athletics")        --竞技？？？？？、暂时还没有
    tolua.cast(athletics,"UILabel")
	athletics:setText("暂时还没有")
	
end
	
     local chat = mFriendInfoRoot:getWidgetByName("chat")            --聊天
    tolua.cast(chat,"UIButton")
    chat:registerEventScript(clicks)
    local deleteFriend = mFriendInfoRoot:getWidgetByName("deleteFriend")   --删除好友
    tolua.cast(deleteFriend,"UIButton")
    deleteFriend:registerEventScript(clicks)
    local close = mFriendInfoRoot:getWidgetByName("close")    --关闭
    tolua.cast(close,"UIButton")
    close:registerEventScript(clicks)  
	
end



