/*
 * Copyright (C) 2010 The MobileSecurePay Project
 * All right reserved.
 * author: shiqun.shi@alipay.com
 * 
 *  提示：如何获取安全校验码和合作身份者id
 *  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
 *  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
 *  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
 */

package com.onekes.lib;

//
// 请参考 Android平台安全支付服务(msp)应用开发接口(4.2 RSA算法签名)部分，并使用压缩包中的openssl RSA密钥生成工具，生成一套RSA公私钥。
// 这里签名时，只需要使用生成的RSA私钥。
// Note: 为安全起见，使用RSA私钥进行签名的操作过程，应该尽量放到商家服务器端去进行。
public final class Keys {

	//合作身份者id，以2088开头的16位纯数字
	public static final String DEFAULT_PARTNER = "2088111176646698";

	//收款支付宝账号
	public static final String DEFAULT_SELLER = "27779590@qq.com";

	//商户私钥，自助生成
	public static final String PRIVATE = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALHNQ2VF6N9y5ZYRVzYkuaNk1y2O3XWPNYr/DLnTp03tfBhkPlxa/+wr22lWYrPecNyLIkUUBsIBW/zKkbvef5o129u3lWetelChuAzlKg6SjiGAhHv2Km2BasZrGNlvriW5H4rvaHU9beGDvrZx8NI5IdHRY3Xx+ELJHmvmW64bAgMBAAECgYEAoASiUTTX3rJjWeoFWV84C4un9QKM4U6f25ard1q7SfEgLDubvDbR+VWHRIhQkJzzail2EEFzy4q5pQsSmcgngbvkg0OI4FDqmaqgoALOKt1oNrhRL93NLbE7LUd+EpST99aAgAXVjVRfYjieuY61D9hQXHJsfp87BzWDNGFVLSECQQDfbVnIaIP9Fojg9H8jwINV1vODBhrU2BiGjAH44hdfWl6b/9+0J2OvjlteaA+sEv2VDyZG1A5/iB8197hZLqYTAkEAy7kajn+tVPhhleOZi9frWcyyxne4eF/9HybA5JM7egmS9586bOi8/yS0t6MwCrxfhldHQmcfGp4nKo6BLyh42QJATDHwooXyLUeYGo+HJFws7gNGPHLCh7/CbXAl5AjGy7/379+NHNUqC97SjhmS7q3zSPhHp3P+FcQIUNFQTym3fQJAAplF4XN3fpH8jLDukH4cnnSiAy4byE1RKUiRRVkrdQ8SNN5vHFyLrKWHOKB4SGrGvSv32L0ABJLn5P8UXsmhYQJBAM3yydblVJ9SsP4/MvrkpulcbTWasVua/GhNF5tloKUyfVwKiNOQJvJUqLRgusEJl7wDnEnhFvWFW+mKpoT+lyM=";

	public static final String PUBLIC = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB";
	//public static final String PUBLIC = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCeAtrNOk0Ihq4+AlQqPzFn/5MEZudvsK7IPUucdNL4r7lCS/JvZmPSbMfHsBPvMWHJhHhUui2FVGxE7EoD2axx37LD0glIvwJdIGCdxm6AZ8zHvS826qYhI1HzzpY2RQHeECyUNs6ZMNTA1c6BmuFq0kQVMl62MPUGtMMR+9dwMwIDAQAB";

	
}
