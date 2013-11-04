//
//  AppDelegate.m
//  Twatch
//
//  Created by 龚涛 on 10/10/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "TMNavigationController.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    if (!IS_IOS7) {
        [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    TMNavigationController *rootViewController = [[TMNavigationController alloc] initWithRootViewController:[[RootViewController alloc] initWithNibName:nil bundle:nil]];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    self.haveNewVersion = NO;
    [self performSelector:@selector(checkVersion) withObject:nil afterDelay:0];
    [self prepareShareData];
    
    return YES;
}

-(void)checkVersion
{
    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",APPID]] encoding:NSUTF8StringEncoding error:nil];
    if (string!=nil && [string length]>0 && [string rangeOfString:@"version"].length==7) {
        NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *appInfo1=[string substringFromIndex:[string rangeOfString:@"\"version\":"].location+10];
        NSString *appInfo2=[string substringFromIndex:[string rangeOfString:@"\"trackViewUrl\":"].location+15];
        appInfo1=[[appInfo1 substringToIndex:[appInfo1 rangeOfString:@","].location] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        appInfo2=[[appInfo2 substringToIndex:[appInfo2 rangeOfString:@","].location] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if (![appInfo1 isEqualToString:version]) {
            self.haveNewVersion = YES;
        }
    }
}
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)prepareShareData
{
    [ShareSDK registerApp:@"b2a621782b0"];
    
    //添加微信应用
    [ShareSDK connectWeChatWithAppId:@"wx601a43912ee66d19"        //此参数为申请的微信AppID
                           wechatCls:[WXApi class]];
    
//    //添加新浪微博应用
//    [ShareSDK connectSinaWeiboWithAppKey:@"177815352"
//                               appSecret:@"83ce845e210aeb0ed385c0419697647d"
//                             redirectUri:@"http://www.tomoon.cn"];
//    
//    //添加腾讯微博应用
//    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
//                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
//                                redirectUri:@"http://www.sharesdk.cn"];
//    
    //添加QQ空间应用
//    [ShareSDK connectQZoneWithAppKey:@"100598779"
//                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
//                   qqApiInterfaceCls:[QQApiInterface class]
//                     tencentOAuthCls:[TencentOAuth class]];

    
    //添加豆瓣应用
    [ShareSDK connectDoubanWithAppKey:@"03711db761b697290a5359262523c57b"
                            appSecret:@"ceb6d9dfe7d294ff"
                          redirectUri:@"http://www.tomoon.cn"];
    
    //添加人人网应用
    [ShareSDK connectRenRenWithAppKey:@"872839531cd843839f01b9974ce4307e"
                            appSecret:@"3f73d4a45de34115b9e84f7430cabba7"];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
