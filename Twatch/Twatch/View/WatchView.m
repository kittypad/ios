//
//  WatchView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-10.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "WatchView.h"

@interface WatchView (Private)

- (void)pullUp:(UIPanGestureRecognizer *)gesture;
- (void)pullDown:(UIPanGestureRecognizer *)gesture;

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
        subViewFrame.origin.x = 0.0;
        subViewFrame.origin.y = -bounds.size.height;
        subViewFrame.size.height = bounds.size.height+Watch_PullDown_Height;
        
        _topView = [[UIView alloc] initWithFrame:subViewFrame];
        _topView.backgroundColor = [UIColor grayColor];
        [self addSubview:_topView];
        
        _notificationView = [[NotificationView alloc] initWithFrame:bounds];
        [_topView addSubview:_notificationView];
        
        UIView *pullUpView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, bounds.size.height-Watch_PullUp_Height, bounds.size.width, Watch_PullUp_Height)];
        [_topView addSubview:pullUpView1];
        UIPanGestureRecognizer *g1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullUp:)];
        [pullUpView1 addGestureRecognizer:g1];
        
        UIView *pullDownView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, bounds.size.height, bounds.size.width, Watch_PullDown_Height)];
        [_topView addSubview:pullDownView1];
        UIPanGestureRecognizer *g3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullDown:)];
        [pullDownView1 addGestureRecognizer:g3];
        
        //切换手表样式界面
        subViewFrame.origin.y = bounds.size.height-Watch_PullUp_Height;
        subViewFrame.size.height = bounds.size.height+Watch_PullUp_Height;
        
        _bottomView = [[UIView alloc] initWithFrame:subViewFrame];
        _bottomView.backgroundColor = [UIColor grayColor];
        [self addSubview:_bottomView];
        
        subViewFrame = bounds;
        subViewFrame.origin.y = Watch_PullUp_Height;
        _switchWatchView = [[SwitchWatchView alloc] initWithFrame:subViewFrame];
        [_bottomView addSubview:_switchWatchView];
        
        UIView *pullUpView2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, bounds.size.width, Watch_PullUp_Height)];
        [_bottomView addSubview:pullUpView2];
        UIPanGestureRecognizer *g2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullUp:)];
        [pullUpView2 addGestureRecognizer:g2];
        
        UIView *pullDownView2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, Watch_PullUp_Height, bounds.size.width, Watch_PullDown_Height)];
        [_bottomView addSubview:pullDownView2];
        UIPanGestureRecognizer *g4 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullDown:)];
        [pullDownView2 addGestureRecognizer:g4];
        
        _isAnimating = NO;
    }
    return self;
}

- (void)pullUp:(UIPanGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self];
//    NSLog(@"%f", p.y);
    if (p.y<0 || p.y>self.frame.size.height || _isAnimating) {
        return;
    }
    if (UIGestureRecognizerStateBegan == gesture.state) {
        _pullView = gesture.view.superview;
        if (_bottomView == _pullView) {
            _topView.hidden = YES;
        }
    }
    else if ((UIGestureRecognizerStateEnded == gesture.state) ||
             (UIGestureRecognizerStateCancelled == gesture.state)) {
        CGRect frame = _pullView.frame;
        if (_topView == _pullView) {
            if (frame.origin.y<-Watch_PullUp_Height) {
                _desY = -self.frame.size.height;
            }
            else {
                _desY = 0.0;
                _bottomView.hidden = NO;
            }
        }
        else {
            if (frame.origin.y<self.frame.size.height-2*Watch_PullUp_Height) {
                _desY = -Watch_PullUp_Height;
            }
            else {
                _desY = self.frame.size.height-Watch_PullUp_Height;
                _topView.hidden = NO;
            }
        }
        _isAnimating = YES;
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             CGRect frame = _pullView.frame;
                             frame.origin.y = _desY;
                             _pullView.frame = frame;
                         }
                         completion:^(BOOL finished){
                             _isAnimating = NO;
                         }];
        _pullView = nil;
    }
    else {
        CGRect frame = _pullView.frame;
        frame.origin.y += p.y-_lastY;
        _pullView.frame = frame;
    }
    _lastY = p.y;
}

- (void)pullDown:(UIPanGestureRecognizer *)gesture
{
    
}

@end
