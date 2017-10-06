require "String"
require "config"
require"lfs"

local mXmlDateCache = {}
function XmlTable_load(fileName)


	local attr = lfs.attributes (fileName)
	assert (type(attr) == "table",fileName.."不存在")

	--重复读表
	--[[
	assert(nil == mXmlDateCache[fileName], "XmlTable -> load() -> repeat load file '"..fileName.."'")
	]]--
	local xmltb = mylib.parseXml(fileName)
	
	for Index,dateInfo in pairs(xmltb) do 
		if Index == "" then 
			assert(nil,fileName.."错误表格!有KEY没填！！找下那个ID填空掉")
		end 
		--value 没填
		for keyName,value in pairs(dateInfo) do 
			assert(value ~= "",fileName.."错误表格!key为："..Index.."对应的字段"..keyName.."没填\n")
			--value 含有空格
			--assert(string.find(value," ") == nil,fileName.."错误表格：key为："..Index.."对应的字段"..keyName.."含有空格\n")
		end 
	end 
	
	mXmlDateCache[fileName] = xmltb
	return xmltb
end

function getXmlDate(fileName)
	local XmlDate = mXmlDateCache[ToAbsolutePath(fileName)]
	if XmlDate == nil then 
		XmlDate = XmlTable_load(ToAbsolutePath(fileName))
	end 
	return XmlDate
end 





--检测关联 语法  
function  checkXmlRelate(srcfileName,xmlConstInfo)
	print("正在检测表关联数据",srcfileName)
	for scrKey,relateXmlFile in pairs(xmlConstInfo.relate) do
		--源表数据
		local srcXmlDate = getXmlDate(srcfileName)
		--关联表数据
		local relateXmlDate = getXmlDate(relateXmlFile)
		
		for k,dateInfo in pairs(srcXmlDate) do 
			for key,v in pairs(dateInfo) do
				if key == scrKey then 	
					for _k,singleValue in pairs(stringSplit(v,",")) do
						if singleValue ~= "0" and singleValue ~= "-1" then 
							assert (relateXmlDate[singleValue] ~=nil ,
							"在"..srcfileName.." ".."key为"..k.."的字段:"..scrKey.."的："..singleValue.."关联到"..relateXmlFile.."时找不到") -- v 可能要改成队列 
						end 
					end
				end 
			end
		end 		
	end 
end 

--检测,匹配
function checkXmpMapping(srcfileName,xmlConstInfo)
	print("正在检测匹配数据",srcfileName)
	for K,mapGroup in pairs(xmlConstInfo.matching) do 
		--源表数据
		local srcXmlDate = getXmlDate(srcfileName)
		for k,dateInfo in pairs(srcXmlDate) do 
			local valueAmount = 0
			local valutAmountTemp = -1
			
			local MapNameTemp = nil
			
			for mapName,mapValue in pairs(mapGroup) do 
				valueAmount = #stringSplit(dateInfo[mapValue],",")
				--print(mapValue,"size:",valueAmount)
				if (valutAmountTemp ~= valueAmount and valutAmountTemp >= 0) then 
					assert(nil,srcfileName.."key:"..k.."匹配对 数量错误 分别对应的KEY值:"..
					MapNameTemp.."长度:"..valutAmountTemp.." "..mapValue.."长度为"..valueAmount)
				end 
				valutAmountTemp = valueAmount
				MapNameTemp = mapValue
			end
		end 
	end 
end 


function ToAbsolutePath(file,_path)
	 if _path == nil then 
		_path = XML_PATH
	 end 
	 local f = _path..'\\'..file
	 return f
end
--检测内容
function checkXmlContent()
	for key,value in pairs(XML) do 
		if value.relate ~= nil then 
			checkXmlRelate(key,value)
		end 	
		if value.matching ~= nil then 
			checkXmpMapping(key,value)
		end 	
	end 
end




function findindir (_path, wefind)
    for file in lfs.dir(_path) do
	
		local rf = ToAbsolutePath(file,_path)		
		local xmlFile,err = string.find(file, wefind)
		if xmlFile ~= nil then 
			print("检测文件",_path.."\\"..file)
			XmlTable_load(rf)
		else 
			print("其他文件"..file)
			if file ~= "." and file ~= ".." then 
				local attr = lfs.attributes (rf)
				if attr.mode == "directory" then --and intofolder then --子文件夹
					print("子文件夹")
					findindir (_path.."\\"..file, wefind)
				end 
			end
		end 
    end
end

function checkXmls()
	findindir(XML_PATH, ".xml")
	checkXmlContent()
end

print("VERSON:",VERSON)
checkXmls()
print("Congratulations! 看到这个你的XML 表填对了 好腻害！")


