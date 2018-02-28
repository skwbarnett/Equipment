//
//  TBBikeDTO.h
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TBBikeDTO : NSObject



@end

@interface TBDashBoardDTO : NSObject

@property (nonatomic, strong) NSString *speed;
@property (nonatomic, strong) NSString *avgSpeed;
@property (nonatomic, strong) NSString *tripDistance;
@property (nonatomic, strong) NSString *ODODistance;/**< 总里程 */
@property (nonatomic, strong) NSString *cadence;/**< 踏频 */
@property (nonatomic, strong) NSArray *tripTime;/**< 时分秒 */
@property (nonatomic, strong) NSString *calorie;
@property (nonatomic, strong) NSString *batteryCapacity;
@property (nonatomic, strong) NSString *remainDistance;
@property (nonatomic, strong) NSString *assistMode;
@property (nonatomic, strong) NSString *light;

@end

@interface TBBetteryDTO : NSObject

@end
