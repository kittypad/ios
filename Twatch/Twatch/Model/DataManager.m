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
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:kBaseURL];
        
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024
                                                             diskCapacity:40 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    }
    
    return self;
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
                    DownloadObject *obj = [[DownloadObject alloc] init];
                    obj.apkUrl = dic[@"apkUrl"];
                    obj.iconUrl = dic[@"iconUrl"];
                    obj.intro = dic[@"intro"];
                    obj.name = dic[@"name"];
                    obj.pkg = dic[@"pkg"];
                    obj.size = dic[@"size"];
                    obj.type = dic[@"type"];
                    obj.ver = dic[@"ver"];
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
