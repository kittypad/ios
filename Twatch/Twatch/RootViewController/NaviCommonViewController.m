//
//  NaviCommonViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

#define kBackButtonSize  18.0

@interface BackNavigationButton : UIButton

@end

@implementation BackNavigationButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(kBackButtonSize+2.0, 0.0, contentRect.size.width-kBackButtonSize-2.0, contentRect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0.0, (contentRect.size.height-kBackButtonSize)/2, kBackButtonSize, kBackButtonSize);
}

@end

@interface NaviCommonViewController ()

@property (nonatomic, strong) UIView *line;

@end

@implementation NaviCommonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  CGRectGetWidth(self.view.frame), IS_IOS7 ? 64 :44)];
//    navigationBar.backgroundColor = RGB(243, 249, 254, 1);
    navigationBar.backgroundColor = [UIColor whiteColor];
    navigationBar.tag = 1322;
    [self.view addSubview:navigationBar];
    
    UIFont *font = [UIFont systemFontOfSize:GoBackNameSize];
    CGSize size = [self.backName sizeWithFont:font];
    BackNavigationButton *goBackButton = [[BackNavigationButton alloc] initWithFrame:CGRectMake(22.0, IS_IOS7 ? 20.0 : 0.0, size.width+kBackButtonSize+2.0, 44.0)];
    [goBackButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [goBackButton setImage:[UIImage imageNamed:@"back-push.png"] forState:UIControlStateHighlighted];
    [goBackButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    goBackButton.titleLabel.font = font;
//    [goBackButton setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
    [goBackButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [goBackButton setTitle:self.backName forState:UIControlStateNormal];
    [navigationBar addSubview:goBackButton];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navigationBar.frame)-1, CGRectGetWidth(self.view.frame), 1)];
    line.tag = 1323;
    line.backgroundColor = RGB(101, 158, 224, 1);
    [navigationBar addSubview:line];
    self.line = line;
    
    self.view.backgroundColor = RGB(243, 249, 254, 1);
    
    self.yOffset = CGRectGetMaxY(self.line.frame);
    self.height =  CGRectGetHeight(self.view.frame) - self.yOffset;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setLineHidden:(BOOL)hidden
{
    [[self.view viewWithTag:1323] setHidden:hidden];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
