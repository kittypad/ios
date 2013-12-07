//
//  NotificationView.m
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "NotificationView.h"
#import "NotificationCell.h"

static NSString *Notification_Cell_Idetifier = @"NotificationCell";

@implementation NotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        
        PSTCollectionViewFlowLayout *watchLayout = [[PSTCollectionViewFlowLayout alloc] init];
        watchLayout.itemSize = CGSizeMake(Watch_Width, NotificationCell_Height);
        watchLayout.sectionInset = UIEdgeInsetsMake(0, 0 , Watch_PullUp_Height/2, 0);
        watchLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        PSTCollectionView *watchCollectiongView = [[PSTCollectionView alloc] initWithFrame:CGRectChangeOrigin(frame, 0, 0)
                                                                      collectionViewLayout:watchLayout];
        watchCollectiongView.delegate = self;
        watchCollectiongView.dataSource = self;
        [watchCollectiongView registerClass:[NotificationCell class] forCellWithReuseIdentifier:Notification_Cell_Idetifier];
        [self addSubview:watchCollectiongView];
    }
    return self;
}

//MARK: PSTCollectionViewDataSource
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Notification_Cell_Idetifier
                                                                            forIndexPath:indexPath];
    
    [((NotificationCell *)cell) configCellWithInfo:indexPath];
    
    return cell;
}

//MARK: PSTCollectionViewDelegate
- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectANotificationBlock(indexPath);
}

@end
