//
//  SettingsViewController.h
//  Twatch
//
//  Created by yugong on 14-5-27.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviCommonViewController.h"
#import "ToggleView.h"
#import "BlockUIAlertView.h"

@interface MoreSettingsCell : UITableViewCell
@end


@interface SettingsViewController : NaviCommonViewController<UITableViewDelegate,UITableViewDataSource,ToggleViewDelegate>

@end
