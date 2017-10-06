#include "save_xml.h"


Save_Xml* Save_Xml::create(const char* fileName)
{
	Save_Xml *node = new Save_Xml();
	node->initWithFileName(fileName);
	node->autorelease();
	return node;
}


bool Save_Xml::initWithFileName(const char* fileName)
{
	std::string filePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	mszFileName = filePath + fileName;
	tinyxml2::XMLDocument *pDoc = new tinyxml2::XMLDocument();
	if (NULL==pDoc) 
	{
		return false;
	}

	tinyxml2::XMLDeclaration *pDel = pDoc->NewDeclaration("xml version=\"1.0\" encoding=\"UTF-8\"");
	if (NULL==pDel) 
	{
		return false;
	}
	pDoc->LinkEndChild(pDel);

	tinyxml2::XMLElement *pRootElement = pDoc->NewElement("root");
	pRootElement->SetAttribute("version", "1.0");
	pDoc->LinkEndChild(pRootElement);
	m_pRootElement = pRootElement;
	m_pDocElement = pDoc;

	return true;
}

void Save_Xml::newElement(const char* elementName)
{
	tinyxml2::XMLElement *arrayElemet = m_pDocElement->NewElement(elementName);
	m_pRootElement->LinkEndChild(arrayElemet);
	m_pCurElement = arrayElemet;
}

void Save_Xml::addSubElement(const char* key, const char* value)
{
	tinyxml2::XMLElement *strEle = m_pDocElement->NewElement(key);
	strEle->LinkEndChild(m_pDocElement->NewText(value));
	m_pCurElement->LinkEndChild(strEle);
}

void Save_Xml::save()
{
	m_pDocElement->SaveFile(mszFileName.c_str());
}

void Save_Xml::release()
{
	delete m_pDocElement;
	CCNode::release();
}