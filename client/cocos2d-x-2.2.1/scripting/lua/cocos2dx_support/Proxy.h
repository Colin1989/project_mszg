#pragma once
#ifndef __CMD5Checksum__  
#define __CMD5Checksum__  

#include "cocos2d.h" 
#include "cocos-ext.h"  

using namespace std;
using namespace cocos2d;
using namespace cocos2d::extension;

typedef unsigned long DWORD;  
typedef unsigned char BYTE;  
typedef unsigned long ULONG;  
typedef unsigned long ULONG;  
typedef unsigned int UINT;  
typedef unsigned char UCHAR;

#define	ASSERT CC_ASSERT

#ifndef TRUE
#define TRUE true
#endif

#ifndef FALSE
#define FALSE false
#endif

class FullScreenSprite : public CCSprite
{
public:
	static FullScreenSprite *create(const std::string& fileName);

	virtual void draw(void);
};

class Proxy : public CCObject
{
public:
	//getAndroidMessage
	Proxy();  
	 ~Proxy();  
	static float getAndroidDisplayDensity();
	
	//static Proxy create();
	 void HttpSend(CCObject *object,const char* url,const char *date);
	 void HttpSendInScript(CCObject *object,const char* url,const char *date,int handler);
	
	static void spriteGray(CCSprite* pSprite, bool bGray);
	static void spriteHighlight(CCSprite* pSprite, bool bHighlight);
public:  
	static string GetMD5OfString(string strString);  
	//interface functions for the RSA MD5 calculation  
	static string GetMD5(const string& strFilePath);  

	int mScriptHandle;
protected:  
	//constructor/destructor  
	//RSA MD5 implementation  
	void Transform(BYTE Block[64]);  
	void Update(BYTE* Input, ULONG nInputLen);  
	string Final();  
	inline DWORD RotateLeft(DWORD x, int n);  
	inline void FF( DWORD& A, DWORD B, DWORD C, DWORD D, DWORD X, DWORD S, DWORD T);  
	inline void GG( DWORD& A, DWORD B, DWORD C, DWORD D, DWORD X, DWORD S, DWORD T);  
	inline void HH( DWORD& A, DWORD B, DWORD C, DWORD D, DWORD X, DWORD S, DWORD T);  
	inline void II( DWORD& A, DWORD B, DWORD C, DWORD D, DWORD X, DWORD S, DWORD T);  

	//utility functions  
	inline void DWordToByte(BYTE* Output, DWORD* Input, UINT nLength);  
	inline void ByteToDWord(DWORD* Output, BYTE* Input, UINT nLength);  

	void onHttpRequestCompleted(CCHttpClient *sender, CCHttpResponse *response);
private:  
	BYTE  m_lpszBuffer[64];  //input buffer  
	ULONG m_nCount[2];   //number of bits, modulo 2^64 (lsb first)  
	ULONG m_lMD5[4];   //MD5 checksum

};
#endif
