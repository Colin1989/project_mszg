/****************************************************************************
*** 读取json配置文件
****************************************************************************/
#import "Config.h"

static NSDictionary *sConfig = nil;      // 当前渠道配置

@implementation Config

+(void)clearCache:(NSString*)cacheDir {
    NSString *curAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [(NSString*)[pathArray objectAtIndex:0] stringByAppendingString:@"/"];
    NSString *appVersionPath = [NSString stringWithFormat:@"%@%@", documentsDirectory, @"appversion.bin"];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:appVersionPath];
    if (nil == fileHandler) {
        [[NSFileManager defaultManager] createFileAtPath:appVersionPath contents:nil attributes:nil];
        [fileHandler writeData:[curAppVersion dataUsingEncoding:NSUTF8StringEncoding]];
        return;
    }
    NSString *oldAppVersion = [[NSString alloc] initWithData:[fileHandler readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    if ([curAppVersion isEqualToString:oldAppVersion]) {
        return;
    }
    [fileHandler writeData:[curAppVersion dataUsingEncoding:NSUTF8StringEncoding]];
}

+(void)loadConfigFile:(NSString*)fileName firstPath:(NSString*)myFirstPath tagName:(NSString*)myTagName {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [(NSString*)[pathArray objectAtIndex:0] stringByAppendingString:@"/"];
    NSString *firstPath = [[documentsDirectory stringByAppendingString:myFirstPath] stringByAppendingString:fileName];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:firstPath];
    if (nil == fileHandle) {
        NSString *defaultPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultPath];
    }
    if (nil == fileHandle) {
        return;
    }
    NSData *data = [fileHandle readDataToEndOfFile];
    NSError *error = nil;
    NSDictionary *configList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    sConfig = [configList objectForKey:myTagName];
    [sConfig retain];
}

+(NSString*)getString:(NSString*)name {
    if (nil == sConfig) {
        return [[NSString alloc] initWithString:@""];
    }
    return [sConfig objectForKey:name];
}

+(NSInteger)getInteger:(NSString*)name {
    if (nil == sConfig) {
        return 0;
    }
    NSString *value = [sConfig objectForKey:name];
    return [value intValue];
}

+(NSNumber*)getNumber:(NSString*)name {
    if (nil == sConfig) {
        return 0;
    }
    NSString *value = [sConfig objectForKey:name];
    return [NSNumber numberWithFloat:[value floatValue]];
}

+(BOOL)getBool:(NSString*)name {
    if (nil == sConfig) {
        return NO;
    }
    NSString *value = [sConfig objectForKey:name];
    return [value boolValue];
}

+(NSDictionary*)getDictionary:(NSString*)name {
    if (nil == sConfig) {
        return nil;
    }
    return [sConfig objectForKey:name];
}

@end

