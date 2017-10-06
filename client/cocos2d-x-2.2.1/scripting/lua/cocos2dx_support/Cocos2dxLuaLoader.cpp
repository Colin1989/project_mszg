/****************************************************************************
Copyright (c) 2011 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "Cocos2dxLuaLoader.h"
#include <string>
#include <algorithm>

using namespace cocos2d;

extern "C"
{
    int cocos2dx_lua_loader(lua_State *L)
    {
        std::string filename(luaL_checkstring(L, 1));
        size_t pos = filename.rfind(".lua");
        if (pos != std::string::npos)
        {
            filename = filename.substr(0, pos);
        }
        
        pos = filename.find_first_of(".");
        while (pos != std::string::npos)
        {
            filename.replace(pos, 1, "/");
            pos = filename.find_first_of(".");
        }
        filename.append(".lua");

		const std::string &codeBuffer = decrypt_file(filename, check_need_decrypt());
		if (luaL_loadbuffer(L, codeBuffer.c_str(), codeBuffer.size(), filename.c_str()) != 0)
        {
			static const int MAX_LEN = cocos2d::kMaxLogLen + 1;
			char szBuf[MAX_LEN];
			memset(szBuf, 0, MAX_LEN);
			sprintf(szBuf, "error loading module %s from file %s :\n\t%s", lua_tostring(L, 1), filename.c_str(), lua_tostring(L, -1));
			showError(szBuf);
			CCLOG("%s", szBuf);
        }
        
        return 1;
    }
}

// add by jaron.ho at 2014-03-12 19:45
bool check_need_decrypt(std::string fileName, std::string compareStr)
{
	static bool init = true;
	static bool need = false;
	if (init)
	{
		init = false;
		unsigned long length = 0;
		unsigned char *buffer = CCFileUtils::sharedFileUtils()->getFileData(fileName.c_str(), "rb", &length);
		if (NULL == buffer)
			return need;

		std::string value = (char*)buffer;
		value = value.substr(0, length);
		delete buffer;
		buffer = NULL;
		need = compareStr == value;
	}
	return need;
}

std::string decrypt_file(std::string fileName, bool done)
{
	static unsigned char aesKey[] = 
	{
		0x2b, 0x7e, 0x15, 0x16, 
		0x28, 0xae, 0xd2, 0xa6, 
		0xab, 0xf7, 0x15, 0x88, 
		0x09, 0xcf, 0x4f, 0x3c
	};
	static AES localAES(aesKey);

	const static char *rc4Key = "W>13MH%p`|Fw895bvw6XF:>~m51<sm*/z564L;6R_xa8pi?7h8-vaV2u,162ym},2W63a7ji2CU03A9$$[*C2`4C+F0/8?FXT%fA3]U90:)oU1[nB(06<Yz7YV<P6M?5S%:G96R14'tXB|A11V9631Pb!s{g1n:a-3m(H}7I8GNwF8j.h91$!3*qCO`&2(#>ENIi8'?_C}0:#Ys1[gXIB3yYh8,wXBwxO2HPVH4CcM266zmI2@41j6Xu6E<u+S}8";

	unsigned long length = 0;
    unsigned char *buffer = CCFileUtils::sharedFileUtils()->getFileData(fileName.c_str(), "rb", &length, true);
	if (done)
	{
		//localAES.decrypt(buffer, length);
		rc4_crypto((char*)buffer, length, rc4Key);
	}
	std::string content = (char*)buffer;
	delete buffer;
	buffer = NULL;
	content = content.substr(0, length);
	return content;
}

bool isNeedDump(void)
{
	static bool init = true;
	static bool need = false;
	if (init)
	{
		init = false;
		unsigned long length = 0;
		unsigned char *buffer = CCFileUtils::sharedFileUtils()->getFileData("NeedDump.txt", "rb", &length);
		if (NULL == buffer)
			return need;
		
		std::string value = (char*)buffer;
		value = value.substr(0, length);
		delete buffer;
		buffer = NULL;
		need = "1" == value;
	}
	return need;
}

void showError(const char* str)
{
	if (NULL == str || !isNeedDump())
		return;

	static int count = 1;
	if (count++ > 6)
		return;

	static CCLabelTTF *pLabel = NULL;
	if (NULL == pLabel)
	{
		CCSize sz = CCDirector::sharedDirector()->getWinSize();
		pLabel = (CCLabelTTF*)CCLabelTTF::create("", "Arial", 24, CCSizeMake(sz.width - 20, sz.height - 200), kCCTextAlignmentLeft);
		pLabel->setAnchorPoint(ccp(0.0f, 1.0f));
		pLabel->setPosition(ccp(10, sz.height - 100));
	}
	static CCLayer *pLayer = NULL;
	if (NULL == pLayer)
	{
		pLayer = CCLayer::create();
		pLayer->addChild(pLabel);
	}
	static CCScene *pScene = NULL;
	if (NULL == pScene)
	{
		pScene = CCScene::create();
		pScene->addChild(pLayer);
	}

	const std::string &buffer =  pLabel->getString();
	pLabel->setString((buffer + str + '\n').c_str());

	CCScene *pCurScene = CCDirector::sharedDirector()->getRunningScene();
	if (NULL == pCurScene)
	{
		CCDirector::sharedDirector()->runWithScene(pScene);
	}
	else if (pCurScene != pScene)
	{
		CCDirector::sharedDirector()->replaceScene(pScene);
	}
}
