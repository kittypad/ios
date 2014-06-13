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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

	// Do any additional setup after loading the view.


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
