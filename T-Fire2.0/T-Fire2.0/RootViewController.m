//
//  ViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "RootViewController.h"
#import "AppCenterViewController.h"
#import "WatchStyleViewController.h"
#import "ConnectionViewController.h"
#import "MoreSettingViewController.h"
#import "SimulatorViewController.h"
#import "ShoppingViewController.h"
#import "RootCell.h"

@interface RootViewController ()

@property (nonatomic, strong) NSArray *titleSourceArray;
@property (nonatomic, strong) NSArray *subControllerSourceArray;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    [self prepareDefaultData];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/3);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UICollectionView *rootView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    rootView.delegate = self;
    rootView.dataSource = self;
    rootView.backgroundColor = [UIColor whiteColor];
    [rootView registerClass:[RootCell class] forCellWithReuseIdentifier:@"RootCell"];
    [self.view addSubview:rootView];
}

- (void)prepareDefaultData
{
    self.titleSourceArray = [NSArray arrayWithObjects:@"应用中心",@"表盘背景",@"同步连接",@"更多设置",@"手表模拟器",@"土曼商城", nil];
    self.subControllerSourceArray = [NSArray arrayWithObjects:@"AppCenterViewController",
                                     @"WatchStyleViewController.h",
                                     @"ConnectionViewController",
                                     @"MoreSettingViewController",
                                     @"SimulatorViewController",
                                     @"ShoppingViewController", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RootCell" forIndexPath:indexPath];
    
    [((RootCell *)cell) configCellWithTitle:self.titleSourceArray[indexPath.row]];
    
    return cell;
}

- (int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = self.subControllerSourceArray[indexPath.row];
    UIViewController *aController = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
    
    NSLog(@"---%@",self.navigationController);
    [self.navigationController pushViewController:aController animated:YES];
    
    aController.title = self.titleSourceArray[indexPath.row];
}

@end
