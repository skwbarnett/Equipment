//
//  BntEquipRequestOperator.h
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BntEquipManager.h"


@interface BntEquipRequestOperator : NSObject

+ (void)dashBoard:(DataAction)success failure:(DataAction)failure;

+ (void)bikeInfo:(DataAction)success failure:(DataAction)failure;

@end
