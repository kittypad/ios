//
//  ImageLabelView.h
//  Twatch
//
//  Created by yugong on 14-6-3.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageLabelView : UIView

@property (nonatomic)float labelheight;

//参数：边框位置大小；文本框背景颜色；imageview的图片；文本框的text
- (id)initWithFrame:(CGRect)frame lblcolor:(UIColor *)lblcolor iamge:(UIImage *)iamge labeltext:(NSString *)labeltext;

@end
