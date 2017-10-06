------------------------------------------------------------------------ 作者: lewis hamilton-- 日期: 2014-05-13-- 描述: 战斗引导引擎----------------------------------------------------------------------GuideBattleEngine = {}local mGridCellWidth = 114		-- 战斗格子宽    114local mGridCellHeight = 107		-- 战斗格子高    107local mHandle = nil				-- 新手引导组处理句柄local mGuideIndex = 0			-- 引导步骤索引local mCurrentEvnir = {}		-- 当前环境表local mExcuteFuncTB = {}		-- 消息执行函数local mEffectiveMsgTB = {}		-- 感兴趣的消息表-- 文本IDlocal function getTextId()	return mHandle.id * 100 + mGuideIndexend-- 生成一个新的环境local function newEvnir()	mCurrentEvnir = {}end-- 是否为感兴趣的消息local function isExsitMsg(msg)	for key, value in pairs(mEffectiveMsgTB) do		if value == msg then			return true		end	end	return falseend-- 开启function GuideBattleEngine.guideStart(handle)	local rect = GridMgr.getConfig("gmc_map_rect")	mGridCellWidth = rect.size.width/GridMgr.getConfig("gmc_map_width")	mGridCellHeight = rect.size.height/GridMgr.getConfig("gmc_map_height")	mHandle = handle	mGuideIndex = 0	GuideView.create(handle.is_gone_masklayer)	GuideMgr.setGuideEngine(GuideBattleEngine)	GuideBattleEngine.excute()end-- 结束function GuideBattleEngine.guideEnd()	if mHandle then		GuideMgr.save(mHandle.id)		mHandle = nil	end	GuideView.cleanup()	GuideMgr.setGuideEngine(nil)end-- 是否是强制引导function GuideBattleEngine.isForce()	return trueend-- 执行function GuideBattleEngine.excute()	mGuideIndex = mGuideIndex + 1	mCurrentEvnir = nil	mEffectiveMsgTB = {}	local config = mHandle["config"][mGuideIndex]	if nil == config then		GuideBattleEngine.guideEnd()		return	end	mExcuteFuncTB[config.cmd](config)end-- 接收消息function GuideBattleEngine.onMessage(msg, param)	if nil == mCurrentEvnir then		return	end	if false == isExsitMsg(msg) then		return	end	if isExsitMsg("on_hurt") then		local life, maxLife = RoleMgr.getPlayerLife()		local lifePercent = (tonumber(life)/tonumber(maxLife))*100		if lifePercent >= mCurrentEvnir.percent then			return		end	end	GuideBattleEngine.excute()end-- 等候消息function GuideBattleEngine.waitMsg(config)	newEvnir()	GuideView.reset()	GuideView.updateLock(config.lock)	mEffectiveMsgTB = {config.msg or "on_wait_msg"}end-- 触摸function GuideBattleEngine.touch(config)	newEvnir()	GuideView.reset()	GuideView.updateLock(config.lock)	mEffectiveMsgTB = {"on_touch"}end-- 点击格子function GuideBattleEngine.tapGrid(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local gridId = tonumber(paramTB["grid_id"])	local pos = GridMgr.getPoistionByGridId(gridId)	GuideView.updateSize(mGridCellWidth, mGridCellHeight, true)	GuideView.updateLock(config.lock)	GuideView.updateText(getTextId())	GuideView.updatePos(pos, config.direct)    mEffectiveMsgTB = {"on_open_grid", "on_fight", "on_after_skill", "on_pickup_gold", "on_pickup_blood"}    	if config.msg then		table.insert(mEffectiveMsgTB, config.msg)	endend-- 点击格子列表function GuideBattleEngine.tapGridList(config)    newEvnir()	GuideView.reset()    local size = 1 --先做固定为1    local paramTB = GuideMgr.parseParamer(config.param)    local centerGridId = tonumber(paramTB["grid_id"])    local pos = GridMgr.getPoistionByGridId(centerGridId)	GuideView.updateSize(mGridCellWidth*3, mGridCellHeight*3, true)	GuideView.updateLock(config.lock)	GuideView.updateText(getTextId())	GuideView.updatePos(pos, config.direct)    mEffectiveMsgTB = {"on_open_grid", "on_fight", "on_after_skill", "on_pickup_gold", "on_pickup_blood"}    	if config.msg then		table.insert(mEffectiveMsgTB, config.msg)	endend -- 主角说话提示function GuideBattleEngine.talk(config)	newEvnir()
	GuideView.reset()
	local paramTB = GuideMgr.parseParamer(config.param)
	local width = paramTB["width"]
	local height = paramTB["height"]
	local x = paramTB["x"]
	local y = paramTB["y"]
	if width and height and x and y then
		GuideView.updateSize(width, height, false)
		GuideView.updatePos(ccp(x, y), config.direct)
	else
		GuideView.updatePos(ccp(360, config.posy or 420), config.direct)
	end
	GuideView.updateLock(config.lock)
	GuideView.updateText(getTextId())
	mEffectiveMsgTB = {"on_touch"}end-- 点击技能function GuideBattleEngine.tapSkill(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local skillId = tonumber(paramTB["skill_id"])	local pos =  RoleMgr.getSkillBtnPosByIdx(skillId)	GuideView.updateSize(110, 110, true)	GuideView.updateLock(config.lock)	GuideView.updateText(getTextId())	GuideView.updatePos(pos, config.direct)        if paramTB.self ~= nil then         mEffectiveMsgTB = {"on_after_skill"}    else 	    mEffectiveMsgTB = {"on_select_skill"}    end end-- 点击援军function GuideBattleEngine.tapAssist(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local skillId = tonumber(paramTB["skill_id"])	local pos =  RoleMgr.getSkillBtnPosByIdx(skillId)	GuideView.updateSize(110, 110, true)	GuideView.updateLock(config.lock)	GuideView.updateText(getTextId())	GuideView.updatePos(pos, config.direct)	mEffectiveMsgTB = {"on_select_assist"}    local p = CCSprite:create();end-- 使用技能function GuideBattleEngine.afterSkill(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local skillId = tonumber(paramTB["skill_id"])	local pos =  RoleMgr.getSkillBtnPosByIdx(skillId)	GuideView.updateSize(110, 110, true)	GuideView.updateLock(config.lock)	GuideView.updateText(getTextId())	GuideView.updatePos(pos, config.direct)	mEffectiveMsgTB = {"on_after_skill"}end-- 受到伤害function GuideBattleEngine.hurt(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local percent = tonumber(paramTB["percent"])	GuideView.updateLock(config.lock)	mCurrentEvnir.percent = percent	mEffectiveMsgTB = {"on_hurt"}end-- 技能解锁function GuideBattleEngine.skillLock(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local index = tonumber(paramTB["index"])	local flag = "true" == paramTB["flag"]	local skillBtn = RoleMgr.getPlayerSkillBtn(index)	if flag then		mEffectiveMsgTB = {config.msg or "on_skill_lock"}		skillBtn:lock()	else		mEffectiveMsgTB = {config.msg or "on_skill_unlock"}		skillBtn:unlock()	end	if "on_no_wait" == config.msg then		GuideBattleEngine.onMessage("on_no_wait")	endend-- 延迟function GuideBattleEngine.delay(config)	newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)	local timecount = tonumber(paramTB["time"])	GuideView.updateLock(config.lock)	mCurrentEvnir.config = config	mEffectiveMsgTB = {"on_delay"}	CreateTimer(timecount, 1, nil, function(tm) GuideBattleEngine.onMessage("on_delay") end).start()end--召唤 function GuideBattleEngine.summon(config)    newEvnir()	GuideView.reset()	local paramTB = GuideMgr.parseParamer(config.param)    local amount = paramTB["amount"]    local monsterid = paramTB["monsterId"]    local boss = GridMgr.getMonsterByGridId(8)      --新手写死 8的位置    GridMgr.summonMonster(amount, monsterid,boss)    GuideBattleEngine.excute()end --战斗对话 重写 by SLlocal function BattleDialogCreateSpeaker(singleDialogInfo)

    local  function getccpByPosId(posid)
        posid = tonumber(posid) local h = 400
        local pos = nil
        if posid == 1 then
            pos = ccp(260, h)
        elseif posid == 2 then
            pos = ccp(180, h)
        elseif posid == 3 then
           pos = ccp(100, h)
        elseif posid == 4 then
            pos = ccp(380, h)
        elseif posid == 5 then
            pos = ccp(460, h)
        elseif posid == 6 then
            pos = ccp(540, h)
        end
		
        return pos
    end 

    local speaker_iconTB = CommonFunc_split(singleDialogInfo.speaker_icon, ",")
    local speaker_posTB = CommonFunc_split(singleDialogInfo.speaker_pos, ",")
    local scaleTB = CommonFunc_split(singleDialogInfo.scale, ",")
    local isflipTB = CommonFunc_split(singleDialogInfo.isflip, ",")


    for k,icon_id in pairs(speaker_iconTB) do 

        local plistFile = ""
        if tonumber(icon_id) ~= 0 then 
            plistFile = ResourceManger.getAnimationFrameById(icon_id).name	
        else 
             local role_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel()	)	
	         plistFile = ResourceManger.getAnimationFrameById(role_tplt.icon).name
        end 

        ResourceManger.LoadSinglePicture(plistFile)	
        local strsb = plistFile.."_wait_001.png"
        local icon = CCSprite:createWithSpriteFrameName(strsb);

        icon:setAnchorPoint(ccp(0.5, 0.0))

	    icon:setPosition(getccpByPosId(speaker_posTB[k]))

        if isflipTB[k] == "1" then 
            icon:setFlipX(true)
        end 
       
        icon:setScale(tonumber(scaleTB[k]))

        return icon
        --BattleDialog.mRootView:addChild(icon,k)
    end 
end 

local function BattleDialogCreateSpeakContent(singleDialogInfo)

    local layerColor = CCLayerColor:create(ccc4(0,0,0,128),640,960)
    GuideView.getIntance():addChild(layerColor,-1)

    local mDialogBg = CCSprite:create("talkbackgroud.png")
	GuideView.getIntance():addChild(mDialogBg,10)
	mDialogBg:setAnchorPoint(ccp(0.5, 0.0))
	mDialogBg:setPosition(ccp(320, 300))

    --对话文字
     local speakerName = ""
     if singleDialogInfo.speaker == '0' then 
        speakerName = ModelPlayer.getNickName()
     else 
        speakerName = singleDialogInfo.speaker
     end 

     local Title = CCLabelTTF:create(speakerName, "Aril", 24);
     Title:setPosition(ccp(110,145))
	 Title:setColor(ccc3(123,83,55))
     Title:setAnchorPoint(ccp(0.5, 0.5))
     mDialogBg:addChild(Title)

    --对话内容
    local layer,line = RichText.create(singleDialogInfo.content, CCSizeMake(495, 180), 22, {},"copydialog.fnt")
    local size = mDialogBg:boundingBox().size

    layer:setPosition(ccp(60,400))

    GuideView.getIntance():addChild(layer,10)
end GuideBattleEngine.battleDialog = function(config)    newEvnir()	GuideView.reset()    GuideView.getIntance():removeAllChildrenWithCleanup(true)    GuideView.getIntance():setVisible(true)    local paramTB = GuideMgr.parseParamer(config.param)    local dialogId = paramTB["dialog_id"]    local _date = BDcontroller.getInstance()     local singleDialogInfo = _date[tostring(dialogId)]    local speakIcon = BattleDialogCreateSpeaker(singleDialogInfo)
    BattleDialogCreateSpeakContent(singleDialogInfo)    GuideView.getIntance():addChild(speakIcon)    mEffectiveMsgTB = {"on_touch"}end mExcuteFuncTB["tap_gridList"]   = GuideBattleEngine.tapGridListmExcuteFuncTB["battleDialog"]   = GuideBattleEngine.battleDialogmExcuteFuncTB["wait_msg"] 		= GuideBattleEngine.waitMsgmExcuteFuncTB["touch"]			= GuideBattleEngine.touchmExcuteFuncTB["tap_grid"] 		= GuideBattleEngine.tapGridmExcuteFuncTB["talk"] 			= GuideBattleEngine.talkmExcuteFuncTB["tap_skill"] 		= GuideBattleEngine.tapSkillmExcuteFuncTB["tap_assist"]		= GuideBattleEngine.tapAssistmExcuteFuncTB["after_skill"] 	= GuideBattleEngine.afterSkillmExcuteFuncTB["hurt"]			= GuideBattleEngine.hurtmExcuteFuncTB["skill_lock"]		= GuideBattleEngine.skillLockmExcuteFuncTB["summon"]			= GuideBattleEngine.summonmExcuteFuncTB["delay"]			= GuideBattleEngine.delay