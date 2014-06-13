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

//登录
-(AFHTTPRequestOperation *)login:(NSString*)url user:(NSString*) user password:(NSString*)password success:(void (^)(id response))success;

//注册
-(AFHTTPRequestOperation *)rigister:(NSString*)url user:(NSString*) user password:(NSString*)password identifycode:(NSString*)identifycode success:(void (^)(id response))success;

//发送短信
-(AFHTTPRequestOperation *)sendSMS:(NSString*)url user:(NSString*)user success :(void (^)(id response))success;

//修改个人信息
-(AFHTTPRequestOperation *)editMyMessage:(NSString*)url para:(NSDictionary*) para success:(void (^)(id response))success;

//修改密码
-(AFHTTPRequestOperation *)changePassword:(NSString*)url username:(NSString*) username passwordold:(NSString*) passwordold passwordnew:(NSString*) passwordmew success:(void (^)(id response))success;

-(NSURLConnection*)changePassword:(NSString*)url username:(NSString*) username passwordold:(NSString*) passwordold passwordnew:(NSString*) passwordmew;

//忘记密码
-(AFHTTPRequestOperation *)forgetPassword:(NSString*)url username:(NSString*) username usercode:(NSString*) usercode passwordnew:(NSString*) passwordmew success:(void (^)(id response))success;

-(NSURLConnection *)forgetPassword:(NSString*)url username:(NSString*) username usercode:(NSString*) usercode passwordnew:(NSString*) passwordmew;

//获取用户信息
-(AFHTTPRequestOperation *)getUserProfile:(NSString*)url username:(NSString*) username success:(void (^)(id response))success;

- (NSString *)md5:(NSString *)str;

//网络请求返回提示
-(NSString*)alertMessage:(NSString*)code;
@end
