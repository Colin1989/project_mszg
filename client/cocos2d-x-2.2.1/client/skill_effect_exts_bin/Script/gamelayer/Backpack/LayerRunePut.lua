--符文穿戴

LayerRunePut = {}

local mLayerRoot = nil

local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		
		for i=1,4 do
			if ModelPlayer.sculpture[i] ~= nil then
				if widgetName == "ImageView_Rune_"..i then
					local param = {}
					param.id = ModelPlayer.sculpture[i]
					param.position = i
					BackpackUIManage.addLayer("UI_runeInfo",param)
				elseif widgetName == "Button_rune"..i then
					LayerRunePut.seed_sculpture_takeoff_msg(i)
					
				end
			end
		end
		
		if widgetName == "Button_close" then
			BackpackUIManage.closeLayer("UI_runePut")
		end
		
		
	end
	
end

function LayerRunePut.init(root,Param)
	mLayerRoot = root
	active = true
	local btn = mLayerRoot:getChildByName("Button_close")
	btn:registerEventScript(onClickEvent)
	
	local btn = nil
	local ImageView = nil
	
	for i=1,4 do
		btn = mLayerRoot:getChildByName("Button_rune"..i)
		btn:registerEventScript(onClickEvent)
		
		ImageView = mLayerRoot:getChildByName("ImageView_Rune_"..i)
		ImageView:registerEventScript(onClickEvent)
	end
	
	LayerRunePut.updataWidget()
	
	--刷新背包数据
	--LayerBackpack.setScrollViewData()
	
end

function LayerRunePut.updataWidget()
	local btn = nil
	local ImageView = nil
	
	for i=1,4 do
		btn = mLayerRoot:getChildByName("Button_rune"..i)
		tolua.cast(btn,"UIButton")
		
		ImageView = mLayerRoot:getChildByName("ImageView_Rune_"..i)
		tolua.cast(ImageView,"UIImageView")
		ImageView:removeAllChildren()
		
		if ModelPlayer.sculpture[i] ~= nil then
			
			local _,BaseAttr = ModelRune.getRuneAppendAttr(ModelPlayer.sculpture[i])
			--local _,BaseAttr = ModelPlayer.getPackItemArr(ModelPlayer.sculpture[i])
			if BaseAttr ~= nil then
				ImageView:loadTexture("Icon/"..BaseAttr.icon)
				ImageView:setTouchEnabled(true)
				btn:setVisible(true)
				btn:setTouchEnabled(true)
				
				--品质框
				CommonFunc_AddQualityNode(ImageView,BaseAttr.quality)
			end
		else
		
			btn:setVisible(false)
			btn:setTouchEnabled(false)
			ImageView:setTouchEnabled(false)
			ImageView:loadTexture("public_Box_1.png",UI_TEX_TYPE_PLIST)
			
		end
		
		btn:registerEventScript(onClickEvent)
	end

	--刷新背包数据
	LayerBackpack.setScrollViewData()
end

function LayerRunePut.seed_sculpture_puton_msg(inst_id)
	
	for i=1,4 do
		--判断是否有空间位置可以穿上符文
		if ModelPlayer.sculpture[i] == nil then 
			local tb = req_sculpture_puton()
			tb.position = i
			tb.inst_id = inst_id
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_puton"])
			
			return
		end
	end
	
	CommonFunc_CreateDialog("位置不足,无法装备符文")
	
end
 
function LayerRunePut.seed_sculpture_takeoff_msg(position)
	--检测背包空间是否已满
	if LayerBackpack.IsPackFull(true) == true then
		return
	end
	
	local tb = req_sculpture_takeoff()
	tb.position = position
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_takeoff"])
	
end


local function Handle_sculpture_puton_msg(resp)	
	print("resp.is_success:",resp.is_success,type(resp.is_success))
	if resp.is_success == 1 then
		print("注意啦,符文更新啦")
		ModelPlayer.sculpture[resp.position] = resp.inst_id
		print("resp.position",resp.position,"resp.inst_id",resp.inst_id)
	elseif resp.is_success == 0 then 
		CommonFunc_CreateDialog("穿上符文失败")
	end
	
	for i=1,4 do
		print("ModelPlayer.sculpture[i] i:",i,ModelPlayer.sculpture[i])
	end
	
	BackpackUIManage.closeLayer("UI_runeInfo")
	LayerRunePut.updataWidget()
end

local function Handle_sculpture_takeoff_msg(resp)	
	print("resp.is_success:",resp.is_success,type(resp.is_success))
	if resp.is_success == common_result["common_success"] then 
		ModelPlayer.sculpture[resp.position] = nil
		print("resp.position",resp.position)
	elseif resp.is_success == common_result["common_failed"] then 
		CommonFunc_CreateDialog("卸下符文失败")
	end
	
	if BackpackUIManage.IsLayerExist("UI_runeInfo") == true then
		BackpackUIManage.closeLayer("UI_runeInfo")
	end
	LayerRunePut.updataWidget()
end


--注册镶嵌符文事件
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_puton"], notify_sculpture_puton(), Handle_sculpture_puton_msg)

--注册卸下符文事件
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_takeoff"], notify_sculpture_takeoff(), Handle_sculpture_takeoff_msg)