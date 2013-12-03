//
//  DataManager.h
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define DownloadElement_Entity  @"DownloadElement"
#define kIconUrl                @"iconUrl"
#define kIntro                  @"intro"
#define kName                   @"name"
#define kPkg                    @"pkg"
#define kSize                   @"size"
#define kType                   @"type"
#define kVer                    @"ver"
#define kState                  @"state"

@interface DataManager : NSObject

+ (DataManager *)sharedManager;

- (BOOL)saveContext:(NSManagedObjectContext *)context;

@end
