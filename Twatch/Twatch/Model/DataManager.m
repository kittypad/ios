//
//  NetworkManager.m
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "DataManager.h"
#import <AFNetworking.h>

#define kBaseURL [NSURL URLWithString:@"http://r.tomoon.cn"]

@interface DataManager ()
{
    AFHTTPRequestOperationManager *_manager;
    
    NSString *_downloadFilePath;
}

@end

@implementation DataManager

+ (DataManager *)sharedManager
{
    static DataManager *sharedManagerInstance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[DataManager alloc] init];
    });
    
    return sharedManagerInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _downloadFilePath = [Path stringByAppendingPathComponent:@"download.dat"];
        
        _downloadSearchDic = [[NSMutableDictionary alloc] init];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_downloadFilePath]) {
            _downloadDic = [NSKeyedUnarchiver unarchiveObjectWithFile:_downloadFilePath];
            
            NSMutableArray *array = _downloadDic[AppDownloadingArray];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                DownloadObject *object = (DownloadObject *)obj;
                _downloadSearchDic[object.apkUrl] = object;
            }];
            
            array = _downloadDic[AppDownloadedArray];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                DownloadObject *object = (DownloadObject *)obj;
                _downloadSearchDic[object.apkUrl] = object;
            }];
        }
        else {
            _downloadDic = [[NSMutableDictionary alloc] init];
            _downloadDic[AppDownloadingArray] = [[NSMutableArray alloc] init];
            _downloadDic[AppDownloadedArray] = [[NSMutableArray alloc] init];
            [NSKeyedArchiver archiveRootObject:_downloadDic toFile:_downloadFilePath];
        }
        
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:kBaseURL];
        
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024
                                                             diskCapacity:40 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
        
        
    }
    
    return self;
}

#pragma mark - Networking

- (AFHTTPRequestOperation *)getDownloadList:(NSUInteger)type
                                       page:(NSUInteger)page
                                    success:(void (^)(NSArray *array))success
                                    failure:(void (^)(NSError *error))failure
{
    
    NSDictionary *params = @{ @"p": [NSNumber numberWithInteger:page],
                              @"t": [NSNumber numberWithInteger:type] };
    
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject != [NSNull null] && [responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"%@", responseObject);
            NSArray *array = (NSArray *)responseObject;
            if (array.count > 0) {
                NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:array.count];
                for (NSDictionary *dic in array) {
                    DownloadObject *obj = _downloadSearchDic[dic[@"apkUrl"]];
                    if (!obj) {
                        obj = [[DownloadObject alloc] init];
                        obj.apkUrl = dic[@"apkUrl"];
                        obj.iconUrl = dic[@"iconUrl"];
                        obj.intro = dic[@"intro"];
                        obj.name = dic[@"name"];
                        obj.pkg = dic[@"pkg"];
                        obj.size = dic[@"size"];
                        obj.type = dic[@"type"];
                        obj.ver = dic[@"ver"];
                    }
                    [resultArray addObject:obj];
                }
                if (success) {
                    success(resultArray);
                    return;
                }
            }
        }
        if (success) {
            success(nil);
        }
    };
    
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failure) {
            failure(error);
        }
    };
    
    AFHTTPRequestOperation *op = [_manager GET:@"app" parameters:params success:requestSuccess failure:requestFailure];
    NSLog(@"request: %@", op.request.URL.absoluteString);
    return op;
}

@end
