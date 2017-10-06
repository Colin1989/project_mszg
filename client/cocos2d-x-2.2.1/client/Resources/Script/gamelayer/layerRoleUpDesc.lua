LayerRoleUpDesc = setmetatable({},{__mode='k'})

LayerRoleUpDesc.jsonFile = "Role_up_desc_1.json"


local function handle_onClick(typeName,widget) 
	if typeName == "releaseUp" then
		local curName = widget:getName()		
		if curName == "cancle_roleupdesc" then 
			setConententPannelJosn(LayerRoleUpPotent,LayerRoleUpPotent.jsonFile,curName)
		end 
	end 
end 

--设置星星
local function showStar(root,key)
	for k=1, key - 1 do 
		local star = root:getChildByName("roleup_star"..k)
		star:setVisible(true)
	end
end 
-- 设置玩家5态
local function showRole(root,index)
	local role_appence = root:getChildByName("role_appence")
	
	local role_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),index)	
	local role_Ani = ResourceManger.getAnimationFrameById(role_tplt.icon)
	ResourceManger.LoadSinglePicture(role_Ani.name)
	local strPath = string.format("%s_%s", role_Ani.name, role_Ani.wait).."_%03d.png"
	local playerNode = createAnimation_forever(strPath, role_Ani.wait_frame, 0.1)
	role_appence:addRenderer(playerNode,23)
end
local function setPotent_Desc_info(root,index)
	local role_advent_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),index)	
	--说明文字
	local desc = root:getChildByName("potent_desc")
	tolua.cast(desc,"UIImageView")
	desc:loadTexture(string.format("potent_require%d.png",index))
	
	--数字标签
	local need_potent = root:getChildByName("atlas_potent_require")
	tolua.cast(need_potent,"UILabelAtlas")
	need_potent:setStringValue(string.format("%.2f",tonumber(role_advent_tplt.potence_level)/100))
end 

local function setScollPanenl (rootview)
	local ScrollView = rootview:getChildByName("ScrollView_roleupdesc")

	local UIWidgetTb = {}
	for k=2,6 do
		local ViewRoot = GUIReader:shareReader():widgetFromJsonFile("Role_Updesc_info_1.json")
		showStar(ViewRoot,k)
		showRole(ViewRoot,k)
		setPotent_Desc_info(ViewRoot,k)
		table.insert(UIWidgetTb,ViewRoot)
	end

	setAdapterGridView(ScrollView,UIWidgetTb,1,0) 
	--setListViewAdapter(LayerRoleUpDesc,ScrollView,UIWidgetTb,"V")
end 

LayerRoleUpDesc.onItemClick =function(pos)

end

LayerRoleUpDesc.init = function(rootview)
	rootview:getChildByName("cancle_roleupdesc"):registerEventScript(handle_onClick)
	setScollPanenl(rootview)
end 


LayerRoleUpDesc.destroy = function()
	
end