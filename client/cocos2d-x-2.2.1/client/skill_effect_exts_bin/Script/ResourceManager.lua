----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-2
-- 描述：资源管理
----------------------------------------------------------------------
ResourceManger = {}
----------------------------------------------------------------------




local mAniFrame = XmlTable_load("animationframe_tplt.xml")
ResourceManger.getAnimationFrameById= function(id)
	local res = XmlTable_getRow(mAniFrame, "id", id)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "name" == v.name then
			row.name = v.value

		elseif "wait" == v.name then
			row.wait = v.value
		elseif "wait_frame" == v.name then
			row.wait_frame = v.value + 0
			
		elseif "attack" == v.name then
			row.attack = v.value 
		elseif "attack_frame" == v.name then
			row.attack_frame = v.value + 0
			
		elseif "hited" == v.name then
			row.hited = v.value	
		elseif "hited_frame" == v.name then
			row.hited_frame = v.value + 0
			
		elseif "skill" == v.name then
			row.skill = v.value
		elseif "skill_frame" == v.name then
			row.skill_frame = v.value + 0
			
		elseif "died" == v.name then
			row.skill = v.value
		elseif "died_frame" == v.name then
			row.skill_frame = v.value + 0
		end
	end
	return row
end

ResourceManger.getAllRes = function()
	local row = {}
	for k , v in pairs(mAniFrame) do
		local cell = {}
		for name, value in pairs(v) do
			if "name" == value.name then
				cell.name = value.value
			end
		end
		table.insert(row, cell)
	end
	return row
end

ResourceManger.LoadSinglePicture = function(file)
	local ImageCache = CCSpriteFrameCache:sharedSpriteFrameCache();
	ImageCache:addSpriteFramesWithFile("Picture/monster/"..file..".plist") 
end

-- 功  能：加载资源  
-- 参  数：status 游戏主状态  type:number
----------------------------------------------------------------------
function LoadResouse(status)	
	local ImageCache = CCSpriteFrameCache:sharedSpriteFrameCache();
	--local TextureCache = CCTextureCache:sharedTextureCache()
	
	ImageCache:addSpriteFramesWithFile("effect.plist");
	ImageCache:addSpriteFramesWithFile("effect_000.plist");
	ImageCache:addSpriteFramesWithFile("monster_death.plist");
	
	
	--local function loadResCall(filePath,texture2d)
		--cclog(p1,type(p1),"texture",p2:getName())
	--end
	for k,v in pairs(ResourceManger.getAllRes()) do 
		--TextureCache:addImageAsyncInScript("monster/"..v.name..".png",loadResCall)
		ImageCache:addSpriteFramesWithFile("monster/"..v.name..".plist")  --加载怪物资源
	end
	ImageCache:addSpriteFramesWithFile("monsterArr.plist");
	
end
----------------------------------------------------------------------
-- 功  能：释放资源  
-- 参  数：status 游戏主状态  type:number
----------------------------------------------------------------------

local mMonsterResCache = {}		--怪物资源缓存
local mSceneResCaChe = {}		--场景资源缓存


function ResourceManger.addSceneCache(picture)
	table.insert(mSceneResCaChe,picture)
end


-- monsterId 怪物ID
function ResourceManger.addMonsterCache(monsterId)
	local monster =  ModelMonster.getMonsterById(monsterId)					--怪物查询
	local animation = ResourceManger.getAnimationFrameById(monster.icon)	--动画查询	
	local mon_pic = "monster/"..animation.name..".plist"
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(mon_pic)
	table.insert(mMonsterResCache,mon_pic)
end


function ResourceManger.releaseAllRes()
	local TextureCache = CCTextureCache:sharedTextureCache()
	local function removeRes(RemoveTb)
		for key,value in pairs(mSceneResCaChe) do 
			cclog("Delete ImageCache",value)
			TextureCache:removeTextureForKey(value)
		end
	end
	

	
	mSceneResCaChe = {}
end

function releaseAllResouse()
	
end