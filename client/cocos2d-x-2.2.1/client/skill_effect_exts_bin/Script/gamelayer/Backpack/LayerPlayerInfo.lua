--玩家详细信息    背包-》详细信息 按钮

local mLayerPlayerInfoRoot = nil


LayerPlayerInfo = {
}

function LayerPlayerInfo.init(root)
	
	--mLayerPlayerInfoRoot = GUIReader:shareReader():widgetFromJsonFile("Backpack_Player.ExportJson")
	--root:addChild(mLayerPlayerInfoRoot)
	mLayerPlayerInfoRoot = root
	--tolua.cast(mLayerPlayerInfoRoot,"UILayout")
	
	local attr = ModelPlayer.getPlayerAllAttr()
	
	local str = ""
	
	local label = mLayerPlayerInfoRoot:getChildByName("Label_ID")
	tolua.cast(label,"UILabel")
	--label:setVisible(false)setText
	label:setText("ID："..ModelPlayer.nickname)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_ZY")
	tolua.cast(label,"UILabel")	
	str = CommonFunc_GetRoletypeString(ModelPlayer.roletype)
	label:setText("职业："..str)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_GH")
	tolua.cast(label,"UILabel")	
	--label:setText("")
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_PK")
	tolua.cast(label,"UILabel")	
	--label:setText("")
	
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_HP")
	tolua.cast(label,"UILabel")	
	label:setText("生命："..attr.life)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_ATK")
	tolua.cast(label,"UILabel")	
	label:setText("攻击："..attr.atk)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_Crit")
	tolua.cast(label,"UILabel")	
	label:setText("暴击："..attr.critical_ratio)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_DEF")
	tolua.cast(label,"UILabel")	
	label:setText("韧性："..attr.tenacity)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_Hit")
	tolua.cast(label,"UILabel")	
	label:setText("命中："..attr.hit_ratio)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_Speed")
	tolua.cast(label,"UILabel")	
	label:setText("速度："..attr.speed)
	
	label = mLayerPlayerInfoRoot:getChildByName("Label_Miss")
	tolua.cast(label,"UILabel")	
	label:setText("闪避："..attr.miss_ratio)
	
	for i=1,4 do
		local rune_id = ModelPlayer.sculpture[i]
		
		if rune_id ~= nil then
			local _,rune_attr = ModelRune.getRuneAppendAttr(rune_id)
			if rune_attr == nil then
				print("玩家信息 身上符文错误i:",i)
				string.print_int64("rune_id:",rune_id)
			else
				local image = mLayerPlayerInfoRoot:getChildByName("ImageView_DW_"..i)
				tolua.cast(image,"UIImageView")	
				image:loadTexture("Icon/"..rune_attr.icon)
				image:registerEventScript(		
						function(typename,widget)
							if "releaseUp" == typename then
								local param = {}
								param.id = rune_id
								BackpackUIManage.addLayer("UI_runeInfo",param)
								
							end
						end)
				
				--添加品质框
				CommonFunc_AddQualityNode(image,rune_attr.quality)
			end
		end
	end
	
	for i=1,2 do
		local temp_id = ModelPlayer.skill[i]
		print("ModelPlayer.skill",ModelPlayer.skill[i])
		local attr = LogicTable.getItemById(temp_id)
		
		if attr == nil then
			return
		end
		
		local image = mLayerPlayerInfoRoot:getChildByName("ImageView_TF_"..i)
		tolua.cast(image,"UIImageView")	
		image:loadTexture("Icon/"..attr.icon)
		image:registerEventScript(		
					function(typename,widget)
						if "releaseUp" == typename then
							local param = {}
							param.itemid = attr.id
							BackpackUIManage.addLayer("UI_itemInfo",param)
							end
						end)
				
				--添加品质框
			CommonFunc_AddQualityNode(image,attr.quality)
		
	end
end

function LayerPlayerInfo.onExit()
	
	
	
end