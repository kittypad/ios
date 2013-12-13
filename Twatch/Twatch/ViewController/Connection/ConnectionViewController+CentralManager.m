//
//  ConnectionViewController+CentralManager.m
//  Twatch
//
//  Created by yixiaoluo on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ConnectionViewController+CentralManager.h"
#import "MBProgressHUD.h"
@implementation ConnectionViewController (CentralManager)

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
    NSLog(@"didDiscoverPeripheral NAME:%@ RSSI:%@", peripheral.name, RSSI);
    for (int i = 0; i < self.array.count; i++) {
        CBPeripheral *p = [self.array objectAtIndex:i];
        if ([p.name compare:peripheral.name] == NSOrderedSame) {
            NSLog(@"equlas");
            return;
        }
    }
    
    [self.array addObject:peripheral];
    [self.tableView reloadData];
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral %@", peripheral.name);
    self.connectedPeripheral = peripheral;
    peripheral.delegate = self;
    //@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
    [peripheral discoverServices:nil];
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
    
    //    [self scan];
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
        
        

        for (CBCharacteristic *ca in s.characteristics) {
            [peripheral writeValue:[@"hello , ble" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:ca type:CBCharacteristicWriteWithResponse];
            
            NSData *sendData = [@"hello , ble" dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"send data: %@",sendData);

        }

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

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic  error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error writing characteristic value: %@",  [error localizedDescription]);
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
    self.cur_rate = i;
    [self.tableView reloadData];
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

-(void) scan
{
    NSLog(@"scan...");
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
}

@end
