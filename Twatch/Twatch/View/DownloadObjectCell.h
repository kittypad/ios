//
//  DownloadObjectCell.h
//  Twatch
//
//  Created by 龚 涛 on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadObject.h"
#import "ProgressBarView.h"

@interface DownloadObjectCell : UITableViewCell
{
    UIImageView *_stateImgView;
    UILabel *_stateLable;
    
    BOOL _isDownloading;
}

@property (nonatomic, strong) UIControl *stateButton;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) ProgressBarView *progressBar;

@property (nonatomic, assign) int type;

- (id)initDownlodingWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)configCell:(DownloadObject *)obj lineHidden:(BOOL)hidden;

- (void)configCell:(DownloadObject *)obj;

- (void)setReadBytes:(CGFloat)readBytes totalBytes:(CGFloat)totalBytes;

@end
