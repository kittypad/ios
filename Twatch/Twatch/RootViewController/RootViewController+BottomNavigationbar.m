//
//  RootViewController+BottomNavigationbar.m
//  Twatch
//
//  Created by yxl on 13-10-22.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController+BottomNavigationbar.h"
#import "ShopViewController.h"

@implementation RootViewController (BottomNavigationbar)

- (void)prepareBottomNavigationbar
{
    UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    naviBar.backgroundColor = RGB(277, 222, 218, 0.8);
    [self.view addSubview:naviBar];
    
    UIButton *left = [FactoryMethods buttonWWithNormalImage:@"购物.png" hiliteImage:@"购物-按下.png" target:self selector:@selector(shopButtonClicked:)] ;
    left.center = CGPointMake(CGRectGetWidth(naviBar.frame)/2, CGRectGetHeight(naviBar.frame)/2);
    [naviBar addSubview:left];
    
//    UIButton *right = [FactoryMethods buttonWWithNormalImage:@"扫描.png" hiliteImage:@"扫描-按下.png" target:self selector:@selector(scanButtonClicked:)] ;
//    right.center = CGPointMake(CGRectGetWidth(naviBar.frame)*3/4, CGRectGetHeight(naviBar.frame)/2);
//    [naviBar addSubview:right];
//    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(naviBar.frame))];
//    line.backgroundColor = [UIColor whiteColor];
//    line.center = CGPointMake(CGRectGetWidth(naviBar.frame)/2, CGRectGetHeight(naviBar.frame)/2);
//    [naviBar addSubview:line];
}



- (void)shopButtonClicked:(UIButton *)sender
{
    ShopViewController *shop = [[ShopViewController alloc] init];
    [self.navigationController pushViewController:shop animated:YES];
}

@end
