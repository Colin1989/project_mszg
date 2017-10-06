
----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-1-21
-- 描述：主界面->背包子界面  不用继承Abstract 因为不属于UI跟节点
----------------------------------------------------------------------
local mLayerBackpackRoot = nil
--装备栏 信息表
--gUserEquipTable = nil

LayerBackpack = {
}

-----------------------ScrollView控件-------------------------
local mScrollView = nil
--背包进度条
local mSilder = nil 

--背包格子数
local mGridCountMax = 50
--开放的格子数
local mGridCountOpen = 20
--每次拓展增加的格子数
local mAddGridCount = 2
--每一行格子数量
local mRowCount = 5
--背包格子大小
local mGridHeight = 106
local mGridWidth = 106
-----------------------END ScrollView控件-------------------------

--local mItemIndex = 1
local mtableItem = {}
mtableItem[1] = {} --装备
mtableItem[2] = {} --符文
mtableItem[3] = {} --物品
mtableItem[4] = {} --全部

--根节点
local mRootNode = nil

local function onClickEvent(typeName,widget)
		--local CurTopLayerName = UIManager.getTopLayerName()
		
		if typeName == "releaseUp" then
			local widgetName = widget:getName()	
			print("typeName:",typeName,"widgetName",widgetName)	
			
			gEquipCurrentID = nil
			gEquipBagID = nil

			for i=1,6 do 
				if widgetName == "ImageEquip_" .. i-1 then
					if ModelPlayer.UserEquipTable[i] == nil then 
						print("ModelPlayer.UserEquipTable==nil",i)
						break
					end
					
					gEquipCurrentID = ModelPlayer.UserEquipTable[i]
					
					BackpackUIManage.addLayer("UI_equip")
					break
				end
			end
			
			
			--按钮
			if widgetName == "Button_0" then --详细信息
				BackpackUIManage.switchLayer("UI_playerInfo")
			end
			
			
			for i=1,4 do 
				if widgetName == "Button_"..i then
					LayerBackpack.setScrollViewData(i)
				end
			end
			
		end
end

--strLayr == gem  rune
function LayerBackpack.mod_BagLayer(strLayr)
	print("===================mod_BagLayer",strLayr)
	local btnName = {}
	local current,layerType = BackpackUIManage.getCurrentLayer()
	--print("LayerBackpack.mod_BagLayer:layerType,current",layerType,current)
	
	--layerType --strLayr
	if layerType == "rune" then
		btnName = {"类型","品质","等级","售价"}
	elseif layerType == "gem" then
		btnName = {"等级","类型","售价"}
	elseif layerType == "equip" then
		btnName = {"装备","符文","宝石材料","全部"}
	end
	
	for key,val in pairs(btnName) do
		print("key:",key,val)
	end
	
	for i=1,4 do
		btn = mLayerBackpackRoot:getChildByName("Button_"..i)
		tolua.cast(btn,"UIButton")
		if i<= #btnName then
			CommonFunc_SetWidgetTouch(btn,true)
			btn:registerEventScript(onClickEvent)
			btn:setTitleText(btnName[i])
		else
			CommonFunc_SetWidgetTouch(btn,false)
		end
	end
	
	LayerBackpack.setScrollViewData(1)
end

--获得背包全部物品表
function LayerBackpack.getTableItemAll()
	print("LayerBackpack.getTableItemAll()")
	
	local tableItemAll = {}

	for i=1,3 do
		for key,val in pairs(mtableItem[i]) do
			table.insert(tableItemAll,val)
		end
	end
	
	return tableItemAll
end

--初始化物品表
function LayerBackpack.initTableItem(tableBag)
	print("LayerBackpack.initTableItem()")
	
	mtableItem = {}
	
	mtableItem[1] = {} --装备
	mtableItem[2] = {} --符文
	mtableItem[3] = {} --材料
	mtableItem[4] = {} --全部

	for key,val in pairs(tableBag) do
		if val.itemtype == item_type["property"] then 
			table.insert(mtableItem[3],val)
		else
			table.insert(mtableItem[val.itemtype],val)
		end
	end
	
end

--增加物品到表
function LayerBackpack.appendTableItem(tableBag)
	print("LayerBackpack.appendTableItem()")
	
	for key,val in pairs(tableBag) do
		if val.itemtype == item_type["property"] then 
			table.insert(mtableItem[3],val)
		else
			table.insert(mtableItem[val.itemtype],val)
		end
		
	end
	
	
end

--删除物品到表
function LayerBackpack.deleteTableItem(tableBag)
	print("LayerBackpack.deleteTableItem()")
	
	local function delete_function(id)
		for i = 1,3 do
			for key,val in pairs(mtableItem[i]) do

				if val.id == id then
					--mtableItem[i][key] = nil
					table.remove(mtableItem[i],key)
					print(string.format("删除mtableItem[%d][%d] = ",i,key))
					return
				end
			end
		end
	end
	
	
	for key,val in pairs(tableBag) do
		delete_function(val.id)
	end
	
end

--更改物品到表
function LayerBackpack.modifyTableItem(tableBag)
	for k,v in pairs(tableBag) do
		for key,val in pairs(mtableItem[v.itemtype]) do 
			if v.id == val.id then 
				mtableItem[v.itemtype][key] = v
				
				if val.itemtype == item_type["property"] then 
					mtableItem[3][key] = v
				else
					mtableItem[v.itemtype][key] = v
				end
		
			end
			
		end
	end
	
end


--判断是否满足拓展背包条件 false失败
local function IsExtendpack()
	print("IsExtendpack()")
	if mGridCountOpen == mGridCountMax then
		CommonFunc_CreateDialog("当前背包格子数已达上限，无法拓展")
		return false
	end
		
	--拓展次数
	local expandCount = (mGridCountOpen-20)/2
	
	--当前拓展费用
	local price = LogicTable.getExpandPrice(expandCount+1)
	--判断当前是否有足够金币拓展背包
	if CommonFunc_IsConsume(price) == false then
		return false
	end
	
	return true
end

function LayerBackpack.setClickButtonIcon(index)
	--设置按钮高亮

	print("LayerBackpack.setClickButtonIcon ",index)
	for i=1,4 do 
		label = mLayerBackpackRoot:getChildByName("Button_"..i)
		tolua.cast(label,"UIButton")
		
		if index == i then --当前选择点击按钮
			label:loadTextureNormal("shortbutton_hover.png")
			
		else
			label:loadTextureNormal("sureback.png")
		end

	end
	
	if BackpackUIManage.IsLayerExist("UI_runeCharge") == true then
		LayerRuneCharge.ClearData()
	end
	
end

--发送扩展背包
function LayerBackpack.SeedExtend_packFunction()

	--满足拓展条件
	if IsExtendpack() == true then 
		--发送消息
		local tb = req_extend_pack()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_extend_pack_result"])
	end
			
end
	
--获得当前标签页背包数据以及显示信息
function LayerBackpack.getBagTable(index)
	print("LayerBackpack.getBagTable index:",index)
	local bagTable = {}
	local scrollinfo = {}
	scrollinfo.bShow_count = false
	scrollinfo.showGrid = 0
	
	local strLayer,layerType = BackpackUIManage.getCurrentLayer()
	print("LayerBackpack.getBagTable layerType,strLayer",layerType,strLayer)
	if layerType == "rune" or  layerType == "gem" then
		bagTable = BackpackUIManage.getSortBagTable(index)
		scrollinfo.showGrid = #bagTable
	else
		if index == 4 then
			bagTable = LayerBackpack.getTableItemAll()
			scrollinfo.showGrid = mGridCountMax
			scrollinfo.bShow_count = true
		else
			bagTable = mtableItem[index]
			scrollinfo.showGrid = #bagTable
		end
	end
			
	
	return bagTable,scrollinfo
end


--[[
local scrollinfo ={
"bShow_count" = false,--是否显示背包数量
"showGrid" = 20 --需要显示的格子数
}]]
local m_Index = nil
function LayerBackpack.setScrollViewData(index)
	print("LayerBackpack.setScrollViewData()")
	
	if mLayerBackpackRoot == nil then
		print("mLayerBackpackRoot == nil")
		return
	end
	
	----------------------------------------
	if(UIManager_UItable["UI_Main"].status ~= "onStart") then
		print("--代表不在当前界面----0")
		return
	end
	
	local Panel = LayerMain.getContendPanel()
	local widget = Panel:getChildByName("Panel_Bag")
	
	if widget == nil then
		print("--代表不在当前界面----1")
		return 
	end
	if mLayerBackpackRoot:getRenderer():isRunning() == false then
		print("--代表不在当前界面----2")
		return
	end
	
	if BackpackUIManage.IsLayerExist("UI_runeGamble") == true then
		print("---在占卜界面不刷新---UI_runeGamble")
		return
	end
	------------------------------------------
	
	
	if mScrollView ~= nil then 
		print("mScrollView:removeAllChildren()")
		mScrollView:removeAllChildren()
	end
	
	
	--获得当前要显示的背包数据
	m_Index = index or m_Index
	LayerBackpack.setClickButtonIcon(m_Index)
	
	local BagTable,scrollinfo = LayerBackpack.getBagTable(m_Index)
	--物品数量
	local itemCout = #BagTable
	
	local label = mLayerBackpackRoot:getChildByName("Label_GridCount")
	tolua.cast(label,"UILabel") 
	label:setText(string.format("%d/%d",itemCout,mGridCountOpen))
	label:setVisible(scrollinfo.bShow_count)
	
	iHeight = math.ceil(scrollinfo.showGrid/mRowCount)
	--临时 如果只显示一行的话坐标会出错
	if iHeight == 1 then 
		iHeight = 2
	end
	iHeight = mGridHeight*iHeight
	-- 计算拖动层尺寸高度
	local contair = mScrollView:getInnerContainer()
	contair:setSize( CCSize(mGridWidth*mRowCount,iHeight) )
	mScrollView:setInnerContainerSize(contair:getSize())	
	--local percent = mScrollView:getPositionPercent()	
	--mScrollView:setInnerContainerSize(CCSize(720,720*2))
	
	if scrollinfo.showGrid == 0 then
		print("当前分类背包为空") 
		return
	end
	
	local structConfirm = {
		strText = "是否拓展背包",
		buttonCount = 2,
		buttonName = {"确定","取消"},
		buttonEvent = {LayerBackpack.SeedExtend_packFunction,nil}
	}
	
	for i=1,scrollinfo.showGrid do
		local iRow = math.floor((i-1)/mRowCount)--行
		local iCol = math.floor((i-1)%mRowCount)--列
		local iX = iCol*mGridWidth+mGridWidth/2 + 12
		local iY = iHeight-(iRow*mGridHeight+mGridHeight/2)
		
		local gridImage = UIImageView:create() --格子
		gridImage:setPosition(ccp(iX,iY))
		gridImage:setTouchEnabled(true)
		
		if i > mGridCountOpen then --未解锁
			gridImage:loadTexture("lockicon.png",UI_TEX_TYPE_PLIST)
			gridImage:registerEventScript(		
					function(typename,widget)
						if "releaseUp" == typename then													
							UIManager.push("UI_ComfirmDialog",structConfirm)
						end
					end)
					
		else --已解锁的格子
			--gridImage:loadTexture("frame_white.png")
			local val = BagTable[i]
			if val ~= nil then --该位置有物品
				local attr = ModelPlayer.getPackItemBaseArr(val.id)
				local path = CommonFunc_GetQualityPath(attr.quality)
				
				--物品
				gridImage:loadTexture("Icon/" .. attr.icon)
				gridImage:registerEventScript(		
					function(typename,widget) 	
						if "releaseUp" == typename then
							gEquipBagID = val.id
							gEquipCurrentID = nil
							
							local itemType = ModelPlayer.findBagItemAttr(val.id).itemtype

							if itemType == item_type["equipment"] then 
								gEquipCurrentID = LayerBackpack.getEquipCurrentID(gEquipBagID)
								BackpackUIManage.addLayer("UI_equip")
							elseif itemType == item_type["sculpture"] then
								local current = BackpackUIManage.getCurrentLayer()
								if current ==  "UI_runeCharge" then --处于充能界面
									LayerRuneCharge.addPitchIcon(gridImage,val.id)
									
								else
									local param = {}
									param.id = val.id
									param.position = nil
									BackpackUIManage.addLayer("UI_runeInfo",param)
									
								end
								
							elseif itemType == item_type["gem"] then
								--当前层为宝石镶嵌界面的话，点击宝石坐标为选中当前宝石
								--不再进入宝石详情页面
								
								if BackpackUIManage.getCurrentLayer() == "UI_gemInlay" then
									BackpackUIManage.addLayer("UI_gemInfo",{val.id,2})
								else
									BackpackUIManage.addLayer("UI_gemInfo",{val.id,1})
								end
							
							else
								local itemID = ModelPlayer.findBagItemIdById(val.id)
								local param = {}
								param.itemid = itemID
								param.id = val.id
								BackpackUIManage.addLayer("UI_itemInfo",param)
							end
							
							
						end
					end)
				gridImage:addChild(itemImage)
				
				--品质框
				CommonFunc_AddQualityNode(gridImage,attr.quality)
				
				--物品数量显示
				if val.amount ~= 1 then 
					local ItemCountLabel = UILabelAtlas:create()
					ItemCountLabel:setProperty("01234567890", "GUI/labelatlasimg.png", 24, 32, "0")
					ItemCountLabel:setStringValue(string.format("X%d",val.amount))
					ItemCountLabel:setPosition(ccp(20,-30))
					gridImage:addChild(ItemCountLabel)
				end
			
			else
				gridImage:loadTexture("frame_white.png")
			end

		end	
		
		mScrollView:addChild(gridImage)
	end
	
	mScrollView:jumpToTop()
	
	mScrollView:registerEventScript(
					function(typename,widget) 
						local contair = mScrollView:getInnerContainer()
						local height = contair:getSize().height
						local pos = contair:getPosition()
						local kuangH = mScrollView:getSize().height
						
						if "scrolling" == typename then
							local Ratio = math.abs(pos.y)/(height-kuangH) * 100
							--print(string.format("height:%d,pos.y:%d,kuangH:%d,Ratio:%d",height,pos.y,kuangH,Ratio))
							mSilder:setPercent(100-Ratio)
							
						end
					end)	
					
	mSilder:setPercent(0)
end


-- onCreate
function  LayerBackpack.init(layer,bagType)
	print("LayerBackpack.init()")
	mLayerBackpackRoot = layer
	--BackpackUIManage.init(layer)
	
	local btn = mLayerBackpackRoot:getChildByName("Button_0")--详细信息	
	tolua.cast(btn,"UIButton")
	btn:registerEventScript(onClickEvent)
	
	mScrollView = mLayerBackpackRoot:getChildByName("ScrollView_66")
	tolua.cast(mScrollView,"UIScrollView") 
	mScrollView:setBounceEnabled(false)
	
	mSilder = mLayerBackpackRoot:getChildByName("Slider_455")
	tolua.cast(mSilder,"UISlider")
	mSilder:setPercent(0)
	
	mScrollView = mLayerBackpackRoot:getChildByName("ScrollView_66")
	tolua.cast(mScrollView,"UIScrollView") 
	mScrollView:setBounceEnabled(false)
	

	--背包容量
	mGridCountOpen = ModelPlayer.pack_space
	
	--按钮
	
	bagType = bagType or "equip"
	LayerBackpack.mod_BagLayer(bagType)
	--LayerBackpack.setScrollViewData(1)
	
	-----------------------------------装备栏---------------------------------------------	
	
	for i=0,5 do
		btn = mLayerBackpackRoot:getChildByName("ImageEquip_" .. i) -- 装备icon
		btn:registerEventScript(onClickEvent)		

		if LayerBackpack.updataEquip(i+1,true) == false then 
			ModelPlayer.UserEquipTable[i+1] = nil 
			--btn:setVisible(false)
		end
		
	end
	
	
	--玩家动画
	local role_tplt = ModelPlayer.getRoleInitDetailMessageById( ModelPlayer.roletype)
	--print("role_tplt.icon",role_tplt.icon)
	local role_Ani = ResourceManger.getAnimationFrameById(role_tplt.icon )
	--[[mPlayerNode = CCSprite:create()
	mPlayerNode:setPosition(ccp(100,100))
	g_sceneRoot:addChild(mPlayerNode,g_Const_GameLayer.uiLayerPlayer)

	local str = string.format("%s_%s",role_Ani.name,role_Ani.wait).."_%03d.png"

	local animation = createAnimation(str,role_Ani.wait_frame,0.1)
	mPlayerNode:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	]]
	
	--print("role_Ani.name:",role_Ani.name)
	ResourceManger.LoadSinglePicture(role_Ani.name)
	
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("Gamemonster1.plist");
	
	local strPath = string.format("%s_%s",role_Ani.name,role_Ani.wait).."_%03d.png"

	local playerNode = createAnimation_forever(strPath,role_Ani.wait_frame,0.1)
	
	local node = mLayerBackpackRoot:getChildByName("ImageView_338")
	node:addRenderer(playerNode,100)
	
	
end

--获得相对应的装备栏ID
function LayerBackpack.getEquipCurrentID(BagItemID)

	local equipType = ModelEquip.getEquipType(BagItemID)
	local EquipID = ModelPlayer.UserEquipTable[equipType]	
	
	return EquipID
end


--更新装备栏
function LayerBackpack.updataEquip(equipType,bShow)
	local ItemID = ModelPlayer.UserEquipTable[equipType]
	local attr = ModelPlayer.getPackItemBaseArr(ItemID)
	
	local widget = mLayerBackpackRoot:getChildByName("ImageEquip_"..equipType-1)
	tolua.cast(widget,"UIImageView")
	widget:removeAllChildren()
	
	if attr == nil then 
		widget:loadTexture("frame_white.png")
		return false
	end
	
	if bShow == true then
		widget:loadTexture("Icon/" .. attr.icon)
		CommonFunc_AddQualityNode(widget,attr.quality)
	else
		widget:loadTexture("frame_white.png")
	end
	
	return true
end

--查询当前背包是否满了 true满了 false  bDialog是否弹窗
function LayerBackpack.IsPackFull(bDialog)
	local ItemAll = LayerBackpack.getTableItemAll()
	if #ItemAll == mGridCountOpen then
		if bDialog == true then
			print("当前背包已满，是否拓展背包")
			local structConfirm = {
				strText = "当前背包已满，是否拓展背包",
				buttonCount = 2,
				buttonName = {"拓展背包","取消"},
				buttonEvent = {LayerBackpack.SeedExtend_packFunction,nil}
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)
		end
	
		return true
	end
	
	
	
	return false
end

--拓展背包成功
local function Handle_extend_pack_msg(resp)
	--ModelEquip.initEquipRandomAttr(resp)
	print("收到背包扩展返回信息")
	if resp.result == common_result["common_success"] then --成功
		mGridCountOpen  = mAddGridCount + mGridCountOpen
		print("当前背包格子数为mGridCountOpen:",mGridCountOpen)
		--刷新背包
		LayerBackpack.setScrollViewData(4)
	elseif resp.result == common_result["common_failed"] then 
	
	
	end
end

--注册背包拓展
NetSocket_registerHandler(NetMsgType["msg_notify_extend_pack_result"], notify_extend_pack_result(), Handle_extend_pack_msg)

