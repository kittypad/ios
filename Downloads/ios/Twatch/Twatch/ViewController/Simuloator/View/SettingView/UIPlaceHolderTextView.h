//
//  UIPlaceHolderTextView.h
//  Twatch
//
//  Created by wangjizeng on 13-10-31.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    
@private
    UILabel *placeHolderLabel;
}

@property(nonatomic, retain) UILabel *placeHolderLabel;
@property(nonatomic, retain) NSString *placeholder;
@property(nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;
- (void)Shake;
@end
