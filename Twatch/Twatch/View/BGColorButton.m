//
//  BGColorButton.m
//  Twatch
//
//  Created by 龚涛 on 12/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "BGColorButton.h"

@interface BGColorButton ()

- (void)_updateBackgroundColor;

@end

@implementation BGColorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _normalColor = [UIColor whiteColor];
        _highlightedColor = [UIColor blueColor];
        
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)_updateBackgroundColor
{
    switch (self.state) {
        case UIControlStateNormal: {
            self.backgroundColor = _normalColor;
            break;
        }
        case UIControlStateHighlighted: {
            self.backgroundColor = _highlightedColor;
            break;
        }
        default:
            break;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self _updateBackgroundColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    switch (state) {
        case UIControlStateNormal: {
            _normalColor = backgroundColor;
            break;
        }
        case UIControlStateHighlighted: {
            _highlightedColor = backgroundColor;
            break;
        }
        default:
            break;
    }
    [self _updateBackgroundColor];
}

@end
