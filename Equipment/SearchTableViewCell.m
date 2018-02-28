//
//  SearchTableViewCell.m
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/23.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "SearchTableViewCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SearchTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation SearchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
        [self constructLayout];
    }
    return self;
}

- (void)setupSubviews{
    [self addSubview:self.titleLab];
}

- (void)constructLayout{
    self.titleLab.frame = CGRectMake(20, 10, [UIScreen mainScreen].bounds.size.width - 20, 80);
}

- (void)interactData:(NSArray *)DataMarr index:(NSInteger)index{
    CBPeripheral *peripheral = DataMarr[index];
    
    _titleLab.text = [NSString stringWithFormat:@"设备唯一识别码:%@\nname:%@\n",peripheral.identifier,peripheral.name];
    
}
- (UILabel *)titleLab{
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont boldSystemFontOfSize:13];
    }
    return _titleLab;
}

@end
