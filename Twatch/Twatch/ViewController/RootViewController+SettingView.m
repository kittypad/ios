//
//  RootViewController+SettingView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController+SettingView.h"
#import "SettingView.h"

@implementation RootViewController (SettingView)

- (void)prepareSettingView
{
    SettingView *settingView = [[SettingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 37, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.view addSubview:settingView];
}

@end
