//
//  HomeButton.m
//  Twatch
//
//  Created by 龚涛 on 12/2/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "HomeButton.h"

#define HomeImageWidth 20.0

@implementation HomeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, HomeImageWidth, HomeImageWidth)];
        _imageView.image = [UIImage imageNamed:@"home.png"];
        _imageView.center = CGPointMake(HomeImageWidth/2.0, frame.size.height/2.0);
        [self addSubview:_imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(HomeImageWidth + 8.0, 0.0, frame.size.width - HomeImageWidth - 8.0, frame.size.height)];
        label.text = NSLocalizedString(@"Home", nil);
        label.textColor = [UIColor blackColor];
        [self addSubview:label];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        _imageView.image = [UIImage imageNamed:@"home-push.png"];
    }
    else {
        _imageView.image = [UIImage imageNamed:@"home.png"];
    }
}

@end
