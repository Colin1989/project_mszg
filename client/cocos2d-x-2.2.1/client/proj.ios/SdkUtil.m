#import "SdkUtil.h"
#import "AppController.h"

NSString *appId=@"30001";
NSString *appKey=@"8a808023468dd22001468dd220270000";
static UIActivityIndicatorView * s_AidV;

@implementation SdkUtil

+(NSString *)applyOrderNo:(NSDictionary*)payDict{
    NSString *uid = [payDict objectForKey:@"uid"];
    NSString *server_id = [payDict objectForKey:@"server_id"];
    NSString *role_id = [payDict objectForKey:@"role_id"];
    NSString *goods_id = [payDict objectForKey:@"goods_id"];
    NSString *goods_price = [payDict objectForKey:@"goods_price"];
    NSString *goods_count = [payDict objectForKey:@"goods_count"];
  
    //第一步，创建URL
    
    NSURL *url = [NSURL URLWithString:[Config getString:@"pay_order_url"]];
    
    //第二步，创建请求
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSMutableString * buff = [[NSMutableString alloc] init];
    [buff appendString:appId];
    [buff appendString:appKey];
    [buff appendString:goods_count];
    [buff appendString:goods_id];
    [buff appendString:goods_price];
    [buff appendString:role_id];
    [buff appendString:server_id];
    [buff appendString:uid];
    NSLog(@"加密参数%@",buff);
    unsigned char result[16];
    const char *cStr = [buff UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        
        [Mstr appendFormat:@"%02X",result[i]];
        
    }
    
    NSString * params = [[NSString alloc]
                         initWithFormat:@"app_id=%@&app_key=%@&uid=%@&role_id=%@&server_id=%@&goods_id=%@&goods_count=%@&goods_price=%@&sign=%@",appId,appKey,uid,role_id,server_id,goods_id,goods_count,goods_price,Mstr];
    NSData * data =[params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];;
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(!received){
        NSLog(@"请求失败%@",[error description]);
        return @"-1";
    }
    
    //NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *responsejson = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    // NSDictionary * responsedata =[responsejson objectForKey:@"data"];
    return [[responsejson objectForKey:@"data"] objectForKey:@"OrderNo"];
    //

}
+(BOOL) postParameterToServer:(NSDictionary*)parameterDict
                          url:(NSString *)urlstr
                        error:(NSError*)error {
    NSMutableString* stringBuff =[[NSMutableString alloc]init];
    NSMutableString* sendData =[[NSMutableString alloc]init];
    NSArray *keys = [parameterDict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryId in sortedArray) {
        NSString *value =[parameterDict objectForKey:categoryId];
        
        [sendData appendFormat:@"%@=%@&",categoryId,value];
        //[stringBuff appendString:value];
        //urlencode
        NSString * urlEncodeStr = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [stringBuff appendString:urlEncodeStr];
        /*
        NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL,
                                                                                      (CFStringRef)value,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,%#[]",
                                                                                      kCFStringEncodingUTF8 );
        [stringBuff appendString:encodedString];
         */
    }
    NSLog(@"加密参数%@",stringBuff);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    unsigned char result[16];
    const char *cStr = [[NSString stringWithString:stringBuff] UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        
        [Mstr appendFormat:@"%02X",result[i]];
        
    }
    [sendData appendFormat:@"sign=%@",Mstr];
    NSLog(@"请求参数%@",sendData);
    NSURL *url = [NSURL URLWithString:urlstr];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3000];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    //第三步，连接服务器
    NSData* received= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if(!received){
        NSLog(@"请求失败%@",[error description]);
        [self showAlertTip:@"提示"
                       tip:[NSString stringWithFormat:@"%@ code:%d", @"连接服务器失败", [error code]]];
        return NO;
    }
    
    //NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *responsejson = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    if(0 == [[responsejson objectForKey:@"success"] integerValue]){
        NSLog(@"验证失败");
        [self showAlertTip:@"提示"
                       tip:[NSString stringWithFormat:@"服务器错误:%@",[responsejson objectForKey:@"code"]]];
        return NO;
    }
    return YES;

}
+(NSDictionary*)postCheckLoginState:(NSDictionary*)dictData error:(NSError*)error{
    NSMutableDictionary* mdict =[NSMutableDictionary dictionaryWithDictionary:dictData];
    NSMutableString* stringBuff =[[NSMutableString alloc]init];
    NSMutableString* sendData =[[NSMutableString alloc]init];
    [mdict setValue:appId forKey:@"app_id"];
    [mdict setValue:appKey forKey:@"app_key"];
    NSArray *keys = [mdict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryId in sortedArray) {
        NSString *value =[mdict objectForKey:categoryId];
        [stringBuff appendString:value];
        [sendData appendFormat:@"%@=%@&",categoryId,value];
    }
    NSLog(@"加密参数%@",stringBuff);
    unsigned char result[16];
    const char *cStr = [[NSString stringWithString:stringBuff] UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        
        [Mstr appendFormat:@"%02X",result[i]];
        
    }
    [sendData appendFormat:@"sign=%@",Mstr];
    NSLog(@"请求参数%@",sendData);
    NSURL *url = [NSURL URLWithString:[Config getString:@"account_server_url"]];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    //第三步，连接服务器
    NSData* received= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(!received){
        NSLog(@"请求失败%@",[error description]);
        [self showAlertTip:@"提示"
                       tip:[NSString stringWithFormat:@"%@ code:%d", @"连接账号服务器失败", [error code]]];
        return nil;
    }
    
    //NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *responsejson = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    if(0 == [[responsejson objectForKey:@"success"] integerValue]){
        NSLog(@"验证失败");
        [self showAlertTip:@"提示"
                       tip:[NSString stringWithFormat:@"账号服务器验证失败:%@",[responsejson objectForKey:@"code"]]];
        return nil;
    }
    return  [responsejson objectForKey:@"data"];
    
}
+(void)showAlertTip:(NSString*)title tip:(NSString*)tipStr {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:tipStr
                                                  delegate:nil
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
    [alert show];
}

+(void)showLoadingCirle
{
    if (s_AidV == nil)
    {
        s_AidV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        s_AidV.frame = CGRectMake(0, 0, 30, 30);
        CGRect rx = [UIScreen mainScreen].bounds;
        [s_AidV setCenter:CGPointMake(rx.size.width/2,rx.size.height/2)];
        
        s_AidV.hidesWhenStopped= NO;
        s_AidV.color = [UIColor whiteColor];
        
        UIView * rootview = [AppController getIntanceView];
        [rootview  addSubview:s_AidV];
        [s_AidV startAnimating];
    }
    [s_AidV setHidden:FALSE];
}

+(void) closeLoadingCirle
{
    if(s_AidV){
        [s_AidV setHidden:TRUE];
    }
}


@end
