//
//  RootViewController+ScanPeripharals.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-19.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "RootViewController+ScanPeripharals.h"

#import "DEASensorTag.h"
#import "DEASensorTagViewController.h"
#import "DEAPeripheralTableViewCell.h"
#import "DEAStyleSheet.h"
#import "DEATheme.h"

@implementation RootViewController (ScanPeripharals)

- (void)prepareCentralManager
{
    self.peripheralsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Watch_Width, Watch_Height) style:UITableViewStylePlain];
    self.peripheralsTableView.delegate = self;
    self.peripheralsTableView.dataSource = self;
    self.peripheralsTableView.rowHeight = 140.0;
    self.peripheralsTableView.center = CGPointMake(self.view.center.x, self.view.center.y-2);
    [self.peripheralsTableView registerClass:[DEAPeripheralTableViewCell class] forCellReuseIdentifier:@"DEAPeripheralTableViewCell"];
    [self.view addSubview:self.peripheralsTableView];
    [self.peripheralsTableView setHidden:YES];
    
    /*
     First time DEACentralManager singleton is instantiated.
     All subsequent references will use [DEACentralManager sharedService].
     */
    DEACentralManager *centralManager = [DEACentralManager initSharedServiceWithDelegate:self];
    centralManager.delegate = self;
    
    [centralManager addObserver:self
                     forKeyPath:@"isScanning"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];

    
    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
        cell.yperipheral.delegate = self;
    }
    
    [self.peripheralsTableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    if (object == centralManager) {
        if ([keyPath isEqualToString:@"isScanning"]) {
            if (centralManager.isScanning) {
                [self.scanButton setTitle:@"停止扫描" forState:UIControlStateNormal];
            } else {
                [self.scanButton setTitle:@"开始扫描" forState:UIControlStateNormal];
            }
        }
    }
}

- (void)startScan
{
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    self.peripheralsTableView.hidden = centralManager.isScanning;
    
    if (centralManager.isScanning == NO) {
        [centralManager startScan];
    }
    else {
        [centralManager stopScan];
        
        //        for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
        //            if (cell.yperipheral.cbPeripheral.state == CBPeripheralStateDisconnected) {
        //                cell.rssiLabel.text = @"—";
        //                cell.peripheralStatusLabel.text = @"QUIESCENT";
        //                [cell.peripheralStatusLabel setTextColor:[[DEATheme sharedTheme] bodyTextColor]];
        //            }
        //        }
        
    }
}

#pragma mark - CBCentralManagerDelegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStatePoweredOff:
            break;
            
        case CBCentralManagerStateUnsupported: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dang."
                                                            message:@"Unfortunately this device can not talk to Bluetooth Smart (Low Energy) Devices"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            
            [alert show];
            break;
        }
        case CBCentralManagerStateResetting: {
            [self.peripheralsTableView reloadData];
            break;
        }
        case CBCentralManagerStateUnauthorized:
            break;
            
        case CBCentralManagerStateUnknown:
            break;
            
        default:
            break;
    }
    
    
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    yp.delegate = self;
    
    [yp.cbPeripheral readRSSI];
    
    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
        if (cell.yperipheral == yp) {
            [cell updateDisplay];
            break;
        }
    }
}



- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
        [cell updateDisplay];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    if (yp.isRenderedInViewCell == NO) {
        [self.peripheralsTableView reloadData];
        yp.isRenderedInViewCell = YES;
    }
    
    if (centralManager.isScanning) {
        for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
            if (cell.yperipheral.cbPeripheral == peripheral) {
                if (peripheral.state == CBPeripheralStateDisconnected) {
                    cell.rssiLabel.text = [NSString stringWithFormat:@"%d", [RSSI integerValue]];
                    cell.peripheralStatusLabel.text = @"ADVERTISING";
                    [cell.peripheralStatusLabel setTextColor:[[DEATheme sharedTheme] advertisingColor]];
                } else {
                    continue;
                }
            }
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    for (CBPeripheral *peripheral in peripherals) {
        YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
        if (yp) {
            yp.delegate = self;
        }
    }
    
    [self.peripheralsTableView reloadData];
    
}


- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    for (CBPeripheral *peripheral in peripherals) {
        YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
        if (yp) {
            yp.delegate = self;
        }
    }
    
    [self.peripheralsTableView reloadData];
}

#pragma mark - CBPeripheralDelegate Methods

- (void)performUpdateRSSI:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    
    [peripheral readRSSI];
    
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
    if (error) {
        NSLog(@"ERROR: readRSSI failed, retrying. %@", error.description);
        
        if (peripheral.state == CBPeripheralStateConnected) {
            NSArray *args = @[peripheral];
            [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:2.0];
        }
        
        return;
    }
    
    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
        if (cell.yperipheral) {
            if (cell.yperipheral.isConnected) {
                if (cell.yperipheral.cbPeripheral == peripheral) {
                    cell.rssiLabel.text = [NSString stringWithFormat:@"%@", peripheral.RSSI];
                    break;
                }
            }
        }
    }
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    
    NSArray *args = @[peripheral];
    [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:yp.rssiPingPeriod];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SensorTagCellIdentifier = @"SensorTagCell";
    //static NSString *UnknownPeripheralCellIdentifier = @"UnknownPeripheralCell";
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager peripheralAtIndex:indexPath.row];
    
    UITableViewCell *cell = nil;
    
    DEAPeripheralTableViewCell *pcell = (DEAPeripheralTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SensorTagCellIdentifier];
    
    if (pcell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DEAPeripheralTableViewCell" owner:self options:nil];
        pcell = self.tvCell;
        self.tvCell = nil;
    }
    
    yp.isRenderedInViewCell = YES;
    
    [pcell configureWithPeripheral:yp];
    
    cell = pcell;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[DEAPeripheralTableViewCell class]]) {
        [DEATheme customizePeripheralTableViewCell:(DEAPeripheralTableViewCell *)cell];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            DEACentralManager *centralManager = [DEACentralManager sharedService];
            YMSCBPeripheral *yp = [centralManager peripheralAtIndex:indexPath.row];
            if ([yp isKindOfClass:[DEASensorTag class]]) {
                if (yp.cbPeripheral.state == CBPeripheralStateConnected) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Disconnect the peripheral before deleting."
                                                                   delegate:nil cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                    break;
                }
            }
            [centralManager removePeripheral:yp];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            
        case UITableViewCellEditingStyleInsert:
        case UITableViewCellEditingStyleNone:
            break;
            
        default:
            break;
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    NSInteger result;
    result = centralManager.count;
    return result;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    DEASensorTag *sensorTag = (DEASensorTag *)[centralManager.ymsPeripherals objectAtIndex:indexPath.row];
    
    DEASensorTagViewController *stvc = [[DEASensorTagViewController alloc] initWithNibName:@"DEASensorTagViewController" bundle:nil];
    stvc.sensorTag = sensorTag;
    
    
    [self.navigationController pushViewController:stvc animated:YES];
}

@end
