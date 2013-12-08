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
    self.transferDataType = type;
    
    // Reset the index
    self.sendDataIndex = 0;

    if (self.transferDataType == kTransferDataType_String) {
        self.dataToSend = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
    }else{
    
    }
    
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}

- (NSData *)getFirstTwoBytes
{
    NSUInteger index = (self.transferDataType == kTransferDataType_String) ? 0 : 16;
    if (self.sendDataIndex == 0 && self.dataToSend.length <= NOTIFY_MTU) {//entire
        
        index += 0;

    }else if (self.sendDataIndex == 0 && self.dataToSend.length > NOTIFY_MTU){//start
        index += 1;
    }else if (self.sendDataIndex + NOTIFY_MTU >= self.dataToSend.length){//end
        index += 3;
    }else {//continue
        index += 2;
    }
    
    NSData *firstByte = [NSData dataWithBytes:&index length:sizeof(index)];
    NSData *secondByte = firstByte;
    
    NSMutableData *bytes = [NSMutableData dataWithData:firstByte];
    [bytes appendData:secondByte];
    
    NSLog(@"");
    
    return bytes;
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
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    // Start sending
    [self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        NSMutableData *dataWillSend = [[NSMutableData alloc] init];
        [dataWillSend appendData:[self getFirstTwoBytes]];
        [dataWillSend appendData:chunk];
        
        // Send it
        didSend = [self.peripheralManager updateValue:dataWillSend forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            return;
        }
    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}
@end
