//
//  ViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "RootViewController.h"
#import "RootViewController+BleManager.h"

#import "AppCenterViewController.h"
#import "WatchStyleViewController.h"
#import "ConnectionViewController.h"
#import "SettingViewController.h"
#import "SimulatorViewController.h"
#import "ShoppingViewController.h"

#import "RootCell.h"
#import "RootHeaderView.h"

@interface RootViewController ()

@property (nonatomic, strong) NSArray *titleSourceArray;
@property (nonatomic, strong) NSArray *imageSourceArray;
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
    layout.itemSize = CGSizeMake(262/2, IS_IPHONE_5 ? 290/2 : 258/2);
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
    layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.frame), IS_IPHONE_5 ? 70 : 50);
    
    
    UICollectionView *rootView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    rootView.delegate = self;
    rootView.dataSource = self;
    rootView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rooView_bg.png"]];
    [rootView registerClass:[RootCell class] forCellWithReuseIdentifier:@"RootCell"];
    [rootView registerClass:[RootHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RootHeaderView"];
    [self.view addSubview:rootView];
    
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)prepareDefaultData
{
    self.titleSourceArray = [NSArray arrayWithObjects:@"应用中心",@"表盘背景",@"同步连接",@"更多设置",@"手表模拟器",@"土曼商城", nil];
    self.imageSourceArray = [NSArray arrayWithObjects:@"应用.png",@"背景.png",@"同步.png",@"更多.png",@"手表.png",@"土曼.png", nil];
    self.subControllerSourceArray = [NSArray arrayWithObjects:@"AppCenterViewController",
                                     @"WatchStyleViewController",
                                     @"ConnectionViewController",
                                     @"SettingViewController",
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
    
    [((RootCell *)cell) configCellWithTitle:self.titleSourceArray[indexPath.row]
                                  imageName:self.imageSourceArray[indexPath.row]];
    if (indexPath.row < 2) {
        cell.contentView.backgroundColor = RGB(149, 179, 49, 1);
    }else{
        cell.contentView.backgroundColor = RGB(77, 175, 224, 1);
    }
    
    return cell;
}

- (int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = self.subControllerSourceArray[indexPath.row];
    UIViewController *aController = nil;
    
    if ([className isEqualToString:@"ConnectionViewController"]) {
        if (self.connectionController == nil) {
            aController = [[NSClassFromString(className) alloc] init];
            self.connectionController = (ConnectionViewController *)aController;
        }else{
            aController = self.connectionController;
        }
    }else{
        aController = [[NSClassFromString(className) alloc] init];
    }
    
    [self.navigationController pushViewController:aController animated:YES];

    ((AppCenterViewController *)aController).backName = self.titleSourceArray[indexPath.row];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                    withReuseIdentifier:@"RootHeaderView"
                                                           forIndexPath:indexPath];
    }
    
    return header;
}
@end
