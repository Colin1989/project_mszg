/**********************************************************************
* Author:	jaron.ho
* Date:		2014-02-14
* Brief:	��Դ����
**********************************************************************/
#ifndef _RES_DOWNLOAD_H_
#define _RES_DOWNLOAD_H_

#include <string>
#include <algorithm>
#include "FileDownload.h"
#include "ResourceUpdate.h"
extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}


/**********************************************************************
************************** c++����lua�ӿ�
**********************************************************************/

const char* lua_callGlobalFunc(lua_State* L, const char* globalFuncName, const char* sig, ...);

void lua_open_interface(lua_State* L);

/**********************************************************************
************************** ��Դ����ģ��
**********************************************************************/

enum ResDownloadListenerType
{
	RDLT_PROGRESS = 1,						// ������Դ���ؽ���
	RDLT_SUCCESS,							// ������Դ�������
	RDLT_TOTAL_PROGRESS,					// ��Դ�б����ؽ���
	RDLT_TOTAL_SUCCESS,						// ������Դ�������
	RDLT_ERROR								// ��Դ���س���
};

class ResDownload : public FileDownloadListener
{
public:
	ResDownload(const std::string& downloadDir);
	~ResDownload(void);

public:
	// ���ؽ���
	virtual void onProgress(FileDownloadCode code, const std::string& fileURL, const std::string& buffer, double totalToDownload, double nowDownloaded);

	// ���سɹ�
	virtual void onSuccess(FileDownloadCode code, const std::string& fileURL, const std::string& buffer);

	// ����ʧ��
	virtual void onError(FileDownloadCode code, const std::string& fileURL, const std::string& buffer);

public:
	void listen(void);

	void excute(const std::vector<std::string>& fileUrlVec);

	void openLua(lua_State* L);

	void registerLuaHandler(ResDownloadListenerType listenerType, const std::string& globalFuncName);

private:
	FileDownload mFileDownload;						// �ļ�����
	lua_State *mLuaState;							// lua�ű������
	std::string mProgressFuncName;					// �����ļ����ؽ��Ƚű���������
	std::string mSuccessFuncName;					// �����ļ�������ɽű���������
	std::string mTotalProgressFuncName;				// �ļ��б����ؽ��Ƚű���������
	std::string mTotalSuccessFuncName;				// �����ļ�������ɽű���������
	std::string mErrorFuncName;						// �ļ����س���ű���������
};

void lua_open_resdownload(lua_State* L, const std::string& path);

/**********************************************************************
************************** ��Դ����ģ��
**********************************************************************/

enum ResUpdateListenerType
{
	RULT_CHECK_VERSION_FAILED = 1,			// �汾���ʧ��
	RULT_NEW_VERSION,						// �����°汾
	RULT_NO_NEW_VERSION,					// û���°汾
	RULT_CHECK_UPDATE_LIST_FAILED,			// �����б���ʧ��
	RULT_UPDATE_LIST,						// ���ָ����б�
	RULT_NO_UPDATE_LIST,					// û�и����б�
	RULT_PROGRESS,							// �����ļ����ؽ���
	RULT_SUCCESS,							// �����ļ��������
	RULT_TOTAL_PROGRESS,					// �ļ��б����ؽ���
	RULT_TOTAL_SUCCESS,						// �����ļ��������
	RULT_ERROR								// �ļ����س���
};

class ResUpdate : public ResourceUpdateListener
{
public:
	ResUpdate(const std::string& downloadDir, const std::string& nativeVersionFile, const std::string& nativeMd5File);
	~ResUpdate(void);

public:
	// �汾���ʧ��
	virtual void onCheckVersionFailed(const std::string& errorBuffer);

	// �����°汾
	virtual void onNewVersion(const std::string& curVersion, const std::string& newVersion);

	// û���°汾
	virtual void onNoNewVersion(const std::string& curVersion);

	// �����б���ʧ��
	virtual void onCheckUpdateListFailed(const std::string errorBuffer);

	// ���ָ����б�
	virtual void onUpdateList(long updateCount, long updateSize);

	// û�и����б�
	virtual void onNoUpdateList(void);

	// �����ļ����ؽ���
	virtual void onPogress(const std::string& fileURL, double totalSize, double curSize);

	// �����ļ��������
	virtual void onSuccess(const std::string& fileURL);

	// �ļ��б����ؽ���
	virtual void onTotalProgress(const std::string& fileURL, int totalCount, int curCount);

	// �����ļ��������
	virtual void onTotalSuccess(void);

	// �ļ����س���
	virtual void onError(const std::string& fileURL, const std::string& errorBuffer);

public:
	void listen(void);

	void checkVersion(const std::string& url, const std::string& versionCheckFile, const std::string& md5CheckFile);

	void checkUpdate(void);

	void startUpdate(void);

	void record(void);

	void openLua(lua_State* L);

	void registerLuaHandler(ResUpdateListenerType listenerType, const std::string& globalFuncName);

private:
	ResourceUpdate *mResourceUpdate;				// ��Դ����
	lua_State *mLuaState;							// lua�ű������
	std::string mCheckVersionFailedFuncName;		// �汾���ʧ�ܽű���������
	std::string mNewVersionFuncName;				// �����°汾�ű���������
	std::string mNoNewVersionFuncName;				// û���°汾�ű���������
	std::string mCheckUpdateListFailedFuncName;		// �����б���ʧ�ܽű���������
	std::string mUpdateListFuncName;				// ���ָ����б�ű���������
	std::string mNoUpdateListFuncName;				// û�и����б�ű���������
	std::string mProgressFuncName;					// �����ļ����ؽ��Ƚű���������
	std::string mSuccessFuncName;					// �����ļ�������ɽű���������
	std::string mTotalProgressFuncName;				// �ļ��б����ؽ��Ƚű���������
	std::string mTotalSuccessFuncName;				// �����ļ�������ɽű���������
	std::string mErrorFuncName;						// �ļ����س���ű���������
};

void lua_open_resupdate(lua_State* L, const std::string& path, const std::string& nativeVersion, const std::string& nativeFileList);

#endif	// _RES_DOWNLOAD_H_
