
#import "cocos2d.h"
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ChannelBase.h"

using namespace cocos2d;
 
 
@interface AppStoreIapLayer: ChannelBase<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKPaymentTransaction *m_PayTranObj;
}

-(NSString*)getChannelId;

-(NSString*)getUid;

-(NSString*)getToken;

//pay!
-(BOOL)paySDK:(NSDictionary*)payDict;


// 查询产品信息：
-(void)RequestProductData;

// 收到产品信息：
-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse *)response;

// 监听购买结果：
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

// 购买处理：
-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction;

// 完成处理：self define
- (void) completeTransaction: (SKPaymentTransaction *)transaction;


// 等待服务器确认后完成交易。
-(void)xgComplete;

// 失败处理：self
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

//
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;

//
-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;

//
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;

//
-(void)provideContent:(NSString *)product;

//
-(void)recordTransaction:(NSString *)product;

//
- (bool)restoreCompletedTransactions;



@end