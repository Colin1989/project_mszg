/******************************************************************************
* Author: jaron.ho
* Date: 2014-04-10
* Brief: string filter
******************************************************************************/
#include "StringFilter.h"

//--------------------------------------------------------------------------
StringFilter::StringFilter(void)
{
	mLoaded = false;
}
//--------------------------------------------------------------------------
StringFilter::~StringFilter(void)
{
}
//--------------------------------------------------------------------------
bool StringFilter::load(const char* filePath)
{
	if (mLoaded)
		return false;

	FILE *fp = fopen(filePath, "rb");
	if (NULL == fp)
		return false;

	char buf[128];
	while (NULL != fgets(buf, sizeof(buf)-1, fp))
	{
		unsigned int wordLen = strlen(buf);
		for (unsigned int i=0; i<wordLen; ++i)
		{
			if ('\r' == buf[i] || '\n' == buf[i])
			{
				buf[i] = '\0';
				break;
			}
		}
		mTrie.insert(replace(buf, " ", ""));
	}
	fclose(fp);
	mLoaded = true;
	return true;
}
//--------------------------------------------------------------------------
bool StringFilter::parse(const char* fileData)
{
	if (mLoaded || NULL == fileData)
		return false;

	const std::vector<std::string> &strVec = split(replace(fileData, " ", ""), "\r\n");
	for (unsigned int i=0; i<strVec.size(); ++i)
	{
		if (strVec[i].empty())
			continue;

		mTrie.insert(strVec[i]);
	}

	mLoaded = true;
	return true;
}
//--------------------------------------------------------------------------
std::string StringFilter::censor(std::string source, const char& mask)
{
	if (!mLoaded)
		return source;

	unsigned int length = source.size();
	std::string substring;
	std::string keyword;
	for (unsigned int start=0; start<length; ++start)
	{
		substring = source.substr(start, length - start);
		keyword = mTrie.search(substring);
		if (!keyword.empty())
		{
			std::string dest(keyword.size(), mask);
			source = replace(source, keyword, dest);
		}
	}
	return source;
}
//--------------------------------------------------------------------------
std::string StringFilter::replace(std::string str, const std::string& src, const std::string& dest)
{
	unsigned int srclen = src.size();
	unsigned int destlen = dest.size();
	std::string::size_type pos = 0;
	while (std::string::npos != (pos = str.find(src, pos)))
	{
		str.replace(pos, srclen, dest);
		pos += destlen;
	}
	return str;
}
//--------------------------------------------------------------------------
std::vector<std::string> StringFilter::split(std::string str, const std::string& pattern)
{
	std::vector<std::string> result;
	if (str.empty() || pattern.empty())
		return result;

	str += pattern;		// extend string
	unsigned int strSize = str.size();
	unsigned int patternSize = pattern.size();
	std::string::size_type pos = 0;
	for (unsigned int i=0; i<strSize; ++i)
	{
		pos = str.find(pattern, i);
		if (pos < strSize)
		{
			result.push_back(str.substr(i, pos - i));
			i = pos + patternSize - 1;
		}
	}
	return result;
}
//--------------------------------------------------------------------------
