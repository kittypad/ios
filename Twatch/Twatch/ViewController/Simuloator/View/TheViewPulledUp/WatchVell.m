//
//  WatchVell.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-13.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "WatchVell.h"

@interface WatchVell ()

@property (nonatomic, strong) UIImageView  *imageView;

@end

@implementation WatchVell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectChangeOrigin(frame, 0, 0)];
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        self.imageView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.backgroundColor = selected ? [UIColor clearColor] : [UIColor grayColor];
}

- (void)configCellWithInfo:(NSString *)imageName
{
    UIImage *img = [UIImage imageNamed:imageName];
    [self.imageView setImage:img];
    self.imageView.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
}

@end
