/**********************************************************************
* Author:	jaron.ho
* Date:		2014-03-21
* Brief:	used in lua for parse .csv file
**********************************************************************/
#include "luacsv.h"
#include <fstream>
#include "Cocos2dxLuaLoader.h"


static int parseCsv(lua_State* L, std::string buffer)
{
	if (buffer.empty())
		return 0;
	
	const static std::string lineEnd = "\r\n";
	const static size_t lineEndSize = lineEnd.size();
	const static std::string fieldEnd = ",";
	const static size_t fieldEndSize = fieldEnd.size();
	// 
	buffer += lineEnd;		// 扩展字符串以方便操作
	size_t bufferSize = buffer.size();
	// 
	std::string line;
	std::string::size_type linePos;
	std::string field;
	std::string::size_type fieldPos;
	//
	for (size_t i=0; i<bufferSize; ++i)
	{
		linePos = buffer.find(lineEnd, i);
		if (linePos >= bufferSize)
			continue;
		
		line = buffer.substr(i, linePos - i);
		if (line.empty())
			continue;

		line += fieldEnd;
		size_t lineSize = line.size();
		for (size_t j=0; j<lineSize; ++j)
		{
			fieldPos = line.find(fieldEnd, j);
			if (fieldPos >= lineSize)
				continue;

			field = line.substr(j, fieldPos - j);
			j = fieldPos + fieldEndSize - 1;
		}
		i = linePos + lineEndSize - 1;
	}
	return 1;
}

static int loadCsvFile(lua_State* L)
{
	const char *filename = (char*)luaL_checkstring(L, 1);
	if (NULL == filename)
	{
		const char *szBuf = "error in function 'loadCsv', arg1 is not string";
		showError(szBuf);
		CCLOG("%s", szBuf);
		
		return 0;
	}
	const std::string &content = decrypt_file(filename, check_need_decrypt());
	int res = parseCsv(L, content);
	if (0 == res)
	{
		static const int MAX_LEN = cocos2d::kMaxLogLen + 1;
		char szBuf[MAX_LEN];
		memset(szBuf, 0, MAX_LEN);
		sprintf(szBuf, "error in function 'loadCsv', parse csv file %s failed", filename);
		showError(szBuf);
		CCLOG("%s", szBuf);
			
		return 0;
	}
	return 1;
}

int luaopen_csv(lua_State* L)
{
	lua_register(L, "loadCsvFile", loadCsvFile);
	return 0;
}
