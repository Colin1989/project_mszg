/**********************************************************************
* Author:	jaron.ho
* Date:		2014-03-08
* Brief:	CURLEx
**********************************************************************/
#ifndef _CURL_EX_H_
#define _CURL_EX_H_

#include <string>
#include <vector>
#include <curl/curl.h>


/*
* write/read callback defined
*/
typedef unsigned int (*CURLEx_callback)(void* buffer, unsigned int size, unsigned int number, void* userdata);


/*
* progress callback defined
*/
typedef int (*CURLEx_progress)(void* ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded);


/*
* packaging for CURL, make the use of interface more convenience
*/
class CURLEx
{
public:
	CURLEx(void);
	~CURLEx(void);

public:
	template <class T>
    CURLcode setOption(CURLoption option, T data)
    {
		if (NULL == mCurl)
			return CURLE_FAILED_INIT;

		CURLcode code = curl_easy_setopt(mCurl, option, data);
        return code;
    }

public:
	// init CURL options
	bool initialize(void);

	// set timeout for connect
	bool setConnectTimeout(int timeout);

	// set timeout for read
	bool setTimeout(int timeout);

	// set full url to get/put
	bool setURL(const std::string& url);

	// set http headers
	bool setHeaders(const std::vector<std::string>& headers);

	// set http post fields and field size
	bool setPostFields(const std::string& fields);

	bool setHeadFunction(CURLEx_callback func, void* userdata);

	bool setWriteFunction(CURLEx_callback func, void* userdata);

	bool setReadFunctioin(CURLEx_callback func, void* userdata);

	bool setProgressFunction(CURLEx_progress func, void* userdata);

	//------------------------ multipart/formdata block ------------------------
	// called when multipart/formdata, after call addForm
	bool setHttpPost(void);

	bool addForm(curl_forms forms[], unsigned int length);

	bool addForm(const std::string& name, CURLformoption option, const std::string& value, const std::string& type = "");

	bool addFormContent(const std::string& name, const std::string& content, const std::string& type = "");

	bool addFormFile(const std::string& name, const std::string& file, const std::string& type = "");
	//--------------------------------------------------------------------

	// called at last
	bool perform(int* curlCode = NULL, int* responseCode = NULL, std::string* errorBuffer = NULL);

private:
	char mErrorBuffer[CURL_ERROR_SIZE];		// error buffer
	CURL *mCurl;							// instance of curl
    curl_slist *mHeaders;					// keeps custom header data
	curl_httppost *mPost;					// needed when multipart/formdata request
	curl_httppost *mLast;					// needed when multipart/formdata request
	static unsigned int sObjCount;			// object count in program
};


/*
* struct of http request
*/
class HttpResuest
{
public:
	HttpResuest(void) : connecttimeout(30), timeout(60) {}

public:
	std::string url;						// http request url
	std::vector<std::string> headers;		// http header
	std::string data;						// http request data
	int connecttimeout;						// http connect timeout
	int timeout;							// http download timeout
};


/*
* http request interface
*/
bool httpGet(const HttpResuest& request, CURLEx_callback writeFunc, void* writeStream, CURLEx_callback headerCallback, void* headerStream, int* curlCode = NULL, int* responseCode = NULL, std::string* errorBuffer = NULL);

bool httpPost(const HttpResuest& request, CURLEx_callback writeFunc, void* writeStream, CURLEx_callback headerCallback, void* headerStream, int* curlCode = NULL, int* responseCode = NULL, std::string* errorBuffer = NULL);

bool httpPut(const HttpResuest& request, CURLEx_callback writeFunc, void* writeStream, CURLEx_callback headerCallback, void* headerStream, int* curlCode = NULL, int* responseCode = NULL, std::string* errorBuffer = NULL);

bool httpDelete(const HttpResuest& request, CURLEx_callback writeFunc, void* writeStream, CURLEx_callback headerCallback, void* headerStream, int* curlCode = NULL, int* responseCode = NULL, std::string* errorBuffer = NULL);


#endif	// _CURL_EX_H_


/*
************************************************** sample_01

static unsigned int uploadWriteFunc(void* buffer, unsigned int size, unsigned int number, void* userdata)
{
	std::string *responseStr = (std::string*)userdata;
	unsigned int length = size * number;
	responseStr->append((char*)buffer, length);
	return length;
}

std::string Screenshot::uploadScreenshotImage(std::string uploadUrl, std::string account, std::string localPath)
{
	if (uploadUrl.empty() || account.empty() || localPath.empty())
		return "";

	FILE *fp = fopen(localPath.c_str(), "rb");
	if (NULL == fp)
		return "";

	CURLEx curl;
	if (false == curl.initialize())
		return "";

	int responseCode = -1;
	std::string errorBuffer = "";
	std::string responseStr = "";
	curl.setURL(uploadUrl);
	curl.addFormContent("acct", account);
	curl.addFormFile("image", localPath);
	curl.setHttpPost();
	curl.setWriteFunction(uploadWriteFunc, &responseStr);
	bool res = curl.perform(&responseCode, &errorBuffer);
	if (false == res)
		return "";

	Json *root= Json_create(responseStr.c_str());
	if (NULL == root)
		return "";

	unsigned int status= Json_getItem(root, "status")->valueint;
	if (1 == status)
		return "";

	std::string imageURL = Json_getItem(root, "image_path")->valuestring;
	mUrlPath = imageURL;
	return imageURL;
}
*/

/*
************************************************** sample_02

static unsigned int downloadFileWriteFunc(void* ptr, unsigned int size, unsigned int number, void* userdata)
{
	FILE *fp = (FILE*)userdata;
	unsigned int written = fwrite(ptr, size, number, fp);
	return written;
}

static int downloadFileProgressFunc(void* ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	FileDownload *self = (FileDownload*)ptr;
	if (self)
	{
		self->downloadFileProgress(totalToDownload, nowDownloaded);
	}
	return 0;
}

int FileDownload::downloadFile(const std::string& save_path, const std::string& save_name, const std::string& file_url, unsigned int timeout, std::string* error_buffer, FileDownload* self)
{
	// 创建下载的文件保存路径
	std::string fullFilePath = save_path + save_name;
	FILE *fp = fopen(fullFilePath.c_str(), "wb");
	if (NULL == fp)				// 创建保存路劲失败
		return 1;
	
	// 下载文件核心部分
	CURLEx curlObj;
	if (!curlObj.initialize())	// 初始curl失败
		return 2;

	curlObj.setURL(file_url);
	curlObj.setWriteFunction(downloadFileWriteFunc, fp);
	curlObj.setProgressFunction(downloadFileProgressFunc, self);
	curlObj.setConnectTimeout(timeout);
	int curlCode = -1, responseCode = -1;
	bool res = curlObj.perform(&curlCode, &responseCode, error_buffer);
	fclose(fp);
	char buf[64];
	sprintf(buf, "code=%d&response=%d&error=", curlCode, responseCode);
	*error_buffer = buf + *error_buffer;
	return res ? 0 : 3;			// 0-文件下载成功;3-文件下载失败
}
*/

