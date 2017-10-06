------------------------------------------------------------------------ 作者：lewis-- 日期：2013-3-31-- 描述：当前玩家角色状态视图----------------------------------------------------------------------PlayerInfoView = class(RoleInfoView)function PlayerInfoView:ctor()    self.UpdateLabelTimer = nil	self.mRole = nil			--绑定的角色	self.mLifeIcon		= nil	--生命图标	self.mLifeBar		= nil	--生命槽	self.mLabels		= {}	--1生命，2攻击力，3速度	self.mOriginals		= {}	--原始数据	self.mShowPoint     = {}    --显示数值	self.mSkillBtnTB	= {}endfunction PlayerInfoView:init(role)	self.mRole = role	local layer = CCLayer:create()	LayerGameUI.mRootView:addChild(layer, 10002)	self.mRootView = layer    --self.mRole:setConfig("role_infoViewRoot",layer)	self:initBuff()		self:createSkillBtn()	self:createAttrView()	end--更新全部function PlayerInfoView:updateAll()	self:updateAttr()	self:updateSkill()    self:updateBuff()end-----------------------------------------------------------------------------------------------------------基本数据--------------------------------------------------------------------------------------------------------------local function numberModifiedAction(node)	local scale = 1.2 * 2.5	node:stopAllActions()	node:setScale(0.6)    local arr = CCArray:create()		arr:addObject(CCEaseBackInOut:create(CCScaleBy:create(0.2, scale)))	arr:addObject(CCEaseBackInOut:create(CCScaleBy:create(0.07, 1 / scale)))	arr:addObject(CCEaseBackInOut:create(CCScaleBy:create(0.2, scale)))	arr:addObject(CCEaseBackInOut:create(CCScaleBy:create(0.07, 1 / scale)))    arr:addObject(CCEaseBackInOut:create(CCScaleBy:create(0.2, scale)))	arr:addObject(CCEaseBackInOut:create(CCScaleBy:create(0.07, 1 / scale)))	node:runAction(CCSequence:create(arr))end--创建生命,速度,攻击力视图function PlayerInfoView:createAttrView()	self.mLabels[1] 	= LayerGameUI.mLifeLabel	self.mLabels[2] 	= LayerGameUI.mAtkLabel		self.mLabels[3] 	= LayerGameUI.mSpeedLabel	self.mOriginals[1]	= 0	self.mOriginals[2]	= 0	self.mOriginals[3]	= 0		self.mLifeBar = LayerGameUI.mRootView:getWidgetByName("player_lifebar"):getVirtualRenderer()	self.mLifeBar = tolua.cast(self.mLifeBar, "CCSprite")		self.mLifeIcon = LayerGameUI.mRootView:getWidgetByName("ImageView_131"):getVirtualRenderer()	self.mLifeIcon = tolua.cast(self.mLifeIcon, "CCSprite")    local attribute = self.mRole.mData.mAttribute	for i = 1, 3 do        self.mOriginals[i] = attribute:getByIndex(i)        self.mShowPoint[i] = self.mOriginals[i]        self.mLabels[i]:setStringValue(string.format("%d",self.mOriginals[i]))    end end--更新主要属性function PlayerInfoView:updateAttr()	local attribute = self.mRole.mData.mAttribute	for i = 1, 3 do		local cur = attribute:getByIndex(i)		local label = self.mLabels[i]		label:setStringValue(string.format("%d", cur))		local color = attribute:getColor(i)		self:labelOnColor(label, color)        if cur ~= self.mOriginals[i] then
			numberModifiedAction(label)
			self.mOriginals[i] = cur
		end        --[[		if cur ~= self.mOriginals[i] then            local updateParam = {}
			updateParam.cur = cur
			updateParam.delta = self.mOriginals[i] - cur
            updateParam.origin = self.mOriginals[i]
            updateParam.label = label
            updateParam.key = i

            updateParam.lifeBar = self.mLifeBar

			self:createUpdateBattleTimer()
            self.UpdateLabelTimer.stop()
			self.UpdateLabelTimer.setParam(updateParam)
			self.UpdateLabelTimer.start()			            self.mShowPoint[i] = self.mShowPoint[i] - updateParam.delta			self.mOriginals[i] = cur		end        ]]--	end		--生命条    local size = self.mLifeBar:getTexture():getContentSizeInPixels()	local percentage = attribute:getByName("life") / attribute:getMaxAttrWithName("life")	local length = size.width * percentage	self.mLifeBar:setTextureRect(CCRectMake(size.width - length, 0, length, size.height))	end---数字跳动测试  
function PlayerInfoView:createUpdateBattleTimer()
    local function getDetla(delta)
	    local x = math.abs(delta)
        if x > 10 then 
		    return math.floor(x/10)
	    else
		    return math.floor(x)
	    end
    end 

	if nil == self.UpdateLabelTimer then
		self.UpdateLabelTimer = CreateTimer(0.04, -1, function(ct)
	
			local cur = ct.getParam().cur   --当前 要变成的值
            local origin = ct.getParam().origin --原来的值
			local delta = ct.getParam().delta  
            local i = ct.getParam().key
            local label = ct.getParam().label


            cclog("cur",cur, "origin",origin,"delta",delta,"getDetla(delta)",getDetla(delta))
			if  cur < origin then 
		        self.mShowPoint[i] = self.mShowPoint[i] - getDetla(delta)
                label:setStringValue(string.format("%d",self.mShowPoint[i]))
				if  self.mShowPoint[i] < cur then 
                    self.mShowPoint[i] = cur
					label:setStringValue(tostring(cur))
					ct.stop()
				end
            elseif cur > origin then 
                self.mShowPoint[i] = self.mShowPoint[i] + getDetla(delta)
				label:setStringValue(string.format("%d",self.mShowPoint[i]))
				if  self.mShowPoint[i] > cur then 
                    self.mShowPoint[i] = cur
					label:setStringValue(tostring(cur))
					ct.stop()
				end 
			end

		end, nil)
	end
end-----------------------------------------------------------------------------------------------------------buff数据--------------------------------------------------------------------------------------------------------------function PlayerInfoView:initBuff()  --FIXBUFF  VIEW	--buff	local unit = self.mBuffView["buff"]	unit.labelPos 		= ccp(198, 84)	unit.labelScale		= 0.4	unit.startPos 		= self.mRole:getMiddlePos()	unit.iconPos		= ccp(198, 122) --改为增益	unit.iconScale 		= 1.0    unit.buffIconPos    = ccp(176, 100)    unit.bufficonScale 	= 1.0    --debuff	unit = self.mBuffView["debuff"]	unit.labelPos 		= ccp(198, 22)	unit.labelScale		= 0.4	unit.startPos 		= self.mRole:getMiddlePos()	unit.iconPos		= ccp(198, 55)	unit.iconScale 		= 1.0    unit.buffIconPos    = ccp(176,52)    unit.bufficonScale 	= 1.0	self:createBuffLabel()endfunction PlayerInfoView:createBuffLabel()	for key, value in pairs(self.mBuffView) do        --icon        local buffIcon = CCSprite:create("status_"..key..".png")        buffIcon:setPosition(value.buffIconPos)        buffIcon:setScale(value.bufficonScale)        self.mRootView:addChild(buffIcon)        value.buffIcon = buffIcon        local buff_count_bg = CCSprite:create("buff_count_bg.png")        buff_count_bg:setPosition(ccp(value.buffIconPos.x +10,value.buffIconPos.y+14))        self.mRootView:addChild(buff_count_bg)         --buff数量		local label = CCLabelAtlas:create("0", "num_black.png", 24, 32, 48)		self.mRootView:addChild(label)		label:setPosition(ccp(value.buffIconPos.x +10,value.buffIconPos.y+14))		label:setScale(value.labelScale)		label:setAnchorPoint(ccp(0.5, 0.5))		label:setVisible(true)		value.label = label	endend--更新bufffunction PlayerInfoView:updateBuff()	local buffTb = self.mRole:getDataInfo("buff")    local newbuff = nil     for key,buffObj in pairs(buffTb) do         if buffObj:getBuffConfig("new_flag") == true then             newbuff = buffObj            break        end     end     --更新BUFF的数量标记	for key, value in pairs(self.mBuffView) do        local amount = BuffMgr.getBuffAmonutByType(self.mRole,key)        self:updateBuffUnit(key,amount)	end    --播放新BUFF动画
    if newbuff ~= nil then 
         local iconRes = newbuff:getBuffConfig("buff_icon")
         local unit = self.mBuffView[self:getBuffType(newbuff:getBuffConfig("buff_type"))]
         --是否需要飘ICON
         if iconRes~=nil and string.find(iconRes,".png") and unit ~= nil then 
             local sprite = CCSprite:createWithSpriteFrameName(iconRes)	         self.mRootView:addChild(sprite)	         sprite:setPosition(unit.startPos)	         sprite:setScale(unit.iconScale)	         unit.icon = sprite	         buffIconEnterAction(sprite, unit.startPos, unit.iconPos, unit.iconScale)
        end
        newbuff:setBuffConfig("new_flag",false)
    endend-----------------------------------------------------------------------------------------------------------技能数据----------------------------------------------------------------------------------------------------------------创建技能按钮function PlayerInfoView:createSkillBtn()	local imgBg = tolua.cast(LayerGameUI.mRootView:getWidgetByName("ImageView_23"), "UIImageView")	local skill = self.mRole.mData.mSkill	local tb = skill:getTB()	for key, value in pairs(tb) do		local pos = RoleMgr.getSkillBtnPosByIdx(key)		local btn = PlayerSkillBtn.new()		btn:init(imgBg, pos, value.id, value.level, key)		btn:setDelegate(self)		self.mSkillBtnTB[key] = btn	endendfunction PlayerInfoView:selectSkill(id, bOn)	--不能开启新回合	if BattleMgr.isNewRoundVaid() == false then		return false	end	local skill = self.mRole.mData.mSkill	local ret = skill:selectSkill(id, bOn)	if bOn == false then		return false	end	GuideEvent.selectSkill()	if ret == "auto" then		local level = skill:getLevel(id)		BattleMgr.autoSkill(self.mRole, id, level)		return true	end	return falseend--更新技能function PlayerInfoView:updateSkill()	local skill = self.mRole.mData.mSkill	local tb = skill:getTB()	for key, value in pairs(tb) do		if value.isValid then			self.mSkillBtnTB[key]:update(value.progress, value.needCD)		end	endend----取消选中所有技能function PlayerInfoView:unselectAllSkill()	for key, value in pairs(self.mSkillBtnTB) do		value:unSelect()	endend--锁定技能function PlayerInfoView:lockSkill(lockTb)	if 0 == #lockTb then		return	end	for key, value in pairs(self.mSkillBtnTB) do		for k1, v1 in pairs(lockTb) do			if key == v1 then				value:lock(v1)				break			end		end	endend------------------