//
//  ConnectionViewController+CentralManager.h
//  Twatch
//
//  Created by yixiaoluo on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ConnectionViewController.h"

@interface ConnectionViewController (CentralManager)
<

CBCentralManagerDelegate,
CBPeripheralDelegate

>

- (void)scan;
- (void)stop;

@end
