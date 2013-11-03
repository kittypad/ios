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

@interface TryViewController : NaviCommonViewController <AVHelperDelegate>
{
    CameraImageHelper *_cameraView;
    UIView *_photoView;
    UIView *_topView;
    UIButton *_cameraButton;
    UIButton *_shareButton;
    
    CGFloat _scale;
}

@end
