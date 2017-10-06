package org.channel;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import org.cocos2dx.client.Client;
import org.cocos2dx.client.Logo;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;
import org.util.Config;
import org.util.HttpResponse;
import org.util.MD5;
import org.util.NETUtil;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

import com.mappn.sdk.common.utils.ToastUtil;
import com.mappn.sdk.pay.GfanPay;
import com.mappn.sdk.pay.GfanPayCallback;
import com.mappn.sdk.pay.model.Order;
import com.mappn.sdk.uc.GfanUCCallback;
import com.mappn.sdk.uc.GfanUCenter;
import com.mappn.sdk.uc.User;

public class Jifen_Channel implements ChannelOperators{
	private  String mSid ="";
	private  String mToken ="";
	
	@Override
	public boolean isNeedSplashScreen() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public int splashScreenLayout() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public boolean creatSuspensionIcon() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean initSDK(String initMsg) {
		GfanPay.getInstance(Logo.self.getApplicationContext()).init();
		loginSDK("");
		return true;
	}

	
	
	@Override
	public boolean loginSDK(String loginMsg) {
		// TODO Auto-generated method stub
		GfanUCenter.login(Logo.self, new GfanUCCallback() {
			
			//private static final long serialVersionUID = 8082863654145655537L;
			
			@Override
			public void onSuccess(User user, int loginType) {
				// TODO 登录成功处理
				Log.e("CY","登陆成功");
				Log.e("CY","loginOnSuccess:" + user.getUserName() + "..." + user.getUid() + "..." + user.getToken());
				ToastUtil.showLong(Logo.self,"登录成功 user：" + user.getUserName());
				
				String uid = user.getUid() + "";
				String token = user.getToken() + "";
				
				Log.e("SL","first uid:"+uid+" token"+token);
				
				try {
					Log.e("CY","account_server_url:"+Config.getString("account_server_url"));
					//String account_server_url = "http://10.0.0.46:8081/txz/pass/jf_login.html";
//					HttpResponse resp = NETUtil.sendHttpPostByJosnParam(Config.getString("account_server_url"),getLoginCheckParam(sid, token));
					HttpResponse resp = NETUtil.sendHttpPostByJosnParam(Config.getString("account_server_url"),getLoginCheckParam(uid, token));
					HandlerRespUIdAndToken(resp);
					//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			
			@Override
			public void onError(int loginType) {
				Log.e("CY","登陆失败");
				ToastUtil.showLong(Logo.self,"登录失败 user：" );	
			}
		});
		return false;
	}
	
	public void secondLogin(){
GfanUCenter.login(Client.self, new GfanUCCallback() {
			
			//private static final long serialVersionUID = 8082863654145655537L;
			
			@Override
			public void onSuccess(User user, int loginType) {
				// TODO 登录成功处理
				Log.e("CY","登陆成功");
				Log.e("CY","loginOnSuccess:" + user.getUserName() + "..." + user.getUid() + "..." + user.getToken());
				ToastUtil.showLong(Client.self,"登录成功" + user.getUserName());
				
				String uid = user.getUid() + "";
				String token = user.getToken() + "";
				
				try {
					HttpResponse resp = NETUtil.sendHttpPostByJosnParam(Config.getString("account_server_url"),getLoginCheckParam(uid, token));				
					if (resp != null){		
						if (resp.isSuccess() == true){ 
							
							try {
								JSONObject recvjosn= new JSONObject(resp.getContent());	
								Log.e("SL","recv Josn-------->"+ recvjosn.toString());
								if (recvjosn.getBoolean("success") == true){  
									JSONObject data = recvjosn.getJSONObject("data");
									
									setUid(data.getString("uid"));
									setToken(data.getString("token"));
									
									Log.e("SL","UID"+getUid());
									Log.e("SL","TOKEN"+getToken());
									// 通知LUA
									Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("secondLogin", "param");	
																		
									setUid(data.getString("uid"));
									setToken(data.getString("token"));
									
								}
								
							} catch (JSONException e) {
								e.printStackTrace();
							}
						}	
					}
					
					//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			
			@Override
			public void onError(int loginType) {
				Log.e("CY","登陆失败");
				ToastUtil.showLong(Logo.self,"登录失败 user：" );	
			}
		});
	}

	@Override
	public boolean paySDK(String payMsg) {
		String OrderNumer = "";
		int price = 0;
		try {
			JSONObject json = new JSONObject(payMsg);
			
			TreeMap<String, String> payInfo = new TreeMap<String, String>();
			payInfo.put("uid", json.getString("uid"));
			payInfo.put("server_id", json.getString("server_id"));
			payInfo.put("role_Id", json.getString("role_id"));
			//payInfo.put("role_Name", json.getString("role_name"));
			payInfo.put("goods_id", json.getString("goods_id"));
			payInfo.put("goods_price", json.getString("goods_price"));
			price = Integer.parseInt( json.getString("goods_price"));
			payInfo.put("goods_count", json.getString("goods_count"));
			
			HttpResponse resp = NETUtil.sendHttpPostByJosnParam(Config.getString("pay_order_url"),sendOrderInfo(payInfo));
			if (resp == null){
				Toast.makeText(Client.self, "account Server error", Toast.LENGTH_SHORT);
				return false;
			}else{
				JSONObject respJson = new JSONObject(resp.getContent());
				if (respJson.getBoolean("success") == true){
					JSONObject data = respJson.getJSONObject("data");
					OrderNumer = data.getString("order_no");	
				}
				else{
					Toast.makeText(Client.self, "订单号申请失败", Toast.LENGTH_SHORT);
				}

			}
		}catch(Exception e){
			e.printStackTrace();
		}
		
		Log.e("CY price==",""+price+"OrderNumer"+OrderNumer);
		Order order  = new Order("魔石", "获得魔石",price*10, OrderNumer);// 第三个参数 是机锋券  1元 == 10机锋券
		
		GfanPay.getInstance(Client.self).pay(order, new GfanPayCallback() {
			@Override
			public void onSuccess(User arg0, Order arg1) {

				//Toast.makeText(Client.self, text, duration)
			}
			
			@Override
			public void onError(User arg0) {
			
			
			}
		});
		
		return false;
	}
	
	@Override
	public boolean exitSDK(String exitMsg) {
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public String getAppId() {
		return "30001";
	}
	
	@Override
	public String getAppKey() {
		return "8a808023468dd22001468dd220270000";
	}

	@Override
	public String getChannelId() {
		return "10061";
	}

	@Override
	public String getUid() {
		return mSid;
	}

	@Override
	public String getToken() {
		return mToken;
	}

	@Override
	public void sendMessage(int type, String msg) {
		// TODO Auto-generated method stub
		try {
			if (1 == type) {
				JSONObject roleMsg = new JSONObject(msg);
				JSONObject jsonExData = new JSONObject();
				jsonExData.put("roleId", roleMsg.get("role_id"));// 玩家角色ID
				jsonExData.put("roleName", roleMsg.get("role_name"));// 玩家角色名
				jsonExData.put("roleLevel", roleMsg.get("role_level"));// 玩家角色等级
				jsonExData.put("zoneId", roleMsg.get("zone_id"));// 游戏区服ID
				jsonExData.put("zoneName", roleMsg.get("zone_name"));// 游戏区服名称
//				UCGameSDK.defaultSDK().submitExtendData("loginGameRole", jsonExData);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void openURL(String url, boolean exitApp) {
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
	
	public  void setUid(String sid) {
		mSid = sid;
	}
	
	public  void setToken(String token) {
		mToken = token;
	}
	
	private void HandlerRespUIdAndToken(HttpResponse resp){ 
		if (resp != null){		
			if (resp.isSuccess() == true){ 
				
				try {
					JSONObject recvjosn= new JSONObject(resp.getContent());	
					Log.e("SL","recv Josn-------->"+ recvjosn.toString());
					if (recvjosn.getBoolean("success") == true){  
						JSONObject data = recvjosn.getJSONObject("data");
						setUid(data.getString("uid"));
						setToken(data.getString("token"));
						
						
						Log.e("SL","UID"+getUid());
						Log.e("SL","TOKEN"+getToken());
						
						Intent intent = new Intent(Logo.self,Client.class);
						Logo.self.startActivity(intent);
						Logo.self.finish();
					}
					
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}	
		}
	}
	
	private Map<String, String> getLoginCheckParam(String uid, String token){
		Map<String, String> mapParam = new TreeMap<String, String>();
		
		mapParam.put("app_id", ChannelProxy.getInstance().getAppId());
		mapParam.put("app_key", ChannelProxy.getInstance().getAppKey());
		mapParam.put("channel_id", ChannelProxy.getInstance().getChannelId());
		mapParam.put("uid", uid);
			
		try {
			mapParam.put("token", URLEncoder.encode(token,"utf-8").toString());
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		StringBuffer sb=new StringBuffer("");
		Iterator<String> it = mapParam.keySet().iterator();
		while(it.hasNext()){
			sb.append(mapParam.get(it.next()));
		}
		mapParam.put("sign", MD5.getmd5(sb.toString()));
		return mapParam;
	}
	
	private static TreeMap<String, String> sendOrderInfo(TreeMap<String, String> payInfo){
		
		payInfo.put("app_id", ChannelProxy.getInstance().getAppId());
		payInfo.put("app_key", ChannelProxy.getInstance().getAppKey());
		
		
		StringBuffer sb=new StringBuffer("");
		Iterator<String> it = payInfo.keySet().iterator();
		while(it.hasNext()){
			sb.append(payInfo.get(it.next()));
		}
		payInfo.put("sign", MD5.getmd5(sb.toString()));
		return payInfo;
	}

	@Override
	public boolean isNeedCancellation() {
		return true;
	}
	
	//注销登入
	public void cancellationLogin(){
		GfanUCenter.logout(Client.self);
		secondLogin();
	}

}
