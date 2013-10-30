//
//  ShopViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-23.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopViewController+NaivBar.h"

@interface ShopViewController ()

@property (strong , nonatomic) UIActivityIndicatorView *activity;

@end

@implementation ShopViewController

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
	// Do any additional setup after loading the view.
    CGRect frame = self.view.frame; frame.size.height -= 44;
    webview = [[UIWebView alloc] initWithFrame:frame];
    webview.delegate = self;
    webview.scalesPageToFit = YES;
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tomoon.cn/"]]];
    
    [self.view addSubview:webview];
    
    [self prepareBottomNavigationbar];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.frame = CGRectMake(0, 0, 60, 60);
    self.activity.center = self.view.center;
    self.activity.hidesWhenStopped = YES;
    [self.view addSubview:self.activity];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activity stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
