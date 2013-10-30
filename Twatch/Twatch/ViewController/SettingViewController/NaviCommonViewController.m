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
    
    UIButton *goBackButton = [FactoryMethods buttonWWithNormalImage:@"back.png" hiliteImage:nil target:self selector:@selector(goBack)];
    goBackButton.frame = CGRectChangeOrigin(goBackButton.frame, 15, 30);
    [self.view addSubview:goBackButton];
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
