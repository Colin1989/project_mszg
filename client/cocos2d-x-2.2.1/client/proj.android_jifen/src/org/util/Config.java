package org.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import org.apache.http.util.EncodingUtils;
import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.res.AssetManager;
import android.preference.PreferenceManager;
import android.util.Log;

public class Config {
	private static JSONObject mConfig = null;
	
	// 閬嶅巻鏌ユ壘鎸囧畾璺緞涓嬬殑鏂囦欢
	public static File getPathFile(String path, String fileName, boolean isErgodic)
	{
		if (false == isErgodic)
		{
			File f = new File(path + "/" + fileName);
			if (null == f || !f.exists() || !f.isFile())
				return null;
			
			return f;
		}
		File dir = new File(path);
		if (null == dir || !dir.exists() || dir.isFile())
		{
			return null;
		}
		for (File subFile : dir.listFiles())
		{
			if (subFile.isDirectory())
			{
				File f = getPathFile(subFile.getAbsolutePath(), fileName, isErgodic);
				if (null != f)
				{
					return f;
				}
			}
			else if (subFile.isFile())
			{
				if (fileName.equals(subFile.getName()))
				{
					return subFile;
				}
			}
		}
		return null;
	}
	
	// 閬嶅巻鏌ユ壘绋嬪簭璧勬簮鐩綍涓嬬殑鏂囦欢
	public static InputStream getAssetFile(AssetManager mgr, String path, String fileName, boolean isErgodic) throws Exception
	{
		try
		{
			String[] subFileList = mgr.list(path);
			for (String subFileName : subFileList)
			{
				String newPath = path + "/" + subFileName;
				if (path.equals(""))
				{
					newPath = subFileName;
				}
				String[] fileList = mgr.list(newPath);
				if (0 == fileList.length)
				{
					if (fileName.equals(subFileName))
					{
						return mgr.open(newPath);
					}
				}
				else
				{
					if (isErgodic)
					{
						InputStream in = getAssetFile(mgr, newPath, fileName, isErgodic);
						if (null != in)
						{
							return in;
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	// 鍒犻櫎鏂囦欢/鏂囦欢澶�
	public static void deleteFile(File f)
	{	
		if (null != f && f.isFile())
		{
			f.delete();
			return;
		}
		if (null != f && f.isDirectory())
		{
			File[] childFiles = f.listFiles();
			if (null == childFiles || 0 == childFiles.length)
			{
				f.delete();
				return;
			}
			for (int i=0; i<childFiles.length; ++i)
			{
				deleteFile(childFiles[i]);  
			}
			f.delete();
		}
	}
	
	// 娓呴櫎缂撳瓨
	public static void clearCacheDir(Context cxt, String cacheDir) throws Exception
	{
		try
		{
			PackageInfo pi = cxt.getPackageManager().getPackageInfo(cxt.getPackageName(), 0);
			SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(cxt);
			int lastVersionCode = prefs.getInt("LAST_VERSION_CODE", 0);
			Log.e("clearCache", "last version code: "+lastVersionCode+", now version code: "+pi.versionCode);
			if (lastVersionCode == pi.versionCode)
				return;
			
			prefs.edit().putInt("LAST_VERSION_CODE", pi.versionCode).commit();
			deleteFile(new File(cxt.getFilesDir().getAbsolutePath() + "/" + cacheDir));
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	// 鍔犺浇閰嶇疆鏂囦欢
	public static void loadConfigFile(Context cxt, String fileDir, String assetDir, String confgFile, String tagName) throws Exception
	{
		if (null == mConfig)
		{
			try
			{
				String firstSearchPath = cxt.getFilesDir().getAbsolutePath() + "/" + fileDir;
				File f = getPathFile(firstSearchPath, confgFile, false);
				if (null == f)
				{
					InputStream in = getAssetFile(cxt.getAssets(), assetDir, confgFile, true);
					if (null == in)
					{
						in = getAssetFile(cxt.getAssets(), "", confgFile, false);
						Log.e("loadConfigFile", "load config from assets");
					}
					else
					{
						Log.e("loadConfigFile", "load config from assets/"+assetDir);
					}
					if (null == in)
					{
						Log.e("loadConfigFile", "load config error");
					}
					else
					{
						byte[] buffer = new byte[in.available()];
						in.read(buffer);
						in.close();
						String configString = EncodingUtils.getString(buffer, "UTF-8");
						JSONObject obj = new JSONObject(configString);
						mConfig = obj.getJSONObject(tagName);
						Log.e("loadConfigFile", configString);
					}
				}
				else
				{
					FileInputStream fin = new FileInputStream(f);
					byte[] buffer = new byte[fin.available()];
					fin.read(buffer);
					fin.close();
					String configString = EncodingUtils.getString(buffer, "UTF-8");
					JSONObject obj = new JSONObject(configString);
					mConfig = obj.getJSONObject(tagName);
					Log.e("loadConfigFile", "load config from "+firstSearchPath);
					Log.e("loadConfigFile", configString);
				}
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
	}
	
	public static String getString(String name) throws Exception
	{
		if (null == mConfig)
			return "";
		
		return mConfig.getString(name);
	}
	
	public static int getInt(String name) throws Exception
	{
		if (null == mConfig)
			return 0;
		
		return mConfig.getInt(name);
	}
	
	public static double getDouble(String name) throws Exception
	{
		if (null == mConfig)
			return 0.0f;
		
		return mConfig.getDouble(name);
	}
	
	public static boolean getBoolean(String name) throws Exception
	{
		if (null == mConfig)
			return false;
		
		return mConfig.getBoolean(name);
	}
	
	public static JSONObject getJSONObject(String name) throws Exception
	{
		if (null == mConfig)
			return null;
		
		return mConfig.getJSONObject(name);
	}
	/*
	 * 读取固定路径
	 */
	public static void readJson(Context ctx,String tagName)
	{
		String fileName = "config.json";  
		String res="";   
		try{    
		   //得到资源中的asset数据流  
		   InputStream in = ctx.getResources().getAssets().open(fileName);	  
		   int length = in.available();           
		   byte [] buffer = new byte[length];          
		  
		   in.read(buffer);              
		   in.close();  
		   res = EncodingUtils.getString(buffer, "UTF-8"); 
		   JSONObject obj = new JSONObject(res);
		   
		   mConfig = obj.getJSONObject(tagName);
		 
		   Log.e("SL2",mConfig.getString("pay_order_url"));
		   
		  }catch(Exception e){   
		      e.printStackTrace();            
		  }
	}
	
	public static  boolean readFirstJson(Context ctx,String tagName)
	{
			String fileName = ctx.getFilesDir().getAbsolutePath() + "/" + "resdir";  
			String res=""; 
			
			try{    
				   //得到资源中的asset数据流  
				   InputStream in = ctx.getResources().getAssets().open(fileName);	  
				   int length = in.available();           
				   byte [] buffer = new byte[length];          
				  
				   in.read(buffer);              
				   in.close();  
				   res = EncodingUtils.getString(buffer, "UTF-8"); 
				   JSONObject obj = new JSONObject(res);
				   
				   mConfig = obj.getJSONObject(tagName);
				   
				   Log.e("SL1",mConfig.getString("pay_order_url"));
				 
				   return true;
				  
			}catch(Exception e){   
				      e.printStackTrace();            
		    }
			return false;
	}
}