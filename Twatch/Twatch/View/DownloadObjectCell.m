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
        
        _stateButton = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 45.0)];
        
        _stateImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 4.0, 25.0, 25.0)];
        [_stateButton addSubview:_stateImgView];
        
        _stateLable = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, 45.0, 10.0)];
        _stateLable.font = [UIFont systemFontOfSize:8.0];
        _stateLable.textColor = [UIColor colorWithHex:@"7e7e7e"];
        _stateLable.textAlignment = NSTextAlignmentCenter;
        [_stateButton addSubview:_stateLable];
        
        self.accessoryView = _stateButton;
        
        _isDownloading = NO;
    }
    return self;
}

- (id)initDownlodingWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isDownloading = YES;
        
        _progressBar = [[ProgressBarView alloc] initWithFrame:CGRectMake(0.0, 0.0, 185.0, 8.0)];
        _progressBar.backgroundColor = [UIColor colorWithHex:@"dcdcdc"];
        _progressBar.progressBar.backgroundColor = [UIColor colorWithHex:@"0cb62f"];
        [self addSubview:_progressBar];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconView.frame = CGRectMake(20.0, 6.0, 33.0, 33.0);
    self.textLabel.frame = CGRectMake(61.0, 5.0, 150.0, 13.0);
    if (_isDownloading) {
        self.detailTextLabel.frame = CGRectMake(61.0, 21.0, 150.0, 10.0);
        _progressBar.frame = CGRectMake(61.0, 33.0, 185.0, 7.0);
    }
    else {
        self.detailTextLabel.frame = CGRectMake(61.0, 30.0, 150.0, 10.0);
    }
    self.lineView.frame = CGRectMake(0.0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
}

- (NSString *)transformByteToString:(CGFloat)bytes
{
    if (bytes<1024.0) {
        return [NSString stringWithFormat:@"%.0fB", bytes];
    }
    
    bytes /= 1024.0;
    if (bytes >= 1024.0) {
        bytes /= 1024.0;
        return [NSString stringWithFormat:@"%.2fMB", bytes];
    }
    else {
        return [NSString stringWithFormat:@"%.0fKB", bytes];
    }
}

- (void)setReadBytes:(CGFloat)readBytes totalBytes:(CGFloat)totalBytes
{
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self transformByteToString:readBytes], [self transformByteToString:totalBytes]];
}

- (void)configCell:(DownloadObject *)obj
{
    [self.iconView setImageWithURL:[NSURL URLWithString:obj.iconUrl]];
    
    self.textLabel.text = obj.name;
    
    self.detailTextLabel.text = [self transformByteToString:[obj.size floatValue]];
    
    switch ([obj.state integerValue]) {
        case kNotDownload: {
            _stateLable.text = NSLocalizedString(@"Download", nil);
            _stateImgView.image = [UIImage imageNamed:@"下载.png"];
            break;
        }
        case kDownloading: {
            _stateLable.text = NSLocalizedString(@"Downloading", nil);
            _stateImgView.image = [UIImage imageNamed:@"下载中.png"];
            break;
        }
        case kNotInstall: {
            _stateLable.text = NSLocalizedString(@"Install", nil);
            _stateImgView.image = [UIImage imageNamed:@"安装.png"];
            break;
        }
        case kInstalled: {
            _stateLable.text = NSLocalizedString(@"Installed", nil);
            _stateImgView.image = [UIImage imageNamed:@"已安装.png"];
            break;
        }
        default:
            break;
    }
    
    self.lineView.hidden = NO;
}

- (void)configCell:(DownloadObject *)obj lineHidden:(BOOL)hidden
{
    [self.iconView setImageWithURL:[NSURL URLWithString:obj.iconUrl]];
    
    self.textLabel.text = obj.name;
    
    self.detailTextLabel.text = obj.intro;
    
    switch ([obj.state integerValue]) {
        case kNotDownload: {
            _stateLable.text = NSLocalizedString(@"Download", nil);
            _stateImgView.image = [UIImage imageNamed:@"下载.png"];
            break;
        }
        case kDownloading: {
            _stateLable.text = NSLocalizedString(@"Downloading", nil);
            _stateImgView.image = [UIImage imageNamed:@"下载中.png"];
            break;
        }
        case kNotInstall: {
            _stateLable.text = NSLocalizedString(@"Install", nil);
            _stateImgView.image = [UIImage imageNamed:@"安装.png"];
            break;
        }
        case kInstalled: {
            _stateLable.text = NSLocalizedString(@"Installed", nil);
            _stateImgView.image = [UIImage imageNamed:@"已安装.png"];
            break;
        }
        default:
            break;
    }
    
    self.lineView.hidden = hidden;
}

@end
