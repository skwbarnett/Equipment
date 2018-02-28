//
//  NSData+Bnt.h
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/29.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Bnt)

//  data -> string
- (NSString *)dataSwitchString;

// data -> hex
- (NSString *)convertDataToHexStr;

//  data -> hexStrArr
- (NSArray *)dataSwitchHexStrArr;

//  data -> intStrArr
- (NSArray *)dataSwitchIntStrArr;


@end
