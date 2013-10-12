//
//  SimulateHomeViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "SimulateHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieViewController.h"

@interface SimulateHomeViewController (Private)

- (void)playAppsVideo:(NSNotification *)notice;

@end

@implementation SimulateHomeViewController

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.watchView = [[WatchView alloc] initWithFrame:CGRectMake(0, 0, Watch_Width, Watch_Height)];
    self.watchView.center = self.view.center;
    self.watchView.layer.masksToBounds = YES;
    [self.view addSubview:self.watchView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAppsVideo:) name:PlayAppsVideoNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayDidFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

@end
