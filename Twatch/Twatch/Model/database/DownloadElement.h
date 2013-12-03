//
//  DownloadElement.h
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DownloadElement : NSManagedObject

@property (nonatomic, retain) NSString * apkUrl;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pkg;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * ver;
@property (nonatomic, retain) NSNumber * state;

@end
