
--符文兑换

LayerRuneConvert = {}
local mLayerRoot = nil

--local   runeId      -- 保存当前点击的item的符文id
local convertTable = nil 
local  debrisCount          --碎片总数（label）
local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		if widgetName == "Button_34" then -- 关闭按钮
			BackpackUIManage.closeLayer("UI_runeConvert")
		end
		
	end
	
end



--点击兑换按钮触发的方法
local  function  clickConvert(type,widget)
	print("我被点击了")
	if type == "releaseUp" then
		for key,val in pairs(convertTable) do
		
              if widget:getTag() == key*100  then
	              local tb = req_sculpture_convert()	    --发送碎片兑换信息
	              tb.target_item_id =  val.id                      --兑换
				print("请求的技能id：",val.id)
	              NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_convert"])
			  end
		end
    end

end


--创建一条一条的item,参数为：图片名(注意类型)，碎片数量,技能说明,兑换的图片,数组的第几个值
local  function addScrollItem(iconStr,fragNum,skillInfo,convertIcon,index)
   local  itemPanel = UILayout:create()       --整个大的容器
   itemPanel:setSize(CCSizeMake(574,152))
   itemPanel:setBackGroundImage("public2_Decoration_5.png",UI_TEX_TYPE_PLIST) 
   local  icon = UIImageView:create()             --技能图标
   icon:setSize(CCSizeMake(106,106))
   icon:setAnchorPoint(ccp(0.5,0.5))
   icon:setPosition(ccp(80,77))
   icon:loadTexture("Icon/" .. iconStr)
   itemPanel:addChild(icon)
   local  skillbackground  = UIImageView:create()          --技能框
   skillbackground:setSize(CCSizeMake(106,106))
   skillbackground:setAnchorPoint(ccp(0.5,0.5))
   skillbackground:setPosition(ccp(80,77))
   skillbackground:loadTexture("uibag_bg_framer.png",UI_TEX_TYPE_PLIST) 
   skillbackground:setZOrder(10)
   itemPanel:addChild(skillbackground)
    local  skillLabel = UILabel:create()          --技能说明
	skillLabel:setSize(CCSizeMake(238,100))
	skillLabel:setTextAreaSize(CCSize(238,100))
    skillLabel:setAnchorPoint(ccp(0.5,0.5))
     skillLabel:setPosition(ccp(253,76))
	skillLabel:setFontSize(20)
    skillLabel:setTextHorizontalAlignment(kCCTextAlignmentLeft)
   skillLabel:setText(skillInfo)
   itemPanel:addChild(skillLabel)
  
    local fragCount = UILabelAtlas:create()              --碎片数量
	fragCount:setProperty(fragNum,"GUI/labelatlasimg.png",24,32,"0")
	fragCount:setPosition(ccp(474,97))
	itemPanel:addChild(fragCount)
   local  fragBackground  = UIImageView:create()          --碎片字
   fragBackground:setSize(CCSizeMake(102,27))
   fragBackground:setAnchorPoint(ccp(0.5,0.5))
   fragBackground:setPosition(ccp(470,126))
   fragBackground:loadTexture("Text_a_03.png",UI_TEX_TYPE_PLIST) 
   itemPanel:addChild(fragBackground)


    local convertBtn = UIButton:create()        --兑换图片
	convertBtn:setSize(CCSizeMake(155,55))
	convertBtn:setAnchorPoint(ccp(0.5,0.5))
    convertBtn:setPosition(ccp(474,47))
	convertBtn:setTitleText("兑换")
	convertBtn:setTitleFontSize(31)
	convertBtn:setTitleColor(ccc3(221,172,67))
	convertBtn:setTouchEnabled(true)
	convertBtn:setTag(index*100)
	print("我正常吗？",convertIcon)
	if  convertIcon == "normal"  then                  -- 可以兑换的情况       (图片需修改)
		--convertBtn:loadTexture("Icon/001.png")
	    convertBtn:loadTextures("sureback.png","sureback.png","")
		convertBtn:setTouchEnabled(true)
	    convertBtn:registerEventScript(clickConvert)
	elseif  convertIcon ==  "gray" then              --不可以兑换的情况        （图片需修改）
	      convertBtn:loadTextures("shortbutton_gray.png","shortbutton_gray.png","")
	    -- convertBtn:loadTexture("Icon/002.png","Icon/002.png","")    
	  --  convertBtn:loadTexture("friends_addlight.png",UI_TEX_TYPE_PLIST)
		convertBtn:setTouchEnabled(false)
	end
    itemPanel:addChild(convertBtn)	
	return  itemPanel
end


local  function  refreshScroll()
	--获取符文兑换表
	scrollItem ={}
	local scroll=  mLayerRoot:getChildByName("ScrollView_33")
	scroll:setZOrder(40)
	scroll:setVisible(true)
	tolua.cast(scroll,"UIScrollView")
			
	convertTable = ModelRune.getRune_convert_table()
	for key,val in pairs(convertTable) do
		if val.can_show == 1 then  --当前显示兑换的符文碎片
			local runeAttr = ModelRune.getRune_tplt(val.id)

			--职业判断
			--runeAttr.role_type = ModelPlayer.roletype
			if runeAttr.role_type == ModelPlayer.roletype then	  --显示的兑换列表

				local  btnIcon = nil
				--数量足够满足兑换条件
				if debrisCount > val.frag_count then
					  btnIcon =  "normal"          --正常状态的图片字符串
				else     
					  btnIcon  =   "gray"         ----碎片数量不足，按钮显示灰色
				end
				
				--兑换数 (runeAttr.frag_count)--符文图标 --runeAttr.icon--符文介绍 --runeAttr.desc
				
				--runeId = val.id
				print("符文介绍：",runeAttr.desc)
			  local  item =	addScrollItem(runeAttr.icon,val.frag_count,runeAttr.desc,btnIcon,key)
				table.insert(scrollItem,item)	
			end	
		end
	end
	setListViewAdapter(LayerRuneConvert,scroll,CommonFunc_InvertedTable(scrollItem),"V")	
	print("我执行完了")	
end




function LayerRuneConvert.init(root,param)
	mLayerRoot = root
	
	local btn = mLayerRoot:getChildByName("Button_34")--关闭按钮
	btn:registerEventScript(onClickEvent)
	
	--当前符文碎片总数
	 debrisCount = ModelRune.RuneDebrisCount()
    total = mLayerRoot:getChildByName("Label_35")
	tolua.cast(total,"UILabelAtlas")
	total:setProperty(string.format("%d",debrisCount),"GUI/labelatlasimg.png",24,32,"0")
	
	refreshScroll()
	
end





	--tb.target_item_id = val.id
	

local function Handle_sculpture_convert_msg(resp)	
	CommonFunc_CreateDialog("兑换成功")
	
    debrisCount = ModelRune.RuneDebrisCount()
	total:setProperty(string.format("%d",allCount),"GUI/labelatlasimg.png",24,32,"0")
	refreshScroll()
	
end


--注册兑换事件
NetSocket_registerHandler(NetMsgType["msg_notify_sculpture_convert"], notify_sculpture_convert(), Handle_sculpture_convert_msg)
