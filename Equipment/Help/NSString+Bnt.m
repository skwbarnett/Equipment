//
//  NSString+Bnt.m
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/28.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "NSString+Bnt.h"

@implementation NSString (Bnt)

- (NSData *)hexToBytes{
    NSMutableData *data = [NSMutableData data];
    int idx;
    for (idx = 0; idx + 2 <= self.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString *hexStr = [self substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

// data -> hex
+ (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

// Hex -> String
- (NSString *)stringFromHexString { //
    
    char *myBuffer = (char *)malloc((int)[self length] / 2 + 1);
    bzero(myBuffer, [self length] / 2 + 1);
    for (int i = 0; i < [self length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [self substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

//  Hex -> 10
- (NSString *)hexSwitchString{
    unsigned long string = strtoul([self UTF8String], 0, 16);
    return @(string).stringValue;
}

- (NSString *)hexSwitchString2Char{
    NSString *hex = [self hexSwitchString];
    if (hex.length == 1) {
        return [@"0" stringByAppendingString:hex];
    }
    return hex;
}

//  切分字符串，每个子字符串有两个字母
- (NSMutableArray *)stringCarveBy2Character{
    if (self.length < 2) {
        return nil;
    }
    NSMutableArray *subStrMArr = [NSMutableArray array];
    NSRange range = NSMakeRange(0, 2);
    for (int i = 0; i < self.length - 1; i += 2) {
        NSString *subStr = [self substringWithRange:range];
        [subStrMArr addObject:subStr];
        range.location += 2;
    }
    return subStrMArr;
}

@end
