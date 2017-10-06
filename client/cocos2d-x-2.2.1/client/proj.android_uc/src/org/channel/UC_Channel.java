package org.channel;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import android.net.Uri;

import org.cocos2dx.client.Client;
import org.cocos2dx.client.Config;
import org.cocos2dx.client.Logo;
import org.json.JSONException;
import org.json.JSONObject;
import org.util.HttpRequest;
import org.util.HttpResponse;
import org.util.MD5;
import org.util.NETUtil;

import com.onekes.mszg.uc.R;







import android.annotation.SuppressLint;
import android.content.Intent;
import android.util.Log;
import cn.uc.gamesdk.IUCBindGuest;
import cn.uc.gamesdk.UCBindGuestResult;
import cn.uc.gamesdk.UCCallbackListener;
import cn.uc.gamesdk.UCCallbackListenerNullException;
import cn.uc.gamesdk.UCFloatButtonCreateException;
import cn.uc.gamesdk.UCGameSDK;
import cn.uc.gamesdk.UCGameSDKStatusCode;
import cn.uc.gamesdk.UCLogLevel;
import cn.uc.gamesdk.UCLoginFaceType;
import cn.uc.gamesdk.UCOrientation;
import cn.uc.gamesdk.info.FeatureSwitch;
import cn.uc.gamesdk.info.GameParamInfo;
import cn.uc.gamesdk.info.OrderInfo;
import cn.uc.gamesdk.info.PaymentInfo;


/**
 * UC渠道
 */

public class UC_Channel implements ChannelOperators {
	
	private static String mUid ="";
	private static String mToken ="";
	
	@Override
	public boolean isNeedSplashScreen() {
		return false;
	}
	
	@Override
	public int splashScreenLayout() {
		return com.onekes.mszg.uc.R.layout.logo;
	}
	
	@Override
	public boolean creatSuspensionIcon() {
		ucSdkCreateFloatButton();
		ucSdkShowFloatButton();
		return true;
	}
	
	@Override
	public boolean initSDK(String initMsg)  {
		GameParamInfo gpi = new GameParamInfo();
		gpi.setCpId(39349);
		gpi.setGameId(540463);
		gpi.setServerId(3161);	
		
		final boolean success = false;		

		IUCBindGuest ucBindGuest = new IUCBindGuest() {
		@Override
		public UCBindGuestResult bind(String sid) {


			UCBindGuestResult bindResult = new UCBindGuestResult();
			bindResult.setSuccess(success); 
			return bindResult;
			}
		};

		UCCallbackListener<String> logoutListener = new UCCallbackListener<String>() {
			@Override
			public void callback(int statuscode, String data) {
				switch (statuscode) {
				case UCGameSDKStatusCode.NO_INIT:
					break;
				case UCGameSDKStatusCode.NO_LOGIN:
					break;
				case UCGameSDKStatusCode.SUCCESS:
					break;
				case UCGameSDKStatusCode.FAIL:
					break;
				default:
					break;
				}
			}
		};
		
		try {
			gpi.setFeatureSwitch(new FeatureSwitch(true, false));
			//
			UCGameSDK.defaultSDK().setOrientation(UCOrientation.PORTRAIT);


			UCGameSDK.defaultSDK().setLoginUISwitch(UCLoginFaceType.USE_WIDGET);
			

			UCGameSDK.defaultSDK().setBindOperation(ucBindGuest);
			
			UCGameSDK.defaultSDK().setLogoutNotifyListener(logoutListener);
			
			UCGameSDK.defaultSDK().initSDK(Logo.self, UCLogLevel.DEBUG, false, gpi,new UCCallbackListener<String>() {

				@Override
				public void callback(int code, String msg) {
					switch (code){
						case UCGameSDKStatusCode.SUCCESS:
							loginSDK("");	
							break;
						case UCGameSDKStatusCode.INIT_FAIL:
							break;
					}
				}
			});
		}catch(Exception e){
			
		}
		return true;
	}
	
	@Override
	public boolean loginSDK(String loginMsg) {
		try {			
			// ��¼�ӿڻص�����������Ի�ȡ��¼�����
			UCCallbackListener<String> loginCallbackListener = new UCCallbackListener<String>() {
				@Override
				public void callback(int code, String msg) {
					Log.e("UCGameSDK", "UCGameSdk:code=" + code+ ",msg=" + msg);


					if (code == UCGameSDKStatusCode.SUCCESS) {

						String sid = UCGameSDK.defaultSDK().getSid();
						Log.e("SL","sid"+sid);	
						
						try {							
							HttpResponse resp = NETUtil.sendHttpPostByJosnParam(Config.getString("account_server_url"),getLoginCheckParam(sid));
							HandlerRespUIdAndToken(resp);
							//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
						} catch (Exception e) {
							e.printStackTrace();
						}
						//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("setRunParam", "{\"is_login_ok\":true,\"is_show_login\":false}");
					}

					if (code == UCGameSDKStatusCode.NO_INIT) {
						initSDK("");
					}

					if (code == UCGameSDKStatusCode.LOGIN_EXIT) {
					}
				}
			};
			UCGameSDK.defaultSDK().login(Logo.self, loginCallbackListener);

		} catch (Exception e) {
			
		}
		return true;
	}
	
	@Override
	public boolean paySDK(String payMsg) {
		try {
			JSONObject json = new JSONObject(payMsg);
			
			TreeMap<String, String> payInfo = new TreeMap<String, String>();
			payInfo.put("uid", json.getString("uid"));
			payInfo.put("server_id", json.getString("server_id"));
			payInfo.put("role_Id", json.getString("role_id"));
			//payInfo.put("role_Name", json.getString("role_name"));
			payInfo.put("goods_id", json.getString("goods_id"));
			payInfo.put("goods_price", json.getString("goods_price"));
			payInfo.put("goods_count", json.getString("goods_count"));
//			payInfo.put("goods_name", json.getString("goods_name"));
			
			PaymentInfo pInfo = new PaymentInfo(); // 创建Payment对象，用于传递充值信息
			pInfo.setCustomInfo(payInfo.get("uid")+"#"+payInfo.get("role_Id")+"#"+payInfo.get("server_id")+"#"+payInfo.get("goods_id")+"#"+payInfo.get("goods_count")+"#"+payInfo.get("goods_price")+"#"+payInfo.get("role_Name"));
			// 非必选参数，可不设置，此参数已废弃,默认传入0即可。
			// 如无法支付，请在开放平台检查是否已经配置了对应环境的支付回调地址，如无请配置，如有但仍无法支付请联系UC技术接口人。
			pInfo.setRoleId(payInfo.get("role_id")); // 设置用户的游戏角色的ID，此为必选参数，请根据实际业务数据传入真实数据
			pInfo.setRoleName(payInfo.get("role_Name")); // 设置用户的游戏角色名字，此为必选参数，请根据实际业务数据传入真实数据
			// 非必填参数，设置游戏在支付完成后的游戏接收订单结果回调地址，必须为带有http头的URL形式。
			pInfo.setNotifyUrl(Config.getString("pay_notify_url"));
			// 当传入一个amount作为金额值进行调用支付功能时，SDK会根据此amount可用的支付方式显示充值渠道
			// 如你传入6元，则不显示充值卡选项，因为市面上暂时没有6元的充值卡，建议使用可以显示充值卡方式的金额
			pInfo.setAmount(Float.parseFloat(payInfo.get("goods_count"))*Float.parseFloat(payInfo.get("goods_price")));// 设置充值金额，此为可选参数
			final TreeMap<String, String> toServerInfo =payInfo;
			try {
				UCGameSDK.defaultSDK().pay(Client.self, pInfo,
						new UCCallbackListener<OrderInfo>() {
	
							@Override
							public void callback(int statudcode, OrderInfo orderInfo) {
								if (statudcode == UCGameSDKStatusCode.NO_INIT) {
									//没有初始化就进行登录调用，需要游戏调用SDK初始化方法
									}if (statudcode == UCGameSDKStatusCode.SUCCESS){
									//订单提交充值
									if (orderInfo != null) {
										TreeMap<String, String> toserver =  toServerInfo;
										toserver.put("third_order_no", orderInfo.getOrderId());//获取订单号
										//toserver.put("amount", String.valueOf(orderInfo.getOrderAmount()));//获取订单金额
										toserver.put("payWay", String.valueOf(orderInfo.getPayWay())) ;//获取充值类型，具体可参考支付通道编码列表
//										toserver.put("payWayName", orderInfo.getPayWayName());//充值类型的中文名称
										try{
											 //toServerInfo.put("role_Name", URLEncoder.encode(toserver.get("role_Name"), "UTF-8"));
											 HttpResponse resp = NETUtil.sendHttpPostByJosnParam(Config.getString("pay_url"),sendOrderInfo(toserver));
											 Log.e("SL","pay http addr-------->"+ Config.getString("pay_url"));
											 JSONObject recvjosn= new JSONObject(resp.getContent());	
											 Log.e("SL","pay recv Josn-------->"+ recvjosn.toString());
										}catch (Exception e) {
											// TODO: handle exception
											e.printStackTrace();
										}
									}
									}
									if (statudcode == UCGameSDKStatusCode.PAY_USER_EXIT) {
									//用户退出充值界面。
									}
							}
					
						});
			} catch (UCCallbackListenerNullException e) {
				// 异常处理
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return true;
	}

	@Override
	public boolean exitSDK(String exitMsg) {
		UCGameSDK.defaultSDK().exitSDK(Client.self, new UCCallbackListener<String>() {
			@Override
			public void callback(int code, String msg) {
				if (UCGameSDKStatusCode.SDK_EXIT_CONTINUE == code) {

				} else if (UCGameSDKStatusCode.SDK_EXIT == code) {
					ucSdkDestoryFloatButton();
					Client.exit();
				}
			}
		});
		return true;
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
		return "10011";
	}
	
	@Override
	public String getUid() {
		return mUid;
	}
	
	@Override
	public String getToken() {
		return mToken;
	}
	
	@Override
	public void sendMessage(int type, String msg) {
		try {
			if (1 == type) {
				JSONObject roleMsg = new JSONObject(msg);
				JSONObject jsonExData = new JSONObject();
				jsonExData.put("roleId", roleMsg.get("role_id"));// 玩家角色ID
				jsonExData.put("roleName", roleMsg.get("role_name"));// 玩家角色名
				jsonExData.put("roleLevel", roleMsg.get("role_level"));// 玩家角色等级
				jsonExData.put("zoneId", roleMsg.get("zone_id"));// 游戏区服ID
				jsonExData.put("zoneName", roleMsg.get("zone_name"));// 游戏区服名称
				UCGameSDK.defaultSDK().submitExtendData("loginGameRole", jsonExData);
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
	
	public static void setUid(String uid) {
		mUid = uid;
	}
	
	public static void setToken(String token) {
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
						//setUid(data.getString("uid"));
						//setToken(data.getString("token"));
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
	


	public void ucSdkCreateFloatButton() {
		Client.self.runOnUiThread(new Runnable() {
			public void run() {
				try {
					UCGameSDK.defaultSDK().createFloatButton(Client.self,
							new UCCallbackListener<String>() {

								@Override
								public void callback(int statuscode, String data) {
									Log.d("SelectServerActivity`floatButton Callback",
											"statusCode == " + statuscode
													+ "  data == " + data);
								}
							});

				} catch (UCCallbackListenerNullException e) {
					e.printStackTrace();
				} catch (UCFloatButtonCreateException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
	}

	public void ucSdkShowFloatButton() {
		Client.self.runOnUiThread(new Runnable() {
			public void run() {
				// ��ʾ����ͼ�꣬��Ϸ����ĳЩ����ѡ�����ش�ͼ�꣬����Ӱ����Ϸ����
				try {
					UCGameSDK.defaultSDK().showFloatButton(Client.self, 100, 50, true);
				} catch (UCCallbackListenerNullException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
	}

	public static void ucSdkDestoryFloatButton() {
		Client.self.runOnUiThread(new Runnable() {
			public void run() {
				UCGameSDK.defaultSDK().destoryFloatButton(Client.self);
			}
		});
	}

	private Map<String, String> getLoginCheckParam(String sid){
		Map<String, String> mapParam = new TreeMap<String, String>();
		
		mapParam.put("app_id", ChannelProxy.getInstance().getAppId());
		mapParam.put("app_key", ChannelProxy.getInstance().getAppKey());
		mapParam.put("channel_id", ChannelProxy.getInstance().getChannelId());
		mapParam.put("sid", sid);
	
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
	
}












