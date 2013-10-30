//
//  TMNavigationController.m
//  Twatch
//
//  Created by 龚涛 on 10/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "TMNavigationController.h"

@implementation TMNavigationController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#else

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#endif

@end
