/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.client;


import org.cocos2dx.client.Config;
import org.channel.ChannelProxy;
import org.channel.UC_Channel;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.WindowManager;

import com.onekes.mszg.uc.R;
import com.wbtech.ums.UmsAgent;

@SuppressLint("NewApi") public class Client extends Cocos2dxActivity{
	
	//private String mUid = null;onRestoreInstanceState
	//private String mToken = null; onSaveInstanceState()
	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onRestoreInstanceState(outState);
		Log.e("SL","onRestoreInstanceState------------>uid:"+ChannelProxy.getInstance().getUid()+"token"+ChannelProxy.getInstance().getToken());
		outState.putString("uid",ChannelProxy.getInstance().getUid() );
		outState.putString("token", ChannelProxy.getInstance().getToken());	
	}
	
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
		
		if (savedInstanceState == null) {
			return;
		}
		String uid = "";
		String token = "";

		uid = savedInstanceState.getString("uid");
		token = savedInstanceState.getString("token");
		Log.e("SL", "restoreBundle" + "token:" + token);

		if (uid.length() > 0 && token.length() > 0) {
			//UC_Channel.setUid(uid);
			//UC_Channel.setToken(token);
			UC_Channel.setUid(uid);
			UC_Channel.setToken(token);
		}
	}

	static public Client self = null;
	protected void onCreate(Bundle savedInstanceState){
		//restoreBundle(savedInstanceState);
		
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		super.onCreate(savedInstanceState);
		
		self = this;
		ChannelProxy.getInstance().creatSuspensionIcon();
		
		try {
			UmsAgent.setBaseURL(Config.getString("ums_url"));
		} catch(Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		UmsAgent.postClientData(this);
		UmsAgent.onError(this);
		//UmsAgent.update(this);
		UmsAgent.setDefaultReportPolicy(this, 1);
	}
	
	/**
	 * 获取appid
	 */
	public static String getAppId() {
		String appId = ChannelProxy.getInstance().getAppId();
		Log.e("Client", "getAppId() -> " + appId);
		return appId;
	}
	
	/**
	 * 获取appkey
	 */
	public static String getAppKey() {
		String appKey = ChannelProxy.getInstance().getAppKey();
		Log.e("Client", "getAppKey() -> " + appKey);
		return appKey;
	}
	
	/**
	 * 获取渠道ID
	 */
	public static String getChannelId() {
		String channelId = ChannelProxy.getInstance().getChannelId();
		Log.e("Client", "getChannelId() -> " + channelId);
		return channelId;
	}
	
	/**
	 * 获取uid
	 */
	public static String getUid() {
		String uid = ChannelProxy.getInstance().getUid();
		Log.e("Client", "getUid() -> " + uid);
		return uid;
	}
	
	/**
	 * 获取token
	 */
	public static String getToken() {
		String token = ChannelProxy.getInstance().getToken();
		Log.e("Client", "getToken() -> " + token);
		return token;
	}
	
	/**
	 * 发送消息
	 */
	public static void sendMessage(int type, String msg) {
		Log.e("Client", "sendMessage() -> type:" + type + ", msg:" + msg);
		ChannelProxy.getInstance().sendMessage(type, msg);
	}
	
	/**
	 * 支付
	 */
	public static void pay(String payMsg) {
		Log.e("Client", "pay() -> " + payMsg);
		ChannelProxy.getInstance().paySDK(payMsg);
	}
	
	/**
	 * 打开网址
	 */
	public static void openURL(String url, boolean exitApp) {
		Log.e("Client", "openURL() -> url:" + url + ", exit:" + exitApp);
		ChannelProxy.getInstance().openURL(url, exitApp);
	}
	
	/**
	 * 复制字符串
	 */
	public static void copyString(String str) {
		Log.e("Client", "copyString() -> " + str);
		ChannelProxy.getInstance().copyString(str);
	}
	
	public static void onUmsAgentEvent(String str){
		if (self != null){
			//Log.e("SL","stronUmsAgentEvent----------->"+str);
			UmsAgent.onEvent(self, str);
		}
	}
	
	public static void handleLuaExecuted() {
		Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
	}
	
	@Override
	protected void onResume() {

		super.onResume();
		UmsAgent.onResume(this);
	}


	
	@Override
	protected void onPause() {

		super.onPause();
		UmsAgent.onPause(this);
	}
	
	public Cocos2dxGLSurfaceView onCreateGLSurfaceView() {
    	return new LuaGLSurfaceView(this);
    }


	public static void exit(){
		android.os.Process.killProcess(android.os.Process.myPid());
		self.finish();
	}
	

	
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK){
			//UC_Channel.exitUC();
			if (ChannelProxy.getInstance().exitSDK("") == false){ 
				// 创建退出对话框  
				final AlertDialog isExit = new AlertDialog.Builder(this).create();  
				// 设置对话框标题  
				isExit.setIcon(R.drawable.ms_icon);
				isExit.setTitle("退出游戏");  
				// 设置对话框消息  
				isExit.setMessage("确定要退出吗?");  
				// 添加选择按钮并注册监听  
				isExit.setButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						isExit.dismiss(); 
					}
				});
				isExit.setButton2("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						exit(); 
					}
				});  

				// 显示对话框  
				isExit.show(); 
			}
		}
		return false; 
	}

    static {
		System.loadLibrary("cocos2dlua");
    }
    
}

class LuaGLSurfaceView extends Cocos2dxGLSurfaceView{
	
	public LuaGLSurfaceView(Context context){
		super(context);
	}
	
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		
    	// exit program when key back is entered
    	if (keyCode == KeyEvent.KEYCODE_BACK) {
    		android.os.Process.killProcess(android.os.Process.myPid());
    	}
        return super.onKeyDown(keyCode, event);
    }
}

