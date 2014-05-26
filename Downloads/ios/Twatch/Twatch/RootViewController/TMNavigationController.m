//
//  TMNavigationController.m
//  Twatch
//
//  Created by 龚涛 on 10/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "TMNavigationController.h"

@implementation TMNavigationController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
