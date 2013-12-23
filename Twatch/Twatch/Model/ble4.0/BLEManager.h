//
//  BLEManager.h
//  Twatch
//
//  Created by 龚 涛 on 13-12-21.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (nonatomic) NSMutableArray *unConnectedDevices;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) void (^writeblock)(void);

//write
@property (nonatomic, strong)      NSData                    *dataToSend;
@property (nonatomic, strong)      NSInputStream             *inputStream;
@property (nonatomic, strong)      NSString                  *toFilePath;
@property (nonatomic, readwrite)   NSInteger                 sendDataIndex;
@property (nonatomic, readwrite)   NSInteger                 sendDataSize;
@property (nonatomic, readwrite)   TransferDataType          transferDataType;
@property (strong, nonatomic)      CBCharacteristic          *curCharacteristic;

+ (BLEManager *)sharedManager;

- (void)scan;

- (void)stopScan;

- (void)sendFileDataToBle:(NSString *)path;

- (void)sendStrDataToBle:(NSString *)str;

- (void)saveConnectedWatch:(NSUUID *)identifier;

- (void)removeConnectedWatch;

//接口

- (void)sendSearchWatchCommand;

- (void)sendUnboundCommand;

- (void)sendFolderPathCommand:(NSString *)path;

- (void)sendAppInstallCommand:(NSString *)apkUrl;

@end
