//
//  InitViewController.m
//  Twatch
//
//  Created by yugong on 14-5-22.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "InitViewController.h"

#import "CommonTabBarViewController.h"
#import "AppCenterViewController.h"
#import "SettingViewController.h"
#import "MyCenterViewController.h"
#import "ShoppingViewController.h"

@interface InitViewController ()

@end

@implementation InitViewController

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
    // Do any additional setup after loading the view.
    
    UIButton* initButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 60)];
    [initButton setBackgroundColor:[UIColor grayColor]];
    [initButton addTarget:self action:@selector(ToTabBarView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:initButton];
    
}

-(void)ToTabBarView
{
    NSMutableArray* items = [[NSMutableArray alloc] init];
    AppCenterViewController* appCenterList = [[AppCenterViewController alloc] init];
    [items addObject:appCenterList];
    ShoppingViewController* shoppingController = [[ShoppingViewController alloc] init];
    [items addObject:shoppingController];
    MyCenterViewController* myCenterController = [[MyCenterViewController alloc] init];
    [items addObject:myCenterController];
    SettingViewController* settingViewController = [[SettingViewController alloc] init];
    [items addObject:settingViewController];
    // items是数组，每个成员都是UIViewController
    CommonTabBarViewController* tabBar = [[CommonTabBarViewController alloc] init];
    //[tabBar setTitle:@"TabBarController"];
    //tabBar.tabBar.selectedImageTintColor = [UIColor redColor];
    [tabBar setViewControllers:items];
    
    [self presentModalViewController : tabBar animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
