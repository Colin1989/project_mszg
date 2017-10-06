package org.channel;

import org.cocos2dx.client.Client;
import org.cocos2dx.client.Logo;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;
import android.net.Uri;

import com.onekes.lib.OnekeySdkimpl;
import com.onekes.lib.oneKesOperationInterf;
import com.onekes.parcelable.AppInfo;
import com.onekes.parcelable.PayInfo;


/**
 * 顽客自有渠道
 * @author Administrator
 *
 */

public class Onekes_Channel implements ChannelOperators {

	@Override
	public boolean isNeedSplashScreen() {
		return false;
	}
	
	@Override
	public int splashScreenLayout() {
		return com.onekes.mszg.R.layout.logo;
	}
	
	@Override
	public boolean creatSuspensionIcon() {
		return false;
	}
	
	@Override
	public boolean initSDK(String initMsg) {
		Intent intent = new Intent(Logo.self,Client.class);
		Logo.self.startActivity(intent);
		Logo.self.finish();

        AppInfo info = new AppInfo();
        info.setAppId(getAppId());
        info.setAppkey(getAppKey());
        info.setAppName(Logo.self.getString(com.onekes.lib.R.string.app_name));
        OnekeySdkimpl.init(info);
        return true;
	}
	
	@Override
	public boolean loginSDK(String loginMsg) {
		return false;
	}
	
	@Override
	public boolean paySDK(String payMsg) {
		try {
			if (Client.self != null){ 
				JSONObject json = new JSONObject(payMsg);
				
				PayInfo info = new PayInfo();
				info.setUid(json.getString("uid"));
				info.setServer_id(json.getString("server_id"));
				info.setRole_id(json.getString("role_id"));
				info.setAccount(json.getString("role_name"));
				info.setGoods_id(json.getString("goods_id"));
				info.setPrice(json.getString("goods_price"));
				info.setGoods_count(json.getString("goods_count"));
				info.setProductName(json.getString("goods_name"));
				
				OnekeySdkimpl.pay(Client.self, info, new oneKesOperationInterf() {
					@Override
					public void CallBack(int statusCode, final String desc) {
						Toast.makeText(Client.self, desc+"status"+statusCode, Toast.LENGTH_SHORT).show();
					}
				});
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return true;
	}
	
	@Override
	public boolean exitSDK(String exitMsg) {
		return false;
	}
	
	@Override
	public String getAppId() {
		return "";
	}
	
	@Override
	public String getAppKey() {
		return "";
	}
	
	@Override
	public String getChannelId() {
		return "10001";
	}
	
	@Override
	public String getUid() {
		return "";
	}
	
	@Override
	public String getToken() {
		return "";
	}
	
	@Override
	public void sendMessage(int type, String msg) {
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
}
