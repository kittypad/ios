//
//  WatchView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-10.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "WatchView.h"

@interface WatchView (Private)

- (void)pan:(UIPanGestureRecognizer *)gesture;

@end


@implementation WatchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        //手表背景
        _backgroundView = [[UIImageView alloc] initWithFrame:bounds];
        [self addSubview:_backgroundView];
        
        //控制手表左右滑动
        _scrollView = [[UIScrollView alloc] initWithFrame:bounds];
        _scrollView.contentSize = CGSizeMake(frame.size.width*3, frame.size.height);
        _scrollView.contentOffset = CGPointMake(frame.size.width, 0.0);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor purpleColor];
        [self addSubview:_scrollView];
        
        CGRect subViewFrame = bounds;
        
        //常用Apps界面
        _commonAppsView = [[CommonAppsView alloc] initWithFrame:subViewFrame];
        [_scrollView addSubview:_commonAppsView];
        subViewFrame.origin.x += subViewFrame.size.width;
        
        //表盘界面
        _dialView = [[DialView alloc] initWithFrame:subViewFrame];
        [_scrollView addSubview:_dialView];
        subViewFrame.origin.x += subViewFrame.size.width;
        
        //所有Apps界面
        _allAppsView = [[AllAppsView alloc] initWithFrame:subViewFrame];
        [_scrollView addSubview:_allAppsView];
        
        //通知界面
        subViewFrame.origin.x = -bounds.size.height;
        _notificationView = [[NotificationView alloc] initWithFrame:bounds];
        [self addSubview:_notificationView];
        
        //切换手表样式界面
        subViewFrame.origin.x = bounds.size.height;
        _switchWatchView = [[SwitchWatchView alloc] initWithFrame:bounds];
        [self addSubview:_switchWatchView];
        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:gesture];
        
        _isAnimating = NO;
    }
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
//    CGPoint p = [gesture locationInView:self];
//    if (p.y<0 || p.y>self.frame.size.height || _isAnimating) {
//        return;
//    }
//    if (UIGestureRecognizerStateBegan == gesture.state) {
//        if (_notificationView.frame.origin.y >= -2.0) {
//            if (p.y > self.frame.size.height-self.pullUpHeight) {
//                _pullView = _notificationView;
//                _desY = -self.frame.size.height;
//                _isUp = YES;
//            }
//        }
//        else if (_switchWatchView.frame.origin.y <= 2.0) {
//            if (p.y > self.frame.size.height-self.pullDownHeight) {
//                _pullView = _switchWatchView;
//                _desY = self.frame.size.height;
//                _isUp = NO;
//            }
//        }
//        else if (p.y < self.pullDownHeight) {
//            _pullView = _notificationView;
//            _desY = 0.0;
//            _isUp = NO;
//        }
//        else if (p.y > self.frame.size.height-self.pullUpHeight) {
//            _pullView = _switchWatchView;
//            _desY = 0.0;
//            _isUp = YES;
//        }
//    }
//    else if (!_pullView) {
//        return;
//    }
//    else if ((UIGestureRecognizerStateEnded == gesture.state) &&
//             (UIGestureRecognizerStateCancelled == gesture.state)) {
//        
//    }
//    else {
//        
//    }
//    _lastY = p.y;
}

@end
