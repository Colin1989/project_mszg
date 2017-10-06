----- 游戏背景层 这个只做背景 不做事件处理------

local m_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local m_origin = CCDirector:sharedDirector():getVisibleOrigin()

--资源表 先模拟4个关卡
local _ResTable ={
 {background = "map001_top.png" ,leftres = "map001_left.png" ,rightres = "map001_right.png",tmxMap = "map001.tmx"},--需要的资源再添加
 {background = "HelloWorld1.png",tmxMap = "gamebackground1.tmx"},
 {background = "HelloWorld2.png",tmxMap = "gamebackground2.tmx"},
 {background = "HelloWorld3.png",tmxMap = "gamebackground3.tmx"} 
}

---  背包转到各种 类型 的中转表（通过物品id，获得物品信息）
local findCopyResDetailById = function(id)
	local _date = XmlTable_load("copy_bg_res_tplt.xml")
	local res = XmlTable_getRow(_date, "id", id)
	local row = {}
	-- 定义奖励信息结构体
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "ground" == v.name then
			row.ground = v.value	
		elseif "grid" == v.name then
			row.grid = v.value
		elseif "top" == v.name then
			row.top = v.value
		elseif "left1" == v.name then
			row.left1 = v.value
		elseif "left2" == v.name then
			row.left2 = v.value
		elseif "right1" == v.name then
			row.right1 = v.value
		elseif "right2" == v.name then
			row.right2 = v.value
		elseif "rate" == v.name then
			row.rate = XmlTable_stringSplit(v.value,",")
		end
	end
	return row
end




-- 创建游戏背景层
-- index 根据关卡类型动态加载资源  要求 type:number
-- SL  FIXME
local function CreatelayerDetails(bg_res_id)
	local resTb = findCopyResDetailById(bg_res_id)
	cclog("bg_res_idbg_res_idbg_res_idbg_res_idbg_res_idbg_res_idbg_res_idbg_res_id--------------->",bg_res_id)
	
	--ResourceManger.releaseScene()	--释放资源纹理
	
	local layer = CCLayer:create()

	local bgstr = "copyres/"..resTb.top
	local bg = CCSprite:create(bgstr)
	bg:setPosition(ccp(0,m_visibleSize.height - bg:boundingBox().size.height))
	bg:setAnchorPoint(ccp(0,0))
	layer:addChild(bg)
	--ResourceManger.addSceneCache(bgstr)

	local tmxmapbgStr = "copyres/"..resTb.ground
	local tmxmapbg = CCTMXTiledMap:create(tmxmapbgStr);
	tmxmapbg:setPosition(ccp(m_visibleSize.width/2,	m_visibleSize.height - bg:boundingBox().size.height));
	tmxmapbg:setAnchorPoint(ccp(0.5,1));
	layer:addChild(tmxmapbg);
	--ResourceManger.addSceneCache(tmxmapbgStr)
	
	local bgleftstr = "copyres/"..resTb.left1
	local bgleft = CCSprite:create(bgleftstr)
	bgleft:setPosition(ccp(0,m_visibleSize.height - bg:boundingBox().size.height))
	bgleft:setAnchorPoint(ccp(0,1))
	g_sceneRoot:addChild(bgleft,g_Const_GameLayer.sceneChildLayer.sprite)
	--ResourceManger.addSceneCache(bgleftstr)
	
	if resTb.left2 ~= "0" then 
		local bgleft2str = "copyres/"..resTb.left2
		local bgleft2 = CCSprite:create("copyres/"..resTb.left2)
		bgleft2:setPosition(ccp(0,m_visibleSize.height - bg:boundingBox().size.height))
		bgleft2:setAnchorPoint(ccp(0,1))
		g_sceneRoot:addChild(bgleft2,g_Const_GameLayer.sceneChildLayer.esp)
		
		--ResourceManger.addSceneCache(bgleft2str)
	end

	local bgrightstr = "copyres/"..resTb.right1
	local bgright = CCSprite:create(bgrightstr)
	bgright:setPosition(ccp(m_visibleSize.width,m_visibleSize.height - bg:boundingBox().size.height))
	bgright:setAnchorPoint(ccp(1,1))
	g_sceneRoot:addChild(bgright,g_Const_GameLayer.sceneChildLayer.sprite)
	ResourceManger.addSceneCache(bgrightstr)
	
	if resTb.right2 ~= "0" then 
		local bgright2str = "copyres/"..resTb.right2
		local bgright2 = CCSprite:create(bgright2str)
		bgright2:setPosition(ccp(m_visibleSize.width,m_visibleSize.height - bg:boundingBox().size.height))
		bgright2:setAnchorPoint(ccp(1,1))
		g_sceneRoot:addChild(bgright2,g_Const_GameLayer.sceneChildLayer.esp)
		
		--ResourceManger.addSceneCache(bgright2str)
	end
		
	return layer
end

-- 从不定长的概率表
local  function getRandomGirdIndex(_random_Num,rateTb) 
	local rate = 0
	for k,v in pairs(rateTb) do
		rate = rate + tonumber(v) 
		if _random_Num <= rate then 
			return k
		end
	end
end	

-- 初始化随机的精灵格子
function initRandomGridSprite(GildEvent,x,y,resId)
	local resTb = findCopyResDetailById(resId)
		
	local GridBatchNode = CCSpriteBatchNode:create("copyres/"..resTb.grid,30)	   --动态格子层 
	GridBatchNode:setPosition(0,0)
	for i = 0,5 do
		for j = 0,4 do
				local pos = (5 - i)*5 +j+1
				if GildEvent[pos].staus == g_Const_Sprite.Type.gird then
					local r = math.random(1,100)
					
					local index = getRandomGirdIndex(r,resTb.rate) 				--print("getRandomGirdIndex----------------------------->",index)
					
					local girdCell = CCSprite:createWithTexture( GridBatchNode:getTexture(),CCRectMake(0+CELLSIZE_WIDTH*(index - 1),0,CELLSIZE_WIDTH,172))
					girdCell:setPosition(x+CELLSIZE_WIDTH*j,	y+CELLSIZE_HEIGHT*i );
					girdCell:setAnchorPoint(ccp(0,0))
					girdCell:setTag(pos)
					GridBatchNode:addChild(girdCell,pos)
				end
		end
	end
	return GridBatchNode
end


function Create_GameBackGroundLayer(index)
	g_sceneRoot:addChild(CreatelayerDetails(index))
end

