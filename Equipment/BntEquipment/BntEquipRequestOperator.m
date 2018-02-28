//
//  BntEquipRequestOperator.m
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import "BntEquipRequestOperator.h"
#import "BntEquipResponseOperator.h"



@interface BntEquipRequestOperator ()

/** request byte param */
@property (nonatomic, assign) int index;

@end

@implementation BntEquipRequestOperator

+ (void)dashBoard:(DataAction)success failure:(DataAction)failure {
    
    NSData *reqData = [[self sharedManager] requestForRead:0x1f];
    [[BntEquipManager sharedManager] requestReadData:reqData success:^(id data) {
        
        id model = [BntEquipResponseOperator readData:data mode:EquipResponseModeDashBoard];
        if (model) {
            success(model);
        }
        
    } failure:^(id data) {
        
    }];
    
}

+ (void)bikeInfo:(DataAction)success failure:(DataAction)failure {
    
    NSData *reqData = [[self sharedManager] requestForRead:0x4F];
    [[BntEquipManager sharedManager] requestReadData:reqData success:^(id data) {
        
        id model = [BntEquipResponseOperator readData:data mode:EquipResponseModeBikeInfo];
        success(model);
        
    } failure:^(id data) {
        
    }];
}

+ (BntEquipRequestOperator *)sharedManager {
    static BntEquipRequestOperator *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.index = 0;
    });
    return sharedInstance;
}

/** 数据协议格式化 */
- (NSData *)requestForRead:(int)cmd {
    
    int length = 1;
    Byte sendByte[8];
    sendByte[0] = 0x5A;     //0.HEAD域为包头固定字段0x5A
    sendByte[1] = _index;        //1.INDEX数据包索引，随发送的数据递增
    sendByte[2] = cmd;     //2.CMD域为数据包标识字段
    sendByte[3] = length;   //3.DATALEN域指示DATA域的数据总长度
    sendByte[4] = 0x00;        //4.DATA域为数据参数域
    int crc16 = [self crc16:sendByte length:5];
    sendByte[5] = crc16 / 256;     //5.6.CRC16校验位
    sendByte[6] = crc16;
    sendByte[7] = 0xA5;     //7.END 结束符固定字段0xA5
    printf("\ncrc16 = %d\n",crc16);
    for (int i = 0; i < 8; i ++) {
        printf("Send Request Byte[%d] hex = %x int = %d\n",i,sendByte[i],sendByte[i]);
    }
    
    NSData *data = [NSData dataWithBytes:sendByte length:8];
    
    self.index ++;
    return data;
}

/** crc16加密 */
- (int)crc16:(Byte[])byte length:(int)length {
    int Reg_CRC=0xffff;
    int temp;
    int i,j;
    for( i = 0; i<length; i ++)
    {
        temp = byte[i];
        if(temp < 0) temp += 256;
        temp &= 0xff;
        Reg_CRC^= temp;
        for (j = 0; j<8; j++)
        {
            if ((Reg_CRC & 0x0001) == 0x0001)
                Reg_CRC=(Reg_CRC>>1)^0xA001;
            else
                Reg_CRC >>=1;
        }
    }
    return (Reg_CRC&0xffff);
}

@end
