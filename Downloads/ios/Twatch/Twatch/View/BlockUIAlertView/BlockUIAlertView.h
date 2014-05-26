//
//  BlockUIAlertView.h
//  BlockAerltDemo
//
//  Created by wei.chen on 13-1-7.
//  Copyright (c) 2013年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonBlock)(NSInteger);

@interface BlockUIAlertView : UIAlertView

@property(nonatomic,copy)ButtonBlock block;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles
        buttonBlock:(ButtonBlock)customblock;

@end
