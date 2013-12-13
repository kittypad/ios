//
//  ConnectionViewController.h
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviCommonViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "TransferService.h"

@interface ConnectionViewController : NaviCommonViewController
<
UITableViewDataSource,
UITableViewDelegate
>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (nonatomic) NSMutableArray *array;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (nonatomic) int cur_row;
@property (nonatomic) int cur_rate;


@property (strong, nonatomic) NSMutableData      *data;


@property (nonatomic, strong) UITableView     *tableView;
@property (nonatomic, strong) NSNumber        *RSSI;

@property (nonatomic, strong) NSMutableArray  *unConnectedDevices;

//test
@property (nonatomic, strong) UIImageView *testImageView;

@end
