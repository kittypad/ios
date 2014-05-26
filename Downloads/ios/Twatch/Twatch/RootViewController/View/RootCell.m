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
@property (nonatomic, strong) UIImageView *logo;

@end

@implementation RootCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *img = [UIImage imageNamed:@"更多.png"];
        UIImageView *logo = [[UIImageView alloc] initWithImage:img];
        logo.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2-20);
        [self addSubview:logo];
        self.logo = logo;
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        text.textAlignment = NSTextAlignmentCenter;
        text.textColor = [UIColor whiteColor];
        text.backgroundColor = [UIColor clearColor];
        text.font = [UIFont systemFontOfSize:20];
        text.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2+30);
        [self addSubview:text];
        
        self.textLabel = text;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    self.textLabel.textColor = selected ? [UIColor whiteColor] : [UIColor whiteColor];
}

- (void)configCellWithTitle:(NSString *)title imageName:(NSString *)name
{
    self.textLabel.text = title;
    
    UIImage *img = [UIImage imageNamed:name];
    self.logo.image = [UIImage imageNamed:name];
    self.logo.bounds = CGRectMake(0, 0, img.size.width,img.size.height);
}

@end
