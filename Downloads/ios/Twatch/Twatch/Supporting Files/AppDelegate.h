//
//  AppDelegate.h
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic)BOOL  haveNewVersion;

@property (strong, nonatomic) RootViewController *rootViewController;

@end
