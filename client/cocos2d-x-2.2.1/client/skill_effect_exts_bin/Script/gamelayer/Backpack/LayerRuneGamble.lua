--符文占卜

LayerRuneGamble = {}
local mLayerRoot = nil

--背包最大数量
local mBagNumMax = 10
--1 金币
--2 魔石
--3 友情
local mLayerType = 1

--货币图标
local mCurrency_iconPath = {"goldicon.png","rmbicon.png","fsicon.png"}

--背包数据 temp_id amount
local mBagTable = {}
LayerRuneGamble.divine_level = {}

--占卜等级图标
local iconString = {
	"public_Ball_Green.png","public_Ball_Blue.png",
	"public_Ball_Purple.png","public_Ball_Orange.png",
	"public_Ball_Red.png"
}

local function seedRuneGamble(iNum)
	if LayerBackpack.IsPackFull(true) == true then
		return
	end
	--print("#mBagTable",#mBagTable,"mBagNumMax",mBagNumMax)
	if mBagNumMax == #mBagTable then
		CommonFunc_CreateDialog("当前背包已满")
		return
	end
	
	local divine_table = ModelRune.getRune_divine_tplt(mLayerType).money_amounts
	local gold = 0
	local emoney = 0 
	local friend = 0
	local divine_level = LayerRuneGamble.divine_level[mLayerType]
	if mLayerType == 1 then
		gold = divine_table[divine_level]
	elseif mLayerType == 2 then
		emoney = divine_table[divine_level] 
	elseif mLayerType == 3 then
		friend = divine_table[divine_level] 
	end
	
	print("gold,emoney,friend",gold,emoney,friend)
	if CommonFunc_IsConsume(gold,emoney,friend) == false then
		return false
	end
	
	local tb = req_sculpture_divine()
	tb.money_type = mLayerType
	--[[
	if iNum > mBagNumMax - #mBagTable then
		iNum = mBagNumMax - #mBagTable
	end]]
	
	tb.times = iNum
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_divine"])
end

local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		
		if widgetName == "Button_close" then
			BackpackUIManage.closeLayer("UI_runeGamble")
			
		elseif widgetName == "Button_one" then
			seedRuneGamble(1)
				
		elseif widgetName == "Button_10" then
			seedRuneGamble(mBagNumMax - #mBagTable)
			
		
		elseif widgetName == "Button_clear" then
			mBagTable = {}
			LayerRuneGamble.updataWidget()
		end
	end
	
end


function LayerRuneGamble.init(root,param)
	print("~~~~~~~~~~~~~~~~~~~~LayerRuneGamble.init()")
	mLayerRoot = root
	mLayerType = param
	
	local btn = nil
	local ImageView = nil
	local label = nil
	mBagTable = {}
	
	btn =  mLayerRoot:getChildByName("Button_close")
	btn:registerEventScript(onClickEvent)
	
	btn =  mLayerRoot:getChildByName("Button_one")
	btn:registerEventScript(onClickEvent)
	
	btn =  mLayerRoot:getChildByName("Button_10")
	btn:registerEventScript(onClickEvent)
	
	btn =  mLayerRoot:getChildByName("Button_clear")
	btn:registerEventScript(onClickEvent)
	
	
	local divine_table = ModelRune.getRune_divine_tplt(mLayerType).money_amounts
	for i=1,5 do
		
		--货币图标
		ImageView = mLayerRoot:getChildByName("currency_icon_"..i)
		tolua.cast(ImageView,"UIImageView")
		print("mLayerType",mLayerType)
		print("mCurrency_iconPath[mLayerType]",mCurrency_iconPath[mLayerType])
		ImageView:loadTexture(mCurrency_iconPath[mLayerType],UI_TEX_TYPE_PLIST)
		--[[
		if mLayerType == 1 then
			loadTextureByPlist_UIImageView(ImageView,mCurrency_iconPath[1])	
		elseif mLayerType == 2 then
			loadTextureByPlist_UIImageView(ImageView,mCurrency_iconPath[2])
		elseif mLayerType == 3 then
			loadTextureByPlist_UIImageView(ImageView,mCurrency_iconPath[3])
		end
		]]
			
		--价格
		label = mLayerRoot:getChildByName("Label_currency_"..i)
		tolua.cast(label,"UILabel")
		label:setText(tostring(divine_table[i]))
		
		ImageView = mLayerRoot:getChildByName("ImageView_"..i)
		tolua.cast(ImageView,"UIImageView")
		
		local level = LayerRuneGamble.divine_level[mLayerType]
		if i <= level then
			ImageView:loadTexture(iconString[i],UI_TEX_TYPE_PLIST)
		else
			ImageView:loadTexture("public_Ball_z.png",UI_TEX_TYPE_PLIST)
		end
	end
	
	
end

function LayerRuneGamble.updataWidget()

	--背包
	local ImageView = nil
	for i=1,10 do
		ImageView = mLayerRoot:getChildByName("grid_"..i)
		tolua.cast(ImageView,"UIImageView")
		ImageView:removeAllChildren()
		
		if mBagTable[i] == nil then
			ImageView:loadTexture("frame_white.png")
			ImageView:unregisterEventScript()
		else
			print("mBagTable[i].temp_id",mBagTable[i].temp_id)
			local attr = LogicTable.getItemById(mBagTable[i].temp_id)
			ImageView:loadTexture(attr.icon)
			
			ImageView:registerEventScript(
					function(typename,widget) 	
						if "releaseUp" == typename then
							param = {}
							param.id = mBagTable[i].temp_id
							
							local itemType = LogicTable.getItemById(param.id).type
							--print("符文占卜:",param.id,"itemType:",itemType)
							if itemType+0 == item_type["sculpture"]+0 then
								--print("BackpackUIManage.addLayer(UI_runeInfo,param)")
								BackpackUIManage.addLayer("UI_runeInfo",param)
							else
								--print("BackpackUIManage.addLayer(UI_itemInfo,param)")
								BackpackUIManage.addLayer("UI_itemInfo",param.id)
							end
						end
					end)
					
			--增加品质框
			local quality = LogicTable.getItemById(mBagTable[i].temp_id).quality
			CommonFunc_AddQualityNode(ImageView,quality)
			
		end
	end
	
	--[[
	for i=1,5 do
		ImageView = mLayerRoot:getChildByName("ImageView_"..i)
		tolua.cast(ImageView,"UIImageView")
		local level = LayerRuneGamble.divine_level[mLayerType]
		if i > level then
			ImageView:loadTexture("public_Ball_z.png",UI_TEX_TYPE_PLIST)
		else
			ImageView:loadTexture(iconString[i],UI_TEX_TYPE_PLIST)
		end
	end
	]]
end

--设置占卜动画 Type "hide" "show"
function setGambleAnimation(index,Type,dTime)
	local widget = mLayerRoot:getChildByName("ImageView_"..index)
	tolua.cast(widget,"UIImageView")
	local strPath = nil
	local action = nil
	dTime = dTime or 0.5
	local array = CCArray:create()
	
	if Type == "show" then
		strPath = iconString[index]
		array:addObject(CCFadeOut:create(0.3))
		array:addObject(CCFadeIn:create(0.7))

	else
		strPath = "public_Ball_z.png"
		
		if index == 1 then
			strPath = iconString[index]
		end
		
		array:addObject(CCDelayTime:create(dTime))
		array:addObject(CCFadeIn:create(0.7))
	end
	
	action = CCSequence:create(array)
	widget:loadTexture(strPath,UI_TEX_TYPE_PLIST)
	local node = widget:getRenderer()
	node:runAction(action)
	
end

--
local function Handle_sculpture_divine_msg(resp)
	print("Handle_sculpture_divine_msg")
	--print("resp.is_success:",resp.is_success,type(resp.is_success))
	
	if resp.is_success == common_result["common_success"] then
		print("resp.divine_level",resp.divine_level)
		local level = LayerRuneGamble.divine_level[mLayerType]
		
		if resp.divine_level > level then
			print("符文占卜等级提升")
			setGambleAnimation(resp.divine_level,"show")
		else
			print("符文占卜等级下降")
			local dTime = 0.2
			for i=1,level-1 do
				setGambleAnimation(level-i+1,"hide",dTime*i)
			end
		end
		
		LayerRuneGamble.divine_level[mLayerType] = resp.divine_level
		
		for key,val in pairs(resp.awards) do
			table.insert(mBagTable,val)
		end

		LayerRuneGamble.updataWidget()
		
	elseif resp.is_success == common_result["common_failed"] then 
		CommonFunc_CreateDialog("符文占卜失败")
	end
	
	
end


--注册符文占卜事件
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_divine"], notify_sculpture_divine(), Handle_sculpture_divine_msg)
