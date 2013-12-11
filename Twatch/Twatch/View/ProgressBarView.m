//
//  ProgressBarView.m
//  Twatch
//
//  Created by 龚 涛 on 13-12-11.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ProgressBarView.h"

@implementation ProgressBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frame = self.bounds;
        frame.size.width = 0.0;
        _progressBar = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_progressBar];
        
        _progress = 0.0;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    frame.origin = CGPointZero;
    frame.size.width *= _progress;
    _progressBar.frame = frame;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress > 1.0) {
        progress = 1.0;
    }
    else if (progress < 0.0) {
        progress = 0.0;
    }
    _progress = progress;
    CGRect frame = self.bounds;
    frame.size.width *= _progress;
    _progressBar.frame = frame;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             [self setProgress:progress];
                         }];
    }
    else {
        [self setProgress:progress];
    }
}

@end
