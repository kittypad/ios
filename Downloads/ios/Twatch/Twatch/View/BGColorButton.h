//
//  BGColorButton.h
//  Twatch
//
//  Created by 龚涛 on 12/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGColorButton : UIControl
{
    UIColor *_normalColor;
    UIColor *_highlightedColor;
}

@property (nonatomic, strong) UILabel *titleLabel;

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end
