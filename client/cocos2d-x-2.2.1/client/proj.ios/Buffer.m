//
//  TRBuffer.m
//  PPHelper
//
//  Created by chenjunhong on 13-1-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "Buffer.h"

@implementation Buffer

@synthesize body = _body;

+ (Buffer*)defaultTRBuffer
{    
    Buffer *buff = [[[Buffer alloc] initWithBuffLen:1024*10] autorelease];
    return buff;
}

- (Buffer*)initWithBuffLen:(unsigned int)len
{    
    if ([super init]) {
        
        _body = malloc(len);
        memset(_body, 0, len);
        _pNow = _body + sizeof(unsigned int);
        
        _freeTag = YES;
    }
    
    return self;
}

- (Buffer*)initWithBuffNoCopy:(char*)buff
{    
    if ([super init]) {
        
        _pNow = _body = buff;
    }

    return self;
}

- (void)dealloc
{
//    NSLog(@"DEALLOC: %@", [self class]);
    
    if (_freeTag) {
        free(_body);
    }
    
    [super dealloc];
}

- (void)writeInt8:(char)val
{
    *(char*)_pNow = val;
//    memcpy(_pNow, &val, sizeof(char));
    _pNow += sizeof(char);
}

- (void)writeInt16:(short)val
{
    *(short*)_pNow = val;
//    memcpy(_pNow, &val, sizeof(short));
    _pNow += sizeof(short);
}

- (void)writeInt32:(int)val
{
    *(int*)_pNow = val;
//    memcpy(_pNow, &val, sizeof(int));
    _pNow += sizeof(int);
}

- (void)writeInt64:(long long)val
{
    *(long long*)_pNow = val;
//    memcpy(_pNow, &val, sizeof(long long));
    _pNow += sizeof(long long);
}

- (void)writeString:(NSString *)val
{
    const char *string = [val UTF8String];
    short len = strlen(string)+1;
    memcpy(_pNow, string, len);
    _pNow += len;
}

- (void)writeMem:(char*)in_mem len:(unsigned int)len
{
    memcpy(_pNow, in_mem, len);
    _pNow += len;
}

- (void)writeLen
{
    unsigned int len = [self bufferLen];
    *(unsigned int*)_body = len;
//    memcpy(_body, &len, sizeof(unsigned int));
}

- (char)readInt8
{
    char ret = *(char*)_pNow;
    _pNow += sizeof(char);
    return ret;
}

- (short)readInt16
{
    short ret = *(short*)_pNow;
    _pNow += sizeof(short);
    return ret;
}

- (int)readInt32
{
    int ret = *(int*)_pNow;
    _pNow += sizeof(int);
    return ret;
}

- (float)readFloat32
{
    float ret = *(float*)_pNow;
    _pNow += sizeof(float);
    return ret;
}

- (long long)readInt64
{
    long long ret = *(long long*)_pNow;
    _pNow += sizeof(long long);
    return ret;
}

- (NSString*)readString
{
    short len = strlen(_pNow);
    NSString *str = [NSString stringWithUTF8String:_pNow];
    _pNow += len+1;
    return str;
}

- (void)readMem:(char*)out_mem len:(unsigned int)len
{
	memcpy(out_mem, _pNow, len);
    _pNow += len;
}

- (unsigned int)bufferLen
{
    return _pNow - _body;
}


@end
