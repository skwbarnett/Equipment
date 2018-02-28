//
//  NSData+Bnt.m
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/29.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "NSData+Bnt.h"

@implementation NSData (Bnt)

//  data -> string
- (NSString *)dataSwitchString{
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return string;
}

// data -> hex
- (NSString *)convertDataToHexStr
{
    if (!self || [self length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[self length]];
    
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
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

- (NSArray *)dataSwitchHexStrArr {
    if (!self || [self length] == 0) {
        return @[];
    }
    NSMutableArray *hexStrArr = [NSMutableArray array];
    Byte *oriByteArr = (Byte *)[self bytes];
    for (int i = 0; i < [self length]; i ++) {
        [hexStrArr addObject:[NSString stringWithFormat:@"%x",oriByteArr[i]]];
    }
    return hexStrArr;
}

- (NSArray *)dataSwitchIntStrArr {
    if (!self || [self length] == 0) {
        return @[];
    }
    NSMutableArray *intStrArr = [NSMutableArray array];
    Byte *oriByteArr = (Byte *)[self bytes];
    for (int i = 0; i < [self length]; i ++) {
        [intStrArr addObject:[NSString stringWithFormat:@"%d",oriByteArr[i]]];
    }
    return intStrArr;
}

@end
