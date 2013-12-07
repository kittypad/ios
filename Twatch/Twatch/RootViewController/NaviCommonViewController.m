//
//  NaviCommonViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

@interface NaviCommonViewController ()

@property (nonatomic, strong) UIView *line;

@end

@implementation NaviCommonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  CGRectGetWidth(self.view.frame), IS_IOS7 ? 64 :44)];
    navigationBar.backgroundColor = RGB(243, 249, 254, 1);
    navigationBar.tag = 1322;
    [self.view addSubview:navigationBar];
    
    UIButton *goBackButton = [ViewUtils buttonWWithNormalImage:@"back.png" hiliteImage:@"back-push.png" target:self selector:@selector(goBack)];
    [goBackButton setTitle:self.backName forState:UIControlStateNormal];
    [goBackButton setTitleColor:RGB(150, 154, 158, 1) forState:UIControlStateNormal];
    goBackButton.frame = CGRectChangeOrigin(goBackButton.frame, 0, IS_IOS7 ? 35 : 15);
    goBackButton.titleLabel.font = [UIFont systemFontOfSize:GoBackNameSize];
    goBackButton.titleLabel.textColor = [UIColor colorWithHex:@"292929"];
    [navigationBar addSubview:goBackButton];
    
    CGSize size = [self.backName sizeWithFont:[UIFont systemFontOfSize:GoBackNameSize]];
    goBackButton.frame = CGRectChangeWidth(goBackButton.frame, CGRectGetWidth(goBackButton.frame) + size.width+ 20) ;//返回不好点
    
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
