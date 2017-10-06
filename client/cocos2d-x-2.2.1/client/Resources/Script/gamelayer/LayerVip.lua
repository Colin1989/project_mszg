LayerVip = setmetatable({},{__mode='k'})

LayerVip.jsonFile = "mszg_vip_1.json"



local mRootView = nil 
local mEnter_layer = nil	--表示从什么界面进来的
local mVipInfo = XmlTable_load("vip_tplt.xml", "id")

--当前旗帜是多少VIP等级
local VipLevel = 1
local lastVipBtn = nil

local mGradeGift = nil 
local mDialyBtn = nil 

--VIP礼包领取消息
local mdaily_rewarded = nil   --0 未领取 1 已领取
local mlevel_rewarded_list = nil 


local function isGreyButton(lv)
	if ModelPlayer.getVipLevel() >=  lv then 
		return true
	end 
	return false
end 



--排序VIP
local function VipSort()
	local tb = {}
	for k, v in pairs(mVipInfo.map) do
		table.insert(tb, v)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return tb
end
-- 当前VIP_INFO
function VipInfo(__vipLv)
	return mVipInfo.map[tostring(__vipLv)]
end 

--创建文本文字
local function createCopyText(text,pos,size)
	local label =UILabel:create()      --往里面添加好友说的话，   
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPosition(pos)
	label:setFontSize(size)
	label:setText(text)
	label:setFontName("fzzdh.TTF")
	label:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	return label
end

local mGiftStrBufTb = {}

local function setShowGiftTb(_data)
    mGiftStrBufTb = {}
    for k,v in pairs(_data)  do 
        local str = string.format("%s * %d",v.name,tonumber(v.amount))
        table.insert(mGiftStrBufTb,str)
    end 
end 


local function showReWard(stringBuf,icount)
     local tb = stringBuf 
     local index = 1
     local str = ""
     for k,v in pairs(tb) do 
       
        if index < icount then 
            str = str..v.." "
            index = index + 1
        else 
            str = str..v.." "
            Toast.show(str)
            index = 1 
            str = ""
        end 
     end  
     
     if str ~= "" then 
         Toast.show(str)
     end  
end 

--领取VIP等级礼包
local function handle_vip_grade_reward_result(resp)
	if resp.result == 1 then 
		--Toast.show(GameString.get("PUBLIC_YI_LING_QU") )
        showReWard(layerVipGradeGift.getVipStrBuf(VipLevel),3)
		setBtnStatus(mGradeGift,false)
		table.insert(mlevel_rewarded_list,VipLevel)
		UIManager.popBounceWindow("UI_TempPack")
	end 
end

local function send_grade_reward_result()
	local req = req_vip_grade_reward()
	req.level = VipLevel
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_vip_grade_reward_result"])
end 

NetSocket_registerHandler(NetMsgType["msg_notify_vip_grade_reward_result"], notify_vip_grade_reward_result, handle_vip_grade_reward_result)
-- 领取每日礼包
local function handle_vip_daily_reward_result(resp)
	if resp.result == 1 then 
		--Toast.show(GameString.get("PUBLIC_YI_LING_QU") )
        showReWard(mGiftStrBufTb,3)
		if mDialyBtn ~= nil then 
			setBtnStatus(mDialyBtn,false)
			mdaily_rewarded = 1
			--Lewis:spriteShaderEffect(mDialyBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		end 
		UIManager.popBounceWindow("UI_TempPack")
	end 
end

local function send_daily_reward()
	local req = req_vip_daily_reward()
	NetHelper.sendAndWait(req, NetMsgType["msg_notify_vip_daily_reward_result"])
end 

NetSocket_registerHandler(NetMsgType["msg_notify_vip_daily_reward_result"], notify_vip_daily_reward_result, handle_vip_daily_reward_result)


local function handle_notify_vip_reward_info(resp)
   mlevel_rewarded_list = resp.level_rewarded_list
   mdaily_rewarded = resp.daily_rewarded
end 

NetSocket_registerHandler(NetMsgType["msg_notify_vip_reward_info"], notify_vip_reward_info, handle_notify_vip_reward_info)


--  vip

local function handle_onClick(typeName,widget) 
	if typeName == "releaseUp" then
		local curName = widget:getName()
		if curName == "cl" then 
			if mEnter_layer ~= nil then 	
				setConententPannelJosn(mEnter_layer, mEnter_layer.jsonFile, typeName)
			else 
				LayerMain.pullPannel(LayerVip)
			end 
		--充值
		elseif curName == "vip_rechange" then 
			setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
			EventCenter_post(EventDef["ED_ENTER_RECHARGE"], LayerVip)
		--查看大礼包
		elseif curName == "vig_bigreward" then  
			UIManager.push("UI_VipGradeGift",VipLevel)
		-- 领取VIP大礼
		elseif curName == "getbigvir_reward" then 
			send_grade_reward_result()
		-- 领取每日VIP奖励
		elseif curName == "getbigvip_everyrewards" then 
			send_daily_reward()
		end 
	end 
end

--vip 特权  fixme Lv

local function Update_Vip_Privilege(RootView,VipLevel)
	local vipDescList = RootView:getChildByName("vip_privilege_desc_list")
	vipDescList:removeAllChildren()
	
	local labelItem = {}
	local PrivilegeIdTB = CommonFunc_split(VipInfo(VipLevel).privilege_ids,",")
	local PrivilegeAmountTB = CommonFunc_split(VipInfo(VipLevel).privilege_amounts,",")
	
	for k,v in pairs(PrivilegeIdTB) do
		local text = string.format(VIP_DESC[tonumber(v)],tonumber(PrivilegeAmountTB[k]))
		local label = createCopyText(k..":"..text,ccp(0,0),22)
		table.insert(labelItem,label)
	end
	setAdapter(vipDescList,labelItem,1,5,10)
	
	local vipDescSlider = RootView:getChildByName("Slider_145")
	CommonFunc_setScrollPosition(vipDescList,vipDescSlider)
end 




--vip 每日礼包
local function Update_VipEveryDayReWards(RootView,VipLevel)
	VipLevel = tonumber(VipLevel)
	local vip_everyreward_list = RootView:getChildByName("vip_everyreward_list")
	tolua.cast(vip_everyreward_list,"UIScrollView")
	vip_everyreward_list:removeAllChildren()
	
	local ItemTb = {}
	local daily_gift_bag_ids = CommonFunc_split(VipInfo(VipLevel).daily_gift_bag_ids,",")
	local daily_gift_bag_amounts = CommonFunc_split(VipInfo(VipLevel).daily_gift_bag_amounts,",")
	
	
	
	local data = {}
	for k,v in pairs(daily_gift_bag_ids) do
		local ItemDate = LogicTable.getRewardItemRow(v)
		ItemDate.amount = daily_gift_bag_amounts[k]
		table.insert(data,ItemDate)
	end 

    setShowGiftTb(data)


	local function createCell(ItemDate)
		local rootView = UIImageView:create()
		rootView:loadTexture("vip_gift_bg.png")
		rootView:setScale(0.85)
		
		local icon = nil -- 图标
		local Label_name = createCopyText(ItemDate.name,ccp(0,54),20)
		Label_name:setScale(1.05)
		local  Label_amount= createCopyText(string.format("%d",ItemDate.amount),ccp(0,-54),22)
		Label_amount:setScale(1.05)
		if 13 == ItemDate.type then 
			icon = CommonFunc_AddGirdWidget_Rune(ItemDate.temp_id, 0, nil, nil)
		else 
			icon = reward_AddGirdWidget(ItemDate.icon, ItemDate.temp_id,0, nil, nil,nil)
		end
		
		icon:setTouchEnabled(true)
		local function clickSkillIcon(icon)
			showLongInfoByRewardId(ItemDate.id,icon)
		end
		
		local function clickSkillIconEnd(icon)
			longClickCallback_reward(ItemDate.id,icon)
		end

		UIManager.registerEvent(icon, nil, clickSkillIcon, clickSkillIconEnd)
		
		
		
		icon:setScale(0.9)
		rootView:addChild(icon)
		rootView:addChild(Label_name)
		rootView:addChild(Label_amount)
		return rootView
	end

	UIEasyScrollView:create(vip_everyreward_list,data,createCell,4, true,0,2,true)	
	local vipEveryreWardSlider = RootView:getChildByName("Slider_179")
	CommonFunc_setScrollPosition(vip_everyreward_list,vipEveryreWardSlider)
	
end

function setBtnStatus(WidgetBtn, _Status)
	if _Status == true then
		WidgetBtn:registerEventScript(handle_onClick)
		Lewis:spriteShaderEffect(WidgetBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	else
		WidgetBtn:unregisterEventScript()
		Lewis:spriteShaderEffect(WidgetBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	end
end

local function isRewardCurGift(level) 
	level = tonumber(level)
	if level > ModelPlayer.getVipLevel() then 
		return false
	else  	
		for k,v in pairs( mlevel_rewarded_list) do
			if tonumber(v) == level then 
					return false
			end
		end 
	end 
	return true
end

local function initBtn(rootview)
	rootview:getChildByName("vip_rechange"):registerEventScript(handle_onClick)
	rootview:getChildByName("vig_bigreward"):registerEventScript(handle_onClick)
	rootview:getChildByName("cl"):registerEventScript(handle_onClick)
	
	mGradeGift = rootview:getChildByName("getbigvir_reward")
	--mGradeGift:registerEventScript(handle_onClick)
	setBtnStatus(mGradeGift,isRewardCurGift(VipLevel))
	
	mDialyBtn = rootview:getChildByName("getbigvip_everyrewards")
	
	if ModelPlayer.getVipLevel() == 0 then 
		--Lewis:spriteShaderEffect(mDialyBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		setBtnStatus(mDialyBtn, false)
	elseif mdaily_rewarded == 0 then
		--mDialyBtn:registerEventScript(handle_onClick)
		setBtnStatus(mDialyBtn, true)
	elseif mdaily_rewarded == 1 then
		setBtnStatus(mDialyBtn, false)
		--Lewis:spriteShaderEffect(mDialyBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	end
end 

local function setVipInfo(RootView)
	--vip level
	local lvLabAas = RootView:getChildByName("vip_lv_Number")
	tolua.cast(lvLabAas,"UILabelAtlas") 
	lvLabAas:setStringValue(string.format("%d", ModelPlayer.getVipLevel()))
	--vip label
	local lvLabel = RootView:getChildByName("vip_label_desc")
	tolua.cast(lvLabel,"UILabel") 
	
	local loadBar = RootView:getChildByName("LoadingBar_118")
	tolua.cast(loadBar,"UILoadingBar") 
		
	if ModelPlayer.getVipLevel() == #VipSort() then 
		lvLabel:setText("最高等级")
		loadBar:setPercent(100)
	else
		lvLabel:setText(ModelPlayer.getMoney().."/"..VipInfo(ModelPlayer.getVipLevel()+1).need_money/100)
		local ratio = 100.0* ModelPlayer.getMoney()/tonumber(VipInfo(ModelPlayer.getVipLevel()+1).need_money/100)
		loadBar:setPercent(ratio)
	end
end
--[[
local VipLevel = 1
local lastVipBtn = nil
]]--


local function OnItemVipClock(typeName,widget)
	if typeName == "releaseUp" then
		local curVipLv = widget:getName()

		if tonumber(curVipLv) == VipLevel then 
			return 
		end
		
		if isGreyButton(VipLevel) == true then 
			lastVipBtn:loadTexture("vip_flag_normal.png")
		else 
			lastVipBtn:loadTexture("vip_grey_normal.png")
		end 
		
		VipLevel = tonumber(curVipLv)
		
		--判断每日礼包是否可以领取
		if mdaily_rewarded == 0 and  ModelPlayer.getVipLevel() == VipLevel then 
			setBtnStatus(mDialyBtn,true)
		else 
			setBtnStatus(mDialyBtn,false)
		end 
		
		--判断当前等级礼包是否可以领取
		setBtnStatus(mGradeGift,isRewardCurGift(VipLevel))
		tolua.cast(widget,"UIImageView") 
			
		if isGreyButton(VipLevel) == true then 
			widget:loadTexture("vip_flag_bright.png")
		else 
			widget:loadTexture("vip_grey_bright.png")
		end 
		
		lastVipBtn = widget
		Update_VipEveryDayReWards(mRootView,curVipLv)
		Update_Vip_Privilege(mRootView,curVipLv)
	end
end 

local function initVipList(RootView)
	local vipList = RootView:getChildByName("vip_list")
	
	local VipItem = {}
	for k,v in pairs(VipSort()) do
		local vipLvView = UIImageView:create()
		if isGreyButton(k) == true then 
			vipLvView:loadTexture("vip_flag_normal.png")
		else
			vipLvView:loadTexture("vip_grey_normal.png")
		end 
		vipLvView:registerEventScript(OnItemVipClock)
		vipLvView:setTouchEnabled(true)
		vipLvView:setName(k.."")
		
		if k == VipLevel then 
			lastVipBtn = vipLvView
			
			if isGreyButton(k) == true then 
				vipLvView:loadTexture("vip_flag_bright.png")
			else 
				vipLvView:loadTexture("vip_grey_bright.png")
			end 
		end 
		
		--vip_lv
		local LabelAtlas =  UILabelAtlas:create()
		LabelAtlas:setPosition(ccp(25,5))
		LabelAtlas:setProperty(k,"vip_lv_num.png", 20, 24, "0");
		vipLvView:addChild(LabelAtlas)	
		table.insert(VipItem,vipLvView)	
	end 
	setAdapterGridView(vipList,VipItem,1,0) 

    if ModelPlayer.getVipLevel()>7 then 
        --local vipList = mRootView:getChildByName("vip_list")
        tolua.cast(vipList,"UIScrollView")
       -- vipList:jumpToBottom()
        vipList:scrollToBottom(0.3, false);
    end 
end 

local function initView(RootView)
	initBtn(RootView)
	initVipList(RootView)
	Update_Vip_Privilege(RootView,VipLevel)
	Update_VipEveryDayReWards(RootView,VipLevel)
	setVipInfo(RootView)
end

local mVipInfo = {}

--[[
	1:"每日多领取%d个召唤石",           
	2:"每日训练赛挑战次数增加%d次"         
	3:"每日分组赛挑战次数增加%d次",    
	4:"每日排位赛挑战次数增加%d次",
	5:"每日魔塔挑战次数增加%d次",
	6:"每日普通炼金次数增加%d次",
	7:"每日魔石炼金次数增加%d次",
	8:"每日购买体力次数增加%d次"
]]--

function getVipAddValueById(id)
    local  value = 0
    for k,v in pairs(mVipInfo) do
        if tonumber(v.id) == id then 
            value = v.value
        end
    end 
    return value
end


LayerVip.UpdateVipInfo = function (vipLevel)
    mVipInfo = {}
    if vipLevel == 0 or vipLevel == "0" then return end  

    vipLevel = tostring(vipLevel)
    local PrivilegeIdTB = CommonFunc_split(VipInfo(vipLevel).privilege_ids,",")
	local PrivilegeAmountTB = CommonFunc_split(VipInfo(vipLevel).privilege_amounts,",")

    for k,v in pairs(PrivilegeIdTB) do
        local tb = {}
        tb.id = v
        tb.value = PrivilegeAmountTB[k]
		table.insert(mVipInfo,tb)
	end
end 

LayerVip.init = function(RootView)
	mRootView= RootView
	if ModelPlayer.getVipLevel() ~= nil and  ModelPlayer.getVipLevel() > 0 then 
		VipLevel = ModelPlayer.getVipLevel()
    else 
        VipLevel = 1
	end 
	initView(RootView)	
end 

LayerVip.destroy = function()
	
	mEnter_layer = nil
end
--------------------------------------------------------------------------------------
local function handleEnter_Vip(param)
	mEnter_layer = param
end 
EventCenter_subscribe(EventDef["ED_ENTER_VIP"], handleEnter_Vip)

----------------------------------test_code
--[[
local uilayer = UILayer:create()
local jsonWidget = LoadWidgetFromJsonFile("mszg_vip_grade_gift_1.json")
jsonWidget:setAnchorPoint(ccp(0.0, 0.0))
uilayer:addWidget(jsonWidget)
g_sceneRoot:addChild(uilayer)
--LayerVip.init(jsonWidget)
local vip_everyreward_list = jsonWidget:getChildByName("ScrollView_gift")	
local ItemTb = {}

tolua.cast(vip_everyreward_list,"UIScrollView")
local data = { }	
for k=1 ,17 do 
	local tb = {}
	tb.index = k
	table.insert(data,tb)
end 

local function createCell(data)
		print("-----------------------",data.index)
		local btn = CommonFunc_AddGirdWidget(6002, data.index, nil, nil)
		btn:setTouchEnabled(true)
		return btn
end
	
UIEasyScrollView:create(vip_everyreward_list,data,createCell,16, true,15,4)	

]]--