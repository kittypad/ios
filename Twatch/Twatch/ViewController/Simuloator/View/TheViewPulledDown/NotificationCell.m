//
//  NotificationCell.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-13.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "NotificationCell.h"

@interface NotificationCell ()

@property (nonatomic, strong) UILabel  *tempLable;

@end

@implementation NotificationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tempLable = [[UILabel alloc] initWithFrame:CGRectChangeOrigin(frame, 0, 0)];
        self.tempLable.textColor = [UIColor whiteColor];
        self.tempLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.tempLable];
        
        self.tempLable.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.backgroundColor = selected ? [UIColor redColor] : [UIColor blueColor];
}

- (void)configCellWithInfo:(id)info
{
    self.tempLable.text = [NSString stringWithFormat:@"通知: %@",info];
}

@end
