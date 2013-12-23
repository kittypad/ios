//
//  BLEManager.m
//  Twatch
//
//  Created by 龚 涛 on 13-12-21.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "BLEManager.h"

#define NOTIFY_MTU      498

//串行队列，同时只执行一个task
static dispatch_queue_t ble_communication_queue() {
    static dispatch_queue_t af_ble_communication_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_ble_communication_queue = dispatch_queue_create("com.tfire.ble", DISPATCH_QUEUE_SERIAL);
    });
    return af_ble_communication_queue;
}

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
    }
    return self;
}

#pragma mark - Public

- (void)sendStrDataToBle:(NSString *)str
{
    dispatch_async(ble_communication_queue(), ^(void){
        self.connectedPeripheral.delegate = self;
        
        BOOL connectedADevice = NO;
#ifdef __IPHONE_7_0
        connectedADevice = self.connectedPeripheral.state == CBPeripheralStateConnected;
#else
        connectedADevice = self.connectedPeripheral.isConnected;
#endif
        if (!connectedADevice || self.connectedPeripheral == nil) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"尚未连接到蓝牙设备，请进入同步界面扫描设备"
                                                               delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            });
            return;
        }
        
        self.transferDataType = kTransferDataType_String;
        
        // Reset the index
        self.sendDataIndex = 0;
        
        self.dataToSend = [str dataUsingEncoding:NSUTF8StringEncoding];
        
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
    NSLog(@"scan...");
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopScan
{
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

#pragma mark - Command

- (void)sendSearchWatchCommand
{
    [self sendStrDataToBle:@"{ 'command': 0, 'content': '{}' }"];
}

- (void)sendUnboundCommand
{
    [self sendStrDataToBle:@"{ 'command': 16, 'content': '{}' }"];
}

- (void)sendAppInstallCommand:(NSString *)apkUrl
{
    [self sendStrDataToBle:[NSString stringWithFormat:@"{ 'command': 3, 'content': '{'App': '%@'}' }", apkUrl]];
}

#pragma mark - Data

/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    
    if (self.sendDataIndex >= self.dataToSend.length)  return;
    
    // Work out how big it should be
    NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
    
    // Can't be longer than 20 bytes
    if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
    
    // Copy out the data we want
    NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
    
    NSMutableData *tempData = [[NSMutableData alloc] initWithData:[self getFirstByte]];
    [tempData appendData:chunk];
    
    // Send it
    [self.connectedPeripheral writeValue:tempData
                       forCharacteristic:self.curCharacteristic type:CBCharacteristicWriteWithResponse];
    
}


- (NSData *)getFirstByte
{
    Byte byte = {0x00};
    
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
    }else if (self.transferDataType == kTransferDataType_File){
        if (self.sendDataIndex == 0 && self.dataToSend.length <= NOTIFY_MTU) {//entire
            byte = 0x20;
        }else if (self.sendDataIndex == 0 && self.dataToSend.length > NOTIFY_MTU){//start
            byte = 0x21;
        }else if (self.sendDataIndex + NOTIFY_MTU >= self.dataToSend.length){//end
            byte = 0x23;
        }else {//continue
            byte = 0x22;
        }
    }
    
    Byte bytes[2] = {byte, 0x00};
    
    NSData *header = [NSData dataWithBytes:bytes length:2];
    NSLog(@"after1: %@",header);
    
    //    NSString *string = [[NSString alloc] initWithData:header encoding:NSUTF8StringEncoding];
    //    NSLog(@"after2: %@",string);
    
    return header;
}

#pragma mark - CBCentralManagerDelegate, CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didWriteValueForCharacteristic: %@",  [error localizedDescription]);
        return;
    }
    
    // Work out how big it should be
    NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
    
    // Can't be longer than 20 bytes
    if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
    
    // It did send, so update our index
    self.sendDataIndex += amountToSend;
    
    [self sendData];
}


//MARK: Scan watch
-(void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"non PoweredOn state");
        return;
    }
    [self scan];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"centrel didFailToConnectPeripheral error:%@", error);
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
    NSLog(@"didConnectPeripheral %@", peripheral.name);
    self.connectedPeripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self.unConnectedDevices removeObject:peripheral];
    [self saveConnectedWatch:peripheral.identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
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
    
    if (self.connectedPeripheral == peripheral) {
        self.connectedPeripheral = nil;
        [self removeConnectedWatch];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
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
            [peripheral readValueForCharacteristic:characteristic];
            peripheral.delegate = self;
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

@end
