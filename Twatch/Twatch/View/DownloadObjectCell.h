//
//  DownloadObjectCell.h
//  Twatch
//
//  Created by 龚 涛 on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadObject.h"

@interface DownloadObjectCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIView *lineView;

- (void)configCell:(DownloadObject *)obj lineHidden:(BOOL)hidden;

- (void)configCell:(DownloadObject *)obj;

@end
