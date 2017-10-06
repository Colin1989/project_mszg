package com.onekes.parcelable;


import android.os.Parcel;
import android.os.Parcelable;

public class PayInfo implements Parcelable{
	
	String price;
	String account;	
	String productName;
	String goods_id;
	String goods_count;
	
	String uid;
	String role_id;
	String server_id;
	
	
	public String getUid() {
		return uid;
	}
	public void setUid(String uid) {
		this.uid = uid;
	}
	public String getRole_id() {
		return role_id;
	}
	public void setRole_id(String role_id) {
		this.role_id = role_id;
	}
	public String getServer_id() {
		return server_id;
	}
	public void setServer_id(String server_id) {
		this.server_id = server_id;
	}
	
	public String getPrice() {
		return price;
	}
	public void setPrice(String price) {
		this.price = price;
	}
	public String getAccount() {
		return account;
	}
	public void setAccount(String account) {
		this.account = account;
	}
	public String getGoods_id() {
		return goods_id;
	}
	public void setGoods_id(String goods_id) {
		this.goods_id = goods_id;
	}
	public String getGoods_count() {
		return goods_count;
	}
	public void setGoods_count(String goods_count) {
		this.goods_count = goods_count;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}
	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flag) {

		dest.writeString(price);
		dest.writeString(account);
		dest.writeString(productName);
		
		dest.writeString(goods_id);
		dest.writeString(goods_count);
		dest.writeString(uid);
		dest.writeString(role_id);
		dest.writeString(server_id);
						
	}
	
	public static final Parcelable.Creator<PayInfo> CREATOR = new Parcelable.Creator<PayInfo>() {
		@Override
		public PayInfo createFromParcel(Parcel s) {
			PayInfo arg = new PayInfo();
					
			arg.setPrice(s.readString());
			arg.setAccount(s.readString());
			arg.setProductName(s.readString());
			
			arg.setGoods_id(s.readString());
			arg.setGoods_count(s.readString());
			arg.setUid(s.readString());
			arg.setRole_id(s.readString());
			arg.setServer_id(s.readString());
			

			return arg;
		}

		@Override
		public PayInfo[] newArray(int size) {
			return null;
		}

	};

}
