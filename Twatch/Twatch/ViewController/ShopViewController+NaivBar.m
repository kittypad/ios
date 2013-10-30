//
//  ShopViewController+NaivBar.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-23.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ShopViewController+NaivBar.h"

@implementation ShopViewController (NaivBar)

- (void)prepareBottomNavigationbar
{
    UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    naviBar.backgroundColor = RGB(277, 222, 218, 1);
    [self.view addSubview:naviBar];
    
    UIButton *left = [FactoryMethods buttonWWithNormalImage:@"back.png" hiliteImage:nil target:self selector:@selector(goback:)] ;
    left.center = CGPointMake(CGRectGetWidth(naviBar.frame)/8, CGRectGetHeight(naviBar.frame)/2);
    [naviBar addSubview:left];
    
    UIButton *right = [FactoryMethods buttonWWithNormalImage:@"refresh.png" hiliteImage:nil target:self selector:@selector(refreshWebView:)] ;
    right.center = CGPointMake(CGRectGetWidth(naviBar.frame)*7/8, CGRectGetHeight(naviBar.frame)/2);
    [naviBar addSubview:right];
}


- (void)goback:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)refreshWebView:(UIButton *)sender
{
    [webview reload];
}

@end
