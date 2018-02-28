//
//  NSString+Bnt.h
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/28.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Bnt)

- (NSData *)hexToBytes;

// data -> hex
+ (NSString *)convertDataToHexStr:(NSData *)data;

// Hex -> String
- (NSString *)stringFromHexString;

//  Hex -> 10
- (NSString *)hexSwitchString;
- (NSString *)hexSwitchString2Char;

//  切分字符串，每个子字符串有两个字母
- (NSMutableArray *)stringCarveBy2Character;


@end
