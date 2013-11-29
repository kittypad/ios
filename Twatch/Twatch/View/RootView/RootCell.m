//
//  RootCell.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "RootCell.h"

@interface RootCell ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation RootCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        text.textAlignment = NSTextAlignmentCenter;
        text.textColor = [UIColor grayColor];
        text.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        [self addSubview:text];
        
        self.textLabel = text;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    self.textLabel.textColor = selected ? [UIColor purpleColor] : [UIColor grayColor];
}

- (void)configCellWithTitle:(NSString *)title
{
    self.textLabel.text = title;
}

@end
