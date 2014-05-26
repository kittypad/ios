//
//  ShoppingViewCell.m
//  Twatch
//
//  Created by yugong on 14-5-26.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "ShoppingViewCell.h"

@implementation ShoppingViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
