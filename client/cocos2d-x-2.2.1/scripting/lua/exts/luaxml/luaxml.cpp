/**********************************************************************
* Author:	jaron.ho
* Date:		2012-9-9
* Brief:	used in lua for parse .xml file
**********************************************************************/
#include "luaxml.h"
#include "rapidxml.hpp"
#include "Cocos2dxLuaLoader.h"


static int parseXml(lua_State* L, const char* buffer)
{
	if (NULL == buffer || 0 == strcmp(buffer, ""))
		return 0;

	rapidxml::xml_document<> doc;
	doc.parse<0>(const_cast<char*>(buffer));

	unsigned int index = 0;
	lua_newtable(L);
	rapidxml::xml_node<> *root = doc.first_node();
	for (rapidxml::xml_node<> *row = root->first_node(); row; row = row->next_sibling())
	{
		lua_newtable(L);
		for (rapidxml::xml_node<> *col = row->first_node(); col; col = col->next_sibling())
		{
			lua_pushstring(L, col->name());
			lua_pushstring(L, col->value());
			lua_rawset(L, -3);
		}
		lua_rawseti(L, -2, ++index);
	}
	return 1;
}

static int loadXmlFile(lua_State* L)
{
	const char *filename = (char*)luaL_checkstring(L, 1);
	if (NULL == filename)
	{
		const char *szBuf = "error in function 'loadXmlFile', arg1 is not string";
		showError(szBuf);
		CCLOG("%s", szBuf);
		
		return 0;
	}
	const std::string &content = decrypt_file(filename, check_need_decrypt());
	int res = parseXml(L, content.c_str());
	if (0 == res)
	{
		static const int MAX_LEN = cocos2d::kMaxLogLen + 1;
		char szBuf[MAX_LEN];
		memset(szBuf, 0, MAX_LEN);
		sprintf(szBuf, "error in function 'loadXmlFile', parse xml file %s failed", filename);
		showError(szBuf);
		CCLOG("%s", szBuf);
		
		return 0;
	}
	return 1;
}

static int getFileString(lua_State* L)
{
	const char *filename = (char*)luaL_checkstring(L, 1);
	if (NULL == filename)
	{
		const char *szBuf = "error in function 'getFileString', arg1 is not string";
		showError(szBuf);
		CCLOG("%s", szBuf);
		return 0;
	}
	unsigned long length = 0;
    unsigned char *buffer = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(filename, "rb", &length, true);
	std::string content = "";
	if (buffer)
	{
		content = (char*)buffer;
		delete buffer;
		buffer = NULL;
		content = content.substr(0, length);
	}
	lua_pushstring(L, content.c_str());
	return 1;
}

int luaopen_xml(lua_State* L)
{
	lua_register(L, "loadXmlFile", loadXmlFile);
	lua_register(L, "getFileString", getFileString);
	return 0;
}
