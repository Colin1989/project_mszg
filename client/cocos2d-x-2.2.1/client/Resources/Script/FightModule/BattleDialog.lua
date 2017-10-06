require("RichText")

-----------------CONTROL----------------------

BDcontroller = {}

local mDate = XmlTable_load("copy_dialog.xml", "id").map  


function BDcontroller.getInstance()
    return mDate
end


function BDcontroller:ctor(DialogGroupId)
    self.mDateInfo = mDate                      --鎵�鏈夋暟鎹?
    self.mDialogGroupId = DialogGroupId         --褰撳墠缁処D
    self.mDialogInfo = nil                      --褰撳墠鍓湰鎵�鏈変俊鎭?
    self.mDialogIndex = 1                       --褰撳墠瀵硅瘽鍒扮鍑犲彞
end 


function BDcontroller:praseInfo(DialogGroupId)
    DialogGroupId = tostring(DialogGroupId)

    self:ctor(DialogGroupId)

    local DialogInfo = {} 
    for k,v in pairs(mDate) do 
        if DialogGroupId == v.dialog_groupid then 
            table.insert(DialogInfo,v)
        end 
    end 
    table.sort(DialogInfo, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
    

    self.mDialogInfo = DialogInfo
end     
--[[

indexInfo = {
    index = 1,
    callback = function(),
    param = param
}

]]--
function BDcontroller:viewDidLoad(_curCopyId,indexInfo)
 
    
    local copyInfo  = LogicTable.getCopyById(_curCopyId)
    local dialog_groupidTB =  CommonFunc_split(copyInfo.dialog_groupid, ",")
    self.indexInfo = indexInfo or {}

    --打过的副本没有对话
    if isGetReSpone(_curCopyId) == true then 
        if type(self.indexInfo.callback) ==  "function" then 
            self.indexInfo.callback(self.indexInfo.param)
			TipModule.onMessage("exit_battle_dialog")
            return
        end  
     end 
 

    local DialogGroupId =  tonumber(dialog_groupidTB[self.indexInfo.index])

    --当前事件没有对话
    if dialog_groupidTB[indexInfo.index] == nil or DialogGroupId < 0 then 
        if type(self.indexInfo.callback) ==  "function" then 
            self.indexInfo.callback(self.indexInfo.param)
        end 
		TipModule.onMessage("exit_battle_dialog")
        return
    end    

   
    if DialogGroupId ~=nil and DialogGroupId > 0 then 
        self:praseInfo(DialogGroupId)
        g_rootNode:addChild(BattleDialog:init(self.mDialogInfo), 1990, 1990)
	else
		TipModule.onMessage("exit_battle_dialog")
    end
end 

function BDcontroller:next()
    self.mDialogIndex = self.mDialogIndex + 1

    if (self.mDialogInfo[self.mDialogIndex] ~= nil ) then 
       BattleDialog:updateDialogText(self.mDialogInfo[self.mDialogIndex])
    else 
       BattleDialog:cleanup()
       if type(self.indexInfo.callback) ==  "function" then 
            self.indexInfo.callback(self.indexInfo.param)
       end 
    end 
end 




-----------------------VIEW-------------------
BattleDialog = {}
local m_priority = -2147483640

local function onTouch(eventType, x, y)
	if eventType == "began" then
		--local rect = mHighLight:boundingBox()
		--if rect:containsPoint(ccp(x, y)) then
            BDcontroller:next()
			return true
	elseif eventType == "moved" then
		
	else
		
	end
end

local function BattleDialog_createSpeaker(singleDialogInfo)
	
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
             local role_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel())	
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
        BattleDialog.mRootView:addChild(icon,k)
    end
end

local function BattleDialog_createSpeakContent(singleDialogInfo)
	
    local layerColor = CCLayerColor:create(ccc4(0,0,0,128),640,960)
    BattleDialog.mRootView:addChild(layerColor,-1)
	
    local mDialogBg = CCSprite:create("talkbackgroud.png")
	BattleDialog.mRootView:addChild(mDialogBg,10)
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
     Title:setPosition(ccp(20,145))
	 Title:setColor(ccc3(123,83,55))
     Title:setAnchorPoint(ccp(0.0, 0.5))
     mDialogBg:addChild(Title)

    --对话内容
    local layer,line = RichText.create(singleDialogInfo.content, CCSizeMake(495, 180), 22, {},"copydialog.fnt")
    local size = mDialogBg:boundingBox().size

    layer:setPosition(ccp(60,100))
	mDialogBg:addChild(layer)
end 

function BattleDialog:init(DialogInfo)

    self.mRootView 		= nil
    self.resTb 		= {}
    self.mIsTalking		= false

	if self.mRootView ~= nil then
		return
	end
	
	self.mRootView = CCLayer:create()
	self.mRootView:setTouchEnabled(true)
	self.mRootView:registerScriptTouchHandler(onTouch, false, m_priority, true)

    BattleDialog_createSpeakContent(DialogInfo[1])
	BattleDialog_createSpeaker(DialogInfo[1])
    return self.mRootView
end

function BattleDialog:updateDialogText(info)
    self.mRootView:removeAllChildrenWithCleanup(true)

    BattleDialog_createSpeaker(info)
    BattleDialog_createSpeakContent(info)
end 

function BattleDialog:release()
    ResourceManger.releasePlist(res)
end 

function BattleDialog:cleanup()
	if self.mRootView == nil then
		return
	end
	self.mRootView:removeFromParentAndCleanup(true)
	self.mRootView = nil
	TipModule.onMessage("exit_battle_dialog")
end
