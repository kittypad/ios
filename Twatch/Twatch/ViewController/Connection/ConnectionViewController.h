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

@property (nonatomic, strong) UITableView     *tableView;

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (nonatomic) NSMutableArray *unConnectedDevices;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (nonatomic) int cur_rate;


//write
@property (nonatomic, strong)      NSData                    *dataToSend;
@property (nonatomic, readwrite)   NSInteger                 sendDataIndex;
@property (nonatomic, readwrite)   TransferDataType          transferDataType;
@property (strong, nonatomic)      CBCharacteristic          *curCharacteristic;


@end
