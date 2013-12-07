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
@property (nonatomic, strong)      ConnectionViewController  *connectionController;
@property (nonatomic, strong)      CBPeripheralManager       *peripheralManager;
@property (nonatomic, strong)      CBMutableCharacteristic   *transferCharacteristic;
@property (nonatomic, strong)      NSData                    *dataToSend;
@property (nonatomic, readwrite)   NSInteger                 sendDataIndex;

@end
