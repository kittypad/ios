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

@property (strong, nonatomic) CBCentralManager   *centralManager;
@property (strong, nonatomic) CBPeripheral       *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData      *data;


@property (nonatomic, strong) UITableView     *tableView;
@property (nonatomic, strong) NSMutableArray  *connectedDevices;
@property (nonatomic, strong) NSMutableArray  *unConnectedDevices;

@end
