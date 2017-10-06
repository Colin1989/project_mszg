package org.channel;

import android.content.Intent;

/**
 * 定义渠道操作接口
 */
public interface ChannelOperators {

	/**
	 * 是否有闪屏LOGO
	 */
	 boolean isNeedSplashScreen();
	
	/**
	 * 获取闪屏资源
	 */
	 int splashScreenLayout();
	
	/**
	 * 创建悬浮ICON
	 */
	 boolean creatSuspensionIcon();
	
	/**
	 * 初始化
	 */
	 boolean initSDK(String initMsg);
	
	/**
	 * 登录
	 */
	 boolean loginSDK(String loginMsg);
	
	/**
	 * 切换
	 */
	 boolean switchSDK(String switchMsg);
	
	/**
	 * 支付
	 */
	 boolean paySDK(String payMsg);
	 
	/**
	 * 暂停
	 */
	 boolean pauseSDK(String pauseMsg);

	/**
	 * 继续
	 */
	 boolean resumeSDK(String resumeMsg);
	
	/**
	 * 退出
	 */
	 boolean exitSDK(String exitMsg);
	
	/**
	 * 本地服务器校验appid
	 */
	 String getAppId();
	
	/**
	 * 本地服务器校验appKey
	 */
	 String getAppKey();
	
	/**
	 * 渠道id
	 */
	 String getChannelId();
	 
	/**
	 * uid
	 */
	public String getUid();
	
	public void setUid(String uid);
	
	/**
	 * token
	 */
	public String getToken();
	
	public void setToken(String token);
	
	/**
	 * 发送消息
	 */
	public void sendMessage(int type, String msg);
	
	/**
	 * 打开url地址
	 */
	void openURL(String url, boolean exitApp);
	
	/**
	 * 复制字符串
	 */
	public void copyString(final String str);
	

	//======== 重写Activity生命周期=========================================
	void onActivityResult(int requestCode, int resultCode, Intent data);

	void onResume();
	void onPause();
	void onDestroy();

	void onNewIntent(Intent intent);

	boolean isLogined();
	

}
