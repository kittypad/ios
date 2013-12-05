//
//  NetworkManager.h
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadObject.h"

@class AFHTTPRequestOperation;

@interface DataManager : NSObject

+ (DataManager *)sharedManager;

- (AFHTTPRequestOperation *)getDownloadList:(NSUInteger)type
                                       page:(NSUInteger)page
                                    success:(void (^)(NSArray *array))success
                                    failure:(void (^)(NSError *error))failure;

@end
