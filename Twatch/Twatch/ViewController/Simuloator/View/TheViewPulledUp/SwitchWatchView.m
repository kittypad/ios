//
//  SwitchWatchView.m
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "SwitchWatchView.h"
#import "WatchVell.h"
#import "DialView.h"

static NSString *Watch_Cell_Idetifier = @"WatchVell";

@interface SwitchWatchView ()

@property (strong, nonatomic) NSArray *watchStyleImageNames;

@end

@implementation SwitchWatchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        PSTCollectionViewFlowLayout *watchLayout = [[PSTCollectionViewFlowLayout alloc] init];
        watchLayout.itemSize = CGSizeMake(Watch_Width-Watch_PullUp_Height, Watch_Height-Watch_PullUp_Height);
        watchLayout.sectionInset = UIEdgeInsetsMake(Watch_PullUp_Height/2, Watch_PullUp_Height/2 , Watch_PullUp_Height/2, Watch_PullUp_Height/2);
        watchLayout.minimumLineSpacing = Watch_PullUp_Height;
        watchLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        PSTCollectionView *watchCollectiongView = [[PSTCollectionView alloc] initWithFrame:CGRectChangeOrigin(frame, 0, 0)
                                                                      collectionViewLayout:watchLayout];
        watchCollectiongView.delegate = self;
        watchCollectiongView.dataSource = self;
        watchCollectiongView.pagingEnabled = YES;
        [watchCollectiongView registerClass:[WatchVell class] forCellWithReuseIdentifier:Watch_Cell_Idetifier];
        [self addSubview:watchCollectiongView];
        
        self.watchStyleImageNames = [NSArray arrayWithObjects:@"数字时钟.png",@"圆点时钟.png",@"长圆时钟.png", nil];
    }
    return self;
}

//MARK: PSTCollectionViewDataSource
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.watchStyleImageNames.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Watch_Cell_Idetifier
                                                                            forIndexPath:indexPath];
    
    [((WatchVell *)cell) configCellWithInfo:self.watchStyleImageNames[indexPath.row]];
    
    return cell;
}

//MARK: PSTCollectionViewDelegate
- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectAWatchBlock(self,indexPath.row + 100);
}

@end
