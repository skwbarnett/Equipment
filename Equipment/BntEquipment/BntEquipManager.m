//
//  BntEquipManager.m
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import "BntEquipManager.h"
#import "BntEquipResponseOperator.h"
#import "BntEquipRequestOperator.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "NSString+Bnt.h"
#import "NSData+Bnt.h"
#import "MBProgressHUD+Bnt.h"

#define BasicUUID  @"4E300001-A2BB-DC65-33C2-E43536BCCB9E"
#define ReadUUID   @"4E3000A1-A2BB-DC65-33C2-E43536BCCB9E"
#define WriteUUID  @"4E3000A2-A2BB-DC65-33C2-E43536BCCB9E"

@interface BntEquipManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSMutableArray *peripheralMArr;// all

@property (nonatomic, strong) NSMutableArray *targetPrpMArr;  // 目标prp

@property (nonatomic, strong) NSMutableArray *scanPrpMArr;  // 待识别prp

@property (nonatomic, strong) CBCharacteristic *readCharacteristic;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic, strong) CBPeripheral *tagPeripheral;

@property (nonatomic, assign) NSInteger command;// 1000stop, 1010 链接设备, 1001 扫描, 1002 读数据请求, 1003 写数据请求

@property (nonatomic, copy) DataAction successComplete;

@property (nonatomic, copy) DataAction failureComplete;

@property (nonatomic, strong) NSMutableArray *responseMArr;

@end

@implementation BntEquipManager

- (void)setupScan{
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
    self.command = 1001;
}

- (void)connectPeripheral:(NSInteger)index {
    _command = 1010;
    [_centralManager connectPeripheral:_targetPrpMArr[index] options:nil];
}

/** 重新扫描 */
- (void)reScan {
    _command = 1001;
    _tagPeripheral = nil;
    _scanPrpMArr = nil;
    _peripheralMArr = nil;
    _readCharacteristic = nil;
    _writeCharacteristic = nil;
    [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if ([peripheral.name containsString:@"Tophmi"]) {
        if (![self.peripheralMArr containsObject:peripheral]) {
            [self.peripheralMArr addObject:peripheral];
            [self.targetPrpMArr addObject:peripheral];
            [_centralManager connectPeripheral:peripheral options:nil];
        }
        NSLog(@"peripheral : >>>%@>>> \n", peripheral.name);
    }else {
        [_centralManager cancelPeripheralConnection:peripheral];
    }
}

//  链接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@">>>设备连接成功:\n%@\n",peripheral.name);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    self.peripheral = peripheral;
    if (_command == 1010 && _connectComplete) {
        _connectComplete(_peripheral);
    }
}
//  链接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

//  断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    
}

/** discovery service */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@">>>扫描到服务：%@",peripheral.services);
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    NSInteger target = -1;
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:BasicUUID]) {
            NSLog(@"目标服务:%@",service);
            [peripheral discoverCharacteristics:nil forService:service];
            [self.scanPrpMArr addObject:peripheral];
            target = 1;
        }
    }
    _reloadViewComplete(_targetPrpMArr);
    if (target == 1) {
        self.tagPeripheral = peripheral;
    }else {
        [_centralManager cancelPeripheralConnection:peripheral];
    }
}

/** discovery characteristics */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"目标特征:%@",characteristic);
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
        
        [self storeCharacteristic:characteristic];
    }
    if (_readCharacteristic && _writeCharacteristic) {
        [self getCharacteristicValue];
    }
}

/** 获取charateristic的value */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    [self printfCharacteristic:characteristic];
    
    [self dataResponse:characteristic.value uuid:characteristic.UUID.UUIDString];
}

/** 数据已发送 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"发送数据失败\n%@",error.userInfo);
    }else{
        NSLog(@"发送数据成功");
    }
    [self getCharacteristicValue];
}

/** 发现Descriptors */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    for (CBDescriptor *des in characteristic.descriptors) {
        NSLog(@"发现描述\n>>>descriptor:%@\n>>>characteristic:%@",des.UUID.UUIDString,characteristic.UUID.UUIDString);
        [peripheral readValueForDescriptor:des];
    }
}

/** 获取 Descriptors value */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    
}

/** 蓝牙状态 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%@",central);
    switch (central.state) {
            
        case CBManagerStateUnknown:
            break;
        case CBManagerStateResetting:
            break;
        case CBManagerStateUnsupported:
            break;
        case CBManagerStateUnauthorized:
            break;
        case CBManagerStatePoweredOff:
            break;
        case CBManagerStatePoweredOn:
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Event Response

- (void)reloadPeripheal:(CBPeripheral *)peripheral{
    if (![self.targetPrpMArr containsObject:peripheral]) {
        [self.targetPrpMArr addObject:peripheral];
        // [self.tableView reloadData];
    }
}

/** log characteristic */
- (void)printfCharacteristic:(CBCharacteristic *)characteristic {
    NSString *characteristicUTFString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSString *characValueHex = [NSString convertDataToHexStr:characteristic.value];
    NSLog(@"接收数据\n%@\n>>>characteristic>>>\nUUID: %@\n>>>UTF8 : %@\n>>>value : %@\n>>>ValueHex : %@\n>>>propertise: %lu",characteristic,characteristic.UUID.UUIDString,characteristicUTFString,characteristic.value,characValueHex,(unsigned long)characteristic.properties);
}

/** 获取读写特征 */
- (void)storeCharacteristic:(CBCharacteristic *)characteristic{
    if ([characteristic.UUID.UUIDString isEqualToString:ReadUUID]) {//读
        self.readCharacteristic = characteristic;
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:WriteUUID]) {//写
        self.writeCharacteristic = characteristic;
    }
}

/** 接收数据 */
- (void)getCharacteristicValue {
    [_tagPeripheral readValueForCharacteristic:_readCharacteristic];
    [_tagPeripheral setNotifyValue:YES forCharacteristic:_readCharacteristic];
    [_tagPeripheral readValueForCharacteristic:_writeCharacteristic];
    [_tagPeripheral setNotifyValue:YES forCharacteristic:_writeCharacteristic];
}

/** 数据返回 */
- (void)dataResponse:(NSData *)data uuid:(NSString *)uuid{
    if ([uuid isEqualToString:ReadUUID]) {
        
        if (_successComplete  && _command == 1003) {
            _successComplete(data);
        }
    }else if ([uuid isEqualToString:WriteUUID]) {
        if ([self responseContain:data]) {
            return ;
        }else {
            [self.responseMArr addObject:data];
            
            if (_successComplete && _command == 1002 && [self responseCompelet:data]) {
                _successComplete(self.responseMArr);
                self.responseMArr = nil;
            }
        }
    }
}

- (BOOL)responseCompelet:(NSData *)data {
    NSString *dataStr = [data convertDataToHexStr];
    NSString *CompeletStr = [dataStr substringWithRange:NSMakeRange(dataStr.length - 2, 2)];
    if ([CompeletStr isEqualToString:@"a5"]) {
        return YES;
    }
    return NO;
}

- (BOOL)responseContain:(NSData *)data {
    for (NSData *rdata in self.responseMArr) {
        if ([rdata isEqual:data]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - help

/** 数据请求 */
- (void)requestReadData:(NSData *)data success:(DataAction)success failure:(DataAction)failure {
    self.successComplete = success;
    self.failureComplete = failure;
    self.responseMArr = nil;
    _command = 1002;
    [_peripheral writeValue:data forCharacteristic:_readCharacteristic type:(CBCharacteristicWriteWithResponse)];
}

- (void)requestWriteData:(NSData *)data success:(DataAction)success failure:(DataAction)failure {
    self.successComplete = success;
    self.failureComplete = failure;
    self.responseMArr = nil;
    _command = 1003;
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:(CBCharacteristicWriteWithResponse)];
}



/** 写数据 */
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value
{
    
    //NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}

/** 设置通知 */
-(void)notifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic
{
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

#pragma mark - setter && getter

+ (BntEquipManager *)sharedManager {
    static BntEquipManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupScan];
    }
    return self;
}

- (NSMutableArray *)responseMArr {
    if (_responseMArr == nil) {
        _responseMArr = [NSMutableArray array];
    }
    return _responseMArr;
}

- (NSMutableArray *)peripheralMArr{
    if (_peripheralMArr == nil) {
        _peripheralMArr = [NSMutableArray array];
    }
    return _peripheralMArr;
}

- (NSMutableArray *)targetPrpMArr{
    if (_targetPrpMArr == nil) {
        _targetPrpMArr = [NSMutableArray array];
    }
    return _targetPrpMArr;
}

- (NSMutableArray *)scanPrpMArr{
    if (_scanPrpMArr == nil) {
        _scanPrpMArr = [NSMutableArray array];
    }
    return _scanPrpMArr;
}

- (CBCentralManager *)centralManager {
    if (_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _centralManager;
}

#pragma mark - CharacteristicData Analyse Delegete

/*- (void)dataAnalyseSuccessWithData:(id)dataModel{
 
 - (void)dataAnalyseFailure{
 NSLog(@"123");
 }
 }*/
 @end
