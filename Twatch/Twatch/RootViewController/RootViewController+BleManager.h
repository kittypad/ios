//
//  RootViewController+BleManager.h
//  Twatch
//
//  Created by yixiaoluo on 13-12-7.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController (BleManager)<CBPeripheralDelegate>

- (void)sendDataToBle:(id)data transerType:(TransferDataType)type;

@end
