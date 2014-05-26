//
//  NetworkManager.m
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "DataManager.h"
#import <AFNetworking.h>
#import "ZipArchive.h"
#import "AFURLResponseSerialization.h"
#import <GDataXMLNode.h>
#import "WatchConstant.h"

#import "SBjson.h"

#define kBaseURL [NSURL URLWithString:@"http://r.tomoon.cn"]

@interface DataManager ()
{
    AFHTTPRequestOperationManager *_manager;
    
    NSString *_downloadFilePath;
}

- (void)_unzipFile:(NSString *)fileName toFile:(NSString *)resultName completion:(void (^)(void))block;

- (void)_finishDownloading:(DownloadObject *)obj;

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
                if (!_downloadSearchDic[object.apkUrl]) {
                    _downloadSearchDic[object.apkUrl] = object;
                }
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

#pragma mark - Private

- (void)_unzipFile:(NSString *)fileName toFile:(NSString *)resultName completion:(void (^)(void))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        ZipArchive *zip = [[ZipArchive alloc] init];
        if ([zip UnzipOpenFile:fileName] && [zip UnzipFileTo:resultName overWrite:YES]) {
            NSLog(@"Unzip success");
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSError *error;
            [fileManager removeItemAtPath:fileName error:&error];
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
            }
            dispatch_async(dispatch_get_main_queue(), block);
        }
        else {
            NSLog(@"Unzip fail");
        }
        [zip UnzipCloseFile];
    });
}

- (void)_finishDownloading:(DownloadObject *)obj
{
    [_downloadDic[AppDownloadingArray] removeObject:obj];
    obj.state = [NSNumber numberWithInt:kNotInstall];
    [_downloadDic[AppDownloadedArray] addObject:obj];
    [self saveDownloadDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFinishedNotification object:nil userInfo:@{@"obj": obj}];
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

- (void)removeDownloadObject:(DownloadObject *)obj
{
    if (obj) {
        [_downloadSearchDic removeObjectForKey:obj.apkUrl];
        
        for (AFHTTPRequestOperation *operation in _manager.operationQueue.operations) {
            if ([operation.request.URL.absoluteString isEqualToString:obj.apkUrl]) {
                AFDownloadRequestOperation *requestOperation = (AFDownloadRequestOperation *)operation;
                [operation pause];
                [operation cancel];
                NSError *error;
                [requestOperation deleteTempFileWithError:&error];
                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
                break;
            }
        }
        
        NSMutableArray *downloadingArray =  _downloadDic[AppDownloadingArray];
        for (DownloadObject *object in downloadingArray) {
            if ([obj.apkUrl isEqualToString:[(DownloadObject *)object apkUrl]]) {
                [downloadingArray removeObject:object];
                return;
            }
        }
        
        NSMutableArray *downloadedArray =  _downloadDic[AppDownloadedArray];
        for (DownloadObject *object in downloadedArray) {
            if ([obj.apkUrl isEqualToString:[(DownloadObject *)object apkUrl]]) {
                NSString *fileName = [[NSURL URLWithString:obj.apkUrl] lastPathComponent];
                NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:[AFDownloadRequestOperation cacheFolder], fileName, nil]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                    if (error) {
                        NSLog(@"Error: %@", error.localizedDescription);
                    }
                }
                [downloadingArray removeObject:object];
                return;
            }
        }
        [self saveDownloadDic];
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
        
        for (int i = 0; i < downloadingArray.count; i++) {
            DownloadObject *obj = [downloadingArray objectAtIndex:i];
            NSURL *url = [NSURL URLWithString:obj.apkUrl];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            
            AFDownloadRequestOperation *requestOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[AFDownloadRequestOperation cacheFolder] shouldResume:YES];
            
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded file");
                if (obj.type.intValue == 1) {
                    AFDownloadRequestOperation *rOperation = (AFDownloadRequestOperation *)operation;
                    NSString *filePath = [rOperation.tempPath stringByReplacingOccurrencesOfString:@".zip" withString:@""];
                    
                    [self _unzipFile:rOperation.tempPath toFile:filePath completion:^(void){
                        NSLog(@"Unzip success");
                        [self _finishDownloading:obj];
                    }];
                }
                else {
                    [self _finishDownloading:obj];
                }
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
            
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded file");
                if (obj.type.intValue == 1) {
                    AFDownloadRequestOperation *rOperation = (AFDownloadRequestOperation *)operation;
                    NSString *filePath = [rOperation.tempPath stringByReplacingOccurrencesOfString:@".zip" withString:@""];
                    
                    [self _unzipFile:rOperation.tempPath toFile:filePath completion:^(void){
                        [self _finishDownloading:obj];
                    }];
                }
                else {
                    [self _finishDownloading:obj];
                }
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

-(void)downLoadWatchVersion:(NSString *)url
{
//    NSMutableArray *array = _downloadDic[AppDownloadingArray];
    
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
        NSURL *localurl = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        requestOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[AFDownloadRequestOperation cacheFolder] shouldResume:YES];
        
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file");
            
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateWatchVersionNotification object:nil userInfo:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [requestOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            NSDictionary *dic = @{@"readFileBytes": [NSNumber numberWithLongLong:totalBytesReadForFile],
                                  @"totalFileBytes": [NSNumber numberWithLongLong:totalBytesExpectedToReadForFile],
                                  };
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadingWatchVersionProcessNotification object:nil userInfo:dic];
        }];
        [_manager.operationQueue addOperation:requestOperation];
        
        NSLog(@" %f",application.backgroundTimeRemaining);
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
    
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


- (AFHTTPRequestOperation *)getWatchVersionDown:(void (^)(NSMutableArray *array))success

{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
   //     NSData *xmlData = [NSData alloc] initWithData:(NSData *) operation.responseString;
        
        
        //使用NSData对象初始化
        NSError *error;
        GDataXMLDocument *docm = [[GDataXMLDocument alloc] initWithXMLString:operation.responseString error:&error];
        
        //获取根节点（Products）
        GDataXMLElement *RootElement = [docm rootElement];
        
        //获取根节点下的节点（product）
        NSArray *products = [RootElement elementsForName:@"product"];
        
        
        NSMutableArray *productArray = [[NSMutableArray alloc] init];
        
        for ( GDataXMLElement *product in products ) {
            NSMutableDictionary *productDic = [NSMutableDictionary dictionary];
            
            //获取model节点的值
            GDataXMLElement *modelElement = [[product elementsForName:@"model"] objectAtIndex:0];
            NSString * model = [modelElement stringValue];
            NSLog(@"product is:%@",model);
            
            //获取url节点的值
            GDataXMLElement *urlElement = [[product elementsForName:@"url"] objectAtIndex:0];
            NSString *url = [urlElement stringValue];
            NSLog(@"the url is:%@",url);
            NSLog(@"-------------------");
            [productDic setObject:model forKey:@"product"];
            [productDic setObject:url   forKey:@"url"];
            [productArray addObject:productDic];
        }
        if(success)
        {
            success(productArray);
            [[NSNotificationCenter defaultCenter] postNotificationName:kCheckWatchVersionNotification object:nil userInfo:nil];
        }

    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        NSLog(@"Error: %@", error);
    };
    

    
    _manager.responseSerializer = [AFXMLParserResponseSerializer new];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    AFHTTPRequestOperation *op = [_manager GET:@"ota/update_products_list.xml" parameters:nil success:requestSuccess failure:requestFailure];
    NSLog(@"request: %@", op.request.URL.absoluteString);
    return op;
}

-(AFHTTPRequestOperation *)checkWatchVersionNewDown:(NSString *)url success:(void (^)(NSMutableArray *array))success
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //     NSData *xmlData = [NSData alloc] initWithData:(NSData *) operation.responseString;
        
        
        //使用NSData对象初始化
        NSError *error;
        GDataXMLDocument *docm = [[GDataXMLDocument alloc] initWithXMLString:operation.responseString error:&error];
        
        //获取根节点（update_list）
        GDataXMLElement *RootElement = [docm rootElement];
        
        //获取根节点下的节点（update）
        NSArray *updates = [RootElement elementsForName:@"update"];
        
        
        NSMutableArray *updateArray = [[NSMutableArray alloc] init];
        
        for ( GDataXMLElement *update in updates ) {
            
            NSMutableDictionary *updateDic = [NSMutableDictionary dictionary];
            //获取version_from节点的值
            GDataXMLElement *oldVersionElement = [[update elementsForName:@"version_from"] objectAtIndex:0];
            NSString * oldVersion = [oldVersionElement stringValue];
            NSLog(@"the oleVersion is:%@",oldVersion);
            
            //获取version_to节点的值
            GDataXMLElement *newVersionElement = [[update elementsForName:@"version_to"] objectAtIndex:0];
            NSString *newVersion = [newVersionElement stringValue];
            NSLog(@"the newVersion is:%@",newVersion);
            NSLog(@"-------------------");
            
            //获取url节点的值
            GDataXMLElement *urlElement = [[update elementsForName:@"url"] objectAtIndex:0];
            NSString *url = [urlElement stringValue];
            NSLog(@"the url is:%@",url);
            NSLog(@"-------------------");
            
            //获取size节点的值
            GDataXMLElement *sizeElement = [[update elementsForName:@"size"] objectAtIndex:0];
            NSString *size = [sizeElement stringValue];
            NSLog(@"the size is:%@",size);
            NSLog(@"-------------------");
            
            //获取description节点的值
            GDataXMLElement *descriptionElement = [[update elementsForName:@"description"] objectAtIndex:0];
            NSString *description = [descriptionElement stringValue];
            NSLog(@"the description is:%@",description);
            NSLog(@"-------------------");

            
            
            [updateDic setObject:oldVersion forKey:@"oldVersion"];
            [updateDic setObject:newVersion forKey:@"newVersion"];
            [updateDic setObject:url   forKey:@"url"];
            [updateDic setObject:size   forKey:@"size"];
            [updateDic setObject:description forKey:@"description"];
            [updateArray addObject:updateDic];
        }
        if(success)
        {
            success(updateArray);
            [[NSNotificationCenter defaultCenter] postNotificationName:kcompareWatchVersionListNotification object:nil userInfo:nil];
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        NSLog(@"Error: %@", error);
    };
    
    NSString * baseURL = @"http://r.tomoon.cn/";
    NSInteger index = baseURL.length;
    NSString *tempURL = [url substringFromIndex:index];
    _manager.responseSerializer = [AFXMLParserResponseSerializer new];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    AFHTTPRequestOperation *op = [_manager GET:tempURL parameters:nil success:requestSuccess failure:requestFailure];
    NSLog(@"request: %@", op.request.URL.absoluteString);
    return op;
}

-(AFHTTPRequestOperation *)getWheather:(NSString *)weatherurl
                               success:(void (^)(NSString *response))success
{
    NSLog(@"success");
    
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        //     NSData *xmlData = [NSData alloc] initWithData:(NSData *) operation.responseString;
//        
//        
//        //使用NSData对象初始化
//        NSError *error;
        NSString *responseString = operation.responseString;
//        
//        //获取根节点（Products）
//        GDataXMLElement *RootElement = [docm rootElement];
//        
//        //获取根节点下的节点（product）
//        NSArray *products = [RootElement elementsForName:@"product"];
//        
//        
//        NSMutableArray *productArray = [[NSMutableArray alloc] init];
//        
//        for ( GDataXMLElement *product in products ) {
//            NSMutableDictionary *productDic = [NSMutableDictionary dictionary];
//            
//            //获取model节点的值
//            GDataXMLElement *modelElement = [[product elementsForName:@"model"] objectAtIndex:0];
//            NSString * model = [modelElement stringValue];
//            NSLog(@"product is:%@",model);
//            
//            //获取url节点的值
//            GDataXMLElement *urlElement = [[product elementsForName:@"url"] objectAtIndex:0];
//            NSString *url = [urlElement stringValue];
//            NSLog(@"the url is:%@",url);
//            NSLog(@"-------------------");
//            [productDic setObject:model forKey:@"product"];
//            [productDic setObject:url   forKey:@"url"];
//            [productArray addObject:productDic];
        
        
        
        if(success)
        {
            success(responseString);
            [[NSNotificationCenter defaultCenter] postNotificationName:kSendWeatherInfoNotification object:nil userInfo:nil];
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        NSLog(@"Error: %@", error);
    };

//    _manager.responseSerializer = [AFXMLParserResponseSerializer new];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  //  _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    AFHTTPRequestOperation *op = [_manager GET:weatherurl parameters:nil success:requestSuccess failure:requestFailure];
    NSLog(@"request: %@", op.request.URL.absoluteString);
    return  op;
}

//获取商品列表
- (NSMutableArray*)getShoppingList:(NSString *)shopurl
{
    NSURL* url = [NSURL URLWithString:shopurl];
    //通过URL创建网络请求
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
    //连接服务器
    NSData* received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    NSString* str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    SBJsonParser* jsonParser = [[SBJsonParser alloc] init];
    
    NSMutableArray* arr = [jsonParser objectWithString:str];
    
    NSLog(@"%@",arr);
    
    if([arr count]>0)
    {
        return arr;
    }
    else
    {
        return 0;
    }
}

@end
