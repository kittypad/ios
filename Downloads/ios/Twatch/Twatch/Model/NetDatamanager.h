//
//  NetDatamanager.h
//  Twatch
//
//  Created by yugong on 14-7-7.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@interface NetDatamanager : NSObject

+ (NetDatamanager *)sharedManager;

//登录
-(AFHTTPRequestOperation *)login:(NSString*) user
                        password:(NSString*)password
                         success:(void (^)(id response, NSString* str))success
                         failure:(void (^)(NSError *error))failure;

//注册
-(AFHTTPRequestOperation *)rigister:(NSString*) user
                           password:(NSString*)password
                       identifycode:(NSString*)identifycode
                            success:(void (^)(id response, NSString* str))success
                            failure:(void (^)(NSError *error))failure;

//发送短信
-(AFHTTPRequestOperation *)sendSMS:(NSString*)user
                    forgetPassword:(NSString*) forgetPassword
                          success :(void (^)(id response, NSString* str))success
                           failure:(void (^)(NSError *error))failure;

//修改个人信息
-(AFHTTPRequestOperation *)editMyMessage:(NSDictionary*) para
                                 success:(void (^)(id response, NSString* str))success
                                 failure:(void (^)(NSError *error))failure;

//修改密码
-(AFHTTPRequestOperation *)changePassword:(NSString*) username
                              passwordold:(NSString*) passwordold
                              passwordnew:(NSString*) passwordmew
                                  success:(void (^)(id response, NSString* str))success
                                  failure:(void (^)(NSError *error))failure;

//忘记密码
-(AFHTTPRequestOperation *)forgetPassword:(NSString*) username
                                 usercode:(NSString*) usercode
                              passwordnew:(NSString*) passwordmew
                                  success:(void (^)(id response, NSString* str))success
                                  failure:(void (^)(NSError *error))failure;

//获取用户信息
-(AFHTTPRequestOperation *)getUserProfile:(NSString*) username
                                  success:(void (^)(id response, NSString* str))success
                                  failure:(void (^)(NSError *error))failure;

//MD5加密（32位加密）
- (NSString *)md5:(NSString *)str;

//网络请求返回提示
-(NSString*)alertMessage:(NSString*)code;

//上传头像
-(AFHTTPRequestOperation *)uploadPhoto:(NSString*) username
                                 iamge:(UIImage*)image
                              filename:(NSString*)filename
                               success:(void (^)(id response))success
                               failure:(void (^)(NSError *error))failure;


//发送消息
-(AFHTTPRequestOperation *)sendMessage:(NSString*)fromUserName
                            toUserName:(NSString*)toUserName
                               content:(NSString*)content
                         voiceFileName:(NSString*)voiceFileName
                               success:(void (^)(id response, NSString* str))success
                               failure:(void (^)(NSError *error))failure;

//上传音频
-(AFHTTPRequestOperation *)uploadVoiceFile:(NSString*)filepath;

//下载音频
-(NSData*)downLoadVoiceFile:(NSString*)fileName;

//获取消息
-(AFHTTPRequestOperation*)getMessage:(NSString*)userName  success:(void (^)(id response))success;

//检测用户名是否存在
-(AFHTTPRequestOperation *)checkUserNameValid:(NSString*)UserName
                            Userlist:(NSArray*)Userlist
                               success:(void (^)(id response, NSString* str))success
                               failure:(void (^)(NSError *error))failure;

//发送关注
-(AFHTTPRequestOperation *)focusSomeone:(NSString*)userName
                            focusUserName:(NSString*)focusUserName
                               verifyMsg:(NSString*)verifyMsg
                               success:(void (^)(id response, NSString* str))success
                               failure:(void (^)(NSError *error))failure;

//反馈关注
-(AFHTTPRequestOperation *)feedbackFocus:(NSString*)userName
                            focusUserName:(NSString*)focusUserName
                               action:(NSString*)action
                               success:(void (^)(id response, NSString* str))success
                               failure:(void (^)(NSError *error))failure;
//删除关注
-(AFHTTPRequestOperation *)deleteFocus:(NSString*)userName
                         focusUserName:(NSString*)focusUserName
                               success:(void (^)(id response, NSString* str))success
                               failure:(void (^)(NSError *error))failure;
//获取联系人列表
-(AFHTTPRequestOperation *)getMyFocusList:(NSString*)UserName
                                focustype:(NSString*)focustype
                                  success:(void (^)(id response, NSString* str))success
                                  failure:(void (^)(NSError *error))failure;

@end
