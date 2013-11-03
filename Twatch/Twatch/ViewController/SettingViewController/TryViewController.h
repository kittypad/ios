//
//  TryViewController.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviCommonViewController.h"
#import "CameraImageHelper.h"

@class TryAdjustViewController;

@interface TryViewController : NaviCommonViewController <AVHelperDelegate>
{
    CameraImageHelper *_cameraView;
    UIView *_photoView;
    UIView *_topView;
    UIView *_bgView;
    UIButton *_cameraButton;
    UIButton *_shareButton;
    
    CGFloat _scale;
    CGFloat _lastScale;
    
    TryAdjustViewController *_tryAdjustViewController;
}

@end
