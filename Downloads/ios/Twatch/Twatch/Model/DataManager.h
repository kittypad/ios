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

- (void)removeDownloadObject:(DownloadObject *)obj;

//Network

- (void)startAllDownloadingFile;

- (void)startDownloadFile:(DownloadObject *)obj;
-(void)downLoadWatchVersion:(NSString *)url;

- (AFHTTPRequestOperation *)getDownloadList:(NSUInteger)type
                                       page:(NSUInteger)page
                                    success:(void (^)(NSArray *array))success
                                    failure:(void (^)(NSError *error))failure;
-(AFHTTPRequestOperation *)getWatchVersionDown:(void (^)(NSMutableArray *array))success;
-(AFHTTPRequestOperation *)checkWatchVersionNewDown:(NSString *)url success:(void (^)(NSMutableArray *array))success;
-(AFHTTPRequestOperation *)getWheather:(NSString *)weatherurl
                               success:(void (^)(NSString *response))success;

//服务器获取商品列表
- (NSMutableArray*)getShoppingList:(NSString *)shopurl;

@end
