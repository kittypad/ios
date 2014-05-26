//
//  UpdateWatchControllerViewController.h
//  Twatch
//
//  Created by huxiaoxi on 14-2-26.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NaviCommonViewController.h"

@interface UpdateWatchController : NaviCommonViewController
{

}

//@property (nonatomic, strong) NSString *newWatchVersion;
//@property (nonatomic, strong) NSString *newVersionURL;
//@property (nonatomic, strong) NSString *newVersionSize;

@property (nonatomic, strong) NSString *updateVersion;
@property (nonatomic, strong) NSString *VersionURL;
@property (nonatomic, strong) NSString *VersionSize;
@property (nonatomic, strong) NSString *description;




@property (nonatomic) UIProgressView *processView;
@property (nonatomic) UILabel *processLable;
@property (nonatomic) UILabel *processPecentLable;
@property (nonatomic) UILabel *bytesLable;
@property (nonatomic) UIButton *updateButton;

@property (nonatomic) UIImageView *updateInfoView;
@property (nonatomic) UITextView  *updateInfoText;


@property (nonatomic, assign) BOOL  isOneClick;
@property (nonatomic, assign) BOOL isUpdated ;//是否有新版本需要升级



//write
@property (nonatomic, strong)      NSMutableArray *product;
@property (nonatomic, strong)      NSMutableArray *versionList;

- (void)loadVersionNetworking;

-(void)actionForUpdateButton;

-(void)checkVersionNetworking:(NSNotification *)notification;

@end
