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

//设置导航条背景颜色
@property (nonatomic) UIColor* naviBackgroundColor;
@property (nonatomic) UIButton* backBtn;
- (void)goBack;
- (void)setLineHidden:(BOOL)hidden;

@end
