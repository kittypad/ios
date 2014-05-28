//
//  BLEServerManager.m
//  Twatch
//
//  Created by huxiaoxi on 14-3-13.
//


#import "AFDownloadRequestOperation.h"
#import "BLEServerManager.h"
#import <Foundation/NSJSONSerialization.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <SBJson.h>

#import "DataManager.h"

#import "ViewUtils.h"
#import "WatchConstant.h"


#define NOTIFY_MTU      18//116

#define UUID_KEY @"MobileUUID"

//串行队列，同时只执行一个task
static dispatch_queue_t ble_communication_queue() {
    static dispatch_queue_t af_ble_communication_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_ble_communication_queue = dispatch_queue_create("com.tfire.ble", DISPATCH_QUEUE_SERIAL);
    });
    return af_ble_communication_queue;
}


@interface BLEServerManager ()

@end

@implementation BLEServerManager

+ (BLEServerManager *)sharedManager
{
    static BLEServerManager *sharedManagerInstance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[BLEServerManager alloc] init];
    });
    
    return sharedManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
//        _unConnectedDevices = [[NSMutableArray alloc] init];
        
        // Start up the CBPeripheralManager
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        
        _isSending = NO;
        
        _isWatchConnected = NO;
        
        _isNotifyCharacter = NO;
        
        _isTransferCharacter = NO;
        
        _transferCharacteristic = nil;
        self.isSendFileName = NO;
        self.isResendFile = NO;
        _retryCount = 0;
        
        //从服务器获得天气信息后的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveGetweatherInfo:) name:kSendWeatherInfoNotification object:nil];
        
        
        [self _initUUID];
        
        
        //经纬度初始化
        if ([CLLocationManager locationServicesEnabled])
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 5.0;

            }
        
        


    }
    return self;
}

- (void)_initUUID
{
    NSString *uuidString = [[NSUserDefaults standardUserDefaults] objectForKey:UUID_KEY];
    
    if(!uuidString || [uuidString length] == 0)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(nil);
        CFStringRef stringRef = CFUUIDCreateString(nil, uuidRef);
        uuidString = (NSString *)CFBridgingRelease(CFStringCreateCopy(nil, stringRef));
        CFRelease(uuidRef);
        CFRelease(stringRef);
        
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:UUID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _mobileBLEName = [NSString stringWithFormat:@"ios-%@", uuidString];
    NSLog(@"UUID:%@", uuidString);
}

#pragma mark - locationManager

-(void)updateLocation
{
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    CGFloat tempLongtitude;
    CGFloat tempLatitude;

    if(_longitude < newLocation.coordinate.longitude )
    {
        tempLongtitude = newLocation.coordinate.longitude - _longitude;
    }
    else
    {
        tempLongtitude = _longitude - newLocation.coordinate.longitude;
    }
    
    if(_latitude < newLocation.coordinate.latitude)
    {
        tempLatitude = newLocation.coordinate.latitude - _latitude;
    }
    else
    {
        tempLatitude = _latitude - newLocation.coordinate.latitude;
    }
        
    if(tempLongtitude < 0.01 || tempLatitude < 0.01)
    {
        _longitude = (int)newLocation.coordinate.longitude;
        _latitude  = (int)newLocation.coordinate.latitude;
       [self sendLocationCommand:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}





#pragma mark - Public

- (BOOL)isSendingData
{
    if (self.isSending) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"蓝牙传输" message:@"正在发送其他数据，请稍后尝试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    return self.isSending;
}

- (BOOL)isBLEPoweredOn;
{
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"尚未开启蓝牙，请进入设置界面开启蓝牙"
                                                           delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
        return NO;
    }
    return YES;
}


- (void)startAdvertising
{
    NSLog(@"开始广播...");
//    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID],[CBUUID UUIDWithString:IND_ANCS_SV_UUID]],CBAdvertisementDataLocalNameKey:@"TFireAPP" }];
    
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]],CBAdvertisementDataLocalNameKey:@"TFireAPP" }];
}


- (void)stopAdvertising
{
    
    [self.peripheralManager stopAdvertising];
}

- (void)saveConnectedWatch:(NSDictionary *)responseDic
{
    [[NSUserDefaults standardUserDefaults] setObject:WATCH_NAME
                                              forKey:kBLEBindingWatch];
    [[NSUserDefaults standardUserDefaults] setObject:[responseDic objectForKey:@"version"] forKey:@"watch version"];
}


- (void)removeConnectedWatch
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBLEBindingWatch];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"watch version"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
    
}

- (BOOL)isBLEConnected
{
    if (![self isBLEConnectedWithoutAlert]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"尚未连接到T-Fire设备，是否进入同步界面连接设备？"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:@"取消", nil];
            [alert show];
        });
        return NO;
    }
    return YES;
}



- (BOOL)isBLEConnectedWithoutAlert
{
    return _isWatchConnected;

}

#pragma mark - Command

- (void)sendSearchWatchCommand
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    [self sendStrDataToBle:@"{ 'command': 0, 'content': '{}' }"];
}

-(void) findMobilePhone:(NSDictionary *)responseDic
{
    
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"mp3"];
    //在这里判断以下是否能找到这个音乐文件
    if (path) {
        //从path路径中 加载播放器
        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:path]error:nil];
        //初始化播放器
        [self.player prepareToPlay];
        
        //设置播放循环次数，如果numberOfLoops为负数 音频文件就会一直循环播放下去
        self.player.numberOfLoops = -1;
        
        //设置音频音量 volume的取值范围在 0.0为最小 0.1为最大 可以根据自己的情况而设置
        self.player.volume = 0.5f;
    }
    if (![self.player isPlaying])
    {
        [self.player play];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"手机去哪了"
                                                   delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)sendBoundCommand
{
    NSLog(@"pair the watch");
    if ([self isSendingData]) {
        return;
    }
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"name":_mobileBLEName,
                          @"command":[NSNumber numberWithInt:9876543]};
    [self sendStrDataToBle:[writer stringWithObject:dic]];
    
    
}

-(void)isSendBoundleCommand
{
    //如果绑定，也就是收到bound watch response，则停定时器
    if(_isWatchConnected)
    {
        NSLog(@"timer stop");
        [_timer invalidate];
        
        return;
    }
    else
    {
        [self sendBoundCommand];
        NSLog(@"no bound response, bound again");
    }
}

- (void)boundWatchResponse:(NSDictionary *)responseDic
{
    _isWatchConnected = YES;
    [self saveConnectedWatch:responseDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
    [self stopAdvertising];
    
    //停止重绑定时器
    //[_timer invalidate];
       [ViewUtils showToast:@"已经与手表建立连接"];
    
    //蓝牙绑定成功后开始定时器来获取当前的经纬度
    [_locationManager startUpdatingLocation];
    if(_locationManager)
    {
        _locationTimer=[NSTimer scheduledTimerWithTimeInterval:1200
                                                        target:self
                                                      selector:@selector(updateLocation)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void)sendUnboundCommand
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    __block BLEServerManager *weakSelf = self;
    self.writeblock = ^(void){
        NSLog(@"send finish");
        
        [weakSelf removeConnectedWatch];
        weakSelf.isWatchConnected = NO;
//        [weakSelf.centralManager cancelPeripheralConnection:weakSelf.connectedPeripheral];
        weakSelf.writeblock = nil;
        weakSelf = nil;
    };
    [self sendStrDataToBle:@"{ 'command': 16, 'content': '{}' }"];
    
    //停止定位经纬度，停止定时器
    [_locationTimer invalidate];
 
}

- (void)sendTimeCommand:(NSDate *)date finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:11],
                          @"content":@{@"time": [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000]}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

-(void) sendLocationCommand:(float)latitude longitude:(float)longitude
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"lat":[NSNumber numberWithFloat:latitude],
                          @"lng":[NSNumber numberWithFloat:longitude],
                          @"command":[NSNumber numberWithInt:15]};
    NSLog(@"%f %f",latitude,longitude);
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

- (void) sendWatchVersion:(NSString *)fileName
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    NSString *path = [NSString stringWithFormat:@"/data/update.zip"];
    
    __block BLEServerManager *weakSelf = self;
    
    self.writeblock = ^(void){
        NSLog(@"file write finish");
        
//        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
//        NSDictionary *dic = @{@"command":[NSNumber numberWithInt:3], @"content":@{@"app": path}};
//        [weakSelf sendStrDataToBle:[writer stringWithObject:dic]];
        
        weakSelf.writeblock = ^(void){
                        [ViewUtils showToast:[NSString stringWithFormat:@"升级成功"]];
        };
        weakSelf = nil;
    };
    
    self.toFilePath = path;
    
    [self sendWatchFileDataToBle:[[AFDownloadRequestOperation cacheFolder] stringByAppendingPathComponent:fileName]];
}

- (void)sendAppInstallCommand:(DownloadObject *)obj
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    __block NSString *fileName = [[NSURL URLWithString:obj.apkUrl] lastPathComponent];
    NSString *path = [NSString stringWithFormat:@"/sdcard/.tomoon/tmp/%@", fileName];
    
    __block BLEServerManager *weakSelf = self;
    
    self.writeblock = ^(void){
        NSLog(@"file write finish");
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSDictionary *dic = @{@"command":[NSNumber numberWithInt:3], @"content":@{@"app": path}};
        [weakSelf sendStrDataToBle:[writer stringWithObject:dic]];
        
        weakSelf.writeblock = ^(void){
            obj.state = [NSNumber numberWithInteger:kInstalled];
            [[DataManager sharedManager] saveDownloadDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFinishedNotification object:nil userInfo:@{@"obj": obj}];
            [ViewUtils showToast:[NSString stringWithFormat:@"应用“%@”安装成功", obj.name]];
        };
        weakSelf = nil;
    };
    
    self.toFilePath = path;
    
    [self sendFileDataToBle:[[AFDownloadRequestOperation cacheFolder] stringByAppendingPathComponent:fileName]];
}

- (void)sendBackgroundImageCommand:(DownloadObject *)obj
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    __block NSString *folderName = [[[NSURL URLWithString:obj.apkUrl] lastPathComponent] stringByReplacingOccurrencesOfString:@".zip" withString:@""];
    NSString *path = [NSString stringWithFormat:@"/sdcard/.tomoon/cards/%@.jpg", folderName];
    
    __block BLEServerManager *weakSelf = self;
    
    self.writeblock = ^(void){
        NSLog(@"file write finish");
        weakSelf.writeblock = nil;
        weakSelf.isSending = NO;
        weakSelf = nil;
        
        obj.state = [NSNumber numberWithInteger:kInstalled];
        [[DataManager sharedManager] saveDownloadDic];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFinishedNotification object:nil userInfo:@{@"obj": obj}];
        [ViewUtils showToast:[NSString stringWithFormat:@"图片“%@”已发送至手表", obj.name]];
    };
    
    self.toFilePath = path;
    
    NSString *folderPath = [[AFDownloadRequestOperation cacheFolder] stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
    if (array.count > 0) {
        [self sendFileDataToBle:[folderPath stringByAppendingPathComponent:[array lastObject]]];
    }
}

- (void)sendBackgroundImageDataCommand:(NSString *)path
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmsszzz"];
    
    __block NSString *fileName = [dateFormatter stringFromDate:[NSDate date]];
    NSString *toPath = [NSString stringWithFormat:@"/sdcard/.tomoon/cards/%@.jpg", fileName];
    
    __block BLEServerManager *weakSelf = self;
    
    self.writeblock = ^(void){
        NSLog(@"file write finish");
        weakSelf.writeblock = nil;
        weakSelf.isSending = NO;
        weakSelf = nil;
        [ViewUtils showToast:@"图片已发送至手表"];
    };
    
    self.toFilePath = toPath;
    
    [self sendFileDataToBle:path];
}

//获取天气信息
-(void)getWheatherInfo:(NSDictionary *)responseDic
{
    NSString *content = [responseDic objectForKey:@"content" ];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\\"];
    
    NSString *tempString = [content stringByTrimmingCharactersInSet:set];

    NSError *error = nil;
    NSDictionary *weatherDic = [NSJSONSerialization  JSONObjectWithData:[tempString dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableLeaves  error:&error];
    
    [[NSUserDefaults standardUserDefaults] setObject:[responseDic objectForKey:@"class"]
                                              forKey:@"class"];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[responseDic objectForKey:@"pkg"]
                                              forKey:@"pkg"];
   
    
    [[NSUserDefaults standardUserDefaults] setObject:[responseDic objectForKey:@"transId"]
                                              forKey:@"transId"];
    [[DataManager sharedManager] getWheather:[weatherDic objectForKey:@"url"] success: ^(NSString *response){_weatherInfo = response;}];
}


//从服务器后的天气信息后的通知处理，将该信息发送到手表
-(void)haveGetweatherInfo:(NSNotification *)notification
{
    
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;

    NSDictionary *dic = @{@"httpResult":[NSNumber numberWithInt:200],
                          @"httpRetString":_weatherInfo};
    
    NSDictionary *responseDic = @{@"class"   :[[NSUserDefaults standardUserDefaults] objectForKey:@"class"],
                                  @"type"    :[NSNumber numberWithInt:6],
                                  @"retCode" :[NSNumber numberWithInt:0],
                                  @"pkg"     :[[NSUserDefaults standardUserDefaults] objectForKey:@"pkg"],
                                  @"transId" :[[NSUserDefaults standardUserDefaults] objectForKey:@"transId"],
                                  @"content" : dic,
                                  };
    NSLog(@" the weather is %@", responseDic);
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    [self sendStrDataToBle:[writer stringWithObject:responseDic]];
    
    
}






#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    self.notifyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC_UUID]
                                                                   properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify
                                                                        value:nil
                                                                  permissions:CBAttributePermissionsWriteable ];
    
    // Then the service
    self.transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    self.transferService.characteristics = @[self.transferCharacteristic,self.notifyCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:self.transferService];
}

-(void) peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    
    if (error != nil)
    {
        NSLog(@" add service fail ");
        _retryCount ++;
        if(_retryCount < 3)
        {
            if (self.transferService != nil && self.transferCharacteristic != nil && self.notifyCharacteristic != nil)
            [self.peripheralManager addService:self.transferService];
        }
        else
        {
            _retryCount = 0;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"蓝牙模块故障，请重启手机"
                                                           delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        NSLog(@"add service success");
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if(error==nil){
        NSLog(@">>>发送advertising成功");
    }
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if(central == nil)
    {
        NSLog(@"the central is nill, unexpected result");
    }
    else
    {
        NSLog(@"OK");
    }
    
    NSLog(@"Central subscribed to characteristic: %@",characteristic.UUID);
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]])
    {
        //起定时器等待相应
        _timer=[NSTimer scheduledTimerWithTimeInterval:5
                                                target:self
                                              selector:@selector(isSendBoundleCommand)
                                              userInfo:nil
                                               repeats:YES];

        [self sendBoundCommand];

    }
    
//    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC_UUID]])
//    {
//        [self sendBoundCommand];
//    }
    
    
    
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{


    NSLog(@"Central unsubscribed from characteristic");
    NSLog(@"the UUID is %@",characteristic.UUID);
    _isWatchConnected = NO;
    self.isSending = NO;

    [self removeConnectedWatch];
    
    //断开连接后，停止获取当前经纬度，停止定时器
    [_locationTimer invalidate];

    
    //重新开始广播
    if ( !self.peripheralManager.isAdvertising )
    {
        [self startAdvertising];
    }
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request
{
    
    if ([request.characteristic.UUID isEqual:self.notifyCharacteristic.UUID])
    {
        if (request.offset > self.notifyCharacteristic.value.length) {
            [self.peripheralManager respondToRequest:request
                                       withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = [self.notifyCharacteristic.value
                         subdataWithRange:NSMakeRange(request.offset,
                                                      self.notifyCharacteristic.value.length - request.offset)];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveWriteRequests:(NSArray *)requests
{

    NSLog(@"receive message from watch");
  
    NSMutableData *receivedata = [[NSMutableData alloc] init];
    for (NSInteger i = 0; i<[requests count]; i++)
    {
        CBATTRequest *request = nil;
        request = [requests objectAtIndex:i];
        if([request.characteristic.UUID isEqual:self.notifyCharacteristic.UUID])
        {
            [receivedata appendData: request.value];
//            NSLog(@"receive data is %@", receivedata);
//            NSLog(@"receive value is %@", request.value);
        }
    }
    //int buf[[receivedata length]];
    void *buf = (void*)[receivedata bytes];
    int len = [receivedata length];
    NSString *strForIsOk = [[NSString alloc] initWithBytes:buf length:1 encoding:NSUTF8StringEncoding];
    if([strForIsOk intValue] == 0)
    {
        [receivedata getBytes:buf range:NSMakeRange(2, len - 2)];
        NSString * response = [[NSString alloc] initWithBytes:buf length:len - 2 encoding:NSUTF8StringEncoding];
//        NSLog(@"the response is %@",response);
        NSError *error = nil;
       NSDictionary *responseDic = [NSJSONSerialization  JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableLeaves  error:&error];
//        NSLog(@"the dictionary is %@",responseDic);
//        NSDictionary *responseDic = [response JSONValue];
        NSString *receiveCMD = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"command" ]] ;
//        NSLog(@"the command is is is %@", receiveCMD);
        NSString *receiveType = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"type" ]];
        if ( ![receiveCMD isEqualToString:@"(null)" ]    )
        {
            NSLog(@"the command is %@",receiveCMD);

            if([receiveCMD isEqualToString:@"9876543"])
            {
                [self boundWatchResponse:responseDic];
            }
            else if([receiveCMD isEqualToString:@"0"])
            {
                [self findMobilePhone:responseDic];
            }
            
            else
            {
                NSLog(@"unrespected commond from watch");
            }
        }
        
        if ( ![receiveType isEqualToString:@"(null)" ]  )
        {
            NSLog(@"the type is %@",receiveType);

            if ([ receiveType isEqualToString:@"5"])
            {
                [self getWheatherInfo:responseDic];
            }
            else
            {
                NSLog(@"unrespected type from watch");
            }
        }
    }

}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    if(self.transferDataType == kTransferDataType_String)
    {
        [self sendData];
    }
    else if(self.transferDataType == kTransferDataType_File && self.isSendFileName == NO)
    {
        [self sendFileData];
    }
    else if(self.transferDataType == kTransferDataType_File && self.isSendFileName == YES)
    {
        [self sendfileName];
    }
    else if(self.transferDataType == kTransferDataType_version && self.isSendFileName == NO)
    {
        [self sendWatchFileData];
    }
    else if(self.transferDataType == kTransferDataType_version && self.isSendFileName == YES)
    {
        [self sendfileName];
    }
}


#pragma Mark send data through peripheral

- (void)sendFileDataToBle:(NSString *)path
{
    // Start the long-running task and return immediately.
    dispatch_async(ble_communication_queue(), ^(void){
        //        self.connectedPeripheral.delegate = self;
        
        NSFileManager *manager = [[NSFileManager alloc] init];
        if ([manager fileExistsAtPath:path isDirectory:NO]) {
            NSError *error = nil;
            unsigned long long size = [[manager attributesOfItemAtPath:path error:&error] fileSize];
            if (error) {
                NSLog(@"Error: %@",  [error localizedDescription]);
                self.isSending = NO;
                return;
            }
            self.sendDataSize = size;
        }
        
        self.transferDataType = kTransferDataType_File;
        
        // Reset the index
        self.sendDataIndex = -1;
        
        // Send it
        if(_isWatchConnected)
        {
            self.inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
            [self.inputStream open];
            [self sendFileData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (!_isWatchConnected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"已经与手表断开，请重连"
                                                               delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}


- (void)sendWatchFileDataToBle:(NSString *)path
{
    // Start the long-running task and return immediately.
    dispatch_async(ble_communication_queue(), ^(void){
        //        self.connectedPeripheral.delegate = self;
        
        NSFileManager *manager = [[NSFileManager alloc] init];
        if ([manager fileExistsAtPath:path isDirectory:NO]) {
            NSError *error = nil;
            unsigned long long size = [[manager attributesOfItemAtPath:path error:&error] fileSize];
            if (error) {
                NSLog(@"Error: %@",  [error localizedDescription]);
                self.isSending = NO;
                return;
            }
            self.sendDataSize = size;
        }
        
        self.transferDataType = kTransferDataType_version;
        
        // Reset the index
        self.sendDataIndex = -1;
        
        // Send it
        if(_isWatchConnected)
        {
            self.inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
            [self.inputStream open];
            [self sendWatchFileData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (!_isWatchConnected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"已经与手表断开，请重连"
                                                               delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}



- (void)sendStrDataToBle:(NSString *)str
{
    dispatch_async(ble_communication_queue(), ^(void){
        //        self.BLEServerManager.delegate = self;
        
        self.transferDataType = kTransferDataType_String;
        
        // Reset the index
        self.sendDataIndex = 0;
        
        self.dataToSend = [str dataUsingEncoding:NSUTF8StringEncoding];
        self.sendDataSize = self.dataToSend.length;
        
        // Send it
        [self sendData];
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (self.transferCharacteristic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"已经与手表断开，请重连"
                                                               delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

- (void)sendData
{
    if (self.sendDataIndex >= self.sendDataSize)  return;
    BOOL didSend = YES;
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        NSMutableData *tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
        [tempData appendData:chunk];
        
        
        // Send it
        didSend = [self.peripheralManager updateValue:tempData forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was
            didSend = NO;
            self.isSending = NO;
            self.dataToSend = nil;
            NSLog(@"send command success");
            
            
            if (self.writeblock) {
                self.writeblock();
            }
            
            return;
        }
    }
    
    
}
- (void)sendfileName
{
    NSLog(@"come to send fileName");
    
    if (self.fileNameIndex >= self.fileNameSize)  return;
    BOOL didSend = YES;
    while (didSend) {
                
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.fileNameSize - self.fileNameIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.fileNameIndex length:amountToSend];
        NSMutableData *tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
        [tempData appendData:chunk];
        
        
        // Send it
        didSend = [self.peripheralManager updateValue:tempData forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend)
        {
            NSLog(@"send file Name error %d",self.fileNameIndex);
            return;
        }
        
        
        
        // It did send, so update our index
        self.fileNameIndex += amountToSend;
        
        // Was it the last one?
        if (self.fileNameIndex >= self.fileNameSize) {
            
            NSLog(@"the last filename index %d",self.fileNameIndex);

            // It was
            didSend = NO;
            
            self.isSendFileName = NO;
            
            //开始传输应用程序包
            self.sendDataIndex = 0;
            
            self.isResendFile = NO;
          
            
            return;
        }

    }
    NSLog(@"send file Name successful %d",self.fileNameIndex);

    
    
}


- (void)sendFileData
{
    BOOL didSend = YES;
    
    if (self.sendDataIndex >= self.sendDataSize && self.isResendFile == NO)
    {
        self.isSending = NO;
        didSend = NO;
        return;
    }
    self.fileNameIndex = 0;
    
    
    
    NSMutableData *tempData = nil;//为了防止发送失败，保存上次发送的包
    while (didSend) {
        
       
        // Make the next chunk
        
        // Work out how big it should be
        
        if (self.sendDataIndex == -1 && self.fileNameIndex == 0) {
            
            NSString *commnad = [NSString stringWithFormat:@"{'to':'%@'}", self.toFilePath];
            NSLog(@"commnad:%@", commnad);
            self.dataToSend = [commnad dataUsingEncoding:NSUTF8StringEncoding];
            
            self.fileNameSize = self.dataToSend.length;
            
            self.isSendFileName = YES ;
            [self sendfileName];
            
            
        }
        else if(self.sendDataIndex >= 0)
        {
            
            
            //如果是重发，则不需要读文件，直接从上次发送失败保存的self.storeData中获取数据重新发送
            if (self.isResendFile == NO )
            {
                // Work out how big it should be
                NSInteger amountToSend = self.sendDataSize - self.sendDataIndex;
                
                // Can't be longer than 20 bytes
                if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;

                Byte data[NOTIFY_MTU] = {0x00};
                int length = [self.inputStream read:data maxLength:amountToSend];
                
                // Copy out the data we want
                self.dataToSend = [NSData dataWithBytes:data length:length];
                
                tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
                [tempData appendData:self.dataToSend];
                
                self.sendDataIndex += length;
            }
            else
            {
                tempData = self.storeData;
            }
            
            
            NSLog(@"temp index: %i", self.sendDataIndex);
            
            // Send it
            didSend = [self.peripheralManager updateValue:tempData forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                
                //设置重发标记，记录要重发的包
                self.isResendFile = YES;
                self.storeData = [[NSMutableData alloc] initWithData:tempData];
                
                return;
            }
            NSDictionary *dic = @{@"readFileBytes": [NSNumber numberWithLongLong:self.sendDataIndex],
                                  @"totalFileBytes": [NSNumber numberWithLongLong:self.sendDataSize],
                                  };
            [[NSNotificationCenter defaultCenter] postNotificationName:kInstallAppNotification object:nil userInfo:dic];
            
            
            // Was it the last one?
            if (self.sendDataIndex >= self.sendDataSize) {
                
                // It was
                didSend = NO;
                self.isSending = NO;
                self.storeData = nil;
                
                if (self.writeblock) {
                    self.writeblock();
                }
                self.dataToSend = nil;
                [self.inputStream close];
                self.inputStream = nil;
                self.isResendFile = NO;
                
                NSLog(@"send file to watch success, the latest index %d", self.sendDataIndex);
                return;
            }
            self.isResendFile = NO;
     
           
        }
        
    }
    
}

- (void)sendWatchFileData
{
    BOOL didSend = YES;
    
    if (self.sendDataIndex >= self.sendDataSize && self.isResendFile == NO)
    {
        self.isSending = NO;
        didSend = NO;
        return;
    }
    self.fileNameIndex = 0;
    
    
    
    NSMutableData *tempData = nil;//为了防止发送失败，保存上次发送的包
    while (didSend) {
        
        
        // Make the next chunk
        
        // Work out how big it should be
        
        if (self.sendDataIndex == -1 && self.fileNameIndex == 0) {
            
            NSString *commnad = [NSString stringWithFormat:@"{'to':'%@'}", self.toFilePath];
            NSLog(@"commnad:%@", commnad);
            self.dataToSend = [commnad dataUsingEncoding:NSUTF8StringEncoding];
            
            self.fileNameSize = self.dataToSend.length;
            
            self.isSendFileName = YES ;
            [self sendfileName];
            
            
        }
        else if(self.sendDataIndex >= 0)
        {
            NSLog(@"send watch version %d", self.sendDataIndex);
            
            //如果是重发，则不需要读文件，直接从上次发送失败保存的self.storeData中获取数据重新发送
            if (self.isResendFile == NO )
            {
                // Work out how big it should be
                NSInteger amountToSend = self.sendDataSize - self.sendDataIndex;
                
                // Can't be longer than 20 bytes
                if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
                
                Byte data[NOTIFY_MTU] = {0x00};
                int length = [self.inputStream read:data maxLength:amountToSend];
                
                // Copy out the data we want
                self.dataToSend = [NSData dataWithBytes:data length:length];
                
                tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
                [tempData appendData:self.dataToSend];
                
                self.sendDataIndex += length;
            }
            else
            {
                NSLog(@"watch version retry %d",self.sendDataIndex);
                tempData = self.storeData;
            }
            
            
            NSLog(@"temp index: %i", self.sendDataIndex);
            
            // Send it
            didSend = [self.peripheralManager updateValue:tempData forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                
                
                self.isResendFile = YES;
                self.storeData = [[NSMutableData alloc] initWithData:tempData];
                
                return;
            }
            NSDictionary *dic = @{@"readFileBytes": [NSNumber numberWithLongLong:self.sendDataIndex],
                                  @"totalFileBytes": [NSNumber numberWithLongLong:self.sendDataSize],
                                  };
            [[NSNotificationCenter defaultCenter] postNotificationName:kWatchVersionInstallAppNotification object:nil userInfo:dic];
            
            
            // Was it the last one?
            if (self.sendDataIndex >= self.sendDataSize) {
                
                // It was
                didSend = NO;
                self.isSending = NO;
                self.storeData = nil;
                
                if (self.writeblock) {
                    self.writeblock();
                }
                self.dataToSend = nil;
                [self.inputStream close];
                self.inputStream = nil;
                self.isResendFile = NO;
                
                NSLog(@"send file to watch success, the latest index %d", self.sendDataIndex);
                return;
            }
            self.isResendFile = NO;
            NSLog(@"send watch version success %d",self.sendDataIndex);
            
            
        }
        
    }
    
}




- (NSData *)getFirstByte
{
    Byte byte = 0x00;
    
    if (self.transferDataType == kTransferDataType_String) {
        if (self.sendDataIndex == 0 && self.dataToSend.length <= NOTIFY_MTU) {//entire
            byte = 0x00;
        }else if (self.sendDataIndex == 0 && self.dataToSend.length > NOTIFY_MTU){//start
            byte = 0x01;
        }else if (self.sendDataIndex + NOTIFY_MTU >= self.dataToSend.length){//end
            byte = 0x03;
        }else {//continue
            byte = 0x02;
        }
    }
    else if (self.transferDataType == kTransferDataType_File && self.isSendFileName == NO) {
        if (self.sendDataIndex == -1 && self.sendDataSize > NOTIFY_MTU){//start
            byte = 0x21;
        }else if (self.sendDataIndex + NOTIFY_MTU >= self.sendDataSize){//end
            byte = 0x23;
        }else {//continue
            byte = 0x22;
        }
    }
    else if(self.transferDataType == kTransferDataType_File && self.isSendFileName == YES)
    {
        if (self.fileNameIndex == 0 && self.fileNameSize > NOTIFY_MTU){//start
            byte = 0x21;
        
        }
        else {//continue
            byte = 0x22;
        }
    }
    else if (self.transferDataType == kTransferDataType_version && self.isSendFileName == NO) {
        if (self.sendDataIndex == -1 && self.sendDataSize > NOTIFY_MTU){//start
            byte = 0x21;
        }else if (self.sendDataIndex + NOTIFY_MTU >= self.sendDataSize){//end
            byte = 0x23;
        }else {//continue
            byte = 0x22;
        }
    }
    else if(self.transferDataType == kTransferDataType_version && self.isSendFileName == YES)
    {
        if (self.fileNameIndex == 0 && self.fileNameSize > NOTIFY_MTU){//start
            byte = 0x21;
            
        }
        else {//continue
            byte = 0x22;
        }
    }

    
    Byte bytes[2] = {byte, 0x00};
    
    NSData *header = [NSData dataWithBytes:bytes length:2];
    
    return header;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLEConnectionNotification object:nil];
    }
    if ([buttonTitle isEqualToString:@"取消"]) {
        if(self.player)
        {
            if ([self.player isPlaying]) {
                [self.player stop];
                NSLog(@"播放停止");
            }
        }
    }
}

- (void)sendWatchSleepTime:(NSString *)sleepTime finish:(void(^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:20],
                          @"content":@{@"value": sleepTime}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//手表时间
- (void)sendWatchTime:(NSDate *) date finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
//    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
////    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:21],
////                          @"content":@{@"value":@{@"autotime":,@"time":,
////                              @"tomezone" :,
////                              @"24hour" : ,
////                              @"dateformat" :
////                          }}};
//    if (block) {
//        __block BLEServerManager *weakSelf = self;
//        self.writeblock = ^(void){
//            block();
//            weakSelf.writeblock = nil;
//            weakSelf = nil;
//        };
//    }
//    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//手表自动开机
- (void)sendPowerOnWatch:(NSString *) hour minute:(NSString *) minute enabled:(NSString*)enabled finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:22],
                          @"content":@{@"value":@{
                              @"enabled":enabled,
                              @"hour":hour,
                              @"minute" :minute
                          }}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//手表自动关机
- (void)sendPowerOffWatch:(NSString *) hour minute:(NSString *) minute enabled:(NSString*)enabled finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:23],
                          @"content":@{@"value":@{
                              @"enabled":enabled,
                              @"hour":hour,
                              @"minute" :minute
                          }}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//手表语言
- (void)sendWatchLanguage:(NSString *) language finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:24],
                          @"content":@{@"value": language}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//手表是否休眠
- (void)sendWatchSleepSet:(NSString*) set finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:26],
                          @"content":@{@"value": set}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//启动app
- (void)sendLaunchApp:(NSString *) launchapp finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:25],
                          @"content":@{@"pkgname": launchapp}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//是否震动
- (void)sendVibrateSetting:(NSString*) vibrate finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:27],
                          @"content":@{@"value":@{@"enabled":vibrate}}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//是否反色
- (void)sendInverseColor:(NSString*) inverse finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:28],@"content":@{@"value":@{@"enabled":inverse}}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

//是否音频即时通信
- (void)sendAudioRealTimeCommunication :(NSString*) communcation finish:(void (^)(void))block
{
    if (![self isBLEConnected]) {
        return;
    }
    if ([self isSendingData]) {
        return;
    }
    self.isSending = YES;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:29],
                          @"content":@{@"value":@{@"enabled":communcation}}};
    if (block) {
        __block BLEServerManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
}

@end