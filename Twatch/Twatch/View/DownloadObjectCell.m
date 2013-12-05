//
//  DownloadObjectCell.m
//  Twatch
//
//  Created by 龚 涛 on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "DownloadObjectCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DownloadObjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor colorWithHex:@"333333"];
        self.textLabel.font = [UIFont systemFontOfSize:11.0];
        
        self.detailTextLabel.textColor = [UIColor colorWithHex:@"7e7e7e"];
        self.detailTextLabel.font = [UIFont systemFontOfSize:8.0];
        
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHex:@"cee2f4"];
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconView.frame = CGRectMake(20.0, 6.0, 33.0, 33.0);
    self.textLabel.frame = CGRectMake(61.0, 5.0, 150.0, 13.0);
    self.detailTextLabel.frame = CGRectMake(61.0, 30.0, 150.0, 10.0);
    self.lineView.frame = CGRectMake(0.0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
}

- (void)configCell:(DownloadObject *)obj
{
    [self.iconView setImageWithURL:[NSURL URLWithString:obj.iconUrl]];
    
    self.textLabel.text = obj.name;
    
    CGFloat f = [obj.size floatValue]/1024.0;
    
    if (f > 1024) {
        f /= 1024.0;
        self.detailTextLabel.text = [NSString stringWithFormat:@"%fMB", f];
    }
    else {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%fKB", f];
    }
    
    self.lineView.hidden = NO;
}

- (void)configCell:(DownloadObject *)obj lineHidden:(BOOL)hidden
{
    [self.iconView setImageWithURL:[NSURL URLWithString:obj.iconUrl]];
    
    self.textLabel.text = obj.name;
    
    self.detailTextLabel.text = obj.intro;
    
    self.lineView.hidden = hidden;
}

@end
