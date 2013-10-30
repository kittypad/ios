//
//  FactoryMethods.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-13.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>

//c-style
CGRect CGRectChangeWidth(CGRect frame, CGFloat width);
CGRect CGRectChangeHeight(CGRect frame, CGFloat height);
CGRect CGRectChangeX(CGRect frame, CGFloat x);
CGRect CGRectChangeY(CGRect frame, CGFloat y);
CGRect CGRectChangeOrigin(CGRect frame, CGFloat x, CGFloat y);
CGRect CGRectChangeSize(CGRect frame, CGFloat width, CGFloat height);


@interface FactoryMethods : NSObject

//oc-style
+ (UIButton *)buttonWWithNormalImage:(NSString *)normal hiliteImage:(NSString *)hilite target:(id)target selector:(SEL)sel;
+ (UIButton *)buttonWWithTitle:(NSString *)title normalBg:(NSString *)bg hiliteBg:(NSString *)hbg target:(id)target selector:(SEL)sel;
+ (UIButton *)buttonWWithTitle:(NSString *)title normalColor:(UIColor *)normal hiliteColor:(UIColor *)hilite target:(id)target selector:(SEL)sel;

@end

@interface UIColor(extend)

// 将十六进制的颜色值转为objective-c的颜色
+ (id)getColor:(NSString *) hexColor;

@end