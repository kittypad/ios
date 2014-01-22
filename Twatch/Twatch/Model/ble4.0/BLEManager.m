//
//  BLEManager.m
//  Twatch
//
//  Created by 龚 涛 on 13-12-21.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "BLEManager.h"

#import "AFDownloadRequestOperation.h"

#import <SBJson.h>

#import "DataManager.h"

#import "ViewUtils.h"

#define NOTIFY_MTU      116

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

@interface BLEManager ()

@property (nonatomic, assign) NSUInteger remainCount;

- (void)sendFileDataToBle:(NSString *)path;

- (void)sendStrDataToBle:(NSString *)str;

- (void)sendData;

- (void)sendFileData;

- (NSData *)getFirstByte;

- (BOOL)isSendingData;

@end

@implementation BLEManager

+ (BLEManager *)sharedManager
{
    static BLEManager *sharedManagerInstance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[BLEManager alloc] init];
    });
    
    return sharedManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _unConnectedDevices = [[NSMutableArray alloc] init];
        
        // Start up the CBCentralManager
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        _isSending = NO;
        _isScanning = NO;
        
        _remainCount = 3;
        
        [self _initUUID];
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

#pragma mark - Public

- (void)sendFileDataToBle:(NSString *)path
{
    // Start the long-running task and return immediately.
    dispatch_async(ble_communication_queue(), ^(void){
        self.connectedPeripheral.delegate = self;

        NSFileManager *manager = [[NSFileManager alloc] init];
        if ([manager fileExistsAtPath:path isDirectory:NO]) {
            NSError *error = nil;
            unsigned long long size = [[manager attributesOfItemAtPath:path error:&error] fileSize];
            if (error) {
                NSLog(@"Error: %@",  [error localizedDescription]);
                return;
            }
            self.sendDataSize = size;
        }
        
        self.transferDataType = kTransferDataType_File;
        
        // Reset the index
        self.sendDataIndex = -1;

        // Send it
        self.curCharacteristic = nil;
        for (CBService *aService in self.connectedPeripheral.services) {
            for (CBCharacteristic *ca in aService.characteristics) {
                if ([ca.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                    self.curCharacteristic = ca;
                    self.inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
                    [self.inputStream open];
                    [self sendFileData];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (self.curCharacteristic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"已连接的蓝牙设备尚未提供此服务"
                                                               delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

- (void)sendStrDataToBle:(NSString *)str
{
    dispatch_async(ble_communication_queue(), ^(void){
        self.connectedPeripheral.delegate = self;
        
        self.transferDataType = kTransferDataType_String;
        
        // Reset the index
        self.sendDataIndex = 0;
        
        self.dataToSend = [str dataUsingEncoding:NSUTF8StringEncoding];
        self.sendDataSize = self.dataToSend.length;
        
        // Send it
        self.curCharacteristic = nil;
        for (CBService *aService in self.connectedPeripheral.services) {
            for (CBCharacteristic *ca in aService.characteristics) {
                if ([ca.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                    self.curCharacteristic = ca;
                    [self sendData];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (self.curCharacteristic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"已连接的蓝牙设备尚未提供此服务"
                                                               delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

- (void)scan
{
    self.isScanning = YES;
    NSLog(@"scan...");
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopScan
{
    self.isScanning = NO;
    [self.centralManager stopScan];
}

- (void)saveConnectedWatch:(NSUUID *)identifier
{
    [[NSUserDefaults standardUserDefaults] setObject:identifier.UUIDString
                                              forKey:kBLEBindingWatch];
}

- (void)removeConnectedWatch
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBLEBindingWatch];
}

- (BOOL)isBLEPoweredOn
{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
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

- (BOOL)isBLEConnected
{
    if (![self isBLEConnectedWithoutAlert]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"尚未连接到蓝牙设备，是否进入同步界面扫描设备？"
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
    
    BOOL connectedADevice = NO;
#ifdef __IPHONE_7_0
    connectedADevice = self.connectedPeripheral.state == CBPeripheralStateConnected;
#else
    connectedADevice = self.connectedPeripheral.isConnected;
#endif
    if (!connectedADevice || self.connectedPeripheral == nil) {
        return NO;
    }
    return YES;
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

- (void)sendBoundCommand
{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"name":_mobileBLEName,
                          @"command":[NSNumber numberWithInt:9876543]};
    [self sendStrDataToBle:[writer stringWithObject:dic]];
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
    __block BLEManager *weakSelf = self;
    self.writeblock = ^(void){
        NSLog(@"send finish");
        [weakSelf removeConnectedWatch];
        [weakSelf.centralManager cancelPeripheralConnection:weakSelf.connectedPeripheral];
        weakSelf.writeblock = nil;
        weakSelf = nil;
    };
    [self sendStrDataToBle:@"{ 'command': 16, 'content': '{}' }"];
}

- (void)sendTimeCommand:(NSDate *)date finish:(void (^)(void))block
{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"command":[NSNumber numberWithInt:11],
                          @"content":@{@"time": [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000]}};
    if (block) {
        __block BLEManager *weakSelf = self;
        self.writeblock = ^(void){
            block();
            weakSelf.writeblock = nil;
            weakSelf = nil;
        };
    }
    [self sendStrDataToBle:[writer stringWithObject:dic]];
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
    
    __block BLEManager *weakSelf = self;
    
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
    
    __block BLEManager *weakSelf = self;
    
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
    
    __block BLEManager *weakSelf = self;
    
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

#pragma mark - Data

/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    if (self.sendDataIndex >= self.sendDataSize)  return;
    
    // Work out how big it should be
    NSInteger amountToSend = self.sendDataSize - self.sendDataIndex;
    
    // Can't be longer than 20 bytes
    if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
    
    // Copy out the data we want
    NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
    
    NSMutableData *tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
    [tempData appendData:chunk];
    
    NSLog(@"temp length: %i", tempData.length);
    
    // Send it
    [self.connectedPeripheral writeValue:tempData
                       forCharacteristic:self.curCharacteristic type:CBCharacteristicWriteWithResponse];
    
}

- (void)sendFileData
{
    if (self.sendDataIndex >= self.sendDataSize)  return;
    
    NSMutableData *tempData = nil;
    if (self.sendDataIndex == -1) {
        NSString *commnad = [NSString stringWithFormat:@"{'to':'%@'}", self.toFilePath];
        NSLog(@"commnad:%@", commnad);
        self.dataToSend = [commnad dataUsingEncoding:NSUTF8StringEncoding];
        
        tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
        [tempData appendData:self.dataToSend];
        self.sendDataIndex = 0;
    }
    else {
        // Work out how big it should be
        NSInteger amountToSend = self.sendDataSize - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        Byte data[NOTIFY_MTU] = {0x00};
        int length = [self.inputStream read:data maxLength:amountToSend];
        
        NSLog(@"length : %i, %i", self.sendDataSize, length);
        // Copy out the data we want
        self.dataToSend = [NSData dataWithBytes:data length:length];
        
        tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
        [tempData appendData:self.dataToSend];
        
        self.sendDataIndex += length;
    }
    
    NSLog(@"temp index: %i", self.sendDataIndex);
    
    // Send it
    [self.connectedPeripheral writeValue:tempData
                       forCharacteristic:self.curCharacteristic type:CBCharacteristicWriteWithResponse];
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
    else if (self.transferDataType == kTransferDataType_File) {
        if (self.sendDataIndex == -1 && self.sendDataSize > NOTIFY_MTU){//start
            byte = 0x21;
        }else if (self.sendDataIndex + NOTIFY_MTU >= self.sendDataSize){//end
            byte = 0x23;
        }else {//continue
            byte = 0x22;
        }
    }
    
    Byte bytes[2] = {byte, 0x00};
    
    NSData *header = [NSData dataWithBytes:bytes length:2];
    
    return header;
}

- (BOOL)isSendingData
{
    if (self.isSending) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"蓝牙传输" message:@"正在发送其他数据，请稍后尝试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    return self.isSending;
}

#pragma mark - CBCentralManagerDelegate, CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didWriteValueForCharacteristic: %@",  [error localizedDescription]);
        [ViewUtils showErrorToast:[NSString stringWithFormat:@"蓝牙发送错误:%@", [error localizedDescription]]];
        if (self.inputStream) {
            [self.inputStream close];
            self.inputStream = nil;
        }
        self.isSending = NO;
        [self.centralManager cancelPeripheralConnection:peripheral];
        [self scan];
        self.dataToSend = nil;
        return;
    }
    
    if (self.transferDataType == kTransferDataType_String) {
        
        NSInteger amountToSend = self.sendDataSize - self.sendDataIndex;
        
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        self.sendDataIndex += amountToSend;
        
        if (self.sendDataIndex >= self.sendDataSize) {
            self.isSending = NO;
            self.dataToSend = nil;
            if (self.writeblock) {
                self.writeblock();
            }
            return;
        }
        
        NSLog(@"send");
        [self sendData];
    }
    else {
        //发送文件
        
        if (self.sendDataIndex >= self.sendDataSize) {
            if (self.writeblock) {
                self.writeblock();
            }
            self.dataToSend = nil;
            [self.inputStream close];
            self.inputStream = nil;
            return;
        }
        
        [self sendFileData];
    }
}


//MARK: Scan watch
-(void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"non PoweredOn state");
        self.isScanning = NO;
        return;
    }
    [self scan];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"centrel didFailToConnectPeripheral error:%@", error);
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kBLEBindingWatch];
    if (identifier && [peripheral.identifier.UUIDString isEqualToString:identifier] && _remainCount>0) {
        [central connectPeripheral:peripheral options:nil];
        _remainCount--;
    }
}

-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"didRetrievePeripherals");
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"didDiscoverPeripheral NAME:%@ RSSI:%@ Id:%@", peripheral.name, RSSI, peripheral.identifier.UUIDString);
    for (int i = 0; i < self.unConnectedDevices.count; i++) {
        CBPeripheral *p = [self.unConnectedDevices objectAtIndex:i];
        if ([p.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            NSLog(@"equlas");
            return;
        }
    }
    
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kBLEBindingWatch];
    if (self.connectedPeripheral == nil && identifier &&
        [identifier isEqualToString:peripheral.identifier.UUIDString]) {
        NSLog(@"didConnectLastPeripheral %@", peripheral.name);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    else if (self.connectedPeripheral && [peripheral.identifier.UUIDString isEqualToString:self.connectedPeripheral.identifier.UUIDString]) {
        NSLog(@"equlas");
        return;
    }
    
    [self.unConnectedDevices addObject:peripheral];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.isSending = NO;
    NSLog(@"didConnectPeripheral %@", peripheral.name);
    self.connectedPeripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self.unConnectedDevices removeObject:peripheral];
    [self saveConnectedWatch:peripheral.identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
    [ViewUtils showToast:@"已经与手表建立连接"];
    _remainCount = 3;
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"central didRetrieveConnectedPeripherals");
}

- (void) centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSLog(@"central willRestoreState");
}

-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral %@", peripheral.name);
    
//    [ViewUtils showErrorToast:@"已经与手表断开连接"];
    
    self.isSending = NO;
    self.dataToSend = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
    
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kBLEBindingWatch];
    if (identifier && self.connectedPeripheral) {
        [central connectPeripheral:self.connectedPeripheral options:nil];
        return;
    }
    
    if (self.connectedPeripheral == peripheral) {
        self.connectedPeripheral = nil;
    }
    [self scan];
}

//- (void)cleanup
//{
//    // Don't do anything if we're not connected
//    if (!self.connectedPeripheral.isConnected) {
//        return;
//    }
//
//    // See if we are subscribed to a characteristic on the peripheral
//    if (self.connectedPeripheral.services != nil) {
//        for (CBService *service in self.connectedPeripheral.services) {
//            if (service.characteristics != nil) {
//                for (CBCharacteristic *characteristic in service.characteristics) {
//                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
//                        if (characteristic.isNotifying) {
//                            // It is notifying, so unsubscribe
//                            [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
//
//                            // And we're done.
//                            return;
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
//    [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
//}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"peripheral didDiscoverServices");
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        //        [self cleanup];
        return;
    }
    
    for (CBService *s in peripheral.services) {
        //NSLog(@"%@", s.UUID);
        //@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"peripheral didDiscoverCharacteristicsForService");
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        //NSLog(@"c: %@", characteristic.UUID);
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            NSLog(@"bingo..");
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            peripheral.delegate = self;
            [self sendBoundCommand];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didUpdateValueForCharacteristic: %@", [error localizedDescription]);
        return;
    }
    
    //    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSData *data = characteristic.value;
    //    const void *d = data.bytes;
    //    int i = d;
    int i = 0, j = 0;
    //[data getBytes:&i length:2];
    const char *a = data.bytes;
    memcpy(&i, a + 1, 1);
    //memcpy(&j, a + 1, 2);
    // Log it
    NSLog(@"peripheral Received: %lu, i:%d, j:%d", (unsigned long)data.length, i, j);
    //    self.cur_rate = i;
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
}

/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//{
//    if (error) {
//        NSLog(@"Error changing notification state: %@", error.localizedDescription);
//    }
//
//    // Exit if it's not the transfer characteristic
//    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
//        NSLog(@"unkonw UUID");
//        return;
//    }
//
//    // Notification has started
//    if (characteristic.isNotifying) {
//        NSLog(@"Notification began on %@", characteristic);
//    }
//
//    // Notification has stopped
//    else {
//        // so disconnect from the peripheral
//        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
//        [self.centralManager cancelPeripheralConnection:peripheral];
//    }
//}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLEConnectionNotification object:nil];
    }
}

@end
