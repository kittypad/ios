//
//  NetworkManager.h
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadObject.h"
#import "AFDownloadRequestOperation.h"

#define AppDownloadingArray     @"downloading"
#define AppDownloadedArray      @"downloaded"

@class AFHTTPRequestOperation;

@interface DataManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *downloadDic;

@property (nonatomic, strong) NSMutableDictionary *downloadSearchDic;

//@property (nonatomic, strong) AFDownloadRequestOperation *requestOperation;

+ (DataManager *)sharedManager;

//Data

- (BOOL)saveDownloadDic;

- (void)addDownloadObject:(DownloadObject *)obj;

//Network

- (void)startAllDownloadingFile;

- (void)startDownloadFile:(DownloadObject *)obj;

- (AFHTTPRequestOperation *)getDownloadList:(NSUInteger)type
                                       page:(NSUInteger)page
                                    success:(void (^)(NSArray *array))success
                                    failure:(void (^)(NSError *error))failure;

@end
