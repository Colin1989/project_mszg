/****************************************************************************
 *** pp助手
 ****************************************************************************/
#import "ChannelPP.h"
#import "Buffer.h"
#import "cocos2d.h"
#import <CommonCrypto/CommonDigest.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include "Config.h"
#include "Channel.h"

@implementation ChannelPP

-(void)dealloc {
    [super dealloc];
    [_uid release];
    [_token release];
}

-(void)showErrorTip:(NSString*)title tip:(NSString*)tipStr {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:tipStr
                                                  delegate:nil
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
    [alert show];
}

-(BOOL)initSDK:(NSString*)initMsg {
    
    /**
     *必须写在程序window初始化之后。详情请commad + 鼠标左键 点击查看接口注释
     *初始化应用的AppId和AppKey。从开发者中心游戏列表获取（https://pay.25pp.com）
     *设置是否打印日志在控制台,[发布时请务必改为NO]
     *设置充值页面初始化金额,[必须为大于等于1的整数类型]
     *设置游戏客户端与游戏服务端链接方式是否为长连接【如果游戏服务端能主动与游戏客户端交互。例如发放道具则为长连接。此处设置影响充值并兑换的方式】
     *用户注销后是否自动push出登陆界面
     *是否开放充值页面【操作在按钮被弹窗】
     *若关闭充值响应的提示语
     *初始化SDK界面代码
     */
    [[PPAppPlatformKit sharedInstance] setAppId:4703 AppKey:@"c689bbd27d2e7674f113c13c0f4208f8"];
    
    [[PPAppPlatformKit sharedInstance] setDelegate:self];
    [[PPAppPlatformKit sharedInstance] setIsNSlogData:NO];// 客户端日志 上线要改为 NO
    [[PPAppPlatformKit sharedInstance] setRechargeAmount:30];
    [[PPAppPlatformKit sharedInstance] setIsLongComet:YES];
    [[PPAppPlatformKit sharedInstance] setIsLogOutPushLoginView:YES];
    [[PPAppPlatformKit sharedInstance] setIsOpenRecharge:YES];//是否开启充值
    [[PPAppPlatformKit sharedInstance] setCloseRechargeAlertMessage:@"封测期间不提供充值"];
 //   [[PPAppPlatformKit sharedInstance] setDelegate:_viewController];
    
    [PPUIKit setIsDeviceOrientationLandscapeLeft:YES];
    [PPUIKit setIsDeviceOrientationLandscapeRight:YES];
    [PPUIKit setIsDeviceOrientationPortrait:YES];
    [PPUIKit setIsDeviceOrientationPortraitUpsideDown:YES];
    [[PPUIKit sharedInstance] checkGameUpdate];
    return YES;
}

-(BOOL)loginSDK:(NSString*)loginMsg {
    [[PPAppPlatformKit sharedInstance] showLogin];
    return YES;
}

-(BOOL)switchSDK:(NSString*)switchMsg {
    [[PPAppPlatformKit sharedInstance] showCenter];
    return YES;
}

-(BOOL)paySDK:(NSDictionary*)payDict {
   
    NSString *roleId = [payDict objectForKey:@"role_id"];
 

    NSString *goodsPrice = [payDict objectForKey:@"goods_price"];
 
    NSString *goodsName = [payDict objectForKey:@"goods_name"];


    NSString * billNO= [self getApplyOrderNoCheckParams:payDict] ;
    if(!billNO){
        //订单获取失败
        NSLog(@"订单获取失败");
        return NO;
    }
    //NSString * billNO=@"3434354345325";
    [[PPAppPlatformKit sharedInstance] exchangeGoods:[goodsPrice intValue]
                                              BillNo:billNO
                                              BillTitle:goodsName
                                              RoleId:roleId
                                              ZoneId:0];

    return YES;
}
-(NSString *)getApplyOrderNoCheckParams:(NSDictionary*)payDict{
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
    [buff appendString:[self getAppId]];
    [buff appendString:[self getAppKey]];
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
                         initWithFormat:@"app_id=%@&app_key=%@&uid=%@&role_id=%@&server_id=%@&goods_id=%@&goods_count=%@&goods_price=%@&sign=%@",[self getAppId],[self getAppKey],uid,role_id,server_id,goods_id,goods_count,goods_price,Mstr];
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
-(BOOL)exitSDK:(NSString*)exitMsg {
    return YES;
}

-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@"20051"];
}

-(NSString*)getUid {
    return _uid;
}

-(NSString*)getToken {
    return _token;
}
-(NSString *)getAppId{
    return @"30001";
}
-(NSString *)getAppKey{
    return @"8a808023468dd22001468dd220270000";
}
-(void)sendMessage:(NSNumber*)type msg:(NSString*)msgStr {
}
#pragma amrk - <callBack> -
/**
 * @brief   余额大于所购买道具
 * @param   INPUT   paramPPPayResultCode       接口返回的结果编码
 * @return  无返回
 */
- (void)ppPayResultCallBack:(PPPayResultCode)paramPPPayResultCode
{
    BOOL res = NO;
    NSString * title = nil;
    NSString * messsage = nil;
    if(paramPPPayResultCode == PPPayResultCodeSucceed){
        title = @"购买成功回调";
        messsage = @"发放道具吧";
        res = YES;
    }else if(paramPPPayResultCode == PPPayResultCodeForbidden){
        title = @"购买失败";
        messsage = @"该用户禁止访问";
    }else if(paramPPPayResultCode == PPPayResultCodeUserNotExist){
        title = @"购买失败";
        messsage = @"该用户不存在";
    }else if(paramPPPayResultCode == PPPayResultCodeParamLost){
        title = @"购买失败";
        messsage = @"必选参数丢失";
    }else if(paramPPPayResultCode == PPPayResultCodeNotSufficientFunds){
        title = @"购买失败";
        messsage = @"PP币余额不足";
    }else if(paramPPPayResultCode == PPPayResultCodeGameDataNotExist){
        title = @"购买失败";
        messsage = @"该游戏数据不存在";
    }else if(paramPPPayResultCode == PPPayResultCodeDeveloperNotExist){
        title = @"购买失败";
        messsage = @"开发者数据不存在";
    }else if(paramPPPayResultCode == PPPayResultCodeZoneNotExist){
        title = @"购买失败";
        messsage = @"该区数据不存在";
    }else if(paramPPPayResultCode == PPPayResultCodeSystemError){
        title = @"购买失败";
        messsage = @"系统错误";
    }else if(paramPPPayResultCode == PPPayResultCodeFail){
        title = @"购买失败";
        messsage = @"购买失败";
    }else if(paramPPPayResultCode == PPPayResultCodeCommunicationFail){
        title = @"购买失败";
        messsage = @"";//与开发商服务器通信失败，如果长时间未收到商品请联系客服：电话：020-38276673　 QQ：800055602
    }else if(paramPPPayResultCode == PPPayResultCodeUntreatedBillNo){
        title = @"购买失败";
        messsage = @"";//开发商服务器未成功处理该订单，如果长时间未收到商品请联系客服：电话：020-38276673　 QQ：800055602
    }else if(paramPPPayResultCode == PPPayResultCodeCancel){
        title = @"购买失败";
        messsage = @"购买取消";
    }else if(paramPPPayResultCode == PPPayResultCodeUserOffLine){
        title = @"购买失败";
        messsage = @"非法访问";//可能用户已经下线
    }
    NSLog(@"%@",title);
    NSLog(@"%@",messsage);
    if (NO == res) {
        [self showErrorTip:title tip:messsage];
    }
}


/**
 * @brief   验证更新成功后
 * @noti    分别在非强制更新点击取消更新和暂无更新时触发回调用于通知弹出登录界面
 * @return  无返回
 */
- (void)ppVerifyingUpdatePassCallBack
{
    
    NSString * title = @"验证更新成功回调";
    NSString * messsage = @"请稍后，请调用显示登录界面";
    NSLog(@"%@",title);
    NSLog(@"%@",messsage);
    [Channel runScripts:NO isShowLoginFlag:YES];
}

/**
 * @brief   登录成功回调【任其一种验证即可】
 * @param   INPUT   paramStrToKenKey       字符串token
 * @return  无返回
 */
- (void)ppLoginStrCallBack:(NSString *)paramStrToKenKey
{
    //获取帐号的安全级别[登录验证成功时必须调用]
    [[PPAppPlatformKit sharedInstance] getUserInfoSecurity];
    
    NSString * title = @"登录成功回调";
    NSString * messsage = [NSString stringWithFormat:@"请在30s内用token:%@验证信息,注释部分为验证DEMO,获取帐号的安全级别[登录验证成功时必须调用]",paramStrToKenKey];
    NSLog(@"%@",title);
    NSLog(@"%@",messsage);
    //第一步，创建URL
    
    NSURL *url = [NSURL URLWithString:[Config getString:@"account_server_url"]];
    //第二步，创建请求
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSData *data = [self getLoginCheckParam:paramStrToKenKey] ;
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(!received){
        NSLog(@"请求失败%@",[error description]);
        [self showErrorTip:@"提示"
                       tip:[NSString stringWithFormat:@"%@ code:%d", @"连接账号服务器失败", [error code]]];
        return;
    }
    
    //NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *responsejson = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    if(0 == [[responsejson objectForKey:@"success"] integerValue]){
        NSLog(@"验证失败");
        [self showErrorTip:@"提示"
                       tip:@"账号服务器验证失败"];
        return;
    }
    NSDictionary *datajson =[responsejson objectForKey:@"data"];
    _uid = [datajson objectForKey:@"uid"];
    [_uid retain];
    _token = [datajson objectForKey:@"token"];
    [_token retain];
    if([[PPAppPlatformKit sharedInstance] loginState] == 1){
        [Channel runScripts:YES isShowLoginFlag:NO];
    }
}
/**
 *合成服务器验证数据 getLoginCheckParam
 */
-(NSData *)getLoginCheckParam:(NSString *)sid
{
    NSString *sidTemp = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)sid, NULL, NULL, kCFStringEncodingUTF8);
    NSString * buff =[[NSString alloc]initWithFormat:@"%@%@%@%@",
                      [self getAppId],[self getAppKey],[self getChannelId],sidTemp];
    NSLog(@"加密参数%@",buff);
    unsigned char result[16];
    const char *cStr = [buff UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        
        [Mstr appendFormat:@"%02X",result[i]];
        
    }
    NSString * param = [[NSString alloc] initWithFormat:@"app_id=%@&app_key=%@&channel_id=%@&sid=%@&sign=%@",
                        [self getAppId],[self getAppKey],[self getChannelId],sidTemp,Mstr];
    NSLog(@"请求信息：%@",param );
    return [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
}
/**
 * @brief   关闭Web页面后的回调
 * @param   INPUT   paramPPWebViewCode    接口返回的页面编码
 * @return  无返回
 */
- (void)ppCloseWebViewCallBack:(PPWebViewCode)paramPPWebViewCode
{
    NSString * title = nil;
    if (paramPPWebViewCode == PPWebViewCodeRecharge) {
        title = @"关闭充值页面回调";
    }else if (paramPPWebViewCode == PPWebViewCodeRechargeAndExchange) {
        title = @"关闭充值并且兑换页面回调";
    }else if (paramPPWebViewCode == PPWebViewCodeRechargeAndExchange) {
        title = @"关闭WEB其他页面回调";
    }
    NSLog(@"关闭Web页面:%@",title);
}

/**
 * @brief   关闭SDK客户端页面后的回调
 * @param   INPUT   paramPPPageCode       接口返回的页面编码
 * @return  无返回
 */
- (void)ppClosePageViewCallBack:(PPPageCode)paramPPPageCode
{
    
    NSString * title = nil;
    if (paramPPPageCode == PPLoginViewPageCode) {
        title = @"关闭登录页面回调";
        [Channel runScripts:NO isShowLoginFlag:NO];
    }else if (paramPPPageCode == PPRegisterViewPageCode) {
        title = @"关闭注册页面回调";
    }else if (paramPPPageCode == PPOtherViewPageCode) {
        title = @"关闭其他页面回调";
    }
    NSLog(@"关闭SDK客户端页面:%@",title);
}
/**
 * @brief   注销后的回调
 * @return  无返回
 */
- (void)ppLogOffCallBack
{
    NSLog(@"注销回调");
    [Channel runScripts:NO isShowLoginFlag:NO];
}

@end
