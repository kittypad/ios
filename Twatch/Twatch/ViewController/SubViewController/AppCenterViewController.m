//
//  AppCenterViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "AppCenterViewController.h"
#import "HomeButton.h"
#import "AppCenterListViewController.h"

@interface AppCenterViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) AppCenterListViewController *appVC;

@property (nonatomic, strong) AppCenterListViewController *wallPaperVC;

- (void)homeButtonPressed:(id)sender;

@end

@implementation AppCenterViewController

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
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHex:@"eef7fe"];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 60.0)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    HomeButton *homeButton = [[HomeButton alloc] initWithFrame:CGRectMake(22.0, 20.0, 60.0, 40.0)];
    [homeButton addTarget:self action:@selector(homeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:homeButton];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 90.0, 320.0, self.view.frame.size.height - 90.0)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width*3, _scrollView.bounds.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    CGRect frame = _scrollView.bounds;
    _appVC = [[AppCenterListViewController alloc] initWithNibName:nil bundle:nil];
    _appVC.view.frame = frame;
    _appVC.type = kAppCenterType;
    [self addChildViewController:_appVC];
    [_scrollView addSubview:_appVC.view];
    
    frame.origin.x += frame.size.width;
    _wallPaperVC = [[AppCenterListViewController alloc] initWithNibName:nil bundle:nil];
    _wallPaperVC.view.frame = frame;
    _wallPaperVC.type = kWallPaperCenterType;
    [self addChildViewController:_wallPaperVC];
    [_scrollView addSubview:_wallPaperVC.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_appVC startNetworkingFetch];
}

- (void)homeButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

@end
