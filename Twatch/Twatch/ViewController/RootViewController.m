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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
