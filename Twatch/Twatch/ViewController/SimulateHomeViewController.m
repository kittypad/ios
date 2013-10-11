//
//  SimulateHomeViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "SimulateHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchView.h"

@interface SimulateHomeViewController ()

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
    
    NSLog(@"%f,%f", self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.watchView = [[WatchView alloc] initWithFrame:CGRectMake(0, 0, Watch_Width, Watch_Height)];
    self.watchView.center = self.view.center;
    self.watchView.layer.masksToBounds = YES;
    [self.view addSubview:self.watchView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
