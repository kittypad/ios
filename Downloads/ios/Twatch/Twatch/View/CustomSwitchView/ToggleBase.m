//
//  ToggleBase.m
//  ToggleView
//
//  Created by SOMTD on 12/10/15.
//  Copyright (c) 2012年 somtd.com. All rights reserved.
//

#import "ToggleBase.h"

//change base image option
NSString *const TOGGLE_BASE_IMAGE_L     = @"按钮-关.png";
NSString *const TOGGLE_BASE_IMAGE_R     = @"按钮-开.png";

@implementation ToggleBase
@synthesize baseType;

- (id)initWithImage:(UIImage *)image baseType:(ToggleBaseType)aBaseType
{
    self = [super initWithImage:image];
    if (self) {
        
        self.baseType = aBaseType;
        if (self.baseType == ToggleBaseTypeChangeImage)
        {
            //default select "L"
            self.image = [UIImage imageNamed:TOGGLE_BASE_IMAGE_L];
            return self;
        }
    }
    return self;
}

- (void)selectedLeftToggleBase
{
    if (self.baseType == ToggleBaseTypeChangeImage) {
        self.image = [UIImage imageNamed:TOGGLE_BASE_IMAGE_L];
    }
}

- (void)selectedRightToggleBase
{
    if (self.baseType == ToggleBaseTypeChangeImage) {
        self.image = [UIImage imageNamed:TOGGLE_BASE_IMAGE_R];
    }
}

@end
