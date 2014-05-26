//
//  ConnectionCell.m
//  Twatch
//
//  Created by yixiaoluo on 13-12-3.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ConnectionCell.h"

@interface ConnectionCell ()

@property (nonatomic, strong) UIView      *line;
@property (nonatomic, strong) UIImageView *selectStatus;

@property (nonatomic, strong) UILabel     *titleLabel;

@end

@implementation ConnectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        self.line.backgroundColor = RGB(230, 240, 250, 1);
        [self addSubview:self.line];
        
        self.selectStatus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"勾选-空.png"]];
        [self addSubview:self.selectStatus];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 320 - CGRectGetWidth(self.selectStatus.frame)-14, 30)];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:18];
        [self addSubview:label];
        self.titleLabel = label;
    }
    return self;
}

- (void)setCellSelected:(BOOL)selected title:(NSString *)title
{
    // Configure the view for the selected state
    self.titleLabel.text = title;
    
    if (selected) {
        [self.selectStatus setImage:[UIImage imageNamed:@"勾选.png"]];
    }else{
        [self.selectStatus setImage:[UIImage imageNamed:@"勾选-空.png"]];
    }
}

- (void)layoutSubviews
{
    self.line.frame = CGRectChangeY(self.line.frame, CGRectGetHeight(self.frame) - 1);
    self.selectStatus.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.selectStatus.frame), CGRectGetHeight(self.frame)/2);
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, CGRectGetHeight(self.frame)/2);
}

@end
