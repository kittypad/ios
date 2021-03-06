//
//  DownloadObject.h
//  Twatch
//
//  Created by 龚 涛 on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kApkUrl                 @"apkUrl"
#define kIconUrl                @"iconUrl"
#define kIntro                  @"intro"
#define kName                   @"name"
#define kPkg                    @"pkg"
#define kSize                   @"size"
#define kType                   @"type"
#define kVer                    @"ver"
#define kState                  @"state"

#define kNotDownload            0
#define kDownloading            1
#define kNotInstall             2
#define kInstalled              3
#define kInstalling             4

@interface DownloadObject : NSObject

@property (nonatomic, retain) NSString * apkUrl;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pkg;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * ver;
@property (nonatomic, retain) NSNumber * state;

- (unsigned long long)fileSizeAtPath:(NSString *)path;

@end
