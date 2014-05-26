//
//  MoreSettingViewController.h
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviCommonViewController.h"
#import "ToggleView.h"
#import "BlockUIAlertView.h"
@interface MoreSettingCell : UITableViewCell
@end
@interface SettingViewController : NaviCommonViewController<UITableViewDelegate,UITableViewDataSource,ToggleViewDelegate>

@end
