//
//  ConnectionViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "ConnectionViewController.h"
#import "ConnectionCell.h"
#import "ConnectionViewController+CentralManager.h"
#import "MBProgressHUD.h"

@interface ConnectionViewController ()

@end

static  NSString *cellId = @"connectin cell identifier";

@implementation ConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.unConnectedDevices = [[NSMutableArray alloc] init];
        
        // Start up the CBCentralManager
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    scanButton.backgroundColor = RGB(116, 198, 250, 1);
    scanButton.frame = CGRectMake(9, CGRectGetMaxY(tableView.frame)+20, CGRectGetWidth(self.view.frame) - 18, 40);
    [scanButton setTitle:@"扫  描" forState:UIControlStateNormal];
    [scanButton setTitle:@"正  在  扫  描" forState:UIControlStateSelected];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fireRefreshTableTimer) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"central viewWillDisappear");
    [self.centralManager stopScan];
//    [self.unConnectedDevices removeAllObjects];
//    self.centralManager = nil;
    NSLog(@"stopScan");
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");

}

- (void)fireRefreshTableTimer
{
    [self.tableView reloadData];
}

- (void)startScan:(UIButton *)btn
{
    NSLog(@"start scan");
    if (!btn.selected) {
        btn.backgroundColor = [UIColor grayColor];
        [self scan];
    }else{
        btn.backgroundColor = RGB(116, 198, 250, 1);
    }
    
    btn.selected = !btn.selected;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"已绑定";
    }else{
        return @"可用设备";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (int)(self.connectedPeripheral != nil);
    }
    return [self.unConnectedDevices count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (indexPath.section == 0) {
        CBPeripheral *p = self.connectedPeripheral;
        
        NSString *s = p.name;
        if (s == nil) s = @"unknown Device";

        if (p.state == CBPeripheralStateConnected) {
            NSLog(@"%@：CBPeripheralStateConnected。。。。",p.name);
        }

        s = [NSString stringWithFormat:@"%@ %d", s, self.cur_rate];
        [cell setCellSelected:YES title:s];
    } else {
        CBPeripheral *p = self.unConnectedDevices[indexPath.row];

        NSString *s = p.name;
        if (s == nil) s = @"unknown Device";
        
        if (p.state == CBPeripheralStateConnecting) {
            NSLog(@"%@：CBPeripheralStateConnecting。。。。",p.name);
        }

        [cell setCellSelected:NO title:s];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"central didSelectRowAtIndexPath %ld", (long)indexPath.row);
    if (indexPath.section == 0) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    }else{
        CBPeripheral *p = self.unConnectedDevices[indexPath.row];
        [self.centralManager connectPeripheral:p options:nil];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    _centralManager.delegate = nil;
    NSLog(@"DEALLOC");
}
@end
