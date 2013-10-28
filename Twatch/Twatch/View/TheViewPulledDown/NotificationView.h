//
//  NotificationView.h
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

typedef void (^SelectANotificationBlock)(id notificationInfo);

@interface NotificationView : UIView<PSTCollectionViewDataSource,PSTCollectionViewDelegate>

@property (nonatomic, copy) SelectANotificationBlock selectANotificationBlock;

@end
