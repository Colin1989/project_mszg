layerVipGradeGift = setmetatable({},{__mode='k'})

local mLayerVipGradeGiftRoot = nil 


layerVipGradeGift.onClick = function (weight)
	local weightName = weight :getName()
    if weightName == "close_btn" then
		UIManager.pop("UI_VipGradeGift")
	end 
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



local function setVipEveryDayReWards(vipLevel)
	local ScrollView_gift = mLayerVipGradeGiftRoot:getWidgetByName("ScrollView_gift")
	ScrollView_gift:removeAllChildren()
	tolua.cast(ScrollView_gift,"UIScrollView")

	local grade_gift_bag_ids = CommonFunc_split(VipInfo(vipLevel).grade_gift_bag_ids,",")
	local grade_gift_bag_amounts = CommonFunc_split(VipInfo(vipLevel).grade_gift_bag_amounts,",")
	

	local data = {}
	for k,v in pairs(grade_gift_bag_ids) do
		local ItemDate = LogicTable.getRewardItemRow(v)
		ItemDate.amount = grade_gift_bag_amounts[k]
		table.insert(data,ItemDate)
	end 

	local function createCell(ItemDate)
		local rootView = UIImageView:create()
		rootView:loadTexture("vip_gift_bg.png")
		rootView:setScale(0.95)
	
		local icon = nil -- 图标
		local Label_name = createCopyText(ItemDate.name,ccp(0,52),22)
		local  Label_amount= createCopyText(string.format("%d",ItemDate.amount),ccp(0,-51),24)
		if 8 == ItemDate.type then 
			icon = CommonFunc_AddGirdWidget_Rune(ItemDate.temp_id, 0, nil, nil)
		elseif 13 == ItemDate.type then
			icon = UIImageView:create()
			icon:loadTexture(ItemDate.icon)
			CommonFunc_SetQualityFrame(icon)
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
		
	
		icon:setScale(0.8)
		rootView:addChild(icon)
		rootView:addChild(Label_name)
		rootView:addChild(Label_amount)
		return rootView
	end
	
	UIEasyScrollView:create(ScrollView_gift,data,createCell,16, true,3,3,false)	
end 

layerVipGradeGift.getVipStrBuf = function(vipLevel)
    local tb = {}

    local grade_gift_bag_ids = CommonFunc_split(VipInfo(vipLevel).grade_gift_bag_ids,",")
	local grade_gift_bag_amounts = CommonFunc_split(VipInfo(vipLevel).grade_gift_bag_amounts,",")

    local _data = {}
	for k,v in pairs(grade_gift_bag_ids) do
		local ItemDate = LogicTable.getRewardItemRow(v)
		ItemDate.amount = grade_gift_bag_amounts[k]
		table.insert(_data,ItemDate)
	end 

    for k,v in pairs(_data)  do 
        local str = string.format("%s * %d",v.name,tonumber(v.amount))
        table.insert(tb,str)
    end 


    
    return tb
end

layerVipGradeGift.init = function(VipLevel)
	cclog("VipLevel",VipLevel)
	mLayerVipGradeGiftRoot = UIManager.findLayerByTag("UI_VipGradeGift")
	
	setVipEveryDayReWards(VipLevel)
	
	setOnClickListenner("close_btn")
end 


layerVipGradeGift.destroy = function()

end