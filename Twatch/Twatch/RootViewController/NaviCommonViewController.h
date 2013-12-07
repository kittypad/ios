//
//  NaviCommonViewController.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NaviCommonViewController : UIViewController

@property (nonatomic, copy) NSString *backName;

@property (nonatomic)       CGFloat  yOffset;//subview origin y coordinate
@property (nonatomic)       CGFloat  height;//subview height

- (void)goBack;
- (void)setLineHidden:(BOOL)hidden;

@end
