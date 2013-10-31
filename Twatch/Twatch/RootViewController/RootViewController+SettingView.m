//
//  RootViewController+SettingView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController+SettingView.h"
#import "SettingView.h"

#import "_360ViewController.h"
#import "TryViewController.h"
#import "SignViewController.h"
#import "AGAuthViewController.h"
#import "MoreSettingViewController.h"

@implementation RootViewController (SettingView)

- (void)prepareSettingView
{
    SettingView *settingView = [[SettingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 37, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.view addSubview:settingView];
    
    NSArray *classNames = [NSArray arrayWithObjects:@"_360ViewController", @"TryViewController",
                           @"SignViewController",@"AGAuthViewController",
                           @"MoreSettingViewController", nil];
    NSArray *backNames = [NSArray arrayWithObjects:@"360°全景视图", @"手表试戴",
                           @"专属刻字",@"账号绑定",
                           @"更多设置", nil];

    __weak typeof(self) weakself = self;
    settingView.settingActionHandle = ^(int i){
        NaviCommonViewController *vc = [[NSClassFromString(classNames[i]) alloc] init];
        vc.backName = backNames[i];
        [weakself.navigationController pushViewController:vc animated:YES];
    };
}

@end
