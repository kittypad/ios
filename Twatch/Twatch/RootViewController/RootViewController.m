//
//  RootViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "RootViewController.h"
#import "RootViewController+BottomNavigationbar.h"
#import "RootViewController+SettingView.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "SettingView.h"

@interface RootViewController ()

@property (nonatomic, strong) WatchView *watchView;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rooView_bg.png"]];
    
    UIImage *img = [UIImage imageNamed:@"蓝2.png"];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    NSLog(@"%f", img.size.height);
    bgView.center = self.view.center;
    [self.view addSubview:bgView];
    [[NSNotificationCenter defaultCenter] addObserverForName:WatchStyleStatusChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
        if (style == wBlack) {
            bgView.image = [UIImage imageNamed:@"黑2.png"];
        }else if (style == wRed){
            bgView.image = [UIImage imageNamed:@"红2.png"];
        }else if (style == wBlue){
            bgView.image = [UIImage imageNamed:@"蓝2.png"];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:WatchStyleStatusChangeNotification object:nil];

    self.watchView = [[WatchView alloc] initWithFrame:CGRectMake(0, 0, Watch_Width, Watch_Height)];
    self.watchView.center = self.view.center;
    self.watchView.frame = CGRectOffset(self.watchView.frame, -2, -2);
    self.watchView.layer.masksToBounds = YES;
    [self.view addSubview:self.watchView];
    bgView.center = CGPointMake(self.view.center.x - 2.0, self.view.center.y + 5.0);
    
    [self prepareBottomNavigationbar];
    
    [self prepareSettingView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAppsVideo:) name:PlayAppsVideoNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayDidFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playAppsVideo:(NSNotification *)notice
{
    NSString *name = [notice.userInfo objectForKey:@"name"];
    switch ([name integerValue])
    {
        case SettingAppType:
            [[NSNotificationCenter defaultCenter] postNotificationName:SettingviewClickNotification object:nil userInfo:nil];
            break;
        default:
            [[NSNotificationCenter defaultCenter] postNotificationName:AppIconClickNotification object:nil userInfo:notice.userInfo];
            
            break;
    }
}

- (void)videoPlayDidFinished:(NSNotification *)notice
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)settingBUttonClicked:(UIButton *)sender
{/*
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"icon_120"  ofType:@"png"];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeQQSpace, ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeRenren, ShareTypeDouBan, nil];

    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"土曼share"
                                       defaultContent:@"亲，这是我的新手表哦"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"土曼手表分享"
                                                  url:@"http://www.tomoon.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSShareOptions> op = [ShareSDK defaultShareOptionsWithTitle:nil oneKeyShareList:shareList qqButtonHidden:YES wxSessionButtonHidden:NO wxTimelineButtonHidden:NO showKeyboardOnAppear:NO shareViewDelegate:nil friendsViewDelegate:nil picViewerViewDelegate:nil];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: op
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];*/
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
