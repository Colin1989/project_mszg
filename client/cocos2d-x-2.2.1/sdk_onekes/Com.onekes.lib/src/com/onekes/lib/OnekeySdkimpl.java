package com.onekes.lib;



import java.util.HashMap;
import java.util.Map;

import com.onekes.parcelable.AppInfo;
import com.onekes.parcelable.PayInfo;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

public class OnekeySdkimpl {
	/**
	 * 支付取消
	 */	
	public static final String PARCELABLE_APPINFO = "PARCELABLE_APPINFO"; 
	public static final String PARCELABLE_PAYINFO = "PARCELABLE_PAYINFO"; 
	
	
	public static AppInfo mAppInfo;
	

	public static void init( AppInfo appInfo){		
		mAppInfo = appInfo;
	}
	
	
	public static void login(){
		Log.e("SL","login");
	}
	
	public static void pay(Context context,PayInfo info,oneKesOperationInterf interf){

	
		Bundle mBundle = new Bundle();  
		mBundle.putParcelable(PARCELABLE_PAYINFO, info);  
		
		
		Intent intent = new Intent(context,PayActivity.class);
		intent.putExtras(mBundle); 
		context.startActivity(intent);
		
		PayActivity.mOneKesInter = interf;
		
	}
}