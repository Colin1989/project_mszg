----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-20
-- Brief:	天赋界面
----------------------------------------------------------------------
LayerRoleTalent = {}
LayerRoleTalent.jsonFile = "RoleTalent.json"

LayerRoleTalent.RootView = nil
----------------------------------------滚动层数据------------------------------
--根据副本id，判断本层有没有解锁
local function isLayerLock(index)
	local role_advent_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),index)
	local potenceInfo = string.format("%.2f",tonumber(role_advent_tplt.potence_level)/100)
	local mPotenceInfo = ModelPlayer.getPotenceLevel()
	if tonumber(mPotenceInfo) >= tonumber(role_advent_tplt.potence_level) then
		return true, potenceInfo
	end
	return false, potenceInfo
end

--判断天赋Id有没有被激活
local function isIdActive(talentId)
	local activeIdTb = TalentLogic.getActiveTalentIds()
	for key,value in pairs(activeIdTb) do
		if talentId == value then
			return true
		end
	end
	return false
end

--判断该层有没有天赋被激活
local function IsLayerActive(layer)
	local alldata = TalentLogic.getScrollData()
	local layerData = alldata[layer]
	for key,value in pairs(layerData) do
		if isIdActive(value.id) then
			return true,value.position
		end
	end
	return false,0
end

--获得天赋界面的感叹号
LayerRoleTalent.getTip = function()
	if CopyDateCache.getCopyStatus(LIMIT_TALENT.copy_id) ~= "pass" or  tonumber(LIMIT_TALENT.copy_id) == 1 then
		return false
	end
	
	local flag = false
	local allData = TalentLogic.getScrollData()
	
	for key,val in pairs(allData) do
		----------------------------------------------第六层数据尚未配置-----------------------------------------------------------
		-- if key == 6 then
			-- return false
		-- end
		------------------------------------------------------------------------------------------------------------
		if isLayerLock(key) then
			if IsLayerActive(key) == false then
				return true
			end
		end
	end
	return false
end
-----------------------------------按钮事件---------------------------
-- 点击重置按钮
local function clickResetBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		UIManager.push("UI_RoleTalent_Reset")
	end
end

-- 点击返回按钮
local function clickBackBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		setConententPannelJosn(LayerRoleUp,LayerRoleUp.jsonFile,curName)
	end
end

--为每一项创建点击事件
local function itemClick(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onMessage("click_role_talent")
		local talentId = widget:getTag()       	-- 天赋的id
		local talentInfo = LogicTable.getTalentTableRow(talentId)
		local layer	= talentInfo.layer			-- 表示是第几层
		local tb = {}			-- 表示要传过去的表
		tb.talentId = talentId
		
		if isLayerLock(layer) == false then				--本层没有解锁
			tb.click = false		--表示激活按钮可不可以点击
			tb.visible = false		--表示激活按钮不显示
			UIManager.push("UI_RoleTalent_NoActive",tb)
		else											--本层解锁了
			tb.visible = true							--表示激活按钮显示
			if IsLayerActive(layer) then				--本层有激活过的id
				if isIdActive(talentId)then				--点击的是已经激活过的
					UIManager.push("UI_RoleTalent_Active",tb)
				else									--点击的是没有被激活过的
					tb.click = false
					UIManager.push("UI_RoleTalent_NoActive",tb)
				end
			else										--本层没有激活过的id
				tb.click = true
				UIManager.push("UI_RoleTalent_NoActive",tb)
			end
		end
	end
end
---------------------------------------加载滚动层---------------------------------
--加载每层的图片和名字
local function loadIconAndName(node,layerNum,ItemDate)
	local delockFlag,potenceInfo = isLayerLock(layerNum)
	--解锁副本名(副本bg)
	local copyNameBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,-82), CCSizeMake(496,32),"public2_bg_05.png", "copyNameBg",5)
	node:addChild(copyNameBg)
	copyNameBg:setScale9Enabled(true)
	copyNameBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	local copyName = CommonFunc_createUILabel(ccp(0.5,0.5), ccp(0,0), nil,20, ccc3(255, 255, 255), 
		"", 3, 1)
	copyNameBg:addChild(copyName)
	
	--最上面的遮罩
	local imgTop = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(0,0),CCSizeMake(532,222),"public2_bg_07_g.png","imgTop",11)
	node:addChild(imgTop)
	imgTop:setScale9Enabled(true)
	imgTop:setCapInsets(CCRectMake(20, 20, 1, 1))
	local imgUnlock = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(-232,75),CCSizeMake(532,222),"inborn_unlock.png","imgUnlock",2)
	node:addChild(imgUnlock)
	if delockFlag == false then					--本层没有解锁
		imgTop:setVisible(true)
		imgTop:setOpacity(180)
		copyNameBg:setVisible(true)
		imgUnlock:setVisible(false)
		copyName:setText(GameString.get("Public_talent_copy",potenceInfo))
	else										--本层解锁了
		imgUnlock:setVisible(true)
		imgTop:setVisible(false)
		imgTop:setOpacity(255)
		copyName:setText(GameString.get("Public_talent_copy_no"))
	end
	
	for key,value in pairs(ItemDate) do
		--整个图片、名字的背景
		local imgBg = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(-120 +152*(key-1),14),CCSizeMake(135,144),"public2_bg_22.png","imgBg",2)
		imgBg:setScale9Enabled(true)
		imgBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		node:addChild(imgBg)
		imgBg:setTouchEnabled(true)
		imgBg:setTag(value.id)
		imgBg:registerEventScript(itemClick)
		--名字的背景
		local nameBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,71), CCSizeMake(112,34),"public2_bg_06.png", "nameBg",5)
		nameBg:setScale9Enabled(true)
		nameBg:setCapInsets(CCRectMake(22, 19, 1, 1))
		imgBg:addChild(nameBg)
		--名字
		local name = CommonFunc_createUILabel(ccp(0.5,0.5), ccp(0,0), nil, 22, ccc3(255, 255, 255), 
			value.name, 3, 1)
		nameBg:addChild(name)
		--图片
		local img = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(1,4), CCSizeMake(94,94),value.icon, "img_3",8)
		imgBg:addChild(img)
		--框
		local kuang = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(1,4), CCSizeMake(94,94),"runekuan_7.png", "kuang",10)
		imgBg:addChild(kuang)
		--等级
		local lel = UILabelAtlas:create()
		lel:setName("level")
		lel:setProperty("01234567890", "labelatlasimg.png", 24, 32, "0")
		lel:setScale(0.5)
		lel:setZOrder(20)
		lel:setPosition(ccp(-32, 38))
		imgBg:addChild(lel)
		lel:setStringValue(ModelSkill.getTalentLevel(value.id))
		--显示是激活的还是未激活的
		local activeLbl = CommonFunc_createUILabel(ccp(0.5,0.5), ccp(0,-56), nil, 16, ccc3(250, 184, 27), 
			nil, 3, 5)							
		imgBg:addChild(activeLbl)
		if IsLayerActive(layerNum) then				--本层有激活过的id
			if isIdActive(value.id)then				--点击的是已经激活过的
				if ModelSkill.getTalentLevel(value.id) >= value.max_level then
					activeLbl:setText(GameString.get("Public_talent_click_Full"))
				else
					activeLbl:setText(GameString.get("Public_talent_click_lelUp"))
				end
					
				LayerInviteCode.showParticle(kuang, true)
				Lewis:spriteShaderEffect(img:getVirtualRenderer(), "buff_gray.fsh", false)
			else									--点击的是没有被激活过的
				activeLbl:setText(GameString.get("Public_talent_click_noActive"))
				LayerInviteCode.showParticle(kuang, false)
				Lewis:spriteShaderEffect(img:getVirtualRenderer(), "buff_gray.fsh",true)
			end 
		else										--本层没有激活过的id
			Lewis:spriteShaderEffect(img:getVirtualRenderer(), "buff_gray.fsh", true)
			activeLbl:setText(GameString.get("Public_talent_click_Active"))
		end		
	end
end

--点击显示碎片信息
local function iconClick(clickType,widget)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(widget)
	CommonFunc_showInfo(0, widget:getTag(), 0, nil, 1)
end

--设置碎片的图片和个数
local function setFragInfo()
	local fragInfo = SkillConfig.getSkillFragInfo(RoleTalent_FragId)
	local fragIcon = tolua.cast(LayerRoleTalent.RootView:getChildByName("Icon_frag"),"UIImageView")
	fragIcon:loadTexture(fragInfo.icon)	
	fragIcon:setTag(fragInfo.id)
	fragIcon:setTouchEnabled(true)
	fragIcon:registerEventScript(iconClick)
	local fragNum = tolua.cast(LayerRoleTalent.RootView:getChildByName("fragNum"),"UILabelAtlas")
	fragNum:setStringValue(ModelSkill.getFragCount(RoleTalent_FragId))
end


--设置scrollView
local function createScrollView()
	--设置碎片信息
	setFragInfo()
	--滚动条
	local scroll = LayerRoleTalent.RootView:getChildByName("ScrollView_content")
	tolua.cast(scroll,"UIScrollView")
	
	local allData = TalentLogic.getScrollData()
	if #allData == 0 then
		Toast.show("目前策划只配了战士的数据")
		return
	end
	local data = {}
	for k,v in pairs(allData) do
		local ItemDate = v
		table.insert(data,ItemDate)
		--------------------------------------------------------------------
		-- if k == 5 then					-- 第6层尚未开启，时间仓促先做简单处理---------------------特此标记
			-- break
		-- end
		--------------------------------------------------------------------
	end 
	
		--创建每一项
		local function createScrollItem(ItemDate)
			local layerNum = ItemDate[1].layer			--层数，表示是第几层
			--整个底板
			local node = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(532,222), "public2_bg_07.png", "node"..layerNum,0)
			node:setScale9Enabled(true)
			node:setCapInsets(CCRectMake(20, 20, 1, 1))	
			--层数（层数背景）
			local layerBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(-226,11), CCSizeMake(44,144), "public2_bg_07.png", "layerBg", 1)
			layerBg:setScale9Enabled(true)
			layerBg:setCapInsets(CCRectMake(22, 24, 1, 1))
			node:addChild(layerBg)
			local layerTb = CommonFunc_createUILabel(ccp(0.5,0.5),ccp(0,0), nil,34,ccc3(248, 228, 78), 
			GameString.get("Public_talent_layer",layerNum),3,5)
			layerTb:setSize(CCSizeMake(33,108))
			--layerTb:setTextAreaSize(CCSizeMake(33,130))
			layerTb:setTextHorizontalAlignment(kCCTextAlignmentCenter)
			layerBg:addChild(layerTb)
			--layerTb:ignoreContentAdaptWithSize(true)
			--加载每层的图片和名字--加载有没有解锁和遮盖的遮罩
			loadIconAndName(node,layerNum,ItemDate)
			return node
		end
	UIEasyScrollView:create(scroll,data,createScrollItem,4, true,0,1,true)	
end
----------------------------------------------------------------------
--设置冷却时间
local function setLeftTime(leftTime)
	if LayerRoleTalent.RootView == nil then
		return
	end
	--冷却时间
	local leftTimeLbl = LayerRoleTalent.RootView:getChildByName("leftTime")
	tolua.cast(leftTimeLbl,"UILabel")
	leftTimeLbl:setText(GameString.get("Public_talent_reset", leftTime))
end
----------------------------------------------------------------
LayerRoleTalent.init = function(rootview)
	LayerRoleTalent.RootView = rootview
	
	--重置天赋
	local resetBtn = LayerRoleTalent.RootView:getChildByName("reset")
	tolua.cast(resetBtn,"UIButton")
	resetBtn:registerEventScript(clickResetBtn)
	--返回按钮
	local backBtn = LayerRoleTalent.RootView:getChildByName("back")
	tolua.cast(backBtn,"UIButton")
	backBtn:registerEventScript(clickBackBtn)
	--设置剩余时间
	setLeftTime(TalentLogic.getLeftTime())
	--创建scrollView
	createScrollView()
	TipModule.onUI(rootview, "ui_roletalent")
end 

LayerRoleTalent.destroy = function()
    LayerRoleTalent.RootView = nil	
end

EventCenter_subscribe(EventDef["ED_ROLETALENT_Time"],setLeftTime)
--升级后需要维护界面，重置后需要维护界面，激活后需要维护界面
EventCenter_subscribe(EventDef["ED_ROLETALENT_LEVELUP"], createScrollView)