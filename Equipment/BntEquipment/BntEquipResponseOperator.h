//
//  BntEquipResponseOperator.h
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EquipResponseMode) {
    EquipResponseModeDashBoard,     //主页    1f
    EquipResponseModeBatteryInfo,   //电池信息 2f
    EquipResponseModeBikeInfo,      //车辆信息 3f
};

@interface BntEquipResponseOperator : NSObject

+ (id)readData:(NSArray *)readData mode:(EquipResponseMode)mode;

+ (id)writeData:(NSArray *)writeData mode:(EquipResponseMode)mode;

@end
