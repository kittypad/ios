//
//  RootViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "RootViewController.h"
#import "RootViewController+ScanPeripharals.h"
#import "RootViewController+BottomNavigationbar.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieViewController.h"
#import <ShareSDK/ShareSDK.h>

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
    
    UIImage *img = [UIImage imageNamed:@"simulator.png"];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    bgView.image = img;
    bgView.center = self.view.center;
    [self.view addSubview:bgView];
    
    UIButton *settingButton = [FactoryMethods buttonWWithNormalImage:@"icon_40.png" hiliteImage:@"icon_40.png" target:self selector:@selector(settingBUttonClicked:)];
    settingButton.center = CGPointMake(CGRectGetWidth(self.view.frame)- CGRectGetWidth(settingButton.frame) - 10, CGRectGetHeight(settingButton.frame)+15);
    [self.view addSubview:settingButton];
    
    self.watchView = [[WatchView alloc] initWithFrame:CGRectMake(0, 0, Watch_Width, Watch_Height)];
    self.watchView.center = self.view.center;
    self.watchView.frame = CGRectOffset(self.watchView.frame, -2, -2);
    self.watchView.layer.masksToBounds = YES;
    [self.view addSubview:self.watchView];
    bgView.center = CGPointMake(self.view.center.x, self.view.center.y + 5);
    
    [self prepareBottomNavigationbar];
    [self prepareCentralManager];
    
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
    NSString *type = [notice.userInfo objectForKey:@"type"];
    if (name && name.length>0 && type && type.length>0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
        NSLog(@"%@", path);
        if (path && path.length>0) {
            NSURL *url = [NSURL fileURLWithPath:path];
            MovieViewController *_moviePlayerViewController = [[MovieViewController alloc] initWithContentURL:url];
            [self presentViewController:_moviePlayerViewController animated:YES completion:^(void){}];
        }
    }
}

- (void)videoPlayDidFinished:(NSNotification *)notice
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)settingBUttonClicked:(UIButton *)sender
{
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
                            }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
