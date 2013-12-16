//
//  WatchStyleEditingViewController.h
//  Twatch
//
//  Created by 龚涛 on 12/13/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WatchStyleEditingViewControllerDelegate <NSObject>

- (void)didEndEditingImage:(UIImage *)image;

@end

@interface WatchStyleEditingViewController : UIViewController

@property (nonatomic, weak) id<WatchStyleEditingViewControllerDelegate> delegate;

- (void)setImage:(UIImage *)image;

@end
