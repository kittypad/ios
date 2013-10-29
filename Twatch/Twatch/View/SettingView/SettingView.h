//
//  SettingView.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _WatchStyle{
    wBlack = 0,
    wRed,
    wBlue
}WatchStyle;



@interface SettingView : UIView<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) BOOL settingHasPullOut;

@end
