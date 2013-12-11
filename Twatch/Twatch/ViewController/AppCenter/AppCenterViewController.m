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
#import "DownloadManagerViewController.h"

@interface AppCenterViewController ()
{
    UIButton *_lastButton;
    
    NSMutableArray *_buttonArray;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) AppCenterListViewController *appVC;

@property (nonatomic, strong) AppCenterListViewController *wallPaperVC;

@property (nonatomic, strong) DownloadManagerViewController *managerVC;

- (void)_selectButton:(UIButton *)button;

- (void)_homeButtonPressed:(id)sender;

- (void)_loadPage:(int)page;

- (void)_updatePage;

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
    _lastButton = nil;
    
    [self setLineHidden:YES];
    
    self.view.backgroundColor = [UIColor colorWithHex:@"eef7fe"];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, IS_IOS7 ? 63 :43, 320.0, 1.0)];
    lineView.backgroundColor = [UIColor colorWithHex:@"49acff"];
    [self.view addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, IS_IOS7 ? 93 :73, 320.0, 1.0)];
    lineView.backgroundColor = [UIColor colorWithHex:@"49acff"];
    [self.view addSubview:lineView];
    
    CGFloat y = IS_IOS7 ? 94 :74;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, y, 321.0, self.view.frame.size.height - y)];
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width*3, _scrollView.bounds.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    CGRect frame = _scrollView.bounds;
    frame.size.width -= 1.0;
    _appVC = [[AppCenterListViewController alloc] initWithStyle:UITableViewStylePlain];
    _appVC.view.frame = frame;
    _appVC.type = kAppCenterType;
    [self addChildViewController:_appVC];
    [_scrollView addSubview:_appVC.view];
    
    frame.origin.x += frame.size.width + 1.0;
    _wallPaperVC = [[AppCenterListViewController alloc] initWithStyle:UITableViewStylePlain];
    _wallPaperVC.view.frame = frame;
    _wallPaperVC.type = kWallPaperCenterType;
    [self addChildViewController:_wallPaperVC];
    [_scrollView addSubview:_wallPaperVC.view];
    
    frame.origin.x += frame.size.width + 1.0;
    _managerVC = [[DownloadManagerViewController alloc] initWithStyle:UITableViewStylePlain];
    _managerVC.view.frame = frame;
    [self addChildViewController:_managerVC];
    [_scrollView addSubview:_managerVC.view];
    
    NSArray *titleArray = @[NSLocalizedString(@"App Center", nil), NSLocalizedString(@"Wallpaper Center", nil),NSLocalizedString(@"Download Manager", nil)];
    
    _buttonArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    frame = CGRectMake(0.0, IS_IOS7 ? 64 :44, 106.0, 30.0);
    for (int i = 0; i < 3; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:@"2197fa"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithHex:@"2197fa"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(_selectButton:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        button.tag = i;
        [self.view addSubview:button];
        [_buttonArray addObject:button];
        frame.origin.x += frame.size.width;
        if (i < 2) {
            CGRect f = CGRectMake(frame.origin.x, IS_IOS7 ? 73 :53, 1.0, 12.0);
            UIView *lineView = [[UIView alloc] initWithFrame:f];
            lineView.backgroundColor = [UIColor colorWithHex:@"b2c9e6"];
            [self.view addSubview:lineView];
        }
        frame.origin.x += 1.0;
    }
    
    [self _selectButton:_buttonArray[0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_selectButton:(UIButton *)button
{
    if (button == _lastButton) {
        return;
    }
    if (_lastButton) {
        _lastButton.selected = NO;
    }
    button.selected = YES;
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = button.tag * frame.size.width;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    [self _loadPage:button.tag];
    _lastButton = button;
}

- (void)_homeButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)_loadPage:(int)page
{
    switch (page) {
        case 0: {
            [_appVC startNetworkingFetch];
            break;
        }
        case 1: {
            [_wallPaperVC startNetworkingFetch];
            break;
        }
        default:
            break;
    }
}

- (void)_updatePage
{
    CGFloat x = self.scrollView.contentOffset.x;
    int page = (int)((x+10.0)/self.scrollView.bounds.size.width);
    [self _selectButton:_buttonArray[page]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _updatePage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self _updatePage];
    }
}

@end
