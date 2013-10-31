//
//  FeedBackViewController.m
//  Twatch
//
//  Created by wangjizeng on 13-10-31.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UIPlaceHolderTextView.h"
@interface FeedBackViewController ()

@end

@implementation FeedBackViewController

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
    // Do any additional setup after loading the view from its nib.
    
    UIPlaceHolderTextView *feedBackTextField = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, 80, 280, 200)];
    feedBackTextField.showsVerticalScrollIndicator = YES;
    feedBackTextField.showsHorizontalScrollIndicator = YES;
    [feedBackTextField setPlaceholder:@"亲，求意见^_^"];
    feedBackTextField.font = [UIFont fontWithName:@"Arial" size:12.0];
    [feedBackTextField setBackgroundColor:[UIColor clearColor]];
    feedBackTextField.layer.borderWidth = 0.5;
    UIColor *color = [UIColor grayColor];
    feedBackTextField.layer.borderColor = color.CGColor;
    [self.view addSubview:feedBackTextField];
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(240, 285, 60, 30)];
    
    [sendBtn setBackgroundColor:[UIColor blueColor]];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.view addSubview:sendBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
