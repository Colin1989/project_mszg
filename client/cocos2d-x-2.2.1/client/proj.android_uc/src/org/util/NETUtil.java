package org.util;

import java.io.IOException;
import java.util.Map;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class NETUtil {

	/**
	 * 检测是否有网络
	 * 
	 * @param act
	 * @return
	 */
	public static boolean isNetworkAvailable(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null && info.getState() == NetworkInfo.State.CONNECTED)
			return true;
		return false;
	}
	
	
	/**
	 * @param url
	 * @param mapParam
	 * @return
	 * @throws IOException 
	 */
	public static HttpResponse sendHttpPostByJosnParam(String url,Map<String, String> mapParam) throws IOException{
	
			HttpRequest http = new HttpRequest();
			HttpResponse response = http.sendPost(url, mapParam);
			return response;
	}
}
