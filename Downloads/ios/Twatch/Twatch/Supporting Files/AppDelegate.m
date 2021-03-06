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
#import "DataManager.h"

#import "CommonTabBarViewController.h"
#import "AppCenterViewController.h"
#import "SettingViewController.h"
#import "MyCenterViewController.h"
#import "ShoppingTableViewController.h"
#import "SettingsViewController.h"

#import "BLEServerManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    if (!IS_IOS7) {
        [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }
    
    BLEServerManager *manger = [BLEServerManager sharedManager];
    
    if (manger.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        //[manger startAdvertising];
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isWatchConnected"]) {
//            [self getWatchSet];
//        }
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    
    MyCenterViewController* myCenterController = [[MyCenterViewController alloc] init];
    TMNavigationController* myCenterNaviContronller = [[TMNavigationController alloc] initWithRootViewController:myCenterController];
    [myCenterController.navigationController setNavigationBarHidden:YES];
    [items addObject:myCenterNaviContronller];
    
    AppCenterViewController* appCenterList = [[AppCenterViewController alloc] init];
    [items addObject:appCenterList];
    
    ShoppingTableViewController* shoppingController = [[ShoppingTableViewController alloc] init];
//    //[shoppingController.navigationController setNavigationBarHidden:YES];
//    TMNavigationController* shopNaviContronller = [[TMNavigationController alloc] initWithRootViewController:shoppingController];
    [items addObject:shoppingController];
    
    SettingsViewController* settingViewController = [[SettingsViewController alloc] init];
    TMNavigationController* settingNaviContronller = [[TMNavigationController alloc] initWithRootViewController:settingViewController];
    [settingViewController.navigationController setNavigationBarHidden:YES];
    [items addObject:settingNaviContronller];
    //[items addObject:settingViewController];
    // items是数组，每个成员都是UIViewController
    CommonTabBarViewController* tabBar = [[CommonTabBarViewController alloc] init];
    //[tabBar setTitle:@"TabBarController"];
    tabBar.tabBar.backgroundImage = [UIImage imageNamed:@"tabbg"];
    tabBar.tabBar.selectedImageTintColor = [UIColor colorWithHex:@"FF6223"];
    //tabBar.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"<#string#>"];
    [tabBar setViewControllers:items];
    
    TMNavigationController* tabBarNaviContronller = [[TMNavigationController alloc] initWithRootViewController:tabBar];
    [tabBar.navigationController setNavigationBarHidden:YES];
    self.window.rootViewController = tabBarNaviContronller;
    
    //TMNavigationController *rootViewController = [[TMNavigationController alloc] initWithRootViewController:self.rootViewController];
    //self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    self.haveNewVersion = NO;
    [self checkVersion];
    [self prepareShareData];
    
    [[DataManager sharedManager] startAllDownloadingFile];
    
    
//    [BLEServerManager sharedManager].peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionRestoreIdentifierKey:(launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey] ?: [[NSUUID UUID] UUIDString])}];
//    
//    //记录蓝牙连接标识
//    NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey];
//    for (NSString* identifier in centralManagerIdentifiers) {
//        if ([identifier isEqualToString:@"com.tfire.ble"]) {
//            //get your manager
//        }
//    }
//    
    
    return YES;
}

//-(void)getWatchSet
//{
//    [[BLEServerManager sharedManager] sendWatchLanguage:@"" finish:^(void){
//    }];
//    sleep(10);
//    [[BLEServerManager sharedManager] sendWatchSleepTime:@"" finish:^(void){
//    }];
//    sleep(10);
//    [[BLEServerManager sharedManager] getIsVibrate];
//    sleep(10);
//    [[BLEServerManager sharedManager] getInverseColor];
//    sleep(10);
//    [[BLEServerManager sharedManager] getPowerOnWatch];
//    sleep(10);
//    [[BLEServerManager sharedManager] getPowerOffWatch];
//}

-(void)checkVersion
{
    NSString *storeString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APPID];
    NSURL *storeURL = [NSURL URLWithString:storeString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ( [data length] > 0 && !error )
         {
             NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                 
                 if ( ![versionsInAppStore count] ) {
                     return;                     
                 } else {
                     NSString *theAppVersion=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                     NSString *currentAppStoreVersion = [versionsInAppStore objectAtIndex:0];

                     if ([theAppVersion compare:currentAppStoreVersion options:NSNumericSearch] == NSOrderedAscending) {
                            self.haveNewVersion = YES;
                     }
                 }
             });
             
             
         }
     }];
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
    
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"177815352"
                               appSecret:@"83ce845e210aeb0ed385c0419697647d"
                             redirectUri:@"http://www.tomoon.cn"];
    
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"801439497"
                                  appSecret:@"be98b1992a65555005f9b67789a7f2c8"
                                redirectUri:@"http://developer.tomoon.cn/tools/tomoonV1.0.apk"];
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
    
    BLEServerManager *manger = [BLEServerManager sharedManager];

    if (manger.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        //[manger startAdvertising];
        manger.peripheralManager.delegate = self;
    }
    
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
}

//实现恢复状态
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSArray *peripherals =
    dict[CBCentralManagerRestoredStatePeripheralsKey];
    NSLog(@"Sent: %@",peripherals);
}

-(void)timerAction:(NSTimer*)time
{
    //    [[BLEServerManager sharedManager] sendWatchLanguage:@"" finish:^(void){
    //    }];
    
    if (![BLEServerManager sharedManager].isWatchConnected) {
        [[BLEServerManager sharedManager] sendBoundCommand];
    }
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
