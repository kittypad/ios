//
//  RootViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "RootViewController.h"
#import "SimulateHomeViewController.h"

@interface RootViewController (private)

- (void)simulateBtnPressed:(id)sender;
- (void)scanBtnPressed:(id)sender;

@end

@implementation RootViewController

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
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor greenColor];
    
    _simulateButton = [[UIButton alloc] initWithFrame:CGRectMake(70.0, 300.0, 55.0, 30.0)];
    [_simulateButton setTitle:@"模拟" forState:UIControlStateNormal];
    [_simulateButton addTarget:self action:@selector(simulateBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_simulateButton];
    
    _scanButton = [[UIButton alloc] initWithFrame:CGRectMake(195.0, 300.0, 55.0, 30.0)];
    [_scanButton setTitle:@"扫描" forState:UIControlStateNormal];
    [_scanButton addTarget:self action:@selector(scanBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)simulateBtnPressed:(id)sender
{
    SimulateHomeViewController *vc = [[SimulateHomeViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scanBtnPressed:(id)sender
{
    
}

@end
