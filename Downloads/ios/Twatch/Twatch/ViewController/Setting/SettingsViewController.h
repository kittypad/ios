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
<<<<<<< HEAD
#import "SettingSleepTimeViewController.h"
=======
>>>>>>> 2a3c53f1caca6d3a32ec8e4e28b41b03dd897cf8

@interface MoreSettingsCell : UITableViewCell
@end


<<<<<<< HEAD
@interface SettingsViewController : NaviCommonViewController<UITableViewDelegate,UITableViewDataSource>
{
    UISwitch *switchVibrate;
    UISwitch *switchInverse;
    SettingSleepTimeViewController * sleepTimeController;
}
=======
@interface SettingsViewController : NaviCommonViewController<UITableViewDelegate,UITableViewDataSource,ToggleViewDelegate>
>>>>>>> 2a3c53f1caca6d3a32ec8e4e28b41b03dd897cf8

@end
