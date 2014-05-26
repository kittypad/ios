//
//  AppsView.h
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
//    SettingAppType = 100,
    PanoramicAppType = 100,
    ExclusuveAppType,
    TryAppType
}AppsType;

@interface AppsView : UIView

- (void)playVideo:(id)sender;

@end
