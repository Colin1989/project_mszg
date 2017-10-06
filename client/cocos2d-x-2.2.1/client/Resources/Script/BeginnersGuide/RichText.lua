----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：新手引导视图
----------------------------------------------------------------------
RichText = {}

local function getWord(strTB)
	local word = nil
	local c = string.sub(strTB.str, strTB.idx, strTB.idx)
	local b = string.byte(c)
	if b > 252 then			-- 6字节
		word = string.sub(strTB.str, strTB.idx, strTB.idx + 5)
		strTB.idx = strTB.idx + 6
	elseif b >= 248 then	-- 5字节
		word = string.sub(strTB.str, strTB.idx, strTB.idx + 4)
		strTB.idx = strTB.idx + 5
	elseif b >= 240 then	-- 4字节
		word = string.sub(strTB.str, strTB.idx, strTB.idx + 3)
		strTB.idx = strTB.idx + 4
	elseif b >= 224 then	-- 3字节
		word = string.sub(strTB.str, strTB.idx, strTB.idx + 2)
		strTB.idx = strTB.idx + 3
	elseif b >= 192 then	-- 2字节
		word = string.sub(strTB.str, strTB.idx, strTB.idx + 1)
		strTB.idx = strTB.idx + 2
	else
		word = c
		strTB.idx = strTB.idx + 1
	end
	return word
end

local function getNextNumber(strTB, offset)
	local idx = strTB.idx + offset
	if idx > #strTB.str then
		return nil
	end
	local c = string.sub(strTB.str, idx, idx)
	local b = string.byte(c)
	if b >= 48 and b <= 57 then
		return c
	end
	return nil
end

-- 解析
local function parse(str)
	local strTB = {}
	strTB.str = str
	strTB.idx = 1
	local word = nil
	local tb = {}
	local bHighLight = false
	local bSpecial = false	--是否采用特殊处理
	while true do
		word = getWord(strTB)
		local wordInfo = {}
		wordInfo.isImg = false
		wordInfo.word = word
		wordInfo.bHighLight = false
		-- 高亮设置
		if word == "【" then
			bHighLight = true
			bSpecial = true
		end
		wordInfo.bHighLight = bHighLight
		if word == "】" then
			bHighLight = false
			bSpecial = true
		end
		-- 图片
		if word == "/" then
			local offset = 0
			local number = ""
			while true do
				local c = getNextNumber(strTB, offset)
				if c == nil then
					strTB.idx = strTB.idx + offset
					break
				end
				number = number..c
				offset = offset + 1
			end
			local n = tonumber(number)	-- 图片的索引
			if n ~= nil then
				wordInfo.isImg = true
				wordInfo.word = n
				bSpecial = true
			end
		end
		table.insert(tb, wordInfo)
		if strTB.idx > #str then
			break
		end
	end
	return tb, bSpecial
end

-- 绘制
local function draw(tb, size, fontSize, imgVec, bitFontFile)
	local layer = CCLayer:create()
    local totalLine = 1
	local x = 0
	local y = 0
	local maxHight = 0
	for key, value in pairs(tb) do
		if value.isImg then		-- 是否渲染图片
			if imgVec ~= nil and imgVec[value.word] ~= nil then
				local sprite = CCSprite:create(imgVec[value.word])
				layer:addChild(sprite, 0, key)
				local spriteSize = sprite:getContentSize()
				if spriteSize.height > maxHight then
					maxHight = spriteSize.height
				end
				-- 换行
				if x + spriteSize.width > size.width then
					x = 0
					y = y - maxHight
					maxHight = 0
                    totalLine = totalLine  + 1
				end
				x = x + spriteSize.width/2
				sprite:setPosition(ccp(x, y))
				x = x + spriteSize.width/2
			end
		else					-- 渲染文字
			local label = CCLabelBMFont:create(value.word, bitFontFile or "fong_guide.fnt")
			layer:addChild(label, 0, key)
			if value.bHighLight then
				label:setColor(ccc3(255, 0, 0))
			else
				label:setColor(ccc3(0, 0, 0))
			end
			local labelSize = label:getContentSize()
			if labelSize.height > maxHight then
				maxHight = labelSize.height
			end
			-- 换行
			if x + labelSize.width > size.width then
				x = 0
				y = y - maxHight
				maxHight = 0
                totalLine = totalLine  + 1
			end
			x = x + labelSize.width/2
			label:setPosition(ccp(x, y))
			x = x + labelSize.width/2
		end
	end
	return layer, totalLine
end

function RichText.create(str, size, fontSize, imgVec, bitFontFile)
	local tb, bSpecial = parse(str)
	local layer, totalLine = draw(tb, size, fontSize, imgVec, bitFontFile)
	return layer, totalLine
end

local function test()
	--[[
	local imgVec = {}
	imgVec[1] = "guide_img_01.png"
	imgVec[2] = "guide_img_02.png"
	imgVec[3] = "guide_img_03.png"
	imgVec[4] = "guide_img_04.png"
	imgVec[5] = "guide_img_05.png"
	imgVec[6] = "guide_img_06.png"
	imgVec[7] = "guide_img_07.png"
	local str = "/2周围有好多小/5动物发狂了，我们必须制止/5他们，快【翻开】格子找到他们/3。"
	local layer = RichText.create(str, CCSizeMake(420, 200), 22, imgVec)
	g_rootNode:addChild(layer, 100000)
	layer:setPosition(ccp(100, 540))
	]]--
end




