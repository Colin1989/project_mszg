----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-2
-- 描述：资源管理
----------------------------------------------------------------------
ResourceManger = {}

local mMonsterResCache = {}		--怪物资源缓存（包括技能）


----------------------------------------------------------------------
local mAniFrame = XmlTable_load("animationframe_tplt.xml", "id")
ResourceManger.getAnimationFrameById= function(id)
	local res = XmlTable_getRow(mAniFrame, id, true)
	local row = {}
	-- 定义奖励信息结构体
	row.id = res.id
	row.name = res.name
	row.wait = res.wait
	row.wait_frame = res.wait_frame + 0
	row.attack = res.attack
	row.attack_frame = res.attack_frame + 0
	row.hited = res.hited
	row.hited_frame = res.hited_frame + 0
	row.skill = res.skill
	row.skill_frame = res.skill_frame + 0	
	row.dead = res.died
	row.dead_frame = res.died_frame + 0
	row.sound_enter = res.sound_enter + 0
	row.sound_hurt = res.sound_hurt + 0
	row.sound_die = res.sound_die + 0
	return row
end

ResourceManger.removeUnused = function()
	--CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	--CCTextureCache:sharedTextureCache():removeUnusedTextures()
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile
end

ResourceManger.getAllRes = function()
	local row = {}
	for k, v in pairs(mAniFrame.data) do
		table.insert(row, v)
	end
	table.sort(tb, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
	return row
end

ResourceManger.LoadSinglePicture = function(file)
	local ImageCache = CCSpriteFrameCache:sharedSpriteFrameCache();
	--local str = CCFileUtils:sharedFileUtils():fullPathForFilename(file..".plist")
	local str = file..".plist"
	ImageCache:addSpriteFramesWithFile(str) 
end


local isLoading = false
function ResourceManger.isLoadPubPic()
	return isLoading
end


-- 功  能：加载资源  
----------------------------------------------------------------------
function LoadPublicResouse()
	isLoading = true
	local index = 0
	local publicRes = 
	{
			"monster_death2.png",
	}
	local TextureCache = CCTextureCache:sharedTextureCache()
	local function loadResCall(filePath,texture2d)
		local str = string.gsub(filePath,".png",".plist")
		--str = CCFileUtils:sharedFileUtils():fullPathForFilename(str)
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(str)
		index = index + 1
		cclog("Load"..str.."Success!"..index,"size",#publicRes)
		if index == #publicRes then
			isLoading = false
		end 
	end
	
	local function beforTextureInitHandle(filePath)
		CCTexture2D:setDefaultAlphaPixelFormat(7)
		print("++++++++++++++++++beforTextureInitHandle", filePath)
	end

	for k,PngPicName in pairs(publicRes) do
		TextureCache:addImageAsyncInScript(PngPicName,loadResCall, beforTextureInitHandle)
	end
end

--释放SpriteFrame
function ResourceManger.releasePlist(res)
	local function checkPlistName(_res)
		local flag = string.find(_res,".plist")
			if  flag == nil then
				_res = _res..".plist"
			end
		return _res
	end 

	local spriteCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	if type(res) == "string" then 
		res = checkPlistName(res)
		--res = CCFileUtils:sharedFileUtils():fullPathForFilename(res)
		cclog("Reomve SpriteFrameFromPlistFile:",res)
		spriteCache:removeSpriteFramesFromFile(res)
	elseif type(res) == "table" then 
		for key,value in pairs(res) do
			local plistFile = checkPlistName(value)
			--plistFile = CCFileUtils:sharedFileUtils():fullPathForFilename(plistFile)
			cclog("Reomve SpriteFrameFromPlistFile:",plistFile)
			spriteCache:removeSpriteFramesFromFile(plistFile)
		end	
	end 
	--CCTextureCache:sharedTextureCache():removeUnusedTextures()
end 


-- 释放上一个场景的 怪物 背景 技能 的资源
function ResourceManger.releaseLastSceneRes()
	local TextureCache = CCTextureCache:sharedTextureCache()
	local SpriteFrameCache =CCSpriteFrameCache:sharedSpriteFrameCache()
	--[[
	local function removeRes(RemoveTb,isAnimation)
		for key,value in pairs(RemoveTb) do 
			cclog("Delete_Res_ImageCache!!!",value)
			TextureCache:removeTextureForKey(value)			--release textureCaChe

			if isAnimation == true then 
				local str = string.gsub(value,".png",".plist")
				cclog("Delete_Res_SpiteCache!!!",str)
				SpriteFrameCache:removeSpriteFramesFromFile(str)
			end
		end
	end
	--release monster
	removeRes(mMonsterResCache,true)
	mMonsterResCache = {}	--怪物资源缓存（包括技能）
	]]--
	--relsease scene
	removeRes(mSceneResCaChe,false)
end
