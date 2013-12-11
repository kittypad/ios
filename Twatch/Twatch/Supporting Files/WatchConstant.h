//
//  WatchConstant.h
//  Twatch
//
//  Created by yixiaoluo on 13-10-10.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#ifndef Twatch_WatchConstant_h
#define Twatch_WatchConstant_h

#define PlayAppsVideoNotification @"PlayAppsVideoNotification"
#define PlayAppsVideoDidPlayFinishedNotification @"PlayAppsVideoDidPlayFinishedNotification"
//#define SettingviewClickNotification @"SettingviewClickNotification"
//#define AppIconClickNotification @"AppIconClickNotification"

#define WatchStyleStatus  @"watch style saved in local "
#define WatchStyleStatusChangeNotification  @"watch style change notification"

#define kDownloadAppNotification @"DownloadAppNotification"
#define kDownloadingProcessNotification @"DownloadingProcessNotification"
#define kDownloadFinishedNotification @"DownloadFinishedNotification"

#define Watch_Height     320.0
#define Watch_Width      240.0

#define Watch_PullDown_Height       30.0
#define Watch_PullUp_Height         30.0

#define RGB(r,g,b,a) ([UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)])

//检测是否iPhone5
#define IS_IPHONE_5    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IOS7        ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)

#define GoBackNameSize  15

#define APPID @"737815068"

typedef enum _WatchStyle{
    wBlack = 0,
    wRed,
    wBlue
}WatchStyle;


#endif
