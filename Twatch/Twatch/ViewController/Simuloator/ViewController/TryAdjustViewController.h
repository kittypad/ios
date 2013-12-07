//
//  TryAdjustViewController.h
//  Twatch
//
//  Created by 龚涛 on 11/1/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TryAdjustViewController : UIViewController
{
    UIImage *_image;
    
    UIImageView *_imageView;
}

@property (nonatomic, retain) UIImage *shareImage;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end
