//
//  NetDatamanager.m
//  Twatch
//
//  Created by yugong on 14-7-7.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "NetDatamanager.h"

#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking.h>
#import "ZipArchive.h"
#import "AFURLResponseSerialization.h"
#import <GDataXMLNode.h>
#import "WatchConstant.h"

@interface NetDatamanager ()
{
    AFHTTPRequestOperationManager *_manager;
}

- (void)_unzipFile:(NSString *)fileName toFile:(NSString *)resultName completion:(void (^)(void))block;

@end

@implementation NetDatamanager

+ (NetDatamanager *)sharedManager
{
    static NetDatamanager *sharedManagerInstance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[NetDatamanager alloc] init];
    });
    
    return sharedManagerInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [_manager.operationQueue setMaxConcurrentOperationCount:3];
        
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HTTPBASE_URL]];
        
        //_manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [_manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
        
        [_manager.requestSerializer setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
         NSString *uuid1 =[[NSUUID UUID] UUIDString];
        [_manager.requestSerializer setValue:uuid1 forHTTPHeaderField:@"UUID"];
        [_manager.requestSerializer setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
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


//登录
-(AFHTTPRequestOperation *)login:(NSString*) user
                        password:(NSString*)password
                         success:(void (^)(id response, NSString* str))success
                         failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"userName", [self md5:password], @"userPass", nil];
    
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"login" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

//注册
-(AFHTTPRequestOperation *)rigister:(NSString*) user password:(NSString*)password identifycode:(NSString*)identifycode success:(void (^)(id response, NSString* str))success failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"userName", [self md5:password], @"userPass", identifycode, @"userCode", nil];
    
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"createAccount" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

//发送短信
-(AFHTTPRequestOperation *)sendSMS:(NSString*)user forgetPassword:(NSString*) forgetPassword success :(void (^)(id response, NSString* str))success failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
        
    };
    
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog ( @"error description:%@" ,[error description ]);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"phoneNum", forgetPassword, @"forgetPassword", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    NSLog(@"%@",jsonString);
    
    [_manager.requestSerializer setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [_manager.requestSerializer setValue:@"getValidateCode" forHTTPHeaderField:@"ACTION"];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

//修改个人信息
-(AFHTTPRequestOperation *)editMyMessage:(NSDictionary*) para success:(void (^)(id response, NSString* str))success failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
            NSLog(@"response:%@", responseObject);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:para];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"changeUserProfile" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

//修改密码
-(AFHTTPRequestOperation *)changePassword:(NSString*) username passwordold:(NSString*) passwordold passwordnew:(NSString*) passwordmew success:(void (^)(id response, NSString* str))success failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:username,@"userName", passwordold, @"userPassOld", passwordmew, @"userPassNew", nil];
    
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"changePassword" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

//忘记密码
-(AFHTTPRequestOperation *)forgetPassword:(NSString*) username usercode:(NSString*) usercode passwordnew:(NSString*) passwordmew success:(void (^)(id response, NSString* str))success failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:username,@"userName", usercode, @"userCode", passwordmew, @"userCode", nil];
    
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"forgetPassword" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

//获取用户信息
-(AFHTTPRequestOperation *)getUserProfile:(NSString*) username success:(void (^)(id response, NSString* str))success failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:username,@"userName", nil];
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"getUserProfile" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    NSString *strMD5 = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15],
                        result[16], result[17],result[18], result[19],
                        result[20], result[21],result[22], result[23],
                        result[24], result[25],result[26], result[27],
                        result[28], result[29],result[30], result[31]
                        ];
    return [strMD5 substringWithRange:NSMakeRange(0, 32)];
}

-(NSString*)alertMessage:(NSString*)code
{
    int icode = [code intValue];
    NSString* strmessage = [[NSString alloc] init];
    switch (icode) {
        case 0:
            strmessage = [NSString stringWithFormat:@"成功"];
            break;
        case 1001:
            strmessage = [NSString stringWithFormat:@"用户/手机号已被注册"];
            break;
        case 1003:
            strmessage = [NSString stringWithFormat:@"用户名不存在"];
            break;
        case 1004:
            strmessage = [NSString stringWithFormat:@"密码不正确"];
            break;
        case 2002:
            strmessage = [NSString stringWithFormat:@"用户/手机号未注册"];
            break;
        case 9990:
            strmessage = [NSString stringWithFormat:@"发送短信失败"];
            break;
        case 9999:
            strmessage = [NSString stringWithFormat:@"系统错误"];
            break;
        case 9991:
            strmessage = [NSString stringWithFormat:@"短信验证码错误"];
            break;
        case 2001:
            strmessage = [NSString stringWithFormat:@"用户/手机号、密码不正确"];
            break;
        case 2003:
            strmessage = [NSString stringWithFormat:@"手机验证码不正确"];
            break;
        case 3001:
            strmessage = [NSString stringWithFormat:@"头像文件不存在"];
            break;
        default:
            break;
    }
    
    return strmessage;
}

-(AFHTTPRequestOperation *)uploadPhoto:(NSString*) username iamge:(UIImage*)image filename:(NSString*)filename success:(void (^)(id response))success
                               failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
     [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    NSData* imageData = UIImageJPEGRepresentation(image, 1);
    [manager.requestSerializer setValue:username forHTTPHeaderField:@"userName"];
    
     AFHTTPRequestOperation *operation = [manager POST:@"http://www.yugong-tech.com/up_avatar.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         
        [formData appendPartWithFileData:imageData
                                    name:@"uploadedfile"
                                fileName:filename mimeType:@"image/jpeg"];
        
        // etc.
    } success:requestSuccess failure:requestFailure];
    
    return operation;
}

//-(void)sendImage:(UIImage*) image username:(NSString*)username
//{
//    //NSString *urlPic = [NSString stringWithFormat:@"%@",@"http://192.168.1.80/up_avatar.php"];
//    NSString *urlPic = [NSString stringWithFormat:@"%@",@"http://www.yugong-tech.com/up_avatar.php"];
//  
//    NSMutableURLRequest * request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlPic parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSData *imageData = UIImagePNGRepresentation(image);
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        // 设置时间格式
//        formatter.dateFormat = @"yyyyMMddHHmmss";
//        NSString *str = [formatter stringFromDate:[NSDate date]];
//        [formData appendPartWithFileData:imageData name:@"uploadedfile" fileName:str mimeType:@"image/jpeg"];
//    } error:nil];
//
//    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSProgress *progress = nil;
//    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, responseObject);
//        }
//    }];
//    [uploadTask resume];
//}

-(AFHTTPRequestOperation*)sendMessage:(NSString*)fromUserName toUserName:(NSString*)toUserName content:(NSString*)content voiceFileName:(NSString*)voiceFileName success:(void (^)(id response, NSString* str))success
           failure:(void (^)(NSError *error))failure;
{
    
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:fromUserName,@"fromUserName",toUserName,@"toUserName",content?content:[NSNull null],@"content",voiceFileName?voiceFileName:[NSNull null],@"voice", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"sendMessage" forHTTPHeaderField:@"ACTION"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

-(AFHTTPRequestOperation*)getMessage:(NSString*)userName  success:(void (^)(id response))success
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
            NSLog(@"talk message:%@",responseObject);
        }
        
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        NSLog(@"Error: %@", error);
    };
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:userName,@"userName", nil];
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    NSString* jsonString=nil;
    jsonString = [writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"Device-Type"];
    [request setValue:@"getMessage" forHTTPHeaderField:@"Action"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    return operation;
}

-(AFHTTPRequestOperation *)uploadVoiceFile:(NSString*)filepath
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"savefilepath:%@",filepath);
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filepath];
    
    NSString* theFileName = [NSString stringWithFormat:@"%@.amr", [[filepath lastPathComponent] stringByDeletingPathExtension]];
    NSLog(@"AmrFileName: %@", theFileName);
    
    AFHTTPRequestOperation *operation = [manager POST:@"http://www.yugong-tech.com/upload_voice_wt" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data
                                    name:@"uploadedfile"
                                fileName:theFileName mimeType:@"application/octet-stream"];
        
        // etc.
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        NSLog(@"Response: %@", operation.response.allHeaderFields);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    return operation;
}

-(NSData*)downLoadVoiceFile:(NSString*)fileName
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@" http://www.yugong-tech.com/download_voice_wt?voice_file=%@",fileName]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    
    //[request setValue:[self.myMessageDic objectForKey:@"Avatar"] forKey:@"avatar"];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response error:&error];
    
    return result;

//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:fileName];
//    if ([fileManager fileExistsAtPath:applicationDocumentsDir])
//        NSLog(@"applicationDocumentsDir exists");   // verifies directory exist
//    
// 
//    if (result) {
//        NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
//                                                      length:[result length] encoding: NSUTF8StringEncoding];
//        
//        NSLog(@"%@", content); // verifies data was downloaded correctly
//        
//        NSError* error;
//        [result writeToFile:storePath options:NSDataWritingAtomic error:&error];
//        
//        if(error != nil)
//            NSLog(@"write error %@", error);
//    }
}

-(AFHTTPRequestOperation *)checkUserNameValid:(NSString*)UserName
                                   Userlist:(NSArray*)Userlist
                                      success:(void (^)(id response, NSString* str))success
                                      failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:UserName,@"userName",Userlist,@"userNameList", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"checkUserNameValid" forHTTPHeaderField:@"Action"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    NSLog ( @"operation: %@" , operation.responseString );
    
    return operation;
}

//发送关注
-(AFHTTPRequestOperation *)focusSomeone:(NSString*)userName
                          focusUserName:(NSString*)focusUserName
                              verifyMsg:(NSString*)verifyMsg
                                success:(void (^)(id response, NSString* str))success
                                failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:userName,@"userName",focusUserName,@"focusUserName",verifyMsg?verifyMsg:[NSNull null],@"verifyMsg", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request setValue:@"focusSomeone" forHTTPHeaderField:@"Action"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    NSLog ( @"operation: %@" , operation.responseString );
    
    return operation;
}

//反馈关注
-(AFHTTPRequestOperation *)feedbackFocus:(NSString*)userName
                           focusUserName:(NSString*)focusUserName
                                  action:(NSString*)action
                                 success:(void (^)(id response, NSString* str))success
                                 failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:userName,@"userName",focusUserName,@"focusUserName",action,@"action", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"Device-Type"];
    [request setValue:@"feedbackFocus" forHTTPHeaderField:@"Action"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    NSLog ( @"operation: %@" , operation.responseString );
    
    return operation;
}

//删除关注
-(AFHTTPRequestOperation *)deleteFocus:(NSString*)userName
                         focusUserName:(NSString*)focusUserName
                               success:(void (^)(id response, NSString* str))success
                               failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:userName,@"userName",focusUserName,@"focusUserName", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"Device-Type"];
    [request setValue:@"deleteFocus" forHTTPHeaderField:@"Action"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    NSLog ( @"operation: %@" , operation.responseString );
    
    return operation;
}

//获取联系人列表
-(AFHTTPRequestOperation *)getMyFocusList:(NSString*)UserName
                                focustype:(NSString*)focustype
                                  success:(void (^)(id response, NSString* str))success
                                  failure:(void (^)(NSError *error))failure
{
    void (^requestSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString* resultcode = [headers objectForKey:@"Result-Code"];
            success(responseObject, resultcode);
        }
    };
    void (^requestFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)  {
        if(failure)
        {
            failure(error);
        }
        NSLog(@"Error: %@", error);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:UserName,@"userName", focustype, @"focusType", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:@"POST" URLString:[_manager.baseURL absoluteString] parameters:nil error:nil];
    [request setValue:@"WT" forHTTPHeaderField:@"Device-Type"];
    [request setValue:@"obtainMyFocusList" forHTTPHeaderField:@"Action"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"CONTENT_LENGTH"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:requestSuccess failure:requestFailure];
    [_manager.operationQueue addOperation:operation];
    
    NSLog ( @"operation: %@" , operation.responseString );
    
    return operation;
}

@end
