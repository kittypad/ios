//
//  WatchView.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-10.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialView.h"
#import "AllAppsView.h"
#import "CommonAppsView.h"
#import "NotificationView.h"
#import "SwitchWatchView.h"

@interface WatchView : UIView
{
    UIImageView *_backgroundView;
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) DialView *dialView;
@property (nonatomic, strong) AllAppsView *allAppsView;
@property (nonatomic, strong) CommonAppsView *commonAppsView;
@property (nonatomic, strong) NotificationView *notificationView;
@property (nonatomic, strong) SwitchWatchView *switchWatchView;

@end
