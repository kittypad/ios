//
//  DialView.h
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockView.h"

#define DIALVIEW_TIMELABEL_WIDTH    240
#define DIALVIEW_TIMELABEL_HIGHT    100

typedef enum
{
	WatchType_number = 0,
    WatchType_plate = 100,//数字+圆形
    WatchType_point,//点状+圆形
    WatchType_reag   //矩形+圆形
} WatchType;

@interface DialView : UIView

- (void)updateWatchViewWithType:(WatchType)watchType;

@property WatchType currentType;


@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) ClockView *clockview;
@end
