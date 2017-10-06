package org.cocos2dx.client;

import java.util.Timer;
import java.util.TimerTask;

import org.channel.ChannelProxy;
import org.util.NETUtil;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;

import com.onekes.mszg.uc.R;


public class Logo extends Activity {
	
	public static Logo self = null;
	protected Timer timer;
	

	public boolean checkNetwork() {
		if (false == NETUtil.isNetworkAvailable(this)) {
			AlertDialog.Builder ab = new AlertDialog.Builder(this);
			ab.setMessage("未检测到网络连接");
			ab.setPositiveButton("设置", new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					Intent intent = new Intent("android.settings.SETTINGS");
					startActivityForResult(intent, 0);
				}
			});
			ab.setNegativeButton("退出", new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					System.exit(0);
				}
			});
			ab.show();
			return false;
		} else {
			return true;
		}
	}
	
	private TimerTask NextTimeTask = new TimerTask() {
		
		@Override
		public void run() {			
			ChannelProxy.getInstance().initSDK("");
		}
	};
		
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		self = this;
        if (Config.readFirstJson(this.getBaseContext(),ChannelProxy.getInstance().getChannelId()) != true ){
        	Config.readJson(this.getBaseContext(),ChannelProxy.getInstance().getChannelId());
        }

		if (!checkNetwork()) {
			return;
		}
		timer = new Timer();
		
		setContentView(R.layout.logo);
		//timer.schedule(NextTimeTask, 2000);
		timer.schedule(new TimerTask() {
			
			@Override
			public void run() {
				runOnUiThread(new Runnable() {
					@Override
					public void run() {
						if (ChannelProxy.getInstance().isNeedSplashScreen() == true)
						{
							setContentView(ChannelProxy.getInstance().splashScreenLayout());
							timer.schedule(NextTimeTask,2000);	
						}
						else{
							ChannelProxy.getInstance().initSDK("");
						}
							
					}
				});

			}
		}, 2000);
		
		/*
		if (ChannelProxy.getInstance().isNeedSplashScreen() == true){
			setContentView(ChannelProxy.getInstance().SplashScreenLayout());
			timer.schedule(new TimerTask() {
				
				@Override
				public void run() {
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							setContentView(R.layout.logo);
							timer.schedule(NextTimeTask,2000);	
						}
					});

				}
			}, 2000);
		}else {
			setContentView(R.layout.logo);
			timer.schedule(NextTimeTask, 2000);
		}
		*/
	}
	
}






