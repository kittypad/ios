//
//  ConnectionViewController.h
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviCommonViewController.h"

@interface ConnectionViewController : NaviCommonViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView     *tableView;

@end
