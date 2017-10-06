 
#pragma once

#include "cocos2d.h"

USING_NS_CC;

class Save_Xml : public CCNode
{
public:
	static Save_Xml* create(const char* fileName);
	void newElement(const char* elementName);
	void addSubElement(const char* key, const char* value);
	void save();
	void release();

private:
	bool initWithFileName(const char* fileName);
	tinyxml2::XMLDocument* m_pDocElement;
	tinyxml2::XMLElement* m_pRootElement;
	tinyxml2::XMLElement* m_pCurElement;

private:
	std::string mszFileName;
};