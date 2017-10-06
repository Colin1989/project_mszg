package org.channel;

/**
 * 定义渠道操作接口
 */
public interface ChannelOperators {

	/**
	 * 是否有闪屏LOGO
	 */
	public boolean isNeedSplashScreen();
	
	/**
	 * 获取闪屏资源
	 */
	public int splashScreenLayout();
	
	/**
	 * 创建悬浮ICON
	 */
	public boolean creatSuspensionIcon();
	
	/**
	 * 初始化SDK
	 */
	public boolean initSDK(String initMsg);
	
	/**
	 * 登录SDK
	 */
	public boolean loginSDK(String loginMsg);
	
	/**
	 * 支付SDK
	 */
	public boolean paySDK(String payMsg);
	
	/**
	 * 退出SDK
	 */
	public boolean exitSDK(String exitMsg);
	
	/**
	 * 本地服务器校验appid
	 */
	public String getAppId();
	
	/**
	 * 本地服务器校验appKey
	 */
	public String getAppKey();
	
	/**
	 * 渠道id
	 */
	public String getChannelId();
	
	/**
	 * uid
	 */
	public String getUid();
	
	/**
	 * token
	 */
	public String getToken();
	
	/**
	 * 发送消息
	 */
	public void sendMessage(int type, String msg);
	
	/**
	 * 打开url地址
	 */
	public void openURL(String url, boolean exitApp);
	
	/**
	 * 复制字符串
	 */
	public void copyString(final String str);
}
