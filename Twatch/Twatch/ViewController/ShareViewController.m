//
//  ShareViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-11-17.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareCell.h"
#import <ShareSDK/ShareSDK.h>

@interface ShareViewController ()

@property (nonatomic, strong) NSArray *listNames;

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.listNames = [NSArray arrayWithObjects:@"微信",@"人人",@"豆瓣",@"腾讯微博",@"新浪", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    self.backName = @"分享";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    PSTCollectionViewFlowLayout *watchLayout = [[PSTCollectionViewFlowLayout alloc] init];
    watchLayout.itemSize = CGSizeMake(232/2, 204/2);
    watchLayout.sectionInset = UIEdgeInsetsMake(60/2, 63/2 , 0/2, 63/2);
    watchLayout.minimumLineSpacing = 45/2;
    watchLayout.minimumInteritemSpacing = 45/2;
    watchLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    PSTCollectionView *watchCollectiongView = [[PSTCollectionView alloc] initWithFrame:CGRectChangeOrigin(self.view.frame, 0, (IS_IOS7 ? 64 : 44))
                                                                  collectionViewLayout:watchLayout];
    watchCollectiongView.delegate = self;
    watchCollectiongView.dataSource = self;
    watchCollectiongView.pagingEnabled = YES;
    [watchCollectiongView registerClass:[ShareCell class] forCellWithReuseIdentifier:@"ShareCell"];
    [self.view addSubview:watchCollectiongView];
}

//MARK: PSTCollectionViewDataSource
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listNames.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ShareCell"
                                                                            forIndexPath:indexPath];
    
    [((ShareCell *)cell) configCellWithInfo:self.listNames[indexPath.row] atIndex:indexPath.row];
    
    return cell;
}

//MARK: PSTCollectionViewDelegate
- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"choose ");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
