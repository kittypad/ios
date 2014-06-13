//
//  SettingWatchTimeViewController.h
//  Twatch
//
//  Created by yugong on 14-5-28.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

@interface SettingWatchTimeViewController : NaviCommonViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSString* dateFormat;

@end
