//
//  ConnectionViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "ConnectionViewController.h"
#import "ConnectionCell.h"
#import "MBProgressHUD.h"
#import "BLEServerManager.h"
//#import "BLEServerManager.h"
#import "ViewUtils.h"

@interface ConnectionViewController ()

- (void)_didBLEChanged:(NSNotification *)notice;

@end

static  NSString *cellId = @"connectin cell identifier";


@implementation ConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backBtn setHidden:YES];
    
    UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?25:5, 30, 30)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:backBtn];
    
    // Do any additional setup after loading the view from its nib.
    CGRect frame = CGRectChangeY(self.view.frame, self.yOffset);
    frame = CGRectChangeHeight(frame, self.height);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset, CGRectGetWidth(self.view.frame), IS_IPHONE_5 ? self.height-70-10 : self.height-170) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    [tableView registerClass:[ConnectionCell class] forCellReuseIdentifier:cellId];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //scanButton.backgroundColor = RGB(116, 198, 250, 1);
    scanButton.backgroundColor = [UIColor colorWithHex:@"1ca1f6"];
    scanButton.frame = CGRectMake(9, CGRectGetMaxY(tableView.frame)+20, CGRectGetWidth(self.view.frame) - 18, 40);
    [scanButton setTitle:NSLocalizedString(@"start bluetooth advertisting",nil) forState:UIControlStateNormal];
//    [scanButton setTitle:@"正 在 蓝 牙 广 播" forState:UIControlStateSelected];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
    scanButton.selected = [BLEServerManager sharedManager].peripheralManager.isAdvertising ;
    [self.view addSubview:scanButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didBLEChanged:) name:kBLEChangedNotification object:nil];
}

- (void)backClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
//    BLEServerManager *manager = [BLEServerManager sharedManager];
//    if (manager.peripheralManager.isAdvertising) {
//        [manager stopAdvertising];
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_didBLEChanged:(NSNotification *)notice
{
    [self.tableView reloadData];
}

- (void)startScan:(UIButton *)btn
{
    BLEServerManager *manger = [BLEServerManager sharedManager];
    if (![manger isBLEPoweredOn]) {
        return;
    }
    if (!manger.peripheralManager.isAdvertising ) {
        btn.backgroundColor = [UIColor colorWithHex:@"6fc6fc"];
        [btn setTitle:NSLocalizedString(@"Bluetooth is advertisting",nil) forState:UIControlStateNormal];
        
        [manger startAdvertising];
    }else{
        btn.backgroundColor = [UIColor colorWithHex:@"1ca1f6"];
        [btn setTitle:NSLocalizedString(@"start bluetooth advertisting",nil) forState:UIControlStateNormal];
        [manger stopAdvertising];
    }
    
    btn.selected = manger.peripheralManager.isAdvertising ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return @"已绑定";
//    }
//    else{
//        return @"可用设备";
//    }
    
    return NSLocalizedString(@"paired watch",nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 0) {
//        return (int)([BLEServerManager sharedManager].transferCharacteristic != nil);
//    }
//    return [[BLEManager sharedManager].unConnectedDevices count];
    
    return (int)([BLEServerManager sharedManager].isWatchConnected);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
//    if (indexPath.section == 0) {
//        CBPeripheral *p = [BLEManager sharedManager].connectedPeripheral;
//        if (p != nil)
//        {
//            NSString *s = p.name;
//            if (s == nil) s = @"unknown Device";
//            
//            if (p.state == CBPeripheralStateConnected) {
//                NSLog(@"%@：CBPeripheralStateConnected。。。。",p.name);
//            }
//            
//            s = [NSString stringWithFormat:@"%@", s];
//            [cell setCellSelected:YES title:s];
//        }
//        
//        
//    } else {
//        CBPeripheral *p = [BLEManager sharedManager].unConnectedDevices[indexPath.row];
//
//        NSString *s = p.name;
//        if (s == nil) s = @"unknown Device";
//        
//        if (p.state == CBPeripheralStateConnecting) {
//            NSLog(@"%@：CBPeripheralStateConnecting。。。。",p.name);
//        }
//
//        [cell setCellSelected:NO title:s];
//    }
//    
//    return cell;
    [cell setCellSelected:YES title:[[NSUserDefaults standardUserDefaults] objectForKey:kBLEBindingWatch]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"central didSelectRowAtIndexPath %ld", (long)indexPath.row);

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确认断开和手表的连接？"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:@"取消", nil];
    [alert show];

}



- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    NSLog(@"DEALLOC");
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]) {
        [[BLEServerManager sharedManager] sendUnboundCommand];
    }
}
@end
