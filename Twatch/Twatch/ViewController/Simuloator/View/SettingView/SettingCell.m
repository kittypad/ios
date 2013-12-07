//
//  SettingCell.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "SettingCell.h"

@interface SettingCell ()



@end

@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        // Initialization code
        self.selectionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"单选.png"]
                                                    highlightedImage:[UIImage imageNamed:@"单选-选中.png"]];
        self.selectionImageView.center = CGPointMake(250, CGRectGetHeight(self.frame)/2);
        [self addSubview:self.selectionImageView];
    }
    return self;
}


- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.selectionImageView.highlighted = _isSelected;
}

@end
