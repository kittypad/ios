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
        
        [_manager.operationQueue setMaxConcurrentOperationCount:3];
        
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

#pragma mark - Data

- (BOOL)saveDownloadDic
{
    return [NSKeyedArchiver archiveRootObject:_downloadDic toFile:_downloadFilePath];
}

- (void)addDownloadObject:(DownloadObject *)obj
{
    if (!_downloadSearchDic[obj.apkUrl]) {
        _downloadSearchDic[obj.apkUrl] = obj;
        NSMutableArray *array = _downloadDic[AppDownloadingArray];
        [array addObject:obj];
        [self saveDownloadDic];
        [self startDownloadFile:obj];
    }
}

#pragma mark - Networking

- (void)startAllDownloadingFile
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        [_manager.operationQueue.operations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//            AFDownloadRequestOperation *operation = obj;
//            [operation pause];
//        }];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSMutableArray *downloadingArray = _downloadDic[AppDownloadingArray];
        __block NSMutableArray *downloadedArray = _downloadDic[AppDownloadedArray];
        
        for (int i = 0; i < downloadingArray.count; i++) {
            DownloadObject *obj = [downloadingArray objectAtIndex:i];
            NSURL *url = [NSURL URLWithString:obj.apkUrl];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            
            AFDownloadRequestOperation *requestOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[AFDownloadRequestOperation cacheFolder] shouldResume:YES];
            
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded file");
                [downloadingArray removeObject:obj];
                obj.state = [NSNumber numberWithInt:kNotInstall];
                [downloadedArray addObject:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFinishedNotification object:nil userInfo:@{@"obj": obj}];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            [requestOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                NSDictionary *dic = @{@"readFileBytes": [NSNumber numberWithLongLong:totalBytesReadForFile],
                                      @"totalFileBytes": [NSNumber numberWithLongLong:totalBytesExpectedToReadForFile],
                                      @"obj": obj};
                [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadingProcessNotification object:nil userInfo:dic];
            }];
            [_manager.operationQueue addOperation:requestOperation];
        }
        
        NSLog(@" %f",application.backgroundTimeRemaining);
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)startDownloadFile:(DownloadObject *)obj
{
    NSMutableArray *array = _downloadDic[AppDownloadingArray];
    if (array.count > 0) {
        __block AFDownloadRequestOperation *requestOperation = nil;
        UIApplication *application = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//            if (requestOperation && ![requestOperation isFinished]) {
//                [requestOperation pause];
//            }
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:obj.apkUrl];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            
            requestOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[AFDownloadRequestOperation cacheFolder] shouldResume:YES];
            
            __block NSMutableArray *downloadingArray = array;
            __block NSMutableArray *downloadedArray = _downloadDic[AppDownloadedArray];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded file");
                [downloadingArray removeObject:obj];
                obj.state = [NSNumber numberWithInt:kNotInstall];
                [downloadedArray addObject:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFinishedNotification object:nil userInfo:@{@"obj": obj}];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            [requestOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                NSDictionary *dic = @{@"readFileBytes": [NSNumber numberWithLongLong:totalBytesReadForFile],
                                      @"totalFileBytes": [NSNumber numberWithLongLong:totalBytesExpectedToReadForFile],
                                      @"obj": obj};
                [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadingProcessNotification object:nil userInfo:dic];
            }];
            [_manager.operationQueue addOperation:requestOperation];
            
            NSLog(@" %f",application.backgroundTimeRemaining);
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    }
}

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
                    if (!obj || ![obj.ver isEqualToString:dic[kVer]]) {
                        obj = [[DownloadObject alloc] init];
                        obj.apkUrl = dic[kApkUrl];
                        obj.iconUrl = dic[kIconUrl];
                        obj.intro = dic[kIntro];
                        obj.name = dic[kName];
                        obj.pkg = dic[kPkg];
                        obj.size = dic[kSize];
                        obj.type = dic[kType];
                        obj.ver = dic[kVer];
                        obj.state = [NSNumber numberWithInteger:kNotDownload];
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
