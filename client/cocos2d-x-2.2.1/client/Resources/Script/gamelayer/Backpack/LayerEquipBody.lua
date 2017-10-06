
--玩家身上装备
LayerEquipBody = {}

local mLayerRoot = nil

local function onClickEvent(widget)	
	TipModule.onClick(widget)
	local widgetName = widget:getName()
	for i=1, 6 do
		if widgetName == "ImageEquip_"..(i-1) then
			local currEquip = ModelEquip.getCurrEquip(i)
			local equip = ModelEquip.getEquipInfo(currEquip)
			if nil == currEquip then
				break
			end
			local param = {}
			param.id = currEquip
			param.index = i
			UIManager.push("UI_Equip_Put",param)
			break
		end
	end
end

function LayerEquipBody.Action_onEnter()
	local widget_left = mLayerRoot:getChildByName("ImageView_left")
	local pos_left = CommonFunc_GetPos(widget_left)
	widget_left:setPosition(ccp(pos_left.x-100,pos_left.y))
	
	local widget_right = mLayerRoot:getChildByName("ImageView_right")
	local pos_right = CommonFunc_GetPos(widget_right)
	widget_right:setPosition(ccp(pos_right.x+100,pos_right.y))
	
	Animation_MoveTo_Rebound(widget_left,0.4,pos_left)
	Animation_MoveTo_Rebound(widget_right,0.4,pos_right)
end

--更新装备栏
local function updataEquip(equipType,bShow)
	local id = ModelEquip.getCurrEquip(equipType)
	local equip = ModelEquip.getEquipInfo(id)
	
	local widget = mLayerRoot:getChildByName("ImageEquip_"..(equipType-1))
	tolua.cast(widget, "UIImageView")
	widget:removeAllChildren()

	if nil == equip then
		widget:loadTexture("equip_none_0"..equipType..".png")
		local widget_grid = CommonFunc_AddGirdWidget(nil)
		widget:addChild(widget_grid)
	else
		local widget_grid = CommonFunc_AddGirdWidget(equip.id, 1, equip.strengthen_level)
		widget:addChild(widget_grid)
	end
end

--长按结束回调
local function longClickCallback(widget)
	UIManager.pop("UI_EquipInfo")
end

local function refreshUI()
	if nil == mLayerRoot then
		return
	end
	for i=1, 6 do
		local btn = mLayerRoot:getChildByName("ImageEquip_"..(i-1)) -- 装备icon
		local currEquip = ModelEquip.getCurrEquip(i)
		if currEquip then
			-- 物品详细信息
			local function showItemDetailCall(widget)
				local position,direct = CommonFuncJudgeInfoPosition(widget)
				local equip = ModelEquip.getEquipInfo(currEquip)
				local tb = {}
				tb.instId = currEquip
				tb.itemId =equip.id
				tb.position = position
				tb.direct = direct
				
				UIManager.push("UI_EquipInfo",tb)
			end
			UIManager.registerEvent(btn, onClickEvent, showItemDetailCall, longClickCallback)
		
		end
		updataEquip(i,true)
	end
end
			
function LayerEquipBody.init(root)
	mLayerRoot = root
	refreshUI()
	TipModule.onUI(root, "ui_equipbody")
end

function LayerEquipBody.destroy()
	mLayerRoot = nil
end

EventCenter_subscribe(EventDef["ED_EQUIPMENT_PUTON"], refreshUI)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_TAKEOFF"], refreshUI)

