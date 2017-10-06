#import "Buffer.h"
#import <CommonCrypto/CommonDigest.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <stdlib.h>
#import <sys/types.h>
#import <arpa/inet.h>
#import "Config.h"


@interface SdkUtil :NSObject

+(NSString *)applyOrderNo:(NSDictionary*)payDict ;

+(NSDictionary*)postCheckLoginState:(NSDictionary*)dictData
                              error:(NSError*)error;

+(void)showAlertTip:(NSString*)title
                tip:(NSString*)tipStr ;

+(BOOL) postParameterToServer:(NSDictionary*)parameterDict
                          url:(NSString*)url
                        error:(NSError*)error;

+(void) showLoadingCirle;
+(void) closeLoadingCirle;

@end
