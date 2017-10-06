 package com.onekes.lib;

import java.io.InputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import org.apache.http.util.EncodingUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.R.integer;
import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.GridView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.alipay.android.app.sdk.AliPay;
import com.onekes.channelconst.alipayConst;
import com.onekes.parcelable.PayInfo;
import com.onekes.tools.HttpResponse;
import com.onekes.tools.MD5;
import com.onekes.tools.NETUtil;

public class PayActivity extends Activity implements OnItemClickListener{
	
	private String payOrderUrl = "";//支付订单获取地址
	private String payUrl = "";//支付回调地址
	
	/**
	 * onekeys支持渠道列表
	 */
	String[] ChannelList;
	
	public static oneKesOperationInterf mOneKesInter;
	
	private PayInfo mPayInfo;
	
	//private static final int RQF_PAY = 1;
	//private static final int RQF_LOGIN = 2;
	
	
	Handler mHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			//switch (msg.what) {	
				alipayConst result = new alipayConst((String) msg.obj);
				
				String showStr = alipayConst.sResultStatus.get(result.getResultStatus());
				
				if ( showStr != null){
					showStr = alipayConst.sResultStatus.get(result.getResultStatus());
				}else {
					showStr = "其他错误";
				}
				
				mOneKesInter.CallBack(Integer.parseInt(result.getResultStatus()),showStr);
			//default:
				//break;
			//}
		};
	};

	private int getDrawIdByString(String fileName){
		int image = this.getResources().getIdentifier(fileName.substring(0, 
				fileName.length()-4), "drawable", getPackageName()); 
		return image;	
	}
	
	
	private void initCurChanenl() throws Exception
	{
		String paychannel = Config.getString("pay_channel");
		ChannelList = paychannel.split("\\|");
		payOrderUrl = Config.getString("pay_order_url");
		payUrl = Config.getString("pay_url");
	}

	private boolean isMyChennel(String key) {
		String[] str = ChannelList;

		for (String buf : str) {
			if (buf.equals(key)) {
				return true;
			}
		}
		return false;
	}
		
	private void setContentGridView() {
		GridView girdView = (GridView) findViewById(R.id.pay_gridView);
		ArrayList<HashMap<String, Object>> lstImageItem = new ArrayList<HashMap<String, Object>>();

		String[] payChannel = getResources().getStringArray(
				R.array.paychannel_info_array);

		for (int k = 0; k < payChannel.length; k++) {
			String[] str = payChannel[k].split("\\|");
			if (ChannelList != null && isMyChennel(str[0]) == true) {
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("ItemImage", getDrawIdByString(str[1]));// 添加图像资源的ID
				map.put("ItemText", str[2]);// 按序号做ItemText
				lstImageItem.add(map);
			}
		}
		SimpleAdapter saImageItem = new SimpleAdapter(this, lstImageItem,
				R.layout.pay_info, new String[] { "ItemImage", "ItemText" },
				new int[] { R.id.pay_info_imageView, R.id.pay_info_textView });

		girdView.setAdapter(saImageItem);
		girdView.setOnItemClickListener(this);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		
		 mPayInfo = getIntent().getParcelableExtra(OnekeySdkimpl.PARCELABLE_PAYINFO);
		
		try {
			initCurChanenl();
		} catch (Exception e) {
			// TODO Auto-generated catch block

			e.printStackTrace();
		}
		setContentView(R.layout.pay);
		setView();
		setContentGridView();
	}
	private void setView(){
		//TextView payAccount = (TextView) findViewById(R.id.payAccount);
		//payAccount.setText(String.format(getString(R.string.pay_account), mPayInfo.getAccount()));
				
		TextView payPrice = (TextView) findViewById(R.id.payPrice);
		payPrice.setText(String.format("%s元", mPayInfo.getPrice()));
		
		TextView payName = (TextView) findViewById(R.id.payName);
		payName.setText( OnekeySdkimpl.mAppInfo.getAppName());
		
		
		Button btn = (Button) findViewById(R.id.cancle_btn);
		btn.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				finish();
			}
		});
	}
	//与账服通信参数
	private Map<String, String> getPayOrderParam(){
		Map<String, String> mapParam = new TreeMap<String, String>();
		
		mapParam.put("app_id", OnekeySdkimpl.mAppInfo.getAppId());
		mapParam.put("app_key", OnekeySdkimpl.mAppInfo.getAppkey());
		
		mapParam.put("uid",mPayInfo.getUid());	
		mapParam.put("role_id",mPayInfo.getRole_id());
		mapParam.put("server_id",mPayInfo.getServer_id());
		
		mapParam.put("goods_id",mPayInfo.getGoods_id());
		mapParam.put("goods_count",mPayInfo.getGoods_count());
		mapParam.put("goods_price",mPayInfo.getPrice());
		
	
		StringBuffer sb=new StringBuffer("");
		Iterator<String> it = mapParam.keySet().iterator();
		while(it.hasNext()){
			sb.append(mapParam.get(it.next()));
		}
		mapParam.put("sign", MD5.getmd5(sb.toString()));
		return mapParam;
	}
	//与支付宝通信参数
	private String getNewOrderInfo(int Position) {
		StringBuilder sb = new StringBuilder();
		sb.append("partner=\"");
		sb.append(Keys.DEFAULT_PARTNER);
		sb.append("\"&subject=\"");
		sb.append(mPayInfo.getProductName()); //sb.append(sProducts[position].subject); 
		//sb.append("\"&body=\"");
		//sb.append("text2");//sb.append(sProducts[position].body);
		sb.append("\"&total_fee=\"");
		sb.append(mPayInfo.getPrice()); //sb.append(sProducts[position].price.replace("一口价:", ""));
		sb.append("\"&notify_url=\"");
		// 网址需要做URL编码
		sb.append(URLEncoder.encode(payUrl));
		sb.append("\"&service=\"mobile.securitypay.pay");

		sb.append("\"&_input_charset=\"UTF-8");
//		sb.append("\"&return_url=\"");
//		sb.append(URLEncoder.encode("http://m.alipay.com"));
		sb.append("\"&payment_type=\"1");
		sb.append("\"&seller_id=\"");
		sb.append(Keys.DEFAULT_SELLER);

		// 如果show_url值为空，可不传
		// sb.append("\"&show_url=\"");
		sb.append("\"&it_b_pay=\"1m");
		sb.append("\"");

		return new String(sb);
	}
	

	private String getSignType() {
		return "sign_type=\"RSA\"";
	}

	@Override
	public void onItemClick(AdapterView<?> adapter, View v, final int channel, long arg3) {
		if (channel == 0){		
				new Thread(new Runnable() {
					
					@Override
					public void run() {	
						try {
							HttpResponse resp = NETUtil.sendHttpPostByJosnParam(payOrderUrl, getPayOrderParam());
			
							JSONObject recvjosn= new JSONObject(resp.getContent());	
							Log.e("SL","recv Josn-------->"+ recvjosn.toString());
							
							if (recvjosn.getBoolean("success") == true)
							{  
								JSONObject data = recvjosn.getJSONObject("data");
								String out_trade_no = data.getString("OrderNo");
								//Log.e("SL","order"+data.getString("OrderNo"));	
								
								String info = getNewOrderInfo(channel);//购买信息
								info =info+("&out_trade_no=\"")+out_trade_no+("\"");//拼接订单信息
								String sign = Rsa.sign(info, Keys.PRIVATE);
								sign = URLEncoder.encode(sign);
								info += "&sign=\"" + sign + "\"&" + getSignType();//设置签名
								Log.e("SL", info+"--------------------->start pay");
								
								
								AliPay alipay = new AliPay(PayActivity.this, mHandler);
								
								//设置为沙箱模式，不设置默认为线上环境
								//alipay.setSandBox(true);

								String result = alipay.pay(info);

								Log.e("SL", "result = " + result);
								Message msg = new Message();
								msg.what = 1; //RQF_PAY;
								msg.obj = result;
								mHandler.sendMessage(msg);
							}
							
						} catch (Exception e) {
							Toast.makeText(PayActivity.this, "支付异常，请检查网络",Toast.LENGTH_SHORT);
							e.printStackTrace();
						} 
	
					}
				}).start();
					
		}
		
	}
	

}
