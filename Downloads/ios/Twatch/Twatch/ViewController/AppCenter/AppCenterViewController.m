//
//  AppCenterViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "AppCenterViewController.h"
#import "AppCenterListViewController.h"
#import "DownloadManagerViewController.h"

@interface AppCenterViewController ()
{
    UIButton *_lastButton;
    
    NSMutableArray *_buttonArray;
}

@property (strong,nonatomic)UIScrollView *imagescrollView;
@property (strong,nonatomic)NSMutableArray *slideImages;
@property (strong,nonatomic)UIPageControl *pageControl;

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
       //glc 2014-5-22 添加tabbar
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"App", @"应用") image:[UIImage imageNamed:@"tabapp"] tag:4];
        self.tabBarItem = item;
        self.backName = NSLocalizedString(@"App Center", @"应用市场");
    }
    return self;
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    _lastButton = nil;
    
    [self setLineHidden:YES];
    
    //滚动图片 glc 2014-5-23
    // 定时器 循环
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
    // 初始化 imagescrollView
    self.imagescrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, IS_IOS7 ? 32 :22, 320, 150)];
    self.imagescrollView.bounces = YES;
    self.imagescrollView.pagingEnabled = YES;
    self.imagescrollView.delegate = self;
    self.imagescrollView.userInteractionEnabled = YES;
    self.imagescrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.imagescrollView];
    // 初始化 数组 并添加四张图片
    self.slideImages = [[NSMutableArray alloc] init];
    [self.slideImages addObject:@"banner1.png"];
    [self.slideImages addObject:@"banner2.png"];

    // 初始化 pagecontrol
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(120,IS_IOS7 ? 160 :150,100,18)]; // 初始化mypagecontrol
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor redColor]];
    [self.pageControl setPageIndicatorTintColor:[UIColor blackColor]];
    self.pageControl.numberOfPages = [self.slideImages count];
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged]; // 触摸mypagecontrol触发change这个方法事件
    [self.view addSubview:self.pageControl];
    // 创建图片 imageview
    for (int i = 0;i<[self.slideImages count];i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.slideImages objectAtIndex:i]]];
        imageView.frame = CGRectMake((320 * i) + 320, IS_IOS7 ? 32 :22, 320, 150);
        [self.imagescrollView addSubview:imageView]; // 首页是第0页,默认从第1页开始的。所以+320。。。
    }
    // 取数组最后一张图片 放在第0页
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.slideImages objectAtIndex:([self.slideImages count]-1)]]];
    imageView.frame = CGRectMake(0, IS_IOS7 ? 32 :22, 320, 150); // 添加最后1页在首页 循环
    [self.imagescrollView addSubview:imageView];
    // 取数组第一张图片 放在最后1页
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.slideImages objectAtIndex:0]]];
    imageView.frame = CGRectMake((320 * ([self.slideImages count] + 1)) , IS_IOS7 ? 32 :22, 320, 150); // 添加第1页在最后 循环
    [self.imagescrollView addSubview:imageView];
    
    [self.imagescrollView setContentSize:CGSizeMake(320 * ([self.slideImages count] + 2), 150)]; //  +上第1页和第4页  原理：4-[1-2-3-4]-1
    [self.imagescrollView setContentOffset:CGPointMake(0, 0)];
    [self.imagescrollView scrollRectToVisible:CGRectMake(320,IS_IOS7 ? 32 :22,320,150) animated:NO]; // 默认从序号1位置放第1页 ，序号0位置位置放第4页
    
//    self.view.backgroundColor = [UIColor colorWithHex:@"eef7fe"];
//    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, IS_IOS7 ? 63 :43, 320.0, 1.0)];
//    lineView.backgroundColor = [UIColor colorWithHex:@"49acff"];
//    [self.view addSubview:lineView];
//    
//    lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, IS_IOS7 ? 93 :73, 320.0, 1.0)];
//    lineView.backgroundColor = [UIColor colorWithHex:@"49acff"];
//    [self.view addSubview:lineView];
    
    CGFloat y = IS_IOS7 ? 182 :172;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, y, 321.0, self.view.frame.size.height - y-50
                                                                 )];
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
    
    //glc 2014-5-22 去掉Wallpaper Center和Download Manager
//    frame.origin.x += frame.size.width + 1.0;
//    _wallPaperVC = [[AppCenterListViewController alloc] initWithStyle:UITableViewStylePlain];
//    _wallPaperVC.view.frame = frame;
//    _wallPaperVC.type = kWallPaperCenterType;
//    [self addChildViewController:_wallPaperVC];
//    [_scrollView addSubview:_wallPaperVC.view];
//    
//    frame.origin.x += frame.size.width + 1.0;
//    _managerVC = [[DownloadManagerViewController alloc] initWithStyle:UITableViewStylePlain];
//    _managerVC.view.frame = frame;
//    [self addChildViewController:_managerVC];
//    [_scrollView addSubview:_managerVC.view];
//    
//    NSArray *titleArray = @[NSLocalizedString(@"App Center", nil), NSLocalizedString(@"Wallpaper Center", nil),NSLocalizedString(@"Download Manager", nil)];
    
    NSArray *titleArray = @[NSLocalizedString(@"", nil)];
    
    _buttonArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    frame = CGRectMake(0.0, IS_IOS7 ? 64 :44, 106.0, 30.0);
    for (int i = 0; i < [titleArray count]; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:@"2197fa"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithHex:@"2197fa"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(_selectButton:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button.tag = i;
        //[self.view addSubview:button];
        [_buttonArray addObject:button];
        frame.origin.x += frame.size.width;
        if (i < 2) {
            CGRect f = CGRectMake(frame.origin.x, IS_IOS7 ? 73 :53, 1.0, 12.0);
            UIView *lineView = [[UIView alloc] initWithFrame:f];
            lineView.backgroundColor = [UIColor colorWithHex:@"b2c9e6"];
            //[self.view addSubview:lineView];
        }
        frame.origin.x += 1.0;
    }
    
    [self _selectButton:_buttonArray[0]];
    
    [super viewDidLoad];
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
    if (scrollView == self.scrollView) {
        [self _updatePage];
    }
    else if(scrollView == self.imagescrollView){
        CGFloat pagewidth = self.imagescrollView.frame.size.width;
        int currentPage = floor((self.imagescrollView.contentOffset.x - pagewidth/ ([self.slideImages count]+2)) / pagewidth) + 1;
        //    int currentPage_ = (int)self.scrollView.contentOffset.x/320; // 和上面两行效果一样
        //    NSLog(@"currentPage_==%d",currentPage_);
        if (currentPage==0)
        {
            [self.imagescrollView scrollRectToVisible:CGRectMake(320 * [self.slideImages count],IS_IOS7 ? 32 :22,320,150) animated:NO]; // 序号0 最后1页
        }
        else if (currentPage==([self.slideImages count]+1))
        {
            [self.imagescrollView scrollRectToVisible:CGRectMake(320,IS_IOS7 ? 32 :22,320,150) animated:NO]; // 最后+1,循环第1页
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self _updatePage];
    }
}

//添加图片滚动
// scrollview 委托函数
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pagewidth = self.imagescrollView.frame.size.width;
    int page = floor((self.imagescrollView.contentOffset.x - pagewidth/([self.slideImages count]+2))/pagewidth)+1;
    page --;  // 默认从第二页开始
    self.pageControl.currentPage = page;
}

// pagecontrol 选择器的方法
- (void)turnPage
{
    int page = self.pageControl.currentPage; // 获取当前的page
    [self.imagescrollView scrollRectToVisible:CGRectMake(320*(page+1), IS_IOS7 ? 32 :22, 320, 150) animated:NO]; // 触摸pagecontroller那个点点 往后翻一页 +1
}
// 定时器 绑定的方法
- (void)runTimePage
{
    int page = self.pageControl.currentPage; // 获取当前的page
    page++;
    page = page > ([self.slideImages count]-1) ? 0 : page ;
    self.pageControl.currentPage = page;
    [self turnPage];
}

@end
