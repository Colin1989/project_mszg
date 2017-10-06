/****************************************************************************
*** 读取json配置文件
****************************************************************************/
@interface Config

/*
 * 清除缓存
 */
+(void)clearCache:(NSString*)cacheDir;

/*
 * 加载配置文件
 */
+(void)loadConfigFile:(NSString*)fileName firstPath:(NSString*)myFirstPath tagName:(NSString*)myTagName;

/*
 * 获取字符串
 */
+(NSString*)getString:(NSString*)name;

/*
 * 获取整数/Users/computer/Desktop/cocos2d-x-2.2.1/client/Resources/config.json
 */
+(NSInteger)getInteger:(NSString*)name;

/*
 * 获取浮点数
 */
+(NSNumber*)getNumber:(NSString*)name;

/*
 * 获取布尔值
 */
+(BOOL)getBool:(NSString*)name;

/*
 * 获取子节点
 */
+(NSDictionary*)getDictionary:(NSString*)name;

@end

