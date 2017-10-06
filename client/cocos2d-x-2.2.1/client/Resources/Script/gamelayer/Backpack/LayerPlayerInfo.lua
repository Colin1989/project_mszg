--玩家详细信息    背包-》详细信息 按钮

local mLayerRoot = nil


LayerPlayerInfo = {
}

local function updatePlayerInfo()
	if nil == mLayerRoot then
		return
	end
	local attr, baseAttr, equipAttr = ModelPlayer.getPlayerAttr()
	local blessBuff = BlessLogic.getBlessBuff()
	-- 生命
	local lifeLabel = tolua.cast(mLayerRoot:getChildByName("Label_HP"), "UILabel")
	lifeLabel:setText(tostring(attr.life))
	-- 攻击
	local attackLabel = tolua.cast(mLayerRoot:getChildByName("Label_ATK"), "UILabel")
	attackLabel:setText(tostring(attr.atk))
	-- 速度
	local speedLabel = tolua.cast(mLayerRoot:getChildByName("Label_Speed"), "UILabel")
	speedLabel:setText(tostring(attr.speed))
	
	local hitPercent,criticalPercent,missPercent,tenacityPercent = 0,0,0,0,0
	hitPercent = transform_2(attr.hit_ratio).."%"
	criticalPercent = transform_1(attr.critical_ratio).."%"
	missPercent = transform_1(attr.miss_ratio).."%"
	tenacityPercent = transform_1(attr.tenacity).."%"
	if tonumber(blessBuff.bless_type) == 6 then		--闪避
		missPercent = attr.miss_ratio_add.."%"
	end
	if tonumber(blessBuff.bless_type) == 7 then		--韧性
		tenacityPercent = attr.tenacity_add.."%"
	end
	if tonumber(blessBuff.bless_type) == 5 then		--暴击
		criticalPercent = attr.critical_ratio_add.."%"
	end
	if tonumber(blessBuff.bless_type) == 4 then		--命中
		hitPercent = attr.hit_ratio_add.."%"
	end
	-- 命中
	local hitLabel = tolua.cast(mLayerRoot:getChildByName("Label_Hit"), "UILabel")
	hitLabel:setText(tostring(attr.hit_ratio)..GameString.get("PUBLIC_L_BRACKET")..hitPercent..GameString.get("PUBLIC_R_BRACKET"))
	-- 暴击
	local criticalLabel = tolua.cast(mLayerRoot:getChildByName("Label_Crit"), "UILabel")
	criticalLabel:setText(tostring(attr.critical_ratio)..GameString.get("PUBLIC_L_BRACKET")..criticalPercent..GameString.get("PUBLIC_R_BRACKET"))
	-- 闪避
	local missLabel = tolua.cast(mLayerRoot:getChildByName("Label_Miss"), "UILabel")
	missLabel:setText(tostring(attr.miss_ratio)..GameString.get("PUBLIC_L_BRACKET")..missPercent..GameString.get("PUBLIC_R_BRACKET"))
	-- 韧性
	local tenacityLabel = tolua.cast(mLayerRoot:getChildByName("Label_DEF"), "UILabel")
	tenacityLabel:setText(tostring(attr.tenacity)..GameString.get("PUBLIC_L_BRACKET")..tenacityPercent..GameString.get("PUBLIC_R_BRACKET"))
	-- 设置祝福属性颜色
	local attrLabelTb = {lifeLabel, attackLabel, speedLabel, hitLabel, criticalLabel, missLabel, tenacityLabel}
	for i=1, 7 do
		local attrLabel = attrLabelTb[i]
		if i == blessBuff.bless_type then
			attrLabel:setColor(ccc3(0, 255, 0))
		else
			attrLabel:setColor(ccc3(209, 155, 16))
		end
	end
end

function LayerPlayerInfo.Action_onEnter()
	local widget = mLayerRoot:getChildByName("ImageView_2053")--底板
	Animation_ScaleTo_FadeIn(widget,0.4)
end

function LayerPlayerInfo.init(root)
	mLayerRoot = root
	-- 玩家id
	local idLabel = tolua.cast(mLayerRoot:getChildByName("Label_ID"), "UILabel")
	idLabel:setText(ModelPlayer.getNickName())
	-- 职业
	local roleTypeLabel = tolua.cast(mLayerRoot:getChildByName("Label_ZY"), "UILabel")
	local strRoleType = CommonFunc_GetRoleTypeString(ModelPlayer.getRoleType())
	roleTypeLabel:setText(strRoleType)
	-- 潜能
	local potentLabel = tolua.cast(mLayerRoot:getChildByName("Label_QN"), "UILabel")
	potentLabel:setText(string.format("%.2f", ModelPlayer.getPotenceLevel()/100))
	-- 军阶
	local miltitaryLevel = MiltitaryLogic.getMiltitaryLevel()
	local miltitaryLabel = tolua.cast(mLayerRoot:getChildByName("Label_JJ"), "UILabel")
	if 0 == miltitaryLevel then
		miltitaryLabel:setText(GameString.get("PUBLIC_NONE"))
	else
		miltitaryLabel:setText(LogicTable.getMiltitaryRankRow(miltitaryLevel).name)
	end
	-- 属性信息
	updatePlayerInfo()
	TipModule.onUI(root, "ui_playerinfo")
end

function LayerPlayerInfo.destroy()
	mLayerRoot = nil
end

function LayerPlayerInfo.onExit()
end

EventCenter_subscribe(EventDef["ED_BLESS_TIMER_OVER"], updatePlayerInfo)

