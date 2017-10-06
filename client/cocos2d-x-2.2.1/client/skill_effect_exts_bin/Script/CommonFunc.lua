----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-29
-- 描述：通用函数
----------------------------------------------------------------------

----------------------------------------------------------------------
-- 功  能：生成枚举类型
-- 参  数：tb(table类型) - 一维表{"aaaa", "bbbb", "cccc", ...}
-- 返回值：二维表{"aaaa"=1, "bbbb"=2, "cccc"=3, ...},枚举下标从1开始
function CommonFunc_enum(tb)
	local enum = {}
	for k, v in pairs(tb) do
		enum[v] = k
	end
	return enum
end


--TEST TABLE LOG 
function CommonFunc_TableLog(tb) 
	for key,value in pairs(tb) do
		for k2,v2 in pairs(value) do
			print("key:",k2,"value",v2)
		end
	end
	
end

----------------------------------------------------------------------
-- 功  能：备份一个table
-- 参  ori_tab(table)
-- 返回值：new_tab
function CommonFunc_table_copy_table(ori_tab)  
    if (type(ori_tab) ~= "table") then  
        return nil  
    end  
    local new_tab = {}  
    for i,v in pairs(ori_tab) do  
        local vtyp = type(v)  
        if (vtyp == "table") then  
            new_tab[i] = CommonFunc_table_copy_table(v)  
        elseif (vtyp == "thread") then  
            new_tab[i] = v  
        elseif (vtyp == "userdata") then  
            new_tab[i] = v  
        else  
            new_tab[i] = v  
        end  
    end  
    return new_tab  
end


----------------------------------------------------------------------
-- 功  能：获取指定概率
-- 参  数：probability(nubmer类型) - 取值范围1到100
-- 返回值：boolean
function CommonFunc_getProbability(probability)
	if probability < 1 or probability > 100 then
		print("CommonFunc -> getProbability -> probability["..getProbability.."] is out of range [1, 100].")
		return false
	end
	local res = math.random(1, 100)
	return res <= probability
end
----------------------------------------------------------------------
-- 功  能：获取随机元素
-- 参  数：arr(talble或string类型)
-- 返回值：随机数据
function CommonFunc_randomValue(arr)
	if nil == arr then
		print("CommonFunc -> randomValue -> arr is nil.")
		return nil
	end
	if "table" ~= type(arr) or "string" ~= type(arr) then
		print("CommonFunc -> randomValue -> arr is not table or string.")
		return nil
	end
	if 0 == #arr then
		print("CommonFunc -> randomValue -> arr is empty")
		return nil
	end
	local index = math.random(1, #arr)
	return arr[index]
end
----------------------------------------------------------------------
--分割字符串
function CommonFunc_split(str, separator)
	local findStartIndex = 1
	local splitIndex = 1
	local splitArray = {}
	while true do
	   local findLastIndex = string.find(str, separator, findStartIndex)
	   if not findLastIndex then
			splitArray[splitIndex] = string.sub(str, findStartIndex, string.len(str))
			break
	   end
	   splitArray[splitIndex] = string.sub(str, findStartIndex, findLastIndex - 1)
	   findStartIndex = findLastIndex + string.len(separator)
	   splitIndex = splitIndex + 1
	end
	return splitArray
end
----------------------------------------------------------------------
-- 功  能：将秒转化为 倒计时形式
-- 参  数: seconds(number类型)
-- 返回值：剩余倒计时
----------------------------------------------------------------------
function CommonFunc_secToString(seconds)
		local t = seconds;
		local remain;
		local days = t / (60 * 60 * 24);
		remain = t % (60 * 60 * 24);
		local hours = remain / (60 * 60);
		remain = remain % (60 * 60);
		local mins = remain / 60;
		remain = remain % 60;
		local rt =""
		if (days >= 1) then
			rt = string.format("%d天",days)
		end
		hours = math.floor(hours)
		mins = math.floor(mins)
		remain = math.floor(remain)
		
		rt = rt..string.format("%02d:%02d:%02d", hours, mins, remain)
		return rt
end
----------------------------------------------------------------------
-- 功  能：将table反过来排序
-- 参  数: tb(table)
-- 返回值：tb
----------------------------------------------------------------------
function CommonFunc_InvertedTable(tb)
	local	a = {}
		for key ,value in pairs(tb) do  
			a[#tb +1 - key] = value
		end
	return a
end


----------------------------------------------------------------------
-- 功  能：获得品质框
-- 参  数: index(int)
-- 返回值：strPath(string) 图片名
----------------------------------------------------------------------
function CommonFunc_GetQualityPath(index)
	local strPath = nil
	local strName = nil
	if index == quality_type["white"] then 
		strPath = "frame_white.png"
		strName = "普通"
	elseif index == quality_type["green"] then
		strPath = "frame_green.png"
		strName = "优秀"
	elseif index == quality_type["blue"] then
		strPath = "frame_bull.png"
		strName = "精良"
	elseif index == quality_type["purple"] then
		strPath = "frame_purple.png"
		strName = "史诗"
	elseif index == quality_type["orange"] then
		strPath = "frame_orange.png"
		strName = "传说"
	end
	
	return strPath,strName
end

----------------------------------------------------------------------
-- 功  能：加载品质框
-- 参  数: quality(int)
-- 返回值：
----------------------------------------------------------------------
function CommonFunc_AddQualityNode(node,quality)
	tolua.cast(node,"UIImageView")
	local path = CommonFunc_GetQualityPath(quality)
	
	local image = UIImageView:create()
	image:loadTexture(path)
	
	node:addChild(image)
end


----------------------------------------------------------------------
-- 功  能：统计表元素个数
-- 参  数: tablevalue(table)
-- 返回值：iCount(int) 图片名
----------------------------------------------------------------------
function CommonFunc_GetTableCount(tablevalue)   
	local iCount = 0
	if tablevalue == nil then 
		return 
	end
	
	for key,val in pairs(tablevalue) do 
		iCount = iCount + 1	
	end
	return iCount
end

----------------------------------------------------------------------
-- 功  能：获得职业名称
-- 参  数: roletype(int) 职业序号
-- 返回值：str(string) 图片名
----------------------------------------------------------------------
function CommonFunc_GetRoletypeString(roletype)
	local strRoleType = ""
	if roletype == 0 then 
		strRoleType = "通用"
	elseif roletype == 1 then
		strRoleType = "战士"
	elseif roletype == 2 then 
		strRoleType = "圣骑"
	elseif roletype == 3 then 
		strRoleType = "萨满"
	elseif roletype == 4 then 
		strRoleType = "法师"
	end

	return strRoleType
end

--物品个数统计
function CommonFunc_ItemStatistics(itemTable)
	local newTable = {}
	for key,val in pairs(itemTable) do
		print("itemTable ",key,val)
	end
	
	
	local newTable = {}
	for k,v in pairs(itemTable) do
	
		local bAdd = true
		for key,val in pairs(newTable) do
			if val.item_id == v.item_id then
				newTable[i].count = newTable[i].count + val.count
				bAdd = false
				break
			end
			
		end
		
		if bAdd == true then 
			table.insert(newTable,{item_id=v.item_id,count=v.count})
		end
		
	end
	
	return newTable
end

----------------------------------------------------------------------
-- 功  能：设置按钮控件是否显示 并且激活or关闭交互
-- 参  数: node(UIWidget)控件节点  bShow true显示 false隐藏
-- 返回值：
----------------------------------------------------------------------
function CommonFunc_SetWidgetTouch(node,bShow)
	if node == nil then
		print("CommonFunc_SetWidgetTouch()当前节点为空")
		return
	end
	
	node:setVisible(bShow)
	--node:setTouchEnabled(bShow)
	node:setEnabled(bShow)
	
	--遍历所有节点
	--[[
	local array = node:getChildren()
	if array == nil then
		return
	end
	--print("array:count()",array:count())
	if array:count() == 0 then
		return
	end
	
	for i=0,array:count()-1 do
		local nodeChild = tolua.cast(array:objectAtIndex(i),"UIWidget")
		CommonFunc_SetWidgetTouch(nodeChild,bShow)
	end
	]]
	--
end

----------------------------------------------------------------------
-- 功  能：快速创建对话框
-- 参  数: strText 显示文本信息
-- 返回值：
---------------------------------------------------------------------
function CommonFunc_CreateDialog(strText)
	local structConfirm = {strText = ""}
	structConfirm.strText = strText
	UIManager.push("UI_ComfirmDialog",structConfirm)
end

----------------------------------------------------------------------
-- 功  能：判断当前金币是否满足玩家购买行为，false不足弹出提示框
-- 参  数: gold 金币  emoney代币 friend友情点
-- 返回值：
---------------------------------------------------------------------
function CommonFunc_IsConsume(gold,emoney,friend)
	gold = gold or 0
	emoney = emoney or 0
	friend = friend or 0
	
	if ModelPlayer.gold < gold+0 then
		CommonFunc_CreateDialog("玩家金币不足")
		return false
	elseif ModelPlayer.emoney < emoney+0 then
		CommonFunc_CreateDialog("玩家代币不足")
		return false
	elseif ModelPlayer.friend_point < friend+0 then
		CommonFunc_CreateDialog("友情点不足")
		return false
	end
	
	return true
end

----------------------------------------------------------------------
-- 功  能：获得属性各项数值名 例如：攻击:10
-- 参  数: attr 属性
-- 返回值：
---------------------------------------------------------------------
function CommonFunc_getGemValueString(attr)
	local strGemAttrValue = {}
	
	if attr.atk ~= 0 then
		table.insert(strGemAttrValue,string.format("攻击:%d",attr.atk))
	end
	if attr.life ~= 0 then
		table.insert(strGemAttrValue,string.format("生命:%d",attr.life))
	end
	if attr.speed ~= 0 then
		table.insert(strGemAttrValue,string.format("速度:%d",attr.speed))
	end
	if attr.hit_ratio ~= 0 then
		table.insert(strGemAttrValue,string.format("命中:%d",attr.hit_ratio))
	end
	if attr.miss_ratio ~= 0 then
		table.insert(strGemAttrValue,string.format("闪避:%d",attr.miss_ratio))
	end
	if attr.tenacity ~= 0 then
		table.insert(strGemAttrValue,string.format("韧性:%d",attr.tenacity))
	end
	
	
	return strGemAttrValue
end

----------------------------------------------------------------------
-- 功  能：获取Label
-- 参  数: rootNode: 节点, name:label名, fntFile:BMF file, bIsAtlas:是否是UILabelAtlas
-- 返回值：Label
-- Created by fjut on 14-03-13
---------------------------------------------------------------------
function CommonFunc_getLabelByName(rootNode, name, fntFile, bIsAtlas)
	if rootNode == nil then
		cclog("getLabel fail, rootNode should not be nil !")
		return nil
	end
	
	if name == nil then
		cclog("getLabel fail, name should not be nil !")
		return nil
	end
	
	if type(name) ~= "string" then
		cclog("getLabel fail, name should be a type of string ! "..name)
		return nil
	end
	
	-- BMF
	if fntFile ~= nil then
		if type(fntFile) ~= "string" then
			cclog("getLabel fail, fntFile should be a type of string ! "..fntFile)
			return nil
		end
		local label = rootNode:getChildByName(name)
		if label == nil then
			cclog("getLabel fail, "..name.." don't exist on the rootNode !")
			return nil
		end
		tolua.cast(label, "UILabelBMFont")
		label:setFntFile(fntFile)
		return label
	end
	
	-- Atlas
	if bIsAtlas ~= nil then
		local label = rootNode:getChildByName(name)
		if label == nil then
			cclog("getLabel fail, "..name.." don't exist on the rootNode !")
			return nil
		end
		tolua.cast(label, "UILabelAtlas")
		return label
	end
	
	-- TTF
	local label = rootNode:getChildByName(name)
	if label == nil then
		cclog("getLabel fail, "..name.." don't exist on the rootNode !")
		return nil
	end
	tolua.cast(label, "UILabel")
	
	return label
end
	
----------------------------------------------------------------------
-- 功  能：获取UINode
-- 参  数: rootNode: 节点, name: node名, nodeType: node type
-- 返回值：UINode
-- Created by fjut on 14-03-13
---------------------------------------------------------------------
function CommonFunc_getNodeByName(rootNode, name, nodeType)
	if rootNode == nil then
		cclog("getNode fail, rootNode should not be nil !")
		return nil
	end
	
	if name == nil then
		cclog("getNode fail, name should not be nil !")
		return nil
	end
	
	if type(name) ~= "string" then
		cclog("getNode fail, name should be a type of string ! "..name)
		return nil
	end
	
	if nodeType == nil then
		local node = rootNode:getWidgetByName(name)
		return node
	end
	
	if type(nodeType) ~= "string" then
		cclog("getNode fail, nodeType should be a type of string ! "..nodeType)
		return nil
	end
	
	local node = rootNode:getChildByName(name)
	if node == nil then
		cclog("getNode fail, "..name.." don't exist on the rootNode !")
		return nil
	end
	tolua.cast(node, nodeType)
	
	return node
end

----------------------------------------------------------------------
-- 功  能：获取UIImageView
-- 参  数: imgName: 图片名, bIsPlist: 是否是打包图
-- 返回值：UIImageView
-- Created by fjut on 14-03-18
---------------------------------------------------------------------
function CommonFunc_getImgView(imgName, bIsPlist)
	if imgName == nil then
		cclog("getImgView fail, imgName should not be nil !")
		return nil
	end
	
	if type(imgName) ~= "string" then
		cclog("getImgView fail, imgName should be a type of string !")
		return nil
	end

	local uiImg = UIImageView:create()
	if bIsPlist == nil then
		uiImg:loadTexture(imgName)
	else
		uiImg:loadTexture(imgName, UI_TEX_TYPE_PLIST)
	end
	
	return uiImg
end

----------------------------------------------------------------------
-- 功  能：获取UILabel
-- 参  数: strValue: string, 
-- 返回值：UILabel
-- Created by fjut on 14-03-19
---------------------------------------------------------------------
function CommonFunc_getLabel(strValue, fontSize, fontColor, fontName)
	if strValue == nil then
		cclog("getLabel fail, strValue should not be nil !")
		return nil
	end
	
	if type(strValue) ~= "string" then
		cclog("getLabel fail, strValue should be a type of string !")
		return nil
	end
	
	-- UILabel
	local defaultLabel = 
	{
		["fontSize"] = 25,
		["fontColor"] = ccc3(255, 255, 255),
		["fontName"] = "Arial",
	}
	
	-- fontSize
	if fontSize == nil then
		fontSize = defaultLabel["fontSize"]
	end
	
	-- fontColor
	if fontColor == nil then
		fontColor = defaultLabel["fontColor"]
	end
	
	-- fontName
	if fontName == nil then
		fontName = defaultLabel["fontName"]
	end
	
	-- UIlabel
	local label = UILabel:create() 
	label:setText(strValue)
	label:setFontSize(fontSize)
	label:setColor(fontColor)
	label:setFontName(fontName)
	
	return label
end

----------------------------------------------------------------------
-- 功  能：获取UILabelAtlas
-- 参  数: strValue: string
-- 返回值：UILabelAtlas
-- Created by fjut on 14-03-19
---------------------------------------------------------------------
function CommonFunc_getAtlas(strValue, charMapFile, itemWidth, itemHeight, startCharMap, bIsUseSpriteFrame)
	if strValue == nil then
		cclog("getAtlas fail, strValue should not be nil !")
		return nil
	end
	
	if type(strValue) ~= "string" then
		cclog("getAtlas fail, strValue should be a type of string !")
		return nil
	end
	
	-- UILabelAtlas
	local defaultAltas = 
	{
		["file"] = "labelatlasimg.png",
		["width"] = 24,
		["height"] = 32,
		["startChar"] = "0",
		["useSpriteFrame"] = false
	}
	
	local label = UILabelAtlas:create()
	if charMapFile == nil then
		label:setProperty(strValue, defaultAltas["file"], defaultAltas["width"], defaultAltas["height"], defaultAltas["startChar"], defaultAltas["useSpriteFrame"]);
	else
		label:setProperty(strValue, charMapFile, itemWidth, itemHeight, startCharMap, useSpriteFrame);
	end
	
	return label
end

----------------------------------------------------------------------
-- 功  能：获取CCSprite
-- 参  数: imgName: 图片名, plistName: plist名
-- 返回值：CCSprite Node
-- Created by fjut on 14-03-18
---------------------------------------------------------------------
function CommonFunc_getSprite(imgName, plistName)
	if imgName == nil then
		cclog("getSprite fail, imgName should not be nil !")
		return nil
	end
	
	if type(imgName) ~= "string" then
		cclog("getSprite fail, imgName should be a type of string !")
		return nil
	end
	
	if plistName == nil then
		return CCSprite:create(imgName)
	end

	local sp = nil
	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	local spFrame = frameCache:spriteFrameByName(imgName)
	if spFrame == nil then
		frameCache:addSpriteFramesWithFile(plistName)
		spFrame = frameCache:spriteFrameByName(imgName)
	end
	if spFrame ~= nil then
		sp = CCSprite:createWithSpriteFrame(spFrame)
	end

	return sp
end

----------------------------------------------------------------------
-- 功  能：填充UIScrollView
-- 参  数: rootNode: 节点, ScrollViewName：scrollview控件名, tbCellInfo: UIWidget table, sliderName:slider控件名 
-- 返回值：UIScrollView
-- Created by fjut on 14-03-18
---------------------------------------------------------------------
function CommonFunc_getScrollView(rootNode, ScrollViewName, tbCellInfo, cellOffsetPosX, sliderName)
	if rootNode == nil then
		cclog("getScrollView fail, rootNode should not be nil !")
		return nil
	end
	
	if tbCellInfo == nil or #tbCellInfo == 0 then
		cclog("getScrollView fail, tbCellInfo should not be nil ! ")
		return nil
	end
	
	-- scrollview
	local scrollView = rootNode:getChildByName(ScrollViewName)
	if scrollView == nil then
		cclog("getScrollView fail, "..ScrollViewName.." don't exist on the rootNode !")
		return nil
	end
	tolua.cast(scrollView, "UIScrollView")
	scrollView:removeAllChildren()
	scrollView:setDirection(SCROLLVIEW_DIR_VERTICAL)
	scrollView:setBounceEnabled(false) -- should be false
	local totalH = (#tbCellInfo)*tbCellInfo[1]:getContentSize().height
	scrollView:setInnerContainerSize(CCSize(scrollView:getSize().width, totalH))
	--cclog("scrollView高："..scrollView:getSize().height.."scrollView in高："..scrollView:getInnerContainerSize().height)
	-- 
	cellOffsetPosX = (cellOffsetPosX == nil) and 30 or cellOffsetPosX
	
	for k, value in next, (tbCellInfo) do
		local node = tbCellInfo[k]
		node:setAnchorPoint(ccp(0, 0.5))
		scrollView:setInnerContainerSize(CCSize(scrollView:getSize().width, (#tbCellInfo)*tbCellInfo[1]:getContentSize().height))
		local h = tbCellInfo[1]:getContentSize().height*0.5 + tbCellInfo[1]:getContentSize().height*(k-1)
		tbCellInfo[k]:setPosition(ccp(cellOffsetPosX, h))
		scrollView:addChild(node)
	end
	
	if (sliderName == nil) then
		return scrollView
	end
	
	-- slider
	local slider = rootNode:getChildByName(sliderName)
	if slider == nil then
		cclog("getSlider fail, "..sliderName.." don't exist on the rootNode !")
		return scrollView
	end
	tolua.cast(slider, "UISlider")
	slider:setPercent(0)
	scrollView:registerEventScript(function(typename, widget) 
						local scrollViewInnerCon = scrollView:getInnerContainer()
						local InnerHei = scrollViewInnerCon:getSize().height
						local InnerPosY = scrollViewInnerCon:getPosition().y
						local scrollHei = scrollView:getSize().height
						local scrollPosY = scrollView:getPosition().y
						if "scrolling" == typename then
							--cclog("scrolling")
							local per = math.abs(InnerPosY)/(InnerHei-scrollHei)*100
							slider:setPercent(100 - per)
						end
					end)
	
	return scrollView
end

----------------------------------------------------------------------
-- 功  能：创建CocoStudio文本控件
-- 参  数：anchorPoint-锚点,position-位置,fontName-字体名字,fontSize-字体大小,color-字体颜色,text-文本,tag-标签,zOrder-渲染层级
-- 返回值：UILabel
-- Created by jaron.ho on 2014-03-17 11:30
----------------------------------------------------------------------
function CommonFunc_createUILabel(anchorPoint, position, fontName, fontSize, color, text, tag, zOrder)
	local label = UILabel:create()
	if nil ~= anchorPoint then
		label:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		label:setPosition(position)
	end
	if nil ~= fontName and "" ~= fontName then
		label:setFontName(fontName)
	end
	if nil ~= fontSize and fontSize > 0 then
		label:setFontSize(fontSize)
	end
	if nil ~= color then
		label:setColor(color)
	end
	if nil ~= text then
		label:setText(text)
	end
	if nil ~= tag then
		label:setTag(tag)
	end
	if nil ~= zOrder then
		label:setZOrder(zOrder)
	end
	return label
end

----------------------------------------------------------------------
-- 功  能：创建CCLabelTTF
-- 参  数：anchorPoint-锚点,position-位置,fontName-字体名字,fontSize-字体大小,color-字体颜色,text-文本,tag-标签,zOrder-渲染层级
-- 返回值：CCLabelTTF
-- Created by jaron.ho on 2014-03-17 11:30
----------------------------------------------------------------------
function CommonFunc_createCCLabelTTF(anchorPoint, position, fontName, fontSize, color, text, tag, zOrder)
	local label = CCLabelTTF:new()
	label:init()
	label:autorelease()
	if nil ~= anchorPoint then
		label:setAnchorPoint(anchorPoint)
	end
	if nil ~= position then
		label:setPosition(position)
	end
	if nil ~= fontName and "" ~= fontName then
		label:setFontName(fontName)
	end
	if nil ~= fontSize and fontSize > 0 then
		label:setFontSize(fontSize)
	end
	if nil ~= color then
		label:setColor(color)
	end
	if nil ~= text then
		label:setString(text)
	end
	if nil ~= tag then
		label:setTag(tag)
	end
	if nil ~= zOrder then
		label:setZOrder(zOrder)
	end
	return label
end
----------------------------------------------------------------------


