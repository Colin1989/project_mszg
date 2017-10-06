require "String"
require "config"
require"lfs"

local mXmlDateCache = {}
function XmlTable_load(fileName)


	local attr = lfs.attributes (fileName)
	assert (type(attr) == "table",fileName.."������")

	--�ظ�����
	--[[
	assert(nil == mXmlDateCache[fileName], "XmlTable -> load() -> repeat load file '"..fileName.."'")
	]]--
	local xmltb = mylib.parseXml(fileName)
	
	for Index,dateInfo in pairs(xmltb) do 
		if Index == "" then 
			assert(nil,fileName.."������!��KEYû��������Ǹ�ID��յ�")
		end 
		--value û��
		for keyName,value in pairs(dateInfo) do 
			assert(value ~= "",fileName.."������!keyΪ��"..Index.."��Ӧ���ֶ�"..keyName.."û��\n")
			--value ���пո�
			--assert(string.find(value," ") == nil,fileName.."������keyΪ��"..Index.."��Ӧ���ֶ�"..keyName.."���пո�\n")
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





--������ �﷨  
function  checkXmlRelate(srcfileName,xmlConstInfo)
	print("���ڼ����������",srcfileName)
	for scrKey,relateXmlFile in pairs(xmlConstInfo.relate) do
		--Դ������
		local srcXmlDate = getXmlDate(srcfileName)
		--����������
		local relateXmlDate = getXmlDate(relateXmlFile)
		
		for k,dateInfo in pairs(srcXmlDate) do 
			for key,v in pairs(dateInfo) do
				if key == scrKey then 	
					for _k,singleValue in pairs(stringSplit(v,",")) do
						if singleValue ~= "0" and singleValue ~= "-1" then 
							assert (relateXmlDate[singleValue] ~=nil ,
							"��"..srcfileName.." ".."keyΪ"..k.."���ֶ�:"..scrKey.."�ģ�"..singleValue.."������"..relateXmlFile.."ʱ�Ҳ���") -- v ����Ҫ�ĳɶ��� 
						end 
					end
				end 
			end
		end 		
	end 
end 

--���,ƥ��
function checkXmpMapping(srcfileName,xmlConstInfo)
	print("���ڼ��ƥ������",srcfileName)
	for K,mapGroup in pairs(xmlConstInfo.matching) do 
		--Դ������
		local srcXmlDate = getXmlDate(srcfileName)
		for k,dateInfo in pairs(srcXmlDate) do 
			local valueAmount = 0
			local valutAmountTemp = -1
			
			local MapNameTemp = nil
			
			for mapName,mapValue in pairs(mapGroup) do 
				valueAmount = #stringSplit(dateInfo[mapValue],",")
				--print(mapValue,"size:",valueAmount)
				if (valutAmountTemp ~= valueAmount and valutAmountTemp >= 0) then 
					assert(nil,srcfileName.."key:"..k.."ƥ��� �������� �ֱ��Ӧ��KEYֵ:"..
					MapNameTemp.."����:"..valutAmountTemp.." "..mapValue.."����Ϊ"..valueAmount)
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
--�������
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
			print("����ļ�",_path.."\\"..file)
			XmlTable_load(rf)
		else 
			print("�����ļ�"..file)
			if file ~= "." and file ~= ".." then 
				local attr = lfs.attributes (rf)
				if attr.mode == "directory" then --and intofolder then --���ļ���
					print("���ļ���")
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
print("Congratulations! ����������XML ������� ���度��")


