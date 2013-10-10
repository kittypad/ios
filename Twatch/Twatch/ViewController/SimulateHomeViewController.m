//
//  SimulateHomeViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "SimulateHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SimulateHomeViewController ()

//watchBackgroundView本身显示表盘的左右列表，列表被上面的watchView遮住，左右滑动watchView，底部的左右列表显示出来。
//底部和顶部界面作为watchBackgroundView的subView，使用pangesture进行上下拖动
@property (nonatomic, strong) UIView *watchBackgroundView;

@end

@implementation SimulateHomeViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.watchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Watch_Width, Watch_Height)];
    self.watchBackgroundView.center = self.view.center;
    self.watchBackgroundView.backgroundColor = [UIColor redColor];
    self.watchBackgroundView.layer.masksToBounds = YES;
    [self.view addSubview:self.watchBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
