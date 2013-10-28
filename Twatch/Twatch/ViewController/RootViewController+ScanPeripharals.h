//
//  RootViewController+ScanPeripharals.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-19.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController.h"
#import "DEACentralManager.h"

@interface RootViewController (ScanPeripharals)
<CBPeripheralDelegate,CBCentralManagerDelegate,UITableViewDataSource,UITableViewDelegate>

- (void)prepareCentralManager;

- (void)startScan;

@end
