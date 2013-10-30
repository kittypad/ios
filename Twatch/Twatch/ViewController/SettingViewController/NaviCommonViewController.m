//
//  NaviCommonViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

@interface NaviCommonViewController ()

@end

@implementation NaviCommonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *goBackButton = [FactoryMethods buttonWWithNormalImage:@"back.png" hiliteImage:@"back-push.png" target:self selector:@selector(goBack)];
    [goBackButton setTitle:self.backName forState:UIControlStateNormal];
    [goBackButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    goBackButton.frame = CGRectChangeOrigin(goBackButton.frame, 10, 30);
    goBackButton.titleLabel.font = [UIFont systemFontOfSize:GoBackNameSize];
    [self.view addSubview:goBackButton];
    
    CGSize size = [self.backName sizeWithFont:[UIFont systemFontOfSize:GoBackNameSize]];
    goBackButton.frame = CGRectChangeWidth(goBackButton.frame, CGRectGetWidth(goBackButton.frame) + size.width);
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, IS_IOS7 ? 64 :44, CGRectGetWidth(self.view.frame), 1)];
    line.backgroundColor = RGB(101, 158, 224, 1);
    [self.view addSubview:line];
    
    self.view.backgroundColor = RGB(243, 249, 254, 1);
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
