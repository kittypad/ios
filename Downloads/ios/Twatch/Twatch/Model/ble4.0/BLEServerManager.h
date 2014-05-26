//
//  BLEServerManager.h
//  Twatch
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import "DownloadObject.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>  

//static BOOL isWatchConnected;

@interface BLEServerManager : NSObject <CBPeripheralManagerDelegate, UIAlertViewDelegate>

//经纬度
@property (nonatomic)CLLocationManager *locationManager;
@property (nonatomic,strong )NSTimer *locationTimer;//定时任务，每10分钟更新一次经纬度
@property (nonatomic )int latitude;
@property (nonatomic )int longitude;

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) NSMutableArray *unConnectedDevices;
//@property (strong, nonatomic) CBCe *connectedPeripheral;
@property (nonatomic, strong) void (^writeblock)(void);
@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, assign) BOOL isWatchConnected;
@property (nonatomic, assign) BOOL isTransferCharacter;
@property (nonatomic, assign) BOOL isNotifyCharacter;

//write
@property (nonatomic, strong)      NSData                    *dataToSend;
@property (nonatomic, strong)      NSInputStream             *inputStream;
@property (nonatomic, strong)      NSString                  *toFilePath;
@property (nonatomic, readwrite)   NSInteger                 sendDataIndex;
@property (nonatomic, readwrite)   NSInteger                 sendDataSize;
@property (nonatomic, readwrite)   TransferDataType          transferDataType;
//@property (strong, nonatomic)      CBCharacteristic          *curCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *notifyCharacteristic;
@property (strong, nonatomic) CBMutableService          *transferService;

@property (nonatomic, readwrite)   NSInteger                 fileNameIndex;

@property (nonatomic, readwrite)   NSInteger                 fileNameSize;

@property (nonatomic, readwrite)   NSInteger                 retryCount;//蓝牙重新广播次数

@property (nonatomic, assign) BOOL isSendFileName;//表示在发送应用的文件名
@property (nonatomic, assign) BOOL isResendFile;//表示发送文件过程中出错，需要重发
@property (nonatomic, strong) NSMutableData *storeData;//用来保存发送失败的包

@property (nonatomic, strong) NSString *mobileBLEName;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic,strong )NSTimer *timer;//定时任务，判断是否和手表绑定

@property (nonatomic, strong) NSString *weatherInfo;//天气信息

+ (BLEServerManager *)sharedManager;
/**
 *  Start advertising as a Bluetooth peripheral.
 *
 *  The advertisement will only begin when the underlying `CBPeripheralManager`
 *  is in the `CBPeripheralManagerStatePoweredOn` state. When the advertising
 *  begins, the delegate method `ANCSServer:didStartAdvertisingWithError:`
 *  will be called.
 */
- (void)startAdvertising;

/**
 *  Stop advertising as a Bluetooth peripheral.
 */
- (void)stopAdvertising;

- (void)saveConnectedWatch:(NSDictionary *)responseDic;

- (void)removeConnectedWatch;

- (BOOL)isBLEPoweredOn;

- (BOOL)isBLEConnected;

- (BOOL)isBLEConnectedWithoutAlert;

- (NSData *)getFirstByte;

-(void)updateLocation;

//接口

- (void)sendSearchWatchCommand;

- (void)sendBoundCommand;

- (void)sendUnboundCommand;

- (void)sendTimeCommand:(NSDate *)date finish:(void (^)(void))block;

- (void)sendAppInstallCommand:(DownloadObject *)obj;

- (void)sendBackgroundImageCommand:(DownloadObject *)obj;

- (void)sendBackgroundImageDataCommand:(NSString *)path;

- (void) sendWatchVersion:(NSString *)fileName;


@end
