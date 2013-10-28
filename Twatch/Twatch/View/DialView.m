//
//  DialView.m
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "DialView.h"

@implementation DialView

- (void)updateWatchViewWithType:(WatchType)type
{
    if (self.currentType == type) return;
    self.currentType = type;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *hour = @"", *minite = @"", *second = @"",*cycle = @"", *background = @"";
    
    self.clockview = [[ClockView alloc] initWithFrame:CGRectMake(0, 0, 210, 210)];
    switch (type) {
        case WatchType_number:
        {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DIALVIEW_TIMELABEL_WIDTH, DIALVIEW_TIMELABEL_HIGHT)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            _timeLabel.font = [UIFont systemFontOfSize:48.0f];
            [self addSubview:_timeLabel];
            
            _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, DIALVIEW_TIMELABEL_HIGHT, DIALVIEW_TIMELABEL_WIDTH, DIALVIEW_TIMELABEL_HIGHT)];
            _dateLabel.backgroundColor = [UIColor clearColor];
            _dateLabel.font = [UIFont systemFontOfSize:24.0f];
            _dateLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_dateLabel];
            
            _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
        }
            break;
        case WatchType_plate:
            hour = @"时针.png";minite=@"分针.png";second = @"秒针.png"; cycle = @"圆点.png"; background = @"数字表盘.png";
            self.clockview.hourPoint = CGPointMake(0.5,0.0);
            self.clockview.minPoint = CGPointMake(0.5,0.0);
            self.clockview.secPoint = CGPointMake(0.5,0.035);
            break;
        case WatchType_point:
            hour = @"point_watch_hour.png";minite=@"point_watch_minite.png";second = @"point_watch_second.png"; cycle = nil; background = @"point_watch.png";
            self.clockview.hourPoint = CGPointMake(0.5,0.23);
            self.clockview.minPoint = CGPointMake(0.5,0.22);
            self.clockview.secPoint = CGPointMake(0.5,0.235);
            break;
        case WatchType_reag:
            hour = @"Rectangle_watch_hour.png";minite=@"Rectangle_watch_minite.png";second = @"Rectangle_watch_second.png"; cycle = nil; background = @"Rectangle_watch.png";
            self.clockview.hourPoint = CGPointMake(0.5,0.0);
            self.clockview.minPoint = CGPointMake(0.5,0.0);
            self.clockview.secPoint = CGPointMake(0.5,0.0);
            break;
        default:
            break;
    }
    
    [self.clockview setClockBackgroundImage:[UIImage imageNamed:background].CGImage];
    [self.clockview setHourHandImage:[UIImage imageNamed:hour].CGImage];
    [self.clockview setMinHandImage:[UIImage imageNamed:minite].CGImage];
    [self.clockview setSecHandImage:[UIImage imageNamed:second].CGImage];
    [self.clockview setClockCenterImage:[UIImage imageNamed:cycle].CGImage];
    self.clockview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self showClock];
    [self.clockview start];
    self.clockview.center = CGPointMake(Watch_Width/2, Watch_Height/2);
}

- (id)initWithFrame:(CGRect)frame watchType:(WatchType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (type == WatchType_number)
        {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DIALVIEW_TIMELABEL_WIDTH, DIALVIEW_TIMELABEL_HIGHT)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            _timeLabel.font = [UIFont systemFontOfSize:48.0f];
            [self addSubview:_timeLabel];
            
            _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, DIALVIEW_TIMELABEL_HIGHT, DIALVIEW_TIMELABEL_WIDTH, DIALVIEW_TIMELABEL_HIGHT)];
            _dateLabel.backgroundColor = [UIColor clearColor];
            _dateLabel.font = [UIFont systemFontOfSize:24.0f];
            _dateLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_dateLabel];
            
            _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
        }
        else if (type == WatchType_plate)
        {
            self.clockview = [[ClockView alloc] initWithFrame:CGRectMake(0, 0, 210, 210)];
            [self.clockview setClockBackgroundImage:[UIImage imageNamed:@"数字表盘.png"].CGImage];
            [self.clockview setHourHandImage:[UIImage imageNamed:@"时针.png"].CGImage];
            [self.clockview setMinHandImage:[UIImage imageNamed:@"分针.png"].CGImage];
            [self.clockview setSecHandImage:[UIImage imageNamed:@"秒针.png"].CGImage];
            [self.clockview setClockCenterImage:[UIImage imageNamed:@"圆点.png"].CGImage];
            self.clockview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self showClock];
            [self.clockview start];
            self.clockview.center = CGPointMake(Watch_Width/2, Watch_Height/2);
        }
        else
        {
            //do 
        }
    }
    return self;
}

-(void)showClock
{
    [self addSubview:self.clockview];
}

- (void) updateClock:(NSTimer *)theTimer{
	
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | kCFCalendarUnitWeekdayOrdinal |NSWeekdayCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSString *weekStr = nil;
    switch ([dateComponent weekday])
    {
        case 1:
            weekStr = @"星期一";
            break;
        case 2:
            weekStr = @"星期二";
            break;
        case 3:
            weekStr = @"星期三";
            break;
        case 4:
            weekStr = @"星期四";
            break;
        case 5:
            weekStr = @"星期五";
            break;
        case 6:
            weekStr = @"星期六";
            break;
        case 7:
            weekStr = @"星期天";
            break;
        default:
            break;
    }
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[dateComponent hour],[dateComponent minute],[dateComponent second]];
    _dateLabel.text = [NSString stringWithFormat:@"%d/%02d/%02d %@",[dateComponent year],[dateComponent month],[dateComponent day],weekStr];
    
}

@end
