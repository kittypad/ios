//
//  RootViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "SimulatorViewController.h"
#import "SimulatorViewController+SettingView.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "SettingView.h"

@interface SimulatorViewController ()

@property (nonatomic, strong) WatchView *watchView;

- (void)backButtonPressed:(UIButton *)button;

@end

@implementation SimulatorViewController

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
    bgView.userInteractionEnabled = YES;
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

    self.watchView = [[WatchView alloc] initWithFrame:CGRectMake(43.0, 106.5, Watch_Width, Watch_Height)];
    self.watchView.layer.masksToBounds = YES;
    [bgView addSubview:self.watchView];
    
    CGFloat y = IS_IOS7 ? 20.0 : 0.0;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, y, 53.0, 53.0)];
    [backButton setImage:[UIImage imageNamed:@"sim-back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"sim-back-push.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(81.0, self.view.frame.size.height-58.0, 158.0, 58.0)];
    bottomView.userInteractionEnabled = YES;
    bottomView.image = [UIImage imageNamed:@"sim-bottom-bg.png"];
    [self.view addSubview:bottomView];
    
    NSArray *colorStrArray = @[@"黑", @"红", @"蓝"];
    
    __block CGFloat x = 6.0;
    __block id weakSelf = self;
    [colorStrArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 6.0, 45.0, 45.0)];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"模拟%@.png", obj]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"模拟%@-push.png", obj]] forState:UIControlStateHighlighted];
        [button addTarget:weakSelf action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = idx;
        [bottomView addSubview:button];
        x += button.frame.size.width + 6.0;
    }];

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
    NSString *className = nil;
    NSString *backName = nil;
    switch ([name integerValue])
    {
        case PanoramicAppType: {
            className = @"_360ViewController";
            backName = NSLocalizedString(@"Panoramicview", nil);
            break;
        }
        case ExclusuveAppType: {
            className = @"TryViewController";
            backName = NSLocalizedString(@"Try", nil);
            break;
        }
        case TryAppType: {
            className = @"SignViewController";
            backName = NSLocalizedString(@"Engraving", nil);
            break;
        }
        default:
            break;
    }
    NaviCommonViewController *vc = [[NSClassFromString(className) alloc] init];
    vc.backName = backName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)videoPlayDidFinished:(NSNotification *)notice
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)backButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)colorButtonPressed:(UIButton *)button
{
    [[NSUserDefaults standardUserDefaults] setInteger:button.tag forKey:WatchStyleStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:WatchStyleStatusChangeNotification object:nil];
}

- (void)settingBUttonClicked:(UIButton *)sender
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
