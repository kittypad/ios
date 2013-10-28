//
//  SwitchWatchView.h
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "DialView.h"

@class SwitchWatchView;
typedef void (^SelectAWatchBlock)(SwitchWatchView *view,WatchType type);

@interface SwitchWatchView : UIView<PSTCollectionViewDataSource,PSTCollectionViewDelegate>

@property (nonatomic, copy) SelectAWatchBlock selectAWatchBlock;

@end

