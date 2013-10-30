//
//  SettingView.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ SettingActionHandle) (int i);

@interface SettingView : UIView<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic)       BOOL                settingHasPullOut;
@property (nonatomic, copy) SettingActionHandle settingActionHandle;

@end
