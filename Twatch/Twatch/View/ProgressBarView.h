//
//  ProgressBarView.h
//  Twatch
//
//  Created by 龚 涛 on 13-12-11.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBarView : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIView *progressBar;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
