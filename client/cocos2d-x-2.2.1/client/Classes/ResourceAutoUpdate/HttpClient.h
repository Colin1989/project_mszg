/**********************************************************************
* Author:	jaron.ho
* Date:		2014-06-04
* Brief:	http 客户端
**********************************************************************/
#ifndef _HTTP_CLIENT_H_
#define _HTTP_CLIENT_H_

#include <string>
#include <list>
#include <pthread.h>
#include "CURLEx.h"


// http请求类型
enum HttpRequestType
{
	HRT_GET,
	HRT_POST,
	HRT_PUT,
	HRT_DELETE
};


// http处理对象
class HttpObject
{
public:
	HttpObject() : tag(""), requesttype(HRT_POST), success(false), curlcode(-1), responsecode(-1) {}
	virtual void response(void) {}			//  http消息处理函数

public:
	// 请求
	std::string tag;						// 标签,用以标识每个请求
	HttpRequestType requesttype;			// 请求类型
	HttpResuest requestdata;				// 请求数据结构

	// 响应
	bool success;							// 是否请求成功
	int curlcode;							// 请求返回的curl码
	int responsecode;						// http响应码,[200, 404]
	std::string errorbuffer;				// 错误描述,当responsecode!=200时,此值描述错误信息
	std::vector<char> responsedata;			// 响应数据,可以通过std::string str(responsedata->begin(), responsedata->end());返回字符串
	std::vector<char> responseheader;		// 响应头数据,可以通过std::string str(responseheader->begin(), responseheader->end());返回字符串
};

// http客户端
class HttpClient
{
public:
	static HttpClient *getInstance(void);	// 获取单件
	static void destroyInstance(void);		// 删除单件
	void send(HttpObject* obj);				// 发送http请求
	void receive(void);						// 每帧循环接收
};

#endif //_HTTP_CLIENT_H_

