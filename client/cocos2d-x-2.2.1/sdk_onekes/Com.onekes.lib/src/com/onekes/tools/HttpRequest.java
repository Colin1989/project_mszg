package com.onekes.tools;



import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.Map;

public class HttpRequest {
	private String defaultContentEncoding;  
	   
    public HttpRequest() {  
        this.defaultContentEncoding = Charset.defaultCharset().name();  
    }  
   
    /** 
     * 鍙戦?GET璇锋眰 
     *  
     * @param urlString 
     *            URL鍦板潃 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    public HttpResponse sendGet(String urlString) throws IOException {  
        return this.send(urlString, "GET", null, null);  
    }  
   
    /** 
     * 鍙戦?GET璇锋眰 
     *  
     * @param urlString 
     *            URL鍦板潃 
     * @param params 
     *            鍙傛暟闆嗗悎 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    public HttpResponse sendGet(String urlString, Map<String, String> params)  
            throws IOException {  
        return this.send(urlString, "GET", params, null);  
    }  
   
    /** 
     * 鍙戦?GET璇锋眰 
     *  
     * @param urlString 
     *            URL鍦板潃 
     * @param params 
     *            鍙傛暟闆嗗悎 
     * @param propertys 
     *            璇锋眰灞炴? 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    public HttpResponse sendGet(String urlString, Map<String, String> params,  
            Map<String, String> propertys) throws IOException {  
        return this.send(urlString, "GET", params, propertys);  
    }  
   
    /** 
     * 鍙戦?POST璇锋眰 
     *  
     * @param urlString 
     *            URL鍦板潃 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    public HttpResponse sendPost(String urlString) throws IOException {  
        return this.send(urlString, "POST", null, null);  
    }  
   
    /** 
     * 鍙戦?POST璇锋眰 
     *  
     * @param urlString 
     *            URL鍦板潃 
     * @param params 
     *            鍙傛暟闆嗗悎 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    public HttpResponse sendPost(String urlString, Map<String, String> params)  
            throws IOException {  
        return this.send(urlString, "POST", params, null);  
    }  
   
    /** 
     * 鍙戦?POST璇锋眰 
     *  
     * @param urlString 
     *            URL鍦板潃 
     * @param params 
     *            鍙傛暟闆嗗悎 
     * @param propertys 
     *            璇锋眰灞炴? 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    public HttpResponse sendPost(String urlString, Map<String, String> params,  
            Map<String, String> propertys) throws IOException {  
        return this.send(urlString, "POST", params, propertys);  
    }  
   
    /** 
     * 鍙戦?HTTP璇锋眰 
     *  
     * @param urlString 
     * @return 鍝嶆槧瀵硅薄 
     * @throws IOException 
     */  
    private HttpResponse send(String urlString, String method,  
            Map<String, String> parameters, Map<String, String> propertys)  
            throws IOException {  
        HttpURLConnection urlConnection = null;  
   
        if (method.equalsIgnoreCase("GET") && parameters != null) {  
            StringBuffer param = new StringBuffer();  
            int i = 0;  
            for (String key : parameters.keySet()) {  
                if (i == 0)  
                    param.append("?");  
                else  
                    param.append("&");  
                param.append(key).append("=").append(parameters.get(key));  
                i++;  
            }  
            urlString += param;  
        }  
        URL url = new URL(urlString);  
        urlConnection = (HttpURLConnection) url.openConnection();  
   
        urlConnection.setRequestMethod(method);  
        urlConnection.setDoOutput(true);  
        urlConnection.setDoInput(true);  
        urlConnection.setUseCaches(false);  
        urlConnection.setConnectTimeout(5000);
   
        if (propertys != null)  
            for (String key : propertys.keySet()) {  
                urlConnection.addRequestProperty(key, propertys.get(key));  
            }  
   
        if (method.equalsIgnoreCase("POST") && parameters != null) {  
            StringBuffer param = new StringBuffer();  
            for (String key : parameters.keySet()) {  
                param.append("&");  
                param.append(key).append("=").append(parameters.get(key));  
            }  
            urlConnection.getOutputStream().write(param.toString().getBytes());  
            urlConnection.getOutputStream().flush();  
            urlConnection.getOutputStream().close();  
        }  
   
        return this.makeContent(urlString, urlConnection);  
    }  
   
    /** 
     * 寰楀埌鍝嶅簲瀵硅薄 
     *  
     * @param urlConnection 
     * @return 鍝嶅簲瀵硅薄 
     * @throws IOException 
     */  
    private HttpResponse makeContent(String urlString,  
            HttpURLConnection urlConnection) throws IOException {  
    	
    	long limitSize = Long.MAX_VALUE;
		long gotSize = 0;
		
    	HttpResponse httpResponser = new HttpResponse();  
        try {  
            InputStream in = urlConnection.getInputStream();  
            
            byte[] buf = new byte[4096];
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            int numRead = 0;
//			int numWrite = 0;
            while (true) {          
                numRead = in.read(buf);
				if (numRead <= 0) {
					break;
				}
				out.write(buf, 0, numRead);
				
				gotSize += numRead;
				if (gotSize >= limitSize) {
					break;
				}
            }   
   
            String ecod = urlConnection.getContentEncoding();  
            if (ecod == null)  
                ecod = this.defaultContentEncoding;  
   
            httpResponser.urlString = urlString;  
   
            httpResponser.defaultPort = urlConnection.getURL().getDefaultPort();  
            httpResponser.file = urlConnection.getURL().getFile();  
            httpResponser.host = urlConnection.getURL().getHost();  
            httpResponser.path = urlConnection.getURL().getPath();  
            httpResponser.port = urlConnection.getURL().getPort();  
            httpResponser.protocol = urlConnection.getURL().getProtocol();  
            httpResponser.query = urlConnection.getURL().getQuery();  
            httpResponser.ref = urlConnection.getURL().getRef();  
            httpResponser.userInfo = urlConnection.getURL().getUserInfo();  
   
            httpResponser.streamContent = out;
//            httpResponser.content = new String(out.toByteArray(), ecod);  
            httpResponser.contentEncoding = ecod;  
            httpResponser.code = urlConnection.getResponseCode();  
            httpResponser.message = urlConnection.getResponseMessage();  
            httpResponser.contentType = urlConnection.getContentType();  
            httpResponser.method = urlConnection.getRequestMethod();  
            httpResponser.connectTimeout = urlConnection.getConnectTimeout();  
            httpResponser.readTimeout = urlConnection.getReadTimeout();  
   
            return httpResponser;  
        } catch (IOException e) {  
            throw e;  
        } finally {  
            if (urlConnection != null)  
                urlConnection.disconnect();  
        }  
    }  
   
    /** 
     * 榛樿鐨勫搷搴斿瓧绗﹂泦 
     */  
    public String getDefaultContentEncoding() {  
        return this.defaultContentEncoding;  
    }  
   
    /** 
     * 璁剧疆榛樿鐨勫搷搴斿瓧绗﹂泦 
     */  
    public void setDefaultContentEncoding(String defaultContentEncoding) {  
        this.defaultContentEncoding = defaultContentEncoding;  
    }  
}
