//
//  UIImage+Tool.h
//  Twatch
//
//  Created by 龚涛 on 11/1/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface UIImage (Tool)

- (UIImage *)scaleToScale:(CGFloat)scale;
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)drawCenterImage:(UIImage *)image;

+ (UIImage*)imageWithImage:(UIImage*)inImage withColorMatrix:(const float*)f;

@end
