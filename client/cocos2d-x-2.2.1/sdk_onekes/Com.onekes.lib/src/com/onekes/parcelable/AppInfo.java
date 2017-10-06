package com.onekes.parcelable;

import android.os.Parcel;
import android.os.Parcelable;

public class AppInfo implements Parcelable{
	
	String appId;
	String appkey;
	String appName;
	
	public String getAppName() {
		return appName;
	}

	public void setAppName(String appName) {
		this.appName = appName;
	}

	public String getAppId() {
		return appId;
	}

	public void setAppId(String appId) {
		this.appId = appId;
	}

	public String getAppkey() {
		return appkey;
	}

	public void setAppkey(String appkey) {
		this.appkey = appkey;
	}

	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flag) {
		dest.writeString(appId);
		dest.writeString(appkey);
		dest.writeString(appName);
		
	}
	
	public static final Parcelable.Creator<AppInfo> CREATOR = new Parcelable.Creator<AppInfo>() {
		@Override
		public AppInfo createFromParcel(Parcel s) {
			AppInfo arg = new AppInfo();
			arg.setAppId(s.readString());
			arg.setAppkey(s.readString());	
			arg.setAppName(s.readString());
			return arg;
		}

		@Override
		public AppInfo[] newArray(int size) {
			return null;
		}

	};

}
