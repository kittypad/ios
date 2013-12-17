//
//  ViewController.h
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@class ConnectionViewController;

@interface RootViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>


//for bluetooth transfer data
@property (strong, nonatomic)      CBPeripheral              *connectedPeripheral;
@property (strong, nonatomic)      CBCharacteristic          *curCharacteristic;

@property (nonatomic, strong)      NSData                    *dataToSend;
@property (nonatomic, readwrite)   NSInteger                 sendDataIndex;
@property (nonatomic, readwrite)   TransferDataType          transferDataType;

@end
