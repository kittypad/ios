//
//  UIImage+Tool.m
//  Twatch
//
//  Created by 龚涛 on 11/1/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "UIImage+Tool.h"

@implementation UIImage (Tool)

- (UIImage *)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)drawCenterImage:(UIImage *)image
{
    if (!image) {
        return self;
    }
    UIGraphicsBeginImageContext(self.size);
    
    CGFloat x = (image.size.width-self.size.width)/2;
    if (image.size.width>self.size.width) {
        x = -x;
    }
    CGFloat y = (image.size.height-self.size.height)/2;
    if (image.size.height>self.size.height) {
        y = -y;
    }
    
    // 绘制图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //绘图
    [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
