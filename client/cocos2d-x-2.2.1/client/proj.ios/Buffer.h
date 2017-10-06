//
//  TRBuffer.h
//  PPHelper
//
//  Created by chenjunhong on 13-1-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buffer : NSObject
{
    char *_body;
    char *_pNow;
    BOOL _freeTag;
}

@property (nonatomic) char *body;

+ (Buffer*)defaultTRBuffer;

- (Buffer*)initWithBuffLen:(unsigned int)len;
- (Buffer*)initWithBuffNoCopy:(char*)buff;

- (void)writeInt8:(char)val;
- (void)writeInt16:(short)val;
- (void)writeInt32:(int)val;
- (void)writeInt64:(long long)val;
- (void)writeString:(NSString*)val;
- (void)writeMem:(char*)in_mem len:(unsigned int)len;

- (char)readInt8;
- (short)readInt16;
- (int)readInt32;
- (float)readFloat32;
- (long long)readInt64;
- (NSString*)readString;
- (void)readMem:(char*)out_mem len:(unsigned int)len;

- (unsigned int)bufferLen;
- (void)writeLen;

@end
