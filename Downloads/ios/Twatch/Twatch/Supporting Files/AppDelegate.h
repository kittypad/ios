//
//  AppDelegate.h
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@class RootViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,CBPeripheralManagerDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic)BOOL  haveNewVersion;

@property (strong, nonatomic) RootViewController *rootViewController;

@property (readwrite, nonatomic, strong) CBPeripheralManager *peripheralManager;

@end
