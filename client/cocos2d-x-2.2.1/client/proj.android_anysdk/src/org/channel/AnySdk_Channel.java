package org.channel;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.TreeMap;
import java.util.Iterator;

import org.cocos2dx.client.Client;
import org.cocos2dx.client.Logo;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import org.json.JSONException;
import org.json.JSONObject;
import org.util.HttpRequest;
import org.util.HttpResponse;
import org.util.MD5;
import org.util.NETUtil;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;
import android.net.Uri;

import com.anysdk.framework.IAPWrapper;
import com.anysdk.framework.PluginWrapper;
import com.anysdk.framework.UserWrapper;
import com.anysdk.framework.java.AnySDK;
import com.anysdk.framework.java.AnySDKAds;
import com.anysdk.framework.java.AnySDKAnalytics;
import com.anysdk.framework.java.AnySDKIAP;
import com.anysdk.framework.java.AnySDKListener;
import com.anysdk.framework.java.AnySDKParam;
import com.anysdk.framework.java.AnySDKPush;
import com.anysdk.framework.java.AnySDKShare;
import com.anysdk.framework.java.AnySDKSocial;
import com.anysdk.framework.java.AnySDKUser;
import com.onekes.mszg.R;

public class AnySdk_Channel implements ChannelOperators {
	private static String mUid ="";
	private static String mToken ="";
	private static Handler mUIHandler = null;
	@Override
	public  String getUid() {
		return mUid;
	} 
	@Override
	public  void setUid(String uid) {
		mUid = uid; 
	}	 
	@Override
	public String getToken() { 
		return mToken;
	}
	@Override
	public void setToken(String token) {
		mToken = token;
	}

	@Override
	public String getChannelId() {
		
		int channel = Integer.parseInt(AnySDK.getInstance().getChannelId());
		Log.e("CY","channel:" + channel);
		switch (channel) {
		case 255://android uc
			return "10011";
		case 7://android 百度91
			return "10021";
		case 550://android 应用宝
			return "10031";
		case 57://android 中兴
			return "10041";
		case 54://android 华为
			return "10051";
		case 2://android 机锋
			return "10061";
		case 6://android 安卓市场
			return "10071";
		case 5:// android 安智
			return "10081";
		case 3://android 当乐
			return "10091";
		case 16://android 联想
			return "10101";
		case 23://android 360
			return "10111";
		case 66://android 小米
			return "10121";
		case 116://android 豌豆荚
			return "10131";
		case 14://android 魅族
			return "10141";
		case 286:// android 金立
			return "10151";
		case 20://android oppo
			return "10161";
		case 9://android 应用汇
			return "10171";
		default:
			break;
		}
		return "10011";
	}

	@Override
	public boolean initSDK(String initMsg) {
		//Log.e("CY", "initSDK");
		mUIHandler = new Handler();
//		String appKey = "71F85AA6-78F7-2975-C114-73DB960184D5";
//		String appSecret = "215c6e9c5afc7ea7b2c4d3c01a1acae5";
//		String privateKey = "A636D7B764992AE6F52869445C80532C";
		
//		String appKey = "AEE563E8-C007-DC32-5535-0518D941D6C2";
//	    String appSecret = "b9fada2f86e3f73948f52d9673366610";
//	    String privateKey = "0EE38DB7E37D13EBC50E329483167860";
//		
		String appKey = "935E3284-0DD6-B44F-6EA8-CADBFF555D58";
		String appSecret = "69e3958c48d9791781d0168fe1c822e3";
		String privateKey = "EE84BA7416C9447EAC915160BDE5BC77";
		//String oauthLoginServer = "http://121.199.38.126:8080/txz/pass/anysdk/login.html";//正式打包会被替换成打包工具配置的地址参数
		String oauthLoginServer = "http://121.199.4.73:8082/txz/pass/anysdkserver/login.html";//正式打包会被替换成打包工具配置的地址参数
		//String oauthLoginServer = "http://10.0.0.46:8081/txz/pass/anysdkserver/login.html";//正式打包会被替换成打包工具配置的地址参数
		AnySDK.getInstance().initPluginSystem(Client.self, appKey, appSecret, privateKey, oauthLoginServer);
		
//		AnySDKUser.getInstance().setDebugMode(true);
//		AnySDKPush.getInstance().setDebugMode(true);
//		AnySDKAnalytics.getInstance().setDebugMode(true);
//		AnySDKAds.getInstance().setDebugMode(true);
//		AnySDKShare.getInstance().setDebugMode(true);
//		AnySDKSocial.getInstance().setDebugMode(true); 
//		AnySDKIAP.getInstance().setDebugMode(true);
		
		AnySDKUser.getInstance().setDebugMode(false);
		AnySDKPush.getInstance().setDebugMode(false);
		AnySDKAnalytics.getInstance().setDebugMode(false);
		AnySDKAds.getInstance().setDebugMode(false);
		AnySDKShare.getInstance().setDebugMode(false);
		AnySDKSocial.getInstance().setDebugMode(false);
		AnySDKIAP.getInstance().setDebugMode(false);
		setListener();
		//Log.e("CY", "initSDK_Over");
		return true;
	}

	 public static void showDialog(String title, String msg) {
	        final String curMsg = msg;
	        final String curTitle = title;
	        
	        mUIHandler.post(new Runnable() {
	            @Override
	            public void run() {
	                new AlertDialog.Builder(Client.self)
	                .setTitle(curTitle)
	                .setMessage(curMsg)
	                .setPositiveButton("Ok", 
	                        new DialogInterface.OnClickListener() {
	                            
	                            @Override
	                            public void onClick(DialogInterface dialog, int which) {
	                                
	                            }
	                        }).create().show();
	            }
	        });
	    }
	  void showTipDialog() {
	        
	        mUIHandler.post(new Runnable() {
	            @Override
	            public void run() {
	                new AlertDialog.Builder(Client.self)
	                .setTitle(R.string.paying_title)
	                .setMessage(R.string.paying_message)
	                .setPositiveButton("NO", 
	                        new DialogInterface.OnClickListener() {
	                            
	                            @Override
	                            public void onClick(DialogInterface dialog, int which) {
	                            	/**
	                       		  	* 重置支付状态
	                       		  	*/
	                                AnySDKIAP.getInstance().resetPayState();
	                            }
	                        })
	                .setNegativeButton("YES", 
	                        new DialogInterface.OnClickListener() {
	                            
	                            @Override
	                            public void onClick(DialogInterface dialog, int which) {
	                                
	                            }
	                        }).create().show();
	            }
	        });
	    }
	private void setListener() {
		/**
		 * 为用户系统设置监听
		 */
		AnySDKUser.getInstance().setListener(new AnySDKListener() {
		
			@Override
			public void onCallBack(int arg0, String arg1) {
				System.out.println("onCallBack"+ arg0);
				Log.e("CY", "onCallBack" + arg0);
				switch(arg0)
				{
				case UserWrapper.ACTION_RET_INIT_SUCCESS://初始化SDK成功回调
					Log.e("CY", "loginSDK");
					loginSDK("");
					break;
				case UserWrapper.ACTION_RET_INIT_FAIL://初始化SDK失败回调
					Log.e("CY", "exitSDK");
					exitSDK("");
					break;
				case UserWrapper.ACTION_RET_LOGIN_SUCCESS://登陆成功回调
					try{
						creatSuspensionIcon();
						JSONObject ext = new JSONObject(arg1);
						setUid(ext.getString("uid"));
						setToken(ext.getString("token"));
						if(AnySDKUser.getInstance().isFunctionSupported("antiAddictionQuery"))
						{
							AnySDKUser.getInstance().callFunction("antiAddictionQuery");
						}
						Log.e("CY", "login");
						//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
					}catch (Exception e) {
						e.printStackTrace();
					}
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
			        break;
				case UserWrapper.ACTION_RET_LOGIN_NO_NEED://登陆失败回调
					Log.e("CY", "false_1");
					Log.e("dsadsdasdada", "dsadasdasdasda");
				case UserWrapper.ACTION_RET_LOGIN_TIMEOUT://登陆失败回调
					Log.e("CY", "false_2");
					Log.e("dsadsdasdada", "dsadasdasdasda");
			    case UserWrapper.ACTION_RET_LOGIN_CANCEL://登陆取消回调
			    	Log.e("CY", "false_3");
			    	exitSDK("");
			    	break;
				case UserWrapper.ACTION_RET_LOGIN_FAIL://登陆失败回调
					//showDialog(arg1, "fail");
					Log.e("CY", "false_4");
					loginSDK("");
					AnySDKAnalytics.getInstance().logError("login", "fail");
			    	break;
				case UserWrapper.ACTION_RET_LOGOUT_SUCCESS://登出成功回调
					break;
				case UserWrapper.ACTION_RET_LOGOUT_FAIL://登出失败回调
					showDialog(arg1  , "登出失败");
					break;
				case UserWrapper.ACTION_RET_PLATFORM_ENTER://平台中心进入回调
					break;
				case UserWrapper.ACTION_RET_PLATFORM_BACK://平台中心退出回调
					break;
				case UserWrapper.ACTION_RET_PAUSE_PAGE://暂停界面回调
					break;
				case UserWrapper.ACTION_RET_EXIT_PAGE://退出游戏回调
			         exitSDK("");
					break;
				case UserWrapper.ACTION_RET_ANTIADDICTIONQUERY://防沉迷查询回调
					showDialog(arg1  , "防沉迷查询回调");
					break;
				case UserWrapper.ACTION_RET_REALNAMEREGISTER://实名注册回调
					showDialog(arg1  , "实名注册回调");
					break;
				case UserWrapper.ACTION_RET_ACCOUNTSWITCH_SUCCESS://切换账号成功回调
					break;
				case UserWrapper.ACTION_RET_ACCOUNTSWITCH_FAIL://切换账号失败回调
					break;
				default:
					break;
				}
			}
		});
		
		AnySDKIAP.getInstance().setListener(new AnySDKListener() { 
			
			@Override
			public void onCallBack(int arg0, String arg1) {
				Log.d(String.valueOf(arg0), arg1);
				String temp = "fail";
				switch(arg0)
				{
				case IAPWrapper.PAYRESULT_INIT_FAIL://支付初始化失败回调
					break;
				case IAPWrapper.PAYRESULT_INIT_SUCCESS://支付初始化成功回调
					break;
				case IAPWrapper.PAYRESULT_SUCCESS://支付成功回调
					temp = "Success";
					showDialog(temp, temp);
					break;
				case IAPWrapper.PAYRESULT_FAIL://支付失败回调
					showDialog(temp, temp);
					break;
				case IAPWrapper.PAYRESULT_CANCEL://支付取消回调
					showDialog(temp, "Cancel" );
					break;
				case IAPWrapper.PAYRESULT_NETWORK_ERROR://支付超时回调
					showDialog(temp, "NetworkError");
					break;
				case IAPWrapper.PAYRESULT_PRODUCTIONINFOR_INCOMPLETE://支付超时回调
					showDialog(temp, "ProductionInforIncomplete");
					break;
				/**
				 * 新增加:正在进行中回调
				 * 支付过程中若SDK没有回调结果，就认为支付正在进行中
				 * 游戏开发商可让玩家去判断是否需要等待，若不等待则进行下一次的支付
				 */
				case IAPWrapper.PAYRESULT_NOW_PAYING:
					showTipDialog();
					break;
				default:
					break;
				}
			}
		});
	}
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		PluginWrapper.onActivityResult(requestCode, resultCode, data);
	}
	@Override
	public void onResume() {

		PluginWrapper.onResume();
		creatSuspensionIcon();
		
	}
	
	@Override
	public void onPause() {
		if (AnySDKUser.getInstance().isFunctionSupported("hideToolBar")) {
		    AnySDKUser.getInstance().callFunction("hideToolBar");
		}
		PluginWrapper.onPause();
		
	}
	
	@Override
	public void onNewIntent(Intent intent) {
		PluginWrapper.onNewIntent(intent);
		
	}
	
	@Override
	public void onDestroy() {
		AnySDK.getInstance().release();
		
	}
	
	
	@Override
	public void sendMessage(int type, String msg) {
		if(AnySDKUser.getInstance().isFunctionSupported("submitLoginGameRole")){
			try {
				JSONObject roleMsg = new JSONObject(msg);
				Map<String,String> map = new HashMap<String, String>();
				map.put("roleId", roleMsg.getString("role_id"));// 玩家角色ID
				map.put("roleName", roleMsg.getString("role_name"));// 玩家角色名
				map.put("roleLevel", roleMsg.getString("role_level"));// 玩家角色等级
				map.put("zoneId", roleMsg.getString("zone_id"));// 游戏区服ID
				map.put("zoneName", roleMsg.getString("zone_name"));// 游戏区服名称
				map.put("ext","login"); 
				AnySDKParam param = new AnySDKParam(map);
				AnySDKUser.getInstance().callFunction("submitLoginGameRole",param);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
	}
	
	@Override
	public boolean isNeedSplashScreen() {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public int splashScreenLayout() {
		return com.onekes.mszg.R.layout.logo;
	}
	
	@Override
	public boolean creatSuspensionIcon() {
		AnySDKParam param = new AnySDKParam(4);
		AnySDKUser.getInstance().callFunction("showToolBar", param);
		return true;
	}

	@Override
	public boolean loginSDK(String loginMsg) {
		AnySDKUser.getInstance().login();
		return true;
	}
	
	@Override
	public boolean switchSDK(String switchMsg) {
		return true;
	}
	
	@Override
	public boolean paySDK(String payMsg) {
		try {
			JSONObject json = new JSONObject(payMsg);
			Map<String, String> mProductionInfo = new HashMap<String, String>();
			mProductionInfo.put("EXT", "uid="+json.getString("uid")+"&appId="+getAppId());
			mProductionInfo.put("Server_Id", json.getString("server_id"));
			mProductionInfo.put("Role_Id", json.getString("role_id"));
			mProductionInfo.put("Role_Name", json.getString("role_name"));
			mProductionInfo.put("Product_Id", json.getString("goods_id"));
			mProductionInfo.put("Product_Price", json.getString("goods_price"));//有些渠道特殊，必须是整数
			mProductionInfo.put("Product_Count", json.getString("goods_count"));
			mProductionInfo.put("Product_Name", json.getString("goods_name"));
			mProductionInfo.put("Role_Balance", "0");//用户游戏虚拟余额
			
			ArrayList<String> idArrayList =  AnySDKIAP.getInstance().getPluginId();
			if (idArrayList.size() == 1) {
			    AnySDKIAP.getInstance().payForProduct(idArrayList.get(0), mProductionInfo);
			}else{
				Log.e("Client", "paySDK()->:idArrayList is "+ idArrayList.size());
				Log.e("Client", "paySDK()->:islogin is "+ AnySDKUser.getInstance().isLogined());
			}
		
		}catch(Exception e){
				
		}
		return true;
	
	}
	
	@Override
	public boolean pauseSDK(String pauseMsg) {
		onPause();
		return true;
	}
	
	@Override
	public boolean resumeSDK(String resumeMsg) {
		onResume();
		return true;
	}

	@Override
	public boolean exitSDK(String exitMsg) {
		 
		 if( Logo.self != null){
			 AnySDK.getInstance().release();
			 Logo.self.finish();
		 }
		 if( Client.self != null)
			 Client.self.finish();
		 System.exit(0);
			 
		    
		return true;
	}
	
	@Override
	public String getAppId() {
		return "30001";
	}
	
	@Override
	public String getAppKey() {
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public void openURL(String url, boolean exitApp) {
		// TODO Auto-generated method stub	
		Intent it = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
    	Client.self.startActivity(it);
    	if (exitApp) {
    		System.exit(0);
    	}
	}
	
	@Override
	public void copyString(final String str) {
		Client.self.runOnUiThread(new Runnable() {			
			@SuppressLint("NewApi")
			@Override
			public void run() {
				if (android.os.Build.VERSION.SDK_INT > 11) {
					android.content.ClipboardManager c = (android.content.ClipboardManager) Client.self.getSystemService(Client.getContext().CLIPBOARD_SERVICE);
					c.setText(str);
				} else {
					android.text.ClipboardManager c = (android.text.ClipboardManager) Client.self.getSystemService(Client.getContext().CLIPBOARD_SERVICE);
					c.setText(str);
				}
			}
		});
	}
	
	//
	@Override
	public boolean isLogined() {
		
		return AnySDKUser.getInstance().isLogined();
	}



	
	

}
