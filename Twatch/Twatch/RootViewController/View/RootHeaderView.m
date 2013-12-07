//
//  RootHeaderView.m
//  Twatch
//
//  Created by yixiaoluo on 13-12-2.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootHeaderView.h"

@implementation RootHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tomoon_logo"]];
        logo.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2+3);
        [self addSubview:logo];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
