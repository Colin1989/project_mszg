package com.onekes.tools;


import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;

public class HttpResponse {
	public static final String TAG = HttpResponse.class.getSimpleName();
	
	String urlString;
    int defaultPort;
    String file;
    String host;
    String path; 
    int port;
    String protocol;
    String query;
    String ref;
    String userInfo;
    String contentEncoding;
//    String content;
    String contentType;
    int code;
    String message;
    String method;  
    int connectTimeout;  
    int readTimeout;  
//    Vector<String> contentCollection;  
    ByteArrayOutputStream streamContent;
   
    public String getContent() {  
        try {
			return new String(streamContent.toByteArray(), contentEncoding);
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        return "";
    }  
   
    public String getContentType() {  
        return contentType;  
    }  
   
    public int getCode() {  
        return code;  
    }  
   
    public String getMessage() {  
        return message;  
    }  
   
//    public Vector<String> getContentCollection() {  
//        return contentCollection;  
//    }  
   
    public String getContentEncoding() {  
        return contentEncoding;  
    }  
   
    public String getMethod() {  
        return method;  
    }  
   
    public int getConnectTimeout() {  
        return connectTimeout;  
    }  
   
    public int getReadTimeout() {  
        return readTimeout;  
    }  
   
    public String getUrlString() {  
        return urlString;  
    }  
   
    public int getDefaultPort() {  
        return defaultPort;  
    }  
   
    public String getFile() {  
        return file;  
    }  
   
    public String getHost() {  
        return host;  
    }  
   
    public String getPath() {  
        return path;  
    }  
   
    public int getPort() {  
        return port;  
    }  
   
    public String getProtocol() {  
        return protocol;  
    }  
   
    public String getQuery() {  
        return query;  
    }  
   
    public String getRef() {  
        return ref;  
    }  
   
    public String getUserInfo() {  
        return userInfo;  
    } 
    
    public byte[] getResData() {
    	return streamContent.toByteArray();
    }
    
    public boolean isSuccess() {
    	return (code == 200 || code == 206); 
    }
}
