
--符文充能

LayerRuneCharge = {}
local mLayerRoot = nil
local mID = nil --符文实例ID
local mSumGold_eat = 0
local mSumExp_eat = 0
--标记选中符文表，存放符文实例ID
local mPitchTable = {}

function LayerRuneCharge.onExit()
	print("LayerRuneCharge.onExit()~~~~~~")
	for key,val in pairs(mPitchTable) do
		val[1]:removeChild(val[2])
	end
end


local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		
		if widgetName == "Button_start" then
			if mSumExp_eat == 0 then
				return
			end
			
			local tb = req_sculpture_upgrade()
			tb.main_id = mID
			tb.eat_ids = {}
			
			for key,val in pairs(mPitchTable) do
				--print("tb.eat_ids~~~~~~key",key)
				table.insert(tb.eat_ids,key)
			end
			
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_upgrade"])
		elseif widgetName == "Button_esc" then
			BackpackUIManage.closeLayer("UI_runeCharge")
			
		end
	end
	
end

function LayerRuneCharge.getRuneID()
	return mID
end

--
function LayerRuneCharge.ClearData()
	--[[
	for key,val in pairs(mPitchTable) do
		val[1]:removeChild(val[2])
	end
	]]
	
	mSumGold_eat = 0
	mSumExp_eat = 0
	mPitchTable = {}
	
	LayerRuneCharge.updataWidget()
end

--计算充能所需要的金币和经验 strCount "+"增加 "-"减少
function LayerRuneCharge.CountChargeGoldandExp(id,strCount)
	local runeAttr = ModelRune.getRuneAppendAttr(id)
	if strCount == "+" then
		mSumGold_eat = mSumGold_eat + runeAttr.eat_gold
		mSumExp_eat = mSumExp_eat + runeAttr.eat_exp
	elseif strCount == "-" then
		mSumGold_eat = mSumGold_eat - runeAttr.eat_gold
		mSumExp_eat = mSumExp_eat - runeAttr.eat_exp
	end
	
end

--添加勾选图标
function LayerRuneCharge.addPitchIcon(widget,id)
	
	if mPitchTable[id] == nil then
		local node = UIImageView:create()
		node:loadTexture("tick.png",UI_TEX_TYPE_PLIST)
		node:setZOrder(100)
		widget:addChild(node)
		
		mPitchTable[id] = {widget,node}
		LayerRuneCharge.CountChargeGoldandExp(id,"+")
	else
		widget:removeChild(mPitchTable[id][2])
		
		mPitchTable[id] = nil
		LayerRuneCharge.CountChargeGoldandExp(id,"-")
	end
	
	LayerRuneCharge.updataWidget()
end

function LayerRuneCharge.init(root,id)
	mID = id
	mLayerRoot = root
	local attr,BaseAttr = ModelRune.getRuneAppendAttr(mID)
	local runeAttr = ModelRune.findRuneByid(mID)
	
	local btn = nil
	local ImageView = nil
	local label = nil
	
	ImageView = mLayerRoot:getChildByName("ImageView_head")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..BaseAttr.icon)
	
	--品质框
	CommonFunc_AddQualityNode(ImageView,BaseAttr.quality)
	
	btn = mLayerRoot:getChildByName("Button_start")
	btn:registerEventScript(onClickEvent)
	btn = mLayerRoot:getChildByName("Button_esc")
	btn:registerEventScript(onClickEvent)
	
	
	LayerRuneCharge.updataWidget()
	
end

function LayerRuneCharge.updataWidget(bUpdataSumExp)
	local attr,BaseAttr = ModelRune.getRuneAppendAttr(mID)
	local runeAttr = ModelRune.findRuneByid(mID)
	
	local label = nil
	
	label = mLayerRoot:getChildByName("Label_gold")
	tolua.cast(label,"UILabel")
	label:setText(string.format("金币:%d",mSumGold_eat))
	
	
	label = mLayerRoot:getChildByName("Label_exp")
	tolua.cast(label,"UILabel")
	label:setText(string.format("升级:%d/%d",mSumExp_eat,attr.upgrade_exp-runeAttr.exp))
	
	--符文简介
	label = mLayerRoot:getChildByName("Label_runeInfo")
	tolua.cast(label,"UILabel")
	label:setText(BaseAttr.describe)
	
	--[[
	label = mLayerRoot:getChildByName("Label_sumexp")
	tolua.cast(label,"UILabel")
	local sumEXP = ModelRune.RuneSumExpCount(attr.id,runeAttr.exp)
	label:setText(string.format("满级:%d/%d",mSumExp_eat,sumEXP))
	]]
end

--
local function Handle_sculpture_upgrade_msg(resp)

	if resp.result == common_result["common_success"] then --成功
		LayerRuneCharge.ClearData()
		--LayerRuneCharge.updataWidget()
		--刷新背包
		LayerBackpack.setScrollViewData()
		
	else
		
		
	end
end

--
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_upgrade"], notify_sculpture_upgrade(), Handle_extend_pack_msg)

