//
//  IconButton.m
//  Twatch
//
//  Created by 龚涛 on 12/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "IconButton.h"

@implementation IconButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(32.0, 0.0, contentRect.size.width-34.0, contentRect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(10.0, 5.0, 20.0, 20.0);
}

@end
