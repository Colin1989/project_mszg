----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-11-14
-- Brief:	设置界面
----------------------------------------------------------------------
LayerSetup = {}
local mIsMusicOn = true				-- 音乐是否开启
local mIsEffectOn = true			-- 音效是否开启

----------------------------------------------------------------------
-- 联系客服
local function clickContactButton(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_Setup")
		UIManager.push("UI_Contact")
	end
end
----------------------------------------------------------------------
-- 切换账号
local function switchAccount()
	local function callback()
		NetHelper.close()
		UIManager.destroyAllUI()
		UIManager.begin(false)
	end
	local diaMsg = 
	{
		strText = string.format(GameString.get("Setup_CHANGE_ACCOUNT_TIPS")),
		buttonCount = 2,
		buttonName = {GameString.get("sure"), GameString.get("cancle")},
		buttonEvent = {callback, nil}
	}
	UIManager.push("UI_ComfirmDialog", diaMsg)
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseButton(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_Setup")
	end
end
----------------------------------------------------------------------
-- 点击切换按钮
local function clickSwitchButton(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_Setup")
		if true == ChannelProxy.isOwnLogin() then
			switchAccount()
		else
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function()
					ChannelProxy.switchAccount()
			end)))
			
		end
	end
end
----------------------------------------------------------------------
-- 点击音乐复选框
local function clickMusicCheckBox(typeName, widget)
	if "releaseUp" == typeName then
		mIsMusicOn = not mIsMusicOn
		widget:setBright(mIsMusicOn)
		Audio.setAudioCfgWithSound(mIsMusicOn)
	end
end
----------------------------------------------------------------------
-- 点击音效复选框
local function clickEffectCheckBox(typeName, widget)
	if "releaseUp" == typeName then
		mIsEffectOn = not mIsEffectOn
		widget:setBright(mIsEffectOn)
		Audio.setAudioCfgWithEffect(mIsEffectOn)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerSetup.init = function(bundle)
	local root = UIManager.findLayerByTag("UI_Setup")
	local framePanel = tolua.cast(root:getWidgetByName("frame"), "UILayout")
	-- 关闭按钮
	local closeButton = tolua.cast(framePanel:getChildByName("Button_close"), "UIButton")
	closeButton:registerEventScript(clickCloseButton)
	-- 切换按钮
	local switchButton = tolua.cast(framePanel:getChildByName("Button_switch"), "UIButton")
	switchButton:registerEventScript(clickSwitchButton)
	-- 联系客服
	local contactButton = tolua.cast(framePanel:getChildByName("Button_contact"), "UIButton")
    Lewis:spriteShaderEffect(contactButton:getVirtualRenderer(),"buff_gray.fsh",true)
	--contactButton:registerEventScript(clickContactButton) 先屏蔽
	-- 音乐复选框
	mIsMusicOn = Audio.getMscIsOpen()
	local musicCheckBox = tolua.cast(framePanel:getChildByName("CheckBox_music"), "UICheckBox")
	musicCheckBox:registerEventScript(clickMusicCheckBox)
	musicCheckBox:setBright(mIsMusicOn)
	-- 音效复选框
	mIsEffectOn = Audio.getEffectIsOpen()
	local effectCheckBox = tolua.cast(framePanel:getChildByName("CheckBox_effect"), "UICheckBox")
	effectCheckBox:registerEventScript(clickEffectCheckBox)
	effectCheckBox:setBright(mIsEffectOn)
end
----------------------------------------------------------------------
-- 销毁
LayerSetup.destroy = function()
end
----------------------------------------------------------------------




