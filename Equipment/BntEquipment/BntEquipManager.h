//
//  BntEquipManager.h
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:\n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

typedef void(^DataAction)(id data);

@interface BntEquipManager : NSObject

@property (nonatomic, copy) DataAction reloadViewComplete;/**< 扫描完成刷新 */

@property (nonatomic, copy) DataAction connectComplete;/**< 连接完成 */

+ (BntEquipManager *)sharedManager;

- (void)setupScan;

- (void)connectPeripheral:(NSInteger)index;


/** 读数据请求 */
- (void)requestReadData:(NSData *)data success:(DataAction)success failure:(DataAction)failure;
/** 写入数据请求 */
- (void)requestWriteData:(NSData *)data success:(DataAction)success failure:(DataAction)failure;

@end
