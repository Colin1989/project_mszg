
----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-3-5
-- 描述：宝石合成
----------------------------------------------------------------------
local mLayerGemCompoundRoot = nil

LayerGemCompound = {
}

local emun_protection_id = 6001 --保护符 物品ID
local mProtection_bagAttr = nil 
local mProtection_attr = nil
local bProtection_use = false --是否使用保护符

local mID = nil --宝石在背包中的实例ID
--local mItemID = nil --宝石物品ID
local mGem_bagAttr = nil 
	
local function onClickEvent(typeName,widget)
	
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		
		if widgetName == "Button_close" then
			BackpackUIManage.closeLayer("UI_gemCompound")
		elseif widgetName == "Button_47" then --使用/取消 保护符
			if mProtection_bagAttr == nil then --背包中没有保护符
				local structConfirm = {
					strText = "背包中没有保护符"
				}
				UIManager.push("UI_ComfirmDialog",structConfirm)
				return
			else 
				local ImageView = mLayerInlayRoot:getChildByName("ImageView_protect")
				tolua.cast(ImageView,"UIImageView")
				
				if bProtection_use == true then 
					ImageView:setVisible(false)
				else
					ImageView:setVisible(true)
				end
			end
			
		elseif widgetName == "Button_HC" then
			if LayerGemCompound.IsMeetCompound() == true then
				local tb = req_gem_compound()
				tb.temp_id = ModelPlayer.findBagItemIdById(mID)
				if bProtection_use == false then 
					tb.is_protect = 0
				else
					tb.is_protect = 1
				end
				NetHelper.sendAndWait(tb, NetMsgType["msg_notify_gem_compound_result"])
			end
		end
		
	end
	
end

--更新 宝石 保护符 控件显示
function LayerGemCompound.updateWidget()
	local bagAttr = ModelPlayer.findBagItemAttr(mID)
	local attr,BaseAttr = ModelPlayer.getPackItemArr(bagAttr.id)
	local compoundAttr = ModelGem.getGemCompoundTable(BaseAttr.sub_id)
	
	local ImageView = nil
	local label = nil 
	
	
	--保护符
	mProtection_bagAttr = ModelPlayer.findBagByItemid(emun_protection_id)
	if mProtection_bagAttr == nil then --当前背包中没有保护符
		
		ImageView = mLayerGemCompoundRoot:getChildByName("ImageView_protect")
		tolua.cast(ImageView,"UIImageView")
		ImageView:setVisible(false)
		
		
		btn = mLayerGemCompoundRoot:getChildByName("Button_47")	--使用保护符
		tolua.cast(btn,"UIButton")	
		btn:registerEventScript(onClickEvent)
		btn:setTitleText("使用保护符")
	
	else
		mProtection_attr = ModelPlayer.getPackItemBaseArr(mProtection_bagAttr.id)
		
		ImageView = mLayerGemCompoundRoot:getChildByName("ImageView_protect")
		tolua.cast(ImageView,"UIImageView")
		ImageView:setVisible(true)
		ImageView:loadTexture(mProtection_attr.icon)
	
		label = mLayerGemCompoundRoot:getChildByName("Label_protect_count")
		tolua.cast(label,"UILabel")
		label:setText(string.format("X%d"),mProtection_bagAttr.amount)
		
		btn = mLayerGemCompoundRoot:getChildByName("Button_47")		
		btn:registerEventScript(onClickEvent)
		tolua.cast(btn,"UIButton")
		btn:setTitleText("取消保护符")
	end
end

function LayerGemCompound.init(root,id)
	print("LayerGemCompound.init() id:",id)
	mLayerGemCompoundRoot = root
	mID = id
	
	local btn = nil
	local ImageView = nil
	local label = nil
	
	bProtection_use = false
	local attr,BaseAttr = ModelPlayer.getPackItemArr(id)
	local compoundAttr = ModelGem.getGemCompoundTable(BaseAttr.sub_id)
	local nextAttr = LogicTable.getItemById(compoundAttr.related_id)
	local nextBaseAttr = ModelGem.getGemAttr(nextAttr.sub_id)
	
	ImageView = mLayerGemCompoundRoot:getChildByName("ImageView_gem1")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..BaseAttr.icon)
	
	
	
	for i=1,2 do
		local strGemAttrValue = CommonFunc_getGemValueString(attr)
		label = mLayerGemCompoundRoot:getChildByName("Label_val_"..i)
		tolua.cast(label,"UILabel")
		
		if strGemAttrValue[i] ~= nil then
			label:setVisible(true)
			label:setText(strGemAttrValue[i])
		else
			label:setVisible(false)
		end
		
	 
		local strGemAttrValue = CommonFunc_getGemValueString(nextBaseAttr)
		label = mLayerGemCompoundRoot:getChildByName("Label_val_"..i+2)
		tolua.cast(label,"UILabel")
		if strGemAttrValue[i] ~= nil then
			label:setVisible(true)
			label:setText(strGemAttrValue[i])
		else
			label:setVisible(false)
		end
	end
	
	
	
	ImageView = mLayerGemCompoundRoot:getChildByName("ImageView_gem2")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..nextAttr.icon)
	
	label = mLayerGemCompoundRoot:getChildByName("Label_gem1")
	tolua.cast(label,"UILabel")
	label:setText(BaseAttr.name)
	
	label = mLayerGemCompoundRoot:getChildByName("Label_gem2")
	tolua.cast(label,"UILabel")
	label:setText(nextAttr.name)
	
	btn = mLayerGemCompoundRoot:getChildByName("Button_close")			
	btn:registerEventScript(onClickEvent)
	
	btn = mLayerGemCompoundRoot:getChildByName("Button_HC")			
	btn:registerEventScript(onClickEvent)
	
	label = mLayerGemCompoundRoot:getChildByName("LabelAtlas_price")
	tolua.cast(label,"UILabelAtlas")
	label:setStringValue(tostring(compoundAttr.gold))
	
	
	label = mLayerGemCompoundRoot:getChildByName("Label_explain") -- 说明简介
	tolua.cast(label,"UILabel")
	--label:setText("")
	
	label = mLayerGemCompoundRoot:getChildByName("Label_probability") 
	tolua.cast(label,"UILabel")
	label:setText(string.format("成功率:%d%%",compoundAttr.success_rate))
	
	
	label = mLayerGemCompoundRoot:getChildByName("Label_need") 
	tolua.cast(label,"UILabel")
	label:setText(string.format("需要%sX5",BaseAttr.name))
	
	--更新控件
	LayerGemCompound.updateWidget()
	
end

--是否满足合成条件
function LayerGemCompound.IsMeetCompound()
	local attr = ModelPlayer.getPackItemBaseArr(mID)
	local compoundAttr = ModelGem.getGemCompoundTable(attr.sub_id)
	
	--判断金币是否足够
	
	if CommonFunc_IsConsume(compoundAttr.gold) == true then 
		if LayerGemInfo.IsCompoundMeet(mID) == true then 
			return true
		else 
			return false
		end
	else
		return false
	end
end


function LayerGemCompound.onExit()
	
	
end

--合成事件
local function Handle_gem_compound_result_msg(resp)	
	local structConfirm = {
		strText = "合成成功",
		buttonCount = 0
	}
	
	if resp.result == common_result["common_success"] then --成功
			
	elseif resp.result == common_result["register_failed"] then 
		structConfirm.strText = string.format("合成失败,毁坏%d颗宝石",resp.lost_gem_amount)
		
	end
	
	--更新控件
	LayerGemCompound.updateWidget()
	
	UIManager.push("UI_ComfirmDialog",structConfirm)

end

--注册合成事件
NetSocket_registerHandler(NetMsgType["msg_notify_gem_compound_result"], notify_gem_compound_result(), Handle_gem_compound_result_msg)


