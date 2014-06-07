//
//  ShoppingViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "ShoppingViewController.h"

@interface ShoppingViewController ()

@property (nonatomic, strong)  UIWebView *webview;
@property (strong , nonatomic) UIActivityIndicatorView *activity;

@end

@implementation ShoppingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //glc 2014-5-22 添加tabbar
<<<<<<< HEAD
        //self.navigationController.navigationBarHidden = YES;
        [self.navigationController.navigationBar setHidden:YES];
        
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Mall", @"商城") image:[UIImage imageNamed:@"tabshopping"] tag:1];
        self.tabBarItem = item;
        self.backName = NSLocalizedString(@"Tomoon Mall", @"土曼商城");
        CGRect frame = CGRectChangeY(self.view.frame, self.yOffset);
        frame = CGRectChangeHeight(frame, self.height);
        UIWebView *webview = [[UIWebView alloc] initWithFrame:frame];
        webview.delegate = self;
        webview.scalesPageToFit = YES;
        self.webview = webview;
        [self.view addSubview:self.webview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shopinit:) name:@"shopdetail" object:nil];
        
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activity.frame = CGRectMake(0, 0, 60, 60);
        self.activity.center = self.view.center;
        self.activity.hidesWhenStopped = YES;
        [self.view addSubview:self.activity];
=======
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Mall", @"商城") image:[UIImage imageNamed:@"tabshopping"] tag:1];
        self.tabBarItem = item;
        self.backName = NSLocalizedString(@"Tomoon Mall", @"土曼商城");
>>>>>>> 2a3c53f1caca6d3a32ec8e4e28b41b03dd897cf8
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
<<<<<<< HEAD
	// Do any additional setup after loading the view.
=======
    //添加返回按钮 glc 2014-5-26
    [self.backBtn setHidden:YES];
    UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?25:5, 30, 30)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shopinit:) name:@"shopdetail" object:nil];
    
	// Do any additional setup after loading the view.
    CGRect frame = CGRectChangeY(self.view.frame, self.yOffset);
    frame = CGRectChangeHeight(frame, self.height);
    UIWebView *webview = [[UIWebView alloc] initWithFrame:frame];
    webview.delegate = self;
    webview.scalesPageToFit = YES;
    //[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tomoon.cn/"]]];
    self.webview = webview;
    [self.view addSubview:self.webview];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.frame = CGRectMake(0, 0, 60, 60);
    self.activity.center = self.view.center;
    self.activity.hidesWhenStopped = YES;
    [self.view addSubview:self.activity];
>>>>>>> 2a3c53f1caca6d3a32ec8e4e28b41b03dd897cf8
}

-(void)shopinit:(NSNotification *)notification
{
    NSMutableDictionary* getData = notification.object ;
    
    NSString* shopURL = [getData objectForKey:@"url"];
    
    //NSString* shopName = [getData objectForKey:@"name"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:shopURL]]];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activity stopAnimating];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
