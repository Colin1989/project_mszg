package org.channel;

/**
 * 瀹氫箟娓犻亾鎿嶄綔鎺ュ彛
 */
public interface ChannelOperators {

	/**
	 * 鏄惁鏈夐棯灞廘OGO
	 */
	public boolean isNeedSplashScreen();
	
	/**
	 * 鑾峰彇闂睆璧勬簮
	 */
	public int splashScreenLayout();
	
	/**
	 * 鍒涘缓鎮诞ICON
	 */
	public boolean creatSuspensionIcon();
	
	/**
	 * 鍒濆鍖朣DK
	 */
	public boolean initSDK(String initMsg);
	
	/**
	 * 鐧诲綍SDK
	 */
	public boolean loginSDK(String loginMsg);
	
	/**
	 * 鏀粯SDK
	 */
	public boolean paySDK(String payMsg);
	
	/**
	 * 閫�嚭SDK
	 */
	public boolean exitSDK(String exitMsg);
	
	/**
	 * 鏈湴鏈嶅姟鍣ㄦ牎楠宎ppid
	 */
	public String getAppId();
	
	/**
	 * 鏈湴鏈嶅姟鍣ㄦ牎楠宎ppKey
	 */
	public String getAppKey();
	
	/**
	 * 娓犻亾id
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
	 * 鍙戦�娑堟伅
	 */
	public void sendMessage(int type, String msg);
	
	/**
	 * 鎵撳紑url鍦板潃
	 */
	public void openURL(String url, boolean exitApp);
	
	/**
	 * 澶嶅埗瀛楃涓�
	 */
	public void copyString(final String str);
	
	/**
	 * 是否需要手动注销
	 */
	public boolean isNeedCancellation();

	public void cancellationLogin();
}
