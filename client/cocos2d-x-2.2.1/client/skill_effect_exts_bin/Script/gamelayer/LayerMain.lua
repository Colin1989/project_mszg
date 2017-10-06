----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-26
-- 描述：主界面
----------------------------------------------------------------------

local mLayerRoot = nil					--主界面根节点
local mLayerPanel = nil					--主界面的中间部分
local image = nil                      --未读图标


local curRoot = nil
LayerMain = {
}


LayerAbstract:extend(LayerMain)


local mStatus = "mainbtn_main"

--获取当前主界面展示状态
LayerMain.getCurStatus  =function()
	return mStatus
	--对应的值
	--"mainbtn_main"	--主页
	--"mainbtn_fight"	--战斗
	--"main_bag"		--背包
	--"mainbtn_friend"	--好友
	--"mainbtn_shop"	--商店
	--"mainbtn_sys"		--设置
	
end


LayerMain.onClick =function (weight)
	local weightName = weight:getName()
	if weightName == "Button_81" then		--购买体力
		if POWER_UP_MAX == ModelPlayer.power_hp then
			Toast.show( GameString.get("Ppfull"))
		else
			UIManager.push("UI_ComfigDialog",GameString.get("BuyPp",ModelPlayer.power_hp_buy_times))
		end
	end
end
function LayerMain_onClick(weight)
	local weightName = weight:getName()
	mStatus = weightName
	
	BackpackUIManage.removeAllUIlayer()
	
	if weightName == "mainbtn_main" then	--主页
        setConententPannelJosn(LayerMainEnter,"MainEnter_1.ExportJson")	
	elseif weightName == "mainbtn_fight" then		--战斗
		setConententPannelJosn(LayerLevelSelcet,"CopyBackgournd_1.ExportJson")	
	elseif weightName == "main_bag" then		-----背包
		setConententPannelJosn(LayerBackpack,"Backpack_Bag.ExportJson")
    elseif weightName == "mainbtn_friend" then   --好友
	    LayerMain.showUnreadInfo("false")                     -------------------------------------------addedBy Lihq  3.19
        setConententPannelJosn(LayerFriendList,"FriendBackground_1.ExportJson")      
    elseif weightName == "Button_set" then    --设置
	end
end

function LayerMain.getContendPanel()
	local Panel_contend =  mLayerRoot:getWidgetByName("Panel_contend")
	tolua.cast(Panel_contend,"UILayout")
	return Panel_contend
end

--动态加载json文件  index 根据按钮给值
function setConententPannelJosn(this,josnfile)
	local Panel_contend =  mLayerRoot:getWidgetByName("Panel_contend")
	tolua.cast(Panel_contend,"UILayout")

	if nil ~= mLayerPanel then
		if nil ~= mLayerPanel.destory then
			mLayerPanel.destory()
		end
		mLayerPanel = nil
	end
	Panel_contend:removeAllChildren()
	mLayerPanel = this
	
	if josnfile == "Backpack_Bag.ExportJson" then
		BackpackUIManage.init()
		BackpackUIManage.addLayer("UI_Bag")
		return 
	end
	
	--当前添加的层
	--local layer = getContentViewByIndex(index)
	local ContentView = GUIReader:shareReader():widgetFromJsonFile(josnfile)
	ContentView:setAnchorPoint(ccp(0.0,0.0))
	Panel_contend:addChild(ContentView)

	this.init(Panel_contend,ContentView)		--FIXME保护
	
end

local function setPowUpLoadingBar(value)
		-- power_bar
	local power_hp = value
	local loadingBar = mLayerRoot:getWidgetByName("LoadingBar_31");
	tolua.cast(loadingBar,"UILoadingBar")
	local ratio = power_hp/POWER_UP_MAX *100.0
	loadingBar:setPercent(ratio)
	--power text
	local powerCurText = mLayerRoot:getWidgetByName("Label_46"); --体力当前数值
	tolua.cast(powerCurText, "UILabel")
	local pp = string.format("/%d",POWER_UP_MAX)
	powerCurText:setText(power_hp..pp)
end

-- 事件机制派发 事件类型：ED_UPDATE_ROLE_INFO
local function updateRoleInfo(playerData)
	if nil == playerData then
		print("empty playerData"); 
		return
	end
	
	if(UIManager_UItable["UI_Main"].status ~= "onStart") then
		print("不在当前界面不刷新")
		return
	end

	setPowUpLoadingBar(playerData.power_hp)	--设置体力进度条
	--头像
	local playerIcon = mLayerRoot:getWidgetByName("hero_imageview")
	tolua.cast(playerIcon, "UIImageView")
	playerIcon:loadTexture( ModelPlayer.getRoleInitDetailMessageById( ModelPlayer.roletype).heroicon ) 

	-- PlayerName
	local nameText = mLayerRoot:getWidgetByName("Player_Name");
	tolua.cast(nameText, "UILabel")
	nameText:setText(playerData.nickname)
	--nameText:setTextAreaSize(CCSizeMake(80,30))
	--PlayerLv text
	local Lv = mLayerRoot:getWidgetByName("LabelAtlas_42")-- 等级
	tolua.cast(Lv,"UILabelAtlas") 
	Lv:setStringValue(ModelPlayer.level)
	--Player Gold
	local moneyTest = mLayerRoot:getWidgetByName("LabelAtlas_gold")-- 金币
	tolua.cast(moneyTest,"UILabelAtlas") 
	moneyTest:setStringValue(ModelPlayer.gold)
	--Player eGold
	local eMoneyTest = mLayerRoot:getWidgetByName("LabelAtlas_rmb")-- 人民币
	tolua.cast(eMoneyTest,"UILabelAtlas") 
	eMoneyTest:setStringValue(ModelPlayer.emoney)
	--Player atk
	local moneyTest = mLayerRoot:getWidgetByName("LabelAtlas_atk")-- 攻击
	tolua.cast(moneyTest,"UILabelAtlas") 
	moneyTest:setStringValue(ModelPlayer.atk)
	--Player left_powerUp
	local playerPowerUpTest = mLayerRoot:getWidgetByName("power_time")	-- 剩余体力
	tolua.cast(playerPowerUpTest, "UILabel")
	playerPowerUpTest:setText( CommonFunc_secToString (ModelPlayer.recover_time_left)) 


end

local function initButtonAndEvent(eventType)

	local BtnList = {}

	local function ceateBtnList(widgetName,N_ImageName,H_ImageName,isBright) 
		 local widgetSingle = {}
		 widgetSingle.isBright = isBright
		 widgetSingle.name = widgetName
		 widgetSingle.N_image = N_ImageName
		 widgetSingle.H_image = H_ImageName
		--print(k,"--------------->",mLayerRoot:getWidgetByName(widgetName))
		 widgetSingle.widget = mLayerRoot:getWidgetByName(widgetName)
		if isBright == true then
			tolua.cast(widgetSingle.widget,"UIImageView")
			widgetSingle.widget:loadTexture(widgetSingle.H_image,UI_TEX_TYPE_PLIST)
		end
		table.insert(BtnList,widgetSingle)
	end

	if eventType == "init" then -- 返回主页
		ceateBtnList("mainbtn_main","mainui_btn_mainui_n.png","mainui_btn_mainui_h.png",true)
		setConententPannelJosn(LayerMainEnter,"MainEnter_1.ExportJson")	
	else 
		ceateBtnList("mainbtn_main","mainui_btn_mainui_n.png","mainui_btn_mainui_h.png",false)
	end

	if eventType == "fightOver" then
		ceateBtnList("mainbtn_fight",	"mainui_btn_warmap_n.png","mainui_btn_warmap_h.png",true)
		setConententPannelJosn(LayerLevelSelcet,"CopyBackgournd_1.ExportJson")
	else
		ceateBtnList("mainbtn_fight",	"mainui_btn_warmap_n.png","mainui_btn_warmap_h.png",false)
	end
	
	if eventType == "bag" then
		ceateBtnList("main_bag", "mainui_btn_bag_n.png","mainui_btn_bag_h.png",true)
		setConententPannelJosn(LayerBackpack,"Backpack_Bag.ExportJson")
	else
		ceateBtnList("main_bag", "mainui_btn_bag_n.png","mainui_btn_bag_h.png",false)
	end

	ceateBtnList("mainbtn_main","mainui_btn_mainui_n.png","mainui_btn_mainui_h.png",false)
	ceateBtnList("mainbtn_fight",	"mainui_btn_warmap_n.png","mainui_btn_warmap_h.png",false)
	ceateBtnList("main_bag", "mainui_btn_bag_n.png","mainui_btn_bag_h.png",false)
	ceateBtnList("mainbtn_friend",	"mainui_btn_friend_n.png","mainui_btn_friend_h.png",false)
	ceateBtnList("mainbtn_shop",	"mainui_btn_busniss_n.png","mainui_btn_busniss_h.png",false)
	ceateBtnList("mainbtn_sys",	"mainui_btn_setup_n.png","mainui_btn_setup_h.png",false)

	SetSingleChooseBtn(BtnList,LayerMain_onClick)
	
end

function SetSingleChooseBtn(BtnList,func_callback)	
	local function handle_onClick(typeName,widget) 
		if typeName == "releaseUp" then
			local curName = widget:getName()
			local curValue = nil
			for key,value in pairs(BtnList) do	--取消原来两的东西
				if value.isBright == true then
					if curName == value.name then -- 如果连续同时按一个按钮 不触发事件
						return
					end
					tolua.cast(widget,"UIImageView")
					value.widget:loadTexture(value.N_image,UI_TEX_TYPE_PLIST)
					value.isBright = false
				end 
				if curName == value.name then 
					curValue = value
				end
			end
			func_callback(widget)
			tolua.cast(widget,"UIImageView")
			widget:loadTexture(curValue.H_image,UI_TEX_TYPE_PLIST)
			curValue.isBright = true
		end
	end


	for k,v in pairs(BtnList) do
		v.widget:registerEventScript(handle_onClick)
		
	end
end
--LayerMain.set = function

LayerMain.init = function(bound)	
	LayerMain.Timer = true		--开启定时器
	mLayerRoot = UIManager.findLayerByTag("UI_Main") --UIManager.Create("UI_main")
	
	--setConententPannelJosn(1) 初始化界面
	setOnClickListenner("Button_81")
	
	--addedBy  lihq 3.24
    image = nil  
	if FriendDataCache.getLengthOfUnreadInfo_process() ~= 0 or #FriendDataCache.receiveTb_receive() ~= 0  then  
	    print("我不为0啊，被重新设置了")
	    LayerMain.showUnreadInfo(true)
	elseif  FriendDataCache.getLengthOfUnreadInfo_process() ~= 0 and #FriendDataCache.receiveTb_receive() ~= 0  then 
	    print("我不为0啊，被重新设置了0000000")
	     LayerMain.showUnreadInfo(true)
	end
	
	
	initButtonAndEvent(bound)
	EventCenter_subscribe(EventDef["ED_UPDATE_ROLE_INFO"], updateRoleInfo)
end

LayerMain.update = function(dt)
	local leftTime,powerUp = ModelPlayer.updatePowerUp(dt)
	if (leftTime) then
		if (powerUp ~= nil)then
			setPowUpLoadingBar(powerUp)
		end
		local playerPowerUpTest = mLayerRoot:getWidgetByName("power_time")	-- 剩余体力
		tolua.cast(playerPowerUpTest, "UILabel")
		if leftTime == "full" then 
			playerPowerUpTest:setVisible(false)
		else
			playerPowerUpTest:setVisible(true)
			playerPowerUpTest:setText(leftTime)
		end
	end
end

-- add by fjut on 2014-03-12
-- 切换pannel
LayerMain.switchPannel = function(pannelNode)
	if mLayerRoot == nil then
		return false
	end
	
	local pannel = mLayerRoot:getWidgetByName("Panel_contend")
	if pannel == nil then
		return false
	end
	
	-- delete
	tolua.cast(pannel, "UILayout")
	pannel:removeAllChildren() -- safe ?
	
	-- 衔接
	if pannelNode == LayerMain then
		setConententPannelJosn(LayerMainEnter, "MainEnter_1.ExportJson")
		return true
	end
	
	local guiNode = pannelNode.init()
	if guiNode == nil then
		return false
	end	
	-- add
	pannel:addChild(guiNode)
		
	return true
end

-- 切换Layer 
LayerMain.switchLayer = function(layer)
	cclog("switchLayer ！")
	-- 援助layer
	if layer == LayerAssistance then
		cclog("LayerAssistance in ！")
		UIManager.push("UI_Assistance") 
	-- 进入战斗
	elseif layer == "EnterGame" then
		UIManager.destroyAllUI()
        StartLoading()
	else
		cclog("fuck ")
	end
end

-- 竞技场消息气泡
local gameRankTipsNum = 0
local msgNumLabel = nil

-- set消息数量
LayerMain.setMsgNum = function(num)
	gameRankTipsNum = num
	LayerMain.updatePannel(LayerMainEnter)
end

-- get消息数量
LayerMain.getMsgNum = function()
	return gameRankTipsNum
end

-- 接收推送消息
local function Handle_req_showGameRankMsgTips(resp)
	cclog("竞技场消息气泡:"..resp.times)
	LayerMain.setMsgNum(resp.times)
end

-- 更新pannel
LayerMain.updatePannel = function(pannelNode)
	-- 竞技场更新提醒消息数量
	if pannelNode == LayerMainEnter then
		pannelNode.updateMsgNum(gameRankTipsNum)
	end
	-- todo
	-- ...
end

-- 推送消息reg
NetSocket_registerHandler(NetMsgType["msg_notify_be_challenged_times"], notify_be_challenged_times(), Handle_req_showGameRankMsgTips)
-- fjut add end



-------------------------------------------addedBy Lihq  3.19----------
--当有好友信息时，就显示未读图标(好友请求，好友聊天信息)
LayerMain.showUnreadInfo = function(str)
    local friend = mLayerRoot:getWidgetByName("mainbtn_friend")
	tolua.cast(friend,"UIImageView")
	if image == nil then
	   image = UIImageView:create()
	   image:setPosition(ccp(452,79))
	   image:setAnchorPoint(ccp(0.5,0.5))
	   image:setZOrder(2)
	   image:setName("remove")
	   mLayerRoot:addWidget(image)
	   image:setVisible(true)
	   image:loadTexture("friends_notice2.png",UI_TEX_TYPE_PLIST)                    -----------------图片有待更改
    end
    if str == "true" then               --我要显示了
		return
	elseif str == "false" then           --我要隐藏了
	      image:setVisible(false)
	end
	
end

















