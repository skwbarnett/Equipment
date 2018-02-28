//
//  BntEquipmentController.m
//  Equipment
//
//  Created by 吴克赛 on 2017/8/15.
//  Copyright © 2017年 BarnettWu. All rights reserved.
//

#import "BntEquipmentController.h"

#import "BntEquipManager.h"
#import "BntEquipRequestOperator.h"
#import "SearchTableViewCell.h"

@interface BntEquipmentController ()

@property (nonatomic, strong) NSArray *peripheralMArr;

@property (nonatomic, strong) UIButton *requestButton;

@end

@implementation BntEquipmentController

static NSString *const cellid = @"cellid";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self interactHTTPData];
}

#pragma mark - interact data
- (void)interactHTTPData {
    __weak typeof (self)weakSelf = self;
    BntEquipManager *manager = [BntEquipManager sharedManager];
    [manager setupScan];
    manager.reloadViewComplete = ^(id data) {
        weakSelf.peripheralMArr = data;
        [weakSelf.tableView reloadData];
    };
}

- (void)requestAction {
    [BntEquipRequestOperator dashBoard:^(id data) {
        
    } failure:^(id data) {
        
    }];
}

#pragma mark - layout views
- (void)setupViews {
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:cellid];
    [self.navigationController.view addSubview:self.requestButton];
}

#pragma mark - table view delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralMArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    [cell interactData:self.peripheralMArr index:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[BntEquipManager sharedManager] connectPeripheral:indexPath.row];
}

#pragma mark - setter && getter

- (UIButton *)requestButton {
    if (_requestButton == nil) {
        _requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _requestButton.backgroundColor = [UIColor lightGrayColor];
        [_requestButton setTitle:@"发送数据" forState:UIControlStateNormal];
        _requestButton.frame = CGRectMake(0, SCREEN_HEIGHT - 88, SCREEN_WIDTH, 44);
        [_requestButton addTarget:self action:@selector(requestAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _requestButton;
}

@end
