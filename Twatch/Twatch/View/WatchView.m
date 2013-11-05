//
//  WatchView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-10.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "WatchView.h"

@interface WatchView ()

- (void)pullUp:(UIPanGestureRecognizer *)gesture;
- (void)pullDown:(UIPanGestureRecognizer *)gesture;
- (void)pullUpFinished;
- (void)pullDownFinished;

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
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        CGRect subViewFrame = bounds;
        
        //常用Apps界面
        _commonAppsView = [[CommonAppsView alloc] initWithFrame:subViewFrame];
        [_scrollView addSubview:_commonAppsView];
        subViewFrame.origin.x += subViewFrame.size.width;
        
        //表盘界面
        _dialView = [[DialView alloc] initWithFrame:subViewFrame];
        [_scrollView addSubview:_dialView];
        [_dialView updateWatchViewWithType:WatchType_plate];
        
        subViewFrame.origin.x += subViewFrame.size.width;
        
        //所有Apps界面
        _allAppsView = [[AllAppsView alloc] initWithFrame:subViewFrame];
        [_scrollView addSubview:_allAppsView];
        
        //通知界面
        subViewFrame.origin.x = 0.0;
        subViewFrame.origin.y = -bounds.size.height;
        subViewFrame.size.height = bounds.size.height+Watch_PullDown_Height;
        _topView = [[UIView alloc] initWithFrame:subViewFrame];
        _topView.backgroundColor = [UIColor clearColor];
        [self addSubview:_topView];
        
        _notificationView = [[NotificationView alloc] initWithFrame:bounds];
        [_topView addSubview:_notificationView];
        _notificationView.selectANotificationBlock = ^(id notificationInfo){
            NSLog(@"选择了通知: %@", notificationInfo);
        };
        
        //通知界面的上拉View
        UIView *pullUpView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, bounds.size.height-Watch_PullUp_Height, bounds.size.width, Watch_PullUp_Height)];
        [_topView addSubview:pullUpView1];
        UIPanGestureRecognizer *g1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullUp:)];
        [pullUpView1 addGestureRecognizer:g1];
        
        //通知界面的下拉View
//        UIView *pullDownView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, bounds.size.height, bounds.size.width, Watch_PullDown_Height)];
//        [_topView addSubview:pullDownView1];
//        UIPanGestureRecognizer *g3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullDown:)];
//        [pullDownView1 addGestureRecognizer:g3];
        
        //切换手表样式界面
        subViewFrame.origin.y = bounds.size.height-Watch_PullUp_Height;
        subViewFrame.size.height = bounds.size.height+Watch_PullUp_Height;
        _bottomView = [[UIView alloc] initWithFrame:subViewFrame];
        _bottomView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bottomView];
        
        subViewFrame = bounds;
        subViewFrame.origin.y = Watch_PullUp_Height;
        _switchWatchView = [[SwitchWatchView alloc] initWithFrame:subViewFrame];
        [_bottomView addSubview:_switchWatchView];
        
        __weak typeof(self) weakself = self;
        __weak typeof(_topView) top = _topView;
        __weak typeof(_bottomView) bottom = _bottomView;
        _switchWatchView.selectAWatchBlock = ^(SwitchWatchView *view, WatchType type){
            if (weakself.dialView.currentType == type){
                NSLog(@"重复选择了手表样式 : %d", type); return;
            }
            
            NSLog(@"选择了手表样式 : %d", type);
            [weakself.dialView updateWatchViewWithType:type];
            
            top.hidden = NO; bottom.hidden = NO;
            
            [UIView animateWithDuration:.3 animations:^{
                bottom.frame = CGRectChangeY(bottom.frame, weakself.frame.size.height-Watch_PullUp_Height);
            }];
        };
        
        //切换手表样式界面的上拉View
        UIView *pullUpView2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, bounds.size.width, Watch_PullUp_Height)];
        [_bottomView addSubview:pullUpView2];
        UIPanGestureRecognizer *g2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullUp:)];
        [pullUpView2 addGestureRecognizer:g2];
        
        //切换手表样式界面的下拉View
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
    //手指滑出手表界面或动画正在进行时结束上拉
    if (p.y<0 || p.y>self.frame.size.height || _isAnimating) {
        if (_pullView) {
            [self pullUpFinished];
        }
        return;
    }
    if (UIGestureRecognizerStateBegan == gesture.state) {
        _pullView = gesture.view.superview;
        //通知切换表盘界面出现时，通知界面隐藏
        if (_bottomView == _pullView) {
            _topView.hidden = YES;
        }
    }
    else if ((UIGestureRecognizerStateEnded == gesture.state) ||
             (UIGestureRecognizerStateCancelled == gesture.state)) {
        [self pullUpFinished];
    }
    else {
        CGRect frame = _pullView.frame;
        frame.origin.y += p.y-_lastY;
        if (_bottomView==_pullView && frame.origin.y<=-Watch_PullUp_Height) {
            frame.origin.y = -Watch_PullUp_Height;
        }
        else if (_topView==_pullView && frame.origin.y>=0.0) {
            frame.origin.y = 0.0;
        }
        _pullView.frame = frame;
    }
    _lastY = p.y;
}

- (void)pullDown:(UIPanGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self];
    //手指滑出手表界面或动画正在进行时结束下拉
    if (p.y<0 || p.y>self.frame.size.height || _isAnimating) {
        if (_pullView) {
            [self pullDownFinished];
        }
        return;
    }
    if (UIGestureRecognizerStateBegan == gesture.state) {
        _pullView = gesture.view.superview;
        //通知界面出现时，切换表盘界面隐藏
        if (_topView == _pullView) {
            _bottomView.hidden = YES;
        }
    }
    else if ((UIGestureRecognizerStateEnded == gesture.state) ||
             (UIGestureRecognizerStateCancelled == gesture.state)) {
        [self pullDownFinished];
    }
    else {
        CGRect frame = _pullView.frame;
        frame.origin.y += p.y-_lastY;
        if (_bottomView==_pullView && frame.origin.y<=-Watch_PullUp_Height) {
            frame.origin.y = -Watch_PullUp_Height;
        }
        else if (_topView==_pullView && frame.origin.y>=0.0) {
            frame.origin.y = 0.0;
        }
        _pullView.frame = frame;
    }
    _lastY = p.y;
}

- (void)pullUpFinished
{
    CGRect frame = _pullView.frame;
    if (_topView == _pullView) {
        if (frame.origin.y<-Watch_PullUp_Height) {
            _desY = -self.frame.size.height;
            _bottomView.hidden = NO;
        }
        else {
            _desY = 0.0;
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

- (void)pullDownFinished
{
    CGRect frame = _pullView.frame;
    if (_topView == _pullView) {
        if (frame.origin.y>-self.frame.size.height+Watch_PullDown_Height) {
            _desY = 0.0;
        }
        else {
            _desY = -self.frame.size.height;
            _bottomView.hidden = NO;
        }
    }
    else {
        if (frame.origin.y>-Watch_PullUp_Height+Watch_PullDown_Height) {
            _desY = self.frame.size.height-Watch_PullUp_Height;
            _topView.hidden = NO;
        }
        else {
            _desY = -Watch_PullUp_Height;
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

@end
