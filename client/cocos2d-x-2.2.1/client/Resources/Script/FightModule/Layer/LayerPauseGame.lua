
-------------------------------------
--作者：李慧琴
--说明：战斗暂停界面
--时间：2014-3-26
-------------------------------------

LayerPauseGame = {
}

local 	mLayerPauseGameRoot = nil   --当前界面的根节点

local  	musicBtn					--音乐按钮
local  	effectBtn					--音效按钮
	
LayerAbstract:extend(LayerPauseGame)

--关于音乐的函数
local function  musicAction(type,widget)
	if type == "releaseUp" then
		local m_bMusic = Audio.getMscIsOpen()
		m_bMusic = not m_bMusic
		
		if m_bMusic == true then
			Audio.setAudioCfgWithSound(true)
			Audio.playBgMscByTag(1)--主战音乐
			musicBtn:loadTexture("Psuse_music.png")	
		else
			musicBtn:loadTexture("Psuse_nomusic.png")
			Audio.setAudioCfgWithSound(false)
		end 	
	end
end

--关于音效的函数
local function  effectAction(type,widget)
	if type == "releaseUp" then
		local m_bEffect = Audio.getEffectIsOpen()
		m_bEffect = not m_bEffect
		Audio.setAudioCfgWithEffect(m_bEffect)
		if m_bEffect == true then
				
			effectBtn:loadTexture("Psuse_sound.png")
		else
			effectBtn:loadTexture("Psuse_nosound.png")
			
		end 
	end
end

--继续战斗
local function continueAction(type,widget)
	if type == "releaseUp" then
		FightDateCache.setData("fd_game_pause", false)
		UIManager.pop("UI_PauseGame")
	end
end

--根据进入的模式，设置变量
local function getEnterGameMode()
	
	local index = FightDateCache.getData("fd_game_mode")
	print("getEnterGameMode********************",type(index))
	if tonumber(index) == 1 then
		return GameString.get("Public_Mode_Pub")
	elseif tonumber(index) == 2 then
		return GameString.get("Public_Mode_TuiTa")
	elseif tonumber(index) == 3 then
		return GameString.get("Public_Mode_JJC")
	elseif tonumber(index) == 4 then
		return GameString.get("Public_Mode_JJC_Train")
	elseif tonumber(index) == 5 then
		return GameString.get("Public_Mode_JJC_TianTiSai")
	elseif tonumber(index) == 6 then
		return GameString.get("Public_Mode_ActivityCopy")
	end
end


--离开副本 
local function leaveAction(type,widget)
	if type == "releaseUp" then
		local structConfirm = 
		{
			strText = GameString.get("LEVEL_COPY",getEnterGameMode()),
			buttonCount = 2,
			buttonName = {GameString.get("sure"),GameString.get("cancle")},
			buttonEvent = {function()
				UIManager.pop("UI_PauseGame")
				local gameMode = FightDateCache.getData("fd_game_mode")
				if 1 == gameMode then
					FightMgr.onExit()
					FightMgr.cleanup()
					UIManager.retrunMain("Fight_fail")
				elseif 6 == gameMode then
					FightMgr.onExit()
					FightMgr.cleanup()
					UIManager.retrunMain("Fight_fail")
				else
					FightEnd.gameSettle(2)
				end
			end,nil}, --回调函数
			buttonEvent_Param = {nil,nil} --函数参数
		}
		UIManager.push("UI_ComfirmDialog", structConfirm)
	end	
end

LayerPauseGame.init = function(bundle) 
	FightDateCache.setData("fd_game_pause", true)
    mLayerPauseGameRoot = UIManager.findLayerByTag("UI_PauseGame")
	
    musicBtn= mLayerPauseGameRoot:getWidgetByName("music")  --音乐按钮
    tolua.cast(musicBtn,"UIImageView")
	musicBtn:registerEventScript(musicAction)
	effectBtn= mLayerPauseGameRoot:getWidgetByName("effect")  --音效按钮
    tolua.cast(effectBtn,"UIImageView")
	effectBtn:registerEventScript(effectAction)
    local continueBtn= mLayerPauseGameRoot:getWidgetByName("continueGame")       --继续战斗
    tolua.cast(continueBtn,"UIButton")
	continueBtn:registerEventScript(continueAction)
    local leaveBtn =  mLayerPauseGameRoot:getWidgetByName("leaveGame")         --离开副本
    tolua.cast(leaveBtn,"UIButton")
    leaveBtn:registerEventScript(leaveAction)
	
	if  Audio.getMscIsOpen() == true then
		musicBtn:loadTexture("Psuse_music.png")
	elseif Audio.getMscIsOpen() == false then
		musicBtn:loadTexture("Psuse_nomusic.png")
	end
	
	if Audio.getEffectIsOpen() == true then
		effectBtn:loadTexture("Psuse_sound.png")	
	elseif Audio.getEffectIsOpen() == false then
		effectBtn:loadTexture("Psuse_nosound.png")	
	end
	if GuideMgr.guideStatus() > 0 then
		leaveBtn:setTouchEnabled(false)
		leaveBtn:setBright(false)
	end
	ChannelProxy.pause()
end

function LayerPauseGame.onExit()
	mLayerPauseGameRoot = UIManager.findLayerByTag("UI_PauseGame")
	if mLayerPauseGameRoot ~= nil then
		mLayerPauseGameRoot:removeFromParentAndCleanup(true)
		mLayerPauseGameRoot = nil
	end
end

