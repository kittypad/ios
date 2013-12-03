//
//  NetworkManager.m
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "NetworkManager.h"
#import <AFNetworking.h>

#define kBaseURL [NSURL URLWithString:@"http://r.tomoon.cn"]

@interface NetworkManager ()
{
    AFHTTPClient *client;
}

@end

@implementation NetworkManager

+ (NetworkManager *)sharedManager
{
    static NetworkManager *sharedManagerInstance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[NetworkManager alloc] init];
    });
    
    return sharedManagerInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        client = [AFHTTPClient clientWithBaseURL:kBaseURL];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
        
        
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024
                                                             diskCapacity:40 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    }
    
    return self;
}



- (AFJSONRequestOperation *)getDownloadList:(NSUInteger)type
                                       page:(NSUInteger)page
                                    success:(void (^)(NSArray *array))success
                                    failure:(void (^)(NSError *error))failure
{
    
    NSDictionary *params = @{ @"p": [NSNumber numberWithInteger:page],
                              @"t": [NSNumber numberWithInteger:type] };
    
    NSURLRequest *request = [client requestWithMethod:@"GET" path:@"app" parameters:params];
    
    void (^requestSuccess)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
    };
    
    void (^requestFailure)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
    };
    
    
    NSLog(@"%@", request.URL);
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    
    [op start];
    return op;
}

@end
