-------------------------------------------------------
-- html控件
-- create by jaron.ho on 2014-11-11
-------------------------------------------------------
UILayoutHtml = {}
----------------------------------------------------------------------
-- 颜色十六进制转为RGB,#FF00FF={r=255, g=0, b=255}
local function colorHexToRgb(colorHex)
	assert("string" == type(colorHex) and 7 == string.len(colorHex) and "#" == string.sub(colorHex, 1, 1), "colorHex = ["..colorHex.."] format error")
	local red = tonumber(string.sub(colorHex, 2, 3), 16)
	local green = tonumber(string.sub(colorHex, 4, 5), 16)
	local blue = tonumber(string.sub(colorHex, 6, 7), 16)
	assert(red and red <= 255 and green and green <= 255 and blue and blue <= 255, "colorHex = ["..colorHex.."] format error")
	return {r=red, g=green, b=blue}
end
----------------------------------------------------------------------
-- 颜色html格式rgb转为自定义格式RGB,rgb{255,0,255}={r=255, g=0, b=255}
local function colorHtmlRgbToRgb(colorRgb)
	assert("string" == type(colorRgb) and string.len(colorRgb) >= 10 and "rgb" == string.sub(colorRgb, 1, 3), "colorRgb = ["..colorRgb.."] format error")
	local str = string.sub(colorRgb, 4, string.len(colorRgb))
	assert("{" == string.sub(str, 1, 1) and "}" == string.sub(str, -1, -1), "colorRgb = ["..colorRgb.."] format error")
	local rgbTb = CommonFunc_split(string.gsub(string.sub(str, 2, -2), " ", ""), ",")
	assert(3 == #rgbTb and tonumber(rgbTb[1]) and tonumber(rgbTb[2]) and tonumber(rgbTb[3]), "colorRgb = ["..colorRgb.."] format error")
	return {r=tonumber(rgbTb[1]), g=tonumber(rgbTb[2]), b=tonumber(rgbTb[3])}
end
----------------------------------------------------------------------
-- 获取颜色值
local function getColor(colorStr, isStyleAttr)
	local defColor = {r=255, g=255, b=255}
	if "string" ~= type(colorStr) then
		return defColor
	end
	colorStr = string.lower(colorStr)
	if true == isStyleAttr then
		local bPos, ePos = string.find(colorStr, "color:")		-- 关键字
		if nil == bPos then
			return defColor
		end
		local tempStr = ""
		for i=ePos+1, string.len(colorStr) do
			local ch = string.sub(colorStr, i, i)
			if ";" == ch then		-- 结束符
				break
			end
			tempStr = tempStr..ch
		end
		colorStr = tempStr
	end
	if "" == colorStr then
		return defColor
	end
	if "#" == string.sub(colorStr, 1, 1) then
		return colorHexToRgb(colorStr)
	end
	if string.len(colorStr) > 3 and "rgb" == string.sub(colorStr, 1, 3) then
		return colorHtmlRgbToRgb(colorStr)
	end
	return defColor
end
----------------------------------------------------------------------
-- 解析html字符串:目前只能解析颜色(color)和段落(p)
local function parseHtmlStr(htmlStr)
	local tb = {}
	-- 插入表
	local function insertTb(tb, text, color, paragraph)
		local data = {}
		if true == paragraph then
			data.paragraph = paragraph				-- 新段落标识
		else
			data.text = text or ""					-- 文本内容
			data.color = color or getColor()		-- 文本颜色
		end
		table.insert(tb, data)
	end
	-- 解析html表
	local function parseHtmlTb(htmlTb, resultTb, color)
		if "table" ~= type(htmlTb) then
			return
		end
		if htmlTb._attr then
			-- 解析颜色
			if htmlTb._attr.style then
				color = getColor(htmlTb._attr.style, true)
			elseif htmlTb._attr.color then
				color = getColor(htmlTb._attr.color, false)
			end
		end
		local tag = string.lower(htmlTb._tag or "")
		-- 解析段落
		if "p" == tag or "br" == tag then
			insertTb(resultTb, "", color, true)
		end
		for i=1, #htmlTb do
			local block = htmlTb[i]
			if block then
				local blockColor = color
				if "string" == type(block) then
					if "p" == string.lower(block._tag or "") then
						insertTb(resultTb, "", color, true)
					end
					insertTb(resultTb, block, blockColor, false)
				else
					-- 解析颜色
					if block._attr then
						if block._attr.style then
							blockColor = getColor(block._attr.style, true)
						elseif block._attr.color then
							blockColor = getColor(block._attr.color, false)
						end
					end
					parseHtmlTb(block, resultTb, blockColor)
				end
			end
		end
	end
	parseHtmlTb(require("html").parsestr(htmlStr), tb)
	return tb
end
----------------------------------------------------------------------
-- 把字符串截取成多段
local function cutString(str, fontSize, headWidth, bodyWidth)
	local strTb = {}
	local headFlag = true
	local preBodyStr = ""
	local width = 0
	local bodyStr = ""
	local startPos = 1
	while startPos <= #str do
		local placeholder = CommonFunc_characterPlaceholder(string.byte(str, startPos))
		local subStr = string.sub(str, startPos, startPos + placeholder - 1)
		startPos = startPos + placeholder
		local subWidth = 0
		if 1 == placeholder then
			subWidth = fontSize/2
		else
			subWidth = fontSize
		end
		width = width + subWidth
		bodyStr = bodyStr..subStr
		if true == headFlag then
			if width > headWidth then		-- 换行
				width = subWidth
				headFlag = false
				table.insert(strTb, preBodyStr)
				bodyStr = subStr
			end
		else
			if width > bodyWidth then		-- 换行
				width = subWidth
				table.insert(strTb, preBodyStr)
				bodyStr = subStr
			end
		end
		preBodyStr = bodyStr
	end
	table.insert(strTb, bodyStr)
	return strTb
end
----------------------------------------------------------------------
-- 创建html控件:htmlStr-html格式文本(目前只支持颜色,换行),fontName-字体,fontSize-字体大小,width-控件宽度,margin-每行间距
UILayoutHtml.create = function(htmlStr, fontName, fontSize, width, margin)
	local tb = parseHtmlStr(htmlStr)
	if 0 == #tb then
		return nil
	end
	margin = margin or 1
	local layout = UILayout:create()
	layout:setAnchorPoint(ccp(0, 0))
	local height = 0
	local x = 0
	for key, val in pairs(tb) do
		if true == val.paragraph then
			height = height + fontSize + margin
			x = 0
		else
			local strTable = cutString(val.text, fontSize, width - x, width)
			local labelWidth = 0
			for k, v in pairs(strTable) do
				local label = UILabel:create()
				label:setAnchorPoint(ccp(0, 1))
				if fontName then
					label:setFontName(fontName)
				end
				label:setFontSize(fontSize)
				label:setColor(ccc3(val.color.r, val.color.g, val.color.b))
				label:setText(v)
				label:setPosition(ccp(x, -height))
				layout:addChild(label)
				labelWidth = label:getSize().width
				if strTable[k+1] then
					height = height + fontSize + margin
					x = 0
					labelWidth = 0
				end
			end
			x = x + labelWidth
		end
	end
	layout:setSize(CCSizeMake(width, height + fontSize))
	return layout
end
----------------------------------------------------------------------

