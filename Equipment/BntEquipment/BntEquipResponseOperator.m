//
//  BntEquipResponseOperator.m
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import "BntEquipResponseOperator.h"
//#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "NSData+Bnt.h"
#import "NSString+Bnt.h"
#import "TBBikeDTO.h"

/** 标识datalen位置 */
#define dataLenLoc 3
/** 非数据域长度 */
#define nonDataLen 7

@interface BntEquipResponseDTO : NSObject

@property (nonatomic, strong) NSArray *oriHexArr;/**< 完整数组(Hex) */

@property (nonatomic, strong) NSArray *dataHexArr;/**< data域数组(Hex) */

@property (nonatomic, strong) NSArray *dataIntArr;/**< data域数组(Int) */

@end

@implementation BntEquipResponseDTO

@end

@implementation BntEquipResponseOperator


+ (id)dashBoard:(NSArray *)readData {
    
    NSData *oriData = [@"5b001f1501410000000000046a0309000000025802014d0001dfdba5" hexToBytes];
    
    
    BntEquipResponseDTO *dto = [self operateOriDataArr:@[oriData]];
    if (dto == nil) {
        return nil;
    }
    
    TBDashBoardDTO *dashDto = [[TBDashBoardDTO alloc] init];
    
    NSArray *dataArr = dto.dataIntArr;//数据域int
    
    //速度
    dashDto.speed = [self setupSpeedS1:dataArr[0] s2:dataArr[1]];
    dashDto.avgSpeed = [self setupSpeedS1:dataArr[2] s2:dataArr[3]];
    //路程
    CGFloat tripD = [self setupDistance:0 d2:dataArr[4] d3:dataArr[5]] * 0.1;
    CGFloat remainD = [self setupDistance:0 d2:dataArr[17] d3:dataArr[18]];
    CGFloat odoInt = [self setupDistance:dataArr[6] d2:dataArr[7] d3:dataArr[8]];
    dashDto.tripDistance =  [NSString stringWithFormat:@"%f",tripD];
    dashDto.remainDistance =  [NSString stringWithFormat:@"%f",remainD];
    dashDto.ODODistance =  [NSString stringWithFormat:@"%f",odoInt];
    
    dashDto.cadence = [self commonIndicator:dataArr[9] s2:dataArr[10]];
    dashDto.tripTime = @[dataArr[11],dataArr[12],dataArr[13]];
    dashDto.calorie = [self commonIndicator:dataArr[14] s2:dataArr[15]];
    dashDto.batteryCapacity = dataArr[16];
    
    dashDto.assistMode = dataArr[19];
    dashDto.light = dataArr[20];
    
    return dashDto;
}

+ (id)readData:(NSArray *)readData mode:(EquipResponseMode)mode{
    [self printfData:readData type:@"read"];
    
    [self dashBoard:readData];
    return nil;
}

+ (id)writeData:(NSArray *)writeData mode:(EquipResponseMode)mode{
    [self printfData:writeData type:@"write"];
    return [self dashBoard:writeData];
}


/** 筛选 log分包 */
+ (void)printfData:(NSArray *)dataArr type:(NSString *)type {
    for (NSData *data in dataArr) {
        Byte *testByte = (Byte *)[data bytes];
        printf("\n/****************************/\n");
        if ([type isEqualToString:@"read"]) {
            for(int i=0;i<[data length];i++)
                printf("ReadResponse[%d] = %d\n",i,testByte[i]);
        }else if ([type isEqualToString:@"write"]) {
            for(int i=0;i<[data length];i++)
                printf("WriteResponse[%d] = %d\n",i,testByte[i]);
        }
    }
}

/** 提取data域数据 */
+ (BntEquipResponseDTO *)operateOriDataArr:(NSArray *)oriDataArr {
    
    NSArray *oriHexStrArr = [self setupOriHexStringArr:oriDataArr];
    NSArray *compArr = [self carveDataArray:oriHexStrArr];
    
    if (compArr.count == 0) {
        return nil;
    }
    
    BntEquipResponseDTO *dto = [[BntEquipResponseDTO alloc] init];
    
    dto.oriHexArr = oriHexStrArr;
    dto.dataHexArr = compArr[0];
    dto.dataIntArr = compArr[1];
    
    
    
    return dto;
}


/** 原始NSData -> hexArr */
+ (NSArray *)setupOriHexStringArr:(NSArray *)oriDataArr {
    NSMutableArray *oriHexStrArr = [NSMutableArray array];
    
    for (NSData *data in oriDataArr) {
        NSArray * speHexDataArr = [data dataSwitchHexStrArr];
        [oriHexStrArr addObjectsFromArray:speHexDataArr];
    }
    return oriHexStrArr;
}

/** data域Arr(Hex& Int) */
+ (NSArray *)carveDataArray:(NSArray *)oriHexArr {
    if (oriHexArr.count < nonDataLen + 1) {
        return nil;
    }
    
    NSInteger length = [oriHexArr[dataLenLoc] hexSwitchString].integerValue;
    if (oriHexArr.count != length + nonDataLen) {
        return nil;
    }
    
    NSArray *returnArr;
    
    NSMutableArray *dataHexArr = [NSMutableArray array];
    NSMutableArray *dataIntArr = [NSMutableArray array];
    for (int i = 0; i < length; i ++) {
        NSString *hexDataStr = oriHexArr[dataLenLoc + 1 + i];
        [dataHexArr addObject:hexDataStr];
        [dataIntArr addObject:[hexDataStr hexSwitchString]];
    }
    if (dataHexArr.count && dataIntArr.count) {
        returnArr = @[dataHexArr,dataIntArr];
    }
    [self printfIntArr:dataIntArr];
    
    return returnArr;
}

#pragma mark 公式

/** 速度 */
+ (NSString *)setupSpeedS1:(NSString *)s1 s2:(NSString *)s2 {
    NSInteger speed = s1.integerValue * 256 + s2.integerValue;
    return [NSString stringWithFormat:@"%f", speed * 0.1];
}

+ (NSInteger)setupDistance:(NSString *)d1 d2:(NSString *)d2 d3:(NSString *)d3 {
    NSInteger distance = d1.integerValue * 65536 + d2.integerValue * 256 + d3.integerValue;
    return distance;
}

+ (NSString *)commonIndicator:(NSString *)s1 s2:(NSString *)s2 {
    NSInteger indicator = s1.integerValue * 256 + s2.integerValue;
    return [NSString stringWithFormat:@"%ld", (long)indicator];
}

#pragma mark - help

+ (void)printfIntArr:(NSArray *)arr {
    printf("\n\n");
    for (int i = 0 ; i < arr.count; i ++) {
        printf("Arr[%d] hex = %x int = %d\n", i,[arr[i] intValue],[arr[i] intValue]);
    }
}

#pragma mark - dec
/*
// 分包组合
+ (NSString *)dataSplit:(NSArray *)dataArr {
    NSString *dataStr = @"";
    for (NSData *data in dataArr) {
        NSString *string = [data convertDataToHexStr];
        dataStr = [NSString stringWithFormat:@"%@%@",dataStr,string];
    }
    
    return dataStr;
}
 
// data域String(Hex)
+ (NSString *)setupDataString:(NSString *)oridata {
    
    NSString *dataHexStr = [oridata substringWithRange:NSMakeRange(6, 2)];
    
    NSInteger length = [dataHexStr hexSwitchString].integerValue;
    
    return [oridata substringWithRange:NSMakeRange(8, length * 2)];
}
*/

@end
