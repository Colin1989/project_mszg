--/**
-- *  @Brief: 游戏音乐、音效控制
-- *  @Created by fjut on 14-03-25
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

Audio = {}

local instance_ = nil
-- 当前正在播放的背景音乐tag
local m_playingBgMscTag = nil
-- 音乐数据
local m_tbMusicFile = LogicTable.getAudioFileTbByType(1)
-- 音效数据
local m_tbEffectFile = LogicTable.getAudioFileTbByType(2)
-- CCNotificationCenter param
local tbNotificationCenterParam =
{
	MSG_BTN = "BtnCall"
}
-- 开关状态
local tbSwitchValue = 
{
	-- 不可变(*固定为0*)
	["default"] = 0, 
	["open"] 	= 1,
	["close"] 	= 2
}

-- 获取音频文件名
-- audioTag: file name tag, shoud be number
-- bIsMp3: hold data
local function getAudioFileNameByTag(audioTag, bIsMp3)
	if audioTag == nil and type(audioTag) ~= "number" then
		cclog("getAudioFileNameByTag fail, param is bad !")
		return
	end
	
	local fileName = LogicTable.getAudioFileNameById(audioTag)
	-- todo
	-- ...
	
	return fileName
end

-- 获取配置信息
local function getAudioCfg()
	-- 声音
	local bSound = CCUserDefault:sharedUserDefault():getIntegerForKey("AudioSound")
	if bSound == tbSwitchValue["default"] then
		CCUserDefault:sharedUserDefault():setIntegerForKey("AudioSound", tbSwitchValue["open"])
		CCUserDefault:sharedUserDefault():flush()
		bSound = tbSwitchValue["open"]
		cclog("AudioSound init")
	end
	-- 音效
	local bEffect = CCUserDefault:sharedUserDefault():getIntegerForKey("AudioEffect")
	if bEffect == tbSwitchValue["default"] then
		CCUserDefault:sharedUserDefault():setIntegerForKey("AudioEffect", tbSwitchValue["open"])
		CCUserDefault:sharedUserDefault():flush()
		bEffect = tbSwitchValue["open"]
		cclog("AudioEffect init")
	end

	bSound = (bSound == tbSwitchValue["open"]) and true or false
	bEffect = (bEffect == tbSwitchValue["open"]) and true or false
	local tb = 
	{
		["music"] = bSound,
		["effect"] = bEffect
	}
	
	return tb
end

-- 获取声音配置
-- return: boolean
Audio.getMscIsOpen = function()
	local tbCfg = getAudioCfg()
	return tbCfg["music"]
end

-- 获取音效配置
-- return: boolean
Audio.getEffectIsOpen = function()
	local tbCfg = getAudioCfg()
	return tbCfg["effect"]
end

-- 修改配置信息(声音)
-- bOpen: boolean
Audio.setAudioCfgWithSound = function(bOpen)
	if bOpen == nil or type(bOpen) ~= "boolean" then
		cclog("setAudioCfgWithSound fail, param is bad !")
		return
	end
	
	local tbCfg = getAudioCfg()
	if tbCfg["music"] ~= bOpen then
		local soundVal = bOpen and tbSwitchValue["open"] or tbSwitchValue["close"]
		CCUserDefault:sharedUserDefault():setIntegerForKey("AudioSound", soundVal)
		CCUserDefault:sharedUserDefault():flush()
		-- go on playing
		if bOpen then
			Audio.playBgMscByTag(3)
		else
			Audio.pauseBgMsc()
		end
	end
end

-- 修改配置信息(音效)
-- bOpen: boolean
Audio.setAudioCfgWithEffect = function(bOpen)
	if bOpen == nil or type(bOpen) ~= "boolean" then
		cclog("setAudioCfgWithEffect fail, param is bad !")
		return
	end
	
	local tbCfg = getAudioCfg()
	if tbCfg["effect"] ~= bOpen then
		local soundVal = bOpen and tbSwitchValue["open"] or tbSwitchValue["close"]
		CCUserDefault:sharedUserDefault():setIntegerForKey("AudioEffect", soundVal)
		CCUserDefault:sharedUserDefault():flush()
	end
end

-- 程序后台返回, 播放背景音乐
Audio.playBgMscFromBackground = function()
	Audio.playBgMscByTag(m_playingBgMscTag)
end

-- 播放背景音乐
-- bgMscTag: file name tag, shoud be number
Audio.playBgMscByTag = function(bgMscTag)
	if bgMscTag == nil and type(bgMscTag) ~= "number" then
		cclog("play bg music fail, param is bad !")
		return
	end
	
	-- 音乐关闭状态
	local tbCfg = getAudioCfg()
	if not tbCfg["music"] then
		cclog("play bg music fail, status is closed !")
	--	m_playingBgMscTag = bgMscTag
		return
	end
	
	-- 首次播放音乐(*音乐必须循环播放*)
	if m_playingBgMscTag == nil then
		SimpleAudioEngine:sharedEngine():playBackgroundMusic(getAudioFileNameByTag(bgMscTag), true);
		m_playingBgMscTag = bgMscTag
		return
	end
	
	-- 已经在播放(pause or playing)(*音乐必须循环播放*)
	if m_playingBgMscTag == bgMscTag and SimpleAudioEngine:sharedEngine():isBackgroundMusicPlaying() then
		Audio.resumeBgMsc()
		return
	end
	
	SimpleAudioEngine:sharedEngine():playBackgroundMusic(getAudioFileNameByTag(bgMscTag), true);
	m_playingBgMscTag = bgMscTag
end

-- 播放音效
-- effectTag: file name tag, shoud be number
Audio.playEffectByTag = function(effectTag)
	if effectTag == nil and type(effectTag) ~= "number" then
		cclog("play effect fail, param is bad !")
		return
	end
	
	-- 音效关闭状态
	local tbCfg = getAudioCfg()
	if not tbCfg["effect"] then
		--cclog("play effect fail, status is closed !")
		return
	end
	
	SimpleAudioEngine:sharedEngine():playEffect(getAudioFileNameByTag(effectTag, false));
end

-- 暂停音乐
Audio.pauseBgMsc = function()
	SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
end

-- 恢复音乐
Audio.resumeBgMsc = function()
	SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
end

-- 按钮call
local function btnCall()
	cclog("CCNotificationCenter btn call !"..getAudioFileNameByTag("effect1", false))
	--Audio.playEffectByTag(tbEffectTag.EFFECT_01) 
end

-- 按钮notify
Audio.EffectNotify = function()
	CCNotificationCenter:sharedNotificationCenter():postNotification(tbNotificationCenterParam.MSG_BTN)
end

-- 预加载音乐
local function loadingMusic()
	for k, value in next, (m_tbMusicFile) do
		SimpleAudioEngine:sharedEngine():preloadBackgroundMusic(value.name)
	end
end

-- 初始化
local function instance()
	if instance_ == nil then
		instance_ = true
		-- 音量
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0.5)
		SimpleAudioEngine:sharedEngine():setEffectsVolume(0.5)
		-- 按钮
		CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, btnCall, tbNotificationCenterParam.MSG_BTN)
		--预加载音乐
		loadingMusic()
	end
	
	return instance_
end

-- 反初始化
local function freeInstance()
	if instance_ ~= nil then
		CCUserDefault:sharedUserDefault():setIntegerForKey("AudioSound", tbSwitchValue["close"])
		CCUserDefault:sharedUserDefault():setIntegerForKey("AudioEffect", tbSwitchValue["close"])
		CCUserDefault:sharedUserDefault():flush()   
		CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(nil, tbNotificationCenterParam.MSG_BTN)
		SimpleAudioEngine:sharedEngine():stopAllEffects()
		SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
		-- SimpleAudioEngine:sharedEngine():end() -- bad !
	end
	m_playingBgMscTag = nil
	instance_ = nil
end

-- init invoke 
instance()

--预加载战斗中音效
function Audio.preloadEffectByTag(effectTag)
	local fileName = getAudioFileNameByTag(effectTag, false)
	SimpleAudioEngine:sharedEngine():preloadEffect(fileName)
	cclog("preload sound effect", fileName)
end

--清除战斗中音效
function Audio.unloadEffectByTag(effectTag)
	local fileName = getAudioFileNameByTag(effectTag, false)
	SimpleAudioEngine:sharedEngine():unloadEffect(fileName)
	cclog("unload sound effect", fileName)
end















