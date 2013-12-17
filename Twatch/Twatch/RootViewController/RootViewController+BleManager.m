//
//  RootViewController+BleManager.m
//  Twatch
//
//  Created by yixiaoluo on 13-12-7.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController+BleManager.h"
#import "ConnectionViewController+CentralManager.h"

#define NOTIFY_MTU      498

@implementation RootViewController (BleManager)

- (void)sendDataToBle:(id)data transerType:(TransferDataType)type
{
    self.connectedPeripheral.delegate = self;
    
    BOOL connectedADevice = NO;
#ifdef __IPHONE_7_0
    connectedADevice = self.connectedPeripheral.state == CBPeripheralStateConnected;
#else
    connectedADevice = self.connectedPeripheral.isConnected;
#endif
    if (!connectedADevice) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"尚未连接到蓝牙设备，请进入同步界面扫描希望连接的设备" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    self.transferDataType = type;
    
    // Reset the index
    self.sendDataIndex = 0;

    if (self.transferDataType == kTransferDataType_String) {
        self.dataToSend = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        self.dataToSend = UIImageJPEGRepresentation([UIImage imageNamed:@"icon-72.png"], 1.0);
    }
    
    // Send it
    self.curCharacteristic = nil;
    for (CBService *aService in self.connectedPeripheral.services) {
        for (CBCharacteristic *ca in aService.characteristics) {
            if ([ca.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                self.curCharacteristic = ca;
            }
        }
    }
    
    if (self.curCharacteristic == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已连接的蓝牙设备尚未提供此服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

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
    
    // Send it
    [self.connectedPeripheral writeValue:chunk
                       forCharacteristic:self.curCharacteristic type:CBCharacteristicWriteWithResponse];
    
    // It did send, so update our index
    self.sendDataIndex += amountToSend;
}


//- (NSData *)getFirstByte
//{
//    NSUInteger index = (self.transferDataType == kTransferDataType_String) ? 0 : 16;
//    if (self.sendDataIndex == 0 && self.dataToSend.length <= NOTIFY_MTU) {//entire
//        
//        index += 0;
//        
//    }else if (self.sendDataIndex == 0 && self.dataToSend.length > NOTIFY_MTU){//start
//        index += 1;
//    }else if (self.sendDataIndex + NOTIFY_MTU >= self.dataToSend.length){//end
//        index += 3;
//    }else {//continue
//        index += 2;
//    }
//    
//    NSData *firstByte = [NSData dataWithBytes:&index length:sizeof(index)];
//    NSData *secondByte = firstByte;
//    
//    NSMutableData *bytes = [NSMutableData dataWithData:firstByte];
//    [bytes appendData:secondByte];
//    
//    NSLog(@"");
//    
//    return bytes;
//}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didWriteValueForCharacteristic: %@",  [error localizedDescription]);
        return;
    }
    [self sendData];
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral //NS_AVAILABLE(NA, 6_0);
{
    NSLog(@"peripheralDidUpdateName");
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral// NS_DEPRECATED(NA, NA, 6_0, 7_0);
{
    NSLog(@"peripheralDidInvalidateServices");

}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices //NS_AVAILABLE(NA, 7_0);
{
    NSLog(@"didModifyServices");
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Error peripheralDidUpdateRSSI: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    if (error) {
        NSLog(@"Error didDiscoverServices: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didDiscoverIncludedServicesForService: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    if (error) {
        NSLog(@"Error didDiscoverCharacteristicsForService: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didUpdateValueForCharacteristic: %@",  [error localizedDescription]);
    }

}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didUpdateNotificationStateForCharacteristic: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didDiscoverDescriptorsForCharacteristic: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didUpdateValueForDescriptor: %@",  [error localizedDescription]);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didWriteValueForDescriptor: %@",  [error localizedDescription]);
    }

}
@end
